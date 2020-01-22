package com.technology.exchange.svnsearcher.svnsearcher.client.widget.list;

import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.*;
import static com.technology.exchange.svnsearcher.svnsearcher.client.SvnSearcherClientConstant.svnSearcherText;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_DATE_FORMAT;
import static com.technology.jep.jepria.shared.JepRiaConstant.DEFAULT_TIME_FORMAT;

import java.util.Date;

import com.google.gwt.dom.client.Element;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.i18n.client.NumberFormat;
import com.google.gwt.safehtml.shared.SafeHtmlUtils;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.CellPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.Label;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.JepRiaUtil;

public class ListItemViewImpl extends CellPanel {

  private Element tableRow;
  private Element nameColumn;

  public ListItemViewImpl(JepRecord record) {
    super();
    
    tableRow = DOM.createTR();
    tableRow.addClassName("svnSearcher-searchRow");
    DOM.appendChild(getBody(), tableRow);
    
    DOM.setElementProperty(getTable(), "cellSpacing", "0");
    DOM.setElementProperty(getTable(), "cellPadding", "0");

    setWidth("100%");

    nameColumn = DOM.createTD();
    nameColumn.addClassName("svnSearcher-nameColumn");
    nameColumn.getStyle().setProperty("padding", "10px");
    DOM.appendChild(tableRow, nameColumn);
    String snippet = (String) record.get(SNIPPET);    
    if(!JepRiaUtil.isEmpty(snippet))
      add(new HTML(SafeHtmlUtils.fromTrustedString(snippet)), nameColumn);
    
    add(new Anchor((String) record.get(SVN_PATH), (String) record.get(URL), "_blank"), nameColumn);
    add(new Label( svnSearcherText.svnSearcher_list_repository_name()+": "+(String) record.get(REPOSITORY_NAME)), nameColumn);
    add(new Label( 
        svnSearcherText.svnSearcher_list_svn_last_modification()
        + ": "
        + dateWithTime((Date) record.get(SVN_LAST_MODIFICATION)))
          , nameColumn);
    add(new Label( svnSearcherText.svnSearcher_list_revision()+": "+(String) record.get(REVISION)), nameColumn);
    add(new Label( svnSearcherText.svnSearcher_list_author()+": "+(String) record.get(AUTHOR)), nameColumn);
    add(new Label( svnSearcherText.svnSearcher_list_file_size()+": "+(String) record.get(FILE_SIZE)), nameColumn);
    add(new Label( 
        svnSearcherText.svnSearcher_list_last_check_date()
        + ": "
        + dateWithTime((Date) record.get(LAST_CHECK_DATE)))
          , nameColumn);
    add(new Label( 
        svnSearcherText.svnSearcher_list_last_all_index_date()
        + ": "
        + dateWithTime((Date) record.get(LAST_ALL_INDEX_DATE)))
          , nameColumn);
  }
  
  private static String dateWithTime(Date date){
    
    if(date == null){
      return "";
    }
    
    return defaultDateTimeFormatter.format(date);
  }
  
  private static DateTimeFormat defaultDateFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT);
  private static DateTimeFormat defaultDateTimeFormatter = DateTimeFormat.getFormat(DEFAULT_DATE_FORMAT+" "+DEFAULT_TIME_FORMAT);
  private static NumberFormat defaultNumberFormatter = NumberFormat.getFormat("#");

}
