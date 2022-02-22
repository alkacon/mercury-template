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

package alkacon.mercury.template.subscriptionmanagement;

import alkacon.mercury.template.captcha.CmsCaptchaPluginLoader;
import alkacon.mercury.template.captcha.I_CmsCaptchaProvider;

import org.opencms.file.CmsObject;
import org.opencms.json.JSONException;

import java.io.IOException;

import javax.servlet.ServletRequest;

/**
 * Handles subscription Captchas in cooperation with the CmsSubscriptionParameterHandler.
 */
public class CmsSubscriptionCaptchaHandler {

    /** The CMS context. */
    private CmsObject m_cms;

    /** The servlet request. */
    private ServletRequest m_servletRequest;

    /** The Captcha provider. */
    private I_CmsCaptchaProvider m_captchaProvider;

    /** The verification result. */
    private Boolean m_verificationResult;

    /**
     * Creates a new subscription Captcha handler.
     * @param request the servlet request
     */
    public CmsSubscriptionCaptchaHandler(CmsObject cms, ServletRequest request) {

        CmsCaptchaPluginLoader captchaPluginLoader = new CmsCaptchaPluginLoader(request);
        m_captchaProvider = captchaPluginLoader.loadCaptchaProvider(cms);
        m_cms = cms;
        m_servletRequest = request;
    }

    /**
     * Returns the widget of the Captcha provider plugin configured for the current site.
     * @param fieldName the fieldName
     * @return the widget of the Captcha provider plugin configured for the current site
     */
    public String getCaptchaWidget(String fieldName) {

        if (m_captchaProvider != null) {
            return m_captchaProvider.getWidgetMarkup(m_cms, m_servletRequest, fieldName);
        }
        return "No captcha plugin configured.";
    }

    /**
     * Returns the evaluated verification result.
     * @return the evaluated verification result
     */
    public boolean getVerificationResult() {

        if (m_captchaProvider == null) { // no Captcha provider configured
            return true;
        }
        return m_verificationResult.booleanValue();
    }

    /**
     * Returns whether there is a Captcha provider configured.
     * @return whether there is a Captcha provider configured
     */
    public boolean hasCaptchaProvider() {

        return m_captchaProvider != null;
    }

    /**
     * Verifies a Captcha solution provided by the user using the configured provider plugin.
     * @param solution the solution
     */
    public void verifyCaptchaSolution(String solution) {

        if (m_verificationResult != null) {
            return;
        }
        if (m_captchaProvider == null) { // no Captcha provider configured
            m_verificationResult = Boolean.valueOf(true);
        } else {
            try {
                m_verificationResult = Boolean.valueOf(m_captchaProvider.verifySolution(m_cms, solution));
            } catch (IOException | JSONException e) {
                m_verificationResult = Boolean.valueOf(false);
            }
        }
    }
}
