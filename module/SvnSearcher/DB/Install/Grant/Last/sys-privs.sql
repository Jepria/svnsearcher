-- script: Install/Grant/Last/sys-privs.sql
-- ������ ��������� ���������� ��� ������ ������.
--
-- ���������:
-- &1                         - ������������, ���� �������� �����

define toUserName = &1

grant execute on ctx_ddl to &toUserName
/
grant ctxapp to &toUserName
/
grant javasyspriv to &toUserName
/



undefine toUserName
