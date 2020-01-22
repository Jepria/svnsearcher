package com.technology.exchange.svnsearcher.main.client;
 
import static com.technology.exchange.svnsearcher.main.client.SvnSearcherClientConstant.*;

import com.allen_sauer.gwt.log.client.Log; 
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.IsWidget;


import com.technology.exchange.svnsearcher.svnsearcher.client.SvnSearcherClientFactoryImpl;
import com.technology.exchange.svnsearcher.main.client.ui.main.SvnSearcherMainModulePresenter;
import com.technology.exchange.svnsearcher.main.client.ui.main.SvnSearcherMainViewImpl;

import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainClientFactoryImpl;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.client.async.LoadAsyncCallback;
import com.technology.jep.jepria.client.async.LoadPlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;

public class SvnSearcherMainClientFactoryImpl extends MainClientFactoryImpl<MainEventBus, JepMainServiceAsync> {

  private static final IsWidget mainView = new SvnSearcherMainViewImpl();
      
  public static MainClientFactory<MainEventBus, JepMainServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(SvnSearcherMainClientFactoryImpl.class);
    }
    return instance;
  }
 
  private SvnSearcherMainClientFactoryImpl() {
    super(
        SVNSEARCHER_MODULE_ID
    );
  }
  
  @Override
  public MainModulePresenter<? extends MainView, MainEventBus, JepMainServiceAsync, ? extends MainClientFactory<MainEventBus, JepMainServiceAsync>>
      createMainModulePresenter() {
    return new SvnSearcherMainModulePresenter(this);
  }

  @Override
  public void getPlainClientFactory(String moduleId, final LoadAsyncCallback<PlainClientFactory<PlainEventBus, JepDataServiceAsync>> callback) {
    // Для эффективного кодоразделения при GWT-компиляции (см. http://www.gwtproject.org/doc/latest/DevGuideCodeSplitting.html)
    // необходимо получать инстанс каждой plain-фабрики модуля с помощью GWT.runAsync, в отдельной ветке if-else, зависящей от ID модуля.
    
    if(SVNSEARCHER_MODULE_ID.equals(moduleId)) {
      GWT.runAsync(new LoadPlainClientFactory(callback) {
        public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getPlainClientFactory() {
          Log.trace(SvnSearcherMainClientFactoryImpl.this.getClass() + ".getPlainClientFactory: moduleId = " + moduleId);
          return SvnSearcherClientFactoryImpl.getInstance();
        }
      });
    }
  }
  
  @Override
  public IsWidget getMainView() {
    return mainView;
  }
}
