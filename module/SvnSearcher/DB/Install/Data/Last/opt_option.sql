declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_SvnSearcherBase.Module_Name
  );

begin
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnServerName_OptionSName
    , optionName => '������ SVN'
    , stringValue => 'srvsvn'
  );
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnLogin_OptionSName
    , optionName => '����� ��� ���������� � ������������ SVN'
    , prodStringValue => 'SvnSearcher'
    , testStringValue => 'SvnSearcherTest'
  );
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnPassword_OptionSName
    , optionName => '������ ��� ���������� � ������������ SVN'
    -- ����������� �������������
    , prodStringValue => null
    , testStringValue => null
    , encryptionFlag => 1
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.FileNameMaskList_OptionSName
    , optionName => '������ ����� ��� ������ ��� ��������������'
    , valueList =>
        '%.con,%.doc,%.docx,%.java,%.jav,%.html,%.htm,%.tab,%.pdf,%.prc,%.pks,%.pkb,%.pl,%.pm,%.snp,%.sqs,%.sql,%.trg,%.typ,%.tyb,%.txt,%.vw,%.xml,%.xls'
    , listSeparator => ','
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.ExcludePathList_OptionSName
    , optionName => '������ ����� ����� ������ ��� ���������� �� �������������� ����� ","'
    , valueList => '%/Tag/%,%/Tags/%,%/Branch/%,%/Branches/%'
    , listSeparator => ','
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName
    , optionName => '������ ����� ������������� ����� SVN ������, ���������������� ��� ��������� � ��������� UTF-8 ����� ","'
    , valueList => '%.java'
    , listSeparator => ','
  );
  optionList.addNumber(
    optionShortName => pkg_SvnSearcherBase.MaxIndexFileSize_OptionSName
    , optionName => '������������ ������ ����� ��� �������������� ( � ������)'
    , numberValue => 10000000
  );
end;
/
