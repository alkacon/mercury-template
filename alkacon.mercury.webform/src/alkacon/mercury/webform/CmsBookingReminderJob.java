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

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResourceFilter;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.CmsDatePastFutureRestriction;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.I_CmsDateRestriction.TimeDirection;
import org.opencms.mail.CmsHtmlMail;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.scheduler.I_CmsScheduledJob;
import org.opencms.search.CmsSearchException;
import org.opencms.search.CmsSearchResource;
import org.opencms.search.fields.CmsSearchField;
import org.opencms.search.solr.CmsSolrIndex;
import org.opencms.search.solr.CmsSolrQuery;
import org.opencms.search.solr.CmsSolrResultList;
import org.opencms.xml.I_CmsXmlDocument;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

// TODO: write a schema conversion

/**
 * Job that reminds users of a booked event that is about to start.
 * Configure this job in a way that it does not run more than once per day.
 */
public class CmsBookingReminderJob implements I_CmsScheduledJob {

    /**
     * Event reminder data.
     */
    public static class EventReminderData {

        /** The Mercury event as a SOLR search resource */
        private final CmsSearchResource m_searchResource;

        /** The event content. */
        private I_CmsXmlDocument m_event;

        /** The form configuration parser. */
        private CmsFormConfigParser m_formConfigParser;

        /**
         * Creates a new event bean for a given search resource.
         * @param searchResource the search resource
         * @param cms the CMS context
         */
        EventReminderData(CmsSearchResource searchResource, CmsObject cms) {

            m_searchResource = searchResource;
            initEventContent(cms);
            if (m_event != null) {
                initBookingFormConfigParser(cms);
            }
        }

        /**
         * Returns the mail subject.
         * @return the mail subject
         */
        String getMailSubjectUser() {

            // TODO: default subject
            return m_formConfigParser.getResolvedConfigurationValue(PATH_REMINDERMAILSUBJECT, null);
        }

        /**
         * Returns the mail text.
         * @return the mail text
         */
        String getMailTextUser() {

            // TODO: default text
            return m_formConfigParser.getResolvedConfigurationValue(PATH_REMINDERMAILTEXT, null);
        }

        /**
         * Returns the form data beans for all registered users.
         * @param cms the CMS context
         * @return the form data beans for all registered users
         */
        List<CmsFormDataBean> getRegisteredUsers(CmsObject cms) {

            String uuid = m_searchResource.getField(FIELD_ID);
            return A_CmsFormDataHandler.readAllFormData(cms, uuid);
        }

        /**
         * Returns the search resource
         * @return the search resource
         */
        CmsSearchResource getSearchResource() {

            return m_searchResource;
        }

        /**
         * Returns whether the remainder day is reached.
         * @return whether the remainder day is reached
         */
        boolean isReminderDayReached() {

            return true; // TODO: implement this
        }

        /**
         * Initializes the booking form configuration parser.
         * @param cms the CMS context
         */
        private void initBookingFormConfigParser(CmsObject cms) {

            final String contentPath = "Booking/Webform";
            try {
                I_CmsXmlContentValue value = m_event.getValue(contentPath, DEFAULT_CONTENT_LOCALE);
                if (value != null) {
                    String webformPath = value.getStringValue(cms);
                    CmsFile file = cms.readFile(webformPath);
                    I_CmsXmlDocument document = CmsXmlContentFactory.unmarshal(cms, file);
                    m_formConfigParser = new CmsFormConfigParser(
                        cms,
                        document,
                        DEFAULT_CONTENT_LOCALE,
                        null, // TODO: initialize macro resolver
                        new HashMap<String, String>());
                }
            } catch (CmsException e) {
                LOG.error(e.getLocalizedMessage(), e);
            }
        }

        /**
         * Initializes the event content.
         * @param cms the CMS context
         */
        private void initEventContent(CmsObject cms) {

            try {
                String path = m_searchResource.getField(FIELD_PATH);
                if (path != null) {
                    CmsFile file = cms.readFile(path);
                    m_event = CmsXmlContentFactory.unmarshal(cms, file);
                }
            } catch (CmsException e) {
                LOG.error(e.getLocalizedMessage(), e);
            }
        }
    }

    /** The log object for this class. */
    static final Log LOG = CmsLog.getLog(CmsBookingReminderJob.class);

    /** The event type. */
    private static final String EVENT_TYPE = "m-event";

    /** The default content locale to handle. */
    static final Locale DEFAULT_CONTENT_LOCALE = new Locale("de"); // TODO: how to handle locale

    /** Solr field. */
    private static final String FIELD_ID = "id";

    /** Solr field. */
    private static final String FIELD_PATH = "path";

    /** Solr field. */
    private static final String FIELD_TITLE = "Title_prop";

    /** Solr field. */
    private static final String FIELD_TYPE = "type";

    /** Solr field. */
    private static final String FIELD_BOOKING_REMINDER = "booking-reminder_" + DEFAULT_CONTENT_LOCALE.toString() + "_b";

    /** Solr field. */
    private static final String FIELD_CURRENT_TILL = CmsSearchField.FIELD_INSTANCEDATE_CURRENT_TILL
        + "_"
        + DEFAULT_CONTENT_LOCALE.toString()
        + "_dt";

