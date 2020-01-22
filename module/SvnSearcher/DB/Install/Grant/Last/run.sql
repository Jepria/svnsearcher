-- script: DB\Install\Grant\Last\run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
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
