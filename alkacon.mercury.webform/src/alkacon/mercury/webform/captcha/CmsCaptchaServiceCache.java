/*
 * This program is part of the Alkacon OpenCms Mercury Template.
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

package alkacon.mercury.webform.captcha;

import org.opencms.file.CmsObject;
import org.opencms.main.CmsEvent;
import org.opencms.main.I_CmsEventListener;
import org.opencms.main.OpenCms;

import java.util.HashMap;
import java.util.Map;

import com.octo.captcha.service.CaptchaService;

import alkacon.mercury.webform.maptcha.CmsMaptchaService;

/**
 * Caches captcha services, otherwise the mechanism will not work.<p>
 */
public final class CmsCaptchaServiceCache implements I_CmsEventListener {

    /** The shared instance of the captcha service cache. */
    private static CmsCaptchaServiceCache sharedInstance;

    /** Stores the captcha services. */
    private Map<String, CmsCaptchaService> m_captchaServices;

    /** Stores the maptcha services. */
    private Map<String, CmsMaptchaService> m_maptchaServices;

    /**
     * Default constructor.
     * <p>
     */
    private CmsCaptchaServiceCache() {

        super();

        // add this class as an event handler to the Cms event listener
        OpenCms.addCmsEventListener(
            this,
            new int[] {
                I_CmsEventListener.EVENT_CLEAR_CACHES,
                I_CmsEventListener.EVENT_CLEAR_ONLINE_CACHES,
                I_CmsEventListener.EVENT_CLEAR_OFFLINE_CACHES,
                I_CmsEventListener.EVENT_PUBLISH_PROJECT});

        m_captchaServices = new HashMap<>();
        m_maptchaServices = new HashMap<>();
    }

    /**
     * Returns the shared instance of the captcha service cache.
     * <p>
     *
     * @return the shared instance of the captcha service cache
     */
    public static synchronized CmsCaptchaServiceCache getSharedInstance() {

        if (sharedInstance == null) {
            sharedInstance = new CmsCaptchaServiceCache();
        }

        return sharedInstance;
    }

    /**
     * @see org.opencms.main.I_CmsEventListener#cmsEvent(org.opencms.main.CmsEvent)
     */
    public void cmsEvent(CmsEvent event) {

        switch (event.getType()) {
            case I_CmsEventListener.EVENT_CLEAR_CACHES:
            case I_CmsEventListener.EVENT_CLEAR_ONLINE_CACHES:
            case I_CmsEventListener.EVENT_CLEAR_OFFLINE_CACHES:
            case I_CmsEventListener.EVENT_PUBLISH_PROJECT:
                clearCaptchaServices();
                break;

            default:
                // noop
                break;
        }
    }

    /**
     * Returns the captcha service specified by the settings.
     * <p>
     *
     * @param captchaSettings the settings to render captcha images.
     *
     * @param cms needed for context information when getting the key for caching.
     *
     * @return the captcha service.
     */
    public synchronized CaptchaService getCaptchaService(CmsCaptchaSettings captchaSettings, CmsObject cms) {

        if (m_captchaServices == null) {
            m_captchaServices = new HashMap<>();
        }
        if (m_maptchaServices == null) {
            m_maptchaServices = new HashMap<>();
        }

        String key = null;
        if (captchaSettings.getPresetPath() != null) {
            key = captchaSettings.getPresetPath() + captchaSettings.getConfigId();
        } else {
            key = captchaSettings.toRequestParams(cms);
        }
        if (captchaSettings.isMathField()) {
            CmsMaptchaService maptchaService = m_maptchaServices.get(key);
            if (maptchaService == null) {
                maptchaService = new CmsMaptchaService(captchaSettings);
                m_maptchaServices.put(key, maptchaService);
            }
            return maptchaService;
        } else {
            CmsCaptchaService captchaService = m_captchaServices.get(key);
            if (captchaService == null) {
                captchaService = new CmsCaptchaService(captchaSettings);
                m_captchaServices.put(key, captchaService);
            } else {
                // install the parameters to the internal engine
                captchaService.setSettings(captchaSettings);
            }

            return captchaService;
        }
    }

    /**
     * Clears the map storing the captcha services.
     * <p>
     */
    private synchronized void clearCaptchaServices() {

        if (m_captchaServices != null) {
            m_captchaServices.clear();
        }

        if (m_maptchaServices != null) {
            m_maptchaServices.clear();
        }
    }
}