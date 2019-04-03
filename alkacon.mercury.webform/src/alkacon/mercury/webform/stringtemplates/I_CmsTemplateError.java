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

/** Interface, describing the error string template, used if the requested string template is not found, with attributes.
 *
 * NOTE: The template has no name, since it is in a separate file the only template.
 */
public interface I_CmsTemplateError {

    /** String attribute containing the headline of the error. */
    final String ATTR_ERROR_HEADLINE = "errorheadline";
    /** String attribute containing the text of the error. */
    final String ATTR_ERROR_TEXT = "errortext";
    /** Set attribute containing the available template names. */
    final String ATTR_ERROR_TEMPLATE_NAMES = "errortemplatenames";
}
