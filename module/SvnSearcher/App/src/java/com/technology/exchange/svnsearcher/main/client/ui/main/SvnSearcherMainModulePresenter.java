package com.technology.exchange.svnsearcher.main.client.ui.main;
 
import static com.technology.exchange.svnsearcher.main.client.SvnSearcherClientConstant.*;
import static com.technology.jep.jepria.client.security.ClientSecurity.CHECK_ROLES_BY_OR;
 
import java.util.HashSet;
import java.util.Set;
 
import com.google.gwt.place.shared.Place;
 
import com.technology.jep.jepria.client.ui.main.MainView;
import com.technology.jep.jepria.client.ui.eventbus.main.MainEventBus;
import com.technology.jep.jepria.client.ui.main.MainClientFactory;
import com.technology.jep.jepria.client.ui.main.MainModulePresenter;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;
 
public class SvnSearcherMainModulePresenter<E extends MainEventBus, S extends JepMainServiceAsync>
      extends MainModulePresenter<MainView, E, S, MainClientFactory<E, S>> {
 
  public SvnSearcherMainModulePresenter(MainClientFactory<E, S> clientFactory) {
    super(clientFactory);
    addModuleProtection(SVNSEARCHER_MODULE_ID, "SsAll", CHECK_ROLES_BY_OR);
  }
 
}
