package com.technology.exchange.svnsearcher.main.client.ui.main;

import static com.technology.exchange.svnsearcher.main.client.SvnSearcherClientConstant.*;

import java.util.ArrayList;
import java.util.List;

import com.technology.jep.jepria.client.ui.main.MainViewImpl;
import com.technology.jep.jepria.client.ui.main.ModuleConfiguration;

public class SvnSearcherMainViewImpl extends MainViewImpl {

  @Override
  protected List<ModuleConfiguration> getModuleConfigurations() {
    List<ModuleConfiguration> ret = new ArrayList<>();
    ret.add(new ModuleConfiguration(SVNSEARCHER_MODULE_ID, svnSearcherText.submodule_svnsearcher_title()));
    return ret;
  }
}
