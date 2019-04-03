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

package alkacon.mercury.template;

import org.opencms.i18n.A_CmsMessageBundle;
import org.opencms.i18n.I_CmsMessageBundle;

/**
 * Bundle with the keys of log messages<p>
 *
 * @author Daniel Seidel
 *
 * @version $Revision: 1.0 $
 *
 * @since 11.0.0
 */
public final class LogMessages extends A_CmsMessageBundle {

    /** Name of the used resource bundle. */
    private static final String BUNDLE_NAME = "alkacon.mercury.template.log.messages";

    /** Static instance member. */
    private static final I_CmsMessageBundle INSTANCE = new LogMessages();

    /** Message key. */
    public static final String LOG_ERROR_CREATE_KEY_0 = "LOG_ERROR_CREATE_KEY_0";

    /** Message key. */
    public static final String LOG_ERROR_DECRPYT_0 = "LOG_ERROR_DECRPYT_0";

    /** Message key. */
    public static final String LOG_ERROR_ENCRYPT_0 = "LOG_ERROR_ENCRYPT_0";

    /** Message key. */
    public static final String LOG_WARN_INVALID_DECRYPT_STRING_1 = "LOG_WARN_INVALID_DECRYPT_STRING_1";

    /** Message key. */
    public static final String LOG_WARN_INVALID_ENCRYPT_STRING_1 = "LOG_WARN_INVALID_ENCRYPT_STRING_1";

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
