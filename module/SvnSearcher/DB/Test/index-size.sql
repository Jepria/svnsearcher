select bytes, segment_name from dba_segments where segment_name like 'DR$SS%' escape '\'

176 160 768

1 881 145 344

select sum( dbms_lob.getlength( file_data)), max( dbms_lob.getlength( file_data)), count(1) 
from ss_index_files

519 724 714

499 326 146

41 228 054

9 523 200

begin
  pkg_SvnSearcherIndex.endIndex();
end;


32 007 455

 select
    max( t.idx_name )
  from
    ctx_user_indexes t
  where
    t.idx_table = 'SS_INDEX_FILES'
    and t.idx_text_name = 'FILE_DATA'
    and t.idx_type = 'CONTEXT'
    
    501033447
    
    574 601 351
