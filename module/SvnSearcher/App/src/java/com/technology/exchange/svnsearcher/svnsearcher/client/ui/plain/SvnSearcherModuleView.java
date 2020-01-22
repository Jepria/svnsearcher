package com.technology.exchange.svnsearcher.svnsearcher.client.ui.plain;

import com.technology.jep.jepria.client.ui.plain.PlainModuleView;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.list.ListManager;
import com.technology.jep.jepria.client.widget.toolbar.PagingStandardBar;
import com.technology.jep.jepria.shared.load.PagingResult;

public interface SvnSearcherModuleView extends PlainModuleView {

  void addSearchButtonClickListener(JepListener listener);
  
  String getSearchText();

  ListManager getListManager();
  
  void setUsername(String username);
  
  FieldManager getFieldManager();
  
  void updateSearchStatus(PagingResult pagingResult);
  
  void clearStatusPanel();
  
  PagingStandardBar getPagingBar();
  
  void addEnterClickListener(JepListener listener);
}
