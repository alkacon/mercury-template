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

import alkacon.mercury.webform.CmsForm;
import alkacon.mercury.webform.CmsFormDataField;
import alkacon.mercury.webform.CmsFormHandler;
import alkacon.mercury.webform.CmsFormMailSettings;
import alkacon.mercury.webform.I_CmsFormMessages;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateHtmlEmail;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateHtmlEmailFields;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.mail.CmsHtmlMail;
import org.opencms.mail.CmsSimpleMail;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsByteArrayDataSource;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

import org.antlr.stringtemplate.StringTemplate;

/**
 * Abstract form mail.
 */
public abstract class A_CmsFormMail {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(A_CmsFormMail.class);

    /** The form handler. */
    protected final CmsFormHandler m_formHandler;

    /** The form configuration. */
    protected final CmsForm m_form;

    /** The CMS object. */
    protected final CmsObject m_cms;

    /** The macro resolver. */
    protected final CmsMacroResolver m_macroResolver;

    /** The form data fields to be shown in the mail body. */
    protected final List<CmsFormDataField> m_formDataFields;

    /** The form data fields to be shown in the mail body as string. */
    protected final StringBuffer m_formDataString;

    /** The HTML mail in the case the user did choose the HTML mail configuration option. */
    protected final CmsHtmlMail m_htmlMail;

    /** Simple mail in the case the user did choose the plain text mail configuration option. */
    protected final CmsSimpleMail m_simpleMail;

    /**
     * Creates a new form mail.
     * @param formHandler the form handler
     * @param formDataFields the form data fields
     * @param formDataString the form data fields as string
     */
    protected A_CmsFormMail(
        CmsFormHandler formHandler,
        List<CmsFormDataField> formDataFields,
        StringBuffer formDataString) {

        m_formHandler = formHandler;
        m_form = m_formHandler.getFormConfiguration();
        m_cms = m_formHandler.getCmsObject();
        m_macroResolver = m_formHandler.getMacroResolver();
        m_formDataFields = formDataFields;
        m_formDataString = formDataString;
        CmsResource resource = getResource();
        if (resource != null) {
            m_htmlMail = new CmsHtmlMail(CmsFormMailSettings.getInstance().getMailHost(m_cms, resource));
            m_simpleMail = new CmsSimpleMail(CmsFormMailSettings.getInstance().getMailHost(m_cms, resource));
        } else {
            m_htmlMail = new CmsHtmlMail();
            m_simpleMail = new CmsSimpleMail();
        }
        m_htmlMail.setCharset(m_cms.getRequestContext().getEncoding());
        m_simpleMail.setCharset(m_cms.getRequestContext().getEncoding());
    }

    /**
     * Creates a list of Internet addresses (email) from a semicolon separated String.<p>
     *
     * @param mailAddresses a semicolon separated String with email addresses
     * @return list of Internet addresses (email)
     * @throws AddressException if an email address is not correct
     */
    protected List<InternetAddress> createInternetAddresses(String mailAddresses) throws AddressException {

        if (CmsStringUtil.isNotEmpty(mailAddresses)) {
            // at least one email address is present, generate list
            StringTokenizer T = new StringTokenizer(mailAddresses, ";");
            List<InternetAddress> addresses = new ArrayList<>(T.countTokens());
            while (T.hasMoreTokens()) {
                InternetAddress address = new InternetAddress(T.nextToken());
                addresses.add(address);
            }
            return addresses;
        } else {
            // no address given, return empty list
            return Collections.emptyList();
        }
    }

