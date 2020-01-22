package com.technology.exchange.svnsearcher.svnsearcher.client.ui.plain;

import static com.technology.exchange.svnsearcher.svnsearcher.client.SvnSearcherClientConstant.svnSearcherText;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant.AUTHORIZATION_ELEMENT;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant.SEARCH_PANEL;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant.SEARCH_PARAMS;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant.SEARCH_RESULTS;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.AUTHOR;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.FILE_NAME_LIST;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.LAST_MODIFICATION_FROM;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.LAST_MODIFICATION_TO;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.REPOSITORY_NAME;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.RESULT_COUNT;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.REVISION_FROM;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.REVISION_TO;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.SKIP_SVN_PATH_LIST;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.SVN_LOGIN;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.SVN_PASSWORD;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.*;
import static com.technology.jep.jepria.client.ui.main.widget.MainTabPanel.createEntrancePanel;
import static com.technology.jep.jepria.client.ui.main.widget.MainTabPanel.createUserNameLabel;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.dom.client.Style.Unit;
import com.google.gwt.event.dom.client.KeyCodes;
import com.google.gwt.event.dom.client.KeyDownEvent;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.SimplePanel;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.technology.exchange.svnsearcher.svnsearcher.client.widget.list.ListItemViewImpl;
import com.technology.jep.jepria.client.entrance.Entrance;
import com.technology.jep.jepria.client.ui.plain.PlainModuleViewImpl;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.field.JepPasswordField;
import com.technology.jep.jepria.client.widget.field.multistate.JepComboBoxField;
import com.technology.jep.jepria.client.widget.field.multistate.JepDateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepIntegerField;
import com.technology.jep.jepria.client.widget.field.multistate.JepListField;
import com.technology.jep.jepria.client.widget.field.multistate.JepMultiStateField;
import com.technology.jep.jepria.client.widget.field.multistate.JepTextField;
import com.technology.jep.jepria.client.widget.list.JepDataWidgetList;
import com.technology.jep.jepria.client.widget.list.ListManager;
import com.technology.jep.jepria.client.widget.list.PagingManager;
import com.technology.jep.jepria.client.widget.toolbar.PagingStandardBar;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;

public class SvnSearcherModuleViewImpl extends PlainModuleViewImpl implements SvnSearcherModuleView {

  private Button searchButton;
  private TextBox searchField;
  private FieldManager fields = new FieldManager();
  private SimplePanel searchStatus;

  private PagingManager list = new PagingManager();
  private PagingStandardBar pagingBar = new PagingStandardBar(10);

  private Label userNameLabel = createUserNameLabel();

  private final static int BAR_HEIGHT = 22;
  private final static Unit BAR_UNIT = Unit.PX;

