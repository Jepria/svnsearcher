create or replace package pkg_SvnSearcher is
/* package: pkg_SvnSearcher
  ������������ ����� ������ SVNSearcher.

  SVN root: Module/SVNSearcher
*/



/* group: ������� */

/* pfunc: getResultUrl
  ��������� URL ��� ����������� ������.

  ���������:
  serverName                  - ��� ������� ( ����)
  repositoryName              - ������������ �����������
  svnPath                     - ������������� ���� � ����� � SVN
  login                       - ����� ��� ����������� � URL ( �� ����������)
  password                    - ������ ��� ����������� � URL ( �� ����������)

  ( <body::getResultUrl>)
*/
function getResultUrl(
  serverName varchar2
  , repositoryName varchar2
  , svnPath varchar2
  , login varchar2
  , password varchar2
)
return varchar2;

/* pfunc: getRepository
  ��������� ������ ������������.

  ���� ������������� �������:
  repository_name             - ����� ����� �����

  ( <body::getRepository>)
*/
function getRepository
return sys_refcursor;

/* pfunc: getFileNameMask
  ��������� ������ ����� ������.

  ���� ������������� �������:
  file_name_mask              - ����� ����� �����

  ( <body::getFileNameMask>)
*/
function getFileNameMask
return sys_refcursor;

/* pfunc: findString
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

  ( <body::findString>)
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
return sys_refcursor;

end pkg_SvnSearcher;
/
