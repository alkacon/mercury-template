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
import org.opencms.file.CmsProject;
import org.opencms.file.CmsResource;
import org.opencms.main.CmsException;
import org.opencms.ugc.CmsUgcSession;
import org.opencms.ugc.CmsUgcSessionFactory;
import org.opencms.ugc.shared.CmsUgcException;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/** Handler for the UGC connections for storing form data in XML contents. */
public class CmsUgcHandler {

    /** The UGC session. */
    CmsUgcSession m_session;
    /** The form data to store in the content. */
    Map<String, String> m_data;

    /**
     * Constructs a new CmsUgcHandler.
     * @param cms the current cms object
     * @param req thre current http servlet request
     * @param config the ugc configuration
     * @param data the form data to store
     * @param isWaitList flag, indicating if the submission is for the waitlist.
     * @throws CmsUgcException thrown if no UGC session can be established or creating a new XML content fails.
     */
    public CmsUgcHandler(
        CmsObject cms,
        HttpServletRequest req,
        CmsFormUgcConfiguration config,
        Map<String, String> data,
        boolean isWaitList)
    throws CmsUgcException {

        m_session = CmsUgcSessionFactory.getInstance().createSession(cms, req, config);
        m_data = data;
        m_data.put(CmsFormDataBean.PATH_WAITLIST_NOTIFICATION, String.valueOf(isWaitList));
        m_data.put(CmsFormDataBean.PATH_TITLEMAPPING, config.getDatasetTitle());
        m_session.createXmlContent();
    }

    /**
     * @see CmsUgcSession#finish()
     * @throws CmsException @see CmsUgcSession#finish()
     */
    public void finish() throws CmsException {

        m_session.finish();
    }

    /**
     * Returns the root path of the content where the form data is stored in.
     * @return the root path of the content where the form data is stored in.
     */
    public String getContentRootPath() {

        if (null != m_session) {
            CmsResource res = m_session.getResource();
            return null == res ? null : res.getRootPath();
        }
        return null;
    }

    /**
     * Returns the name of the project created for the UGC session that is handled.
     * @return the name of the project created for the UGC session that is handled.
     */
    public String getUgcProject() {

        if (null != m_session) {
            CmsProject project = m_session.getProject();
            return null == project ? null : m_session.getProject().getName();
        }
        return null;
    }

    /**
     * Save the form data with the flags for confirmation/registration mail status set as provided by the parameters.
     * @param isConfirmationMailSend a flag, indicating if the confirmation mail has been sent.
     * @param isRegistrationMailSend a flag, indicating if the registration mail has been sent.
     * @throws CmsUgcException thrown if the save action fails.
     */
    public void saveWithStatus(boolean isConfirmationMailSend, boolean isRegistrationMailSend) throws CmsUgcException {

        m_data.put(CmsFormDataBean.PATH_CONFIRMATION_MAIL_SENT, String.valueOf(isConfirmationMailSend));
        m_data.put(CmsFormDataBean.PATH_REGISTRATION_MAIL_SENT, String.valueOf(isRegistrationMailSend));
        m_session.saveContent(m_data);
    }
}
