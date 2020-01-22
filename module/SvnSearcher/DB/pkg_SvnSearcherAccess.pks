create or replace package pkg_SvnSearcherAccess is
/* package: pkg_SvnSearcherAccess
  ����� ��� �������� ������� ��� ������ ����������� ������.

  SVN root: Module/SVNSearcher
*/



/* group: ������� */

/* pfunc: checkAccess
  �������� ������� � ����� � �����������.

  ���������:
  svnLogin                    - ����� � SVN
  svnPassword                 - ������ � SVN
  repositoryName              - ��� ����������� SVN
  svnPath                     - ������������� ���� � SVN

  �������:
  - 1, ���� ������ ����;
  - 0, ���� ������� ���;

  ���������:
  - ������� ��������� � ���� ���������� ����������, ��� ��� ����������
    �� SQL;

  ( <body::checkAccess>)
*/
function checkAccess(
  svnLogin varchar2
  , svnPassword varchar2
  , repositoryName varchar2
  , svnPath varchar2
)
return integer;

end pkg_SvnSearcherAccess;
/
