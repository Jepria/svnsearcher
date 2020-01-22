-- Индексирование репозиториев SVN.
declare

  repositoryCount integer := pkg_Scheduler.getContextValueCount(
    'RepositoryNameList'
    , riseException => 1
  );

  directoryMaskList varchar2(32767) := pkg_Scheduler.getContextString(
    'DirectoryMaskList'
  );

  timeLimitMinute number := pkg_Scheduler.getContextInteger(
    'TimeLimitMinute'
  );

  utf8FileMaskList varchar2(32767) := pkg_Scheduler.getContextString(
    'Utf8FileMaskList'
  );

  -- Время начала
  startTime date := sysdate;

begin
  for repositoryIndex in 1 .. repositoryCount loop
    pkg_Scheduler.writeLog( pkg_Scheduler.Debug_MessageTypeCode, to_char( repositoryIndex));
    pkg_SvnSearcherIndex.indexRepository(
      repositoryName =>
         pkg_Scheduler.getContextString(
          'RepositoryNameList'
          , riseException => 1
          , valueIndex => repositoryIndex
        )
      , directoryMaskList => directoryMaskList
      , maxFinishTime => startTime + timeLimitMinute / 24 / 60
      , utf8FileMaskList => utf8FileMaskList
    );
  end loop;
end;
