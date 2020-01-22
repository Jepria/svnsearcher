create or replace package body pkg_SvnSearcherIndex is
/* package body: pkg_SvnSearcherIndex::body */

/* ivar: lg_logger_t
  Интерфейсный объект для модуля Logging
*/
logger lg_logger_t := lg_logger_t.GetLogger(
  moduleName => pkg_SvnSearcherBase.Module_Name
  , objectName => 'pkg_SvnSearcherIndex'
);




/* group: Константы */

/* const: Max_IndexDirRecursiveLevel
  Максимальный уровень рекурсии для получения списка директорий.
*/
Max_IndexDirRecursiveLevel constant integer := 3;

/* const: Text_CtxFormat
  Формат текстовых данных для колонки "format column" индекса типа "CONTEXT".
*/
Text_CtxFormat constant varchar2(10) := 'TEXT';

/* const: Utf8_CtxCharset
  Кодировка "UTF-8" для колонки "charset column" индекса типа "CONTEXT".
  См. <http://docs.oracle.com/cd/B19306_01/text.102/b14218/cdatadic.htm#i1007132>
*/
Utf8_CtxCharset constant varchar2(10) := 'UTF8';




/* group: Переменные процесса индексирования */

/* ivar: indexedNewFileCount
  Проиндексировано новых файлов.
*/
indexedNewFileCount integer;

/* ivar: indexedUpdatedFileCount
  Обновлёно файлов.
*/
indexedUpdatedFileCount integer;

/* ivar: deletedFileCount
  Удалено файлов.
*/
deletedFileCount integer;

/* ivar: ignoredFileCount
  Проигнорировано файлов.
*/
ignoredFileCount integer;

/* ivar: remainedFileCount
  Количество файлов без изменений.
*/
remainedFileCount integer;




/* group: Функции */



/* group: Утилиты */

/* func: encodeXml
  Кодирует XML для того, чтобы индексировались значения атрибутов.

  Параметры:
  xmlData                     - данные XML в виде blob

  Возврат:
  - кодированные данные в виде blob;
*/
function encodeXml(
  xmlData blob
)
return blob
is
-- encodeXml
begin
  return
    pkg_TextCreate.convertToBlob(
      replace(
      replace(
      replace(
        pkg_TextCreate.convertToClob( xmlData)
        , '\'
        , '\\'
      )
        , '<'
        , '\<'
      )
        , '>'
        , '\>'
      )
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка кодирования текста XML'
      )
    , true
  );
end encodeXml;

/* func: decodeXmlSnippet
  Декодирование XML, обратное <encodeXml>, из снипета в виде HTML.

  Параметры:
  encodedSnippet               - текст xml в виде HTML, кодированный
                                 <encodedXml>;

  Возврат:
  - декодированный снипет ( участок текста);
*/
function decodeXmlSnippet(
  encodedSnippet varchar2
)
return varchar2
is
-- decodeXml
begin
  return
    replace(
    replace(
    replace(
      encodedSnippet
      , '\\'
      , '\'
    )
      , '\&gt'
      , '&gt'
    )
      , '\&lt'
      , '&lt'
    )
  ;
end decodeXmlSnippet;

/* func: getRepositoryUrl
  Получение URL репозитория по имени.

  Параметры:
  serverName                  - имя сервера
  repositoryName              - имя репозитория
*/
function getRepositoryUrl(
  serverName varchar2
  , repositoryName varchar2
)
return varchar2
is
-- getRepositoryUrl
begin
  return
    'svn://' || serverName || '/' || repositoryName
  ;
end getRepositoryUrl;

/* proc: openConnection
  Соединение с репозиторием SVN с использованием опций модуля
  <pkg_SvnSearcherBase::Наименования опций для соединения с репозиторием>;

  Параметры:
  repositoryName              - имя репозитория
*/
procedure openConnection(
  repositoryName varchar2
)
is

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_SvnSearcherBase.Module_Name
  );

