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
import org.opencms.file.CmsProject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.lock.CmsLockUtil;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.scheduler.I_CmsScheduledJob;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.logging.Log;

/**
 * Scheduled job which deletes form data resources with a deletion date before the current time.
 */
public class CmsDeleteFormDataJob implements I_CmsScheduledJob {

    /** Logger instance for this class. */
    private static final Log LOG = CmsLog.getLog(CmsDeleteFormDataJob.class);

    /** Name for the 'testOnly' parameter (if set to true, don't delete resources). */
    public static final String PARAM_TEST_ONLY = "testOnly";

    /**  Name for the 'folder' parameter (if set, test resources from this folder, else use the root folder). */
    public static final String PARAM_ROOT_FOLDER = "folder";

    /** Key for the types parameter. */
    public static final String PARAM_TYPES = "types";

    /** The default resource types to read. */
    public static final String DEFAULT_TYPES = CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA + "," + "a-formdata";

    /** The default folder to read. */
    public static final String DEFAULT_FOLDER = "/";

    /** The process id. */
    private String m_pid;

    /** The resource types to read. */
    private List<String> m_types;

    /** The folder to read. */
    private String m_folder;

    /**
     * @see org.opencms.scheduler.I_CmsScheduledJob#launch(org.opencms.file.CmsObject, java.util.Map)
     */
    public String launch(CmsObject cms, Map<String, String> parameters) throws Exception {

        String randomKey = RandomStringUtils.randomAlphanumeric(6);
        m_pid = "[" + randomKey + "] ";
        LOG.info(m_pid + "Parsing parameters for CmsDeleteFormDataJob");
        parseJobParams(parameters);
        LOG.info(m_pid + "Starting CmsDeleteFormDataJob");
        List<CmsResource> resourcesToDelete = collectResources(cms);
        if (resourcesToDelete.size() == 0) {
            LOG.info(m_pid + "nothing to delete, exiting...");
            return "";
        }
        deleteResources(cms, resourcesToDelete);
        return "";
    }

    /**
     * Collects all resources that are delete candidates.
     * @param cms the job's CMS object
     * @return the collected delete candidates
     */
    private List<CmsResource> collectResources(CmsObject cms) {

        List<CmsResource> resourcesToDelete = new ArrayList<CmsResource>();
        for (String type : m_types) {
            try {
                List<CmsResource> resources = cms.readResources(
                    m_folder,
                    CmsResourceFilter.IGNORE_EXPIRATION.addRequireType(
                        OpenCms.getResourceManager().getResourceType(type)));
                LOG.info(m_pid + "Found " + resources.size() + " form data resources for type " + type);
                for (CmsResource resource : resources) {
                    LOG.debug(m_pid + "Processing " + resource.getRootPath());
                    try {
                        CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
                        long deletionDate = Long.MAX_VALUE;
                        for (Locale locale : content.getLocales()) {
                            if (content.hasValue(CmsFormDataBean.PATH_DELETION_DATE, locale)) {
                                I_CmsXmlContentValue deletionDateVal = content.getValue(
                                    CmsFormDataBean.PATH_DELETION_DATE,
                                    locale);
                                deletionDate = Long.parseLong(deletionDateVal.getStringValue(cms));
                                LOG.info(m_pid + " Deletion date: " + new Date(deletionDate));
                                break;
                            }
                        }
                        if (deletionDate < System.currentTimeMillis()) {
                            resourcesToDelete.add(resource);
                            LOG.info(m_pid + "Adding resource " + resource.getRootPath() + " to deletion list.");
                        }
                    } catch (Exception e) {
                        LOG.error(m_pid + e.getLocalizedMessage(), e);
                    }
                }
            } catch (Exception e) {
                LOG.error(m_pid + e.getLocalizedMessage(), e);
            }
        }
        return resourcesToDelete;
    }

