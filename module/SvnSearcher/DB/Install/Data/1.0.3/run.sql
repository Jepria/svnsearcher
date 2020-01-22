-- script: Install/Data/1.0.3/run.sql
-- Изменение в данных в индексе для XML файлов
--

update
  ss_file f
set
  f.file_data = pkg_SvnSearcherIndex.encodeXml( f.file_data)
, f.ctx_format = 'TEXT'
where
  pkg_SvnSearcherIndex.isOfMask( file_name, '%.xml') = 1
  and f.ctx_format is null
/

commit
/

begin
  Pkg_Svnsearcherindex.synchronizeIndex();
end;
/