-- openConnection
begin
  pkg_Subversion.openConnection(
    repositoryUrl => getRepositoryUrl(
      serverName => optionList.getString( pkg_SvnSearcherBase.SvnServerName_OptionSName)
      , repositoryName => repositoryName
    )
    , login => optionList.getString( pkg_SvnSearcherBase.SvnLogin_OptionSName)
    , password => optionList.getString( pkg_SvnSearcherBase.SvnPassword_OptionSName)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка соединения с репозиторием ( '
        || 'repositoryName="' || repositoryName || '"'
        || ')'
      )
    , true
  );
end openConnection;

/* proc: closeConnection
  Закрытие соединения с репозиторием.
*/
procedure closeConnection
is
-- closeConnection
begin
  pkg_Subversion.closeConnection();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка закрытия соединения с репозиторием'
      )
    , true
  );
end closeConnection;

/* func: isOfMask
  Возвращаем 1, если имя файла удовлетворяет хотя бы одной из масок
  перечисленных в MaskSet через ',', и 0 в противном случае.

  Параметры:
  fileName                    - имя файла
  maskSet                     - маски для файлов (через ',')
*/
function isOfMask(
  fileName varchar2
  , maskSet varchar2
)
return integer
is
  tmpString varchar2( 1000 );
  safeCycle integer := 0;
begin
  tmpString := upper( MaskSet || ',' );
  loop
    exit when tmpString is null
              or upper( fileName )
              like Substr( tmpString , 1, Instr( tmpString, ',' ) - 1 );
    tmpString := Substr( tmpString, Instr( tmpString, ',' ) + 1 );
    safeCycle := safeCycle + 1;
    if safeCycle > 100 then
      raise_application_error(
        pkg_Error.ProcessError,
        'Произошло зацикливание в функции IsOfMask'
      );
    end if;
  end loop;
  if upper( fileName ) like Substr( tmpString , 1, Instr( tmpString, ',' ) - 1 ) then
    return 1;
  else
    return 0;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo,
    'Ошибка IsOfMask. fileName = "'
    || fileName || '" maskSet = "' || maskSet || '"'
    , true
  );
end isOfMask;



/* group: Индексирование */

/* proc: finishRepositoryIndex
  Завершение индексирования репозитория.

  Параметры:
  repositoryName              - имя SVN репозитория
*/
procedure finishRepositoryIndex(
  repositoryName varchar2
)
is
-- finishRepositoryIndex
begin
  merge into
    ss_repository r
  using
    (
    select
      repositoryName as repository_name
      , sysdate as last_all_index_date
    from
      dual
    ) t
  on
    (
      r.repository_name = t.repository_name
    )
  when not matched then insert (
    repository_id
    , repository_name
    , last_all_index_date
  )
  values(
    ss_repository_seq.nextval
    , t.repository_name
    , t.last_all_index_date
  )
  when matched then update set
    r.last_all_index_date = t.last_all_index_date
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка завершения индексированя репозитория'
      )
    , true
  );
end finishRepositoryIndex;

/* proc: synchronizeIndex
  Синхронизация индекса <ss_file::ss_file_ctx_search>;
*/
procedure synchronizeIndex
is
-- endIndex
begin
  ctxsys.ctx_ddl.sync_index(
    idx_name => 'SS_FILE_CTX_SEARCH'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка синхронизации индекса'
      )
    , true
  );
end synchronizeIndex;

