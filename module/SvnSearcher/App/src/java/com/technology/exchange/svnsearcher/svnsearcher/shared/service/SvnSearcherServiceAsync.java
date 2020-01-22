package com.technology.exchange.svnsearcher.svnsearcher.shared.service;

import com.technology.jep.jepria.shared.field.option.JepOption;
import com.google.gwt.user.client.rpc.AsyncCallback;
import java.util.List;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;

public interface SvnSearcherServiceAsync extends JepDataServiceAsync {
  void getFileNameList(AsyncCallback<List<JepOption>> callback);
  void getRepository(AsyncCallback<List<JepOption>> callback);
  void getOrderColumnName(AsyncCallback<List<JepOption>> callback);
}
