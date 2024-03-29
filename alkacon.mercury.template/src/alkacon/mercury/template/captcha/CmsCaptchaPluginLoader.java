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

package alkacon.mercury.template.captcha;

import org.opencms.file.CmsObject;
import org.opencms.jsp.util.CmsJspStandardContextBean;
import org.opencms.jsp.util.CmsTemplatePluginWrapper;
import org.opencms.main.CmsLog;

import java.util.List;
import java.util.Map;

import javax.servlet.ServletRequest;

import org.apache.commons.logging.Log;

/**
 * Class handling Captcha plugins.
 */
public class CmsCaptchaPluginLoader {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCaptchaPluginLoader.class);

    /** Plugin group name. */
    public static final String PLUGIN_WEBFORM_CAPTCHA = "webform-captcha";

    /** The servlet request. */
    ServletRequest m_servletRequest;

    /**
     * Creates a Captcha plugin loader.
     * @param servletRequest the servlet request
     */
    public CmsCaptchaPluginLoader(ServletRequest servletRequest) {

        m_servletRequest = servletRequest;
    }

    /**
     * Finds the Captcha plugin configured for the current site context.
     * @return the Captcha plugin configured
     */
    public CmsTemplatePluginWrapper findPlugin() {

        CmsJspStandardContextBean standardContextBean = CmsJspStandardContextBean.getInstance(m_servletRequest);
        Map<String, List<CmsTemplatePluginWrapper>> plugins = standardContextBean.getPlugins();
        if (plugins.containsKey(PLUGIN_WEBFORM_CAPTCHA) && !plugins.get(PLUGIN_WEBFORM_CAPTCHA).isEmpty()) {
            return plugins.get(PLUGIN_WEBFORM_CAPTCHA).get(0);
        }
        return null;
    }

    /**
     * Loads the Captcha provider for the current site context or null if the provider is disabled
     * for the current site context.
     * @param cms the CMS context
     * @return the Captcha provider
     */
    public I_CmsCaptchaProvider loadCaptchaProvider(CmsObject cms) {

        CmsTemplatePluginWrapper pluginWrapper = findPlugin();
        if (pluginWrapper == null) {
            return null;
        }
        String className = pluginWrapper.getAttributes().get("className");
        I_CmsCaptchaProvider captchaProvider = null;
        if (className != null) {
            try {
                Class<?> providerClass = Class.forName(className, false, getClass().getClassLoader());
                if (I_CmsCaptchaProvider.class.isAssignableFrom(providerClass)) {
                    captchaProvider = ((Class<? extends I_CmsCaptchaProvider>)providerClass).newInstance();
                }
                if ((captchaProvider != null) && captchaProvider.isDisabled(cms)) {
                    captchaProvider = null;
                }
            } catch (ClassNotFoundException | InstantiationException | IllegalAccessException e) {
                LOG.error(e.getLocalizedMessage(), e);
            }
        }
        return captchaProvider;
    }
}
