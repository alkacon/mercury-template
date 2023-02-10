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

package alkacon.mercury.webform.mail;

/**
 * iCalendar information.
 */
public class CmsFormMailICalInfo {

    /** The iCalendar link. */
    private final String m_link;

    /** The file name of the downloaded ICS file. */
    private final String m_fileName;

    /** The label to be shown on the download button. */
    private final String m_label;

    /**
     * Creates a new iCalendar info.
     * @param link the link
     * @param fileName the file name
     * @param label the label
     */
    public CmsFormMailICalInfo(String link, String fileName, String label) {

        m_link = link;
        m_fileName = fileName;
        m_label = label;
    }

    /**
     * Returns the file name of the downloaded ICS file.
     * @return the file name of the downloaded ICS file
     */
    public String getFileName() {

        return m_fileName;
    }

    /**
     * Returns the label to be shown on the download button.
     * @return the label to be shown on the download button
     */
    public String getLabel() {

        return m_label;
    }

    /**
     * Returns the iCalendar link.
     * @return the iCalendar link
     */
    public String getLink() {

        return m_link;
    }
}
