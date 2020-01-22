-- script: Install/Data/Last/Access-Operator/op_role.sql
-- Скрипт для добавления ролей для модуля.


begin
merge into
  op_role r
using
  (
  select
    'SsAll' as short_name
    , 'SvnSearcher: Использование модуля' as role_name_rus
    , 'SvnSearcher: Usage' as role_name_eng
    , 'SvnSearcher: пользователь с данной ролью имеет доступ к использованию SvnSearcher'
      as description
  from
    dual
  minus
  select
    r.short_name as short_name
    , r.role_name_rus as role_name_rus
    , r.role_name_eng as role_name_eng
    , r.description as description
  from
    op_role r
  ) s
on
  (
    r.short_name = s.short_name
  )
when not matched then insert(
  role_id
  , short_name
  , role_name_rus
  , role_name_eng
  , description
  , operator_id
)
values(
  op_role_seq.nextval
  , s.short_name
  , s.role_name_rus
  , s.role_name_eng
  , s.description
  , pkg_Operator.getCurrentUserId()
)
when matched then update set
  r.role_name_rus = s.role_name_rus
  , r.role_name_eng = s.role_name_eng
  , r.description = s.description
;
  dbms_output.put_line( 'changed: ' || sql%rowcount);
  commit;
end;
/