  public SvnSearcherModuleViewImpl() {

    // панель управления поиском
    RootPanel searchPanelElement = RootPanel.get(SEARCH_PANEL);
    if (searchPanelElement != null) {
      HorizontalPanel searchPanel = new HorizontalPanel();

      searchPanel.getElement().getStyle().setMarginTop(20, Unit.PX);
      searchPanel.getElement().getStyle().setMarginBottom(20, Unit.PX);
      searchPanel.getElement().getStyle().setWidth(100, Unit.PCT);

      searchButton = new Button(svnSearcherText.search_searchButton());
      searchButton.getElement().getStyle().setHeight(35, Unit.PX);
      searchButton.getElement().getStyle().setWidth(100, Unit.PCT);

      searchField = new TextBox();
      searchField.getElement().getStyle().setWidth(98, Unit.PCT);
      searchField.getElement().getStyle().setPaddingLeft(5, Unit.PX);
      searchField.getElement().getStyle().setHeight(30, Unit.PX);
      searchField.getElement().getStyle().setFontSize(18, Unit.PX);

      searchPanel.add(searchField);
      searchPanel.add(searchButton);
      searchPanel.setCellWidth(searchButton, "150px");
      searchPanelElement.add(searchPanel);
    }

    JepDataWidgetList dataList = new JepDataWidgetList() {
      @Override
      protected Widget getDataWidget(JepRecord data) {
        return new ListItemViewImpl(data);
      }
    };

    list.setWidget(dataList);
    list.setPagingToolBar(pagingBar);

    searchStatus = new SimplePanel();

    RootPanel resultElement = RootPanel.get(SEARCH_RESULTS);
    if (resultElement != null) {
      resultElement.add(searchStatus);
      resultElement.add(dataList);

      pagingBar.setVisible(false);
      resultElement.add(pagingBar);
    }

    //панель пользователя/log off
    RootPanel authorizationPanelElement = RootPanel.get(AUTHORIZATION_ELEMENT);
    if (authorizationPanelElement != null) {
      List<JepListener> exitListeners = new ArrayList<JepListener>();
      exitListeners.add(event -> Entrance.logout());
      HorizontalPanel entrancePanel = createEntrancePanel(userNameLabel, exitListeners);
      authorizationPanelElement.add(entrancePanel);
    }

    //панель параметров поиска
    RootPanel searchParamsPanel = RootPanel.get(SEARCH_PARAMS);
    if (searchParamsPanel != null) {

      JepTextField svnLoginTextField = new JepTextField(svnSearcherText.svnSearcher_detail_svn_login());
      JepPasswordField svnPasswordTextField = new JepPasswordField(svnSearcherText.svnSearcher_detail_svn_password());

      JepListField repositoryNameListField = new JepListField(svnSearcherText.svnSearcher_detail_repository_name());
      repositoryNameListField.setSelectAllCheckBoxVisible(true);
      JepListField fileNameListListField = new JepListField(svnSearcherText.svnSearcher_detail_file_name_list());
      fileNameListListField.setSelectAllCheckBoxVisible(true);
      JepTextField svnPathListTextField = new JepTextField(svnSearcherText.svnSearcher_detail_svn_path_list());
      JepTextField skipSvnPathListTextField = new JepTextField(svnSearcherText.svnSearcher_detail_skip_svn_path_list());
      JepDateField lastModificationFromDateField = new JepDateField(svnSearcherText.svnSearcher_detail_last_modification_from());
      JepDateField lastModificationToDateField = new JepDateField(svnSearcherText.svnSearcher_detail_last_modification_to());
      JepIntegerField revisionFromDateField = new JepIntegerField(svnSearcherText.svnSearcher_detail_revision_from());
      JepIntegerField revisionToDateField = new JepIntegerField(svnSearcherText.svnSearcher_detail_revision_to());
      JepTextField authorTextField = new JepTextField(svnSearcherText.svnSearcher_detail_author());
      JepComboBoxField orderColumnNameComboBoxField = new JepComboBoxField(svnSearcherText.svnSearcher_detail_order_column_name());

      JepIntegerField maxRowCountField = new JepIntegerField(svnSearcherText.svnSearcher_detail_row_count());
      maxRowCountField.setMaxLength(4);
      maxRowCountField.setFieldWidth(55);

      fields.put(SVN_LOGIN, svnLoginTextField);
      fields.put(SVN_PASSWORD, svnPasswordTextField);
      fields.put(REPOSITORY_NAME, repositoryNameListField);
      fields.put(FILE_NAME_LIST, fileNameListListField);
      fields.put(SVN_PATH_LIST, svnPathListTextField);
      fields.put(SKIP_SVN_PATH_LIST, skipSvnPathListTextField);
      fields.put(LAST_MODIFICATION_FROM, lastModificationFromDateField);
      fields.put(LAST_MODIFICATION_TO, lastModificationToDateField);
      fields.put(REVISION_FROM, revisionFromDateField);
      fields.put(REVISION_TO, revisionToDateField);
      fields.put(AUTHOR, authorTextField);
      fields.put(ORDER_COLUMN_NAME, orderColumnNameComboBoxField);
      fields.put(MAX_ROW_COUNT, maxRowCountField);

      searchParamsPanel.add(labelOnTop(maxRowCountField));
      searchParamsPanel.add(labelOnTop(svnLoginTextField));
      searchParamsPanel.add(labelOnTop(svnPasswordTextField));
      searchParamsPanel.add(labelOnTop(repositoryNameListField));
      searchParamsPanel.add(labelOnTop(fileNameListListField));
      searchParamsPanel.add(labelOnTop(svnPathListTextField));
      searchParamsPanel.add(labelOnTop(skipSvnPathListTextField));
      searchParamsPanel.add(labelOnTop(lastModificationFromDateField));
      searchParamsPanel.add(labelOnTop(lastModificationToDateField));
      searchParamsPanel.add(labelOnTop(revisionFromDateField));
      searchParamsPanel.add(labelOnTop(revisionToDateField));
      searchParamsPanel.add(labelOnTop(authorTextField));
      searchParamsPanel.add(labelOnTop(orderColumnNameComboBoxField));
    }
  }

  /**
   * Создает панель с наименованием поля и полем, при этом надпись над полем. <br/>
   * При этом создается второе наименование.
   * Оригинальное наименование недоступно никак public, поэтому скрыта через css.
   * @param field Поле
   * @return Панель
   */
  private static VerticalPanel labelOnTop(JepMultiStateField field){

    VerticalPanel vp = new VerticalPanel();
    vp.add(new Label(field.getFieldLabel()));
    vp.add(field);
    vp.getElement().getStyle().setMarginBottom(10, Unit.PX);

    return vp;
  }

  public FieldManager getFieldManager() {
    return fields;
  }

  public void clearStatusPanel() {
    searchStatus.clear();
  }

  public void setUsername(String username) {
    userNameLabel.setText(username);
  }

  public void addEnterClickListener(final JepListener listener) {

    for(JepMultiStateField field: fields.values()) {
      field.addDomHandler(event -> {
        if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) {
          listener.handleEvent(new JepEvent(event));
        }
      }, KeyDownEvent.getType());
    }

    searchField.addDomHandler(event -> {
      if (event.getNativeKeyCode() == KeyCodes.KEY_ENTER) {
        listener.handleEvent(new JepEvent(event));
      }
    }, KeyDownEvent.getType());
  }

  public void addSearchButtonClickListener(final JepListener listener) {
    searchButton.addClickHandler(event -> listener.handleEvent(new JepEvent(event)));
  }

  public String getSearchText() {
    return searchField.getText();
  }

  public ListManager getListManager() {
    return list;
  }

  @Override
  public PagingStandardBar getPagingBar() {
    return pagingBar;
  }

  @Override
  public void updateSearchStatus(PagingResult pagingResult) {
    List<JepRecord> data = pagingResult.getData();
    String status = "";

    if(data.size() > 0){

      Integer resultCount = (Integer) data.get(0).get(RESULT_COUNT);

      status = svnSearcherText.svnSearcher_list_result_count()
          + " " + (resultCount == null ? "" : resultCount.toString());
    }else{
      status = svnSearcherText.svnSearcher_list_no_result_count();
      pagingBar.setVisible(false);
    }

    clearStatusPanel();
    HTML statusHTML = new HTML(status);
    statusHTML.getElement().getStyle().setFontSize(18, Unit.PX);
    statusHTML.getElement().getStyle().setPaddingBottom(10, Unit.PX);
    searchStatus.add(statusHTML);
  }
}