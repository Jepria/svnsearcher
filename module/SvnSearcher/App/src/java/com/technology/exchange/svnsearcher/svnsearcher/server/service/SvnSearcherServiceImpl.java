package com.technology.exchange.svnsearcher.svnsearcher.server.service;

import java.util.List;

import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.technology.exchange.svnsearcher.svnsearcher.server.SvnSearcherFactory;
import com.technology.exchange.svnsearcher.svnsearcher.server.dao.SvnSearcher;
import com.technology.exchange.svnsearcher.svnsearcher.shared.record.SvnSearcherRecordDefinition;
import com.technology.exchange.svnsearcher.svnsearcher.shared.service.SvnSearcherService;
import com.technology.jep.jepria.server.service.JepDataServiceServlet;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;

@RemoteServiceRelativePath("SvnSearcherService")
public class SvnSearcherServiceImpl extends JepDataServiceServlet<SvnSearcher> implements SvnSearcherService  {

  private static final long serialVersionUID = 1L;

  public SvnSearcherServiceImpl() {
    super(SvnSearcherRecordDefinition.instance, SvnSearcherFactory.instance);
  }

  public List<JepOption> getFileNameList() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getFileNameList();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }

  public List<JepOption> getRepository() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getRepository();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }

  @Override
  public List<JepOption> getOrderColumnName() throws ApplicationException {
    List<JepOption> result = null;
    try {
      result = dao.getOrderColumnName();
    } catch (Throwable th) {
      throw new ApplicationException(th.getLocalizedMessage(), th);
    }
    return result;
  }
}
