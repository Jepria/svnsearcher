-- script: DB\Install\Grant\Last\run.sql
-- ������ ����� �� ������������� ������.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



grant
  execute
on
  pkg_SvnSearcher
to
  &toUserName
/

create or replace synonym
  &toUserName..pkg_SvnSearcher
for
  pkg_SvnSearcher
/



undefine toUserName
