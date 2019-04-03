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

package alkacon.mercury.template.subscriptionmanagement;

import org.opencms.i18n.A_CmsMessageBundle;
import org.opencms.i18n.I_CmsMessageBundle;

/**
 * Convenience class to access the localized messages of this OpenCms package.<p>
 *
 * @author Daniel Seidel
 *
 * @version $Revision: 1.0 $
 *
 * @since 11.0
 */
public final class Messages extends A_CmsMessageBundle {

    /** Name of the used resource bundle. */
    private static final String BUNDLE_NAME = "alkacon.mercury.template.subscriptionmanagement.messages";

    /** Static instance member. */
    private static final I_CmsMessageBundle INSTANCE = new Messages();

    /** Message key. */
    public static final String GUI_FAILED_SENDING_CONFIRM_SUBSCRIPTION_MAIL_2 = "GUI_FAILED_SENDING_CONFIRM_SUBSCRIPTION_MAIL_2";

    /** Message key. */
    public static final String GUI_FAILED_SUBSCRIPTION_ACTIVATION_FOR_2 = "GUI_FAILED_SUBSCRIPTION_ACTIVATION_FOR_2";

    /** Message key. */
    public static final String GUI_FAILED_UNSUBSCRIPTION_FOR_2 = "GUI_FAILED_UNSUBSCRIPTION_FOR_2";

    /** Message key. */
    public static final String GUI_FAILED_SENDING_CONFIRM_UNSUBSCRIPTION_MAIL_2 = "GUI_FAILED_SENDING_CONFIRM_UNSUBSCRIPTION_MAIL_2";

    /** Message key. */
    public static final String GUI_INVALID_PARAMETERS_0 = "GUI_INVALID_PARAMETERS_0";

    /**
    * Hides the public constructor for this utility class.<p>
    */
    private Messages() {

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
