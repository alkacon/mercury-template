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

import alkacon.mercury.webform.CmsFormHandler;
import alkacon.mercury.webform.I_CmsFormMessages;
import alkacon.mercury.webform.fields.A_CmsField;
import org.opencms.i18n.CmsEncoder;
import org.opencms.i18n.CmsMessages;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.I_CmsMacroResolver;

/**
 * Represents a text area.<p>
 */
public class CmsTextareaField extends A_CmsField {

    /** HTML field type: text area. */
    private static final String TYPE = "textarea";

    /**
     * Returns the type of the input field, e.g. "text" or "select".<p>
     *
     * @return the type of the input field
     */
    public static String getStaticType() {

        return TYPE;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#buildHtml(CmsFormHandler, CmsMessages, String, boolean, String)
     */
    @Override
    public String buildHtml(
        CmsFormHandler formHandler,
        CmsMessages messages,
        String errorKey,
        boolean showMandatory,
        String infoKey) {

        String errorMessage = createStandardErrorMessage(errorKey, messages);
        String attributes = null;

        if (CmsStringUtil.isNotEmpty(errorKey)
            && !CmsFormHandler.ERROR_MANDATORY.equals(errorKey)
            && CmsStringUtil.isNotEmpty(getErrorMessage())
            && (getErrorMessage().indexOf(I_CmsMacroResolver.MACRO_DELIMITER) == 0)) {
            // there are additional field attributes defined in the error message of the field
            attributes = " " + getErrorMessage().substring(2, getErrorMessage().length() - 1);
            errorMessage = null;
        }

        String result = createHtml(formHandler, messages, null, getType(), attributes, errorMessage, showMandatory);
        // sets the cell numbers for the place holders in two column layout
        incrementPlaceholder(messages.key(I_CmsFormMessages.FORM_HTML_MULTILINE_PLACEHOLDER));
        return result;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getType()
     */
    @Override
    public String getType() {

        return TYPE;
    }

    /**
     * Returns the XML escaped value of the field.<p>
     *
     * @see alkacon.mercury.webform.fields.A_CmsField#getValueEscaped()
     */
    @Override
    public String getValueEscaped() {

        return CmsEncoder.escapeXml(getValue());
    }

}
