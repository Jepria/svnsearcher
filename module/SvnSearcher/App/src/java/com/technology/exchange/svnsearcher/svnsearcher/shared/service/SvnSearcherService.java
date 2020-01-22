package com.technology.exchange.svnsearcher.svnsearcher.shared.service;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataService;

@RemoteServiceRelativePath("SvnSearcherService")
public interface SvnSearcherService extends JepDataService {
  List<JepOption> getFileNameList() throws ApplicationException;
  List<JepOption> getRepository() throws ApplicationException;
  List<JepOption> getOrderColumnName() throws ApplicationException;
}
