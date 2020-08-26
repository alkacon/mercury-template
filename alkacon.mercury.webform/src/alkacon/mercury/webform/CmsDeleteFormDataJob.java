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
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.scheduler.I_CmsScheduledJob;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

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

    /** The resource type to read. */
    public static final String RESOURCE_TYPE = CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA;

    /**
     * @see org.opencms.scheduler.I_CmsScheduledJob#launch(org.opencms.file.CmsObject, java.util.Map)
     */
    public String launch(CmsObject cms, Map<String, String> parameters) throws Exception {

        boolean testOnly = Boolean.parseBoolean(parameters.get(PARAM_TEST_ONLY));
        String randomKey = RandomStringUtils.randomAlphanumeric(6);
        String p = "[" + randomKey + "][testOnly=" + testOnly + "] ";
        LOG.info(p + "Starting CmsDeleteFormDataJob");
        String folder = parameters.get(PARAM_ROOT_FOLDER);
        if (folder == null) {
            folder = "/";
        }
        List<CmsResource> resources = cms.readResources(
            folder,
            CmsResourceFilter.IGNORE_EXPIRATION.addRequireType(
                OpenCms.getResourceManager().getResourceType(RESOURCE_TYPE)));
        LOG.info(p + "Found " + resources.size() + " form data resources.");
        List<CmsResource> resourcesToDelete = new ArrayList<>();
        for (CmsResource resource : resources) {
            LOG.debug(p + "Processing " + resource.getRootPath());
            try {
                CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
                long deletionDate = Long.MAX_VALUE;
                for (Locale locale : content.getLocales()) {
                    if (content.hasValue(CmsFormDataBean.PATH_DELETION_DATE, locale)) {
                        I_CmsXmlContentValue deletionDateVal = content.getValue(
                            CmsFormDataBean.PATH_DELETION_DATE,
                            locale);
                        deletionDate = Long.parseLong(deletionDateVal.getStringValue(cms));
                        LOG.info(p + " Deletion date: " + new Date(deletionDate));
                        break;
                    }
                }
                if (deletionDate < System.currentTimeMillis()) {
                    resourcesToDelete.add(resource);
                    LOG.info(p + "Adding resource " + resource.getRootPath() + " to deletion list.");
                }
            } catch (Exception e) {
                LOG.error(p + e.getLocalizedMessage(), e);
            }
        }
        LOG.info(p + " deletion list has " + resourcesToDelete.size() + " resources.");
        if (testOnly) {
            LOG.info(p + " exiting becaue we are in test-only mode");
            return "";
        }
        try {
            CmsProject tempProject = cms.createProject(
                "Form data delete project " + randomKey,
                "Form data delete project",
                OpenCms.getDefaultUsers().getGroupAdministrators(),
                OpenCms.getDefaultUsers().getGroupAdministrators(),
                CmsProject.PROJECT_TYPE_TEMPORARY);
            CmsObject cmsClone = OpenCms.initCmsObject(cms);
            cmsClone.getRequestContext().setCurrentProject(tempProject);
            cmsClone.copyResourceToProject("/");
            for (CmsResource resource : resourcesToDelete) {
                try {
                    LOG.info(p + " deleting " + resource.getRootPath());
                    CmsLockUtil.ensureLock(cmsClone, resource);
                    cmsClone.deleteResource(resource, CmsResource.DELETE_PRESERVE_SIBLINGS);
                } catch (Exception e) {
                    // Errors when deleting individual resources shouldn't keep other resources from being deleted
                    LOG.error(p + e.getLocalizedMessage(), e);
                }
            }
            LOG.info(p + " publishing deleted files");
            OpenCms.getPublishManager().publishProject(cmsClone);
        } catch (Exception e) {
            LOG.error(p + e.getLocalizedMessage(), e);
        }
        return "";
    }

}
