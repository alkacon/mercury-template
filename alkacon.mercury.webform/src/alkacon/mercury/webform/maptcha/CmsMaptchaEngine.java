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

import com.octo.captcha.CaptchaFactory;
import com.octo.captcha.engine.CaptchaEngineException;
import com.octo.captcha.engine.GenericCaptchaEngine;

/**
 * A captcha engine using a Maptcha factory to create mathematical captchas.<p>
 */
public class CmsMaptchaEngine extends GenericCaptchaEngine {

    /** The configured mathematical captcha factory. */
    private CmsMaptchaFactory m_factory;

    /**
     * Creates a new Maptcha engine.<p>
     *
     * @param captchaSettings the settings to create mathematical captchas
     */
    public CmsMaptchaEngine(CmsCaptchaSettings captchaSettings) {

        super(new CaptchaFactory[] {new CmsMaptchaFactory()});
        initMathFactory();
    }

    /**
     * Returns the hardcoded factory (array of length 1) that is used.<p>
     *
     * @return the hardcoded factory (array of length 1) that is used
     *
     * @see com.octo.captcha.engine.CaptchaEngine#getFactories()
     */
    @Override
    public CaptchaFactory[] getFactories() {

        return new CaptchaFactory[] {m_factory};
    }

    /** This method build a Maptcha Factory.<p>
     *
     * @return a Maptcha Factory
     */
    public CmsMaptchaFactory getFactory() {

        return m_factory;
    }

    /**
     * This does nothing.<p>
     *
     * A hardcoded factory is used.<p>
     *
     * @see com.octo.captcha.engine.CaptchaEngine#setFactories(com.octo.captcha.CaptchaFactory[])
     */
    @Override
    public void setFactories(CaptchaFactory[] arg0) throws CaptchaEngineException {

        // TODO Auto-generated method stub

    }

    /**
     * Initializes a Maptcha Factory.<p>
     */
    protected void initMathFactory() {

        m_factory = new CmsMaptchaFactory();
    }

}
