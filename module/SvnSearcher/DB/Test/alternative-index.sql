create table
  ss_file_alt
(
  file_id                         integer                             not null
  , repository_name               varchar2(100)                       not null
  , file_name                     varchar2(4000)                      not null
  , svn_path                      varchar2(4000)                      not null
  , revision                      integer                             not null
  , author                        varchar2(100)                       not null
  , last_modification             timestamp with local time zone  not null
  , file_size                     integer                             not null
  , file_data                     blob
  , ctx_format                    varchar2(10)
  , ctx_charset                   varchar2(20)
  , last_check_date               date                                not null
  , last_refresh_date             date                                not null
  , date_ins                      date                default sysdate not null
  , constraint ss_file_alt_pk primary key
    ( file_id)
    using index tablespace &indexTablespace
  , constraint ss_file_alt_uk unique (
      repository_name
      , svn_path
    )
    using index tablespace &indexTablespace
  , constraint ss_file_alt_ck_ctx_format check (
      ctx_format in ( 'TEXT', 'BINARY', 'IGNORE')
    )
)
/

insert into
  ss_file_alt
select
  *
from
  ss_file
/

commit;


begin
  ctx_ddl.create_preference( 'ss_lexer', 'BASIC_LEXER');
  ctx_ddl.set_attribute( 'ss_lexer', 'printjoins', '_-');
end;
/

create index
  ss_file_ctx_search_alt
on
  ss_file_alt( file_data)
indextype is
  ctxsys.context
parameters(
  '
  filter ctxsys.auto_filter
  format column ctx_format
  charset column ctx_charset
  lexer ss_lexer
  '
)
/

begin
  ctxsys.ctx_ddl.sync_index(
    idx_name => 'SS_FILE_CTX_SEARCH_ALT'
  );
end;
/
