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
import alkacon.mercury.webform.fields.CmsEmptyField;
import alkacon.mercury.webform.fields.CmsFieldItem;
import alkacon.mercury.webform.fields.CmsSelectionField;
import alkacon.mercury.webform.fields.CmsTextField;
import org.opencms.i18n.CmsEncoder;
import org.opencms.i18n.CmsMessages;
import org.opencms.util.CmsStringUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Represents a parameter field.<p>
 */
public class CmsParameterField extends A_CmsField {

    /** HTML field type: parameter field. */
    private static final String TYPE = "parameter";

    /**
     * Returns the configured form field values as hidden input fields.<p>
     * @param reqParams Map holding the http request parameters
     * @param params Map holding the http request parameters
     * @return the configured form field values as hidden input fields
     */
    public static String createHiddenFields(Map<String, String[]> reqParams, Map<String, String> params) {

        // Write request parameters to hidden fields
        StringBuffer result = new StringBuffer(reqParams.size() * 8);
        Set<String> keys = params.keySet();

        //check if parameter(s) have been set in webform
        if (!params.isEmpty() && !(reqParams.isEmpty())) {
            //Iterate over parameters
            //            Set<String> keys = params.keySet();
            for (String key : keys) {
                String[] paramArray = reqParams.get(key);
                if (paramArray != null) {
                    for (int i = 0; i < paramArray.length; i++) {
                        result.append("<input type=\"hidden\" name=\"");
                        result.append(CmsEncoder.escapeXml(key));
                        result.append("\" value=\"");
                        result.append(CmsEncoder.escapeXml(paramArray[i]));
                        result.append("\" />\n");
                    }
                }
            }
        }

        // return generated result list
        return result.toString();
    }

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

        // Preset stringTemplate type to "empty" form field, if parameter is not defined or has no value
        String type = CmsEmptyField.getStaticType();

