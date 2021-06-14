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

import java.security.SecureRandom;
import java.util.Locale;
import java.util.Random;

import com.octo.captcha.text.TextCaptcha;
import com.octo.captcha.text.TextCaptchaFactory;

/**
 * A factory for mathematical operations to display as maptcha on the form.<p>
 */
public class CmsMaptchaFactory extends TextCaptchaFactory {

    /** The used random int generator. */
    private Random m_ramdom = new SecureRandom();

    /**
     * Default constructor.<p>
     */
    public CmsMaptchaFactory() {

        // nothing to do
    }

    /***
     * Returns the text captcha.<p>
     *
     * @return the text captcha
     */
    @Override
    public TextCaptcha getTextCaptcha() {

        return getTextCaptcha(Locale.getDefault());
    }

    /***
     * Returns the text captcha for the current Locale.<p>
     *
     * @param locale the current Locale
     * @return a localized text captcha
     */
    @Override
    public TextCaptcha getTextCaptcha(Locale locale) {

        // build the challenge: get 2 random int values
        int one = 0;
        int two = 0;
        while (one == 0) {
            one = m_ramdom.nextInt(11);
        }
        while (two == 0) {
            two = m_ramdom.nextInt(11);
        }

        String operator = "+";
        String result;
        // choose randomly the operation (plus, minus)
        int opInt = m_ramdom.nextInt(2);
        if (opInt == 1) {
            int swap = one;
            if (two > one) {
                one = two;
                two = swap;
            }
            operator = "-";
            result = String.valueOf(one - two);
        } else {
            result = String.valueOf(one + two);
        }

        TextCaptcha captcha = new CmsMaptcha(getQuestion(locale), one + " " + operator + " " + two, result);

        return captcha;
    }

    /**
     * Returns the localized question for the text captcha.<p>
     *
     * @param locale the current Locale
     * @return the localized question for the text captcha
     */
    protected String getQuestion(Locale locale) {

        return "";
    }
}