    /** Configuration node name for the confirmation mail subject node. */
    public static final String PATH_REMINDERMAILSUBJECT = "OptionalConfirmationMail/ReminderMail/ReminderMailSubject";

    /** Configuration node name for the confirmation mail text node. */
    public static final String PATH_REMINDERMAILTEXT = "OptionalConfirmationMail/ReminderMail/ReminderMailText";

    /**
     * @see org.opencms.scheduler.I_CmsScheduledJob#launch(org.opencms.file.CmsObject, java.util.Map)
     */
    public String launch(CmsObject cms, Map<String, String> parameters) throws Exception {

        List<EventReminderData> events = findAllFutureEventsWithReminderMail(cms);
        if (events != null) {
            for (EventReminderData event : events) {
                LOG.debug(
                    "Future event found with reminder mail configured: "
                        + event.getSearchResource().getField(FIELD_TITLE));
                if (event.isReminderDayReached()) {
                    sendReminderMails(event, cms);
                }
            }
            return "OK";
        } else {
            return "ERROR";
        }
    }

    /**
     * Returns the content locale to handle.
     * @return the content locale to handle
     */
    Locale getLocale() {

        return DEFAULT_CONTENT_LOCALE;
    }

    /**
     * Returns all future events with a reminder mail enabled.
     * @param cms
     * @return all future events with a reminder mail enabled
     */
    private List<EventReminderData> findAllFutureEventsWithReminderMail(CmsObject cms) {

        final int numRows = 1000000;
        CmsSolrIndex solrIndex = OpenCms.getSearchManager().getIndexSolr(CmsSolrIndex.DEFAULT_INDEX_NAME_ONLINE);
        CmsSolrQuery q = new CmsSolrQuery();
        q.addFilterQuery(FIELD_TYPE + ":" + EVENT_TYPE);
        CmsDatePastFutureRestriction dateRestriction = new CmsDatePastFutureRestriction(TimeDirection.future);
        q.addFilterQuery(FIELD_CURRENT_TILL + ":" + dateRestriction.getRange());
        q.addFilterQuery(FIELD_BOOKING_REMINDER + ":true");
        q.setFields(FIELD_ID, FIELD_TITLE, FIELD_PATH);
        q.setRows(Integer.valueOf(numRows));
        CmsSolrResultList result = null;
        try {
            result = solrIndex.search(cms, q, true, null, true, CmsResourceFilter.DEFAULT, numRows);
            return result.stream().map(searchResource -> new EventReminderData(searchResource, cms)).collect(
                Collectors.toList());
        } catch (CmsSearchException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return null;
        }
    }

    /**
     * Sends a mail to the event administrators informing about success and failure of mail reminders.
     * @return whether the mail was successfully sent
     */
    private boolean sendReminderMailAdmin() {

        return true; // TODO
    }

    /**
     * Sends reminder mails to all registered users of an event.
     * @param eventReminderData the event with a reminder mail configured
     * @param cms the CMS context
     */
    private void sendReminderMails(EventReminderData eventReminderData, CmsObject cms) {

        for (CmsFormDataBean formDataBean : eventReminderData.getRegisteredUsers(cms)) {
            if (!formDataBean.isReminderMailSent()) {
                boolean successfullySent = sendReminderMailUser(eventReminderData, formDataBean);
                if (successfullySent) {
                    CmsFile file = formDataBean.getFile();
                    if (file != null) {
                        boolean locked = A_CmsFormDataHandler.lockResource(cms, file);
                        if (!locked) {
                            LOG.warn("Could not lock resource " + file.getRootPath());
                            continue;
                        }
                        CmsXmlContent content = A_CmsFormDataHandler.readContent(cms, file);
                        if (content == null) {
                            LOG.error("Could not read content for " + file.getRootPath());
                            continue;
                        }
                        boolean updated = A_CmsFormDataHandler.updateContent(
                            cms,
                            content,
                            CmsFormDataBean.PATH_REMINDER_MAIL_SENT,
                            "true");
                        if (!updated) {
                            LOG.error("Could not update content " + file.getRootPath());
                            // anyway continue to publish
                        }
                        // TODO: make sure that formDataBean.getFile() is not a folder and / or check type
                        boolean published = A_CmsFormDataHandler.publishResource(cms, cms.getSitePath(file));
                        if (!published) {
                            LOG.error("Could not publish content " + file.getRootPath());
                        }
                    }
                }
            }
        }
    }

    /**
     * Sends a reminder mail to one registered user.
     * @param eventReminderData the event reminder data
     * @param formDataBean the form data of the registered user
     * @return whether the reminder mail was successfully sent
     */
    private boolean sendReminderMailUser(EventReminderData eventReminderData, CmsFormDataBean formDataBean) {

        try {
            CmsHtmlMail mail = new CmsHtmlMail();
            String subject = eventReminderData.getMailSubjectUser();
            String text = eventReminderData.getMailTextUser();
            mail.setSubject(subject);
            mail.setHtmlMsg(text);
            mail.addTo("j.graf@alkacon.com");
            mail.send();
            return true;
        } catch (EmailException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
    }
}
