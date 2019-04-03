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

/** Interface, describing the "form" string template, with name and attributes. */
public interface I_CmsTemplateForm {

    /** Name of the string template. */
    final String TEMPLATE_NAME = "form";

    /** String attribute containing the current uri (uri where the form is rendered). */
    final String ATTR_FORM_URI = "formuri";
    /** String attribute containing the encryption to use. */
    final String ATTR_ENCTYPE = "enctype";
    /** String attribute containing the error message to display with the form. */
    final String ATTR_ERRORMESSAGE = "errormessage";
    /** String attribute containing the mandatory message to display with the form. */
    final String ATTR_MANDATORYMESSAGE = "mandatorymessage";
    /** Attribute exposing the form configuration ({@link alkacon.mercury.webform.CmsForm}). */
    final String ATTR_FORM_CONFIG = "formconfig";
    /** String attribute with field HTML generated for the fields. */
    final String ATTR_FIELDS = "fields";
    /** String attribute with the JavaScript to be added for subfields. */
    final String ATTR_SUBFIELD_JS = "subfieldjs";
    /** String attribute for rendering the hidden fields. */
    final String ATTR_HIDDENFIELDS = "hiddenfields";
    /** String attribute with the text for the reset button. */
    final String ATTR_RESETBUTTON = "resetbutton";
    /** String attribute with the text for the previous button. */
    final String ATTR_PREVBUTTON = "prevbutton";
    /** String attribute with the text for the submit button. */
    final String ATTR_SUBMITBUTTON = "submitbutton";
    /** String attribute with the waitlist notification text. */
    final String ATTR_WAITLISTMESSAGE = "waitlistmessage";

}
