package com.technology.exchange.svnsearcher.main.client;
 
import com.google.gwt.core.client.GWT;
 
import com.technology.exchange.svnsearcher.main.shared.text.SvnSearcherText;
 
import com.technology.jep.jepria.shared.JepRiaConstant;
 
public class SvnSearcherClientConstant extends JepRiaConstant {
  public static final String SVNSEARCHER_MODULE_ID = "SvnSearcher";
 
  public static final SvnSearcherText svnSearcherText = (SvnSearcherText) GWT.create(SvnSearcherText.class);
 
  public static final String URL_SVNSEARCHER_MODULE = "/SvnSearcher/SvnSearcher.jsp?em=SvnSearcher&es=sh";
}
