#
# Project Makefile
#

# ����������� ����
.PHONY:									\
	all										\
	$(MAKECMDGOALS)				\
	


#
# ����������� ���� � �����������
#
all:
	@$(MAKE) -C DB $(MAKECMDGOALS)

ifeq ($(filter all,$(MAKECMDGOALS)),)
$(MAKECMDGOALS): all
endif
