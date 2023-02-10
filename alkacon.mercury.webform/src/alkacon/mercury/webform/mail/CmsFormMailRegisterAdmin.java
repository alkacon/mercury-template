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

import java.util.List;
import java.util.Map;

import javax.mail.internet.AddressException;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.mail.EmailException;

/**
 * Form mail sent to the administrator when a user registers for the first time.
 */
public class CmsFormMailRegisterAdmin extends A_CmsFormMailAdmin {

    /**
     * Creates a new form mail for the administrator when a user registers for the first time.
     * @param formHandler the form handler
     * @param formDataFields the form data fields
     * @param formDataString the form data fields as string
     */
    public CmsFormMailRegisterAdmin(
        CmsFormHandler formHandler,
        List<CmsFormDataField> formDataFields,
        StringBuffer formDataString) {

        super(formHandler, formDataFields, formDataString);
    }

    /**
     * @see alkacon.mercury.webform.mail.A_CmsFormMailAdmin#sendMail(java.util.Map)
     */
    @Override
    public void sendMail(Map<String, FileItem> fileUploads) throws AddressException, EmailException {

        String mailSubject = m_macroResolver.resolveMacros(m_form.getMailSubjectPrefix() + m_form.getMailSubject());
        sendMail(mailSubject, createMailBody(), fileUploads);
    }

    /**
     * @see alkacon.mercury.webform.mail.A_CmsFormMail#getMailReceiver()
     */
    @Override
    protected String getMailReceiver() {

        return m_form.getMailTo();
    }

    /**
     * @see alkacon.mercury.webform.mail.A_CmsFormMail#getMailText()
     */
    @Override
    protected String getMailText() {

        return m_form.getMailText();
    }

    /**
     * @see alkacon.mercury.webform.mail.A_CmsFormMail#getMailTextPlain()
     */
    @Override
    protected String getMailTextPlain() {

        return m_form.getMailTextPlain();
    }
}
