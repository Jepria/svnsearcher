begin
  pkg_SvnSearcherIndex.openConnection( repositoryName => '&1');
  delete from svn_file_tmp;
  pkg_Subversion.getFileTree(
    dirSvnPath => ''
    , maxRecursiveLevel => 3
    , directoryRecordFlag => true
  );
  pkg_SvnSearcherIndex.closeConnection();
end;
/
select
  *
from
  svn_file_tmp
where
  directory_flag = 1
/
