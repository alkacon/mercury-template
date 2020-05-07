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

package alkacon.mercury.webform.maptcha;

import alkacon.mercury.webform.captcha.CmsCaptchaSettings;

import com.octo.captcha.service.captchastore.MapCaptchaStore;
import com.octo.captcha.service.multitype.GenericManageableCaptchaService;

/**
 * Provides the facility to create and cache the maptchas.<p>
 */
public class CmsMaptchaService extends GenericManageableCaptchaService {

    /**
     * Creates a new maptcha service.<p>
     *
     * The following settings are used:
     * <pre>
     * minGuarantedStorageDelayInSeconds = 180s
     * maxCaptchaStoreSize = 100000
     * captchaStoreLoadBeforeGarbageCollection = 75000
     * </pre>
     * <p>
     *
     * @param captchaSettings the settings to display maptcha challenges
     */
    public CmsMaptchaService(CmsCaptchaSettings captchaSettings) {

        super(new MapCaptchaStore(), new CmsMaptchaEngine(captchaSettings), 180, 100000, 75000);
    }

}
