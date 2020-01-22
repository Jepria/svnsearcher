create or replace package body pkg_SvnSearcher is
/* package body: pkg_SvnSearcher::body */

/* ivar: lg_logger_t
  ������������ ������ ��� ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_SvnSearcherBase.Module_Name
    , objectName => 'pkg_SvnSearcher'
  );

/* const: Default_InternalResultLimit
  ����� ����������� ������ ��� ����������� ������������������ �� ���������
  ( ����������� ���������� ������� �� rownum)
*/
Default_InternalResultLimit constant integer := 500;



/* group: ������� */

/* func: getResultUrl
  ��������� URL ��� ����������� ������.

  ���������:
  serverName                  - ��� ������� ( ����)
  repositoryName              - ������������ �����������
  svnPath                     - ������������� ���� � ����� � SVN
  login                       - ����� ��� ����������� � URL ( �� ����������)
  password                    - ������ ��� ����������� � URL ( �� ����������)
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
        '������ ��������� URL ��� ����������� ������'
      )
    , true
  );
end getResultUrl;

/* func: getRepository
  ��������� ������ ������������.

  ���� ������������� �������:
  repository_name             - ����� ����� �����
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
        '������ ��������� ������ ������������'
      )
    , true
  );
end getRepository;

/* func: getFileNameMask
  ��������� ������ ����� ������.

  ���� ������������� �������:
  file_name_mask              - ����� ����� �����
*/
function getFileNameMask
return sys_refcursor
is
  resultCursor sys_refcursor;

  -- ������ ����� ������ � ���� ������ ����� ","
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
        '������ ��������� ������ ����� ������'
      )
    , true
  );
end getFileNameMask;

/* func: findString
  ����� ��������� � SVN.

  ���������:
  operatorId                  - id ���������
  searchString                - ����� ��� ������ ( �������� ������ ,
                                ���������� "%", "?", ������������� �
                                �������� CONTAINS
                                <http://docs.oracle.com/cd/E11882_01/text.112/e24435/query.htm#CCAPP9175>)
  pageRowCount                - ���������� ������� ����������� �� �������� (
                                ������������ ��������)
  pageNumber                  - ����� �������� ( ��-��������� 1)
  internalResultLimit         - ����� ����������� ������ ��� �����������
                                ������������������ ( ��-���������
                                <body::Default_InternalResultLimit>)
  svnLogin                    - ����� SVN ��� ������ ����� ������, ��� ������� ������
  svnPassword                 - ������ SVN ��� ������ ����� ������, ��� ������� ������
  repositoryNameList          - ������ ������������ ����� ","
  fileNameList                - ������ ����� ��� ��� ������ ����� "," (
                                ���������� � ���������� �������������� �
                                �������������� <getFileNameMask>)
  svnPathList                 - ������ ����� ����� � ����� SVN ����� ","
  skipSvnPathList             - ������ ����� ����� � ����� SVN ����� "," ���
                                �������������
  lastModificationFrom        - ���� ����������� ����� SVN ��
  lastModificationTo          - ���� ����������� ����� SVN ��
  revisionFrom                - ������� ( ������) � SVN ��
  revisionTo                  - ������� ( ������) � SVN ��
  author                      - ����� � SVN
  fileSizeFrom                - ������ ����� ��
  fileSizeTo                  - ������ ����� ��
  svnPathOrderFlag            - ������� ���������� ��������� �� ���� � SVN
                                ( �� ��������� �� ���� �����������)

  ���� ������������� �������:
  file_id                     - id �����, ��������� ����
  repository_name             - ������������ �����������
  svn_path                    - ���� � ����� � ����������� SVN
  url                         - ������ ( URL)
  file_extention              - ���������� �����
  svn_last_modification       - ����/����� ����������� � SVN
  revision                    - ����� ������� ( ������ ) SVN
  author                      - ����� � SVN
  file_size                   - ������ �����
  last_check_date             - ���� ������������
  last_all_index_date         - ���� ���������� ���������� ��������������
                                �����������
  result_count                - ���������� ������� � ����������
  result_row_number           - ����� ������ � ����������
  snippet                     - ������� ����, ���������� ������, ��� �������
                                �������

  ����������:
  - ���������� ����������� �� ���� ��������� � SVN, � ����� �� ������������� �
    �������� �������;
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
  -- ������ ��� ������ � ������������ sql
  dynamicSql dyn_dynamic_sql_t;

  -- ������������ ������
  svnFileCur sys_refcursor;

  -- ��� ������� ��� URL
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
      , '�� ����� ������������ �������� pageRowCount ( ���������� ������� ����������� �� ��������)'
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
    -- ������������ ���������� �����������
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
        '������ ������ ��������� � SVN'
      )
    , true
  );
end findString;

end pkg_SvnSearcher;
/
