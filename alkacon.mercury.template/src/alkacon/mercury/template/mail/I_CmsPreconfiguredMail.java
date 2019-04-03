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

package alkacon.mercury.template.mail;

import java.util.Map;

import org.apache.commons.mail.EmailException;

/**
 * Interface for emails that are already fully configured, i.e, content, subject, sender, etc. are already set.
 * Only the receipient is not determined yet.
 */
public interface I_CmsPreconfiguredMail {

    /**
     * Sends the email.
     *
     * @param recepient the email address of the recipient of the mail.
     * @param receipientSpecificMacros  map from macros to replacements, that are specific for the recipient.
     *
     * @throws EmailException if sending the email fails.
     */
    void sendTo(String recepient, Map<String, String> receipientSpecificMacros) throws EmailException;

}
