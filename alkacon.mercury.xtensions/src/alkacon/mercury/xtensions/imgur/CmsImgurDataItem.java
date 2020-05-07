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

package alkacon.mercury.xtensions.imgur;

import org.opencms.widgets.dataview.I_CmsDataViewItem;

/**
 * Class for the imgur items.<p>
 */
public class CmsImgurDataItem implements I_CmsDataViewItem {

    /**image.*/
    String m_image;

    /**id.*/
    String m_id;

    /**description.*/
    String m_description;

    /**title.*/
    String m_title;

    /**album id.*/
    String m_albumID;

    /**is album.*/
    Boolean m_isAlbum;

    /**
     * public constructor.<p>
     *
     * @param id id
     * @param image image
     * @param description description
     * @param title title
     * @param isAlbum boolean
     * @param aID album id
     */
    public CmsImgurDataItem(String id, String image, String description, String title, Boolean isAlbum, String aID) {

        m_description = description;
        m_id = id;
        m_image = image;
        m_title = title;
        m_isAlbum = isAlbum;
        m_albumID = aID;

    }

    /**
     * Gets album id.<p>
     *
     * @return string
     */
    public String getAlbumID() {

        return m_albumID;
    }

    /**
     * gets column data.<p>
     *
     * @param colName name of column
     * @return object
     */
    public Object getColumnData(String colName) {

        switch (colName) {
            case "id":
                return getId();
            case "title":
                return getTitle();
            case "description":
                return getDescription();
            case "image":
                return m_image;
            default:
                return null;
        }
    }

    /**
     * Returns link.<p>
     *
     * @return String     *
     * */
    public String getData() {

        return "http://imgur.com/gallery/" + m_albumID;
    }

    /**
     * Returns description.<p>
     *
     * @return string
     */
    public String getDescription() {

        if (m_description.equals("") | m_description.equals("null")) {
            return m_title;
        } else {
            if (m_description.length() > 540) {
                return m_description.substring(0, 540) + "...";
            } else {
                return m_description;
            }
        }
    }

    /**
     * Returns id.<p>
     *
     * @return string
     */
    public String getId() {

        return m_id;
    }

    /**
     * Returns image.<p>
     *
     * @return string
     */
    public String getImage() {

        return m_image;
    }

    /**
     * Returns title.<p>
     *
     * @return string
     */
    public String getTitle() {

        return m_title;
    }

    /**
     * checks if item is alblum.<p>
     *
     * @return boolean
     */
    public Boolean isAlbum() {

        return m_isAlbum;
    }
}
