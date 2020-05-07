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

package alkacon.mercury.webform.fields;

import org.opencms.util.CmsStringUtil;

/**
 * Represents a text input field for an email address.<p>
 */
public class CmsEmailField extends CmsTextField {

    /** HTML field type: email field. */
    private static final String TYPE = "email";

    /** Regular expression to validate email addresses. */
    public static final String VALIDATION_REGEX = "^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$";

    /**
     * Returns the type of the input field, e.g. "text" or "select".<p>
     *
     * @return the type of the input field
     */
    public static String getStaticType() {

        return TYPE;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getType()
     */
    @Override
    public String getType() {

        return TYPE;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getValue()
     */
    @Override
    public String getValue() {

        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(super.getValue())) {
            return super.getValue().toLowerCase();
        }
        return super.getValue();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getValueEscaped()
     */
    @Override
    public String getValueEscaped() {

        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(getValue())) {
            return CmsStringUtil.escapeHtml(getValue());
        }
        return super.getValueEscaped();
    }

}
