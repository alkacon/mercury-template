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

import org.opencms.db.CmsPublishList;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.types.I_CmsResourceType;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.publish.CmsPublishManager;
import org.opencms.relations.CmsRelation;
import org.opencms.relations.CmsRelationFilter;
import org.opencms.report.CmsLogReport;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.CmsUUID;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

import org.apache.commons.logging.Log;

/**
 * Action class for managing form data via Ajax requests.
 */
public class CmsFormDataAjaxHandler extends A_CmsFormDataHandler {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormDataAjaxHandler.class);

    /** A message key. */
    private final static String INFO_SUCCESS_DELETED_ALL_SUBMISSIONS = "msg.page.bookingmanage.info.successdeleteallsubmissions";

    /**
     * Creates a new form data handler.
     * @param context the page context
     * @param request the request
     * @param response the response
     */
    public CmsFormDataAjaxHandler(PageContext context, HttpServletRequest request, HttpServletResponse response) {

        super(context, request, response);
    }

    /**
     * On request, deletes all submissions.
     * @param eventUuid the UUID of the event content
     * @param formdataUuids comma separated list of form-data UUIDs
     * @return whether deleting the submissions was successful
     */
    public boolean deleteSubmissions(String eventUuid, String formdataUuids) {

        if (getCmsObject().getRequestContext().getCurrentProject().isOnlineProject()) {
            return false;
        }
        CmsObject clone = null;
        boolean success = true;
        try {
            clone = OpenCms.initCmsObject(getCmsObject());
            CmsResource event = readResource(clone, eventUuid);
            if (event == null) {
                setError(ERROR_RESOURCE_NOT_FOUND);
                return false;
            }
            I_CmsResourceType resourceType = OpenCms.getResourceManager().getResourceType(event);
            I_CmsResourceType eventType = OpenCms.getResourceManager().getResourceType("m-event");
            if (!resourceType.equals(eventType)) {
                setError(ERROR_FORBIDDEN);
                return false;
            }
            List<CmsResource> formDataResources = readFormData(clone, eventUuid, formdataUuids);
            List<CmsResource> publishList = new ArrayList<CmsResource>();
            for (CmsResource relatedResource : formDataResources) {
                boolean deleted = deleteSubmission(relatedResource.getStructureId().toString(), false);
                if (!deleted) {
                    success = false;
                    break;
                } else {
                    CmsResource publishResource = clone.readResource(
                        relatedResource.getStructureId(),
                        CmsResourceFilter.ALL);
                    publishList.add(publishResource);
                }
            }
            boolean published = publishResources(clone, publishList);
            if (!published) {
                setError(ERROR_INTERNAL);
                success = false;
            }
        } catch (CmsException e) {
            setError(ERROR_INTERNAL);
            LOG.error(e.getLocalizedMessage(), e);
            success = false;
        }
        if (success) {
            setInfo(INFO_SUCCESS_DELETED_ALL_SUBMISSIONS);
        }
        return success;
    }

    /**
     * Publishes a list of resources.
     * @param clone the CMS clone
     * @param resources the list of resources
     * @return whether the list of resources was successfully published
     */
    private boolean publishResources(CmsObject clone, List<CmsResource> resources) {

        try {
            CmsPublishManager publishManager = OpenCms.getPublishManager();
            CmsPublishList publishList = publishManager.getPublishListAll(clone, resources, false, true);
            publishManager.publishProject(
                clone,
                new CmsLogReport(Locale.ENGLISH, CmsFormDataHandler.class),
                publishList);
            return true;
        } catch (Exception e) {
            LOG.error(e.getLocalizedMessage(), e);
            return false;
        }
    }

    /**
     * Reads the related form data resources.
     * @param clone the CMS clone
     * @param eventUuid the event UUID
     * @param formdataUuids comma separated list of form-data UUIDs
     * @return the related form data resources
     */
    private List<CmsResource> readFormData(CmsObject clone, String eventUuid, String formdataUuids) {

        List<CmsResource> formData = new ArrayList<CmsResource>();
        List<String> ids = null;
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(formdataUuids)) {
            if (formdataUuids.contains(",")) {
                ids = Arrays.asList(formdataUuids.split(","));
            } else {
                ids = new ArrayList<String>();
                ids.add(formdataUuids);
            }
        }
        CmsRelationFilter relationFilter = CmsRelationFilter.relationsToStructureId(new CmsUUID(eventUuid));
        if (relationFilter != null) {
            try {
                List<CmsRelation> relationsToResource = clone.readRelations(relationFilter);
                I_CmsResourceType formDataType = OpenCms.getResourceManager().getResourceType(
                    CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA);
                for (CmsRelation relation : relationsToResource) {
                    CmsResource relatedResource = null;
                    try {
                        relatedResource = relation.getSource(clone, CmsResourceFilter.ALL.addRequireType(formDataType));
                    } catch (CmsException e) {
                        // resource does not exist in online project, nothing to do
                    }
                    if (relatedResource != null) {
                        if (ids == null) {
                            formData.add(relatedResource);
                        } else if (ids.contains(relatedResource.getStructureId().toString())) {
                            formData.add(relatedResource);
                        }
                    }
                }
            } catch (CmsException e) {
                setError(ERROR_INTERNAL);
                LOG.error(e.getLocalizedMessage(), e);
            }
        } else {
            setError(ERROR_INTERNAL);
        }
        return formData;
    }
}
