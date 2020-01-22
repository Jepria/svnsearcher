declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_SvnSearcherBase.Module_Name
  );

begin
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnServerName_OptionSName
    , optionName => 'Ñåğâåğ SVN'
    , stringValue => 'srvsvn'
  );
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnLogin_OptionSName
    , optionName => 'Ëîãèí äëÿ ñîåäèíåíèÿ ñ ğåïîçèòîğèåì SVN'
    , prodStringValue => 'SvnSearcher'
    , testStringValue => 'SvnSearcherTest'
  );
  optionList.addString(
    optionShortName => pkg_SvnSearcherBase.SvnPassword_OptionSName
    , optionName => 'Ïàğîëü äëÿ ñîåäèíåíèÿ ñ ğåïîçèòîğèåì SVN'
    -- Çàïîëíÿåòñÿ ïîëüçîâàòåëåì
    , prodStringValue => null
    , testStringValue => null
    , encryptionFlag => 1
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.FileNameMaskList_OptionSName
    , optionName => 'Ñïèñîê ìàñîê èì¸í ôàéëîâ äëÿ èíäåêñèğîâàíèÿ'
    , valueList =>
        '%.con,%.doc,%.docx,%.java,%.jav,%.html,%.htm,%.tab,%.pdf,%.prc,%.pks,%.pkb,%.pl,%.pm,%.snp,%.sqs,%.sql,%.trg,%.typ,%.tyb,%.txt,%.vw,%.xml,%.xls'
    , listSeparator => ','
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.ExcludePathList_OptionSName
    , optionName => 'Ñïèñîê ìàñîê ïóòåé ôàéëîâ äëÿ èñêëş÷åíèÿ èç èíäåêñèğîâàíèÿ ÷åğåç ","'
    , valueList => '%/Tag/%,%/Tags/%,%/Branch/%,%/Branches/%'
    , listSeparator => ','
  );
  optionList.addStringList(
    optionShortName => pkg_SvnSearcherBase.Utf8PathMaskList_OptionSName
    , optionName => 'Ñïèñîê ìàñîê îòíîñèòåëüíûõ ïóòåé SVN ôàéëîâ, èíòåğïğåòèğóåìûõ êàê òåêñòîâûå â êîäèğîâêå UTF-8 ÷åğåç ","'
    , valueList => '%.java'
    , listSeparator => ','
  );
  optionList.addNumber(
    optionShortName => pkg_SvnSearcherBase.MaxIndexFileSize_OptionSName
    , optionName => 'Ìàêñèìàëüíûé ğàçìåğ ôàéëà äëÿ èíäåêñèğîâàíèÿ ( â áàéòàõ)'
    , numberValue => 10000000
  );
end;
/
