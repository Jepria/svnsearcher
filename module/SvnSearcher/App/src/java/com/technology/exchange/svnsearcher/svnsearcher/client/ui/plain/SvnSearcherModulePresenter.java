package com.technology.exchange.svnsearcher.svnsearcher.client.ui.plain;

import static com.technology.exchange.svnsearcher.svnsearcher.client.SvnSearcherClientConstant.svnSearcherText;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.FILE_NAME_LIST;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.REPOSITORY_NAME;
import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.*;
import static com.technology.jep.jepria.client.JepRiaClientConstant.JepTexts;
import static com.technology.jep.jepria.client.widget.event.JepEventType.PAGING_GOTO_EVENT;
import static com.technology.jep.jepria.client.widget.event.JepEventType.PAGING_REFRESH_EVENT;
import static com.technology.jep.jepria.client.widget.event.JepEventType.PAGING_SIZE_EVENT;
import static com.technology.jep.jepria.shared.JepRiaConstant.JEP_USER_NAME_FIELD_NAME;
import static com.technology.jep.jepria.shared.JepRiaConstant.JEP_USER_ROLES_FIELD_NAME;
import static com.technology.jep.jepria.shared.field.JepFieldNames.MAX_ROW_COUNT;
import static com.technology.jep.jepria.shared.field.JepFieldNames.OPERATOR_ID;

import java.util.List;

import com.allen_sauer.gwt.log.client.Log;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.shared.EventBus;
import com.google.gwt.place.shared.Place;
import com.google.gwt.user.client.ui.AcceptsOneWidget;
import com.technology.exchange.svnsearcher.svnsearcher.shared.service.SvnSearcherServiceAsync;
import com.technology.jep.jepria.client.async.JepAsyncCallback;
import com.technology.jep.jepria.client.history.place.JepViewListPlace;
import com.technology.jep.jepria.client.history.scope.JepScopeStack;
import com.technology.jep.jepria.client.security.ClientSecurity;
import com.technology.jep.jepria.client.ui.eventbus.plain.PlainEventBus;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.PagingEvent;
import com.technology.jep.jepria.client.ui.eventbus.plain.event.RefreshEvent;
import com.technology.jep.jepria.client.ui.plain.PlainClientFactory;
import com.technology.jep.jepria.client.ui.plain.PlainModulePresenter;
import com.technology.jep.jepria.client.widget.event.JepEvent;
import com.technology.jep.jepria.client.widget.event.JepListener;
import com.technology.jep.jepria.client.widget.field.FieldManager;
import com.technology.jep.jepria.client.widget.list.ListManager;
import com.technology.jep.jepria.shared.dto.JepDto;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.load.PagingConfig;
import com.technology.jep.jepria.shared.load.PagingResult;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.service.JepMainServiceAsync;

