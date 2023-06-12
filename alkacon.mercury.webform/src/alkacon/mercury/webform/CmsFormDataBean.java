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

package alkacon.mercury.webform;

import org.opencms.file.CmsFile;
import org.opencms.file.CmsResource;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.util.CmsMacroResolver;
import org.opencms.xml.I_CmsXmlDocument;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Bean to provide easy access to XML contents storing submitted form data. */
public class CmsFormDataBean {

    /** xpath for the form data content value containing the deletion date. */
    public static final String PATH_DELETION_DATE = "DeletionDate";

    /** The XPath to store the form configuration in. */
    public static final String PATH_FORM = "Form[1]";

    /** The XPath to store the event configuration in. */
    public static final String PATH_EVENT = "Event[1]";

    /** The XPATH to store the title mapping. */
    public static final String PATH_TITLEMAPPING = "TitleMapping[1]";

    /** The XPATH to store the configuration mail sent information. */
    public static final String PATH_CONFIRMATION_MAIL_SENT = "ConfirmationMailSent[1]";

    /** The XPATH to store the registration mail sent information. */
    public static final String PATH_REGISTRATION_MAIL_SENT = "RegistrationMailSent[1]";

    /** The XPATH to store the waitlist notification flag. */
    public static final String PATH_WAITLIST_NOTIFICATION = "WaitlistNotification[1]";

    /** The XPATH to store the move-up mail sent information. */
    public static final String PATH_MOVE_UP_MAIL_SENT = "MoveUpMailSent[1]";

    /** The XPATH to store the cancel mail sent information. */
    public static final String PATH_CANCEL_MAIL_SENT = "CancelMailSent[1]";

    /** The XPATH to store the date when the user was moved up from the waiting list. */
    public static final String PATH_WAITLIST_MOVE_UP_DATE = "WaitlistMoveUpDate[1]";

    /** The XPATH to store the date when the user registration was cancelled. */
    public static final String PATH_CANCEL_DATE = "CancelDate[1]";

    /** The path to the "Cancelled" flag. */
    public static final String PATH_CANCELLED = "Cancelled[1]";

    /** The path to all data key-value pairs. */
    private static final String PATH_DATA = "Data";

    /** The path part for the key sub-path of key-value pairs. */
    private static final String PATH_PART_DATA_KEY = "/Key";

    /** The path part for the key sub-path of key-value pairs. */
    private static final String PATH_PART_DATA_VALUE = "/Value";

    /** The form data as "form field" - "user input" map. */
    private LinkedHashMap<String, String> m_data;

    /** The form data content. */
    private I_CmsXmlDocument m_content;

    /** The resolved title. */
    private String m_title;

    /** Whether this submission is in cancelled state. */
    private Boolean m_isCancelled;

    /** Whether this submission is in waitlist state. */
    private Boolean m_isWaitlist;

    /** Whether this submission is in waitlist moved-up state. */
    private Boolean m_isWaitlistMovedUp;

    /** Whether a confirmation mail was sent. */
    private Boolean m_isConfirmationMailSent;

    /** Whether a registration mail was sent. */
    private Boolean m_isRegistrationMailSent;

    /** Whether a waitlist notification mail was sent. */
    private Boolean m_isWaitlistNotification;

    /** Whether a move-up mail was sent. */
    private Boolean m_isMoveUpMailSent;

    /** Whether a cancel mail was sent. */
    private Boolean m_isCancelMailSent;

    /**
     * Constructor for wrapping the plain CmsXmlContent of a form data content.
     * @param content the form data content to wrap.
     */
    public CmsFormDataBean(I_CmsXmlDocument content) {

        m_content = content;
    }

    /**
     * Creates the XPath to the key of a key-value pair.
     * @param entryNum the number of the key-value pair.
     * @return the XPath to the key of the <code>entryNum</code>s key-value pair.
     */
    public static String getKeyPath(int entryNum) {

        return getDataPath(entryNum) + "/Key[1]";
    }

    /**
     * Creates the XPath to the value of a key-value pair.
     * @param entryNum the number of the key-value pair.
     * @return the XPath to the value of the <code>entryNum</code>s key-value pair.
     */
    public static String getValuePath(int entryNum) {

        return getDataPath(entryNum) + "/Value[1]";
    }

