package com.technology.exchange.svnsearcher.main.client.entrance;

import com.technology.exchange.svnsearcher.main.client.SvnSearcherMainClientFactoryImpl;
import com.technology.jep.jepria.client.entrance.JepEntryPoint;

public class SvnSearcherEntryPoint extends JepEntryPoint {

  SvnSearcherEntryPoint() {
    super(SvnSearcherMainClientFactoryImpl.getInstance());
  }
}
