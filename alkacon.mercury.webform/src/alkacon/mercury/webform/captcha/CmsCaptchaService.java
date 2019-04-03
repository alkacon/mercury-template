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

import com.octo.captcha.service.captchastore.MapCaptchaStore;
import com.octo.captcha.service.image.AbstractManageableImageCaptchaService;

/**
 * Provides the facility to create and cache the captcha images.<p>
 */
public class CmsCaptchaService extends AbstractManageableImageCaptchaService {

    /**
     * Creates a new captcha service.
     * <p>
     *
     * The following settings are used:
     * <pre>
     * minGuarantedStorageDelayInSeconds = 180s
     * maxCaptchaStoreSize = 100000
     * captchaStoreLoadBeforeGarbageCollection = 75000
     * </pre>
     * <p>
     *
     * @param captchaSettings the settings to render captcha images
     */
    public CmsCaptchaService(CmsCaptchaSettings captchaSettings) {

        super(new MapCaptchaStore(), new CmsCaptchaEngine(captchaSettings), 180, 100000, 75000);
    }

    /**
     * Implant new captcha settings to this service.
     * <p>
     * This is an expensive method as new Image filters and many processing objects are allocated anew.
     * Prefer using the {@link CmsCaptchaServiceCache#getCaptchaService(CmsCaptchaSettings, org.opencms.file.CmsObject)} method instead.
     * It will return cached instances for equal settings.
     * <p>
     *
     * @param settings the captcha settings to implant.
     */
    protected void setSettings(CmsCaptchaSettings settings) {

        CmsCaptchaEngine captchaEngine = (CmsCaptchaEngine)engine;
        captchaEngine.setSettings(settings);
    }

}
