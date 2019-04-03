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

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.i18n.CmsMessages;
import org.opencms.jsp.util.A_CmsJspCustomContextBean;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.xml.I_CmsXmlDocument;
import org.opencms.xml.content.CmsXmlContentFactory;

import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.logging.Log;

/**
 * Helper class to export form data as CSV file that can be opened with Excel and LibreOffice correctly.
 * Unfortunately, Encoding is difficult, but it seems that Excel (at least the German version from 2013 and 365)
 * opens csv files correctly if:
 * <ul>
 *   <li>separator is not the number separator (ie. ";" instead of ",")</li>
 *   <li>files are UTF-8 encoded WITH BOM</li>
 *   <li>all values are escaped by double quotes</li>
 *   <li>line breaks are only "\n".</li>
 * </ul>
 */
public class CmsCsvExportBean extends A_CmsJspCustomContextBean {

    /** Helper to produce Csv files. */
    public static class CsvWriter {

        /** The "bom" bytes as String that need to be placed at the very beginning of the produced csv. */
        private static final String BOM = "\ufeff";

        /** Internal variable holding the CSV content. */
        StringBuffer m_csv = new StringBuffer(BOM);

        /**
         * Adds a line to the CSV.
         * @param values the (unescaped) values to add.
         */
        public void addLine(String... values) {

            if (null != values) {
                if (values.length > 0) {
                    m_csv.append(esc(values[0]));
                }
                for (int i = 1; i < values.length; i++) {
                    m_csv.append(sep()).append(esc(values[i]));
                }
            }
            m_csv.append(nl());
        }

        /**
         * @see java.lang.Object#toString()
         */
        @Override
        public String toString() {

            return m_csv.toString();
        }

        /**
         * Escapes the provided value for CSV.
         * @param value the value to escape
         * @return the escaped value.
         */
        private String esc(String value) {

            value = value.replace("\"", "\"\"");
            return '"' + value + '"';
        }

        /**
         * Returns a line break as to use in the CSV output.
         * @return a line break as to use in the CSV output.
         */
        private String nl() {

            return "\n";
        }

