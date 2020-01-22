package com.technology.exchange.svnsearcher.svnsearcher.server.dao;

import static com.technology.exchange.svnsearcher.svnsearcher.shared.field.SvnSearcherFieldNames.*;

import com.technology.exchange.svnsearcher.svnsearcher.shared.field.OrderColumnNameOptions;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.technology.exchange.svnsearcher.svnsearcher.shared.field.FileNameListOptions;
import com.technology.exchange.svnsearcher.svnsearcher.shared.field.RepositoryOptions;
import com.technology.jep.jepria.server.dao.JepDao;
import com.technology.jep.jepria.server.dao.ResultSetMapper;
import com.technology.jep.jepria.shared.exceptions.ApplicationException;
import com.technology.jep.jepria.shared.field.option.JepOption;
import com.technology.jep.jepria.shared.record.JepRecord;
import com.technology.jep.jepria.shared.util.Mutable;


public class SvnSearcherDao extends JepDao implements SvnSearcher {

  public List<JepRecord> find( JepRecord templateRecord, Mutable<Boolean> autoRefreshFlag, Integer maxRowCount, Integer operatorId) throws ApplicationException {
    String sqlQuery =
      "begin  "
        +  "? := pkg_svnsearcher.findString("
            + "repositoryNameList => ? "
            + ", searchString => ? "
            + ", pageRowCount => ? "
            + ", pageNumber => ? "
            + ", internalResultLimit => ? "
            + ", svnLogin => ? "
            + ", svnPassword => ? "
            + ", fileNameList => ? "
            + ", svnPathList => ? "
            + ", skipSvnPathList => ? "
            + ", lastModificationFrom => ? "
            + ", lastModificationTo => ? "
            + ", revisionFrom => ? "
            + ", revisionTo => ? "
            + ", author => ? "
            + ", fileSizeFrom => ? "
            + ", fileSizeTo => ? "
            + ", orderColumnName => ?"
          + ", operatorId => ? "
        + ");"
     + " end;";
    return super.find( sqlQuery,
        new ResultSetMapper<JepRecord>() {
          public void map(ResultSet rs, JepRecord record) throws SQLException {
            record.set(FILE_ID, getInteger(rs, FILE_ID));
            record.set(REPOSITORY_NAME, rs.getString(REPOSITORY_NAME));
            record.set(SVN_PATH, rs.getString(SVN_PATH));
            record.set(URL, rs.getString(URL));
            record.set(FILE_EXTENTION, rs.getString(FILE_EXTENTION));
            record.set(SVN_LAST_MODIFICATION, getTimestamp(rs, SVN_LAST_MODIFICATION));
            record.set(REVISION, rs.getString(REVISION));
            record.set(FILE_SIZE, rs.getString(FILE_SIZE));
            record.set(LAST_CHECK_DATE, getTimestamp(rs, LAST_CHECK_DATE));
            record.set(LAST_ALL_INDEX_DATE, getTimestamp(rs, LAST_ALL_INDEX_DATE));
            record.set(RESULT_COUNT, getInteger(rs, RESULT_COUNT));
            record.set(RESULT_ROW_NUMBER, getInteger(rs, RESULT_ROW_NUMBER));
            record.set(SNIPPET, rs.getString(SNIPPET));
            record.set(AUTHOR, rs.getString(AUTHOR));
          }
        }
        , JepOption.getOptionValuesAsString((List<JepOption>) templateRecord.get(REPOSITORY_NAME), ",")
        , templateRecord.get(SEARCH_STRING)
        , maxRowCount
        , 1
        , templateRecord.get(INTERNAL_RESULT_LIMIT)
        , templateRecord.get(SVN_LOGIN)
        , templateRecord.get(SVN_PASSWORD)
        , JepOption.getOptionValuesAsString((List<JepOption>) templateRecord.get(FILE_NAME_LIST), ",")
        , templateRecord.get(SVN_PATH_LIST)
        , templateRecord.get(SKIP_SVN_PATH_LIST)
        , templateRecord.get(LAST_MODIFICATION_FROM)
        , templateRecord.get(LAST_MODIFICATION_TO)
        , templateRecord.get(REVISION_FROM)
        , templateRecord.get(REVISION_TO)
        , templateRecord.get(AUTHOR)
        , templateRecord.get(FILE_SIZE_FROM)
        , templateRecord.get(FILE_SIZE_TO)
        , JepOption.<String>getValue(templateRecord.get(ORDER_COLUMN_NAME))
        , operatorId);
  }
  public void delete(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public void update(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }

  public Integer create(JepRecord record, Integer operatorId) throws ApplicationException {
    throw new UnsupportedOperationException();
  }


  public List<JepOption> getFileNameList() throws ApplicationException {
    String sqlQuery =
      " begin "
      + " ? := pkg_svnsearcher.getFileNameMask;"
      + " end;";

    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(FileNameListOptions.FILE_NAME_MASK));
            dto.setName(rs.getString(FileNameListOptions.FILE_NAME_MASK));
          }
        }
    );
  }


  public List<JepOption> getRepository() throws ApplicationException {
    String sqlQuery =
      " begin "
        + " ? := pkg_svnsearcher.getRepository;"
    + " end;";

    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(RepositoryOptions.REPOSITORY_NAME));
            dto.setName(rs.getString(RepositoryOptions.REPOSITORY_NAME));
          }
        }
    );
  }

  public List<JepOption> getOrderColumnName() throws ApplicationException {
    String sqlQuery =
      " begin "
      + " ? := pkg_svnsearcher.getOrderColumnList;"
      + " end;";

    return super.getOptions(
        sqlQuery,
        new ResultSetMapper<JepOption>() {
          public void map(ResultSet rs, JepOption dto) throws SQLException {
            dto.setValue(rs.getString(OrderColumnNameOptions.ORDER_COLUMN_NAME));
            dto.setName(rs.getString(OrderColumnNameOptions.ORDER_COLUMN_NAME_NAME));
          }
        }
    );
  }
}