/* proc: indexDirectory
  Индексирование директории в SVN.

  Параметры:
  repositoryName              - имя SVN репозитория
  directorySvnPath            - относительный путь директории в SVN
  maxFinishTime               - время, после которого индексирование
                                прекращается
  fileNameMaskList            - список масок имён файлов для индексирования
  excludeSvnPathMaskList      - список масок путей файлов для исключения из
                                индексирования
  utf8FileMaskList            - маска для имён файлов, содержащих ( через ",")
                                ( по-умолчанию используется значение опции
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - удаление неактуальных устаревших данных (
                                по-умолчанию, да)

  Замечание:
  - предполагается, что соединение с SVN установлено;
  - процедура выполняется в автономной транзакции для скорейшей возможности
    использования результатов индексирования;
*/
procedure indexDirectory(
  repositoryName varchar2
  , directorySvnPath varchar2
  , maxFinishTime date
  , fileNameMaskList varchar2
  , excludeSvnPathMaskList varchar2
  , utf8FileMaskList varchar2
  , maxIndexFileSize integer
  , deleteOldDataFlag boolean := null
)
is
  pragma autonomous_transaction;

  /*
    Удаление из <svn_file_tmp> данных не подпадающих под условия
    индексирования.
  */
  procedure filterFile
  is
    deletedCount integer;
  begin
    insert into
      ss_file_exclude_tmp
    (
      file_tmp_id
    )
    select
      file_tmp_id
    from
      svn_file_tmp
    where
      not (
        (
          pkg_SvnSearcherIndex.isOfMask( file_name, fileNameMaskList) = 1
          or fileNameMaskList is null
        )
        and (
          pkg_SvnSearcherIndex.isOfMask( svn_path, excludeSvnPathMaskList) = 0
          or excludeSvnPathMaskList is null
        )
        and (
          file_size <= maxIndexFileSize
          or maxIndexFileSize is null
        )
      )
    ;
    if logger.isTraceEnabled() then
      -- Выводим расширения которые не попали в выборку
      for extention in
        (
        select
          substr(
            file_name
            , instr( file_name, '.', -1) + 1
          ) as file_extention
          , max( f.svn_path) as example_svn_path
        from
          ss_file_exclude_tmp e
        inner join
          svn_file_tmp f
        on
          f.file_tmp_id = e.file_tmp_id
        group by
          substr(
            file_name
            , instr( file_name, '.', -1) + 1
          )
        )
      loop
        logger.trace(
          'excluded extention: ' || extention.file_extention
          || '; example: "' || extention.example_svn_path || '"'
        );
      end loop;
    end if;
    delete from
      svn_file_tmp
    where
      file_tmp_id in
      (
      select
        file_tmp_id
      from
        ss_file_exclude_tmp
      )
    ;
    deletedCount := sql%rowcount;
    ignoredFileCount := ignoredFileCount + deletedCount;
    logger.debug( 'svn_file_tmp: delete: ' || to_char( deletedCount));
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка удаления данных'
        )
      , true
    );
  end filterFile;

  /*
    Обновление данных проверенных файлов.
  */
  procedure updateCheckedFile
  is
    -- Количество неизменённых файлов
    fileCount integer;
  begin
    update
      ss_file s
    set
      s.last_check_date = sysdate
    where
      s.file_id in
      (
      select
        f.file_id
      from
        svn_file_tmp t
      inner join
        ss_file f
      on
        -- Файлы не изменились
        f.repository_name = repositoryName
        and f.svn_path = t.svn_path
        and f.revision = t.revision
      )
    ;
    fileCount := sql%rowcount;
    remainedFileCount := remainedFileCount + fileCount;
    logger.debug( 'files not changed: ' || to_char( fileCount));
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка обновления данных проверяемых файлов'
        )
      , true
    );
  end updateCheckedFile;

  /*
    Обновление данных файлов.
  */
  procedure updateFileData
  is

    -- Номер файла
    fileNumber integer := 0;

    -- Курсор для получения изменившихся в SVN файлов
    cursor svnFileCur is
      select
        t.svn_path
        , t.file_name
        , t.revision
        , t.author
        , t.last_modification as svn_last_modification
        , t.file_size
        , f.file_id
        , case when
            pkg_SvnSearcherIndex.isOfMask( t.file_name, utf8FileMaskList) = 1
          then
            Utf8_CtxCharset
          end as ctx_charset
        , count(1) over() as file_count
      from
        svn_file_tmp t
      left join
        ss_file f
      on
        -- Файлы изменились
        f.repository_name = repositoryName
        and f.svn_path = t.svn_path
      where
        -- Либо файл не был проиндексирован
        f.revision is null
        -- Либо он изменился
        or t.revision > f.revision
      order by
        -- Очередь: сначала индексируем новые файлы, потом устаревшие
        f.last_refresh_date nulls first
        , t.last_modification
    ;

    /*
      Обновление данных файла.
    */
    procedure mergeFile( svnFile svnFileCur%rowtype)
    is

      -- Данные файла
      fileData blob;
    begin
      logger.trace(
        'merging file: '
        || to_char( fileNumber) || ' of ' || to_char( svnFile.file_count)
        || ': ' || repositoryName || '/' || svnFile.svn_path
      );
      pkg_Subversion.getSvnFile(
        fileData => fileData
        , fileSvnPath => svnFile.svn_path
      );
      if svnFile.file_id is not null then
        update
          ss_file s
        set
          revision                = svnFile.revision
          , author                = svnFile.author
          , svn_last_modification = svnFile.svn_last_modification
          , file_size             = svnFile.file_size
          , file_data             =
              case
                when lower( svnFile.file_name) like '%.xml'
              then
                encodeXml( fileData)
              else
                fileData
              end
          , ctx_format            =
              case when
                svnFile.ctx_charset is not null
                or lower( svnFile.file_name) like '%.xml'
              then
                Text_CtxFormat
              end
          , ctx_charset           = svnFile.ctx_charset
          , last_check_date       = sysdate
          , last_refresh_date     = sysdate
        where
          s.file_id = svnFile.file_id
        ;
        if sql%rowcount = 1 then
          logger.trace( 'record updated');
        else
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Неверное количество записей при обновлении данных'
          );
        end if;
        indexedUpdatedFileCount := indexedUpdatedFileCount + 1;
      else
        insert into
          ss_file
        (
          file_id
          , repository_name
          , svn_path
          , file_name
          , revision
          , author
          , svn_last_modification
          , file_size
          , file_data
          , ctx_format
          , ctx_charset
          , last_check_date
          , last_refresh_date
        )
        values(
          ss_file_seq.nextval
          , repositoryName
          , svnFile.svn_path
          , svnFile.file_name
          , svnFile.revision
          , svnFile.author
          , svnFile.svn_last_modification
          , svnFile.file_size
          , case
              when lower( svnFile.file_name) like '%.xml'
            then
              encodeXml( fileData)
            else
              fileData
            end
          , case when
              svnFile.ctx_charset is not null
              or lower( svnFile.file_name) like '%.xml'
            then
              Text_CtxFormat
            end
          , svnFile.ctx_charset
          , sysdate
          , sysdate
        );
        indexedNewFileCount := indexedNewFileCount + 1;
      end if;
      commit;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка обновления данных файла ( svn_path="' || svnFile.svn_path || '")'
          )
        , true
      );
    end mergeFile;

  begin
    fileNumber := 0;
    for svnFile in svnFileCur loop
      if sysdate < maxFinishTime then
        fileNumber := fileNumber + 1;
        mergeFile( svnFile => svnFile);
        synchronizeIndex();
      else
        logger.info( 'Индексирование директории: "' || directorySvnPath || '": Достигнут лимит времени: {' || to_char( maxFinishTime, 'dd.mm.yyyy hh24:mi:ss') || '}');
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка обновления данных файлов'
        )
      , true
    );
  end updateFileData;

  /*
    Удаление устаревших неактуальных данных.
  */
  procedure deleteOldData
  is

    -- Количество устаревших файлов
    oldFileCount integer;
  begin
    for c in (
      select
        *
      from
        ss_file s
      where
        repository_name = repositoryName
        and svn_path like directorySvnPath || '%'
        and
        (
          s.repository_name
          , s.svn_path
        ) not in
        (
        select
          repositoryName as repository_name
          , t.svn_path
        from
          svn_file_tmp t
        )
    ) loop
      logger.debug( repositoryName || ':' || c.svn_path);
    end loop;
    delete from
      ss_file s
    where
      repository_name = repositoryName
      and svn_path like directorySvnPath || '%'
      and
      (
        s.repository_name
        , s.svn_path
      ) not in
      (
      select
        repositoryName as repository_name
        , t.svn_path
      from
        svn_file_tmp t
      )
    ;
    oldFileCount := sql%rowcount;
    logger.debug( 'deleteOldData: ' || to_char( oldFileCount));
    deletedFileCount := deletedFileCount + oldFileCount;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка удаления устаревших неактуальных данных'
        )
      , true
    );
  end deleteOldData;

