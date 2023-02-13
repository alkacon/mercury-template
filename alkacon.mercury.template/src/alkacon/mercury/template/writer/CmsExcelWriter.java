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

import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.WorkbookUtil;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Class representing an Excel writer.
 */
public class CmsExcelWriter extends A_CmsWriter {

    /** The workbook. */
    private Workbook m_workbook = new XSSFWorkbook();

    /** The workbook sheet. */
    private Sheet m_sheet;

    /** Headline columns. */
    private List<CellRangeAddress> cellRangeAddressList = new ArrayList<>();

    /** Maximum number of columns. */
    private int m_numColumns = 0;

    /** Whether auto size column was called already. */
    boolean m_autoSizeColumn = false;

    /**
     * Creates a new Excel writer.
     * @param sheetName the sheet name
     */
    public CmsExcelWriter(String sheetName) {

        String sheetNameSafe = WorkbookUtil.createSafeSheetName(sheetName);
        m_sheet = m_workbook.createSheet(sheetNameSafe);
    }

    /**
     * @see alkacon.mercury.template.writer.A_CmsWriter#addRow(java.lang.String[])
     */
    @Override
    public void addRow(String... values) {

        Row row = m_sheet.createRow(m_sheet.getLastRowNum() + 1);
        for (int i = 0; i < values.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(values[i]);
        }
        if (values.length > m_numColumns) {
            m_numColumns = values.length;
        }
        m_autoSizeColumn = false;
    }

    /**
     * @see alkacon.mercury.template.writer.A_CmsWriter#addRowHeadline(java.lang.String)
     */
    @Override
    public void addRowHeadline(String headline) {

        Row row = m_sheet.createRow(m_sheet.getLastRowNum() + 1);
        CellRangeAddress cellRangeAddress = new CellRangeAddress(
            m_sheet.getLastRowNum(),
            m_sheet.getLastRowNum(),
            0,
            m_numColumns);
        cellRangeAddressList.add(cellRangeAddress);
        Cell cell = row.createCell(0);
        cell.setCellValue(headline);
        m_autoSizeColumn = false;
    }

    /**
     * Returns the workbook of this Excel writer.
     * @return the workbook
     */
    public Workbook getWorkbook() {

        if (!m_autoSizeColumn) {
            for (CellRangeAddress cellRangeAddress : cellRangeAddressList) {
                cellRangeAddress.setLastColumn(m_numColumns - 1);
                m_sheet.addMergedRegion(cellRangeAddress);
            }
            for (int i = 0; i < m_numColumns; i++) {
                m_sheet.autoSizeColumn(i);
            }
            m_autoSizeColumn = true;
        }
        return m_workbook;
    }
}
