create or replace package body pkg_SvnSearcherTest is
/* package body: pkg_SvnSearcherTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_SvnSearcherTest.Module_Name
  , objectName  => 'pkg_SvnSearcherTest'
);



/* group: ������� */

/* proc: testSearch


  ���������:
  argName                -
*/
procedure testSearch(

)
is
-- testSearch
begin

end testSearch;

/* proc: testCharacterSet
  �������� ����, ��� ��������� ������������ ���������.
*/
procedure testCharacterSet
is
-- testCharacterSet
begin
  null;
end testCharacterSet;

end pkg_SvnSearcherTest;
/
