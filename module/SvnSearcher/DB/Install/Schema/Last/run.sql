-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run ss_file.tab
@oms-run ss_file_exclude_tmp.tab
@oms-run ss_index_directory_tmp.tab
@oms-run ss_repository.tab


-- Последовательности

@oms-run ss_file_seq.sqs
@oms-run ss_repository_seq.sqs