-- indexDirectory
begin
  delete from svn_file_tmp;
  pkg_Subversion.getFileTree(
    dirSvnPath => directorySvnPath
    , maxRecursiveLevel => null
    , directoryRecordFlag => false
  );
  filterFile();
  if coalesce( deleteOldDataFlag, true) then
    deleteOldData();
  end if;
  updateCheckedFile();
  updateFileData();
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка индексирования директории в SVN ( '
        || 'directorySvnPath="' || directorySvnPath || '"'
        || ')'
      )
    , true
  );
end indexDirectory;

/* proc: indexRepository
  Индексирование репозитория.

  Параметры:
  repositoryName              - имя SVN репозитория
  directoryMaskList           - список масок директорий для индексирования
  maxFinishTime               - время, после которого индексирование
                                прекращается
  utf8FileMaskList            - маска для имён файлов, содержащих ( через ",")
                                ( по-умолчанию используется значение опции
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - удаление неактуальных устаревших данных (
                                по-умолчанию, да)
*/
procedure indexRepository(
  repositoryName varchar2
  , directoryMaskList varchar2 := null
  , maxFinishTime date := null
  , utf8FileMaskList varchar2 := null
  , deleteOldDataFlag boolean := null
)
is

  -- Список опций модуля
  optionList opt_option_list_t;

  -- Значения опций модуля
  fileNameMaskList varchar2(32767);
  excludeSvnPathMaskList varchar2(32767);
  maxIndexFileSize integer;
  usedUtf8FileMaskList varchar2(32767);

  -- Количество директорий для индексирования
  directoryCount integer;

  /*
    Получение списка директорий для индексирования.
  */
  procedure getDirectoryList
  is
    pragma autonomous_transaction;
  begin
    delete from svn_file_tmp;
    pkg_Subversion.getFileTree(
      dirSvnPath => ''
      , maxRecursiveLevel =>
          case when
            directoryMaskList is null
          then
            1
          else
            Max_IndexDirRecursiveLevel
          end
      , directoryRecordFlag => true
    );
    delete from
      ss_index_directory_tmp
    ;
    insert into
      ss_index_directory_tmp
    (
      directory_svn_path
      , svn_last_modification
    )
    select
      svn_path
      , last_modification
    from
      svn_file_tmp
    where
      (
        pkg_SvnSearcherIndex.isOfMask( svn_path, directoryMaskList) = 1
        or directoryMaskList is null
      )
      and directory_flag = 1
    ;
    directoryCount := sql%rowcount;
    logger.info( 'Найдено директорий для индексирования: ' || to_char( directoryCount));
    commit;
  exception when others then
    rollback;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения списка модулей'
        )
      , true
    );
  end getDirectoryList;

  /*
    Удаление данных файлов, не попадающих под индексирование.
  */
  procedure deleteExcessFile
  is
    deletedExcessFileCount integer;
  begin
    delete from
      ss_file f
    where
      repository_name = repositoryName
      and not exists (
        select
          1
        from
          ss_index_directory_tmp  d
        where
          f.svn_path like d.directory_svn_path || '%'
      );
    deletedExcessFileCount := sql%rowcount;
    logger.debug( 'Удалено файлов, не попадающих под индексирование: ' || to_char( deletedExcessFileCount));
    deletedFileCount := deletedFileCount + deletedExcessFileCount;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка удаления файлов, не попадающих под индексирование.'
        )
      , true
    );
  end deleteExcessFile;

  /*
    Индекcирование найденных директорий.
  */
  procedure indexDirectory
  is
  begin
    for directory in (
      select
        directory_svn_path
        , rownum as directory_number
      from
        (
        select
          directory_svn_path
        from
          ss_index_directory_tmp
        order by
          svn_last_modification
        )
    ) loop
      logger.debug(
        'directory: ' || to_char( directory.directory_number) || ' of '
        || to_char( directoryCount) || ': '
        || repositoryName || '/' || directory.directory_svn_path
      );
      pkg_SvnSearcherIndex.indexDirectory(
        repositoryName => repositoryName
        , directorySvnPath => directory.directory_svn_path
        , maxFinishTime => maxFinishTime
        , fileNameMaskList => fileNameMaskList
        , excludeSvnPathMaskList => excludeSvnPathMaskList
        , utf8FileMaskList => usedUtf8FileMaskList
        , maxIndexFileSize => maxIndexFileSize
        , deleteOldDataFlag => deleteOldDataFlag
      );
      if sysdate > maxFinishTime then
        logger.info( 'Индексирование репозитория "' || repositoryName || '": Достигнут лимит времени: {' || to_char( maxFinishTime, 'dd.mm.yyyy hh24:mi:ss') || '}');
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка индексирования директорий'
        )
      , true
    );
  end indexDirectory;

