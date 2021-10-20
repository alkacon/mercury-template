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

import alkacon.mercury.template.writer.A_CmsWriter;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.i18n.CmsMessages;
import org.opencms.jsp.util.A_CmsJspCustomContextBean;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;
import org.opencms.xml.I_CmsXmlDocument;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.text.DateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.logging.Log;

/**
 * Class representing an export bean for data submitted by a form.
 */
public abstract class A_CmsExportBean extends A_CmsJspCustomContextBean {

    /** Logger instance for this class. */
    private static final Log LOG = CmsLog.getLog(A_CmsExportBean.class);

    /** The bundle with the localization keys. */
    protected static final String BUNDLE_NAME = "alkacon.mercury.template.messages";

    /** Constant for message key. */
    protected static final String KEY_HEADLINE_1 = "msg.page.form.bookingstatus.headline.1";

    /** Constant for message key. */
    protected static final String KEY_EXPORT_DATE_0 = "msg.page.form.bookingstatus.export.date";

    /** Constant for message key. */
    protected static final String KEY_SUBMISSIONS_LABEL = "msg.page.form.bookingstatus.submissions.label";

    /** Constant for message key. */
    protected static final String KEY_SUBMISSIONS_STATUS_3 = "msg.page.form.bookingstatus.submissions.status.3";

    /** Constant for message key. */
    protected static final String KEY_PLACES_LABEL = "msg.page.form.bookingstatus.places.label";

    /** Constant for message key. */
    protected static final String KEY_PLACES_LABEL_UNLIMITED = "msg.page.form.bookingstatus.places.unlimited";

    /** Constant for message key. */
    protected static final String KEY_MAXSUBMISSIONS_NOWAITLIST_1 = "msg.page.form.bookingstatus.maxsubmission.nowaitlist.1";

    /** Constant for message key. */
    protected static final String KEY_MAXSUBMISSIONS_WAITLIST_2 = "msg.page.form.bookingstatus.maxsubmission.waitlist.2";

    /** Constant for message key. */
    protected static final String KEY_FREEPLACES_LABEL = "msg.page.form.bookingstatus.freeplaces.label";

    /** Constant for message key. */
    protected static final String KEY_FULLYBOOKED = "msg.page.form.bookingstatus.fullybooked";

    /** Constant for message key. */
    protected static final String KEY_ONLYWAITLIST_1 = "msg.page.form.bookingstatus.onlywaitlist.1";

    /** Constant for message key. */
    protected static final String KEY_REMAININGSUBMISSIONS_NOWAITLIST_1 = "msg.page.form.bookingstatus.remainingsubmissions.nowaitlist.1";

    /** Constant for message key. */
    protected static final String KEY_REMAININGSUBMISSIONS_WAITLIST_2 = "msg.page.form.bookingstatus.remainingsubmissions.waitlist.2";

    /** Constant for message key. */
    protected static final String KEY_SUBMISSIONDATA_HEADLINE = "msg.page.form.bookingstatus.submissiondata.heading";

    /** Constant for message key. */
    protected static final String KEY_STATUS_CANCELLED = "msg.page.form.status.submission.cancelled";

    /** Constant for message key. */
    protected static final String KEY_STATUS_WAITLIST = "msg.page.form.status.submission.waitlist";

    /** Constant for message key. */
    protected static final String KEY_STATUS_CONFIRMED = "msg.page.form.status.submission.confirmed";

    /** Constant for message key. */
    //protected static final String KEY_STATUS_MAILED = "msg.page.form.status.submission.mailed";

    /** Constant for message key. */
    protected static final String KEY_STATUS_CHANGED = "msg.page.form.status.submission.changed";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT = "DBExport";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_IGNORE_FIELD = "IgnoreField";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_IGNORE_INPUT_FIELD = "IgnoreInputField";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_IGNORE_DEPENDENT_FIELD = "IgnoreDependentField";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_IGNORE_FORMER_FIELD = "IgnoreFormerField";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_RENAME_FIELD = "RenameField";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_RENAME_FIELD_ORIG = "RenameFieldOrig";

    /** Configuration node name for the value. */
    public static final String NODE_EXPORT_RENAME_FIELD_NEW = "RenameFieldNew";

    /** List of fields to ignore during export. */
    private List<String> m_exportConfigFieldIgnore = new ArrayList<String>();

    /** List of fields to rename or merge during export. */
    private Map<String, String> m_exportConfigFieldRename = new HashMap<String, String>();

    /** The form to export submissions for. */
    protected CmsFormBean m_form;

    /** The form's title. */
    protected String m_formTitle;

    /** The message bundle to get the localizations from - already open for the correct locale. */
    protected CmsMessages m_messages;

    /**
     * Exports the submission data and returns the writer holding the data.
     * @return the writer
     */
    abstract public A_CmsWriter export();