        /**
         * Returns the value separator to use in the CSV output.
         * @return the value separator to use in the CSV output.
         */
        private String sep() {

            return ";";
        }

    }

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCsvExportBean.class);
    /** Constant for message key. */
    private static final String KEY_HEADLINE_1 = "msg.page.form.bookingstatus.headline.1";
    /** Constant for message key. */
    private static final String KEY_EXPORT_DATE_0 = "msg.page.form.bookingstatus.export.date";
    /** Constant for message key. */
    private static final String KEY_SUBMISSIONS_LABEL = "msg.page.form.bookingstatus.submissions.label";
    /** Constant for message key. */
    private static final String KEY_SUBMISSIONS_STATUS_3 = "msg.page.form.bookingstatus.submissions.status.3";
    /** Constant for message key. */
    private static final String KEY_PLACES_LABEL = "msg.page.form.bookingstatus.places.label";
    /** Constant for message key. */
    private static final String KEY_PLACES_LABEL_UNLIMITED = "msg.page.form.bookingstatus.places.unlimited";
    /** Constant for message key. */
    private static final String KEY_MAXSUBMISSIONS_NOWAITLIST_1 = "msg.page.form.bookingstatus.maxsubmission.nowaitlist.1";
    /** Constant for message key. */
    private static final String KEY_MAXSUBMISSIONS_WAITLIST_2 = "msg.page.form.bookingstatus.maxsubmission.waitlist.2";
    /** Constant for message key. */
    private static final String KEY_FREEPLACES_LABEL = "msg.page.form.bookingstatus.freeplaces.label";
    /** Constant for message key. */
    private static final String KEY_FULLYBOOKED = "msg.page.form.bookingstatus.fullybooked";
    /** Constant for message key. */
    private static final String KEY_ONLYWAITLIST_1 = "msg.page.form.bookingstatus.onlywaitlist.1";
    /** Constant for message key. */
    private static final String KEY_REMAININGSUBMISSIONS_NOWAITLIST_1 = "msg.page.form.bookingstatus.remainingsubmissions.nowaitlist.1";
    /** Constant for message key. */
    private static final String KEY_REMAININGSUBMISSIONS_WAITLIST_2 = "msg.page.form.bookingstatus.remainingsubmissions.waitlist.2";
    /** Constant for message key. */
    private static final String KEY_SUBMISSIONDATA_HEADLINE = "msg.page.form.bookingstatus.submissiondata.heading";
    /** Constant for message key. */
    private static final String KEY_STATUS_CANCELLED = "msg.page.form.status.submission.cancelled";
    /** Constant for message key. */
    private static final String KEY_STATUS_WAITLIST = "msg.page.form.status.submission.waitlist";
    /** Constant for message key. */
    private static final String KEY_STATUS_CONFIRMED = "msg.page.form.status.submission.confirmed";
    /** Constant for message key. */
    //private static final String KEY_STATUS_MAILED = "msg.page.form.status.submission.mailed";
    /** Constant for message key. */
    private static final String KEY_STATUS_CHANGED = "msg.page.form.status.submission.changed";
    /** The bundle with the localization keys. */
    private static final String BUNDLE_NAME = "alkacon.mercury.template.messages";

    /** The form to export submissions for. */
    private CmsFormBean m_form;
    /** The form's title. */
    private String m_formTitle;
    /** The message bundle to get the localizations from - already open for the correct locale. */
    private CmsMessages m_messages;

    /**
     * Produces the CSV export for data submitted by a form.
     * @return the CSV export data.
     */
    public String export() {

        CmsObject cms = getCmsObject();
        // Start with BOM
        CsvWriter csv = new CsvWriter();

        CmsSubmissionStatus status = m_form.getSubmissionStatus();

        // Add meta data
        csv.addLine(m_messages.key(KEY_HEADLINE_1, m_formTitle));
        csv.addLine();
        csv.addLine(m_messages.key(KEY_EXPORT_DATE_0), m_messages.getDateTime(new Date(), DateFormat.LONG));
        csv.addLine();
        csv.addLine(
            m_messages.key(KEY_SUBMISSIONS_LABEL),
            m_messages.key(
                KEY_SUBMISSIONS_STATUS_3,
                Integer.valueOf(status.getNumTotalSubmissions()),
                Integer.valueOf(status.getNumFormSubmissions()),
                Integer.valueOf(status.getNumOtherSubmissions())));
        csv.addLine(
            m_messages.key(KEY_PLACES_LABEL),
            null == status.getMaxRegularSubmissions()
            ? m_messages.key(m_messages.key(KEY_PLACES_LABEL_UNLIMITED))
            : status.getMaxWaitlistSubmissions() == 0
            ? m_messages.key(KEY_MAXSUBMISSIONS_NOWAITLIST_1, status.getMaxRegularSubmissions())
            : m_messages.key(
                KEY_MAXSUBMISSIONS_WAITLIST_2,
                status.getMaxRegularSubmissions(),
                Integer.valueOf(status.getMaxWaitlistSubmissions())));
        csv.addLine(
            m_messages.key(KEY_FREEPLACES_LABEL),
            status.isFullyBooked()
            ? m_messages.key(KEY_FULLYBOOKED)
            : status.isOnlyWaitlist()
            ? m_messages.key(KEY_ONLYWAITLIST_1, Integer.valueOf(status.getNumRemainingWaitlistSubmissions()))
            : status.getMaxWaitlistSubmissions() == 0
            ? m_messages.key(KEY_REMAININGSUBMISSIONS_NOWAITLIST_1, status.getNumRemainingRegularSubmissions())
            : m_messages.key(
                KEY_REMAININGSUBMISSIONS_WAITLIST_2,
                status.getNumRemainingRegularSubmissions(),
                Integer.valueOf(status.getNumRemainingWaitlistSubmissions())));
        csv.addLine();
        csv.addLine(m_messages.key(KEY_SUBMISSIONDATA_HEADLINE));
        csv.addLine();

        boolean first = true;
        for (CmsResource submission : m_form.getSubmissions()) {
            try {
                I_CmsXmlDocument formDataXml;
                formDataXml = CmsXmlContentFactory.unmarshal(cms, cms.readFile(submission));
                CmsFormDataBean formData = new CmsFormDataBean(formDataXml);
                if (first) {
                    csv.addLine(getHeadline(formData));
                    csv.addLine();
                    first = false;
                }
                csv.addLine(getData(formData));
            } catch (CmsException e) {
                LOG.warn(
                    "Failed to read submission data from "
                        + submission.getRootPath()
                        + " when exporting the data as CSV.",
                    e);
                csv.addLine("??? " + submission.getRootPath() + "???");
            }
        }
        return csv.toString();
    }

    /**
     * Initialize the export bean.
     * @param form the form to export data for.
     * @param formTitle the form title to print in the export.
     * @param locale the locale to export the data in.
     */
    public void init(CmsFormBean form, String formTitle, Locale locale) {

        m_form = form;
        m_formTitle = formTitle;
        m_messages = new CmsMessages(BUNDLE_NAME, locale);
    }

    /**
     * Generates the String value to put in the CSV instead of the boolean value provided.
     * @param b the value to convert to a String.
     * @return the value as it is printed in the CSV output.
     */
    String asString(boolean b) {

        return b ? "X" : "";
    }

    /**
     * Returns the submission data as String array with the values for one line in the CSV output.
     * @param formData the submission data as bean.
     * @return the submission data as String array with the values for one line in the CSV output.
     */
    String[] getData(CmsFormDataBean formData) {

        Map<String, String> data = formData.getData();
        String[] result = new String[data.keySet().size() + 5];
        int i = 0;
        for (String field : data.keySet()) {
            result[i++] = data.get(field);
        }
        result[i++] = "";
        result[i++] = asString(formData.isCancelled());
        result[i++] = asString(formData.isWaitlist());
        result[i++] = asString(formData.isConfirmationMailSent());
        result[i++] = asString(formData.isChanged());
        return result;
    }

    /**
     * Returns the headline for the submission with the separate CSV values for the line in a String array.
     * @param formData a sample submitted data.
     * @return the headline for the submission with the separate CSV values for the line in a String array.
     */
    String[] getHeadline(CmsFormDataBean formData) {

        Map<String, String> data = formData.getData();
        String[] result = new String[data.keySet().size() + 5];
        int i = 0;
        for (String field : formData.getData().keySet()) {
            result[i++] = field;
        }
        result[i++] = "";
        result[i++] = m_messages.key(KEY_STATUS_CANCELLED);
        result[i++] = m_messages.key(KEY_STATUS_WAITLIST);
        result[i++] = m_messages.key(KEY_STATUS_CONFIRMED);
        result[i++] = m_messages.key(KEY_STATUS_CHANGED);
        return result;
    }

}