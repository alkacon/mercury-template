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

import org.opencms.i18n.A_CmsMessageBundle;
import org.opencms.i18n.I_CmsMessageBundle;

/**
 * Convenience class to access the localized messages of this OpenCms package.<p>
 */
public final class LogMessages extends A_CmsMessageBundle {

    /** Message constant for key in the resource bundle. */
    public static final String ERR_INIT_INPUT_FIELD_MISSING_ITEM_2 = "ERR_INIT_INPUT_FIELD_MISSING_ITEM_2";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_REPORT_NO_FORM_URI_0 = "ERR_REPORT_NO_FORM_URI_0";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_WRONG_FORM_CONFIG_FORMAT_1 = "ERR_WRONG_FORM_CONFIG_FORMAT_1";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_READING_FORM_CONFIG_FAILED_0 = "ERR_READING_FORM_CONFIG_FAILED_0";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_FORM_CONFIGURATION_CANNOT_BE_SAVED_0 = "ERR_FORM_CONFIGURATION_CANNOT_BE_SAVED_0";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_VALIDATION_GROUP_INVALID_1 = "ERR_VALIDATION_GROUP_INVALID_1";

    /** Message constant for key in the resource bundle. */
    public static final String ERR_READING_UGC_CONFIG_FAILED_0 = "ERR_READING_UGC_CONFIG_FAILED_0";

    /** Name of the used resource bundle. */
    private static final String BUNDLE_NAME = "alkacon.mercury.webform.log_messages";

    /** Static instance member. */
    private static final I_CmsMessageBundle INSTANCE = new LogMessages();

    public static final String GUI_FORMDATA_HEADING_1 = "GUI_FORMDATA_HEADING_1";

    /**
    * Hides the public constructor for this utility class.<p>
    */
    private LogMessages() {

        // hide the constructor
    }

    /**
     * Returns an instance of this localized message accessor.<p>
     *
     * @return an instance of this localized message accessor
     */
    public static I_CmsMessageBundle get() {

        return INSTANCE;
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