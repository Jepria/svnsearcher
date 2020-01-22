create or replace package pkg_SvnSearcherBase is
/* package: pkg_SvnSearcherBase
  �����, ���������� ������� ���������.

  SVN root: Module/SVNSearcher
*/



/* const: Module_Name
  ������������ ������.
*/
Module_Name constant varchar2(30) := 'SvnSearcher';



/* group: ������������ ����� */

/* const: All_RoleShortName
  �������� ������������ ���� "������ � ������ SvnSearcher".
*/
All_RoleShortName constant varchar2(30) := 'SsAll';



/* group: ������������ ����� ��� ���������� � ������������ */

/* const: SvnServerName_OptionSName
  �������� ������������ ����� "��� ������� SVN".
*/
SvnServerName_OptionSName constant varchar2(50) := 'SvnServerName';

/* const: SvnLogin_OptionSName
  �������� ������������ ����� "����� ��� ���������� � ������������ SVN".
*/
SvnLogin_OptionSName constant varchar2(50) := 'SvnLogin';

/* const: SvnPassword_OptionSName
  �������� ������������ ����� "������ ��� ���������� � ������������ SVN".
*/
SvnPassword_OptionSName constant varchar2(50) := 'SvnPassword';



/* group: ������������ ����� ��� ��������� �������������� */

/* const: FileNameMaskList_OptionSName
  �������� ������������ ����� "������ ����� ��� ������ ��� �������������� ����� ','"
*/
FileNameMaskList_OptionSName constant varchar2(50) := 'FileNameMaskList';

/* const: ExcludePathList_OptionSName
  �������� ������������ ����� "������ ����� ����� ������ ��� ���������� �� �������������� ����� ','"
*/
ExcludePathList_OptionSName constant varchar2(50) := 'ExcludeFileSvnPathMaskList';

/* const: Utf8PathMaskList_OptionSName
  �������� ������������ ����� "������ ����� ������������� ����� SVN ������,
  ���������������� ��� ��������� � ��������� UTF-8".
*/
Utf8PathMaskList_OptionSName constant varchar2(50) := 'Utf8SvnPathMaskList';

/* const: MaxIndexFileSize_OptionSName
  �������� ������������ ����� "������������ ������ ����� ��� ��������������".
*/
MaxIndexFileSize_OptionSName constant varchar2(50) := 'MaxIndexFileSize';

end pkg_SvnSearcherBase;
/
