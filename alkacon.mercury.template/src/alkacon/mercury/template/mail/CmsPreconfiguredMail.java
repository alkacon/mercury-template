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

import org.opencms.mail.CmsHtmlMail;
import org.opencms.mail.CmsMailHost;
import org.opencms.main.CmsLog;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;

import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

/** Class for sending HTML mails. */
public class CmsPreconfiguredMail implements I_CmsPreconfiguredMail {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsPreconfiguredMail.class);

    /** Configuration of the mail wrapped in a special config object. */
    private I_CmsMailConfig m_mailConfig;

    /** The mail host to send the mail with. */
    private CmsMailHost m_mailHost;

    /**
     * Constructs a mail that can be send to various recipients.
     * @param mailConfig mail specific values (content (with macros), subject, sender, ...)
     *
     * @throws Exception thrown if generating the mail fails, in particular content adjustment fails.
     */
    public CmsPreconfiguredMail(I_CmsMailConfig mailConfig)
    throws Exception {

        this(mailConfig, null);

    }

    /**
     * Constructs a mail that can be send to various recipients.
     * @param mailConfig mail specific values (content (with macros), subject, sender, ...)
     * @param mailHost the mail host to send emails with.
     *
     * @throws Exception thrown if generating the mail fails, in particular content adjustment fails.
     */
    public CmsPreconfiguredMail(I_CmsMailConfig mailConfig, CmsMailHost mailHost)
    throws Exception {

        m_mailConfig = mailConfig;
        m_mailHost = mailHost;

    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsPreconfiguredMail#sendTo(java.lang.String, java.util.Map)
     */
    @Override
    public void sendTo(String receipient, Map<String, String> receipientspecificMacros) throws EmailException {

        CmsHtmlMail mail = m_mailHost == null ? new CmsHtmlMail() : new CmsHtmlMail(m_mailHost);
        try {
            String senderName = m_mailConfig.getSenderName();
            String senderEmail = m_mailConfig.getSenderAddress();
            String senderReplyTo = m_mailConfig.getSenderReplyTo();
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(senderEmail)) {
                senderEmail = mail.getFromAddress().getAddress();
            }
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(senderName)) {
                mail.setFrom(senderEmail);
                if (!CmsStringUtil.isEmptyOrWhitespaceOnly(senderReplyTo)) {
                    mail.addReplyTo(senderReplyTo);
                }
            } else {
                mail.setFrom(senderEmail, senderName);
                if (!CmsStringUtil.isEmptyOrWhitespaceOnly(senderReplyTo)) {
                    mail.addReplyTo(senderReplyTo, senderName);
                }
            }
            mail.setSubject(
                null != receipientspecificMacros
                ? resolveReceipientSpecificMacros(m_mailConfig.getSubject(), receipientspecificMacros)
                : m_mailConfig.getSubject());
            mail.setCharset(m_mailConfig.getEncoding());
            mail.addTo(receipient);

            mail.setHtmlMsg(
                null != receipientspecificMacros
                ? resolveReceipientSpecificMacros(m_mailConfig.getContent(), receipientspecificMacros)
                : m_mailConfig.getContent());
            // send the mail
            mail.send();
        } catch (EmailException e) {
            if (LOG.isWarnEnabled()) {
                LOG.warn(
                    "Failed to send mail with subject \"" + m_mailConfig.getSubject() + "\" to \"" + receipient + "\".",
                    e);
            }
            throw e;
        }
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsPreconfiguredMail#sendTo(java.lang.String, java.util.Map, java.lang.String)
     */
    public void sendTo(String recipient, Map<String, String> recipientSpecificMacros, String senderEmail)
    throws EmailException {

        CmsHtmlMail mail = m_mailHost == null ? new CmsHtmlMail() : new CmsHtmlMail(m_mailHost);
        if ((senderEmail != null)
            && senderEmail.equals(A_CmsDkimMailSettings.SITEMAP_ATTRVALUE_DKIM_MAILFROM_DEFAULT)) {
            senderEmail = m_mailHost.getMailfrom();
        }
        try {
            String senderName = m_mailConfig.getSenderName();
            String senderReplyTo = m_mailConfig.getSenderReplyTo();
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(senderReplyTo)) {
                senderReplyTo = m_mailConfig.getSenderAddress();
            }
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(senderName)) {
                mail.setFrom(senderEmail);
                if (!CmsStringUtil.isEmptyOrWhitespaceOnly(senderReplyTo)) {
                    mail.addReplyTo(senderReplyTo);
                }
            } else {
                mail.setFrom(senderEmail, senderName);
                if (!CmsStringUtil.isEmptyOrWhitespaceOnly(senderReplyTo)) {
                    mail.addReplyTo(senderReplyTo, senderName);
                }
            }
            mail.setSubject(
                null != recipientSpecificMacros
                ? resolveReceipientSpecificMacros(m_mailConfig.getSubject(), recipientSpecificMacros)
                : m_mailConfig.getSubject());
            mail.setCharset(m_mailConfig.getEncoding());
            mail.addTo(recipient);

            mail.setHtmlMsg(
                null != recipientSpecificMacros
                ? resolveReceipientSpecificMacros(m_mailConfig.getContent(), recipientSpecificMacros)
                : m_mailConfig.getContent());
            // send the mail
            mail.send();
        } catch (EmailException e) {
            if (LOG.isWarnEnabled()) {
                LOG.warn(
                    "Failed to send mail with subject \"" + m_mailConfig.getSubject() + "\" to \"" + recipient + "\".",
                    e);
            }
            throw e;
        }
    }

    /**
     * Resolves the provided macros in the mail's content.
     * Other macros are kept.
     *
     * @param content the string to resolve the macros in.
     * @param macros the macros to resolve.
     *
     * @return the content string with macros resolved.
     */
    private String resolveReceipientSpecificMacros(String content, Map<String, String> macros) {

        CmsMacroResolver resolver = new CmsMacroResolver();
        resolver.setKeepEmptyMacros(true);
        resolver.setAdditionalMacros(macros);
        return resolver.resolveMacros(content);
    }
}
