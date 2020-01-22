create or replace package body pkg_SvnSearcher is
/* package body: pkg_SvnSearcher::body */

/* ivar: lg_logger_t
  Интерфейсный объект для модуля Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_SvnSearcherBase.Module_Name
    , objectName => 'pkg_SvnSearcher'
  );

/* const: Default_InternalResultLimit
  Лимит внутреннего поиска для оптимизации производительности по умолчанию
  ( органичение внутренней выборки по rownum)
*/
Default_InternalResultLimit constant integer := 500;



/* group: Функции */

/* func: getResultUrl
  Получение URL для результатов поиска.

  Параметры:
  serverName                  - имя сервера ( хост)
  repositoryName              - наименование репозитория
  svnPath                     - относительный путь к файлу в SVN
  login                       - логин для подстановки в URL ( не обязателен)
  password                    - пароль для подстановки в URL ( не обязателен)
*/
function getResultUrl(
  serverName varchar2
  , repositoryName varchar2
  , svnPath varchar2
  , login varchar2
  , password varchar2
)
return varchar2
is
-- getResultUrl
begin
  return
    utl_url.escape(
      'http://'
      ||
      case when
        login is not null
      then
        login || ':' || password || '@'
      end
      || serverName || '/repo/' || repositoryName || '/' || svnPath
      , url_charset => 'UTF8'
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения URL для результатов поиска'
      )
    , true
  );
end getResultUrl;

/* func: getRepository
  Получение списка репозиториев.

  Поля возвращаемого курсора:
  repository_name             - маска имени файла
*/
function getRepository
return sys_refcursor
is

  resultCursor sys_refcursor;

-- getRepository
begin
  open
    resultCursor
  for
  select
    repository_name
  from
    ss_repository
  ;
  return
    resultCursor
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения списка репозиториев'
      )
    , true
  );
end getRepository;

/* func: getFileNameMask
  Получение списка масок файлов.

  Поля возвращаемого курсора:
  file_name_mask              - маска имени файла
*/
function getFileNameMask
return sys_refcursor
is
  resultCursor sys_refcursor;

  -- Список масок файлов в виде строки через ","
  fileMaskList varchar2(32767) :=
    opt_option_list_t(
      moduleName => pkg_SvnSearcherBase.Module_Name
    ).getValueList( pkg_SvnSearcherBase.FileNameMaskList_OptionSName)
  ;

-- getFileNameMask
begin
  open
    resultCursor
  for
  select
    column_value as file_name_mask
  from
    table( pkg_Common.split( fileMaskList, ','))
  ;
  return
    resultCursor
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения списка кодов файлов'
      )
    , true
  );
end getFileNameMask;

