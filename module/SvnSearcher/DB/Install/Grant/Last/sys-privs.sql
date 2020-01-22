-- script: Install/Grant/Last/sys-privs.sql
-- Выдача системных привилений для работы модуля.
--
-- Параметры:
-- &1                         - пользователь, кому выдаются права

define toUserName = &1

grant execute on ctx_ddl to &toUserName
/
grant ctxapp to &toUserName
/
grant javasyspriv to &toUserName
/



undefine toUserName