        // get predefined parameter(s) from webform
        Map<String, String> params = getParameters();
        // get parameters from HTTP request
        Map<String, String[]> reqParams = formHandler.getParameterMap();
        // New map to take only the request parameters matching the "parameter" webform field
        Map<String, String[]> paramsForHiddenFields = new HashMap<>();
        //check if parameter(s) have been set in webform
        if (!params.isEmpty()) {
            //Iterate over parameters
            Set<String> keys = params.keySet();
            for (String key : keys) {
                if (reqParams.containsKey(key)) {
                    String[] paramsRequest = reqParams.get(key);
                    paramsForHiddenFields.put(key, paramsRequest);
                    // check if a single value has been passed or multiple (or empty)
                    int length = paramsRequest.length;
                    List<String> paramValues = new ArrayList<>(length);
                    for (int i = 0; i < length; i++) {
                        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(paramsRequest[i])
                            && !paramValues.contains(paramsRequest[i])) {
                            paramValues.add(paramsRequest[i]);
                        }
                    }

                    if (paramValues.size() > 1) {
                        String[] selectedValue = null;
                        if (reqParams.containsKey(getName())) {
                            selectedValue = reqParams.get(getName());
                        }
                        // parameter has more than one value -> SelectBox
                        type = CmsSelectionField.getStaticType();
                        String value = "";
                        String label = messages.key(I_CmsFormMessages.PARAMETER_FIELD_SELECTBOX);
                        List<CmsFieldItem> items = new ArrayList<>(length + 1);
                        items.add(new CmsFieldItem(value, label, false, false));
                        // while
                        for (String paramValue : paramValues) {
                            if (!isAscii(paramValue)) {
                                paramValue = decode(paramValue);
                            }
                            value = CmsEncoder.escapeXml(paramValue);
                            label = value;
                            boolean isSelected = false;
                            if (selectedValue != null) {
                                if (value.equals(selectedValue[0])) {
                                    isSelected = true;
                                }
                            }
                            items.add(new CmsFieldItem(value, label, isSelected, false));

                        }
                        setItems(items);
                    } else {
                        // parameter has a single value -> display as editable text
                        type = CmsTextField.getStaticType();
                        String value = paramValues.get(0);
                        if (!isAscii(value)) {
                            value = decode(value);
                        }
                        setValue(CmsEncoder.escapeXml(value));
                        setMandatory(false);
                    }
                } else {
                    // pre-defined parameter not found in request parameters.
                    type = CmsTextField.getStaticType();
                    setValue(CmsEncoder.escapeXml(""));
                    setMandatory(false);
                }
            }
        }
        // create error message
        String errorMessage = createStandardErrorMessage(errorKey, messages);

        // create HTML and append hidden fields to pass request params;
        String result = createHtml(formHandler, messages, null, type, null, errorMessage, showMandatory);
        result += requestParamsToHiddenFields(paramsForHiddenFields);
        return result;
    }

    /**
     * Checks if a string contains undefined characters indicating an UTF-8 encoding<p>
     * @param in the input string the handler of the current form
     * @return if the input string contains undefined characters
     */
    public boolean containsUndefinedCharacters(String in) {

        boolean check = false;

        for (int i = 0; i < in.length(); i++) {
            char c = in.charAt(i);
            if ((128 < c) && (c < 191)) {
                return true;
            } else {
                check = false;
            }
        }
        return check;
    }

    /**
     * Decodes a UTF-8 string<p>
     * @param in the input UTF-8 string
     * @return The decoded string
     */
    public String decode(String in) {

        StringBuffer buf = new StringBuffer();

        for (int i = 0; i < in.length(); i++) {
            char c = in.charAt(i);
            if ((31 < c) && (c < 127)) {
                buf.append(c);
            } else {
                if (containsUndefinedCharacters(in)) {
                    // String probably UTF-8 encoded
                    byte[] u = new byte[2];
                    u[0] = (byte)c;
                    if (i < in.length()) {
                        u[1] = (byte)in.charAt(i + 1);
                        i++;
                    } else {
                        u[1] = 0;
                    }
                    String value = CmsEncoder.createString(u, CmsEncoder.ENCODING_UTF_8);
                    buf.append(value);
                } else {
                    // String probably contains ANSI code extending the ASCII code
                    buf.append(c);
                }
            }
        }

        return buf.toString();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getType()
     */
    @Override
    public String getType() {

        return TYPE;
    }

    /**
     * Checks if a string contains only ASCII characters<p>
     * @param in the input string the handler of the current form
     * @return if the input string contains only ASCII characters
     */
    public boolean isAscii(String in) {

        boolean check = false;

        for (int i = 0; i < in.length(); i++) {
            char c = in.charAt(i);
            if ((31 < c) && (c < 127)) {
                check = true;
            } else {
                return false;
            }
        }
        return check;
    }

    /**
     * Returns the configured form field values as hidden input fields.<p>
     * @param reqParams Map holding the http request parameters
     * @return the configured form field values as hidden input fields
     */
    public String requestParamsToHiddenFields(Map<String, String[]> reqParams) {

        // Write request parameters to hidden fields
        StringBuffer result = new StringBuffer(reqParams.size() * 8);
        Set<String> keys = reqParams.keySet();
        for (String key : keys) {
            String[] paramArray = reqParams.get(key);
            for (int i = 0; i < paramArray.length; i++) {
                result.append("<input type=\"hidden\" name=\"");
                result.append(CmsEncoder.escapeXml(key));
                result.append("\" value=\"");
                result.append(CmsEncoder.escapeXml(paramArray[i]));
                result.append("\" />\n");
            }
        }
        // return generated result list
        return result.toString();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#validate(CmsFormHandler)
     */
    @Override
    public String validate(CmsFormHandler formHandler) {

        // validate the constraints
        String validationError = validateConstraints(formHandler);

        if (CmsStringUtil.isEmpty(validationError)) {
            // no constraint or unique error, validate the input value
            validationError = validateValue();
        }

        return validationError;
    }

    /**
     * Checks if the mandatory field has to be evaluated<p>
     * @param formHandler the handler of the current form
     * @return if the mandatory flag has to be evaluated (if select box is displayed)
     */
    protected boolean evaluateMandatory(CmsFormHandler formHandler) {

        boolean mandatory = false;
        // get predefined parameter(s) from webform
        Map<String, String> params = getParameters();
        // get parameters from HTTP request
        Map<String, String[]> reqParams = formHandler.getParameterMap();
        //check if parameter(s) have been set in webform
        if (!params.isEmpty()) {
            //Iterate over parameters
            Set<String> keys = params.keySet();
            for (String key : keys) {
                if (reqParams.containsKey(key)) {
                    String[] paramArray = reqParams.get(key);
                    // check if a single value has been passed or multiple (or empty)
                    if (paramArray.length > 1) {
                        mandatory = true;
                    } else {
                        // set mandatory to false
                        mandatory = false;
                    }
                } else {
                    mandatory = false;
                }
            }
        }

        return mandatory;
    }

    /**
     * @see alkacon.mercury.webform.fields.A_CmsField#validateConstraints()
     * @param formHandler Map holding the http request parameters
     * @return the configured form field values as hidden input fields
     */
    protected String validateConstraints(CmsFormHandler formHandler) {

        // check first, if mandatory flag has to be evaluated
        if (evaluateMandatory(formHandler)) {
            return super.validateConstraints();
        } else {
            return null;
        }
    }
}
