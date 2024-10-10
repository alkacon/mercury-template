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

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResourceFilter;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.CmsDatePastFutureRestriction;
import org.opencms.jsp.search.config.parser.simplesearch.daterestrictions.I_CmsDateRestriction.TimeDirection;
import org.opencms.mail.CmsHtmlMail;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.scheduler.I_CmsScheduledJob;
import org.opencms.search.CmsSearchResource;
import org.opencms.search.fields.CmsSearchField;
import org.opencms.search.solr.CmsSolrIndex;
import org.opencms.search.solr.CmsSolrQuery;
import org.opencms.search.solr.CmsSolrResultList;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

/**
 * Job that reminds users of a booked event that is about to start.
 * Configure this job in a way that it does not run more than once per day.
 */
public class CmsBookingReminderJob implements I_CmsScheduledJob {

    /**
     * Class representing a Mercury event along with the booking form
     * and the form data of all registered users.
     */
    public static class ReminderEvent {

        /** The Mercury event as a SOLR search resource */
        private final CmsSearchResource m_searchResource;

        /** The booking form. */
        private CmsForm m_bookingForm;

        /** Form data of all registered users. */
        private List<CmsFormDataBean> m_registeredUsers = new ArrayList<CmsFormDataBean>();

        /**
         * Creates a new event bean for a given search resource.
         * @param searchResource the search resource
         */
        public ReminderEvent(CmsSearchResource searchResource) {

            m_searchResource = searchResource;
        }

        /**
         * Returns the form data beans for all registered users.
         * @return the form data beans for all registered users
         */
        public List<CmsFormDataBean> getRegisteredUsers() {

            return m_registeredUsers;
        }

        /**
         * Returns the search resource
         * @return the search resource
         */
        public CmsSearchResource getSearchResource() {

            return m_searchResource;
        }

        /**
         * Returns whether the remainder day is reached.
         * @return whether the remainder day is reached
         */
        public boolean isReminderDayReached() {

            return true;
        }
    }

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsBookingReminderJob.class);

    /** The event type. */
    private static final String EVENT_TYPE = "m-event";

    /** The search locale to generate the future events SOLR filter. */
    private static final Locale SEARCH_LOCALE = new Locale("de"); // TODO: how to handle locale

    /**
     * @see org.opencms.scheduler.I_CmsScheduledJob#launch(org.opencms.file.CmsObject, java.util.Map)
     */
    public String launch(CmsObject cms, Map<String, String> parameters) throws Exception {

        List<ReminderEvent> events = findAllFutureEventsWithReminderMail();
        if (events != null) {
            for (ReminderEvent event : events) {
                LOG.error(
                    "Future event found with reminder mail configured: "
                        + event.getSearchResource().getField("Title_prop"));
                if (event.isReminderDayReached()) {
                    sendReminderMails(event);
                }
            }
            return "OK";
        } else {
            return "ERROR";
        }
    }

    /**
     * Returns all future events with a reminder mail enabled.
     * @return all future events with a reminder mail enabled
     */
    private List<ReminderEvent> findAllFutureEventsWithReminderMail() {

        final int numRows = 1000000;
        CmsSolrIndex solrIndex = OpenCms.getSearchManager().getIndexSolr(CmsSolrIndex.DEFAULT_INDEX_NAME_ONLINE);
        CmsSolrQuery q = new CmsSolrQuery();
        q.addFilterQuery("type:" + EVENT_TYPE);
        String dateField = CmsSearchField.FIELD_INSTANCEDATE_CURRENT_TILL + "_" + SEARCH_LOCALE.toString() + "_dt";
        CmsDatePastFutureRestriction dateRestriction = new CmsDatePastFutureRestriction(TimeDirection.future);
        q.addFilterQuery(dateField + ":" + dateRestriction.getRange());
        String reminderField = "booking-reminder_" + SEARCH_LOCALE.toString() + "_b";
        q.addFilterQuery(reminderField + ":true");
        q.setFields("Title_prop");
        q.setRows(Integer.valueOf(numRows));
        try {
            CmsObject cms = CmsWebformModuleAction.getAdminCms(null);
            CmsSolrResultList result = solrIndex.search(cms, q, true, null, true, CmsResourceFilter.DEFAULT, numRows);
            return result.stream().map(searchResource -> new ReminderEvent(searchResource)).collect(
                Collectors.toList());
        } catch (CmsException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return null;
        }
    }

    /**
     * Sends a reminder mail to one registered user.
     * @param reminderEvent the reminder event
     * @param formDataBean the form data of the registered user
     * @return whether the reminder mail was successfully sent
     */
    private boolean sendReminderMail(ReminderEvent reminderEvent, CmsFormDataBean formDataBean) {

        try {
            CmsHtmlMail mail = new CmsHtmlMail();
            mail.setSubject("Reminder");
            mail.setHtmlMsg("<div>Reminder</div>");
            mail.setTextMsg("Reminder");
            mail.addTo("reminder@alkacon.com");
            mail.send();
            return true;
        } catch (EmailException e) {
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
    }

    /**
     * Sends reminder mails to all registered users of an event.
     * @param reminderEvent the event with a reminder mail configured
     */
    private void sendReminderMails(ReminderEvent reminderEvent) {

        for (CmsFormDataBean registeredUser : reminderEvent.getRegisteredUsers()) {
            boolean successfullySent = sendReminderMail(reminderEvent, registeredUser);
            if (successfullySent) {
                // TODO: save that the user did receive the reminder mail
            }
        }
    }
}
