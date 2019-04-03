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

/** Interface, describing the "form_js" string template, used for rendering an optional check page, with name and attributes. */
public interface I_CmsTemplateFormJs {

    /** Name of the string template. */
    final String TEMPLATE_NAME = "form_js";

    /** Attribute exposing the form configuration ({@link alkacon.mercury.webform.CmsForm}). */
    final String ATTR_FORM_CONFIG = "formconfig";
    /** String attribute with the link to the session js. */
    final String ATTR_SESSION_JS = "sessionjs";
    /** String attribute with the link to the keepsession.jsp. */
    final String ATTR_SESSION_URI = "sessionuri";
    /** String attribute with the link to the subfields.js. */
    final String ATTR_SUBFIELD_JS = "subfieldjs";

}
