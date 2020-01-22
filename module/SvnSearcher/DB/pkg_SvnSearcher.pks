create or replace package pkg_SvnSearcher is
/* package: pkg_SvnSearcher
  Интерфейсный пакет модуля SVNSearcher.

  SVN root: Module/SVNSearcher
*/



/* group: Функции */

/* pfunc: getResultUrl
  Получение URL для результатов поиска.

  Параметры:
  serverName                  - имя сервера ( хост)
  repositoryName              - наименование репозитория
  svnPath                     - относительный путь к файлу в SVN
  login                       - логин для подстановки в URL ( не обязателен)
  password                    - пароль для подстановки в URL ( не обязателен)

  ( <body::getResultUrl>)
*/
function getResultUrl(
  serverName varchar2
  , repositoryName varchar2
  , svnPath varchar2
  , login varchar2
  , password varchar2
)
return varchar2;

/* pfunc: getRepository
  Получение списка репозиториев.

  Поля возвращаемого курсора:
  repository_name             - маска имени файла

  ( <body::getRepository>)
*/
function getRepository
return sys_refcursor;

/* pfunc: getFileNameMask
  Получение списка масок файлов.

  Поля возвращаемого курсора:
  file_name_mask              - маска имени файла

  ( <body::getFileNameMask>)
*/
function getFileNameMask
return sys_refcursor;

/* pfunc: findString
  Поиск подстроки в SVN.

  Параметры:
  operatorId                  - id оператора
  searchString                - фраза для поиска ( возможен шаблон ,
                                содержащий "%", "?", подставляется в
                                оператор CONTAINS
                                <http://docs.oracle.com/cd/E11882_01/text.112/e24435/query.htm#CCAPP9175>)
  pageRowCount                - количество записей результатов на странице (
                                обязательный параметр)
  pageNumber                  - номер страницы ( по-умолчанию 1)
  internalResultLimit         - лимит внутреннего поиска для оптимизации
                                производительности ( по-умолчанию
                                <body::Default_InternalResultLimit>)
  svnLogin                    - логин SVN для показа куска текста, где найдена строка
  svnPassword                 - пароль SVN для показа куска текста, где найдена строка
  repositoryNameList          - список репозиториев через ","
  fileNameList                - список масок для имён файлов через "," (
                                заполнение в интерфейсе предполагается с
                                использованием <getFileNameMask>)
  svnPathList                 - список масок путей к файлу SVN через ","
  skipSvnPathList             - список масок путей к файлу SVN через "," для
                                игнорирования
  lastModificationFrom        - дата модификации файла SVN от
  lastModificationTo          - дата модификации файла SVN по
  revisionFrom                - ревизия ( правка) в SVN от
  revisionTo                  - ревизия ( правка) в SVN по
  author                      - автор в SVN
  fileSizeFrom                - размер файла от
  fileSizeTo                  - размер файла по
  svnPathOrderFlag            - признак применения сотировки по пути в SVN
                                ( по умолчанию по дате модификации)

  Поля возвращаемого курсора:
  file_id                     - id файла, первичный ключ
  repository_name             - наименование репозитория
  svn_path                    - путь к файлу в репозитории SVN
  url                         - ссылка ( URL)
  file_extention              - расширение файла
  svn_last_modification       - дата/время модификации в SVN
  revision                    - номер ревизии ( правки ) SVN
  author                      - автор в SVN
  file_size                   - размер файла
  last_check_date             - дата актуальности
  last_all_index_date         - дата последнего завершения индексирования
                                репозитория
  result_count                - количество записей в результате
  result_row_number           - номер строки в результате
  snippet                     - участок кода, содержащий строку, при наличии
                                доступа

  Примечание:
  - результаты упорядочены по дате изменения в SVN, а также по релевантности в
    обратном порядке;

  ( <body::findString>)
*/
function findString(
  operatorId integer
  , searchString varchar2
  , pageRowCount integer
  , pageNumber integer := null
  , internalResultLimit integer := null
  , svnLogin varchar2 := null
  , svnPassword varchar2 := null
  , repositoryNameList varchar2 := null
  , fileNameList varchar2 := null
  , svnPathList varchar2 := null
  , skipSvnPathList varchar2 := null
  , lastModificationFrom date := null
  , lastModificationTo date := null
  , revisionFrom integer := null
  , revisionTo integer := null
  , author varchar2 := null
  , fileSizeFrom integer := null
  , fileSizeTo integer := null
  , svnPathOrderFlag integer := null
)
return sys_refcursor;

end pkg_SvnSearcher;
/