    /**
     * Creates the mail body.
     * @return the mail body
     */
    protected String createMailBody() {

        StringBuffer formDataString = new StringBuffer(m_formDataString);
        String mailCss = null;
        // determine CSS to use for HTML email
        if (isHtmlMail()) {
            // create HTML email using the template output
            if (CmsStringUtil.isNotEmpty(m_form.getMailCSS())) {
                // use individually configured CSS
                mailCss = m_form.getMailCSS();
            }
        }
        // generate the main mail text
        String mailText;
        if (isHtmlMail()) {
            mailText = getMailText();
            // create field output
            StringTemplate sTemplate = m_formHandler.getOutputTemplate(I_CmsTemplateHtmlEmailFields.TEMPLATE_NAME);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmailFields.ATTR_MAIL_CSS, mailCss);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmailFields.ATTR_FIELDS, m_formDataFields);
            formDataString.append(sTemplate.toString());
        } else {
            mailText = getMailTextPlain();
        }
        // resolve the common macros
        mailText = m_formHandler.getMacroResolver().resolveMacros(mailText);
        // check presence of formdata macro in mail text using new macro resolver (important, do not use the same here!)
        CmsMacroResolver macroResolver = CmsMacroResolver.newInstance();
        macroResolver.setKeepEmptyMacros(true);
        macroResolver.addMacro(CmsFormHandler.MACRO_FORMDATA, "");
        if (mailText.length() > macroResolver.resolveMacros(mailText).length()) {
            // form data macro found, resolve it
            macroResolver.addMacro(CmsFormHandler.MACRO_FORMDATA, formDataString.toString());
            mailText = macroResolver.resolveMacros(mailText);
        } else {
            // no form data macro found, add the fields below the mail text
            if (!isHtmlMail()) {
                mailText += "\n\n";
            }
            mailText += formDataString;
        }

        if (isHtmlMail()) {
            StringTemplate sTemplate = m_formHandler.getOutputTemplate(I_CmsTemplateHtmlEmail.TEMPLATE_NAME);
            String errorHeadline = null;
            if ((this instanceof A_CmsFormMailAdmin) && m_form.hasConfigurationErrors()) {
                // write form configuration errors to html mail
                errorHeadline = m_formHandler.getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_HEADLINE);
            }
            // set necessary attributes
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_MAIL_CSS, mailCss);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_MAIL_TEXT, mailText);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_ERROR_HEADLINE, errorHeadline);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_ERRORS, m_form.getConfigurationErrors());
            if (((this instanceof CmsFormMailRegisterUser) || (this instanceof CmsFormMailMoveUpUser))
                && m_form.isConfirmationMailICalLinkEnabled()) {
                sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_ICAL_INFO, m_formHandler.getICalInfo());
            }
            return sTemplate.toString();
        } else {
            StringBuffer result = new StringBuffer(mailText);
            if ((this instanceof A_CmsFormMailAdmin) && m_form.hasConfigurationErrors()) {
                // write form configuration errors to text mail
                result.append("\n");
                result.append(m_formHandler.getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_HEADLINE));
                result.append("\n");
                for (int k = 0; k < m_form.getConfigurationErrors().size(); k++) {
                    result.append(m_form.getConfigurationErrors().get(k));
                    result.append("\n");
                }
            }
            if (((this instanceof CmsFormMailRegisterUser) || (this instanceof CmsFormMailMoveUpUser))
                && m_form.isConfirmationMailICalLinkEnabled()) {
                if (m_formHandler.getICalInfo() != null) {
                    String iCalLabel = m_formHandler.getICalInfo().getLabel();
                    String iCalLink = m_formHandler.getICalInfo().getLink();
                    result.append("\n\n" + iCalLabel + ": " + iCalLink);
                }
            }
            return result.toString();
        }
    }

    /**
     * Returns the mail receiver.
     * @return the mail receiver
     */
    protected abstract String getMailReceiver();

    /**
     * Returns the configured mail text as HTML with macros not yet resolved.
     * @return the configured mail text as HTML
     */
    protected abstract String getMailText();

    /**
     * Returns the configured mail text as plain text with macros not yet resolved.
     * @return the configured mail text as plain text
     */
    protected abstract String getMailTextPlain();

    /**
     * Returns the form configuration resource.
     * @return the form configuration resource
     */
    protected CmsResource getResource() {

        CmsResource resource = null;
        try {
            resource = m_cms.readResource(m_form.getConfigUri());
        } catch (CmsException e) {
            LOG.error(e.getLocalizedMessage(), e);
        }
        return resource;
    }

    /**
     * Returns whether this form mail is configured as an HTML mail.
     * @return whether this form mail is configured as an HTML mail
     */
    protected boolean isHtmlMail() {

        return m_form.getMailType().equals(CmsForm.MAILTYPE_HTML);
    }

    /**
     * Sends this form mail, either as an HTML mail or as a plain text mail.
     * @throws EmailException if sending the form mail fails
     */
    protected final void send() throws EmailException {

        if (isHtmlMail()) {
            m_htmlMail.send();
        } else {
            m_simpleMail.send();
        }
    }

    /**
     * Sets attachments to this form mail.
     * @param attachments the attachments
     * @throws EmailException if settings the attachments fails
     */
    protected final void setAttachments(Map<String, FileItem> attachments) throws EmailException {

        if (attachments != null) {
            Iterator<FileItem> i = attachments.values().iterator();
            while (i.hasNext()) {
                FileItem attachment = i.next();
                if (attachment != null) {
                    String filename = attachment.getName().substring(
                        attachment.getName().lastIndexOf(File.separator) + 1);
                    m_htmlMail.attach(
                        new CmsByteArrayDataSource(
                            filename,
                            attachment.get(),
                            OpenCms.getResourceManager().getMimeType(filename, null, "application/octet-stream")),
                        filename,
                        filename);
                }
            }
        }
    }

    /**
     * Sets the mail body of this form mail.
     * @param mailBody the mail body to set
     * @throws EmailException if settings the mail body fails
     */
    protected final void setMailBody(String mailBody) throws EmailException {

        m_htmlMail.setHtmlMsg(mailBody);
        m_simpleMail.setMsg(mailBody);
    }

    /**
     * Sets the mail subject of this form mail.
     * @param mailSubject if setting the mail subject fails
     */
    protected final void setMailSubject(String mailSubject) {

        m_htmlMail.setSubject(mailSubject);
        m_simpleMail.setSubject(mailSubject);
    }
}
