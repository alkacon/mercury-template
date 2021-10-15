/*
 * This program is part of the OpenCms Mercury Template.
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package alkacon.mercury.webform;

import alkacon.mercury.template.writer.A_CmsWriter;
import alkacon.mercury.template.writer.CmsCsvWriter;

/**
 * Helper class to export form data as CSV files that can be opened with Excel and
 * LibreOffice correctly. Unfortunately, encoding for CSV is difficult, but it seems that
 * Excel (at least the German version from 2013 and 365) opens CSV files correctly if:
 * <ul>
 *   <li>separator is not the number separator (ie. ";" instead of ",")</li>
 *   <li>files are UTF-8 encoded WITH BOM</li>
 *   <li>all values are escaped by double quotes</li>
 *   <li>line breaks are only "\n".</li>
 * </ul>
 */
public class CmsExportBeanCsv extends A_CmsExportBean {

    /**
     * @see alkacon.mercury.webform.A_CmsExportBean#export()
     */
    @Override
    public A_CmsWriter export() {

        return export(new CmsCsvWriter());
    }

}