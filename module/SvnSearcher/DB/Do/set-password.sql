-- script: Do\set-password.sql
-- ��������� ����� - ������ ��� ������������ SVN.
--
-- &1                         - �������� ����� ( ���������������)
declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_SvnSearcherBase.Module_Name
  );

begin
  optionList.setString(
    optionShortName => pkg_SvnSearcherBase.SvnPassword_OptionSName
    , stringValue => '&1'
  );
end;
/
