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

import alkacon.mercury.template.mail.A_CmsDkimMailSettings;
import alkacon.mercury.webform.mail.CmsFormMailMessages;

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResourceFilter;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.CmsDatePastFutureRestriction;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.I_CmsDateRestriction.TimeDirection;
import org.opencms.jsp.util.CmsJspContentAccessValueWrapper;
import org.opencms.jsp.util.CmsJspDateSeriesBean;
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
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;
import org.opencms.widgets.serialdate.CmsSerialDateBeanFactory;
import org.opencms.widgets.serialdate.I_CmsSerialDateBean;
import org.opencms.xml.I_CmsXmlDocument;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.TimeUnit;
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
         * Returns the content title.
         * @param cms the CMS context
         * @return the content title
         */
        String getContentTitle(CmsObject cms) {

            String contentTitle = "";
            I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_TITLE, cms.getRequestContext().getLocale());
            if ((value != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                contentTitle = value.getStringValue(cms);
            }
            return contentTitle;
        }

        /**
         * Returns the event note.
         * @param cms the CMS context
         * @return the event note
         */
        String getEventNote(CmsObject cms) {

            String eventNote = "";
            I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_NOTE, cms.getRequestContext().getLocale());
            if ((value != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                eventNote = value.getStringValue(cms);
            }
            return eventNote;
        }

        /**
         * Returns the event time.
         * @param cms the CMS context
         * @return the formatted event time
         */
        String getEventTime(CmsObject cms) {

            I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_DATES, cms.getRequestContext().getLocale());
            CmsJspContentAccessValueWrapper wrapper = CmsJspContentAccessValueWrapper.createWrapper(
                cms,
                value,
                m_event,
                PATH_EVENT_DATES,
                cms.getRequestContext().getLocale());
            CmsJspDateSeriesBean dateSeriesBean = new CmsJspDateSeriesBean(
                wrapper,
                cms.getRequestContext().getLocale());
            return dateSeriesBean.getFirst().getStartInstance().getFormatLong();
        }

        /**
         * Returns the event type.
         * @param cms the CMS context
         * @return the event type
         */
        String getEventType(CmsObject cms) {

            String eventType = "";
            I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_TYPE, cms.getRequestContext().getLocale());
            if ((value != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                eventType = value.getStringValue(cms);
            }
            return eventType;
        }

        /**
         * Returns the event file.
         * @return the event file
         */
        CmsFile getFile() {

            return m_event.getFile();
        }

        /**
         * Returns the mail from address.
         * @param cms the CMS context
         * @return the mail from address
         */
        String getMailFrom(CmsObject cms) {

            String mailFrom = "";
            I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_MAIL_FROM, cms.getRequestContext().getLocale());
            if ((value == null) || CmsStringUtil.isEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                String path = CmsForm.NODE_OPTIONALCONFIRMATION + "/" + CmsForm.NODE_CONFIRMATIONMAILFROM;
                mailFrom = m_formConfigParser.getConfigurationValue(path, "");
            }
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(mailFrom)) {
                String path = CmsForm.NODE_MAILFROM;
                mailFrom = m_formConfigParser.getConfigurationValue(path, "");
            }
            return mailFrom;
        }

        /**
         * Returns the name of the mail sender.
         * @param cms the CMS context
         * @return the name of the mail sender
         */
        String getMailFromName(CmsObject cms) {

            String mailFromName = "";
            I_CmsXmlContentValue value = m_event.getValue(
                PATH_EVENT_MAIL_FROM_NAME,
                cms.getRequestContext().getLocale());
            if ((value == null) || CmsStringUtil.isEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                String path = CmsForm.NODE_OPTIONALCONFIRMATION + "/" + CmsForm.NODE_CONFIRMATIONMAILFROMNAME;
                mailFromName = m_formConfigParser.getConfigurationValue(path, "");
            }
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(mailFromName)) {
                String path = CmsForm.NODE_MAILFROMNAME;
                mailFromName = m_formConfigParser.getConfigurationValue(path, "");
            }
            return mailFromName;
        }

        /**
         * Returns the reply-to address.
         * @param cms the CMS context
         * @return the mail reply-to address
         */
        String getMailReplyTo(CmsObject cms) {

            String mailReplyTo = "";
            String path = CmsForm.NODE_OPTIONALCONFIRMATION + "/" + CmsForm.NODE_CONFIRMATIONMAILREPLYTO;
            mailReplyTo = m_formConfigParser.getConfigurationValue(path, "");
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(mailReplyTo)) {
                path = CmsForm.NODE_MAILREPLYTO;
                mailReplyTo = m_formConfigParser.getConfigurationValue(path, "");
            }
            return mailReplyTo;
        }

        /**
         * Returns the mail subject.
         * @param cms the CMS context
         * @return the mail subject
         */
        String getMailSubjectUser(CmsObject cms) {

            String defaultSubject = CmsFormMailMessages.get().container(
                CmsFormMailMessages.MAIL_SUBJECT_REMINDER_USER).key(cms.getRequestContext().getLocale());
            return m_formConfigParser.getConfigurationValue(PATH_REMINDERMAILSUBJECT, defaultSubject);
        }

        /**
         * Returns the mail text.
         * @param cms the CMS context
         * @return the mail text
         */
        String getMailTextUser(CmsObject cms) {

            String defaultText = CmsFormMailMessages.get().container(CmsFormMailMessages.MAIL_TEXT_REMINDER_USER).key(
                cms.getRequestContext().getLocale());
            return m_formConfigParser.getConfigurationValue(PATH_REMINDERMAILTEXT, defaultText);
        }

        /**
         * Returns the mail receiver address.
         * @param formDataBean the form data bean
         * @param cms the CMS context
         * @return the mail receiver address
         */
        String getMailTo(CmsFormDataBean formDataBean, CmsObject cms) {

            String mailTo = "";
            String path = CmsForm.NODE_OPTIONALCONFIRMATION + "/" + CmsForm.NODE_CONFIRMATIONMAILFIELD;
            String mailDataField = m_formConfigParser.getConfigurationValue(path, null);
            if ((mailDataField != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailDataField)) {
                mailTo = formDataBean.getData().get(mailDataField);
            }
            return mailTo;
        }

        /**
         * Returns the form data beans for all registered users.
         * @param cms the CMS context
         * @return the form data beans for all registered users
         */
        List<CmsFormDataBean> getRegisteredUsers(CmsObject cms) {

            String uuid = m_searchResource.getField(FIELD_ID);
            List<CmsFormDataBean> all = A_CmsFormDataHandler.readAllFormData(cms, uuid);
            List<CmsFormDataBean> registered = new ArrayList<CmsFormDataBean>();
            for (CmsFormDataBean formDataBean : all) {
                if (formDataBean.isRegistered()) {
                    registered.add(formDataBean);
                }
            }
            return registered;
        }

        /**
         * Returns the reminder time interval.
         * @param cms the CMS context
         * @return the reminder time interval
         */
        String getReminderInterval(CmsObject cms) {

            String reminderInterval = "";
            I_CmsXmlContentValue value = m_event.getValue(
                PATH_EVENT_REMINDER_INTERVAL,
                cms.getRequestContext().getLocale());
            if ((value != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                reminderInterval = value.getStringValue(cms);
            }
            return reminderInterval;
        }

        /**
         * Returns the reminder note.
         * @param cms the CMS context
         * @return the reminder note
         */
        String getReminderNote(CmsObject cms) {

            String reminderNote = "";
            I_CmsXmlContentValue value = m_event.getValue(
                PATH_EVENT_REMINDER_NOTE,
                cms.getRequestContext().getLocale());
            if ((value != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(value.getStringValue(cms))) {
                reminderNote = value.getStringValue(cms);
            }
            return reminderNote;
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
         * @param cms the CMS context
         * @return whether the remainder day is reached
         */
        boolean isReminderDayReached(CmsObject cms) {

            boolean reached = false;
            I_CmsXmlContentValue datesValue = m_event.getValue(PATH_EVENT_DATES, cms.getRequestContext().getLocale());
            I_CmsXmlContentValue timeIntervalValue = m_event.getValue(
                PATH_EVENT_REMINDER_INTERVAL,
                cms.getRequestContext().getLocale());
            long timeInterval = 3L;
            if (timeIntervalValue != null) {
                try {
                    timeInterval = Long.parseLong(timeIntervalValue.getStringValue(cms));
                } catch (NumberFormatException e) {
                    LOG.error(e.getLocalizedMessage(), e);
                }
            }
            if (datesValue != null) {
                I_CmsSerialDateBean serialDate = CmsSerialDateBeanFactory.createSerialDateBean(
                    datesValue.getStringValue(cms));
                LOG.debug("Serial date value is " + datesValue.getStringValue(cms));
                Date now = new Date();
                if (!serialDate.getDates().isEmpty()) {
                    Date startDate = serialDate.getDates().first();
                    long diffMillis = startDate.getTime() - now.getTime();
                    long diffDays = TimeUnit.DAYS.convert(diffMillis, TimeUnit.MILLISECONDS);
                    if ((diffDays > 0L) && (diffDays <= timeInterval)) {
                        LOG.debug("Reminder day reached. " + m_searchResource.getField(FIELD_TITLE));
                        reached = true;
                    } else {
                        LOG.debug(
                            "Reminder day not yet reached, "
                                + (diffDays - timeInterval)
                                + " remaining. "
                                + m_searchResource.getField(FIELD_TITLE));
                    }
                } else {
                    LOG.debug("No dates configured for event.");
                }
            }
            return reached;
        }

        /**
         * Initializes the booking form configuration parser.
         * @param cms the CMS context
         */
        private void initBookingFormConfigParser(CmsObject cms) {

            try {
                I_CmsXmlContentValue value = m_event.getValue(PATH_EVENT_WEBFORM, cms.getRequestContext().getLocale());
                if (value != null) {
                    String webformPath = value.getStringValue(cms);
                    CmsFile file = cms.readFile(webformPath);
                    I_CmsXmlDocument document = CmsXmlContentFactory.unmarshal(cms, file);
                    m_formConfigParser = new CmsFormConfigParser(
                        cms,
                        document,
                        cms.getRequestContext().getLocale(),
                        null,
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

    /** Solr field. */
    private static final String FIELD_BOOKING_REMINDER = "booking-reminder";

    /** Solr field. */
    private static final String FIELD_ID = "id";

    /** Solr field. */
    private static final String FIELD_PATH = "path";

    /** Solr field. */
    private static final String FIELD_TITLE = "Title_prop";

    /** Solr field. */
    private static final String FIELD_TYPE = "type";

    /** Path for the confirmation mail subject node. */
    public static final String PATH_REMINDERMAILSUBJECT = "OptionalConfirmationMail/ReminderMail/ReminderMailSubject";

    /** Path for the confirmation mail text node. */
    public static final String PATH_REMINDERMAILTEXT = "OptionalConfirmationMail/ReminderMail/ReminderMailText";

    /** Path for the confirmation mail sender address. */
    public static final String PATH_EVENT_MAIL_FROM = "Booking/MailFrom";

    /** Path for the confirmation mail sender name. */
    public static final String PATH_EVENT_MAIL_FROM_NAME = "Booking/MailFromName";

    /** Path for the event dates. */
    public static final String PATH_EVENT_DATES = "Dates";

    /** Path for the event booking note. */
    public static final String PATH_EVENT_NOTE = "Booking/Note";

    /** Path for the event booking webform. */
    public static final String PATH_EVENT_WEBFORM = "Booking/Webform";

    /** Path for the event reminder time interval. */
    public static final String PATH_EVENT_REMINDER_INTERVAL = "Booking/ReminderMail/TimeInterval";

    /** Path for the event reminder note. */
    public static final String PATH_EVENT_REMINDER_NOTE = "Booking/ReminderMail/Note";

    /** Path for the event type. */
    public static final String PATH_EVENT_TYPE = "Type";

    /** Path for the event title. */
    public static final String PATH_EVENT_TITLE = "Title";

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
                if (event.isReminderDayReached(cms)) {
                    sendReminderMails(event, cms);
                }
            }
            return "OK";
        } else {
            return "ERROR";
        }
    }

    /**
     * Creates a macro resolver for a given form data bean.
     * @param eventReminderData the event reminder data
     * @param formDataBean the form data bean
     * @param cms the CMS context
     * @return the macro resolver
     */
    private CmsMacroResolver createMacroResolver(
        EventReminderData eventReminderData,
        CmsFormDataBean formDataBean,
        CmsObject cms) {

        CmsMacroResolver resolver = CmsMacroResolver.newInstance();
        resolver.setKeepEmptyMacros(true);
        resolver.addMacro(CmsForm.MACRO_CONTENT_TITLE, eventReminderData.getContentTitle(cms));
        resolver.addMacro("event.note", eventReminderData.getEventNote(cms));
        resolver.addMacro("event.type", eventReminderData.getEventType(cms));
        resolver.addMacro("event.time", eventReminderData.getEventTime(cms));
        resolver.addMacro("reminder.interval", eventReminderData.getReminderInterval(cms));
        resolver.addMacro("reminder.note", eventReminderData.getReminderNote(cms));
        for (Entry<String, String> field : formDataBean.getData().entrySet()) {
            CmsFormDataField formDataField = new CmsFormDataField(field.getKey(), field.getValue());
            resolver.addMacro(formDataField.getLabel(), formDataField.getValue());
        }
        return resolver;
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
        q.addFilterQuery(
            CmsSearchField.FIELD_INSTANCEDATE_CURRENT_TILL
                + "_"
                + cms.getRequestContext().getLocale()
                + "_dt:"
                + dateRestriction.getRange());
        q.addFilterQuery(FIELD_BOOKING_REMINDER + "_" + cms.getRequestContext().getLocale() + "_b:true");
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
     * Returns a offline CMS.
     * @param cms The job's CMS object
     * @return the offline CMS
     */
    private CmsObject getOfflineCms(CmsObject cms) {

        CmsObject offlineCms = null;
        try {
            offlineCms = OpenCms.initCmsObject(cms);
            offlineCms.getRequestContext().setSiteRoot(cms.getRequestContext().getSiteRoot());
            offlineCms.getRequestContext().setCurrentProject(offlineCms.readProject("Offline"));
        } catch (CmsException e) {
            LOG.error(e.getLocalizedMessage(), e);
        }
        return offlineCms;
    }

    /**
     * Returns a subsite CMS useful to read sitemap attributes.
     * @param cms the CMS to clone
     * @param eventContent the
     * @return the subsite CMS object
     */
    private CmsObject getSubsiteCms(CmsObject cms, CmsFile eventContent) {

        CmsObject subsiteCms = null;
        String siteRoot = OpenCms.getSiteManager().getSiteRoot(eventContent.getRootPath());
        try {
            subsiteCms = OpenCms.initCmsObject(cms);
            subsiteCms.getRequestContext().setSiteRoot(siteRoot);
            String sitePath = subsiteCms.getRequestContext().removeSiteRoot(eventContent.getRootPath());
            subsiteCms.getRequestContext().setUri(sitePath);
        } catch (CmsException e) {
            LOG.error(e.getLocalizedMessage(), e);
        }
        return subsiteCms;
    }

    /**
     * Sends reminder mails to all registered users of an event.
     * @param eventReminderData the event with a reminder mail configured
     * @param cms the CMS context
     */
    private void sendReminderMails(EventReminderData eventReminderData, CmsObject cms) {

        for (CmsFormDataBean formDataBean : eventReminderData.getRegisteredUsers(cms)) {
            if (!formDataBean.isReminderMailSent()) {
                boolean successfullySent = sendReminderMailUser(eventReminderData, formDataBean, cms);
                if (successfullySent) {
                    CmsFile file = formDataBean.getFile();
                    if (file != null) {
                        CmsObject offlineCms = getOfflineCms(cms);
                        boolean locked = A_CmsFormDataHandler.lockResource(offlineCms, file);
                        if (!locked) {
                            LOG.warn("Could not lock resource " + file.getRootPath());
                            continue;
                        }
                        CmsXmlContent content = A_CmsFormDataHandler.readContent(offlineCms, file);
                        if (content == null) {
                            LOG.error("Could not read content for " + file.getRootPath());
                            continue;
                        }
                        boolean updated = A_CmsFormDataHandler.updateContent(
                            offlineCms,
                            content,
                            CmsFormDataBean.PATH_REMINDER_MAIL_SENT,
                            "true");
                        if (!updated) {
                            LOG.error("Could not update content " + file.getRootPath());
                            // anyway continue to publish
                        }
                        boolean published = A_CmsFormDataHandler.publishResource(
                            offlineCms,
                            offlineCms.getSitePath(file));
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
     * @param cms the CMS context
     * @return whether the reminder mail was successfully sent
     */
    private boolean sendReminderMailUser(
        EventReminderData eventReminderData,
        CmsFormDataBean formDataBean,
        CmsObject cms) {

        try {
            CmsMacroResolver resolver = createMacroResolver(eventReminderData, formDataBean, cms);
            CmsHtmlMail mail = new CmsHtmlMail();
            mail.setCharset(cms.getRequestContext().getEncoding());
            String mailFromName = eventReminderData.getMailFromName(cms);
            String mailFrom = eventReminderData.getMailFrom(cms);
            String mailReplyTo = eventReminderData.getMailReplyTo(cms);
            CmsObject subsiteCms = getSubsiteCms(cms, eventReminderData.getFile());
            if (CmsFormMailSettings.getInstance().useDkimMailHost(subsiteCms, eventReminderData.getFile())) {
                if (CmsStringUtil.isEmptyOrWhitespaceOnly(mailReplyTo)) {
                    mailReplyTo = mailFrom;
                }
                String dkimMailFrom = CmsFormMailSettings.getInstance().getAttributeDkimMailFrom(subsiteCms);
                if (dkimMailFrom.equals(A_CmsDkimMailSettings.SITEMAP_ATTRVALUE_DKIM_MAILFROM_DEFAULT)) {
                    mailFrom = ""; // use the sender address configured in opencms-system.xml
                } else {
                    mailFrom = dkimMailFrom;
                }
            }
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFrom)) {
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromName)) {
                    mail.setFrom(mailFrom, mailFromName);
                } else {
                    mail.setFrom(mailFrom);
                }
            }
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailReplyTo)) {
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromName)) {
                    mail.addReplyTo(mailReplyTo, mailFromName);
                } else {
                    mail.addReplyTo(mailReplyTo);
                }
            }
            String mailTo = eventReminderData.getMailTo(formDataBean, cms);
            mail.addTo(mailTo);
            String subject = eventReminderData.getMailSubjectUser(cms);
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(subject)) {
                subject = resolver.resolveMacros(subject);
            }
            mail.setSubject(subject);
            String text = eventReminderData.getMailTextUser(cms);
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(text)) {
                text = resolver.resolveMacros(text);
            }
            mail.setHtmlMsg(text);
            mail.send();
            return true;
        } catch (EmailException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
    }
}