/* func: findString
  Поиск подстроки в SVN.

  Параметры:
  operatorId                  - id оператора
  searchString                - фраза для поиска ( возможен шаблон ,
                                содержащий "%", "?", подставляется в
                                оператор CONTAINS
                                <http://docs.oracle.com/cd/E11882_01/text.112/e24435/query.htm#CCAPP9175>)
  pageRowCount                - количество записей результатов на странице (
                                обязательный параметр)
  pageNumber                  - номер страницы ( по-умолчанию 1)
  internalResultLimit         - лимит внутреннего поиска для оптимизации
                                производительности ( по-умолчанию
                                <body::Default_InternalResultLimit>)
  svnLogin                    - логин SVN для показа куска текста, где найдена строка
  svnPassword                 - пароль SVN для показа куска текста, где найдена строка
  repositoryNameList          - список репозиториев через ","
  fileNameList                - список масок для имён файлов через "," (
                                заполнение в интерфейсе предполагается с
                                использованием <getFileNameMask>)
  svnPathList                 - список масок путей к файлу SVN через ","
  skipSvnPathList             - список масок путей к файлу SVN через "," для
                                игнорирования
  lastModificationFrom        - дата модификации файла SVN от
  lastModificationTo          - дата модификации файла SVN по
  revisionFrom                - ревизия ( правка) в SVN от
  revisionTo                  - ревизия ( правка) в SVN по
  author                      - автор в SVN
  fileSizeFrom                - размер файла от
  fileSizeTo                  - размер файла по
  svnPathOrderFlag            - признак применения сотировки по пути в SVN
                                ( по умолчанию по дате модификации)

  Поля возвращаемого курсора:
  file_id                     - id файла, первичный ключ
  repository_name             - наименование репозитория
  svn_path                    - путь к файлу в репозитории SVN
  url                         - ссылка ( URL)
  file_extention              - расширение файла
  svn_last_modification       - дата/время модификации в SVN
  revision                    - номер ревизии ( правки ) SVN
  author                      - автор в SVN
  file_size                   - размер файла
  last_check_date             - дата актуальности
  last_all_index_date         - дата последнего завершения индексирования
                                репозитория
  result_count                - количество записей в результате
  result_row_number           - номер строки в результате
  snippet                     - участок кода, содержащий строку, при наличии
                                доступа

  Примечание:
  - результаты упорядочены по дате изменения в SVN, а также по релевантности в
    обратном порядке;
*/
function findString(
  operatorId integer
  , searchString varchar2
  , pageRowCount integer
  , pageNumber integer := null
  , internalResultLimit integer := null
  , svnLogin varchar2 := null
  , svnPassword varchar2 := null
  , repositoryNameList varchar2 := null
  , fileNameList varchar2 := null
  , svnPathList varchar2 := null
  , skipSvnPathList varchar2 := null
  , lastModificationFrom date := null
  , lastModificationTo date := null
  , revisionFrom integer := null
  , revisionTo integer := null
  , author varchar2 := null
  , fileSizeFrom integer := null
  , fileSizeTo integer := null
  , svnPathOrderFlag integer := null
)
return sys_refcursor
is
  -- Объект для работы с динамическим sql
  dynamicSql dyn_dynamic_sql_t;

  -- Возвращаемый курсор
  svnFileCur sys_refcursor;

  -- Имя сервера для URL
  serverName varchar2(1000) :=
    opt_option_list_t(
      moduleName => pkg_SvnSearcherBase.Module_Name
    ).getString( pkg_SvnSearcherBase.SvnServerName_OptionSName)
  ;


