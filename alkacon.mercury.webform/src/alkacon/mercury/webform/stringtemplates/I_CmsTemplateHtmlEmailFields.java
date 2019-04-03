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

/** Interface, describing the "htmlemailfields" string template, with name, attributes and relevant message keys. */
public interface I_CmsTemplateHtmlEmailFields {

    /** Name of the string template. */
    final String TEMPLATE_NAME = "htmlemailfields";

    /** Attribute to output the mail css. */
    final String ATTR_MAIL_CSS = "mailcss";
    /** Attribute exposing the list of fields. */
    final String ATTR_FIELDS = "fields";
}
