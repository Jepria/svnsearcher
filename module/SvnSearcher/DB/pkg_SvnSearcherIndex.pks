create or replace package pkg_SvnSearcherIndex
is
/* package: pkg_SvnSearcherIndex
  Интерфейсный пакет модуля SvnSearcher.

  SVN root: Module/SvnSearcher
*/

/* const: PathSeparator_Windows
  Разделитель пути в ОС семейства Windows.
*/
PathSeparator_Windows constant varchar2(1) := '\';

/* const: PathSeparator_Unix
  Разделитель пути в ОС семейства Unix.
*/
PathSeparator_Unix constant varchar2(1) := '/';

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'SvnSearcher';

/* const: indexSyncOperationType
  Название типа операции по синхронизации индекса Oracle Text.
*/
indexSyncOperationType constant varchar2(30) := 'SYNC';

/* const: indexRecreateOperationType
  Название типа операции по пересозданию индекса Oracle Text.
*/
indexRecreateOperationType constant varchar2(30) := 'RECREATE';


/* group: Кодировки */

/* const: Win1251_Encoding
  Код кодировки windows 1251.
*/
Win1251_Encoding constant varchar2(30) := 'CL8MSWIN1251';

/* const: Utf8_Encoding
  Код кодировки utf 8.
*/
Utf8_Encoding constant varchar2(30) := 'UTF8';




/* group: Функции */



/* group: Утилиты */

/* pfunc: encodeXml
  Кодирует XML для того, чтобы индексировались значения атрибутов.

  Параметры:
  xmlData                     - данные XML в виде blob

  Возврат:
  - кодированные данные в виде blob;

  ( <body::encodeXml>)
*/
function encodeXml(
  xmlData blob
)
return blob;

/* pfunc: decodeXmlSnippet
  Декодирование XML, обратное <encodeXml>, из снипета в виде HTML.

  Параметры:
  encodedSnippet               - текст xml в виде HTML, кодированный
                                 <encodedXml>;

  Возврат:
  - декодированный снипет ( участок текста);

  ( <body::decodeXmlSnippet>)
*/
function decodeXmlSnippet(
  encodedSnippet varchar2
)
return varchar2;

/* pfunc: getRepositoryUrl
  Получение URL репозитория по имени.

  Параметры:
  serverName                  - имя сервера
  repositoryName              - имя репозитория

  ( <body::getRepositoryUrl>)
*/
function getRepositoryUrl(
  serverName varchar2
  , repositoryName varchar2
)
return varchar2;

/* pproc: openConnection
  Соединение с репозиторием SVN с использованием опций модуля
  <pkg_SvnSearcherBase::Наименования опций для соединения с репозиторием>;

  Параметры:
  repositoryName              - имя репозитория

  ( <body::openConnection>)
*/
procedure openConnection(
  repositoryName varchar2
);

/* pproc: closeConnection
  Закрытие соединения с репозиторием.

  ( <body::closeConnection>)
*/
procedure closeConnection;

/* pfunc: isOfMask
  Возвращаем 1, если имя файла удовлетворяет хотя бы одной из масок
  перечисленных в MaskSet через ',', и 0 в противном случае.

  Параметры:
  fileName                    - имя файла
  maskSet                     - маски для файлов (через ',')

  ( <body::isOfMask>)
*/
function isOfMask(
  fileName varchar2
  , maskSet varchar2
)
return integer;



/* group: Индексирование */

/* pproc: finishRepositoryIndex
  Завершение индексирования репозитория.

  Параметры:
  repositoryName              - имя SVN репозитория

  ( <body::finishRepositoryIndex>)
*/
procedure finishRepositoryIndex(
  repositoryName varchar2
);

/* pproc: synchronizeIndex
  Синхронизация индекса <ss_file::ss_file_ctx_search>;

  ( <body::synchronizeIndex>)
*/
procedure synchronizeIndex;

/* pproc: indexDirectory
  Индексирование директории в SVN.

  Параметры:
  repositoryName              - имя SVN репозитория
  directorySvnPath            - относительный путь директории в SVN
  maxFinishTime               - время, после которого индексирование
                                прекращается
  fileNameMaskList            - список масок имён файлов для индексирования
  excludeSvnPathMaskList      - список масок путей файлов для исключения из
                                индексирования
  utf8FileMaskList            - маска для имён файлов, содержащих ( через ",")
                                ( по-умолчанию используется значение опции
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - удаление неактуальных устаревших данных (
                                по-умолчанию, да)

  Замечание:
  - предполагается, что соединение с SVN установлено;
  - процедура выполняется в автономной транзакции для скорейшей возможности
    использования результатов индексирования;

  ( <body::indexDirectory>)
*/
procedure indexDirectory(
  repositoryName varchar2
  , directorySvnPath varchar2
  , maxFinishTime date
  , fileNameMaskList varchar2
  , excludeSvnPathMaskList varchar2
  , utf8FileMaskList varchar2
  , maxIndexFileSize integer
  , deleteOldDataFlag boolean := null
);

/* pproc: indexRepository
  Индексирование репозитория.

  Параметры:
  repositoryName              - имя SVN репозитория
  directoryMaskList           - список масок директорий для индексирования
  maxFinishTime               - время, после которого индексирование
                                прекращается
  utf8FileMaskList            - маска для имён файлов, содержащих ( через ",")
                                ( по-умолчанию используется значение опции
                                <pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName>;
  deleteOldDataFlag           - удаление неактуальных устаревших данных (
                                по-умолчанию, да)

  ( <body::indexRepository>)
*/
procedure indexRepository(
  repositoryName varchar2
  , directoryMaskList varchar2 := null
  , maxFinishTime date := null
  , utf8FileMaskList varchar2 := null
  , deleteOldDataFlag boolean := null
);

end pkg_SvnSearcherIndex;
/
