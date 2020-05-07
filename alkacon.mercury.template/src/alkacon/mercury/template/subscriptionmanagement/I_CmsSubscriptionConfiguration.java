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

import java.util.List;

/** Interface for a subscription configuration.
 *
 * Subscription configurations provide the necessary information to perform subscription actions.
 *
 */
public interface I_CmsSubscriptionConfiguration {

    /**
     * Returs the subscription action instance for the provided subscription action.
     * @param action the action to perform.
     *
     * @return the object performing the action.
     */
    I_CmsSubscriptionAction getAction(SubscriptionAction action);

    /**
     * Returns the terms and conditions text that must be agreed on subscription.
     * @return the terms and conditions text that must be agreed on subscription.
     */
    String getAgreementNotice();

    /**
     * Returns the link to the page where the confirmation links should go to.
     * @param cms the current context.
     * @return the link to the page where the confirmation links should go to.
     */
    String getConfirmationPageLink(CmsObject cms);

    /**
     * Returns the mail content of the sent mail respective to the action.
     * @param cms the current context
     * @param action the action that triggers sending the mail.
     * @param confirmationLinkParameters the parameters to add to the confirmation link.
     * @param reguestedGroups the groups where action takes place for.
     * @param email email address of the receiver of the email.
     * @return the mail content of the sent mail respective to the action.
     * @throws Exception thrown if generating the mail fails.
     */
    I_CmsPreconfiguredMail getMail(
        CmsObject cms,
        SubscriptionAction action,
        List<String> reguestedGroups,
        String email,
        String confirmationLinkParameters)
    throws Exception;

    /**
     * Returns the groups one can subscribe to via this configuration.
     * @return the groups one can subscribe to via this configuration.
     */
    List<String> getManagedGroups();

    /**
     * Returns the passphrase to use for request parameter encryption.
     * @return the passphrase to use for request parameter encryption.
     */
    String getParameterEncryptionPassphrase();

    /**
     * Returns the redirect URL to go to when the respective action is performed.
     * @param action the action for which the redirect is request for.
     * @return the redirect URL (site path), or <code>null</code> if no redirect is specified.
     */
    String getRedirect(SubscriptionAction action);

}