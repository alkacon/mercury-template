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

/** Interface for a fully configured email, where only the receipient is not yet known. */
public interface I_CmsMailConfig {

    /**
     * Returns the emails content.
     * @return the emails content.
     */
    String getContent();

    /**
     * Returns the emails content encoding.
     * @return the emails content encoding.
     */
    String getEncoding();

    /**
     * Returns the email address of the emails sender.
     * @return the email address of the emails sender.
     */
    String getSenderAddress();

    /**
     * Returns the name of the emails sender.
     * @return the name of the emails sender.
     */
    String getSenderName();

    /**
     * Returns the reply-to address of the emails sender.
     * @return the reply-to address of the emails sender.
     */
    String getSenderReplyTo();

    /**
     * Returns the subject of the email.
     * @return the subject of the email.
     */
    String getSubject();

}
