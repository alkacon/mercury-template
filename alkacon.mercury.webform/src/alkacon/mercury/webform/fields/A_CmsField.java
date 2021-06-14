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

import org.opencms.i18n.CmsMessages;
import org.opencms.main.CmsLog;
import org.opencms.util.CmsStringUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.apache.commons.logging.Log;

import org.antlr.stringtemplate.StringTemplate;

/**
 * Abstract base class for all input fields.<p>
 */
public abstract class A_CmsField implements I_CmsField {

    /** Input field parameter: unique. */
    public static final String PARAM_FIELD_UNIQUE = "unique";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormHandler.class);

    private String m_dbLabel;

    private String m_errorMessage;

    private int m_fieldNr;

    private String m_infoMessage;

    private List<CmsFieldItem> m_items;
    private String m_label;
    private boolean m_mandatory;
    private String m_name;
    private Map<String, String> m_parameters;
    private int m_placeholder;
    private int m_position;
    private boolean m_subField;
    private Map<String, List<I_CmsField>> m_subFields;
    private String m_subFieldScript;
    private CmsFieldText m_text;
    private Boolean m_twoCols;
    private String m_validationExpression;
    private String m_value;

    /**
     * Default constructor.<p>
     */
    public A_CmsField() {

        super();

        m_dbLabel = "";
        m_fieldNr = 0;
        m_items = new ArrayList<>();
        m_mandatory = false;
        m_parameters = new HashMap<>();
        m_placeholder = 0;
        m_position = 0;
        m_subFields = new HashMap<>();
        m_subFieldScript = "";
        m_validationExpression = "";
        m_value = "";
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#addSubField(java.lang.String, alkacon.mercury.webform.fields.I_CmsField)
     */
    @Override
    public void addSubField(String fieldValue, I_CmsField subField) {

        List<I_CmsField> subFields = m_subFields.get(fieldValue);
        if (subFields == null) {
            subFields = new ArrayList<>();
        }
        subFields.add(subField);
        m_subFields.put(fieldValue, subFields);
    }

    /**
     * Builds the HTML input element for this element to be used in a frontend JSP.<p>
     *
     * @param formHandler the handler of the current form
     * @param messages a resource bundle containing localized messages to build the HTML element
     * @param errorKey the key of the current error message
     * @param showMandatory flag to determine if the mandatory mark should be shown or not
     * @param infoKey the key of the current info message
     *
     * @return the HTML input element for this element to be used in a frontend JSP
     */
    @Override
    public String buildHtml(
        CmsFormHandler formHandler,
        CmsMessages messages,
        String errorKey,
        boolean showMandatory,
        String infoKey) {

        String errorMessage = createStandardErrorMessage(errorKey, messages);
        return createHtml(formHandler, messages, null, getType(), null, errorMessage, showMandatory);
    }

    /**
     * Builds the HTML for sub fields of this element.<p>
     *
     * @param formHandler the handler of the current form
     * @param messages a resource bundle containing HTML snippets to build the HTML element
     * @param showMandatory flag to determine if the mandatory mark should be shown or not
     *
     * @return the HTML for sub fields of this element
     */
    public String buildSubFields(CmsFormHandler formHandler, CmsMessages messages, boolean showMandatory) {

        StringBuffer result = new StringBuffer(4096);
        StringBuffer js = new StringBuffer(256);
        // loop the defined sub field sets
        Iterator<Entry<String, List<I_CmsField>>> i = getSubFields().entrySet().iterator();
        while (i.hasNext()) {
            Map.Entry<String, List<I_CmsField>> subSet = i.next();
            String fieldValue = subSet.getKey();
            // generate ID for sub field set
            String subID = "subField-" + (getName() + fieldValue).hashCode();
            // store sub ID mapping in JS variable
            js.append("\taddWebFormSubFieldMapping(\"");
            js.append(getName()).append("\", \"").append(fieldValue).append("\", \"").append(subID);
            js.append("\");\n");
            String displayStyle = "display: none;";

            if (isActiveSubFieldList(fieldValue)) {
                // this is the currently active set of sub fields, set it in JS variable
                displayStyle = null;
                js.append("\tsetActiveWebformSubField(\"");
                js.append(getName()).append("\", \"").append(subID);
                js.append("\");\n");
            }

            // iterate the sub fields to show
            Iterator<I_CmsField> k = subSet.getValue().iterator();
            StringBuffer subFieldHtml = new StringBuffer(2048);
            while (k.hasNext()) {
                I_CmsField field = k.next();
                String errorMessage = formHandler.getErrors().get(field.getName());
                String infoMessage = formHandler.getInfos().get(field.getName());
                // validate the file upload field here already because of the lost values in these fields
                if (field instanceof CmsFileUploadField) {
                    infoMessage = field.validateForInfo(formHandler);
                }
                subFieldHtml.append(field.buildHtml(formHandler, messages, errorMessage, showMandatory, infoMessage));
            }
            // get the sub field template
            StringTemplate sTemplate = formHandler.getOutputTemplate("subfieldwrapper");
            // set template attributes
            sTemplate.setAttribute("subfields", subFieldHtml.toString());
            sTemplate.setAttribute("style", displayStyle);
            sTemplate.setAttribute("id", subID);
            result.append(sTemplate.toString());
        }
        // store JS for sub fields
        m_subFieldScript = js.toString();

        // generate the HTML output
        return result.toString();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#decodeValue(java.lang.String)
     */
    public String decodeValue(String value) {

        return value;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getCurrentSubFields()
     */
    public List<I_CmsField> getCurrentSubFields() {

        if (needsItems()) {
            // for check boxes, radio and select box, check the field items
            List<I_CmsField> result = new ArrayList<>();
            Iterator<CmsFieldItem> it = getSelectedItems().iterator();
            while (it.hasNext()) {
                CmsFieldItem item = it.next();
                if (m_subFields.containsKey(item.getValue())) {
                    result.addAll(m_subFields.get(item.getValue()));
                }
            }
            if (result.isEmpty()) {
                return null;
            }
            return result;
        } else {
            // common field
            return m_subFields.get(getValue());
        }
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getDbLabel()
     */
    public String getDbLabel() {

        return m_dbLabel;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getErrorMessage()
     */
    public String getErrorMessage() {

        return m_errorMessage;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getFieldNr()
     */
    public int getFieldNr() {

        return m_fieldNr;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getInfoMessage()
     */
    public String getInfoMessage() {

        return m_infoMessage;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getItems()
     */
    public List<CmsFieldItem> getItems() {

        return m_items;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getLabel()
     */
    public String getLabel() {

        return m_label;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getName()
     */
    public String getName() {

        return m_name;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getParameters()
     */
    public Map<String, String> getParameters() {

        return m_parameters;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getPlaceholder()
     */
    public int getPlaceholder() {

        return m_placeholder;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getPosition()
     */
    public int getPosition() {

        return m_position;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getSubFields()
     */
    public Map<String, List<I_CmsField>> getSubFields() {

        return m_subFields;
    }

    /**
     * Returns the JavaScript initialization for the sub fields.<p>
     *
     * Note: has to be called after {@link #buildSubFields(CmsFormHandler, CmsMessages, boolean)}.<p>
     *
     * @see alkacon.mercury.webform.fields.I_CmsField#getSubFieldScript()
     *
     *
     */
    public String getSubFieldScript() {

        return m_subFieldScript;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getText()
     */
    public CmsFieldText getText() {

        return m_text;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getValidationExpression()
     */
    public String getValidationExpression() {

        return m_validationExpression;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getValue()
     */
    public String getValue() {

        return m_value;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getValueEscaped()
     */
    public String getValueEscaped() {

        if (CmsStringUtil.isEmptyOrWhitespaceOnly(getValue())) {
            return null;
        }
        return CmsStringUtil.escapeHtml(getValue());
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#hasCurrentSubFields()
     */
    public boolean hasCurrentSubFields() {

        if (needsItems()) {
            // for check boxes, radio and select box, check the field items
            Iterator<CmsFieldItem> it = getSelectedItems().iterator();
            while (it.hasNext()) {
                CmsFieldItem item = it.next();
                if (m_subFields.containsKey(item.getValue())) {
                    return true;
                }
            }
            return false;
        } else {
            // common field
            return m_subFields.containsKey(getValue());
        }
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#isHasSubFields()
     */
    public boolean isHasSubFields() {

        return !m_subFields.isEmpty();
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#isHasText()
     */
    public boolean isHasText() {

        return m_text != null;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#isMandatory()
     */
    public boolean isMandatory() {

        return m_mandatory;
    }

    /**
     * This functions looks if the row should be ended. By one colsize, its
     * every time ending. By two colsize every second cell its ending.<p>
     *
     * @return true the row end should be shown
     */
    public boolean isShowRowEnd() {

        if ((isTwoCols() == null) || !isTwoCols().booleanValue()) {
            return true;
        }

        boolean result = false;
        if (m_position != 0) {
            result = true;
        }
        if (m_position == 0) {
            m_position = 1;
        } else {
            m_position = 0;
        }
        //if it needs a place holder
        if ((m_position == 1) && (m_placeholder >= 1)) {
            result = true;
            m_position = 0;
            m_placeholder--;
        }
        return result;
    }

    /**
     * This functions looks if the row should be started. By one colsize, its
     * every time starting. By two colsize every second cell its starting.<p>
    
     * @return true if the row should be shown
     */
    public boolean isShowRowStart() {

        if ((isTwoCols() == null) || !isTwoCols().booleanValue()) {
            return true;
        }
        if (m_position == 0) {
            return true;
        }
        return false;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#isSubField()
     */
    public boolean isSubField() {

        return m_subField;
    }

    /**
     * Returns if two columns should be used for webform output.<p>
     *
     * If not initialized, <code>null</code> is returned
     *
     * @return <code>true</code> if the webform should be shown in two columns, otherwise <code>false</code>
     */
    public Boolean isTwoCols() {

        return m_twoCols;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#needsItems()
     */
    public boolean needsItems() {

        return false;
    }

    /**
     * Sets the database label.<p>
     *
     * @param dbLabel the database label to set
     */
    public void setDbLabel(String dbLabel) {

        m_dbLabel = dbLabel;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setErrorMessage(java.lang.String)
     */
    public void setErrorMessage(String errorMessage) {

        m_errorMessage = errorMessage;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setFieldNr(int)
     */
    public void setFieldNr(int fieldNr) {

        m_fieldNr = fieldNr;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setInfoMessage(java.lang.String)
     */
    public void setInfoMessage(String infoMessage) {

        m_infoMessage = infoMessage;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setItems(java.util.List)
     */
    public void setItems(List<CmsFieldItem> items) {

        m_items = items;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setLabel(java.lang.String)
     */
    public void setLabel(String description) {

        m_label = description;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setMandatory(boolean)
     */
    public void setMandatory(boolean mandatory) {

        m_mandatory = mandatory;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setName(java.lang.String)
     */
    public void setName(String name) {

        m_name = name;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setParameters(java.lang.String)
     */
    public void setParameters(String parameters) {

        if (CmsStringUtil.isNotEmpty(parameters)) {
            m_parameters = CmsStringUtil.splitAsMap(parameters, "|", "=");
        }
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setPlaceholder(int)
     */
    public void setPlaceholder(int placeholder) {

        m_placeholder = placeholder;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setPosition(int)
     */
    public void setPosition(int position) {

        m_position = position;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setSubField(boolean)
     */
    public void setSubField(boolean subField) {

        m_subField = subField;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setText(CmsFieldText)
     */
    public void setText(CmsFieldText text) {

        m_text = text;
    }

    /**
     * Sets if two columns should be used for webform output.<p>
     *
     * @param twoCols <code>true</code> if the webform should be shown in two columns, otherwise <code>false</code>
     */
    public void setTwoCols(boolean twoCols) {

        m_twoCols = new Boolean(twoCols);
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setValidationExpression(java.lang.String)
     */
    public void setValidationExpression(String expression) {

        m_validationExpression = expression;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#setValue(java.lang.String)
     */
    public void setValue(String value) {

        m_value = value;
    }

    /**
     * Returns the field value as a String.<p>
     *
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {

        String result;
        if (needsItems()) {
            // check which item has been selected
            StringBuffer fieldValue = new StringBuffer(8);
            Iterator<CmsFieldItem> k = getItems().iterator();
            boolean isSelected = false;
            while (k.hasNext()) {
                CmsFieldItem currentItem = k.next();
                if (currentItem.isSelected()) {
                    if (isSelected) {
                        fieldValue.append(", ");
                    }
                    fieldValue.append(currentItem.getLabel());
                    isSelected = true;
                }
            }
            result = fieldValue.toString();
        } else {
            // for other field types, append value
            result = getValue();
        }

        return result;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#validate(CmsFormHandler)
     */
    public String validate(CmsFormHandler formHandler) {

        // validate the constraints
        String validationError = validateConstraints();

        if (CmsStringUtil.isEmpty(validationError)) {
            // no constraint or unique error, validate the input value
            validationError = validateValue();
        }

        return validationError;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#validateForInfo(CmsFormHandler)
     */
    public String validateForInfo(CmsFormHandler formHandler) {

        return "";
    }

    /**
     * Returns the HTML for the field.<p>
     *
     * @param formHandler the handler of the current form
     * @param messages a resource bundle containing localized messages to build the HTML element
     * @param stAttributes optional additional attributes for the output template
     * @param fieldType the name of the field to create
     * @param attributes optional input field attributes (has to be <code>null</code> if no attributes are used)
     * @param errorMessage the localized error message (has to be <code>null</code> if no error should be shown)
     * @param showMandatory flag to determine if the mandatory mark should be shown or not
     * @return the HTML for the field
     */
    protected String createHtml(
        CmsFormHandler formHandler,
        CmsMessages messages,
        Map<String, Object> stAttributes,
        String fieldType,
        String attributes,
        String errorMessage,
        boolean showMandatory) {

        if (isTwoCols() == null) {
            // get the two columns configuration template
            StringTemplate sTemplate = formHandler.getOutputTemplate("form_twocolumns");
            m_twoCols = Boolean.valueOf(sTemplate.toString());
        }

        // get the localized mandatory marker if necessary
        String mandatory = null;
        if (isMandatory() && showMandatory) {
            mandatory = messages.key(I_CmsFormMessages.FORM_HTML_MANDATORY);
        }

        // get the form field template
        StringTemplate sTemplate = formHandler.getOutputTemplate("field_" + fieldType);
        // first set additional attributes for the field, do this before adding the default attributes
        if (stAttributes != null) {
            sTemplate.setAttributes(stAttributes);
        }
        // set default template attributes for the field
        sTemplate.setAttribute("field", this);
        sTemplate.setAttribute("formconfig", formHandler.getFormConfiguration());
        sTemplate.setAttribute("attributes", attributes);
        sTemplate.setAttribute("errormessage", errorMessage);
        sTemplate.setAttribute("mandatory", mandatory);
        // generate the HTML output
        StringBuffer result = new StringBuffer(sTemplate.toString());
        if (isHasSubFields()) {
            result.append(buildSubFields(formHandler, messages, showMandatory));
        }
        return result.toString();
    }

    /**
     * Returns the standard error message for the field, depending on the given error key.<p>
     *
     * @param errorKey the key of the current error message
     * @param messages the resource bundle containing the localized error messages
     * @return the standard error message for the field, or <code>null</code> if no error is shown
     */
    protected String createStandardErrorMessage(String errorKey, CmsMessages messages) {

        String errorMessage = null;
        if (CmsStringUtil.isNotEmpty(errorKey)) {
            if (CmsFormHandler.ERROR_MANDATORY.equals(errorKey)) {
                errorMessage = messages.key(I_CmsFormMessages.FORM_ERROR_MANDATORY);
            } else if (CmsStringUtil.isNotEmpty(getErrorMessage())) {
                errorMessage = getErrorMessage();
            } else {
                errorMessage = messages.key(I_CmsFormMessages.FORM_ERROR_VALIDATION);
            }
        }
        return errorMessage;
    }

    /**
     * @see java.lang.Object#finalize()
     */
    @Override
    protected void finalize() throws Throwable {

        try {
            if (m_items != null) {
                m_items.clear();
            }
        } catch (Throwable t) {
            // ignore
        }
        super.finalize();
    }

    /**
     * Returns the selected items.<p>
     *
     * @return the selected items
     */
    protected List<CmsFieldItem> getSelectedItems() {

        List<CmsFieldItem> selected = new ArrayList<>();
        List<String> values = (getValue() == null ? null : CmsStringUtil.splitAsList(getValue(), ",", true));
        Iterator<CmsFieldItem> i = getItems().iterator();
        while (i.hasNext()) {
            CmsFieldItem curOption = i.next();
            if (values != null) {
                if (values.contains(curOption.getValue())) {
                    selected.add(curOption);
                }
            } else if (curOption.isSelected()) {
                selected.add(curOption);
            }
        }
        return selected;
    }

    /**
     * This function sets the cells of place holder. Its only work with
     * a column size of 2.<p>
     *
     * @param message integer value of adding to the place holder value
     */
    protected void incrementPlaceholder(String message) {

        int parse = 0;
        if (!CmsStringUtil.isEmptyOrWhitespaceOnly(message) && !message.startsWith("?")) {
            parse = Integer.parseInt(message.trim());
        }
        m_placeholder += parse;
    }

    /**
     * Returns if the list of sub fields for the given sub field value is active.<p>
     *
     * @param subFieldValue the sub field value for a list of sub fields
     *
     * @return <code>true</code> if the list of sub fields for the given sub field value is active, otherwise <code>false</code>
     */
    protected boolean isActiveSubFieldList(String subFieldValue) {

        if (needsItems()) {
            // for check boxes, radio and select box, check the field items
            Iterator<CmsFieldItem> it = getSelectedItems().iterator();
            while (it.hasNext()) {
                CmsFieldItem item = it.next();
                if (subFieldValue.equals(item.getValue())) {
                    return true;
                }
            }
        } else {
            // common field
            return subFieldValue.equals(getValue());
        }
        return false;
    }

    /**
     * Validates the constraints if this field is mandatory.<p>
     *
     * @return {@link CmsFormHandler#ERROR_MANDATORY} if a constraint is violated
     */
    protected String validateConstraints() {

        if (isMandatory()) {
            // check if the field has a value
            if (needsItems()) {
                // check if at least one item has been selected
                Iterator<CmsFieldItem> k = m_items.iterator();
                boolean isSelected = false;
                while (k.hasNext()) {
                    CmsFieldItem currentItem = k.next();
                    if (currentItem.isSelected()) {
                        isSelected = true;
                        continue;
                    }
                }

                if (!isSelected) {
                    // no item has been selected, create an error message
                    return CmsFormHandler.ERROR_MANDATORY;
                }
            } else {
                // check if the field has been filled out
                if (CmsStringUtil.isEmpty(m_value)) {
                    return CmsFormHandler.ERROR_MANDATORY;
                }
            }
        }

        return null;
    }

    /**
     * Validates the input value of this field.<p>
     *
     * @return {@link CmsFormHandler#ERROR_VALIDATION} if validation of the input value failed
     */
    protected String validateValue() {

        // validate non-empty values with given regular expression
        if (CmsStringUtil.isNotEmpty(m_value) && (!"".equals(m_validationExpression))) {
            try {
                Pattern pattern = Pattern.compile(m_validationExpression);
                if (!pattern.matcher(m_value).matches()) {
                    return CmsFormHandler.ERROR_VALIDATION;
                }
            } catch (PatternSyntaxException e) {
                // syntax error in regular expression, log to opencms.log
                if (LOG.isErrorEnabled()) {
                    LOG.error(Messages.get().getBundle().key(Messages.LOG_ERR_PATTERN_SYNTAX_0), e);
                }
            }
        }

        return null;
    }

}