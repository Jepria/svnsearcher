create or replace package pkg_SvnSearcherAccess is
/* package: pkg_SvnSearcherAccess
  Пакет для проверки доступа при выдаче результатов поиска.

  SVN root: Module/SVNSearcher
*/



/* group: Функции */

/* pfunc: checkAccess
  Проверка доступа к файлу в репозитории.

  Параметры:
  svnLogin                    - логин в SVN
  svnPassword                 - пароль в SVN
  repositoryName              - имя репозитория SVN
  svnPath                     - относительный путь в SVN

  Возврат:
  - 1, если доступ есть;
  - 0, если доступа нет;

  Замечание:
  - функция оформлена в виде автономной транзакции, так как вызывается
    из SQL;

  ( <body::checkAccess>)
*/
function checkAccess(
  svnLogin varchar2
  , svnPassword varchar2
  , repositoryName varchar2
  , svnPath varchar2
)
return integer;

end pkg_SvnSearcherAccess;
/
