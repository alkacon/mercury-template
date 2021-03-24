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
import org.opencms.file.CmsGroup;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsUser;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.CmsUUID;
import org.opencms.xml.I_CmsXmlDocument;

import java.util.Locale;
import java.util.Map;

import org.apache.commons.logging.Log;

import com.google.common.base.Objects;
import com.google.common.base.Optional;

/** UGC configuration reader for the webform content. */
public class CmsFormUgcConfigurationReader {

    /** XML content value name. */
    public static final String N_CONTENT_PATH = "ContentPath";

    /** XML content value name. */
    public static final String N_DB_CONFIG = "DBConfig";

    /** XML content value name. */
    public static final String N_MAX_REGULAR_DATASETS = "MaxRegularDatasets";

    /** XML content value name. */
    public static final String N_NUM_OTHER_DATASETS = "NumOtherDatasets";

    /** XML content value name. */
    public static final String N_NUM_WAITLIST_DATASETS = "MaxWaitlistDatasets";

    /** XML content value name. */
    public static final String N_PROJECT_GROUP = "ProjectGroup";

    /** XML content value name. */
    public static final String N_USER_FOR_GUEST = "UserForGuest";

    /** Prefix for the data folder. */
    private static final String DATA_FOLDER_PREFIX = "data_";

    /** Special value for the project group. If set, the whole UGC configuration is ignored. */
    private static final String IGNORE_CONFIG_SPECIALCONTENTFOLDER = "none";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormUgcConfigurationReader.class);

    /** XML content value name. */
    private static final String N_DATASET_TITLE = "DatasetTitle";

    /** Node name for the node containing the number of days to keep the form data after the event. */
    private static final String N_KEEP_DAYS = "KeepDays";

    /** The Admin CMS context used by this configuration reader. */
    private CmsObject m_adminCms;

    /** The CMS context used by this configuration reader. */
    private CmsObject m_cms;

    /** The XML content from which the configuration is read. */
    private I_CmsXmlDocument m_content;

    /** The site path to the content folder. */
    private String m_contentFolderRootPath;

    /** The file containing the configuration form. */
    private CmsFile m_file;

    /** Parser for form configurations. */
    private CmsFormConfigParser m_formConfigParser;

    /** The locale to read the content in. */
    private Locale m_locale;

    /**
     * @param cms the current context
     * @param formConfig the form configuration XML
     * @param configLocale the locale to read the configuration in
     * @param dynamicConfig dynamic configuration for the form to overwrite form configuration values.
     * @return the UGC configuration read from the form config
     * @throws Exception thrown if reading the configuration fails.
     */
    public CmsFormUgcConfiguration readConfiguration(
        CmsObject cms,
        I_CmsXmlDocument formConfig,
        Locale configLocale,
        Map<String, String> dynamicConfig)
    throws Exception {

        if (formConfig == null) {
            return null;
        }
        m_cms = cms;
        m_adminCms = CmsWebformModuleAction.getAdminCms(m_cms);
        m_content = formConfig;
        m_file = formConfig.getFile();
        m_locale = null == configLocale
        ? OpenCms.getLocaleManager().getBestMatchingLocale(
            cms.getRequestContext().getLocale(),
            OpenCms.getLocaleManager().getDefaultLocales(cms, cms.getRequestContext().getUri()),
            m_content.getLocales())
        : configLocale;
        m_formConfigParser = new CmsFormConfigParser(cms, formConfig, m_locale, null, dynamicConfig);
        if (isUgcConfigured()) {
            String pathPrefix = N_DB_CONFIG + "/";
            String contentFolderRootPath = m_formConfigParser.getConfigurationValue(pathPrefix + N_CONTENT_PATH, null);
            if (isIgnoreUgcConfiguration(contentFolderRootPath)) {
                return null;
            }
            Optional<Integer> maxRegularDataSets = getIntValue(pathPrefix + N_MAX_REGULAR_DATASETS);
            Optional<Integer> numOtherDataSets = getIntValue(pathPrefix + N_NUM_OTHER_DATASETS);
            Optional<Integer> maxWaitlistDataSets = getIntValue(pathPrefix + N_NUM_WAITLIST_DATASETS);
            String userForGuestStr = m_formConfigParser.getConfigurationValue(pathPrefix + N_USER_FOR_GUEST, null);
            Optional<CmsUser> userForGuest = Optional.absent();
            String projectGroupStr = m_formConfigParser.getConfigurationValue(pathPrefix + N_PROJECT_GROUP, null);
            if (userForGuestStr != null) {
                userForGuest = Optional.of(m_adminCms.readUser(userForGuestStr.trim()));
            }

            m_contentFolderRootPath = null == contentFolderRootPath
            ? getDefaultContentFolderRootPath()
            : contentFolderRootPath;

            CmsGroup projectGroup = null;
            if (null != projectGroupStr) {
                try {
                    projectGroup = m_adminCms.readGroup(projectGroupStr.trim());
                } catch (Throwable t) {
                    LOG.warn(
                        "Failed to read project group \"" + projectGroupStr + "\" Using default project group.",
                        t);
                }
            }
            String datasetTitle = m_formConfigParser.getConfigurationValue(pathPrefix + N_DATASET_TITLE, "");
            CmsUUID id = m_content.getFile().getStructureId();

            String keepDaysStr = m_formConfigParser.getResolvedConfigurationValue(pathPrefix + N_KEEP_DAYS, null);
            Integer keepDays = null;
            if (keepDaysStr != null) {
                try {
                    keepDays = Integer.valueOf(keepDaysStr);
                } catch (NumberFormatException e) {
                    LOG.info(e.getLocalizedMessage(), e);
                }
            }

            CmsFormUgcConfiguration result = new CmsFormUgcConfiguration(
                id,
                userForGuest,
                null != projectGroup
                ? projectGroup
                : m_adminCms.readGroup(OpenCms.getDefaultUsers().getGroupAdministrators()),
                m_contentFolderRootPath,
                maxRegularDataSets,
                numOtherDataSets,
                maxWaitlistDataSets,
                datasetTitle,
                keepDays,
                null != projectGroup);
            result.setPath(m_content.getFile().getRootPath());
            return result;
        } else {
            return null;
        }
    }

    /**
     * Reads the UGC configuration from a form configuration.
     * @param cmsObject the CmsObject used for reading.
     * @param formConfig the form configuration containing the UGC configuration.
     * @param dynamicConfig dynamic configuration for the form to overwrite form configuration values.
     * @return the UGC configuration for the form.
     * @throws Exception thrown if reading fails.
     */
    public CmsFormUgcConfiguration readConfiguration(
        CmsObject cmsObject,
        I_CmsXmlDocument formConfig,
        Map<String, String> dynamicConfig)
    throws Exception {

        return readConfiguration(cmsObject, formConfig, null, dynamicConfig);

    }

    /**
     * Returns the root path of the folder where the submission data is stored.
     * @return the root path of the folder where the submission data is stored.
     */
    private String getDefaultContentFolderRootPath() {

        return CmsStringUtil.joinPaths(
            CmsResource.getFolderPath(m_file.getRootPath()),
            DATA_FOLDER_PREFIX + m_file.getName());
    }

    /**
     * Parses an optional integer value.<p>
     *
     * @param path the xpath of the content field (without prefix)
     * @return the optional integer value in that field
     */
    private Optional<Integer> getIntValue(String path) {

        String stringValue = m_formConfigParser.getConfigurationValue(path, null);
        if (stringValue == null) {
            return Optional.absent();
        } else {
            try {
                return Optional.<Integer> of(Integer.valueOf(stringValue.trim()));
            } catch (NumberFormatException e) {
                throw new NumberFormatException("Could not read a number from " + path + " ,value= " + stringValue);
            }
        }
    }

    /**
     * Returns true, iff the ugc configuration should be ignored, which is the case if the content folder has the special value "none".
     * @param contentFolderRootPath the content folder, read wrt the dynamic configuration.
     * @return true, iff the ugc configuration should be ignored.
     */
    private boolean isIgnoreUgcConfiguration(String contentFolderRootPath) {

        return Objects.equal(contentFolderRootPath, IGNORE_CONFIG_SPECIALCONTENTFOLDER);
    }

    /**
     * Returns a flag, indicating if UGC is configured at all.
     * @return a flag, indicating if UGC is configured at all.
     */
    private boolean isUgcConfigured() {

        return null != m_content.getValue(N_DB_CONFIG, m_locale);
    }
}
