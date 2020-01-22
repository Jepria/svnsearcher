create or replace package body pkg_SvnSearcherAccess is
/* package body: pkg_SvnSearcherAccess::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_SvnSearcherBase.Module_Name
  , objectName  => 'pkg_SvnSearcherAccess'
);

/* ivar: serverName
  Кешированное имя сервера.
*/
serverName varchar2(100) := null;



/* group: Функции */

/* func: checkAccess
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
*/
function checkAccess(
  svnLogin varchar2
  , svnPassword varchar2
  , repositoryName varchar2
  , svnPath varchar2
)
return integer
is
  pragma autonomous_transaction;

  -- Флаг доступа - возврат функции
  accessFlag number(1,0);

-- checkAccess
begin
  logger.trace( 'check access: "' || svnPath || '": end');
  if serverName is null then
    serverName :=
      opt_option_list_t( pkg_SvnSearcherBase.Module_Name).getString(
        pkg_SvnSearcherBase.SvnServerName_OptionSName
      );
  end if;
  if svnLogin is not null then
    pkg_Subversion.openConnection(
      repositoryUrl => pkg_SvnSearcherIndex.getRepositoryUrl(
        serverName => serverName
        , repositoryName => repositoryName
      )
      , login => svnLogin
      , password => svnPassword
    );
    accessFlag := pkg_Subversion.checkAccess(
      svnPath => svnPath
    );
    pkg_Subversion.closeConnection();
  end if;
  logger.trace( 'check access: "' || svnPath || '": end');
  return
    accessFlag;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки доступа к файлу в репозитории'
      )
    , true
  );
end checkAccess;

end pkg_SvnSearcherAccess;
/