    /**
     * Creates the XPath to the value of a key-value pair.
     * @param entryNum the number of the key-value pair.
     * @return the XPath to the value of the <code>entryNum</code>s key-value pair.
     */
    private static String getDataPath(int entryNum) {

        return PATH_DATA + "[" + entryNum + "]";
    }

    /**
     * Returns a map form field names to the values entered in that field.
     * @return a map form field names to the values entered in that field.
     */
    public LinkedHashMap<String, String> getData() {

        if (null == m_data) {
            m_data = new LinkedHashMap<>();
            List<I_CmsXmlContentValue> entries = m_content.getValues(PATH_DATA, CmsLocaleManager.MASTER_LOCALE);
            for (I_CmsXmlContentValue entry : entries) {
                I_CmsXmlContentValue key = m_content.getValue(entry.getPath() + PATH_PART_DATA_KEY, entry.getLocale());
                I_CmsXmlContentValue value = m_content.getValue(
                    entry.getPath() + PATH_PART_DATA_VALUE,
                    entry.getLocale());
                m_data.put(key.getStringValue(null), value.getStringValue(null));
            }
        }
        return m_data;
    }

    /**
     * Returns the date when this registration was cancelled or null if not cancelled.
     * @return the date when this registration was cancelled or null if not cancelled
     */
    public Date getDateCancelled() {

        long expires = m_content.getFile().getDateExpired();
        if (expires == CmsResource.DATE_EXPIRED_DEFAULT) {
            return null;
        } else {
            return new Date(expires);
        }
    }

    /**
     * Returns the date when the user did move up from the wait list or null if not moved up.
     * @return the date when the user did move up from the wait list or null if not moved up
     */
    public Date getDateMovedUp() {

        I_CmsXmlContentValue movedUp = m_content.getValue(PATH_WAITLIST_MOVE_UP_DATE, CmsLocaleManager.MASTER_LOCALE);
        return movedUp == null ? null : new Date(Long.parseLong(movedUp.getStringValue(null)));
    }

    /**
     * Returns the registration date.
     * @return the registration date
     */
    public Date getDateRegistered() {

        return new Date(m_content.getFile().getDateCreated());
    }

    /**
     * Returns the file of this form data bean.
     * @return the file of this form data bean
     */
    public CmsFile getFile() {

        return m_content.getFile();
    }

    /**
     * Returns the title property the content should get (with all field macros resolved).
     * @return the title property the content should get (with all field macros resolved).
     */
    public String getTitleProperty() {

        if (null == m_title) {
            m_title = resolveTitle();
        }
        return m_title;
    }

    /**
     * Returns whether this submission is in cancelled state.
     * @return whether this submission is in cancelled state
     */
    public boolean isCancelled() {

        if (null == m_isCancelled) {
            I_CmsXmlContentValue value = m_content.getValue(PATH_CANCELLED, CmsLocaleManager.MASTER_LOCALE);
            m_isCancelled = Boolean.valueOf(value.getStringValue(null));
        }
        return m_isCancelled.booleanValue();
    }

    /**
     * Whether a cancel mail was sent.
     * @return whether a cancel mail was sent
     */
    public boolean isCancelMailSent() {

        if (null == m_isCancelMailSent) {
            I_CmsXmlContentValue value = m_content.getValue(PATH_CANCEL_MAIL_SENT, CmsLocaleManager.MASTER_LOCALE);
            if (value == null) {
                m_isCancelMailSent = Boolean.FALSE;
            } else {
                m_isCancelMailSent = Boolean.valueOf(value.getStringValue(null));
            }
        }
        return m_isCancelMailSent.booleanValue();
    }

    /**
     * Returns a flag, indicating if the offline version of this content differs from the online version.
     *
     * NOTE: We assume, we access the offline version of the content. Otherwise this method will not work properly.
     *
     * @return a flag, indicating if the offline version of this content differs from the online version.
     */
    public boolean isChanged() {

        return !m_content.getFile().getState().isUnchanged();
    }

    /**
     * Whether a confirmation mail was sent.
     * @return whether a confirmation mail was sent
     */
    public boolean isConfirmationMailSent() {

        if (null == m_isConfirmationMailSent) {
            I_CmsXmlContentValue value = m_content.getValue(
                PATH_CONFIRMATION_MAIL_SENT,
                CmsLocaleManager.MASTER_LOCALE);
            m_isConfirmationMailSent = Boolean.valueOf(value.getStringValue(null));
        }
        return m_isConfirmationMailSent.booleanValue();
    }