public class SvnSearcherModulePresenter<V extends SvnSearcherModuleView, E extends PlainEventBus, S extends SvnSearcherServiceAsync,
    F extends PlainClientFactory<E, S>>
  extends PlainModulePresenter<V, E, S, F>
  implements
  PagingEvent.Handler,
  RefreshEvent.Handler {

  private JepMainServiceAsync mainService = clientFactory.getMainClientFactory().getMainService();

  protected JepRecord searchFormFields;
  protected PagingConfig searchTemplate = null;
  protected ListManager list;
  protected S service;
  protected FieldManager fields;

  public SvnSearcherModulePresenter(String moduleId, Place place, F clientFactory) {
    super(moduleId, place, clientFactory);

    service = clientFactory.getService();
    list = view.getListManager();
    fields = view.getFieldManager();
  };

  public void start(AcceptsOneWidget container, EventBus eventBus) {
    //Подписка activity-презентера на события EventBus.
    eventBus.addHandler(PagingEvent.TYPE, this);
    eventBus.addHandler(RefreshEvent.TYPE, this);

    super.start(container, eventBus);
    loadUserDataAndEnterScope();
  }

  protected void loadUserDataAndEnterScope() {
    mainService.getUserData(new JepAsyncCallback<JepDto>() {
      public void onFailure(Throwable caught) {
        Log.error(caught.getLocalizedMessage(), caught);
        clientFactory.getExceptionManager().handleException(caught);
      }

      public void onSuccess(JepDto userData) {
        Log.trace("MainModulePresenter.getUserData().onSuccess(): userData = " + userData);
        ClientSecurity.instance.setOperatorId((Integer)userData.get(OPERATOR_ID));
        ClientSecurity.instance.setRoles((List<String>) userData.get(JEP_USER_ROLES_FIELD_NAME));
        enterScope((String)userData.get(JEP_USER_NAME_FIELD_NAME));
      }
    });
  }

  protected void enterScope(String username) {
    ClientSecurity.instance.setUsername(username);
    view.setUsername(username);
    JepScopeStack.instance.setUserEntered();
  }

  public void doSearch() {

    String searchText = view.getSearchText();

    if (searchText != null && searchText.length() > 0) {

      view.clearStatusPanel();
      searchFormFields = fields.getValues();
      searchFormFields.set(SEARCH_STRING, searchText);

      searchTemplate = new PagingConfig(searchFormFields);
      searchTemplate.setListUID(list.getUID());
      searchTemplate.setPageSize(list.getPageSize());

      eventBus.refresh();
    } else {
      messageBox.showError(svnSearcherText.search_noSearchString());
    }
  }

  protected void bind() {
    super.bind();

    JepListener searchListener = event -> doSearch();

    view.addEnterClickListener(searchListener);
    view.addSearchButtonClickListener(searchListener);

    list.addListener(PAGING_REFRESH_EVENT, event -> pagingRefresh(event));

    list.addListener(PAGING_SIZE_EVENT, event -> pagingSize(event));

    list.addListener(PAGING_GOTO_EVENT, event -> pagingGoto(event));

    service.getFileNameList(new JepAsyncCallback<List<JepOption>>() {
      public void onSuccess(List<JepOption> result){
        fields.setFieldOptions(FILE_NAME_LIST, result);
      }
    });

    service.getRepository(new JepAsyncCallback<List<JepOption>>() {
      public void onSuccess(List<JepOption> result){
        fields.setFieldOptions(REPOSITORY_NAME, result);
      }
    });

    service.getOrderColumnName(new JepAsyncCallback<List<JepOption>>() {
      @Override
      public void onSuccess(List<JepOption> result){
        fields.setFieldOptions(ORDER_COLUMN_NAME, result);
      }
    });

    fields.setFieldValue(MAX_ROW_COUNT, 100);
  }

  /**
   * Установка главного виджета(-контейнера) приложения.<br/>
   * В методе используется вызов вида : <code>mainEventBus.setMainView(clientFactory.getMainClientFactory().getMainView());</code> <br/>
   * При этом, при передаче <code>null</code> в качестве главного виджета приложения, текущий главный виджет удаляется с RootPanel'и.<br/>
   * Т.о., перегрузкой данного метода можно установить, при заходе на модуль приложения, любой главный виджет приложения или скрыть текущий.
   */
  protected void setMainView() {
    Log.trace(this.getClass() + ".setMainView()");

    mainEventBus.setMainView(null);
  }

  /**
   * Обработчик события обновления списка.
   *
   * @param event событие обновления списка
   */
  public void onRefresh(RefreshEvent event) {
    // Если существует сохраненный шаблон, по которому нужно обновлять список, то ...
    if(searchTemplate != null) {
      list.clear(); // Очистим список от предыдущего содержимого (чтобы не вводить в заблуждение пользователя).
      list.mask(JepTexts.loadingPanel_dataLoading()); // Выставим индикатор "Загрузка данных...".
      searchTemplate.setListUID(list.getUID()); // Выставим идентификатор получаемого списка данных.
      searchTemplate.setPageSize(list.getPageSize()); // Выставим размер получаемой страницы набора данных.
      service.find(searchTemplate, new JepAsyncCallback<PagingResult<JepRecord>>() {
        public void onSuccess(PagingResult<JepRecord> pagingResult) {

          view.getPagingBar().setVisible(true);
          view.updateSearchStatus(pagingResult);
          list.set(pagingResult); // Установим в список полученные от сервиса данные.
          list.unmask(); // Скроем индикатор "Загрузка данных...".
        }

        public void onFailure(Throwable caught) {
          list.unmask(); // Скроем индикатор "Загрузка данных...".
          super.onFailure(caught);
        }

      });
    }
  }

  /**
   * Обработчик события листания набора данных.
   *
   * @param event событие листания набора данных
   */
  public void onPaging(PagingEvent event) {
    // Если поиск уже осуществлялся, то ...
    if(searchTemplate != null) {
      list.mask(JepTexts.loadingPanel_dataLoading()); // Выставим индикатор "Загрузка данных...".
      PagingConfig pagingConfig = event.getPagingConfig();
      pagingConfig.setListUID(list.getUID()); // Выставим идентификатор листаемого списка данных.
      pagingConfig.setTemplateRecord(searchFormFields); // Выставим параметры поиска на случай отсутствия списка в серверной сессии.
      clientFactory.getService().paging(pagingConfig, new JepAsyncCallback<PagingResult<JepRecord>>() {
        public void onSuccess(PagingResult<JepRecord> pagingResult) {

          list.set(pagingResult); // Установим в список полученные от сервиса данные.
          list.unmask(); // Скроем индикатор "Загрузка данных...".
        }

        public void onFailure(Throwable caught) {
          list.unmask(); // Скроем индикатор "Загрузка данных...".
          super.onFailure(caught);
        }

      });
    }
  }

  public void pagingRefresh(JepEvent event) {
    eventBus.refresh();
    // Важно при обновлении списка менять рабочее состояние на VIEW_LIST, чтобы скинуть состояние SELECTED (тем самым, скрыть кнопки работы с
    // конкретной, ранее выбранной, записью).
    // Вызов перехода на новый Place происходит ОБЯЗАТЕЛЬНО ПОСЛЕ подготовки данных для записи в History
    // (изменения Scope в обработчиках шины событий).
    placeController.goTo(new JepViewListPlace());
  }

  public void pagingSize(JepEvent event) {
    PagingConfig pagingConfig = (PagingConfig)event.getParameter();
    eventBus.paging(pagingConfig);
  }

  public void pagingGoto(JepEvent event) {
    PagingConfig pagingConfig = (PagingConfig)event.getParameter();
    eventBus.paging(pagingConfig);
  }
}