    /**
     * Deletes all resources that are delete candidates. If all resources of a
     * folder are deleted, delete the folder as well.
     * @param cms the CMS object
     * @param resources the delete candidate resources
     * @return whether deleting the resources was successful
     */
    private void deleteResources(CmsObject cms, List<CmsResource> resources) {

        try {
            CmsObject cmsClone = OpenCms.initCmsObject(cms);
            CmsProject tempProject = cms.createProject(
                "Form data deletion project " + m_pid,
                "Form data deletion project",
                OpenCms.getDefaultUsers().getGroupAdministrators(),
                OpenCms.getDefaultUsers().getGroupAdministrators(),
                CmsProject.PROJECT_TYPE_TEMPORARY);
            cmsClone.getRequestContext().setCurrentProject(tempProject);
            Set<String> parentFolders = new HashSet<>();
            boolean hasChanges = false;
            for (CmsResource resource : resources) {
                try {
                    LOG.info(m_pid + "deleting " + resource.getRootPath());
                    parentFolders.add(CmsResource.getParentFolder(resource.getRootPath()));
                    CmsLockUtil.ensureLock(cmsClone, resource);
                    cmsClone.deleteResource(resource, CmsResource.DELETE_PRESERVE_SIBLINGS);
                    hasChanges = true;
                } catch (Exception e) {
                    // Errors when deleting individual resources shouldn't keep other resources from being deleted
                    LOG.error(m_pid + e.getLocalizedMessage(), e);
                }
            }
            for (String parentFolder : parentFolders) {
                try {
                    List<CmsResource> filesInFolder = cms.readResources(
                        parentFolder,
                        CmsResourceFilter.IGNORE_EXPIRATION,
                        false);
                    // If all files in folder have the state 'deleted'
                    if (filesInFolder.size() == 0) {
                        LOG.info(m_pid + "deleting empty folder " + parentFolder);
                        CmsResource folderRes = cms.readResource(parentFolder, CmsResourceFilter.IGNORE_EXPIRATION);
                        try {
                            CmsLockUtil.ensureLock(cmsClone, folderRes);
                            cmsClone.deleteResource(folderRes, CmsResource.DELETE_PRESERVE_SIBLINGS);
                            hasChanges = true;
                        } catch (Exception e) {
                            LOG.error(m_pid + e.getLocalizedMessage(), e);
                        }
                    }
                } catch (Exception e) {
                    LOG.error(m_pid + e.getLocalizedMessage(), e);
                }
            }
            if (hasChanges) {
                LOG.info(m_pid + "publishing changes...");
                OpenCms.getPublishManager().publishProject(cmsClone);
            } else {
                cmsClone = null;
                try {
                    cms.deleteProject(tempProject.getId());
                } catch (CmsException e) {
                    LOG.error("Failed to delete project " + tempProject.getName(), e);
                }
            }
        } catch (Exception e) {
            LOG.error(m_pid + e.getLocalizedMessage(), e);
        }
    }

    /**
     * Parses and initializes the job's parameters.
     * @param parameters the job's parameters
     */
    private void parseJobParams(Map<String, String> parameters) {

        String typesParam = parameters.get(PARAM_TYPES);
        String types[];
        if (typesParam != null) {
            if (typesParam.contains(",")) {
                types = typesParam.split(",");
            } else {
                types = new String[1];
                types[0] = typesParam;
            }
            m_types = new ArrayList<String>();
            for (String type : types) {
                if (OpenCms.getResourceManager().hasResourceType(type)) {
                    m_types.add(type);
                } else {
                    LOG.info(m_pid + "skipping resource type " + type + " because it doesn't exist.");
                }
            }
        } else {
            m_types = Arrays.asList(DEFAULT_TYPES.split(","));
        }
        String folderParam = parameters.get(PARAM_ROOT_FOLDER);
        if (folderParam != null) {
            m_folder = folderParam;
        } else {
            m_folder = DEFAULT_FOLDER;
        }
    }
}