-- indexRepositoryList
begin
  logger.info( 'Индексирование репозитория: "' || repositoryName || '"');
  indexedNewFileCount := 0;
  indexedUpdatedFileCount := 0;
  deletedFileCount := 0;
  ignoredFileCount := 0;
  remainedFileCount := 0;
  openConnection( repositoryName => repositoryName);
  optionList := opt_option_list_t(
    moduleName => pkg_SvnSearcherBase.Module_Name
  );
  fileNameMaskList := optionList.getValueList(
    pkg_SvnSearcherBase.FileNameMaskList_OptionSName
  );
  logger.debug( 'fileNameMaskList="' || fileNameMaskList || '"');
  excludeSvnPathMaskList := optionList.getValueList(
    pkg_SvnSearcherBase.ExcludePathList_OptionSName
  );
  logger.debug( 'excludeSvnPathMaskList="' || excludeSvnPathMaskList || '"');
  usedUtf8FileMaskList := coalesce(
    utf8FileMaskList
    , optionList.getValueList(
        pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName
      )
  );
  logger.debug( 'usedUtf8FileMaskList="' || usedUtf8FileMaskList || '"');
  maxIndexFileSize := optionList.getNumber(
    pkg_SvnSearcherBase.MaxIndexFileSize_OptionSName
  );
  logger.debug( 'maxIndexFileSize=' || to_char( maxIndexFileSize));
  getDirectoryList();
  deleteExcessFile();
  indexDirectory();
  closeConnection();
  if sysdate < maxFinishTime then
    finishRepositoryIndex( repositoryName => repositoryName);
  end if;
  logger.info( 'Проиндексировано новых файлов: ' || to_char( indexedNewFileCount));
  logger.info( 'Обновлено файлов для индексирования: ' || to_char( indexedUpdatedFileCount));
  logger.info( 'Удалено файлов из индекса: ' || to_char( deletedFileCount));
  logger.info( 'Проигнорировано файлов: ' || to_char( ignoredFileCount));
  logger.info( 'Файлов без изменений: ' || to_char( remainedFileCount));
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка индексирования репозитория '
      )
    , true
  );
end indexRepository;

end pkg_SvnSearcherIndex;
/
