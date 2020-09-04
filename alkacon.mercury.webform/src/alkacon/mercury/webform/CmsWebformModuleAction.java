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

import org.opencms.configuration.CmsConfigurationManager;
import org.opencms.db.CmsPublishList;
import org.opencms.file.CmsObject;
import org.opencms.main.CmsEvent;
import org.opencms.main.CmsException;
import org.opencms.main.OpenCms;
import org.opencms.module.CmsModule;
import org.opencms.module.I_CmsModuleAction;
import org.opencms.report.I_CmsReport;

/**
 * Module action class for the user-generated content module.<p>
 */
public class CmsWebformModuleAction implements I_CmsModuleAction {

    /**
     * The admin-level CMS context.<p>
     *
     */
    private static CmsObject m_adminCms;

    /**
     * Returns a CMS context with admin privileges, but the request time set as from the current cms object.<p>
     * @param cms the current CmsObject, where the request time is read of.
     *
     * @return a CMS context with admin privileges, but the request time set as from the current cms object.
     * @throws CmsException thrown if cloning the CmsObject fails.
     */
    protected static CmsObject getAdminCms(CmsObject cms) throws CmsException {

        CmsObject result = OpenCms.initCmsObject(m_adminCms);
        if (null != cms) {
            result.getRequestContext().setRequestTime(cms.getRequestContext().getRequestTime());
        }
        return result;
    }

    /**
     * @see org.opencms.main.I_CmsEventListener#cmsEvent(org.opencms.main.CmsEvent)
     */
    @Override
    public void cmsEvent(CmsEvent event) {

        // ignore
    }

    /**
     * @see org.opencms.module.I_CmsModuleAction#initialize(org.opencms.file.CmsObject, org.opencms.configuration.CmsConfigurationManager, org.opencms.module.CmsModule)
     */
    @Override
    public void initialize(CmsObject adminCms, CmsConfigurationManager configurationManager, CmsModule module) {

        m_adminCms = adminCms;
    }

    /**
     * @see org.opencms.module.I_CmsModuleAction#moduleUninstall(org.opencms.module.CmsModule)
     */
    @Override
    public void moduleUninstall(CmsModule module) {

        // ignore
    }

    /**
     * @see org.opencms.module.I_CmsModuleAction#moduleUpdate(org.opencms.module.CmsModule)
     */
    @Override
    public void moduleUpdate(CmsModule module) {

        // ignore
    }

    /**
     * @see org.opencms.module.I_CmsModuleAction#publishProject(org.opencms.file.CmsObject, org.opencms.db.CmsPublishList, int, org.opencms.report.I_CmsReport)
     */
    @Override
    public void publishProject(CmsObject cms, CmsPublishList publishList, int publishTag, I_CmsReport report) {

        // ignore

    }

    /**
     * @see org.opencms.module.I_CmsModuleAction#shutDown(org.opencms.module.CmsModule)
     */
    @Override
    public void shutDown(CmsModule module) {

        // ignore

    }

}
