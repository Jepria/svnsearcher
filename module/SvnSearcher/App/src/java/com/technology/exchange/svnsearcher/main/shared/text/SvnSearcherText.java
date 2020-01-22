package com.technology.exchange.svnsearcher.main.shared.text;

/**
 * Interface to represent the constants contained in resource bundle:
 *   'D:/svn/Exchange/Module/SvnSearcher/Trunk/App/src/java/com/technology/exchange/svnsearcher/main/shared/text/SvnSearcherText.properties'.
 */
public interface SvnSearcherText extends com.google.gwt.i18n.client.Constants {
  
  /**
   * Translated "SvnSearcher".
   * 
   * @return translated "SvnSearcher"
   */
  @DefaultStringValue("SvnSearcher")
  @Key("module.title")
  String module_title();

  /**
   * Translated "Поиск по svn".
   * 
   * @return translated "Поиск по svn"
   */
  @DefaultStringValue("Поиск по svn")
  @Key("submodule.svnsearcher.title")
  String submodule_svnsearcher_title();
}
