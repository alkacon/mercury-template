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
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.jsp.util.A_CmsJspCustomContextBean;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.security.CmsRole;
import org.opencms.ugc.CmsUgcConfiguration;
import org.opencms.xml.I_CmsXmlDocument;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

import org.apache.commons.logging.Log;

/**
 * Bean for easy form initialization and access in JSPs.
 */
public class CmsFormBean extends A_CmsJspCustomContextBean {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormBean.class);

    /** The form configuration. */
    protected I_CmsXmlDocument m_formConfig;

    /** The ugc configuration. */
    protected CmsFormUgcConfiguration m_ugcConfig;

    /** The dynamic form configuration. */
    protected Map<String, String> m_dynamicConfig = new HashMap<>();

    /** Flag, indicating if the UGC configuration has been initialized already. */
    protected boolean m_isUgcInitialized;

    /** Field with additional configuration values. */
    protected Map<String, String> m_extraConfig = new HashMap<>();

    /**
     * Add an addtional config value to be accessible in the string template, e.g., to forward element settings.
     * @param key the key to access the value.
     * @param value the value.
     */
    public void addExtraConfig(String key, String value) {

        m_extraConfig.put(key, value);
    }

    /**
    * Overwrite a value from the form configuration.
    * @param key the XPATH to the value in the XML configuration.
    * @param value the replacement value.
    */
    public void adjustConfigValue(String key, String value) {

        m_dynamicConfig.put(key, value);
    }

    /**
    * Creates the form handler.
    *
    * @param context the current page context.
    *
    * @return the created form handler, or <code>null</code> if creation fails.
    */
    public CmsFormHandler createFormHandler(PageContext context) {

        try {
            String configSitePath = null != m_formConfig ? getCmsObject().getSitePath(m_formConfig.getFile()) : null;
            return CmsFormHandlerFactory.create(
                context,
                (HttpServletRequest)context.getRequest(),
                (HttpServletResponse)context.getResponse(),
                null,
                configSitePath,
                m_dynamicConfig,
                m_extraConfig);
        } catch (Exception e) {
            LOG.error(e);
            return null;
        }
    }

    /**
     * Returns the dynamic value with the xPath key, or the default value if it is not found.
     * @param xPath key for the dynamic value.
     * @param defaultValue the default value returned if the dynamic value is not found.
     *
     * @return the dynamic value with the xPath key, or the default value if it is not found.
     */
    public String getDynamicValue(String xPath, String defaultValue) {

        String value = m_dynamicConfig.get(xPath);
        return null != value ? value : defaultValue;
    }

    /**
     * Returns the form configuration.
     * @return the form configuration
     */
    public I_CmsXmlDocument getFormConfig() {

        return m_formConfig;
    }

    /**
     * Returns the resource of the folder where the submitted data is stored in.
     * @return the resource of the folder where the submitted data is stored in.
     */
    public CmsResource getSubmissionDataFolder() {

        CmsUgcConfiguration ugcConfig = getUgcConfig();
        if (null != ugcConfig) {
            return ugcConfig.getContentParentFolder();
        } else {
            return null;
        }
    }

    /**
     * Returns the already submitted data sets as resources.
     * @return The resources holding the already submitted data sets.
     */
    public List<CmsResource> getSubmissions() {

        CmsObject cms = getCmsObject();
        CmsResource submissionDataFolder = getSubmissionDataFolder();
        if (null != submissionDataFolder) {
            try {
                return cms.readResources(
                    cms.getRequestContext().removeSiteRoot(submissionDataFolder.getRootPath()),
                    CmsResourceFilter.IGNORE_EXPIRATION.addRequireType(
                        OpenCms.getResourceManager().getResourceType(CmsFormUgcConfiguration.CONTENT_TYPE_FORM_DATA)),
                    false);
            } catch (CmsException e) {
                LOG.warn(
                    "Failed to load submitted data sets for form from folder "
                        + submissionDataFolder.getRootPath()
                        + ".");
            }
        }
        return Collections.emptyList();
    }

    /**
     * Returns the submission status for the form.
     * @return the submission status for the form.
     */
    public CmsSubmissionStatus getSubmissionStatus() {

        CmsSubmissionStatus result;
        try {
            result = new CmsSubmissionStatus(getCmsObject(), getUgcConfig());
        } catch (Exception e) {
            result = new CmsSubmissionStatus();
        }
        return result;
    }

    /**
     * Flag, indicating if the current user is allowed to manage the submissions.</p>
     *
     * Returns true, iff data is stored at all and the current user can access the folder where the submitted data is stored.
     * @return a flag, indicating if the current user is allowed to manage the submissions.
     */
    public boolean getUserCanManage() {

        CmsFormUgcConfiguration ugcConfig = getUgcConfig();
        if (null == ugcConfig) {
            return false;
        } else {
            if (OpenCms.getRoleManager().hasRole(getCmsObject(), CmsRole.ROOT_ADMIN)) {
                return true;
            }
            CmsResource contentFolder = ugcConfig.getContentParentFolder();
            if (null == contentFolder) {
                try {
                    return getCmsObject().getGroupsOfUser(
                        getCmsObject().getRequestContext().getCurrentUser().getName(),
                        false).contains(ugcConfig.getProjectGroup());
                } catch (Throwable t) {
                    if (LOG.isDebugEnabled()) {
                        LOG.debug("Failed to determine if the current user is member of the project group", t);
                    } else {
                        LOG.error("Failed to determine if the current user is member of the project group");
                    }
                    return false;
                }
            } else {
                return getCmsObject().existsResource(contentFolder.getStructureId());
            }
        }
    }

    /**
     * Set the additional configuration values accessible in the the string template, e.g., to forward element settings to the template.
     * @param valueMap the additional configuration values.
     */
    public void setExtraConfig(Map<String, String> valueMap) {

        m_extraConfig = null == valueMap ? new HashMap<>() : new HashMap<>(valueMap);
    }

    /**
     * Sets the form configuration.
     * For convenience the form itself is returned.
     *
     * @param formConfig the form configuration (either the file or the XML or ...)
     *
     * @return the bean itself.
     */
    public CmsFormBean setForm(Object formConfig) {

        try {
            m_formConfig = toXml(formConfig);
            if (!OpenCms.getResourceManager().getResourceType(m_formConfig.getFile()).getTypeName().equals(
                CmsForm.TYPE_FORM_CONFIG)) {
                throw new CmsException(
                    LogMessages.get().container(
                        LogMessages.ERR_WRONG_FORM_CONFIG_FORMAT_1,
                        m_formConfig.getFile().getRootPath()));
            }
        } catch (Exception e) {
            LOG.error(LogMessages.get().getBundle().key(LogMessages.ERR_READING_FORM_CONFIG_FAILED_0), e);
        }
        return this;
    }

    /**
     * Returns the lazily initialized UGC configuration. Lazy initialization is necessary since the dynamic configuration has to be set first.
     * @return the lazily initialized UGC configuration.
     */
    private CmsFormUgcConfiguration getUgcConfig() {

        if (!m_isUgcInitialized) {
            CmsFormUgcConfigurationReader ugcConfigReader = new CmsFormUgcConfigurationReader();
            try {
                m_ugcConfig = ugcConfigReader.readConfiguration(getCmsObject(), m_formConfig, m_dynamicConfig);
            } catch (Exception e) {
                //DO nothing, just return null.
            }
            m_isUgcInitialized = true;
        }
        return m_ugcConfig;
    }

}
