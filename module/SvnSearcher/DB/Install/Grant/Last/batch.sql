-- script: Install/Grant/Last/batch.sql
-- ������ ���� ��� �������� ������.

define toUserName=&1

grant execute on pkg_SvnSearcherIndex to &toUserName
/
create or replace synonym &toUserName..pkg_SvnSearcherIndex for pkg_SvnSearcherIndex
/

undefine toUserName
