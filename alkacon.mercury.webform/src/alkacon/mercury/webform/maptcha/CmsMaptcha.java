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

import com.octo.captcha.text.TextCaptcha;

/**
 * Extends the text captcha for generating math challenges.<p>
 */
public class CmsMaptcha extends TextCaptcha {

    /** Serial version ID. */
    private static final long serialVersionUID = 3866109424461928101L;

    /** The response String. */
    private String m_response;

    /**
     * Constructor with parameters.<p>
     *
     * @param questionMath the question
     * @param challengeMath the challenge
     * @param response the response
     */
    CmsMaptcha(String questionMath, String challengeMath, String response) {

        super(questionMath, challengeMath);
        m_response = response;
    }

    /**
     * Validation routine from the CAPTCHA interface. this methods verify if the response is not null and a String and
     * then compares the given response to the internal string.<p>
     *
     * @param response the response
     * @return true if the given response equals the internal response, false otherwise
     */
    @Override
    public final Boolean validateResponse(final Object response) {

        return ((null != response) && (response instanceof String))
        ? validateResponse((String)response)
        : Boolean.FALSE;
    }

    /**
     * Very simple validation routine that compares the given response to the internal string.<p>
     *
     * @param response the response
     * @return true if the given response equals the internal response, false otherwise
     */
    private Boolean validateResponse(final String response) {

        return Boolean.valueOf(response.equals(m_response));
    }
}
