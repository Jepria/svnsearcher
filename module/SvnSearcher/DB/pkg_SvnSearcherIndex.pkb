create or replace package body pkg_SvnSearcherIndex is
/* package body: pkg_SvnSearcherIndex::body */

/* ivar: lg_logger_t
  ������������ ������ ��� ������ Logging
*/
logger lg_logger_t := lg_logger_t.GetLogger(
  moduleName => pkg_SvnSearcherBase.Module_Name
  , objectName => 'pkg_SvnSearcherIndex'
);




/* group: ��������� */

/* const: Max_IndexDirRecursiveLevel
  ������������ ������� �������� ��� ��������� ������ ����������.
*/
Max_IndexDirRecursiveLevel constant integer := 3;

/* const: Text_CtxFormat
  ������ ��������� ������ ��� ������� "format column" ������� ���� "CONTEXT".
*/
Text_CtxFormat constant varchar2(10) := 'TEXT';

/* const: Utf8_CtxCharset
  ��������� "UTF-8" ��� ������� "charset column" ������� ���� "CONTEXT".
  ��. <http://docs.oracle.com/cd/B19306_01/text.102/b14218/cdatadic.htm#i1007132>
*/
Utf8_CtxCharset constant varchar2(10) := 'UTF8';




/* group: ���������� �������� �������������� */

/* ivar: indexedNewFileCount
  ���������������� ����� ������.
*/
indexedNewFileCount integer;

/* ivar: indexedUpdatedFileCount
  �������� ������.
*/
indexedUpdatedFileCount integer;

/* ivar: deletedFileCount
  ������� ������.
*/
deletedFileCount integer;

/* ivar: ignoredFileCount
  ��������������� ������.
*/
ignoredFileCount integer;

/* ivar: remainedFileCount
  ���������� ������ ��� ���������.
*/
remainedFileCount integer;




/* group: ������� */



/* group: ������� */

/* func: encodeXml
  �������� XML ��� ����, ����� ��������������� �������� ���������.

  ���������:
  xmlData                     - ������ XML � ���� blob

  �������:
  - ������������ ������ � ���� blob;
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
        '������ ����������� ������ XML'
      )
    , true
  );
end encodeXml;

/* func: decodeXmlSnippet
  ������������� XML, �������� <encodeXml>, �� ������� � ���� HTML.

  ���������:
  encodedSnippet               - ����� xml � ���� HTML, ������������
                                 <encodedXml>;

  �������:
  - �������������� ������ ( ������� ������);
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
  ��������� URL ����������� �� �����.

  ���������:
  serverName                  - ��� �������
  repositoryName              - ��� �����������
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
  ���������� � ������������ SVN � �������������� ����� ������
  <pkg_SvnSearcherBase::������������ ����� ��� ���������� � ������������>;

  ���������:
  repositoryName              - ��� �����������
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
        '������ ���������� � ������������ ( '
        || 'repositoryName="' || repositoryName || '"'
        || ')'
      )
    , true
  );
end openConnection;

/* proc: closeConnection
  �������� ���������� � ������������.
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
        '������ �������� ���������� � ������������'
      )
    , true
  );
end closeConnection;

/* func: isOfMask
  ���������� 1, ���� ��� ����� ������������� ���� �� ����� �� �����
  ������������� � MaskSet ����� ',', � 0 � ��������� ������.

  ���������:
  fileName                    - ��� �����
  maskSet                     - ����� ��� ������ (����� ',')
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
        '��������� ������������ � ������� IsOfMask'
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
    '������ IsOfMask. fileName = "'
    || fileName || '" maskSet = "' || maskSet || '"'
    , true
  );
end isOfMask;



/* group: �������������� */

