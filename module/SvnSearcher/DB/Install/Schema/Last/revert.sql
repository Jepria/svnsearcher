-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_SvnSearcher
/
drop package pkg_SvnSearcherAccess
/
drop package pkg_SvnSearcherBase
/
drop package pkg_SvnSearcherIndex
/


-- Внешние ключи

@oms-drop-foreign-key ss_file
@oms-drop-foreign-key ss_file_exclude_tmp
@oms-drop-foreign-key ss_index_directory_tmp
@oms-drop-foreign-key ss_repository


-- Таблицы

drop table ss_file
/
drop table ss_file_exclude_tmp
/
drop table ss_index_directory_tmp
/
drop table ss_repository
/


-- Последовательности

drop sequence ss_file_seq
/
drop sequence ss_repository_seq
/
