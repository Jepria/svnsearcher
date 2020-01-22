#
# ����������� ��� �������� ������ � ��.
#
# ����� � ������������ ������ ����������� � �������������� ���������:
# .$(lu)      - �������� ��� ������ �������������
# .$(lu2)     - �������� ��� ������ �������������
# .$(lu3)     - �������� ��� ������� �������������
# ...         - ...
#
# ������ ( ����������� ���� ������ pkg_TestModule �� ����������� ������������
# � ������������ ������ pkg_TestModule2 ��� �������� ��� ������ �������������):
#
# pkg_TestModule.pkb.$(lu): \
#   pkg_TestModule.pks.$(lu) \
#   pkg_TestModule2.pks.$(lu)
#
#
# ���������:
# - � ������ ����� �� ������ �������������� ������ ��������� ( ������ ���� ���
#   �������������� ����� ������������ �������), �.�. ������ ��������� �����
#   ����������� �������� ��� make � ��� ��������� ��������� ����� �������� �
#   �������������������� �������;
# - � ������, ���� ��������� ������ ����������� ����� ����������� ��������
#   ������������� ( �������� ����� ������), �� ����� �����������
#   ������ ���� ��� ������� ���� ������ ������, ����� ��� �������� �����
#   ��������� ������ "*** No rule to make target ` ', needed by ...";
# - ����� � ����������� ������ ����������� � ����� ������������ �������� DB
#   � ������ ��������, �������� "Install/Schema/Last/test_view.vw.$(lu): ...";
#

pkg_SvnSearcher.pkb.$(lu): \
  pkg_SvnSearcher.pks.$(lu) \
  pkg_SvnSearcherBase.pks.$(lu)


pkg_SvnSearcher.pkb.$(lu): \
  pkg_SvnSearcher.pks.$(lu) \
  pkg_SvnSearcherBase.pks.$(lu) \
  pkg_SvnSearcherIndex.pks.$(lu)


pkg_SvnSearcherAcccess.pkb.$(lu): \
  pkg_SvnSearcherBase.pks.$(lu) \
  pkg_SvnSearcherAccess.pks.$(lu)


pkg_SvnSearcherIndex.pkb.$(lu): \
  pkg_SvnSearcherBase.pks.$(lu) \
  pkg_SvnSearcher.pks.$(lu) \
  pkg_SvnSearcherIndex.pks.$(lu)