/* proc: finishRepositoryIndex
  ���������� �������������� �����������.

  ���������:
  repositoryName              - ��� SVN �����������
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
        '������ ���������� ������������� �����������'
      )
    , true
  );
end finishRepositoryIndex;

/* proc: synchronizeIndex
  ������������� ������� <ss_file::ss_file_ctx_search>;
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
        '������ ������������� �������'
      )
    , true
  );
end synchronizeIndex;

/* proc: indexDirectory
  �������������� ���������� � SVN.

  ���������:
  repositoryName              - ��� SVN �����������
  directorySvnPath            - ������������� ���� ���������� � SVN
  maxFinishTime               - �����, ����� �������� ��������������
                                ������������
  fileNameMaskList            - ������ ����� ��� ������ ��� ��������������
  excludeSvnPathMaskList      - ������ ����� ����� ������ ��� ���������� ��
                                ��������������
  utf8FileMaskList            - ����� ��� ��� ������, ���������� ( ����� ",")
                                ( ��-��������� ������������ �������� �����
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - �������� ������������ ���������� ������ (
                                ��-���������, ��)

  ���������:
  - ��������������, ��� ���������� � SVN �����������;
  - ��������� ����������� � ���������� ���������� ��� ��������� �����������
    ������������� ����������� ��������������;
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
    �������� �� <svn_file_tmp> ������ �� ����������� ��� �������
    ��������������.
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
      -- ������� ���������� ������� �� ������ � �������
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
          '������ �������� ������'
        )
      , true
    );
  end filterFile;

  /*
    ���������� ������ ����������� ������.
  */
  procedure updateCheckedFile
  is
    -- ���������� ����������� ������
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
        -- ����� �� ����������
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
          '������ ���������� ������ ����������� ������'
        )
      , true
    );
  end updateCheckedFile;

  /*
    ���������� ������ ������.
  */
  procedure updateFileData
  is

    -- ����� �����
    fileNumber integer := 0;

    -- ������ ��� ��������� ������������ � SVN ������
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
        -- ����� ����������
        f.repository_name = repositoryName
        and f.svn_path = t.svn_path
      where
        -- ���� ���� �� ��� ���������������
        f.revision is null
        -- ���� �� ���������
        or t.revision > f.revision
      order by
        -- �������: ������� ����������� ����� �����, ����� ����������
        f.last_refresh_date nulls first
        , t.last_modification
    ;

    /*
      ���������� ������ �����.
    */
    procedure mergeFile( svnFile svnFileCur%rowtype)
    is

      -- ������ �����
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
            , '�������� ���������� ������� ��� ���������� ������'
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
            '������ ���������� ������ ����� ( svn_path="' || svnFile.svn_path || '")'
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
        logger.info( '�������������� ����������: "' || directorySvnPath || '": ��������� ����� �������: {' || to_char( maxFinishTime, 'dd.mm.yyyy hh24:mi:ss') || '}');
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ������ ������'
        )
      , true
    );
  end updateFileData;

  /*
    �������� ���������� ������������ ������.
  */
  procedure deleteOldData
  is

    -- ���������� ���������� ������
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
          '������ �������� ���������� ������������ ������'
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
        '������ �������������� ���������� � SVN ( '
        || 'directorySvnPath="' || directorySvnPath || '"'
        || ')'
      )
    , true
  );
end indexDirectory;

/* proc: indexRepository
  �������������� �����������.

  ���������:
  repositoryName              - ��� SVN �����������
  directoryMaskList           - ������ ����� ���������� ��� ��������������
  maxFinishTime               - �����, ����� �������� ��������������
                                ������������
  utf8FileMaskList            - ����� ��� ��� ������, ���������� ( ����� ",")
                                ( ��-��������� ������������ �������� �����
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - �������� ������������ ���������� ������ (
                                ��-���������, ��)
*/
procedure indexRepository(
  repositoryName varchar2
  , directoryMaskList varchar2 := null
  , maxFinishTime date := null
  , utf8FileMaskList varchar2 := null
  , deleteOldDataFlag boolean := null
)
is

  -- ������ ����� ������
  optionList opt_option_list_t;

  -- �������� ����� ������
  fileNameMaskList varchar2(32767);
  excludeSvnPathMaskList varchar2(32767);
  maxIndexFileSize integer;
  usedUtf8FileMaskList varchar2(32767);

  -- ���������� ���������� ��� ��������������
  directoryCount integer;

  /*
    ��������� ������ ���������� ��� ��������������.
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
    logger.info( '������� ���������� ��� ��������������: ' || to_char( directoryCount));
    commit;
  exception when others then
    rollback;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ������ �������'
        )
      , true
    );
  end getDirectoryList;

  /*
    �������� ������ ������, �� ���������� ��� ��������������.
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
    logger.debug( '������� ������, �� ���������� ��� ��������������: ' || to_char( deletedExcessFileCount));
    deletedFileCount := deletedFileCount + deletedExcessFileCount;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������, �� ���������� ��� ��������������.'
        )
      , true
    );
  end deleteExcessFile;

  /*
    �����c�������� ��������� ����������.
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
        logger.info( '�������������� ����������� "' || repositoryName || '": ��������� ����� �������: {' || to_char( maxFinishTime, 'dd.mm.yyyy hh24:mi:ss') || '}');
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������������� ����������'
        )
      , true
    );
  end indexDirectory;

-- indexRepositoryList
begin
  logger.info( '�������������� �����������: "' || repositoryName || '"');
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
  logger.info( '���������������� ����� ������: ' || to_char( indexedNewFileCount));
  logger.info( '��������� ������ ��� ��������������: ' || to_char( indexedUpdatedFileCount));
  logger.info( '������� ������ �� �������: ' || to_char( deletedFileCount));
  logger.info( '��������������� ������: ' || to_char( ignoredFileCount));
  logger.info( '������ ��� ���������: ' || to_char( remainedFileCount));
exception when others then
  closeConnection();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������������� ����������� '
      )
    , true
  );
end indexRepository;

end pkg_SvnSearcherIndex;
/
