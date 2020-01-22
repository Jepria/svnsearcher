create or replace package body pkg_SvnSearcherTest is
/* package body: pkg_SvnSearcherTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_SvnSearcherTest.Module_Name
  , objectName  => 'pkg_SvnSearcherTest'
);



/* group: Функции */

/* proc: testSearch


  Параметры:
  argName                -
*/
procedure testSearch(

)
is
-- testSearch
begin

end testSearch;

/* proc: testCharacterSet
  Проверка того, что корректно определяется кодировка.
*/
procedure testCharacterSet
is
-- testCharacterSet
begin
  null;
end testCharacterSet;

end pkg_SvnSearcherTest;
/
