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

import alkacon.mercury.webform.fields.CmsFieldItem;
import alkacon.mercury.webform.fields.CmsSelectionField;
import alkacon.mercury.webform.fields.I_CmsHasHiddenFieldHtml;

/**
 * Selection field which does not send the actual option values to the client, but only their MD5 hashes.
 */
public class CmsEmailSelectionField extends CmsSelectionField implements I_CmsHasHiddenFieldHtml {

    /**
     * Gets the static type.<p>
     * 
     * @return the type 
     */
    public static final String getStaticType() {

        return "email_select";
    }

    /**
     * @see alkacon.mercury.webform.fields.A_CmsField#setValue(java.lang.String)
     */
    @Override
    public void setValue(String value) {

        if (value == null) {
            super.setValue(null);
        } else {
            for (CmsFieldItem item : getItems()) {
                item.setSelected(false);
            }
            for (CmsFieldItem item : getItems()) {
                if (item.getValue().equals(value)) {
                    item.setSelected(true);
                }
            }
            super.setValue(value);
        }
    }

    /**
     * @see alkacon.mercury.webform.fields.A_CmsField#decodeValue(java.lang.String)
     */
    @Override
    public String decodeValue(String value) {

        if (value != null) {
            for (CmsFieldItem item : getItems()) {
                if (value.equals(item.getValueHash())) {
                    return item.getValue();
                }
            }
        }
        return null;
    }

    /**
     * @see alkacon.mercury.webform.fields.CmsSelectionField#getType()
     */
    @Override
    public String getType() {

        return getStaticType();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsHasHiddenFieldHtml#getHiddenFieldHtml()
     */
    public String getHiddenFieldHtml() {

        StringBuffer result = new StringBuffer();
        result.append("<input type=\"hidden\" name=\"");
        result.append(getName());
        result.append("\" value=\"");
        result.append(CmsFieldItem.getHash(getValue()));
        result.append("\" />\n");
        return result.toString();

    }
}
