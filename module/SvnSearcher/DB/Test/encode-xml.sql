update
  (
  select
    file_data
  from
    ss_file
  where
    file_name like '%.xml'
  )
set
  file_data = pkg_SvnSearcherIndex.encodeXml( file_data)
where
  pkg_TextCreate.convertToClob( file_data) not like '\<%'
/
