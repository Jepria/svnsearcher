package com.technology.exchange.svnsearcher.svnsearcher.client;

import static com.technology.exchange.svnsearcher.main.client.SvnSearcherClientConstant.SVNSEARCHER_MODULE_ID;

import com.google.gwt.core.client.GWT;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.IsWidget;
import com.technology.exchange.svnsearcher.svnsearcher.client.ui.plain.SvnSearcherModulePresenter;
import com.technology.exchange.svnsearcher.svnsearcher.client.ui.plain.SvnSearcherModuleViewImpl;
import com.technology.exchange.svnsearcher.svnsearcher.shared.record.SvnSearcherRecordDefinition;
import com.technology.exchange.svnsearcher.svnsearcher.shared.service.SvnSearcherService;
import com.technology.exchange.svnsearcher.svnsearcher.shared.service.SvnSearcherServiceAsync;
import com.technology.jep.jepria.client.ui.JepPresenter;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl;
import com.technology.jep.jepria.shared.service.data.JepDataServiceAsync;

public class SvnSearcherClientFactoryImpl<E extends PlainEventBus, S extends SvnSearcherServiceAsync>
  extends com.technology.jep.jepria.client.ui.plain.PlainClientFactoryImpl<E, S> {

  private static PlainClientFactoryImpl<PlainEventBus, JepDataServiceAsync> instance = null;

  public SvnSearcherClientFactoryImpl() {
    super(SvnSearcherRecordDefinition.instance);
  }

  static public PlainClientFactory<PlainEventBus, JepDataServiceAsync> getInstance() {
    if(instance == null) {
      instance = GWT.create(SvnSearcherClientFactoryImpl.class);
    }
    return instance;
  }

  public IsWidget getModuleView() {
    if(moduleView == null) {
      moduleView = new SvnSearcherModuleViewImpl();
    }
    return moduleView;
  }

  public JepPresenter createPlainModulePresenter(Place place) {
    return new SvnSearcherModulePresenter(SVNSEARCHER_MODULE_ID, place, this);
  }


  public S getService() {
    if(dataService == null) {
      dataService = (S) GWT.create(SvnSearcherService.class);
    }
    return dataService;
  }
}
