/*
 * This library is part of OpenCms -
 * the Open Source Content Management System
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * For further information about Alkacon Software, please see the
 * company website: http://www.alkacon.com
 *
 * For further information about OpenCms, please see the
 * project website: http://www.opencms.org
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

package alkacon.mercury.template.writer;

import org.opencms.main.CmsLog;

import java.util.Map;

import org.apache.commons.logging.Log;

import org.bouncycastle.util.Arrays;

/**
 * Class representing a writer for tabular data such as CSV or Excel.
 */
public abstract class A_CmsWriter {

    /** Logger instance for this class. */
    private static final Log LOG = CmsLog.getLog(A_CmsWriter.class);

    /** Column names of the current table. */
    private Map<String, Integer> m_columnNames;

    /**
     * Adds String values to a table row.
     * @param values the values to add
     */
    abstract public void addRow(String... values);

    /**
     * Adds a headline row to a table.
     * @param headline the headline to add
     */
    abstract public void addRowHeadline(String headline);

    /**
     * Starts a new table for given column names.
     * @param columnNames the columnNames
     */
    public void addTable(Map<String, Integer> columnNames) {

        m_columnNames = columnNames;
        addRow(columnNames.keySet().toArray(new String[0]));
    }

    /**
     * Inserts data into a table row respecting columns.
     * @param tableData the table data
     */
    public void addTableRow(Map<String, String> tableData) {

        if (m_columnNames == null) {
            LOG.warn("Trying to insert data into table columns but no columns are defined.");
            return;
        }
        String[] row = new String[m_columnNames.size()];
        Arrays.fill(row, "");
        for (Map.Entry<String, String> entry : tableData.entrySet()) {
            Integer position = m_columnNames.get(entry.getKey());
            if ((position != null) && (position.intValue() >= 0) && (position.intValue() < (row.length))) {
                row[position.intValue()] = entry.getValue();
            } else {
                LOG.warn("Trying to insert data into table column <" + entry.getKey() + "> which is not defined.");
                return;
            }
        }
        addRow(row);
    }
}