    /**
     * Whether a move-up mail was sent.
     * @return whether a move-up mail was sent
     */
    public boolean isMoveUpMailSent() {

        if (null == m_isMoveUpMailSent) {
            I_CmsXmlContentValue value = m_content.getValue(PATH_MOVE_UP_MAIL_SENT, CmsLocaleManager.MASTER_LOCALE);
            if (value == null) {
                m_isMoveUpMailSent = Boolean.FALSE;
            } else {
                m_isMoveUpMailSent = Boolean.valueOf(value.getStringValue(null));
            }
        }
        return m_isMoveUpMailSent.booleanValue();
    }

    /**
     * Whether a registration mail was sent. This is the case if the confirmation mail flag is true and
     * the waitlist notification flag is false.
     * @return whether a registration mail was sent
     */
    public boolean isRegistrationMailSent() {

        if ((m_isWaitlistNotification == null) || (m_isRegistrationMailSent == null)) {
            I_CmsXmlContentValue value = m_content.getValue(PATH_WAITLIST_NOTIFICATION, CmsLocaleManager.MASTER_LOCALE);
            m_isWaitlistNotification = Boolean.valueOf(value.getStringValue(null));
            m_isRegistrationMailSent = Boolean.valueOf(
                (isConfirmationMailSent() == true) && (m_isWaitlistNotification == Boolean.FALSE));
        }
        return m_isRegistrationMailSent.booleanValue();
    }

    /**
     * Whether this submission is in waitlist state.
     * @return whether this submission is in waitlist state
     */
    public boolean isWaitlist() {

        if (null == m_isWaitlist) {
            if (isCancelled()) {
                m_isWaitlist = Boolean.FALSE;
            } else if (isWaitlistMovedUp()) {
                m_isWaitlist = Boolean.FALSE;
            } else {
                I_CmsXmlContentValue value = m_content.getValue(
                    PATH_WAITLIST_NOTIFICATION,
                    CmsLocaleManager.MASTER_LOCALE);
                m_isWaitlist = Boolean.valueOf(value.getStringValue(null));
            }
        }
        return m_isWaitlist.booleanValue();
    }

    /**
     * Whether this submission is in waitlist moved-up state.
     * @return whether this submission is in waitlist moved-up state
     */
    public boolean isWaitlistMovedUp() {

        if (m_isWaitlistMovedUp == null) {
            if (isCancelled()) {
                m_isWaitlistMovedUp = Boolean.FALSE;
            } else if (m_content.getValue(PATH_WAITLIST_MOVE_UP_DATE, CmsLocaleManager.MASTER_LOCALE) != null) {
                m_isWaitlistMovedUp = Boolean.TRUE;
            } else {
                m_isWaitlistMovedUp = Boolean.FALSE;
            }
        }
        return m_isWaitlistMovedUp.booleanValue();
    }

    /**
     * Whether a waitlist notification mail was sent. This is the case if the confirmation mail flag is true
     * and the waitlist notification flag is true.
     * @return whether a waitlist notification mail was sent
     */
    public boolean isWaitlistNotificationSent() {

        if (m_isWaitlistNotification == null) {
            I_CmsXmlContentValue value = m_content.getValue(PATH_WAITLIST_NOTIFICATION, CmsLocaleManager.MASTER_LOCALE);
            m_isWaitlistNotification = Boolean.valueOf(value.getStringValue(null));
        }
        return isConfirmationMailSent() && m_isWaitlistNotification.booleanValue();
    }

    /**
     * Returns the intended title for the XML content without any macros resolved.
     * @return the intended title for the XML content without any macros resolved.
     */
    private String getTitleFromContent() {

        I_CmsXmlContentValue titleValue = m_content.getValue(PATH_TITLEMAPPING, CmsLocaleManager.MASTER_LOCALE);
        return titleValue.getStringValue(null);
    }

    /**
     * Retrieves the title from the XML content's special element, resolves the contained macros for form fields and returns the resulting string.
     * @return the title with resolved macros.
     */
    private String resolveTitle() {

        CmsMacroResolver resolver = CmsMacroResolver.newInstance();
        resolver.setKeepEmptyMacros(false);
        for (Map.Entry<String, String> entry : getData().entrySet()) {
            resolver.addMacro(entry.getKey(), entry.getValue());
        }
        return resolver.resolveMacros(getTitleFromContent());

    }

}
