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

package alkacon.mercury.webform.stringtemplates;

/** Interface, describing the "checkpage" string template, used for rendering an optional check page, with name and attributes. */
public interface I_CmsTemplateCheckPage {

    /** Name of the string template. */
    final String TEMPLATE_NAME = "checkpage";

    /** String Attribute containing the current uri (uri where the form is rendered). */
    final String ATTR_FORM_URI = "formuri";
    /** Attribute exposing the form configuration ({@link alkacon.mercury.webform.CmsForm}). */
    final String ATTR_FORM_CONFIG = "formconfig";
    /** String Attribute with the check text (with resolved macros). */
    final String ATTR_CHECKTEXT = "checktext";
    /** Attribute containing the {@link alkacon.mercury.webform.fields.CmsCaptchaField} of the form. */
    final String ATTR_CAPTCHA_FIELD = "captchafield";
    /** String attribute containing the error (mandatory or validation error) caused by the captcha field. */
    final String ATTR_CAPTCHA_ERROR = "captchaerror";
    /** Attribute with the link to the captcha image. */
    final String ATTR_CAPTCHA_IMAGE_LINK = "captchaimagelink";
    /** List attribute with {@link alkacon.mercury.webform.fields.I_CmsField} fields to check. */
    final String ATTR_CHECKFIELDS = "checkfields";
    /** String attribute for rendering the hidden fields. */
    final String ATTR_HIDDENFIELDS = "hiddenfields";
    /** String attribute with the text for the check button. */
    final String ATTR_CHECKBUTTON = "checkbutton";
    /** String attribute with the text for the correct button. */
    final String ATTR_CORRECTBUTTON = "correctbutton";

}
