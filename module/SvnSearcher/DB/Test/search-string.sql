-- script: Test/search-string.sql
-- ����� ������ � �������.

select
  pkg_SvnSearcher.findString(
    operatorId => pkg_Operator.getCurrentUserId()
    , searchString => '&1'
    , repositoryNameList => 'Business,Budget'
    , svnLogin => '&2'
    , svnPassword => '&3'
    , pageRowCount => 10
  )
from
  dual
/

