create or replace package pkg_SvnSearcherIndex
is
/* package: pkg_SvnSearcherIndex
  ������������ ����� ������ SvnSearcher.

  SVN root: Module/SvnSearcher
*/

/* const: PathSeparator_Windows
  ����������� ���� � �� ��������� Windows.
*/
PathSeparator_Windows constant varchar2(1) := '\';

/* const: PathSeparator_Unix
  ����������� ���� � �� ��������� Unix.
*/
PathSeparator_Unix constant varchar2(1) := '/';

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'SvnSearcher';

/* const: indexSyncOperationType
  �������� ���� �������� �� ������������� ������� Oracle Text.
*/
indexSyncOperationType constant varchar2(30) := 'SYNC';

/* const: indexRecreateOperationType
  �������� ���� �������� �� ������������ ������� Oracle Text.
*/
indexRecreateOperationType constant varchar2(30) := 'RECREATE';


/* group: ��������� */

/* const: Win1251_Encoding
  ��� ��������� windows 1251.
*/
Win1251_Encoding constant varchar2(30) := 'CL8MSWIN1251';

/* const: Utf8_Encoding
  ��� ��������� utf 8.
*/
Utf8_Encoding constant varchar2(30) := 'UTF8';




/* group: ������� */



/* group: ������� */

/* pfunc: encodeXml
  �������� XML ��� ����, ����� ��������������� �������� ���������.

  ���������:
  xmlData                     - ������ XML � ���� blob

  �������:
  - ������������ ������ � ���� blob;

  ( <body::encodeXml>)
*/
function encodeXml(
  xmlData blob
)
return blob;

/* pfunc: decodeXmlSnippet
  ������������� XML, �������� <encodeXml>, �� ������� � ���� HTML.

  ���������:
  encodedSnippet               - ����� xml � ���� HTML, ������������
                                 <encodedXml>;

  �������:
  - �������������� ������ ( ������� ������);

  ( <body::decodeXmlSnippet>)
*/
function decodeXmlSnippet(
  encodedSnippet varchar2
)
return varchar2;

/* pfunc: getRepositoryUrl
  ��������� URL ����������� �� �����.

  ���������:
  serverName                  - ��� �������
  repositoryName              - ��� �����������

  ( <body::getRepositoryUrl>)
*/
function getRepositoryUrl(
  serverName varchar2
  , repositoryName varchar2
)
return varchar2;

/* pproc: openConnection
  ���������� � ������������ SVN � �������������� ����� ������
  <pkg_SvnSearcherBase::������������ ����� ��� ���������� � ������������>;

  ���������:
  repositoryName              - ��� �����������

  ( <body::openConnection>)
*/
procedure openConnection(
  repositoryName varchar2
);

/* pproc: closeConnection
  �������� ���������� � ������������.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pfunc: isOfMask
  ���������� 1, ���� ��� ����� ������������� ���� �� ����� �� �����
  ������������� � MaskSet ����� ',', � 0 � ��������� ������.

  ���������:
  fileName                    - ��� �����
  maskSet                     - ����� ��� ������ (����� ',')

  ( <body::isOfMask>)
*/
function isOfMask(
  fileName varchar2
  , maskSet varchar2
)
return integer;



/* group: �������������� */

/* pproc: finishRepositoryIndex
  ���������� �������������� �����������.

  ���������:
  repositoryName              - ��� SVN �����������

  ( <body::finishRepositoryIndex>)
*/
procedure finishRepositoryIndex(
  repositoryName varchar2
);

/* pproc: synchronizeIndex
  ������������� ������� <ss_file::ss_file_ctx_search>;

  ( <body::synchronizeIndex>)
*/
procedure synchronizeIndex;

/* pproc: indexDirectory
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

  ( <body::indexDirectory>)
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
);

/* pproc: indexRepository
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

  ( <body::indexRepository>)
*/
procedure indexRepository(
  repositoryName varchar2
  , directoryMaskList varchar2 := null
  , maxFinishTime date := null
  , utf8FileMaskList varchar2 := null
  , deleteOldDataFlag boolean := null
);

end pkg_SvnSearcherIndex;
/
