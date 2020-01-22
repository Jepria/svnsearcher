package com.technology.exchange.svnsearcher.svnsearcher.server;

import com.technology.exchange.svnsearcher.svnsearcher.server.dao.SvnSearcher;
import com.technology.exchange.svnsearcher.svnsearcher.server.dao.SvnSearcherDao;
import com.technology.jep.jepria.server.ServerFactory;

import static com.technology.exchange.svnsearcher.svnsearcher.server.SvnSearcherServerConstant.DATA_SOURCE_JNDI_NAME;

public class SvnSearcherFactory extends ServerFactory<SvnSearcher> {

  public SvnSearcherFactory() {
    super(new SvnSearcherDao(), DATA_SOURCE_JNDI_NAME);
  }
  
  public final static SvnSearcherFactory instance = new SvnSearcherFactory();

}
