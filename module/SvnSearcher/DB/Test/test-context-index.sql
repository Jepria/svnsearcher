begin
  execute immediate 'drop table ss_test_index'
  ;
exception when others then
  null;
end;
/

create table ss_test_index(
  a blob
  , charset varchar2(10) default 'AUTO'
  , format varchar2(10)
  , file_name varchar2(10)
)
/

declare
  dbEncoding varchar2(30) := 'CL8MSWIN1251';
  sourceText varchar2(100) := 'фотографиям';
  resultBlob blob;
  encoding varchar2(30) := 'UTF8';
begin
  resultBlob :=
    cast(
      utl_raw.convert(
        utl_raw.cast_to_raw( sourceText)
        -- Обязательно указывать территорию
        , 'RUSSIAN_CIS.' || encoding
        , 'RUSSIAN_CIS.' || dbEncoding
      )
      as blob
    )
  ;
  insert into ss_test_index(
    a
    , charset
    , format
    , file_name
  )
  values(
    resultBlob
    , 'UTF8'
    , 'TEXT'
    , 'artificial'
  );
  pkg_File.loadBlobFromFile(
    resultBlob
    -- Путь к документу .doc
    , '&1'
  );
  insert into ss_test_index(
    a
    , charset
    , format
    , file_name
  )
  values(
    resultBlob
    , null
    , 'binary'
    , '1.doc'
  );
  insert into ss_test_index(
    a
    , charset
    , format
    , file_name
  )
  values(
    pkg_TextCreate.convertToBlob( '\\\<xml a="фотографиям"\>')
    , null
    , 'TEXT'
    , 'xml'
  );
end;
/

commit;

declare
  preferenceExists number(1,0);
begin
  select
    count(1)
  into
    preferenceExists
  from
    ctx_preferences
  where
    pre_name = upper( 'ss_filter_charset')
  ;
  if ( preferenceExists = 1 ) then
    ctx_ddl.drop_preference( 'ss_filter_charset');
  end if;
  ctx_ddl.create_preference( 'ss_filter_charset', 'AUTO_FILTER');
--  ctx_ddl.set_attribute( 'ss_filter_charset', 'CHARSET', 'CL8MSWIN1251');
end;
/

commit;

create index
  ss_test_index_ix_search
on
  ss_test_index ( a )
indextype is
  ctxsys.context
parameters(
  'filter ctxsys.auto_filter format column format charset column charset'
)
/

begin
  ctxsys.ctx_ddl.sync_index(
    idx_name => upper( 'ss_test_index_ix_search')
  );
end;
/


select
  file_name
from
  ss_test_index
where
  contains( a, 'фотографиям', 1) > 0
/


