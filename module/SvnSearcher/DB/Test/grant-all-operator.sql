begin
  insert into op_operator_role(
    operator_id
    , role_id
    , operator_id_ins
  )
  select
    operator_id
    , (
      select
        role_id
      from
        op_role
      where
        short_name = 'SsAll'
      ) as role_Id
    , 1 as operator_id_ins
  from
    op_operator r
  where
    not exists (
      select
        1
      from
        op_operator_role opr
      where
        opr.operator_id = r.operator_id
        and opr.role_id =
        (
        select
          role_id
        from
          op_role
        where
          short_name = 'SsAll'
        )
    )
  ;
  dbms_output.put_line( 'op_operator_role: ' || to_char( sql%rowcount));
end;
/


