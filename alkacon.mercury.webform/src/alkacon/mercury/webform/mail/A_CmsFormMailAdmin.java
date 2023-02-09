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

import alkacon.mercury.webform.CmsFormDataField;
import alkacon.mercury.webform.CmsFormHandler;

import org.opencms.util.CmsStringUtil;

import java.util.List;
import java.util.Map;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.mail.EmailException;

/**
 * Form mail sent to the administrators of a configured form.
 */
public abstract class A_CmsFormMailAdmin extends A_CmsFormMail {

    /**
     * Creates a new form mail for administrators.
     * @param formHandler the form handler
     * @param formDataFields the form data fields
     * @param formDataString the form data fields as string
     */
    protected A_CmsFormMailAdmin(
        CmsFormHandler formHandler,
        List<CmsFormDataField> formDataFields,
        StringBuffer formDataString) {

        super(formHandler, formDataFields, formDataString);
    }

    /**
     * Sends the form mail with attachments.
     * @param attachments the attachments
     * @throws AddressException if there is an error with the mail addresses
     * @throws EmailException if sending the mail fails
     */
    public abstract void sendMail(Map<String, FileItem> attachments) throws AddressException, EmailException;

    /**
    * Internal mail send function.
    * @param mailSubject the mail subject
    * @param mailBody the mail body
    * @param attachments the mail attachments
    * @throws EmailException if sending the mail fails
    * @throws AddressException if there is an error with the mail addresses
    */
    protected void sendMail(String mailSubject, String mailBody, Map<String, FileItem> attachments)
    throws EmailException, AddressException {

        setAddresses();
        setMailSubject(mailSubject);
        setMailBody(mailBody);
        setAttachments(attachments);
        send();
    }

    /**
     * Sets the configured addresses for a administrator's form mail.
     * @throws EmailException if sending the mail fails
     * @throws AddressException if there is an error with the mail addresses
     */
    protected void setAddresses() throws AddressException, EmailException {

        String mailFrom = m_macroResolver.resolveMacros(m_form.getMailFrom());
        String mailFromName = m_macroResolver.resolveMacros(m_form.getMailFromName());
        String mailReplyTo = m_macroResolver.resolveMacros(m_form.getMailReplyTo());
        String mailTo = m_macroResolver.resolveMacros(getMailReceiver());
        List<InternetAddress> mailCC = createInternetAddresses(m_macroResolver.resolveMacros(m_form.getMailCC()));
        List<InternetAddress> mailBcc = createInternetAddresses(m_macroResolver.resolveMacros(m_form.getMailBCC()));
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFrom)) {
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromName)) {
                m_htmlMail.setFrom(mailFrom, mailFromName);
                m_simpleMail.setFrom(mailFrom, mailFromName);
            } else {
                m_htmlMail.setFrom(mailFrom);
                m_simpleMail.setFrom(mailFrom);
            }
        }
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailReplyTo)) {
            m_htmlMail.addReplyTo(mailReplyTo);
            m_simpleMail.addReplyTo(mailReplyTo);
        }
        m_htmlMail.setTo(createInternetAddresses(mailTo));
        m_simpleMail.setTo(createInternetAddresses(mailTo));
        if (mailCC.size() > 0) {
            m_htmlMail.setCc(mailCC);
            m_simpleMail.setCc(mailCC);
        }
        if (mailBcc.size() > 0) {
            m_htmlMail.setBcc(mailBcc);
            m_simpleMail.setBcc(mailBcc);
        }
    }
}
