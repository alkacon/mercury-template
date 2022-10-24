/*
 * File   : $Source: /home/cvs/LgtModulesNew/com.alkacon.opencms.newsletter/src/com/alkacon/opencms/newsletter/Messages.java,v $
 * Date   : $Date: 2011-06-06 07:22:28 $
 * Version: $Revision: 1.1 $
 *
 * This file is part of the Alkacon OpenCms Add-On Module Package
 *
 * Copyright (c) 2007 Alkacon Software GmbH (http://www.alkacon.com)
 *
 * The Alkacon OpenCms Add-On Module Package is free software:
 * you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Alkacon OpenCms Add-On Module Package is distributed
 * in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Alkacon OpenCms Add-On Module Package.
 * If not, see http://www.gnu.org/licenses/.
 *
 * For further information about Alkacon Software GmbH, please see the
 * company website: http://www.alkacon.com.
 *
 * For further information about OpenCms, please see the
 * project website: http://www.opencms.org.
 */

package alkacon.mercury.template.content;

import org.opencms.i18n.A_CmsMessageBundle;
import org.opencms.i18n.I_CmsMessageBundle;

/**
 * Convenience class to access the localized messages of this OpenCms package.<p>
 */
public final class Messages extends A_CmsMessageBundle {

    /** Name of the used resource bundle. */
    private static final String BUNDLE_NAME = "alkacon.mercury.template.messages";

    /** Static instance member. */
    private static final I_CmsMessageBundle INSTANCE = new Messages();

    /** Message key. */
    public static final String GUI_ORGANIZATION_SELECT_PLEASE_SELECT_0 = "GUI_ORGANIZATION_SELECT_PLEASE_SELECT_0";

    /** Message key. */
    public static final String GUI_ORGANIZATION_SELECT_TYPE_STAFF_0 = "GUI_ORGANIZATION_SELECT_TYPE_STAFF_0";

    /** Message key. */
    public static final String GUI_ORGANIZATION_SELECT_TYPE_STANDARD_0 = "GUI_ORGANIZATION_SELECT_TYPE_STANDARD_0";

    /**
     * Returns an instance of this localized message accessor.<p>
     *
     * @return an instance of this localized message accessor
     */
    public static I_CmsMessageBundle get() {

        return INSTANCE;
    }

    /**
     * Hides the public constructor for this utility class.<p>
     */
    private Messages() {

        // hide the constructor
    }

    /**
     * Returns the bundle name for this OpenCms package.<p>
     *
     * @return the bundle name for this OpenCms package
     */
    @Override
    public String getBundleName() {

        return BUNDLE_NAME;
    }

}
