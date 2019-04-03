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

/** Interface, describing the "fullybooked" string template, with name and attributes. */
public interface I_CmsTemplateFullyBooked {

    /** Name of the string template. */
    final String TEMPLATE_NAME = "fullybooked";

    /** Attribute to output the text of the fully booked information. */
    final String ATTR_TEXT = "text";
    /** Attribute to output the headline of the fully booked information. */
    final String ATTR_HEADLINE = "headline";

}
