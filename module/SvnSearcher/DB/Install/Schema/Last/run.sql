-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run ss_file.tab
@oms-run ss_file_exclude_tmp.tab
@oms-run ss_index_directory_tmp.tab
@oms-run ss_repository.tab


-- ������������������

@oms-run ss_file_seq.sqs
@oms-run ss_repository_seq.sqs
