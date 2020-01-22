-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_SvnSearcher
/
drop package pkg_SvnSearcherAccess
/
drop package pkg_SvnSearcherBase
/
drop package pkg_SvnSearcherIndex
/


-- ������� �����

@oms-drop-foreign-key ss_file
@oms-drop-foreign-key ss_file_exclude_tmp
@oms-drop-foreign-key ss_index_directory_tmp
@oms-drop-foreign-key ss_repository


-- �������

drop table ss_file
/
drop table ss_file_exclude_tmp
/
drop table ss_index_directory_tmp
/
drop table ss_repository
/


-- ������������������

drop sequence ss_file_seq
/
drop sequence ss_repository_seq
/
