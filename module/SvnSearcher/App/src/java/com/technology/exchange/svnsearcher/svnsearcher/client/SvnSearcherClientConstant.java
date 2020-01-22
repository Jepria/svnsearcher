package com.technology.exchange.svnsearcher.svnsearcher.client;
 
import com.google.gwt.core.client.GWT;
import com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant;
import com.technology.exchange.svnsearcher.svnsearcher.shared.text.SvnSearcherText;
 
public class SvnSearcherClientConstant extends SvnSearcherConstant {
 
  public static final SvnSearcherText svnSearcherText = (SvnSearcherText) GWT.create(SvnSearcherText.class);
  
}
