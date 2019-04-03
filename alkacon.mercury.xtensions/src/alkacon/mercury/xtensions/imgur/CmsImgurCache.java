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

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Class for Imgur cache.<p>
 */
public class CmsImgurCache implements Serializable {

    /**serial id.*/
    private static final long serialVersionUID = 1L;

    /**Album images.*/
    public static Map<String, String> albumImages = new HashMap<>();

    /**Album descriptions. */
    public static Map<String, String> albumDescription = new HashMap<>();

    /**Cached items.*/
    public static Map<String, ArrayList<I_CmsDataViewItem>> itemLists = new HashMap<String, ArrayList<I_CmsDataViewItem>>();

    /**cache timestamp.*/
    public static Map<String, Long> itemListTime = new HashMap<>();
}
