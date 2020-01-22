package com.technology.exchange.svnsearcher.svnsearcher.shared.record;
 
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.*;
import static com.technology.jep.jepria.shared.field.JepTypeEnum.*;
import com.technology.jep.jepria.shared.field.JepTypeEnum;
import com.technology.jep.jepria.shared.record.JepRecordDefinition;
 
import java.util.HashMap;
import java.util.Map;
 
public class SvnSearcherRecordDefinition extends JepRecordDefinition {
 
  private static final long serialVersionUID = 1L;
 
  public static final SvnSearcherRecordDefinition instance = new SvnSearcherRecordDefinition();
 
  private SvnSearcherRecordDefinition() {
    super(buildTypeMap()
      , new String[]{FILE_ID}
    );
  }
 
  private static Map<String, JepTypeEnum> buildTypeMap() {
    Map<String, JepTypeEnum> typeMap = new HashMap<String, JepTypeEnum>();
    typeMap.put(FILE_ID, INTEGER);
    typeMap.put(REPOSITORY_NAME, STRING);
    typeMap.put(SVN_PATH, STRING);
    typeMap.put(URL, STRING);
    typeMap.put(FILE_EXTENTION, STRING);
    typeMap.put(SVN_LAST_MODIFICATION, STRING);
    typeMap.put(REVISION, STRING);
    typeMap.put(FILE_SIZE, STRING);
    typeMap.put(LAST_CHECK_DATE, DATE);
    typeMap.put(LAST_ALL_INDEX_DATE, DATE);
    typeMap.put(RESULT_COUNT, INTEGER);
    typeMap.put(RESULT_ROW_NUMBER, INTEGER);
    typeMap.put(SNIPPET, STRING);
    typeMap.put(SEARCH_STRING, STRING);
    typeMap.put(PAGE_ROW_COUNT, INTEGER);
    typeMap.put(PAGE_NUMBER, INTEGER);
    typeMap.put(INTERNAL_RESULT_LIMIT, INTEGER);
    typeMap.put(SVN_LOGIN, STRING);
    typeMap.put(SVN_PASSWORD, STRING);
    typeMap.put(FILE_NAME_LIST, STRING);
    typeMap.put(SVN_PATH_LIST, STRING);
    typeMap.put(LAST_MODIFICATION_FROM, DATE);
    typeMap.put(LAST_MODIFICATION_TO, DATE);
    typeMap.put(REVISION_FROM, INTEGER);
    typeMap.put(REVISION_TO, INTEGER);
    typeMap.put(AUTHOR, STRING);
    typeMap.put(FILE_SIZE_FROM, INTEGER);
    typeMap.put(FILE_SIZE_TO, INTEGER);
    return typeMap;
  }
}
