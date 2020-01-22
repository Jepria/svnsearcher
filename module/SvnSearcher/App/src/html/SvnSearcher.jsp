<!DOCTYPE html>
 
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.technology.jep.jepria.client.JepRiaClientConstant" %>
<%@ page import="static com.technology.jep.jepria.server.util.JepServerUtil.getLocale"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.technology.exchange.svnsearcher.svnsearcher.shared.SvnSearcherConstant" %>
 
 <% ResourceBundle jepRiaText = ResourceBundle.getBundle("com.technology.jep.jepria.shared.text.JepRiaText", getLocale(request)); %>
 <% ResourceBundle svnSearcherText = ResourceBundle.getBundle("com.technology.exchange.svnsearcher.svnsearcher.shared.text.SvnSearcherText", getLocale(request)); %>
 
<html style="width: 100%; height: 100%;">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    
    <title>SvnSearcher Module</title>
    <script type="text/javascript" language="javascript" src="SvnSearcher/SvnSearcher.nocache.js"></script>
  </head>
 
  <body style="margin: 0px; padding: 0px; width: 100%; height: 100%;">
    <table style="border: 0px; table-layout: fixed; border-collapse: collapse; margin: 0px; padding: 0px; width: 100%; height: 100%;">
      <tr>
        <td style="width: 100%; height: 100%;">
 
          <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position: absolute; width: 0; height: 0; border: 0;"></iframe>
          
          <noscript>
            <div class="jepRia-noJavaScriptEnabledMessage"><%= jepRiaText.getString("noJavaScriptEnabledMessage") %></div>
          </noscript>

          <div id="testBuildMessage" class="<%= JepRiaClientConstant.TEST_BUILD_MESSAGE_CLASS %>">
            <div class="jepRia-testBuildMessageNotification error"> 
              <div class="jepRia-testBuildMessageClose" onclick="document.getElementById('testBuildMessage').style.display = 'none';">
                X
              </div> 
              <div class="jepRia-testBuildMessageHeader">
                Attention please!
              </div> 
              <div class="jepRia-testBuildMessageInfo">
                This is test build!
              </div> 
            </div> 
          </div>
          
          <div id="loadingProgress" class="jepRia-loadingProgress">
            <div class="jepRia-loadingIndicator">
              <img src="images/loading.gif" width="32" height="32" alt="Loading..."/>
                <div>
                  <p>
                    <span id="loadingHeader">SvnSearcher</span>
                  </p>
                <span id="loadingMessage" class="jepRia-loadingMessage"><%= jepRiaText.getString("loadingMessage") %></span>
              </div>
            </div>
          </div> 

          <table style="border: 0px; table-layout: fixed; border-collapse: collapse; margin: 0 5%; padding: 0px; width: 90%; height: 100%;">
            <tr>
              <td style="text-align: center; height: 50px; vertical-align:middle;">
                <table style="border: 0px; table-layout: fixed; border-collapse: collapse; margin: 0px; padding: 0px; width: 100%; height: 100%;">
                  <colgroup>
                    <col style="width: 90%; ">
                    <col style="width: 10%; ">
                  </colgroup>
                  <tr>
                    <td class="svnSearcher-header">
                      <h1 class="svnSearcher-title"><%= svnSearcherText.getString("svnSearcher.title") %></h1>
                      <p class="svnSearcher-text"><%= svnSearcherText.getString("svnSearcher.text.html") %></p>
                    </td>
                    <td><div id="<%= SvnSearcherConstant.AUTHORIZATION_ELEMENT %>" style="border: 0px; position: relative; width: 100%; "></div></td>
                   </tr>
                </table>
              </td>
            </tr>
            <tr>
              <td  style="text-align: center; vertical-align:middle;">
                <div id="<%= SvnSearcherConstant.SEARCH_PANEL %>" style="border: 0px; position: relative; width: 100%; "></div>
              </td>
            </tr>
            <tr style="height: 80%;">
              <td style="vertical-align: top;  text-align: left; height: 100%;">
                <table style="border: 0px; table-layout: fixed; border-collapse: collapse; margin: 0px; padding: 0px; width: 100%; height: 100%;">
                  <colgroup>
                    <col style="width: 80%; ">
                    <col style="width: 20%; ">
                  </colgroup>
                  <tr>
                    <td style="padding-right: 10px;">
                      <div id="<%= SvnSearcherConstant.SEARCH_RESULTS %>" style="border: 0px; position: relative; width: 100%; height: 100%;"></div>
                    </td>
                    <td><div id="<%= SvnSearcherConstant.SEARCH_PARAMS %>" style="border: 0px; position: relative; width: 100%; height: 100%;"></div></td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
    
    <link type="text/css" rel="stylesheet" href="css/JepRia.css">
    <link type="text/css" rel="stylesheet" href="css/SvnSearcher.css">
  </body>
</html>
