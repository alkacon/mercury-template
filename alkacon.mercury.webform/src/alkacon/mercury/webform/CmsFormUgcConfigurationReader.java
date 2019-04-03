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

import alkacon.mercury.webform.CmsFormConfigParser;
import alkacon.mercury.webform.CmsFormUgcConfiguration;
import alkacon.mercury.webform.CmsFormUgcConfigurationReader;
import alkacon.mercury.webform.CmsWebformModuleAction;
import org.opencms.file.CmsFile;
import org.opencms.file.CmsGroup;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsProject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.CmsUser;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.lock.CmsLockUtil.LockedFile;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.report.CmsLogReport;
import org.opencms.security.CmsAccessControlEntry;
import org.opencms.security.CmsOrgUnitManager;
import org.opencms.security.CmsOrganizationalUnit;
import org.opencms.security.CmsPermissionSet;
import org.opencms.security.I_CmsPrincipal;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.CmsUUID;
import org.opencms.util.CmsVfsUtil;
import org.opencms.xml.I_CmsXmlDocument;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;

import com.google.common.base.Objects;
import com.google.common.base.Optional;

/** UGC configuration reader for the webform content. */
public class CmsFormUgcConfigurationReader {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormUgcConfigurationReader.class);

    /** XML content value name. */
    public static final String N_DB_CONFIG = "DBConfig";

    /** XML content value name. */
    public static final String N_MAX_REGULAR_DATASETS = "MaxRegularDatasets";

    /** XML content value name. */
    public static final String N_NUM_OTHER_DATASETS = "NumOtherDatasets";

    /** XML content value name. */
    public static final String N_NUM_WAITLIST_DATASETS = "MaxWaitlistDatasets";

    /** XML content value name. */
    public static final String N_USER_FOR_GUEST = "UserForGuest";

    /** XML content value name. */
    public static final String N_PROJECT_GROUP = "ProjectGroup";

    /** XML content value name. */
    public static final String N_CONTENT_PATH = "ContentPath";

    /** Prefix for the data folder. */
    private static final String DATA_FOLDER_PREFIX = "data_";

    /** XML content value name. */
    private static final String N_DATASET_TITLE = "DatasetTitle";

    /** Special value for the project group. If set, the whole UGC configuration is ignored. */
    private static final String IGNORE_CONFIG_SPECIALCONTENTFOLDER = "none";

    /** The CMS context used by this configuration reader. */
    private CmsObject m_cms;

    /** The Admin CMS context used by this configuration reader. */
    private CmsObject m_adminCms;

    /** The XML content from which the configuration is read. */
    private I_CmsXmlDocument m_content;

    /** The locale to read the content in. */
    private Locale m_locale;

    /** The file containing the configuration form. */
    private CmsFile m_file;

    /** Parser for form configurations. */
    private CmsFormConfigParser m_formConfigParser;

    /** The site path to the content folder. */
    private String m_contentFolderRootPath;

    /**
     * @param cms
     * @param formConfig
     * @param configLocale
     * @param dynamicConfig dynamic configuration for the form to overwrite form configuration values.
     * @return the UGC configuration read from the form config
     * @throws Exception
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
                userForGuest = Optional.of(m_cms.readUser(userForGuestStr.trim()));
            }

            m_contentFolderRootPath = null == contentFolderRootPath
            ? getDefaultContentFolderRootPath()
            : contentFolderRootPath;
            CmsGroup projectGroup = null == projectGroupStr
            ? getDefaultProjectGroup()
            : m_cms.readGroup(projectGroupStr.trim());
            CmsResource contentFolder = getPreparedContentFolder(projectGroup.getName());
            String datasetTitle = m_formConfigParser.getConfigurationValue(pathPrefix + N_DATASET_TITLE, "");
            CmsUUID id = m_content.getFile().getStructureId();
            CmsFormUgcConfiguration result = new CmsFormUgcConfiguration(
                id,
                userForGuest,
                projectGroup,
                contentFolder,
                maxRegularDataSets,
                numOtherDataSets,
                maxWaitlistDataSets,
                datasetTitle);
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
     * Determine the best fitting OU that contains the resource with the given path.
     *
     * "Best fitting" means the OU that contains the resource with the path,
     * but is not the parent OU of any other OU containing the path.
     *
     * @param parentRootPath the root path of the resource that must be contained in the OU.
     *
     * @return the best fitting OU for the provided path.
     * @throws CmsException
     */
    private CmsOrganizationalUnit getBestFittingOU(String parentRootPath) throws CmsException {

        CmsOrgUnitManager ouManager = OpenCms.getOrgUnitManager();
        Set<CmsOrganizationalUnit> ous = new HashSet<>();
        ous.add(ouManager.readOrganizationalUnit(m_adminCms, ""));
        ous.addAll(ouManager.getOrganizationalUnits(m_adminCms, "", true));
        Map<String, CmsOrganizationalUnit> fittingOUs = new HashMap<>();
        Set<String> parents = new HashSet<>();
        for (CmsOrganizationalUnit ou : ous) {
            List<CmsResource> ouRess = ouManager.getResourcesForOrganizationalUnit(m_adminCms, ou.getName());
            for (CmsResource ouRes : ouRess) {
                if (parentRootPath.startsWith(ouRes.getRootPath())) {
                    fittingOUs.put(ou.getName(), ou);
                    parents.add(ou.getParentFqn());
                    break;
                }
            }
        }
        for (String ouFqn : fittingOUs.keySet()) {
            if (!parents.contains(ouFqn)) {
                return fittingOUs.get(ouFqn);
            }
        }
        return null;
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
     * Returns the default project group to use for UGC and storing contents.
     * Use that method if no explicit group is given.
     *
     * The group is determined by first looking at the permissions on the folder where the
     * data sets are stored, if existing, and tries to determine the group from the set permissions.
     *
     * If the folder does not exist, the users group of the best fitting OU for the content folder is chosen.
     *
     * @return the default project group.
     */
    private CmsGroup getDefaultProjectGroup() {

        int requiredPermissions = CmsPermissionSet.PERMISSION_READ
            | CmsPermissionSet.PERMISSION_WRITE
            | CmsPermissionSet.PERMISSION_DIRECT_PUBLISH;
        if (m_adminCms.existsResource(m_contentFolderRootPath)) {
            try {
                List<CmsAccessControlEntry> accs = m_adminCms.getAccessControlEntries(m_contentFolderRootPath, false);

                for (CmsAccessControlEntry acc : accs) {
                    int allowedPermissions = acc.getAllowedPermissions();
                    if ((allowedPermissions & requiredPermissions) == requiredPermissions) {
                        try {
                            CmsGroup group = m_adminCms.readGroup(acc.getPrincipal());
                            return group;
                        } catch (CmsException e) {
                            // do nothing, probably the principal was a user, not a group.
                        }
                    }
                }
            } catch (Exception e) {
                LOG.error(
                    "Cannot determine default project group for the weform. Failed to read permission sets for folder: \""
                        + m_contentFolderRootPath
                        + "\". Make sure +r+w+d permissions are set for a group at the folder.");
            }
        } else {
            try {
                CmsOrganizationalUnit ou = getBestFittingOU(m_contentFolderRootPath);
                if (ou != null) {
                    return m_adminCms.readGroup(ou.getName() + OpenCms.getDefaultUsers().getGroupUsers());
                } else {
                    LOG.error(
                        "Could not deterime best fitting organizational unit for the webform that should store content in \""
                            + m_contentFolderRootPath
                            + "\".");
                }

            } catch (CmsException e) {
                LOG.error(
                    "Could not deterime best project group for the webform that should store content in \""
                        + m_contentFolderRootPath
                        + "\".",
                    e);
            }
        }
        return null;
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
     * Prepares the content folder and returns the prepared resource.
     *
     * @param groupName the name of the group for which allowed permissions should be set.
     * @return The prepared content folder
     * @throws Exception thrown if setting permissions or publishing fails.
     */
    private CmsResource getPreparedContentFolder(String groupName) throws Exception {

        CmsResource contentFolder = null;
        try {
            m_adminCms.getRequestContext().setCurrentProject(m_cms.getRequestContext().getCurrentProject());
            contentFolder = m_adminCms.readResource(m_contentFolderRootPath, CmsResourceFilter.ALL);
        } catch (CmsException e) {
            CmsVfsUtil.createFolder(m_adminCms, m_contentFolderRootPath);
            contentFolder = m_adminCms.readResource(m_contentFolderRootPath, CmsResourceFilter.ALL);
            try (LockedFile lockedRes = LockedFile.lockResource(m_adminCms, contentFolder)) {
                m_adminCms.chacc(
                    contentFolder.getRootPath(),
                    null,
                    CmsAccessControlEntry.PRINCIPAL_OVERWRITE_ALL_NAME,
                    "");
                m_adminCms.chacc(
                    contentFolder.getRootPath(),
                    I_CmsPrincipal.PRINCIPAL_GROUP,
                    groupName,
                    "+r+w+v+c+d+i+o");
                contentFolder = m_adminCms.readResource(contentFolder.getStructureId());
            }
            if (!contentFolder.getState().isUnchanged()) {
                OpenCms.getPublishManager().publishResource(
                    m_adminCms,
                    contentFolder.getRootPath(),
                    false,
                    new CmsLogReport(CmsLocaleManager.MASTER_LOCALE, this.getClass()));
            }
        } finally {
            m_adminCms.getRequestContext().setCurrentProject(m_adminCms.readProject(CmsProject.ONLINE_PROJECT_ID));
        }
        return contentFolder;

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