    /**
     * Returns a safe export file name with no suffix.
     * @return the export file name
     */
    public String getSafeFileNameNoSuffix() {

        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        String formatted = formatter.format(now);
        String safeFileName = OpenCms.getResourceManager().getFileTranslator().translateResource(m_formTitle);
        return safeFileName + formatted;
    }

    /**
     * Initializes this export bean.
     * @param form the form to export data for.
     * @param formTitle the form title to print in the export.
     * @param locale the locale to export the data in.
     */
    public void init(CmsFormBean form, String formTitle, Locale locale) {

        m_form = form;
        m_formTitle = formTitle;
        m_messages = new CmsMessages(BUNDLE_NAME, locale);
        initExportConfigFieldIgnore(locale);
        initExportConfigFieldRename(locale);
    }

    /**
     * Generates the String value to put in the CSV instead of the boolean value provided.
     * @param b the value to convert to a String.
     * @return the value as it is printed in the CSV output.
     */
    protected String asString(boolean b) {

        return b ? "X" : "";
    }

    /**
     * Collects all actual and former data keys from a collection of stored form submissions and
     * transforms the collected data keys into a ordered map with the column names as the keys
     * of the map and the position as the value.
     * @param formDataBeans the form data beans
     * @return the column name / position map.
     */
    protected Map<String, Integer> collectColumnNames(List<CmsFormDataBean> formDataBeans) {

        Map<String, Integer> columnNames = new LinkedHashMap<String, Integer>();
        for (CmsFormDataBean formDataBean : formDataBeans) {
            for (String field : formDataBean.getData().keySet()) {
                if (m_exportConfigFieldIgnore.contains(field)) {
                    continue;
                }
                if (m_exportConfigFieldRename.containsKey(field)) {
                    field = m_exportConfigFieldRename.get(field);
                }
                if (!columnNames.containsKey(field)) {
                    columnNames.put(field, Integer.valueOf(columnNames.size()));
                }
            }
        }
        columnNames.put(m_messages.key(KEY_STATUS_CANCELLED), Integer.valueOf(columnNames.size()));
        columnNames.put(m_messages.key(KEY_STATUS_WAITLIST), Integer.valueOf(columnNames.size()));
        columnNames.put(m_messages.key(KEY_STATUS_CONFIRMED), Integer.valueOf(columnNames.size()));
        columnNames.put(m_messages.key(KEY_STATUS_CHANGED), Integer.valueOf(columnNames.size()));
        return columnNames;
    }

    /**
     * Reads all submissions, transforms the submissions according to given configurations
     * and writes the the transformed data to the export file writer.
     * @param writer the writer
     * @return the export file writer.
     */
    protected A_CmsWriter export(A_CmsWriter writer) {

        writeMetadata(writer);
        writeData(writer);
        return writer;
    }

    /**
     * Returns the data of one submission as a map. May include inactive former columns.
     * Filters fields to ignore. Renames and merges fields according to the export configuration.
     * @param formData the submission data as bean.
     * @return the submission data as map.
     */
    protected Map<String, String> getData(CmsFormDataBean formData) {

        Map<String, String> data = formData.getData();
        Iterator<Map.Entry<String, String>> iter = data.entrySet().iterator();
        Map<String, String> merged = new LinkedHashMap<String, String>();
        while (iter.hasNext()) {
            Map.Entry<String, String> entry = iter.next();
            String key = entry.getKey();
            String value = entry.getValue();
            if (m_exportConfigFieldIgnore.contains(key)) {
                continue;
            }
            if (m_exportConfigFieldRename.containsKey(key)) {
                key = m_exportConfigFieldRename.get(key);
            }
            if (merged.containsKey(key)) {
                String merge = merged.get(key);
                if (!CmsStringUtil.isEmptyOrWhitespaceOnly(value)) {
                    merge += " " + value;
                }
                merged.put(key, merge);
            } else {
                merged.put(key, value);
            }
        }
        merged.put(m_messages.key(KEY_STATUS_CANCELLED), asString(formData.isCancelled()));
        merged.put(m_messages.key(KEY_STATUS_WAITLIST), asString(formData.isWaitlist()));
        merged.put(m_messages.key(KEY_STATUS_CONFIRMED), asString(formData.isConfirmationMailSent()));
        merged.put(m_messages.key(KEY_STATUS_CHANGED), asString(formData.isChanged()));
        return merged;
    }

    /**
     * Reads all form submissions from the database and returns the data as a list of form data beans.
     * @return the list of form data beans
     */
    protected List<CmsFormDataBean> readFormDataBeans() {

        CmsObject cms = getCmsObject();
        List<CmsFormDataBean> formDataBeans = new ArrayList<CmsFormDataBean>();
        for (CmsResource submission : m_form.getSubmissions()) {
            try {
                I_CmsXmlDocument formDataXml;
                formDataXml = CmsXmlContentFactory.unmarshal(cms, cms.readFile(submission));
                CmsFormDataBean formDataBean = new CmsFormDataBean(formDataXml);
                formDataBeans.add(formDataBean);
            } catch (CmsException e) {
                LOG.warn(
                    "Failed to read submission data from " + submission.getRootPath() + " when exporting the data.",
                    e);
            }
        }
        return formDataBeans;
    }

