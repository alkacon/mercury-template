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

import org.opencms.file.CmsGroup;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsProject;
import org.opencms.file.CmsProperty;
import org.opencms.file.CmsPropertyDefinition;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.CmsUser;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.lock.CmsLockUtil.LockedFile;
import org.opencms.main.CmsException;
import org.opencms.security.CmsAccessControlEntry;
import org.opencms.security.I_CmsPrincipal;
import org.opencms.ugc.CmsUgcConfiguration;
import org.opencms.util.CmsUUID;
import org.opencms.util.CmsVfsUtil;

import java.util.Collections;
import java.util.List;

import com.google.common.base.Optional;

/** Extension of {@link CmsUgcConfiguration} that is fitted for the webform module.
 * It allows for easier construction and saves some more configuration values concerning the waitlist.
 */
public class CmsFormUgcConfiguration extends CmsUgcConfiguration {

    /** The resource type for db entry XML contents. */
    public static final String CONTENT_TYPE_FORM_DATA = "m-webform-data";

    /** The name pattern to use for form data contents. */
    public static final String DEFAULT_NAME_PATTERN = "formdata_%(number).xml";

    /** The title property for datasets which can contain macros for form fields. */
    private String m_datasetTitle;
    /** Number of days to keep the form data - if null, keep indefinitely. */
    private Integer m_keepDays;
    /** The maximally allowed submissions without waitlist. */
    private Integer m_maxRegularDataSets;
    /** The maximal number of additional data sets accepted on a waitlist. */
    private int m_maxWaitlistDataSets;

    /** The number of submissions added otherwise (i.e., where the submitted data is stored differently). */
    private int m_numOtherDataSets;

    /** The root path to the folder of the XML contents. */
    private String m_contentFolderRootPath;

    /** The resource of the content parent folder. */
    private CmsResource m_contentParentFolder;

    /** Flag, indicating if permissions for the folder should be set. */
    private boolean m_setFolderPermissions;

    /**
     * Creates a new form configuration.
     *
     * @param id the id for the form configuration
     * @param userForGuests the user to use for VFS operations caused by guests who submit the XML content form
     * @param projectGroup the group to be used as the manager group for projects based on this configuration
     * @param contentFolderRootPath the root path of the folder for XML contents.
     * @param maxRegularDataSets the maximally allowed submissions without waitlist.
     * @param numOtherDataSets the number of submissions added otherwise (i.e., where the submitted data is stored differently)
     * @param maxWaitlistDataSets the maximal number of additional data sets accepted on a waitlist.
     * @param datasetTitle the title for XML contents that store form data (possibly with macros for values of form fields).
     * @param keepDays the number of days to keep the form data after the event (if null, keep indefinitely)
     * @param setFolderPermissions if <code>true</code> it is ensured that permissions for the data folder will be set iff it is created.
     */
    public CmsFormUgcConfiguration(
        CmsUUID id,
        Optional<CmsUser> userForGuests,
        CmsGroup projectGroup,
        String contentFolderRootPath,
        Optional<Integer> maxRegularDataSets,
        Optional<Integer> numOtherDataSets,
        Optional<Integer> maxWaitlistDataSets,
        String datasetTitle,
        Integer keepDays,
        boolean setFolderPermissions) {

        super(
            id,
            userForGuests,
            projectGroup,
            CONTENT_TYPE_FORM_DATA,
            null,
            DEFAULT_NAME_PATTERN,
            CmsLocaleManager.MASTER_LOCALE,
            Optional.<CmsResource> absent(), // uploadParent
            Optional.<Long> absent(), //maxUploadSize
            calculateMaxNumDataSets(maxRegularDataSets, numOtherDataSets, maxWaitlistDataSets),
            Optional.<Long> absent(), //queueTimeout
            Optional.<Integer> absent(), //maxQueueLength
            true, //autoPublish
            Optional.<List<String>> absent()); //validExtensions

        m_maxRegularDataSets = maxRegularDataSets.isPresent() ? maxRegularDataSets.get() : null;
        m_numOtherDataSets = numOtherDataSets.isPresent() ? numOtherDataSets.get().intValue() : 0;
        m_maxWaitlistDataSets = maxWaitlistDataSets.isPresent() ? maxWaitlistDataSets.get().intValue() : 0;
        m_datasetTitle = null == datasetTitle ? "" : datasetTitle;
        m_keepDays = keepDays;
        m_contentFolderRootPath = contentFolderRootPath;
        m_setFolderPermissions = setFolderPermissions;
        initContentFolderIfPresent();
    }

