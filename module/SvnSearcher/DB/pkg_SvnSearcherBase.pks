create or replace package pkg_SvnSearcherBase is
/* package: pkg_SvnSearcherBase
  Пакет, содержащий базовые константы.

  SVN root: Module/SVNSearcher
*/



/* const: Module_Name
  Наименование модуля.
*/
Module_Name constant varchar2(30) := 'SvnSearcher';



/* group: Наименование ролей */

/* const: All_RoleShortName
  Короткое наименование роли "Доступ к данным SvnSearcher".
*/
All_RoleShortName constant varchar2(30) := 'SsAll';



/* group: Наименования опций для соединения с репозиторием */

/* const: SvnServerName_OptionSName
  Короткое наименование опции "Имя сервера SVN".
*/
SvnServerName_OptionSName constant varchar2(50) := 'SvnServerName';

/* const: SvnLogin_OptionSName
  Короткое наименование опции "Логин для соединения с репозиторием SVN".
*/
SvnLogin_OptionSName constant varchar2(50) := 'SvnLogin';

/* const: SvnPassword_OptionSName
  Короткое наименование опции "Пароль для соединения с репозиторием SVN".
*/
SvnPassword_OptionSName constant varchar2(50) := 'SvnPassword';



/* group: Наименования опций для настройки индексирования */

/* const: FileNameMaskList_OptionSName
  Короткое наименование опции "Список масок имён файлов для индексирования через ','"
*/
FileNameMaskList_OptionSName constant varchar2(50) := 'FileNameMaskList';

/* const: ExcludePathList_OptionSName
  Короткое наименование опции "Список масок путей файлов для исключения из индексирования через ','"
*/
ExcludePathList_OptionSName constant varchar2(50) := 'ExcludeFileSvnPathMaskList';

/* const: Utf8PathMaskList_OptionSName
  Короткое наименование опции "Список масок относительных путей SVN файлов,
  интерпретируемых как текстовые в кодировке UTF-8".
*/
Utf8PathMaskList_OptionSName constant varchar2(50) := 'Utf8SvnPathMaskList';

/* const: MaxIndexFileSize_OptionSName
  Короткое наименование опции "Максимальный размер файла для индексирования".
*/
MaxIndexFileSize_OptionSName constant varchar2(50) := 'MaxIndexFileSize';

end pkg_SvnSearcherBase;
/