    /**
     * Reads the ignore field export configuration from the form content.
     * @param locale the locale
     */
    private void initExportConfigFieldIgnore(Locale locale) {

        CmsObject cms = getCmsObject();
        if (m_form.getFormConfig().hasValue(NODE_EXPORT, locale)) {
            String pathPrefix = NODE_EXPORT + "/" + NODE_EXPORT_IGNORE_FIELD;
            if (m_form.getFormConfig().hasValue(pathPrefix, locale)) {
                String pathIgnoreInputField = pathPrefix + "/" + NODE_EXPORT_IGNORE_INPUT_FIELD;
                String pathIgnoreDependentField = pathPrefix + "/" + NODE_EXPORT_IGNORE_DEPENDENT_FIELD;
                String pathIgnoreFormerField = pathPrefix + "/" + NODE_EXPORT_IGNORE_FORMER_FIELD;
                List<I_CmsXmlContentValue> values = new ArrayList<I_CmsXmlContentValue>();
                values.addAll(m_form.getFormConfig().getValues(pathIgnoreInputField, locale));
                values.addAll(m_form.getFormConfig().getValues(pathIgnoreDependentField, locale));
                values.addAll(m_form.getFormConfig().getValues(pathIgnoreFormerField, locale));
                for (I_CmsXmlContentValue value : values) {
                    m_exportConfigFieldIgnore.add(value.getStringValue(cms));
                }
            }
        }
    }

    /**
     * Reads the rename field export configuration from the form content.
     * @param locale the locale
     */
    private void initExportConfigFieldRename(Locale locale) {

        CmsObject cms = getCmsObject();
        if (m_form.getFormConfig().hasValue(NODE_EXPORT, locale)) {
            String pathPrefix = NODE_EXPORT + "/" + NODE_EXPORT_RENAME_FIELD;
            int numRenameFields = m_form.getFormConfig().getIndexCount(pathPrefix, locale);
            for (int i = 1; i <= numRenameFields; i++) {
                String pathRenameFieldOrig = pathPrefix + "[" + i + "]/" + NODE_EXPORT_RENAME_FIELD_ORIG;
                String pathRenameFieldNew = pathPrefix + "[" + i + "]/" + NODE_EXPORT_RENAME_FIELD_NEW;
                String renameFieldOrig = m_form.getFormConfig().getValue(pathRenameFieldOrig, locale).getStringValue(
                    cms);
                String renameFieldNew = m_form.getFormConfig().getValue(pathRenameFieldNew, locale).getStringValue(cms);
                m_exportConfigFieldRename.put(renameFieldOrig, renameFieldNew);
            }
        }
    }

    /**
     * Writes the submission data to the export file writer.
     * @param writer the export file writer
     */
    private void writeData(A_CmsWriter writer) {

        List<CmsFormDataBean> formDataBeans = readFormDataBeans();
        Collections.reverse(formDataBeans);
        writer.addTable(collectColumnNames(formDataBeans));
        for (CmsFormDataBean formDataBean : formDataBeans) {
            writer.addTableRow(getData(formDataBean));
        }
    }

    /**
     * Writes the submission metadata to the export file writer.
     * @param writer the export file writer
     */
    private void writeMetadata(A_CmsWriter writer) {

        CmsSubmissionStatus status = m_form.getSubmissionStatus();
        writer.addRow(m_messages.key(KEY_HEADLINE_1, m_formTitle));
        writer.addRow();
        writer.addRow(m_messages.key(KEY_EXPORT_DATE_0), m_messages.getDateTime(new Date(), DateFormat.LONG));
        writer.addRow();
        writer.addRow(
            m_messages.key(KEY_SUBMISSIONS_LABEL),
            m_messages.key(
                KEY_SUBMISSIONS_STATUS_3,
                Integer.valueOf(status.getNumTotalSubmissions()),
                Integer.valueOf(status.getNumFormSubmissions()),
                Integer.valueOf(status.getNumOtherSubmissions())));
        writer.addRow(
            m_messages.key(KEY_PLACES_LABEL),
            null == status.getMaxRegularSubmissions()
            ? m_messages.key(m_messages.key(KEY_PLACES_LABEL_UNLIMITED))
            : status.getMaxWaitlistSubmissions() == 0
            ? m_messages.key(KEY_MAXSUBMISSIONS_NOWAITLIST_1, status.getMaxRegularSubmissions())
            : m_messages.key(
                KEY_MAXSUBMISSIONS_WAITLIST_2,
                status.getMaxRegularSubmissions(),
                Integer.valueOf(status.getMaxWaitlistSubmissions())));
        writer.addRow(
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
        writer.addRow();
        writer.addRow(m_messages.key(KEY_SUBMISSIONDATA_HEADLINE));
        writer.addRow();
    }
}
