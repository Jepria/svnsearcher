select
  repository_name
  , file_svn_path
  , CTX_DOC.SNIPPET(
     'SS_IDX_FILES_IX_FILE_DATA'
      , to_char( file_id)
      , 'convertto%lob'
    ) as snippet
from
  ss_index_files
where
  contains( file_data, 'convertto%lob', 1) > 0
order by
  score(1) desc
/