-- findString
begin
  if pageRowCount is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не задан обязательный параметр pageRowCount ( количество записей результатов на странице)'
    );
  end if;
  pkg_Operator.setCurrentUserId(
    operatorId => operatorId
  );
  pkg_Operator.isRole( roleShortName => pkg_SvnSearcherBase.All_RoleShortName);
  dynamicSql :=
     dyn_dynamic_sql_t(
       sqlText =>  '
select
  file_id
  , repository_name
  , svn_path
  , pkg_SvnSearcher.getResultUrl(
      serverName => :serverName
      , repositoryName => repository_name
      , svnPath => svn_path
      , login => :svnLogin
      , password => :svnPassword
    ) as url
  , substr(
      file_name
      , instr( file_name, ''.'', -1) + 1
    ) as file_extention
  , svn_last_modification
  , revision
  , author
  , file_size
  , last_check_date
  , last_all_index_date
  , result_count
  , result_row_number
  , case when
      :svnLogin is not null
    then
      case when
        pkg_SvnSearcherAccess.checkAccess(
          svnLogin => :svnLogin
          , svnPassword => :svnPassword
          , repositoryName => repository_name
          , svnPath => svn_path
        ) = 1
      then
        case when
          lower( file_name) like ''%.xml''
        then
          pkg_SvnSearcherIndex.decodeXmlSnippet(
            ctx_doc.snippet(
              ''SS_FILE_CTX_SEARCH''
              , to_char( file_id)
              , :searchString
            )
          )
        else
          ctx_doc.snippet(
            ''SS_FILE_CTX_SEARCH''
            , to_char( file_id)
            , :searchString
          )
        end
      end
   end as snippet
from
  (
  select
    s.file_id
    , s.repository_name
    , file_name
    , svn_path
    , svn_last_modification
    , revision
    , author
    , file_size
    , last_check_date
    , r.last_all_index_date
    , count(1) over () as result_count
    , row_number() over( order by svn_last_modification desc, score(1) desc) as result_row_number
  from
    ss_file s
  left join
    ss_repository r
  on
    r.repository_name = s.repository_name
  where
    $(condition)
    -- Ограничиваем количество результатов
    and rownum <= ' || to_char( coalesce( internalResultLimit, Default_InternalResultLimit)) || '
  ) t
where
  result_row_number
    between
  :pageRowCount * ( :pageNumber - 1) + 1
    and
  ( :pageRowCount * :pageNumber)
order by
' || case svnPathOrderFlag
      when 1 then 'svn_path'
      else 'result_row_number'
      end || '
'
  );
  dynamicSql.addCondition(
    conditionText => 'contains( file_data, :searchString, 1) > 0'
    , isNullValue => searchString is null
    , parameterName => 'searchString'
  );
  dynamicSql.addCondition(
    conditionText => 'pkg_SvnSearcherIndex.isOfMask( s.repository_name, :repositoryNameList) = 1'
    , isNullValue => repositoryNameList is null
    , parameterName => 'repositoryNameList'
  );
  dynamicSql.addCondition(
    conditionText => 'pkg_SvnSearcherIndex.isOfMask( file_name, :fileNameList) = 1'
    , isNullValue => fileNameList is null
    , parameterName => 'fileNameList'
  );
  dynamicSql.addCondition(
    conditionText => 'pkg_SvnSearcherIndex.isOfMask( svn_path, :svnPathList) = 1'
    , isNullValue => svnPathList is null
    , parameterName => 'svnPathList'
  );
  dynamicSql.addCondition(
    conditionText => 'pkg_SvnSearcherIndex.isOfMask( svn_path, :skipSvnPathList) = 0'
    , isNullValue => skipSvnPathList is null
    , parameterName => 'skipSvnPathList'
  );
  dynamicSql.addCondition(
    conditionText => 'svn_last_modification >= :lastModificationFrom'
    , isNullValue => lastModificationFrom is null
    , parameterName => 'lastModificationFrom'
  );
  dynamicSql.addCondition(
    conditionText => 'svn_last_modification <= :lastModificationTo'
    , isNullValue => lastModificationTo is null
    , parameterName => 'lastModificationTo'
  );
  dynamicSql.addCondition(
    conditionText => 'revision <= :revisionFrom'
    , isNullValue => revisionFrom is null
    , parameterName => 'revisionFrom'
  );
  dynamicSql.addCondition(
    conditionText => 'revision >= :revisionTo'
    , isNullValue => revisionTo is null
    , parameterName => 'revisionTo'
  );
  dynamicSql.addCondition(
    conditionText => 'author = :author'
    , isNullValue => author is null
    , parameterName => 'author'
  );
  dynamicSql.addCondition(
    conditionText => 'file_size >= :fileSizeFrom'
    , isNullValue => fileSizeFrom is null
    , parameterName => 'fileSizeFrom'
  );
  dynamicSql.addCondition(
    conditionText => 'file_size <= :fileSizeTo'
    , isNullValue => fileSizeTo is null
    , parameterName => 'fileSizeTo'
  );
  dynamicSql.useCondition( 'condition');
  logger.trace( 'sql=' || dynamicSql.getSqlText());
  open
    svnFileCur
  for
    dynamicSql.getSqlText()
  using
    -- getResultUrl
    serverName
    , svnLogin
    , svnPassword
    --  checkAccess, snippet
    , svnLogin
    , svnLogin
    , svnPassword
    , searchString
    , searchString
    -- find
    , searchString
    , repositoryNameList
    , fileNameList
    , svnPathList
    , skipSvnPathList
    , lastModificationFrom
    , lastModificationTo
    , revisionFrom
    , revisionTo
    , author
    , fileSizeFrom
    , fileSizeTo
    -- search page
    , pageRowCount
    , coalesce( pageNumber, 1)
    , pageRowCount
    , coalesce( pageNumber, 1)
  ;
  return
    svnFileCur
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка поиска подстроки в SVN'
      )
    , true
  );
end findString;

end pkg_SvnSearcher;
/
