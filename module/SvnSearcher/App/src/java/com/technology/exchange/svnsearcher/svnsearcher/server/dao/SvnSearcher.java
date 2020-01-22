package com.technology.exchange.svnsearcher.svnsearcher.server.dao;

import java.util.List;

import com.technology.jep.jepria.server.dao.JepDataStandard;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;

public interface SvnSearcher extends JepDataStandard {
  List<JepOption> getFileNameList() throws ApplicationException;
  List<JepOption> getRepository() throws ApplicationException;
  List<JepOption> getOrderColumnName() throws ApplicationException;
}
