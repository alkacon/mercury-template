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

import alkacon.mercury.template.mail.I_CmsPreconfiguredMail;
import alkacon.mercury.template.subscriptionmanagement.CmsSubscriptionParameterHandler.SubscriptionAction;

import org.opencms.file.CmsObject;
import org.opencms.i18n.CmsMessageContainer;
import org.opencms.main.CmsLog;

import java.util.Collections;
import java.util.List;

import org.apache.commons.logging.Log;

/**
 * Action that sends a suitable confirmation mail for unsubscription to the user.
 * The unsubscription will not be active until the user confirms it.
 */
public class CmsSubscriptionActionUnsubscribe implements I_CmsSubscriptionAction {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsSubscriptionActionUnsubscribe.class);

    /** The current context. */
    private final CmsObject m_cms;

    /** The subscription configuration. */
    private final I_CmsSubscriptionConfiguration m_config;

    /**
     * Creates a new unsubscription action.
     *
     * @param cms the current context
     * @param config the subscription configuration
     */
    public CmsSubscriptionActionUnsubscribe(CmsObject cms, I_CmsSubscriptionConfiguration config) {

        m_cms = cms;
        m_config = config;
    }

    /**
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#getName()
     */
    @Override
    public String getName() {

        return SubscriptionAction.UNSUBSCRIBE.toString();
    }

    /**
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#getParamValue()
     */
    @Override
    public String getParamValue() {

        return String.valueOf(SubscriptionAction.UNSUBSCRIBE.ordinal());
    }

    /**
     * Sends a suitable confirmation mail for unsubscription to the user.
     *
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#perform(alkacon.mercury.template.subscriptionmanagement.CmsSubscriptionParameterHandler)
     */
    @Override
    public List<CmsMessageContainer> perform(CmsSubscriptionParameterHandler paramHandler) {

        try {
            I_CmsPreconfiguredMail mail = m_config.getMail(
                m_cms,
                SubscriptionAction.UNSUBSCRIBE,
                paramHandler.getRequestedGroups(),
                paramHandler.getEmail(),
                paramHandler.getConfirmationLinkParameters());
            mail.sendTo(paramHandler.getEmail(), null);
        } catch (Exception e) {
            if (LOG.isErrorEnabled()) {
                LOG.error(
                    "Failed to send unsubscription confirmation for groups \""
                        + paramHandler.getRequestedGroups()
                        + "\" to user \""
                        + paramHandler.getEmail()
                        + "\".",
                    e);
            }
            return Collections.singletonList(
                new CmsMessageContainer(
                    Messages.get(),
                    Messages.GUI_FAILED_SENDING_CONFIRM_UNSUBSCRIPTION_MAIL_2,
                    paramHandler.getEmail(),
                    paramHandler.getRequestedGroups()));
        }
        return Collections.emptyList();
    }

}
