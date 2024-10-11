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

package alkacon.mercury.webform;

import alkacon.mercury.webform.mail.CmsFormMailCancelAdmin;
import alkacon.mercury.webform.mail.CmsFormMailCancelUser;
import alkacon.mercury.webform.mail.CmsFormMailMoveUpAdmin;
import alkacon.mercury.webform.mail.CmsFormMailMoveUpUser;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.types.I_CmsResourceType;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsMacroResolver;
import org.opencms.xml.content.CmsXmlContent;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map.Entry;

import javax.mail.internet.AddressException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

/**
 * Action class for managing form data.
 */
public class CmsFormDataHandler extends A_CmsFormDataHandler {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormDataHandler.class);

    /** Action name. */
    private final static String ACTION_CANCEL = "cancel";

    /** Action name. */
    private final static String ACTION_MOVEUP = "moveup";

    /** A message key. */
    private final static String ERROR_ALREADY_CANCELLED = "msg.page.bookingmanage.error.alreadycancelled";

    /** A message key. */
    private final static String ERROR_ALREADY_FULLY_BOOKED = "msg.page.bookingmanage.error.alreadyfullybooked";

    /** A message key. */
    private final static String ERROR_ALREADY_MOVED_UP = "msg.page.bookingmanage.error.alreadymovedup";

    /** A message key. */
    private final static String ERROR_SENDING_MAIL_FAILED = "msg.page.bookingmanage.error.sendingmailfailed";

    /** A message key. */
    private final static String INFO_SUCCESS_CANCELLED_REGISTRATION = "msg.page.bookingmanage.info.successcancelregistration";

    /** A message key. */
    private final static String INFO_SUCCESS_WAITLIST_MOVED_UP = "msg.page.bookingmanage.info.successwaitlistmoveup";

    /** The form handler. */
    private CmsFormHandler m_formHandler;

    /** The submission status */
    private CmsSubmissionStatus m_submissionStatus;

    /**
     * Creates a new form data handler.
     * @param context the page context
     * @param request the request
     * @param response the response
     * @param formHandler the form handler
     */
    public CmsFormDataHandler(
        PageContext context,
        HttpServletRequest request,
        HttpServletResponse response,
        CmsFormHandler formHandler) {

        super(context, request, response);
        m_formHandler = formHandler;
        m_submissionStatus = formHandler.getSubmissionStatus();
    }

    /**
     * On request, cancels a user registration.
     * @param paramUuid the UUID of the form data content
     * @return whether canceling the registration was successful
     */
    public boolean cancelRegistration(String paramUuid) {

        if (getCmsObject().getRequestContext().getCurrentProject().isOnlineProject()) {
            return false;
        }
        CmsObject clone = null;
        try {
            clone = OpenCms.initCmsObject(getCmsObject());
            CmsResource resource = readResource(clone, paramUuid);
            if (resource == null) {
                setError(ERROR_RESOURCE_NOT_FOUND);
                return false;
            }
            I_CmsResourceType resourceType = OpenCms.getResourceManager().getResourceType(resource);
            I_CmsResourceType formDataType = OpenCms.getResourceManager().getResourceType(
                CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA);
            if (!resourceType.equals(formDataType)) {
                setError(ERROR_FORBIDDEN);
                return false;
            }
            boolean locked = lockResource(clone, resource);
            if (!locked) {
                setError(ERROR_LOCKING_FAILED);
                return false;
            }
            CmsXmlContent content = readContent(clone, resource);
            if (content == null) {
                setError(ERROR_INTERNAL);
                return false;
            }
            CmsFormDataBean bean = new CmsFormDataBean(content);
            if (bean.isCancelled()) {
                setError(ERROR_ALREADY_CANCELLED);
                return false;
            }
            boolean updated = updateContent(clone, content, CmsFormDataBean.PATH_CANCELLED, "true");
            if (!updated) {
                setError(ERROR_INTERNAL);
                return false;
            }
            boolean mailSent = sendMail(bean, ACTION_CANCEL);
            if (mailSent) {
                String sent = String.valueOf(m_formHandler.getFormConfiguration().isConfirmationMailEnabled());
                boolean updated1 = updateContent(clone, content, CmsFormDataBean.PATH_CANCEL_MAIL_SENT, sent);
                if (!updated1) {
                    setError(ERROR_INTERNAL);
                    return false;
                }
            } else {
                setError(ERROR_SENDING_MAIL_FAILED);
                return false;
            }
            boolean published = publishResource(clone, clone.getSitePath(resource));
            if (!published) {
                setError(ERROR_PUBLISHING_FAILED);
                return false;
            }
            setInfo(INFO_SUCCESS_CANCELLED_REGISTRATION);
        } catch (CmsException e) {
            setError(ERROR_INTERNAL);
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
        return true;
    }

    /**
     * On request, deletes a submission.
     * @param paramUuid the UUID of the form data content
     * @return whether deleting the submission was successful
     */
    public boolean deleteSubmission(String paramUuid) {

        return deleteSubmission(paramUuid, true);
    }

    /**
     * On request, moves a user up from the waiting list, making it a registered user.
     * @param paramUuid the UUID of the form data content
     * @return whether moving up the user from the waiting list was successful
     */
    public boolean moveUpFromWaitingList(String paramUuid) {

        if (getCmsObject().getRequestContext().getCurrentProject().isOnlineProject()) {
            return false;
        }
        CmsObject clone = null;
        try {
            clone = OpenCms.initCmsObject(getCmsObject());
            CmsResource resource = readResource(clone, paramUuid);
            if (resource == null) {
                setError(ERROR_RESOURCE_NOT_FOUND);
                return false;
            }
            I_CmsResourceType resourceType = OpenCms.getResourceManager().getResourceType(resource);
            I_CmsResourceType formDataType = OpenCms.getResourceManager().getResourceType(
                CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA);
            if (!resourceType.equals(formDataType)) {
                setError(ERROR_FORBIDDEN);
                return false;
            }
            boolean locked = lockResource(clone, resource);
            if (!locked) {
                setError(ERROR_LOCKING_FAILED);
                return false;
            }
            CmsXmlContent content = readContent(clone, resource);
            if (content == null) {
                setError(ERROR_INTERNAL);
                return false;
            }
            CmsFormDataBean bean = new CmsFormDataBean(content);
            if (bean.isWaitlistMovedUp()) {
                setError(ERROR_ALREADY_MOVED_UP);
                return false;
            }
            if (m_submissionStatus.isFullyBooked()) {
                setError(ERROR_ALREADY_FULLY_BOOKED);
                return false;
            }
            long now = (new Date()).getTime();
            boolean updated1 = updateContent(
                clone,
                content,
                CmsFormDataBean.PATH_WAITLIST_MOVE_UP_DATE,
                String.valueOf(now));
            if (!updated1) {
                setError(ERROR_INTERNAL);
                return false;
            }
            boolean mailSent = sendMail(bean, ACTION_MOVEUP);
            if (mailSent) {
                String sent = String.valueOf(m_formHandler.getFormConfiguration().isConfirmationMailEnabled());
                boolean updated2 = updateContent(clone, content, CmsFormDataBean.PATH_MOVE_UP_MAIL_SENT, sent);
                if (!updated2) {
                    setError(ERROR_INTERNAL);
                    return false;
                }
            } else {
                setError(ERROR_SENDING_MAIL_FAILED);
                return false;
            }
            boolean published = publishResource(clone, clone.getSitePath(resource));
            if (!published) {
                setError(ERROR_PUBLISHING_FAILED);
                return false;
            }
            setInfo(INFO_SUCCESS_WAITLIST_MOVED_UP);
        } catch (CmsException e) {
            setError(ERROR_INTERNAL);
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
        return true;
    }

    /**
     * Sends a mail to the administrators and, if configured, also to the user.
     * @param bean the form data bean
     * @param action the action to send the mail for
     * @return whether sending the mails was successful
     */
    private boolean sendMail(CmsFormDataBean bean, String action) {

        List<CmsFormDataField> formDataFields = new ArrayList<>();
        StringBuffer formDataString = new StringBuffer();
        CmsMacroResolver macroResolver = m_formHandler.getMacroResolver();
        for (Entry<String, String> field : bean.getData().entrySet()) {
            CmsFormDataField formDataField = new CmsFormDataField(field.getKey(), field.getValue());
            formDataFields.add(formDataField);
            macroResolver.addMacro(formDataField.getLabel(), formDataField.getValue());
            macroResolver.addMacro(
                CmsFormHandler.MACRO_PREFIX_VALUE + formDataField.getLabel(),
                formDataField.getValue());
            if (!m_formHandler.getFormConfiguration().getMailType().equals(CmsForm.MAILTYPE_HTML)) {
                formDataString.append(formDataField.getLabel());
                formDataString.append("\t\t");
                formDataString.append(formDataField.getValue());
                formDataString.append("\n");
            }
        }
        try {
            if (action.equals(ACTION_CANCEL)) {
                CmsFormMailCancelAdmin mailCancelAdmin = new CmsFormMailCancelAdmin(
                    m_formHandler,
                    formDataFields,
                    formDataString);
                mailCancelAdmin.sendMail(null);
                if (m_formHandler.getFormConfiguration().isConfirmationMailEnabled()) {
                    CmsFormMailCancelUser mailCancelUser = new CmsFormMailCancelUser(
                        m_formHandler,
                        formDataFields,
                        formDataString);
                    mailCancelUser.sendMail();
                }
            } else if (action.equals(ACTION_MOVEUP)) {
                CmsFormMailMoveUpAdmin mailMoveUpAdmin = new CmsFormMailMoveUpAdmin(
                    m_formHandler,
                    formDataFields,
                    formDataString);
                mailMoveUpAdmin.sendMail(null);
                if (m_formHandler.getFormConfiguration().isConfirmationMailEnabled()) {
                    CmsFormMailMoveUpUser mailMoveUpUser = new CmsFormMailMoveUpUser(
                        m_formHandler,
                        formDataFields,
                        formDataString);
                    mailMoveUpUser.sendMail();
                }
            }
        } catch (AddressException | EmailException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
        return true;
    }
}
