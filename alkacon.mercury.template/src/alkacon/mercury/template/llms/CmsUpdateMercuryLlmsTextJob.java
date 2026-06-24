/*
 * This program is part of the Alkacon OpenCms Mercury Template.
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */

package alkacon.mercury.template.llms;

import org.opencms.db.CmsPublishList;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.types.I_CmsResourceType;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.scheduler.I_CmsScheduledJob;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;

/**
 * Scheduled job for updating Mercury llms.txt files.<p>
 */
public class CmsUpdateMercuryLlmsTextJob implements I_CmsScheduledJob {

    /** Logger. */
    private static final Log LOG = CmsLog.getLog(CmsUpdateMercuryLlmsTextJob.class);

    /**
     * @see org.opencms.scheduler.I_CmsScheduledJob#launch(org.opencms.file.CmsObject, java.util.Map)
     */
    public String launch(CmsObject cms, Map<String, String> parameters) throws Exception {

        long start = System.currentTimeMillis();
        LOG.info("Starting job " + getClass().getName());
        String parentFolder = parameters.get("folder");
        if (parentFolder == null) {
            parentFolder = "/";
        }
        I_CmsResourceType type = OpenCms.getResourceManager().getResourceType(CmsMercuryLlmsFile.TYPE_NAME);
        List<CmsResource> resources = cms.readResources(
            parentFolder,
            CmsResourceFilter.DEFAULT_FILES.addRequireType(type),
            true);
        List<CmsResource> publishList = new ArrayList<CmsResource>();
        int index = 0;
        for (CmsResource resource : resources) {
            index++;
            try {
                LOG.info("Processing file " + resource.getRootPath() + " [" + index + "/" + resources.size() + "]");
                CmsMercuryLlmsGenerator generator = new CmsMercuryLlmsGenerator(cms, resource);
                if (generator.updateLlmsFile() && !resource.getState().isNew()) {
                    publishList.add(resource);
                }
            } catch (Exception e) {
                LOG.error("Error processing file " + resource.getRootPath() + ": " + e.getLocalizedMessage(), e);
            }
        }
        if (!publishList.isEmpty()) {
            LOG.info("Publishing updated Mercury llms.txt files...");
            CmsPublishList pubList = OpenCms.getPublishManager().getPublishList(cms, publishList, false);
            OpenCms.getPublishManager().publishProject(cms, null, pubList);
        }
        long end = System.currentTimeMillis();
        LOG.info("Finished processing Mercury llms.txt files. Elapsed time: " + ((end - start) / 1000) + " seconds");
        return "";
    }
}