    /**
     * Calculates the maximal number of data sets that can be added via UGC.
     * @param maxRegularDataSets the maximally allowed regular data sets (without the waitlist).
     * @param numOtherDataSets the otherwise added data sets (that are not in the folder where UGC stores in.
     * @param maxWaitlistDataSets the maximal number of additional data sets for a waitlist.
     * @return the maximal number of data sets that can be added via UGC.
     */
    protected static Optional<Integer> calculateMaxNumDataSets(
        Optional<Integer> maxRegularDataSets,
        Optional<Integer> numOtherDataSets,
        Optional<Integer> maxWaitlistDataSets) {

        Optional<Integer> maxNumContents;
        if (maxRegularDataSets.isPresent()) {
            if (numOtherDataSets.isPresent()) {
                maxNumContents = Optional.<Integer> of(
                    Integer.valueOf(
                        Math.max((maxRegularDataSets.get().intValue() - numOtherDataSets.get().intValue()), 0)));
            } else {
                maxNumContents = maxRegularDataSets;
            }
            if (maxWaitlistDataSets.isPresent()) {
                maxNumContents = Optional.<Integer> of(
                    Integer.valueOf(maxNumContents.get().intValue() + maxWaitlistDataSets.get().intValue()));
            }
        } else {
            maxNumContents = Optional.absent();
        }
        return maxNumContents;
    }

    /**
     * Returns the folder for XML contents.<p>
     *
     * @return the folder for XML contents
     */
    @Override
    public CmsResource getContentParentFolder() {

        return m_contentParentFolder;
    }

    /**
     * Returns the title for dataset XML contents (possibly with macros for form fields).
     * @return the title for dataset XML contents (possibly with macros for form fields).
     */
    public String getDatasetTitle() {

        return m_datasetTitle;
    }

    /**
     * Gets the number of days to keep the form data after the event (if null, keep indefinitely).
     *
     * @return the number of days to keep the data
     */
    public Integer getKeepDays() {

        return m_keepDays;
    }

    /**
     * Returns the maximal number of regular submissions. If not specified, <code>null</code> is returned.
     * @return the maximal number of regular submissions. If not specified, <code>null</code> is returned.
     */
    public Integer getMaxRegularDataSets() {

        return m_maxRegularDataSets;
    }

    /**
     * Returns the maximal number of waitlist submissions. If not specified, <code>null</code> is returned.
     * @return the maximal number of waitlist submissions. If not specified, <code>null</code> is returned.
     */
    public int getMaxWaitlistDataSets() {

        return m_maxWaitlistDataSets;
    }

    /**
     * Returns the number of differently submitted data sets. If not specified, <code>0</code> is returned.
     * @return the number of differently submitted data sets. If not specified, <code>0</code> is returned.
     */
    public int getNumOtherDataSets() {

        return m_numOtherDataSets;
    }

    /**
     * If the content folder is not present yet, it is created and published in the UGC session.
     * @param project the project of the UGC session.
     * @throws Exception thrown if creation fails.
     */
    void ensureContentFolder(CmsProject project) throws Exception {

        if (null == m_contentParentFolder) {
            CmsObject adminCms = CmsWebformModuleAction.getAdminCms(null);
            adminCms.getRequestContext().setCurrentProject(project);
            CmsResource contentFolder = null;
            // We avoid to check the presence of the folder here. If it was published already, we will never get here
            // If it was not published yet, we will get into an error later anyway.
            CmsVfsUtil.createFolder(adminCms, m_contentFolderRootPath);
            contentFolder = adminCms.readResource(m_contentFolderRootPath, CmsResourceFilter.ALL);
            try (LockedFile lockedRes = LockedFile.lockResource(adminCms, contentFolder)) {
                if (m_setFolderPermissions) {
                    adminCms.chacc(
                        contentFolder.getRootPath(),
                        null,
                        CmsAccessControlEntry.PRINCIPAL_OVERWRITE_ALL_NAME,
                        "");
                    adminCms.chacc(
                        contentFolder.getRootPath(),
                        I_CmsPrincipal.PRINCIPAL_GROUP,
                        getProjectGroup().getName(),
                        "+r+w+v+c+d+i+o");
                }
                adminCms.writePropertyObjects(
                    contentFolder,
                    Collections.singletonList(
                        new CmsProperty(CmsPropertyDefinition.PROPERTY_HISTORY_REMOVE_DELETED, "true", null)));
                contentFolder = adminCms.readResource(contentFolder.getStructureId());
            }
            m_contentParentFolder = contentFolder;
        }
    }

    /**
     * Reads the content folder, if it is already present.
     */
    void initContentFolderIfPresent() {

        try {
            CmsObject adminCms = CmsWebformModuleAction.getAdminCms(null);
            m_contentParentFolder = adminCms.readResource(m_contentFolderRootPath);
        } catch (CmsException e) {
            // This is ok if the folder does not exist.
        }

    }
}
