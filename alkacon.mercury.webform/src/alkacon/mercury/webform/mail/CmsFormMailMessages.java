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

import org.opencms.i18n.A_CmsMessageBundle;
import org.opencms.i18n.I_CmsMessageBundle;

/**
 * Form mail messages.
 */
public final class CmsFormMailMessages extends A_CmsMessageBundle {

    /** Static instance member. */
    private static final I_CmsMessageBundle INSTANCE = new CmsFormMailMessages();

    /** Name of the used resource bundle. */
    private static final String BUNDLE_NAME = "alkacon.mercury.webform.mail.messages";

    /** Message constant for key in the resource bundle. */
    public static final String MAIL_PREFIX_CANCELLED = "MAIL_PREFIX_CANCELLED";

    /** Message constant for key in the resource bundle. */
    public static final String MAIL_PREFIX_MOVEDUP = "MAIL_PREFIX_MOVEDUP";

    /** Message constant for key in the resource bundle. */
    public static final String MAIL_SUBJECT_REMINDER_USER = "MAIL_SUBJECT_REMINDER_USER";

    /** Message constant for key in the resource bundle. */
    public static final String MAIL_TEXT_REMINDER_USER = "MAIL_TEXT_REMINDER_USER";

    /** Message constant for key in the resource bundle. */
    public static final String INFO_CANCELLED_ADMIN = "INFO_CANCELLED_ADMIN";

    /** Message constant for key in the resource bundle. */
    public static final String INFO_MOVEDUP_ADMIN = "INFO_MOVEDUP_ADMIN";

    /** Message constant for key in the resource bundle. */
    public static final String INFO_CANCELLED_USER = "INFO_CANCELLED_USER";

    /** Message constant for key in the resource bundle. */
    public static final String INFO_MOVEDUP_USER = "INFO_MOVEDUP_USER";

    /**
     * Hidden constructor.
     */
    private CmsFormMailMessages() {

        // hide the constructor
    }

    /**
     * Returns an instance of this localized message accessor.
     * @return an instance of this localized message accessor
     */
    public static I_CmsMessageBundle get() {

        return INSTANCE;
    }

    /**
     * @see org.opencms.i18n.I_CmsMessageBundle#getBundleName()
     */
    @Override
    public String getBundleName() {

        return BUNDLE_NAME;
    }
}
