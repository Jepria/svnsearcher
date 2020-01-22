begin
  pkg_SvnSearcherIndex.openConnection(
    repositoryName => '&1'
  );
  pkg_SvnSearcherIndex.closeConnection();
end;
/
