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

package alkacon.mercury.webform;

import alkacon.mercury.webform.fields.CmsCaptchaField;
import alkacon.mercury.webform.fields.CmsCheckboxField;
import alkacon.mercury.webform.fields.CmsEmptyField;
import alkacon.mercury.webform.fields.CmsFieldItem;
import alkacon.mercury.webform.fields.CmsFileUploadField;
import alkacon.mercury.webform.fields.CmsHiddenField;
import alkacon.mercury.webform.fields.CmsPagingField;
import alkacon.mercury.webform.fields.CmsParameterField;
import alkacon.mercury.webform.fields.CmsPasswordField;
import alkacon.mercury.webform.fields.CmsPrivacyField;
import alkacon.mercury.webform.fields.CmsTextField;
import alkacon.mercury.webform.fields.I_CmsField;
import alkacon.mercury.webform.fields.I_CmsHasHiddenFieldHtml;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateCheckPage;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateConfirmationPage;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateError;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateForm;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateFormJs;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateFullyBooked;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateHtmlEmail;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateHtmlEmailFields;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateInitError;
import alkacon.mercury.webform.stringtemplates.I_CmsTemplateSubmissionError;

import org.opencms.cache.CmsVfsMemoryObjectCache;
import org.opencms.file.CmsFile;
import org.opencms.file.CmsProperty;
import org.opencms.file.CmsResource;
import org.opencms.i18n.CmsEncoder;
import org.opencms.i18n.CmsMessages;
import org.opencms.i18n.CmsMultiMessages;
import org.opencms.jsp.CmsJspActionElement;
import org.opencms.jsp.util.CmsJspStandardContextBean;
import org.opencms.mail.CmsHtmlMail;
import org.opencms.mail.CmsSimpleMail;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.module.CmsModule;
import org.opencms.util.CmsByteArrayDataSource;
import org.opencms.util.CmsDateUtil;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsRequestUtil;
import org.opencms.util.CmsStringUtil;
import org.opencms.workplace.CmsWorkplace;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.Writer;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.logging.Log;
import org.apache.commons.mail.EmailException;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateErrorListener;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.antlr.stringtemplate.language.DefaultTemplateLexer;

/**
 * The form handler controls the HTML or mail output of a configured email form.<p>
 *
 * Provides methods to determine the action that takes place and methods to create different
 * output formats of a submitted form.<p>
 *
 */
public class CmsFormHandler extends CmsJspActionElement {

    /** Request parameter value for the form action parameter: correct the input. */
    public static final String ACTION_CONFIRMED = "confirmed";

    /** Request parameter value for the form action parameter: correct the input. */
    public static final String ACTION_CORRECT_INPUT = "correct";

    /** Request parameter value for the form action parameter: form submitted. */
    public static final String ACTION_SUBMIT = "submit";

    /** Name of the file item session attribute. */
    public static final String ATTRIBUTE_FILEITEMS = "fileitems";

    /** Configuration key name for the 'end time' of an event. */
    public static final String CONFIG_END_TIME = "EndTime";

    /** Form error: mandatory field not filled out. */
    public static final String ERROR_MANDATORY = "mandatory";

    /** Error: failed to save form data in the XML-content. */
    public static final String ERROR_STORE_FORMDATA = "storedata";

    /** Form error: unique error of input. */
    public static final String ERROR_UNIQUE = "unique";

    /** Form error: validation error of input. */
    public static final String ERROR_VALIDATION = "validation";

    /** Form info: mandatory upload field filled out already. */
    public static final String INFO_UPLOAD_FIELD_MANDATORY_FILLED_OUT = "uploadfield_mandatory_filled_out";

    /** Macro name for the waitlist information macro that can be used in registration mail text fields. */
    public static final String MACRO_EVENT_WAITLIST_INFO = "event.waitlist.info";

    /** Macro name for the date macro that can be used in mail text fields. */
    public static final String MACRO_DATE = "date";

    /** Macro name for the form data macro that can be used in mail text fields. */
    public static final String MACRO_FORMDATA = "formdata";

    /** Macro name for the locale macro that can be used in mail text fields. */
    public static final String MACRO_LOCALE = "locale";

    /** Macro prefix for field values. */
    public static final String MACRO_PREFIX_VALUE = "value_";

    /** Macro name for the url macro that can be used in mail text fields. */
    public static final String MACRO_URL = "url";

    /** Request parameter name for the back parameter. */
    public static final String PARAM_BACK = "back";

    /** Request parameter name for the final page parameter. */
    public static final String PARAM_FINALPAGE = "finalpage";

    /** Request parameter name for the hidden form action parameter to determine the action. */
    public static final String PARAM_FORMACTION = "formaction";

    /** Request parameter name for the page parameter. */
    public static final String PARAM_PAGE = "page";

    /** Request parameter uri for the page parameter. */
    public static final String PARAM_URI = "uri";

    /** Prefix for encrypted String values. */
    public static final String PREFIX_ENCRYPTED = "encrypted:";

    /** The module path of the webform module. */
    static final String MODULE_PATH = CmsWorkplace.VFS_PATH_MODULES + CmsForm.MODULE_NAME + "/";

    /** Path to the captcha.jsp. */
    static final String PATH_CAPTCHA_JSP = MODULE_PATH + "elements/captcha.jsp";

    /** Path to the keepsession.js. */
    static final String PATH_KEEP_SESSION_JS = MODULE_PATH + "resources/js/keepsession.js";

    /** Path to the keepsession.jsp. */
    static final String PATH_KEEP_SESSION_JSP = MODULE_PATH + "elements/keepsession.jsp";

    /** Path to the subfields.js. */
    static final String PATH_SUBFIELDS_JS = MODULE_PATH + "resources/js/subfields.js";

    /** Prefix for dynamic config values that should be used as macros. */
    private static final String DYNAMIC_CONFIG_PREFIX_MACRO = "macro:";

    /** Error that happened when the confirmation mail was tried to send. */
    private static final String ERROR_CONFIRMATION_SENT = "confirmationsent";

    /** Error that happened when the confirmation mail was tried to send. */
    private static final String ERROR_REGISTRATION_SENT = "registrationsent";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormHandler.class);

    /**
     * Gets the truncated file item name. Some clients, such as the Opera browser, do include path information.
     * This method only returns the the base file name.<p>
     *
     * @param name the file item name
     *
     * @return the truncated file item name
     */
    public static String getTruncatedFileItemName(String name) {

        // here is not used the File.separator, because there are problems is the
        // OpenCms OS and the explores OS are different
        // for example if you have an OpenCms on Unix and you use the
        // formgenerator in a browser in Windows
        if (name.contains("/")) {
            int lastIndex = name.lastIndexOf("/");
            if (name.length() > lastIndex) {
                name = name.substring(lastIndex + 1);
                return name;
            }
        } else if (name.contains("\\")) {
            int lastIndex = name.lastIndexOf("\\");
            if (name.length() > lastIndex) {
                name = name.substring(lastIndex + 1);
                return name;
            }
        }
        return name;
    }

    /** Contains eventual validation errors. */
    protected Map<String, String> m_errors;

    /** The form configuration object. */
    protected CmsForm m_formConfiguration;

    /** Temporarily stores the fields as hidden fields in the String. */
    protected String m_hiddenFields;

    /** Contains eventual validation infos. */
    protected Map<String, String> m_infos;

    /** Flag indicating if the form is displayed for the first time. */
    protected boolean m_initial;

    /** Flag indicating if the form handler configuration has been initialized successfully. */
    protected boolean m_initSuccess;

    /** Boolean indicating if the form is validated correctly. */
    protected Boolean m_isValidatedCorrect;

    /** Needed to implant form fields into the mail text. */
    protected transient CmsMacroResolver m_macroResolver;

    /** The localized messages for the form handler. */
    protected CmsMultiMessages m_messages;

    /** The multipart file items. */
    protected List<FileItem> m_multipartFileItems;

    /** The templates for the web form output. */
    protected StringTemplateGroup m_outputTemplates;

    /** The map of request parameters. */
    protected Map<String, String[]> m_parameterMap;

    /** The submission status of the form. Initialized lazily. */
    protected CmsSubmissionStatus m_submissionStatus;

    /** For the case of bookable events, this is the end time of the event, otherwise null. */
    private Long m_endTime;

    /**
     * Empty constructor, be sure to call one of the available initialization methods afterwards.<p>
     *
     * Possible initialization methods are:<p>
     * <ul>
     * <li>{@link #init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link #init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     */
    public CmsFormHandler() {

        super();
        m_errors = new HashMap<>();
        m_infos = new HashMap<>();
    }

    /**
     * Adds the field specific macros to the resolver.
     * @param resolver the resolver to which the macros should be added.
     * @param fields the fields, for which the macros should be added.
     * @param specialUploadHandling flag, indicating if the values for upload fields should be handled special.
     */
    void addFieldMacros(CmsMacroResolver resolver, Collection<I_CmsField> fields, boolean specialUploadHandling) {

        Iterator<I_CmsField> itFields = fields.iterator();
        // add field values as macros
        while (itFields.hasNext()) {
            I_CmsField field = itFields.next();
            if (field instanceof CmsPagingField) {
                continue;
            }
            String fValue = field.toString();
            if (specialUploadHandling && (field instanceof CmsFileUploadField)) {
                if (CmsStringUtil.isEmptyOrWhitespaceOnly(fValue)) {
                    // try to read upload item from session attribute
                    FileItem fileItem = getUploadFile(field);
                    if (fileItem != null) {
                        fValue = fileItem.getName();
                    }
                }
                fValue = CmsFormHandler.getTruncatedFileItemName(fValue);
            }
            resolver.addMacro(field.getLabel(), fValue);
            resolver.addMacro(MACRO_PREFIX_VALUE + field.getLabel(), field.getValue());
            if (!field.getLabel().equals(field.getDbLabel())) {
                resolver.addMacro(field.getDbLabel(), fValue);
                resolver.addMacro(MACRO_PREFIX_VALUE + field.getDbLabel(), field.getValue());
            }
        }
    }

    /**
     * Adds on the first position the given messages.<p>
     *
     * @param messages the localized messages
     */
    public void addMessages(CmsMessages messages) {

        CmsMultiMessages tmpOld = m_messages;
        m_messages = new CmsMultiMessages(messages.getLocale());
        m_messages.addMessages(messages);
        if (tmpOld != null) {
            m_messages.addMessages(tmpOld.getMessages());
        }
        tmpOld = null;
    }

    /**
     * Returns the HTML for the optional form check page, generated by using the given string template file.<p>
     *
     * @return the HTML for the optional form check page, generated by using the given string template file
     */
    protected String buildCheckHtml() {

        // create the check page
        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateCheckPage.TEMPLATE_NAME);
        // set the necessary attributes to use in the string template
        String formUri = getCmsObject().getRequestContext().getUri();
        if (CmsJspStandardContextBean.getInstance(getRequest()).isDetailRequest()) {
            formUri = CmsJspStandardContextBean.getInstance(getRequest()).getDetailContentSitePath();
        }
        sTemplate.setAttribute(
            I_CmsTemplateCheckPage.ATTR_FORM_URI,
            OpenCms.getLinkManager().substituteLink(getCmsObject(), formUri));
        sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_FORM_CONFIG, getFormConfiguration());
        sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_CHECKTEXT, getFormCheckText());

        CmsCaptchaField captchaField = getFormConfiguration().getCaptchaField();
        sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_CAPTCHA_FIELD, captchaField);
        if (captchaField != null) {
            // do this only if a captcha field is configured
            String errorMessage = getErrors().get(captchaField.getName());
            if (errorMessage != null) {
                // create the error message for the field
                if (CmsFormHandler.ERROR_MANDATORY.equals(errorMessage)) {
                    errorMessage = getMessages().key(I_CmsFormMessages.FORM_ERROR_MANDATORY);
                } else {
                    errorMessage = getMessages().key(I_CmsFormMessages.FORM_ERROR_VALIDATION);
                }
            }
            sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_CAPTCHA_ERROR, errorMessage);
            String tokenId = getParameter(CmsCaptchaField.C_PARAM_CAPTCHA_TOKEN_ID);
            if (tokenId.isEmpty()) {
                tokenId = UUID.randomUUID().toString();
            }
            sTemplate.setAttribute(
                I_CmsTemplateCheckPage.ATTR_CAPTCHA_IMAGE_LINK,
                OpenCms.getLinkManager().substituteLink(
                    getCmsObject(),
                    PATH_CAPTCHA_JSP
                        + "?"
                        + captchaField.getCaptchaSettings().toRequestParams(getCmsObject())
                        + "&"
                        + CmsCaptchaField.C_PARAM_CAPTCHA_TOKEN_ID
                        + "="
                        + tokenId));
            sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_CAPTCHA_TOKEN_ID, tokenId);
        }

        List<I_CmsField> fields = getFormConfiguration().getAllFields(true, false, false);
        List<I_CmsField> checkFields = new ArrayList<>(fields.size());
        for (int i = 0, n = fields.size(); i < n; i++) {
            I_CmsField current = fields.get(i);
            if ((!CmsHiddenField.class.isAssignableFrom(current.getClass())
                && !CmsCaptchaField.class.isAssignableFrom(current.getClass()))) {

                // only show the empty field in the confirmation mail, if it is marked as mandatory
                if (((current instanceof CmsEmptyField) && (!current.isMandatory()))
                    || (current instanceof CmsPagingField)) {
                    continue;
                }
                String label = current.getLabel();
                if (current instanceof CmsEmptyField) {
                    label = "";
                }
                String value = current.toString();
                if (current instanceof CmsPasswordField) {
                    value = value.replaceAll(".", "*");
                } else if (current instanceof CmsFileUploadField) {
                    if (CmsStringUtil.isEmptyOrWhitespaceOnly(value)) {
                        // try to read upload item from session attribute
                        FileItem fileItem = getUploadFile(current);
                        if (fileItem != null) {
                            value = fileItem.getName();
                        }
                    }
                    value = CmsFormHandler.getTruncatedFileItemName(value);
                    value = convertToHtmlValue(value);
                } else if (current instanceof CmsEmptyField) {
                    // do nothing
                } else {
                    value = convertToHtmlValue(value);
                }
                I_CmsField checkField = new CmsTextField();
                checkField.setLabel(label);
                checkField.setValue(value);
                checkFields.add(checkField);
            }
        }
        sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_CHECKFIELDS, checkFields);
        sTemplate.setAttribute(I_CmsTemplateCheckPage.ATTR_HIDDENFIELDS, createHiddenFields());
        sTemplate.setAttribute(
            I_CmsTemplateCheckPage.ATTR_CHECKBUTTON,
            getMessages().key(I_CmsFormMessages.FORM_BUTTON_CHECKED));
        sTemplate.setAttribute(
            I_CmsTemplateCheckPage.ATTR_CORRECTBUTTON,
            getMessages().key(I_CmsFormMessages.FORM_BUTTON_CORRECT));
        return sTemplate.toString();
    }

    /**
     * Returns the HTML for the form confirmation page, generated by using the given string template file.<p>
     *
     * @return the HTML for the form confirmation page, generated by using the given string template file
     */
    protected String buildConfirmHtml() {

        // create the confirmation page
        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateConfirmationPage.TEMPLATE_NAME);
        // set the necessary attributes to use in the string template
        sTemplate.setAttribute(I_CmsTemplateConfirmationPage.ATTR_FORM_CONFIG, getFormConfiguration());
        sTemplate.setAttribute(I_CmsTemplateConfirmationPage.ATTR_CONFIRMATIONTEXT, getFormConfirmationText());
        // generate the list of fields to display
        List<I_CmsField> fields = getFormConfiguration().getAllFields(true, false, true);
        List<I_CmsField> confirmFields = new ArrayList<>(fields.size());

        for (int i = 0, n = fields.size(); i < n; i++) {
            I_CmsField current = fields.get(i);
            if (CmsHiddenField.class.isAssignableFrom(current.getClass())
                || CmsPrivacyField.class.isAssignableFrom(current.getClass())
                || CmsCaptchaField.class.isAssignableFrom(current.getClass())
                || CmsPagingField.class.isAssignableFrom(current.getClass())) {
                continue;
            }

            // only show the empty field in the confirmation mail, if it is marked as mandatory
            if ((current instanceof CmsEmptyField) && (!current.isMandatory())) {
                continue;
            }

            String label = current.getLabel();
            if (current instanceof CmsEmptyField) {
                label = "";
            }
            String value = current.toString();
            if (current instanceof CmsPasswordField) {
                value = value.replaceAll(".", "*");
            } else if (current instanceof CmsFileUploadField) {
                if (CmsStringUtil.isEmptyOrWhitespaceOnly(value)) {
                    // try to read upload item from session attribute
                    FileItem fileItem = getUploadFile(current);
                    if (fileItem != null) {
                        value = fileItem.getName();
                    }
                }
                value = CmsFormHandler.getTruncatedFileItemName(value);
                value = convertToHtmlValue(value);
            } else if (current instanceof CmsEmptyField) {
                // do nothing
            } else {
                value = convertToHtmlValue(value);
            }
            // if label and value is not set, skip it
            if (CmsStringUtil.isEmpty(label) && CmsStringUtil.isEmpty(value)) {
                continue;
            }
            I_CmsField confirmField = new CmsTextField();
            confirmField.setLabel(label);
            confirmField.setValue(value);
            confirmFields.add(confirmField);
        }
        sTemplate.setAttribute(I_CmsTemplateConfirmationPage.ATTR_CONFIRMFIELDS, confirmFields);
        return sTemplate.toString();
    }

    /**
     * Returns the HTML to render if form submission failed.
     * @return the HTML to render if form submission failed.
     */
    protected String buildFailureHtml() {

        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateSubmissionError.TEMPLATE_NAME);
        if (getErrors().containsKey(ERROR_STORE_FORMDATA)) {
            sTemplate.setAttribute(
                I_CmsTemplateSubmissionError.ATTR_HEADLINE,
                getMessages().key(I_CmsFormMessages.FORM_ERROR_DB_HEADLINE));
            sTemplate.setAttribute(
                I_CmsTemplateSubmissionError.ATTR_TEXT,
                getMessages().key(I_CmsFormMessages.FORM_ERROR_DB_TEXT));
            sTemplate.setAttribute(I_CmsTemplateSubmissionError.ATTR_ERROR, getErrors().get(ERROR_STORE_FORMDATA));
        } else {
            sTemplate.setAttribute(
                I_CmsTemplateSubmissionError.ATTR_HEADLINE,
                getMessages().key(I_CmsFormMessages.FORM_ERROR_MAIL_HEADLINE));
            sTemplate.setAttribute(
                I_CmsTemplateSubmissionError.ATTR_TEXT,
                getMessages().key(I_CmsFormMessages.FORM_ERROR_MAIL_TEXT));
            sTemplate.setAttribute(I_CmsTemplateSubmissionError.ATTR_ERROR, getErrors().get(ERROR_REGISTRATION_SENT));
        }
        return sTemplate.toString();
    }

    /**
     * Returns the HTML for the input form, generated by using the given string template file.<p>
     *
     * @return the HTML for the input form, generated by using the given string template file
     */
    protected String buildFormHtml() {

        // determine if form type has to be set to "multipart/form-data" in case of upload fields
        String encType = null;
        for (I_CmsField field : getFormConfiguration().getAllFields(false, true, false)) {
            if (field.getType().equals(CmsFileUploadField.getStaticType())) {
                encType = " enctype=\"multipart/form-data\"";
                break;
            }
        }

        // determine error message
        String errorMessage = null;
        if (hasValidationErrors()) {
            errorMessage = getMessages().key(I_CmsFormMessages.FORM_ERROR_MESSAGE);
        }

        // determine mandatory message
        String mandatoryMessage = null;
        if (getFormConfiguration().isShowMandatory() && getFormConfiguration().hasMandatoryFields()) {
            mandatoryMessage = getMessages().key(I_CmsFormMessages.FORM_MESSAGE_MANDATORY);
        }

        // check if the mail host has been configured
        if (!hasValidationErrors()
            && getFormConfiguration().hasConfigurationErrors()
            && getFormConfiguration().getConfigurationErrors().contains(
                getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAIL_HOST))) {
            errorMessage = getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAIL_HOST);
        }

        // determine the waitlist message
        String waitlistMessage = getSubmissionStatus().isOnlyWaitlist()
        ? getMessages().key(I_CmsFormMessages.FORM_MESSAGE_WAITLIST)
        : null;

        // calculate fields to show (e.g. if paging is activated)
        boolean paging = false;
        int pos = 0;
        int fieldNr = 0;
        int place = 0;
        int currPage = 1;
        int pagingPos = 0;
        String pagingParam = PARAM_PAGE + getFormConfiguration().getConfigId();
        if (getParameterMap().containsKey(PARAM_BACK + getFormConfiguration().getConfigId())
            && getParameterMap().containsKey(pagingParam)) {
            String[] pagingString = getParameterMap().get(pagingParam);
            currPage = new Integer(pagingString[0]).intValue();
            currPage = CmsPagingField.getPreviousPage(currPage);
        } else if (getParameterMap().containsKey(pagingParam) && !hasValidationErrors()) {
            String[] pagingString = getParameterMap().get(pagingParam);
            currPage = new Integer(pagingString[0]).intValue();
            currPage = CmsPagingField.getNextPage(currPage);
        } else if (getParameterMap().containsKey(pagingParam) && hasValidationErrors()) {
            String[] pagingString = getParameterMap().get(pagingParam);
            currPage = new Integer(pagingString[0]).intValue();
        }
        pagingPos = CmsPagingField.getFirstFieldPosFromPage(this, currPage);
        fieldNr = pagingPos;

        // generate HTML for the input fields
        StringBuffer fieldHtml = new StringBuffer(getFormConfiguration().getFields().size() * 256);
        StringBuffer subFieldJSBuf = new StringBuffer(512);
        for (int i = pagingPos, n = getFormConfiguration().getFields().size(); i < n; i++) {
            fieldNr += 1;
            // loop through all form input fields
            I_CmsField field = getFormConfiguration().getFields().get(i);

            if (i == (n - 1)) {
                // the last one has to close the row
                place = 1;
            }
            field.setPlaceholder(place);
            field.setPosition(pos);
            field.setFieldNr(fieldNr);
            String infoMessage = getInfos().get(field.getName());
            // validate the file upload field here already because of the lost values in these fields
            if (field instanceof CmsFileUploadField) {
                infoMessage = field.validateForInfo(this);
            }
            fieldHtml.append(
                field.buildHtml(
                    this,
                    getMessages(),
                    getErrors().get(field.getName()),
                    getFormConfiguration().isShowMandatory(),
                    infoMessage));
            subFieldJSBuf.append(field.getSubFieldScript());
            pos = field.getPosition();
            place = field.getPlaceholder();
            // if there is a paging field do not show the following fields
            if (field instanceof CmsPagingField) {
                paging = true;
                break;
            }
        }

        // determine if subfield JavaScript has to be added
        String subFieldJS = null;
        if (subFieldJSBuf.length() > 0) {
            subFieldJS = subFieldJSBuf.toString();
        }

        // determine if the submit and other buttons are shown
        String submitButton = null;
        String resetButton = null;
        String hiddenFields = null;
        String prevButton = null;

        if (!paging) {
            // show submit button on last form page
            submitButton = getMessages().key(I_CmsFormMessages.FORM_BUTTON_SUBMIT);
            if (getParameterMap().containsKey(pagingParam)) {
                // add hidden fields and previous button on last form page
                StringBuffer hFieldsBuf = CmsPagingField.appendHiddenFields(
                    this,
                    getMessages(),
                    getFormConfiguration().getFields().size());
                hFieldsBuf.append("<input type=\"hidden\" name=\"").append(PARAM_PAGE).append(
                    getFormConfiguration().getConfigId()).append("\" value=\"").append(currPage).append("\" />");
                hFieldsBuf.append("<input type=\"hidden\" name=\"").append(PARAM_FINALPAGE).append(
                    "\" value=\"true\" />");
                hiddenFields = hFieldsBuf.toString();
                prevButton = getMessages().key(I_CmsFormMessages.FORM_BUTTON_PREV);
            } else {
                // there is no paging, but do the file upload values in hidden values
                // otherwise the contents are forgotten in case of other wrong filled fields
                StringBuffer hFieldsBuf = CmsPagingField.appendHiddenUploadFields(this, getMessages());
                hiddenFields = hFieldsBuf.toString();
            }
            if (getFormConfiguration().isShowReset()) {
                // show reset button if configured
                resetButton = getMessages().key(I_CmsFormMessages.FORM_BUTTON_RESET);

            }
        }

        // create the main form and pass the previously generated field HTML as attribute
        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateForm.TEMPLATE_NAME);
        // set the necessary attributes to use in the string template
        String formUri;
        if (getFormConfiguration().hasTargetUri() && getFormConfiguration().isInstantRedirect()) {
            formUri = getFormConfiguration().getTargetUri();
        } else {
            formUri = getCmsObject().getRequestContext().getUri();
            if (CmsJspStandardContextBean.getInstance(getRequest()).isDetailRequest()) {
                formUri = CmsJspStandardContextBean.getInstance(getRequest()).getDetailContentSitePath();
            }
        }

        sTemplate.setAttribute(
            I_CmsTemplateForm.ATTR_FORM_URI,
            OpenCms.getLinkManager().substituteLink(getCmsObject(), formUri));
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_ENCTYPE, encType);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_ERRORMESSAGE, errorMessage);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_MANDATORYMESSAGE, mandatoryMessage);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_FORM_CONFIG, getFormConfiguration());
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_FIELDS, fieldHtml.toString());
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_SUBFIELD_JS, subFieldJS);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_SUBMITBUTTON, submitButton);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_RESETBUTTON, resetButton);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_HIDDENFIELDS, hiddenFields);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_PREVBUTTON, prevButton);
        sTemplate.setAttribute(I_CmsTemplateForm.ATTR_WAITLISTMESSAGE, waitlistMessage);
        return sTemplate.toString();
    }

    /**
     * Builds the HTML for the information on a fully booked form.
     * @return the HTML for the information on a fully booked form.
     */
    protected String buildFullyBookedHtml() {

        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateFullyBooked.TEMPLATE_NAME);
        sTemplate.setAttribute(
            I_CmsTemplateFullyBooked.ATTR_HEADLINE,
            getMessages().key(I_CmsFormMessages.FORM_FULLYBOOKED_HEADLINE));
        sTemplate.setAttribute(
            I_CmsTemplateFullyBooked.ATTR_TEXT,
            getMessages().key(I_CmsFormMessages.FORM_FULLYBOOKED_TEXT));
        return sTemplate.toString();
    }

    /**
     * Builds the HTML for the initialization error.
     * @return the HTML for the initialization error.
     */
    protected String buildInitError() {

        StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateInitError.TEMPLATE_NAME);
        sTemplate.setAttribute(
            I_CmsTemplateInitError.ATTR_HEADLINE,
            getMessages().key(I_CmsFormMessages.FORM_INIT_ERROR_HEADLINE));
        sTemplate.setAttribute(
            I_CmsTemplateInitError.ATTR_TEXT,
            getMessages().key(I_CmsFormMessages.FORM_INIT_ERROR_DESCRIPTION));
        return sTemplate.toString();
    }

    /**
     * Get JavaScript necessary to render the form.
     * @return the JavaScript necessary to render the form.
     */
    protected String buildNecessaryJavaScript() {

        // determine if the user session should be kept
        String sessionJs = null;
        if (isInitSuccess() && getFormConfiguration().isRefreshSession()) {
            sessionJs = link(PATH_KEEP_SESSION_JS);
        }
        // get the JS output template
        StringTemplate sTemplateJS = getOutputTemplate(I_CmsTemplateFormJs.TEMPLATE_NAME);
        sTemplateJS.setAttribute(I_CmsTemplateFormJs.ATTR_FORM_CONFIG, getFormConfiguration());
        sTemplateJS.setAttribute(I_CmsTemplateFormJs.ATTR_SESSION_JS, sessionJs);
        sTemplateJS.setAttribute(I_CmsTemplateFormJs.ATTR_SESSION_URI, link(PATH_KEEP_SESSION_JSP));
        sTemplateJS.setAttribute(I_CmsTemplateFormJs.ATTR_SUBFIELD_JS, link(PATH_SUBFIELDS_JS));
        return sTemplateJS.toString();
    }

    /**
     * Returns the HTML for errors in the used string template group file.<p>
     *
     * <b>Note</b>: Only generates output in an offline project
     *
     * @return the HTML for errors in the used string template group file
     */
    protected String buildTemplateGroupCheckHtml() {

        String result = "";
        if (!getRequestContext().getCurrentProject().isOnlineProject()) {
            // check template group errors
            StringTemplateErrorListener el = getOutputTemplateGroup().getErrorListener();
            if ((el != null) && CmsStringUtil.isNotEmptyOrWhitespaceOnly(el.toString())) {
                // errors(s) found, show error template
                try {
                    CmsFile stFile = getCmsObject().readFile(CmsForm.VFS_PATH_ERROR_TEMPLATEFILE);
                    String stContent = new String(
                        stFile.getContents(),
                        getCmsObject().getRequestContext().getEncoding());
                    StringTemplate st = new StringTemplate(stContent, DefaultTemplateLexer.class);
                    // set the error attributes of the template
                    st.setAttribute(I_CmsTemplateError.ATTR_ERROR_HEADLINE, "Error parsing output template group");
                    st.setAttribute(
                        I_CmsTemplateError.ATTR_ERROR_TEXT,
                        "Error output:<br/><pre>" + el.toString() + "</pre>");
                    st.setAttribute(
                        I_CmsTemplateError.ATTR_ERROR_TEMPLATE_NAMES,
                        getOutputTemplateGroup().getTemplateNames());
                    result = st.toString();
                } catch (Exception e) {
                    // something went wrong, log error
                    LOG.error(
                        "Error while getting error output template from file \""
                            + CmsForm.VFS_PATH_ERROR_TEMPLATEFILE
                            + "\".");
                }
            }
        }
        return result;
    }

    /**
     * Parses the form configuration and creates the necessary configuration objects.<p>
     *
     * @param req the JSP request
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     * @param extraConfig a map of additional configuration values to be accessed in the string template.
     *
     * @throws Exception if creating the form configuration objects fails
     */
    protected void configureForm(
        HttpServletRequest req,
        String formConfigUri,
        Map<String, String> dynamicConfig,
        Map<String, String> extraConfig)
    throws Exception {

        // read the form configuration file from VFS
        if (CmsStringUtil.isEmpty(formConfigUri)) {
            formConfigUri = getRequestContext().getUri();
        }
        m_multipartFileItems = CmsRequestUtil.readMultipartFileItems(req);
        m_macroResolver = CmsMacroResolver.newInstance();
        m_macroResolver.setKeepEmptyMacros(true);
        m_macroResolver.setCmsObject(getCmsObject());
        m_macroResolver.addMacro(
            MACRO_URL,
            OpenCms.getSiteManager().getCurrentSite(getCmsObject()).getServerPrefix(
                getCmsObject(),
                getRequestContext().getUri()) + link(getRequestContext().getUri()));
        m_macroResolver.addMacro(MACRO_LOCALE, getRequestContext().getLocale().toString());
        m_macroResolver.setAdditionalMacros(getMacrosFromDynamicConfig(dynamicConfig));

        if (m_multipartFileItems != null) {
            m_parameterMap = CmsRequestUtil.readParameterMapFromMultiPart(
                getRequestContext().getEncoding(),
                m_multipartFileItems);
        } else {
            m_parameterMap = new HashMap<>();
            m_parameterMap.putAll(getRequest().getParameterMap());
        }

        if (m_multipartFileItems != null) {
            Map<String, FileItem> fileUploads = getFileUploads();
            if (fileUploads == null) {
                fileUploads = new HashMap<>();
            }
            // check, if there are any attachments
            Iterator<FileItem> i = m_multipartFileItems.iterator();
            while (i.hasNext()) {
                FileItem fileItem = i.next();
                if (CmsStringUtil.isNotEmpty(fileItem.getName())) {
                    // append file upload to the map of file items
                    fileUploads.put(fileItem.getFieldName(), fileItem);
                    m_parameterMap.put(fileItem.getFieldName(), new String[] {fileItem.getName()});
                }
            }
            req.getSession().setAttribute(ATTRIBUTE_FILEITEMS, fileUploads);
        } else {
            req.getSession().removeAttribute(ATTRIBUTE_FILEITEMS);
        }
        String actionHashBase = formConfigUri;
        if ((null != dynamicConfig) && dynamicConfig.containsKey(CmsForm.CONFIG_KEY_FORM_ID)) {
            actionHashBase = dynamicConfig.get(CmsForm.CONFIG_KEY_FORM_ID);
        }
        String formAction = getParameter(PARAM_FORMACTION + actionHashBase.hashCode());

        m_isValidatedCorrect = null;
        setInitial(CmsStringUtil.isEmpty(formAction));

        // get the localized messages
        initMessages(formConfigUri);

        // get the form configuration
        CmsForm form = new CmsForm(
            this,
            getMessages(),
            isInitial(),
            formConfigUri,
            formAction,
            dynamicConfig,
            extraConfig);
        if (dynamicConfig != null) {
            String endTimeStr = dynamicConfig.get(CONFIG_END_TIME);
            if (endTimeStr != null) {
                try {
                    m_endTime = Long.valueOf(endTimeStr);
                } catch (Exception e) {
                    LOG.warn(e.getLocalizedMessage(), e);
                }
            }
        }
        setFormConfiguration(form);
    }

    /**
     * Replaces line breaks with html &lt;br&gt;.<p>
     *
     * @param value the value to substitute
     * @return the substituted value
     */
    public String convertToHtmlValue(String value) {

        return convertValue(value, "html");
    }

    /**
     * Replaces html &lt;br&gt; with line breaks.<p>
     *
     * @param value the value to substitute
     * @return the substituted value
     */
    public String convertToPlainValue(String value) {

        return convertValue(value, "");
    }

    /**
     * Converts a given String value to the desired output format.<p>
     *
     * The following output formats are possible:
     * <ul>
     * <li>"HTML" meaning that &lt;br&gt; tags are added</li>
     * <li>"plain"  or any other String value meaning that &lt;br&gt; tags are removed</li>
     * </ul>
     *
     * @param value the String value to convert
     * @param outputType the type of the resulting output
     * @return the converted String in the desired output format
     */
    public String convertValue(String value, String outputType) {

        if ("html".equalsIgnoreCase(outputType)) {
            // output should be HTML, add line break tags and characters
            value = CmsStringUtil.escapeHtml(value);
        } else {
            // output should be plain, remove HTML line break tags and characters
            value = CmsStringUtil.substitute(value, "<br>", "\n");
        }
        return value;
    }

    /**
     * Creates the main web form output for usage on a JSP.<p>
     *
     * @throws IOException if an I/O error occurs
     * @throws ServletException if forwarding goes wrong
     */
    public void createForm() throws IOException, ServletException {

        // the output writer
        Writer out = getJspContext().getOut();

        // include eventual JavaScript
        out.write(buildNecessaryJavaScript());

        // check the template group syntax and show eventual errors
        out.write(buildTemplateGroupCheckHtml());

        if (!isInitSuccess()) {

            // form was not configured correctly, show error message
            out.write(buildInitError());

        } else if (showRelease()) {

            // form is still to be released, show release text
            out.write(getFormConfiguration().getReleaseText());

        } else if (showExpired()) {

            // form is expired, show expiration text
            out.write(getFormConfiguration().getExpirationText());

        } else if (!showForm() && isValidFormaction()) {

            // form has been submitted with correct values, decide further actions
            if (showCheck()) {

                // show optional check page
                out.write(buildCheckHtml());

            } else {

                // try to send a notification email with the submitted form field values
                String errorLinkTarget = executeBeforeWebformAction();
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(errorLinkTarget)) {
                    getResponse().sendRedirect(link(errorLinkTarget));
                    return;
                }

                if (sendData()) {
                    // successfully stored data and/or sent email, decide further actions

                    // prepare the web form action class if configured
                    executeAfterWebformAction();

                    if (getFormConfiguration().hasTargetUri() && !getFormConfiguration().isInstantRedirect()) {
                        onSuccessRedirect();
                    } else {
                        // show confirmation end page
                        out.write(buildConfirmHtml());
                    }
                } else {
                    out.write(buildFailureHtml());
                }
            }
        } else {
            if (getSubmissionStatus().isFullyBooked()) {
                out.write(buildFullyBookedHtml());
            } else {
                // create the main input form
                out.write(buildFormHtml());
            }
        }
    }

    /**
     * Returns the configured form field values as hidden input fields.<p>
     *
     * @return the configured form field values as hidden input fields
     */
    public String createHiddenFields() {

        if (CmsStringUtil.isEmpty(m_hiddenFields)) {
            List<I_CmsField> fields = getFormConfiguration().getAllFields(true, false, false);
            StringBuffer result = new StringBuffer(fields.size() * 8);
            // iterate the form fields
            for (int i = 0, n = fields.size(); i < n; i++) {
                I_CmsField currentField = fields.get(i);
                if (currentField == null) {
                    continue;
                } else if (CmsCheckboxField.class.isAssignableFrom(currentField.getClass())) {
                    // special case: checkbox, can have more than one value
                    Iterator<CmsFieldItem> k = currentField.getItems().iterator();
                    while (k.hasNext()) {
                        CmsFieldItem item = k.next();
                        if (item.isSelected()) {
                            result.append("<input type=\"hidden\" name=\"");
                            result.append(currentField.getName());
                            result.append("\" value=\"");
                            result.append(CmsEncoder.escapeXml(item.getValue()));
                            result.append("\" />\n");
                        }
                    }
                } else if (CmsParameterField.class.equals(currentField.getClass())) {
                    // special case: table, can have more than one value
                    //Iterator<CmsFieldItem> k = currentField.getItems().iterator();
                    result.append("<input type=\"hidden\" name=\"");
                    result.append(currentField.getName());
                    result.append("\" value=\"");
                    result.append(CmsEncoder.escapeXml(currentField.getValue()));
                    result.append("\" />\n");
                    result.append(
                        CmsParameterField.createHiddenFields(getParameterMap(), currentField.getParameters()));
                } else if (currentField instanceof I_CmsHasHiddenFieldHtml) {
                    String hiddenFieldHtml = ((I_CmsHasHiddenFieldHtml)currentField).getHiddenFieldHtml();
                    result.append(hiddenFieldHtml);
                } else if (CmsStringUtil.isNotEmpty(currentField.getValue())) {
                    // all other fields are converted to a simple hidden field
                    result.append("<input type=\"hidden\" name=\"");
                    result.append(currentField.getName());
                    result.append("\" value=\"");
                    result.append(CmsEncoder.escapeXml(currentField.getValue()));
                    result.append("\" />\n");
                }

            }
            // store the generated input fields for further usage to avoid unnecessary rebuilding
            m_hiddenFields = result.toString();
        }
        // return generated result list
        return m_hiddenFields;
    }

    /**
     * Creates a list of Internet addresses (email) from a semicolon separated String.<p>
     *
     * @param mailAddresses a semicolon separated String with email addresses
     * @return list of Internet addresses (email)
     * @throws AddressException if an email address is not correct
     */
    protected List<InternetAddress> createInternetAddresses(String mailAddresses) throws AddressException {

        if (CmsStringUtil.isNotEmpty(mailAddresses)) {
            // at least one email address is present, generate list
            StringTokenizer T = new StringTokenizer(mailAddresses, ";");
            List<InternetAddress> addresses = new ArrayList<>(T.countTokens());
            while (T.hasMoreTokens()) {
                InternetAddress address = new InternetAddress(T.nextToken());
                addresses.add(address);
            }
            return addresses;
        } else {
            // no address given, return empty list
            return Collections.emptyList();
        }
    }

    /**
     * Creates the output String of the submitted fields for email creation.<p>
     *
     * @param isHtmlMail if true, the output is formatted as HTML, otherwise as plain text
     * @param isConfirmationMail if true, the text for the confirmation mail is created, otherwise the text for mail receiver
     *
     * @return the output String of the submitted fields for email creation
     */
    public String createMailTextFromFields(boolean isHtmlMail, boolean isConfirmationMail) {

        List<I_CmsField> fieldValues = getFormConfiguration().getAllFields(true, false, true);
        StringBuffer fieldsResult = new StringBuffer(fieldValues.size() * 16);
        List<I_CmsField> htmlFields = new ArrayList<>(fieldValues.size());
        String mailCss = null;
        // determine CSS to use for HTML email
        if (isHtmlMail) {
            // create HTML email using the template output
            if (CmsStringUtil.isNotEmpty(getFormConfiguration().getMailCSS())) {
                // use individually configured CSS
                mailCss = getFormConfiguration().getMailCSS();
            }
        }

        // generate output for submitted form fields
        Iterator<I_CmsField> i = fieldValues.iterator();
        while (i.hasNext()) {
            I_CmsField current = i.next();
            if (current instanceof CmsPagingField) {
                continue;
            }
            if (!useInFormDataMacro(current)) {
                continue;
            }
            // only show the empty field in the confirmation mail, if it is marked as mandatory
            if ((current instanceof CmsEmptyField) && !current.isMandatory()) {
                continue;
            }
            String value = current.toString();
            if (current instanceof CmsFileUploadField) {
                value = current.getValue();
                if (CmsStringUtil.isEmptyOrWhitespaceOnly(value)) {
                    // try to read upload item from session attribute
                    FileItem fileItem = getUploadFile(current);
                    if (fileItem != null) {
                        value = fileItem.getName();
                    }
                }
                value = CmsFormHandler.getTruncatedFileItemName(value);
            }
            if (isHtmlMail) {
                // format field label as HTML
                String label = current.getLabel();
                // special case for table and empty fields
                if (current instanceof CmsEmptyField) {
                    label = "";
                }
                // format field value as HTML
                String fieldValue = convertToHtmlValue(value);
                // special case for table and empty fields
                if (current instanceof CmsEmptyField) {
                    fieldValue = value;
                }
                // if label and value is not set, skip it
                if (CmsStringUtil.isEmpty(label) && CmsStringUtil.isEmpty(fieldValue)) {
                    continue;
                }
                I_CmsField mailField = new CmsTextField();
                mailField.setLabel(label);
                mailField.setValue(fieldValue);
                htmlFields.add(mailField);
            } else {
                // format output as plain text
                String label;
                try {
                    label = CmsHtmlToTextConverter.htmlToText(
                        current.getLabel(),
                        getCmsObject().getRequestContext().getEncoding(),
                        true).trim();
                } catch (Exception e) {
                    // error parsing the String, provide it as is
                    label = current.getLabel();
                }
                // if label and value is not set, skip it
                if (CmsStringUtil.isEmpty(label) && CmsStringUtil.isEmpty(value)) {
                    continue;
                } else if (current instanceof CmsEmptyField) {
                    label = "";
                }
                fieldsResult.append(label);
                fieldsResult.append("\t");
                fieldsResult.append(value);
                fieldsResult.append("\n");
            }
        }

        // generate the main mail text
        String mailText;
        if (isHtmlMail) {
            // generate HTML email
            if (isConfirmationMail) {
                // append the confirmation email text
                mailText = getFormConfiguration().getConfirmationMailText();
            } else {
                // append the email text
                mailText = getFormConfiguration().getMailText();
            }
            // create field output
            StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateHtmlEmailFields.TEMPLATE_NAME);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmailFields.ATTR_MAIL_CSS, mailCss);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmailFields.ATTR_FIELDS, htmlFields);
            fieldsResult.append(sTemplate.toString());
        } else {
            // generate simple text email
            if (isConfirmationMail) {
                // append the confirmation email text
                mailText = getFormConfiguration().getConfirmationMailTextPlain();
            } else {
                // append the email text
                mailText = getFormConfiguration().getMailTextPlain();
            }
        }
        // resolve the common macros
        mailText = m_macroResolver.resolveMacros(mailText);
        // check presence of formdata macro in mail text using new macro resolver (important, do not use the same here!)
        CmsMacroResolver macroResolver = CmsMacroResolver.newInstance();
        macroResolver.setKeepEmptyMacros(true);
        macroResolver.addMacro(MACRO_FORMDATA, "");
        if (mailText.length() > macroResolver.resolveMacros(mailText).length()) {
            // form data macro found, resolve it
            macroResolver.addMacro(MACRO_FORMDATA, fieldsResult.toString());
            mailText = macroResolver.resolveMacros(mailText);
        } else {
            // no form data macro found, add the fields below the mail text
            if (!isHtmlMail) {
                mailText += "\n\n";
            }
            mailText += fieldsResult;
        }

        if (isHtmlMail) {
            StringTemplate sTemplate = getOutputTemplate(I_CmsTemplateHtmlEmail.TEMPLATE_NAME);
            String errorHeadline = null;
            if (!isConfirmationMail && getFormConfiguration().hasConfigurationErrors()) {
                // write form configuration errors to html mail
                errorHeadline = getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_HEADLINE);
            }
            // set necessary attributes
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_MAIL_CSS, mailCss);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_MAIL_TEXT, mailText);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_ERROR_HEADLINE, errorHeadline);
            sTemplate.setAttribute(I_CmsTemplateHtmlEmail.ATTR_ERRORS, getFormConfiguration().getConfigurationErrors());
            return sTemplate.toString();
        } else {
            StringBuffer result = new StringBuffer(mailText);
            if (!isConfirmationMail && getFormConfiguration().hasConfigurationErrors()) {
                // write form configuration errors to text mail
                result.append("\n");
                result.append(getMessages().key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_HEADLINE));
                result.append("\n");
                for (int k = 0; k < getFormConfiguration().getConfigurationErrors().size(); k++) {
                    result.append(getFormConfiguration().getConfigurationErrors().get(k));
                    result.append("\n");
                }
            }
            return result.toString();
        }
    }

    /**
     * Returns the values to store in the XML content.
     * @return the values to store in the XML content.
     */
    Map<String, String> createUgcContentValues() {

        Map<String, String> result = new HashMap<>();
        CmsForm form = getFormConfiguration();
        result.put(CmsFormDataBean.PATH_FORM, form.getConfigUri());
        List<I_CmsField> formFields = getFormConfiguration().getAllFields(false, true, true);
        int entryNum = 1;
        for (I_CmsField field : formFields) {
            // do not store empty fields: users will not be able to enter something and "duplicate entry" errors may happen
            // do not store paging fields as well
            if ((field instanceof CmsPagingField) || (field instanceof CmsEmptyField)) {
                continue;
            }
            result.put(CmsFormDataBean.getKeyPath(entryNum), field.getDbLabel());
            result.put(CmsFormDataBean.getValuePath(entryNum), field.getValue());
            entryNum++;
        }
        CmsFormUgcConfiguration ugc = getFormConfiguration().getUgcConfiguration();
        if ((ugc != null) && (ugc.getKeepDays() != null)) {
            long keepMillis = TimeUnit.MILLISECONDS.convert(ugc.getKeepDays().intValue(), TimeUnit.DAYS);
            if (m_endTime != null) {
                long deletionDate = m_endTime.longValue() + keepMillis;
                result.put(CmsFormDataBean.PATH_DELETION_DATE, "" + deletionDate);
            }
        }

        return result;
    }

    /**
     * Executes the after web form action.<p>
     */
    public void executeAfterWebformAction() {

        String actionClass = getFormConfiguration().getActionClass();
        if (CmsStringUtil.isNotEmpty(actionClass)) {
            try {
                I_CmsWebformActionHandler handler = getObject(actionClass);
                handler.afterWebformAction(getCmsObject(), this);
            } catch (Exception e) {
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Invalid webform action handler class: " + actionClass, e);
                }
            }
        }
    }

    /**
     * Executes the before web form action.<p>
     *
     * @return <code>null</code> if successful, otherwise a redirect link for the failure case.
     */
    public String executeBeforeWebformAction() {

        String actionClass = getFormConfiguration().getActionClass();
        if (CmsStringUtil.isNotEmpty(actionClass)) {
            try {
                I_CmsWebformActionHandler handler = getObject(actionClass);
                return handler.beforeWebformAction(getCmsObject(), this);
            } catch (Exception e) {
                if (LOG.isDebugEnabled()) {
                    LOG.debug("Invalid webform action handler class: " + actionClass, e);
                }
            }
        }
        return null;
    }

    /**
     * Returns the errors found when validating the form.<p>
     *
     * @return the errors found when validating the form
     */
    public Map<String, String> getErrors() {

        return m_errors;
    }

    /**
     * Returns the map of uploaded files.<p>
     *
     * @return the map of uploaded files
     */
    @SuppressWarnings("unchecked")
    private Map<String, FileItem> getFileUploads() {

        if (getRequest().getSession().getAttribute(ATTRIBUTE_FILEITEMS) != null) {
            return (Map<String, FileItem>)getRequest().getSession().getAttribute(ATTRIBUTE_FILEITEMS);
        }
        return null;
    }

    /**
     * Returns the check page text, after resolving macros.<p>
     *
     * @return the check page text
     */
    public String getFormCheckText() {

        CmsMacroResolver macroResolver = CmsMacroResolver.newInstance();
        macroResolver.setKeepEmptyMacros(true);
        List<I_CmsField> fields = getFormConfiguration().getFields();
        addFieldMacros(macroResolver, fields, false);
        return macroResolver.resolveMacros(getFormConfiguration().getFormCheckText());
    }

    /**
     * Returns the form configuration.<p>
     *
     * @return the form configuration
     */
    public CmsForm getFormConfiguration() {

        return m_formConfiguration;
    }

    /**
     * Returns the confirmation text, after resolving macros.<p>
     *
     * @return the confirmation text
     */
    public String getFormConfirmationText() {

        return m_macroResolver.resolveMacros(getFormConfiguration().getFormConfirmationText());
    }

    /**
     * Returns the infos found when validating the form.<p>
     *
     * @return the infos found when validating the form
     */
    public Map<String, String> getInfos() {

        return m_infos;
    }

    /**
     * Returns the macro resolver.<p>
     *
     * @return the resolver
     */
    public CmsMacroResolver getMacroResolver() {

        return m_macroResolver;
    }

    /**
     * Returns the macros and their values as defined in the dynamic config.
     *
     * @param dynamicConfig the dynamic form configuration
     *
     * @return the macros and their values as defined in the dynamic config.
     */
    private Map<String, String> getMacrosFromDynamicConfig(Map<String, String> dynamicConfig) {

        Map<String, String> result = new HashMap<>();
        int keyPrefixLength = DYNAMIC_CONFIG_PREFIX_MACRO.length();
        if (null != dynamicConfig) {
            for (Map.Entry<String, String> entry : dynamicConfig.entrySet()) {
                String key = entry.getKey();
                if (key.startsWith(DYNAMIC_CONFIG_PREFIX_MACRO)) {
                    result.put(key.substring(keyPrefixLength), entry.getValue());
                }
            }
        }
        return result;
    }

    /**
     * Returns the localized messages.<p>
     *
     * @return the localized messages
     */
    public CmsMessages getMessages() {

        return m_messages;
    }

    /**
     * Creates an object from data type I_CmsWebformActionHandler.<p>
     *
     * @param className name from class to create an object from
     *
     * @return object from data type I_CmsWebformActionHandler
     *
     * @throws Exception if the creation goes wrong
     */
    private I_CmsWebformActionHandler getObject(String className) throws Exception {

        I_CmsWebformActionHandler object = null;
        @SuppressWarnings("unchecked")
        Class<I_CmsWebformActionHandler> c = (Class<I_CmsWebformActionHandler>)Class.forName(className);
        object = c.newInstance();

        return object;
    }

    /**
     * Returns the template for the web form HTML output.<p>
     *
     * @param templateName the name of the template to return
     *
     * @return the template for the web form HTML output
     */
    public StringTemplate getOutputTemplate(String templateName) {

        StringTemplate result = getOutputTemplateGroup().getInstanceOf(templateName);
        if (!getRequestContext().getCurrentProject().isOnlineProject() && (result == null)) {
            // no template with the specified name found, return initialized error template
            try {
                CmsFile stFile = getCmsObject().readFile(CmsForm.VFS_PATH_ERROR_TEMPLATEFILE);
                String stContent = new String(stFile.getContents(), getCmsObject().getRequestContext().getEncoding());
                result = new StringTemplate(stContent, DefaultTemplateLexer.class);
                // set the error attributes of the template
                result.setAttribute(I_CmsTemplateError.ATTR_ERROR_HEADLINE, "Error getting output template");
                result.setAttribute(
                    I_CmsTemplateError.ATTR_ERROR_TEXT,
                    "The desired template \"" + templateName + "\" was not found.");
                result.setAttribute(
                    I_CmsTemplateError.ATTR_ERROR_TEMPLATE_NAMES,
                    getOutputTemplateGroup().getTemplateNames());
            } catch (Exception e) {
                // something went wrong, log error
                LOG.error(
                    "Error while getting error output template from file \""
                        + CmsForm.VFS_PATH_ERROR_TEMPLATEFILE
                        + "\".");
            }
        }
        return result;
    }

    /**
     * Returns the output template group that generates the web form HTML output.<p>
     *
     * @return the output template group that generates the web form HTML output
     */
    public StringTemplateGroup getOutputTemplateGroup() {

        if (m_outputTemplates == null) {
            String vfsPath = null;
            if (getFormConfiguration() != null) {
                // check if an individual output template path is set
                vfsPath = getFormConfiguration().getTemplateFile();
                if (!getCmsObject().existsResource(vfsPath)) {
                    // configured output template path does not exist, log error and use default output templates
                    LOG.error("Configured web form HTML output template file \"" + vfsPath + "\" does not exist.");
                    vfsPath = null;
                }
            }

            if (vfsPath == null) {
                // no valid template path configured, use default output templates
                vfsPath = OpenCms.getModuleManager().getModule(CmsForm.MODULE_NAME).getParameter(
                    CmsForm.MODULE_PARAM_TEMPLATE_FILE,
                    CmsForm.VFS_PATH_DEFAULT_TEMPLATEFILE);
            }
            try {
                // first try to get the initialized template group from VFS cache
                String rootPath = getRequestContext().addSiteRoot(vfsPath);
                StringTemplateGroup stGroup = (StringTemplateGroup)CmsVfsMemoryObjectCache.getVfsMemoryObjectCache().getCachedObject(
                    getCmsObject(),
                    rootPath);
                if (stGroup == null) {
                    // template group is not in cache, read the file and generate template group
                    CmsFile stFile = getCmsObject().readFile(vfsPath);
                    String stContent = new String(
                        stFile.getContents(),
                        getCmsObject().getRequestContext().getEncoding());
                    StringTemplateErrorListener errors = new CmsStringTemplateErrorListener();
                    stGroup = new StringTemplateGroup(new StringReader(stContent), DefaultTemplateLexer.class, errors);
                    // store the template group in cache
                    CmsVfsMemoryObjectCache.getVfsMemoryObjectCache().putCachedObject(
                        getCmsObject(),
                        rootPath,
                        stGroup);
                }
                m_outputTemplates = stGroup;
            } catch (Exception e) {
                // something went wrong, log error
                LOG.error("Error while creating web form HTML output templates from file \"" + vfsPath + "\".");
            }
        }
        return m_outputTemplates;
    }

    /**
     * Returns the request parameter with the specified name.<p>
     *
     * @param parameter the parameter to return
     *
     * @return the parameter value
     */
    public String getParameter(String parameter) {

        if (PARAM_FORMACTION.equals(parameter) || CmsForm.PARAM_SENDCONFIRMATION.equals(parameter)) {
            parameter += getFormConfiguration().getConfigId();
        }
        try {
            return (m_parameterMap.get(parameter))[0];
        } catch (NullPointerException e) {
            return "";
        }
    }

    /**
     * Returns the map of request parameters.<p>
     *
     * @return the map of request parameters
     */
    public Map<String, String[]> getParameterMap() {

        return m_parameterMap;
    }

    /**
     * Returns the lazily initialized submission status.
     * @return the lazily initialized submission status.
     */
    public CmsSubmissionStatus getSubmissionStatus() {

        if (null == m_submissionStatus) {
            try {
                m_submissionStatus = new CmsSubmissionStatus(
                    CmsWebformModuleAction.getAdminCms(getCmsObject()),
                    getFormConfiguration().getUgcConfiguration());
            } catch (CmsException e) {
                LOG.error("Failed to initialize submission status of the form. Using default submission status.", e);
                m_submissionStatus = new CmsSubmissionStatus();
            }
        }
        return m_submissionStatus;
    }

    /**
     * Return <code>null</code> or the file item for the given field in
     * case it is of type <code>{@link CmsFileUploadField}</code>.<p>
     *
     * @param isFileUploadField the field to the the file item of
     *
     * @return <code>null</code> or the file item for the given field in
     *      case it is of type <code>{@link CmsFileUploadField}</code>
     */
    public FileItem getUploadFile(I_CmsField isFileUploadField) {

        FileItem result = null;
        FileItem current;
        String fieldName = isFileUploadField.getName();
        String uploadFileFieldName;
        Map<String, FileItem> fileUploads = getFileUploads();
        if (fileUploads != null) {
            Iterator<FileItem> i = fileUploads.values().iterator();
            while (i.hasNext()) {
                current = i.next();
                uploadFileFieldName = current.getFieldName();
                if (fieldName.equals(uploadFileFieldName)) {
                    result = current;
                }
            }
        }
        return result;
    }

    /**
     * Returns if the submitted values contain validation errors.<p>
     *
     * @return <code>true</code> if the submitted values contain validation errors, otherwise <code>false</code>
     */
    public boolean hasValidationErrors() {

        return (!isInitial() && (getErrors().size() > 0));
    }

    /**
     * Initializes the form handler and creates the necessary configuration objects.<p>
     *
     * @see org.opencms.jsp.CmsJspBean#init(javax.servlet.jsp.PageContext, javax.servlet.http.HttpServletRequest, javax.servlet.http.HttpServletResponse)
     */
    @Override
    public void init(PageContext context, HttpServletRequest req, HttpServletResponse res) {

        try {
            init(context, req, res, null);
        } catch (CmsException e) {
            // log initialization error
            LOG.error(e);
        }
    }

    /**
     * Initializes the form handler and creates the necessary configuration objects.<p>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     *
     * @throws CmsException if initializing the form message objects fails
     */
    public void init(PageContext context, HttpServletRequest req, HttpServletResponse res, String formConfigUri)
    throws CmsException {

        init(context, req, res, formConfigUri, null);
    }

    /**
     * Initializes the form handler and creates the necessary configuration objects.<p>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     *
     * @throws CmsException if initializing the form message objects fails
     */
    public void init(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String formConfigUri,
        Map<String, String> dynamicConfig)
    throws CmsException {

        init(context, req, res, formConfigUri, dynamicConfig, null);
    }

    /**
     * Initializes the form handler and creates the necessary configuration objects.<p>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     * @param extraConfig a map of additional configuration values to be accessed in the string template.
     *
     * @throws CmsException if initializing the form message objects fails
     */
    public void init(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String formConfigUri,
        Map<String, String> dynamicConfig,
        Map<String, String> extraConfig)
    throws CmsException {

        super.init(context, req, res);
        try {
            // initialize the form configuration
            configureForm(req, formConfigUri, dynamicConfig, extraConfig);
            m_initSuccess = true;
        } catch (Exception e) {
            LOG.error(e);
            // error in form initialization, initialize at least the localized messages
            initMessages(formConfigUri);
        }

    }

    /**
     * Initializes the localized messages for the web form.<p>
     *
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     *
     * @throws CmsException if accessing the VFS fails
     */
    protected void initMessages(String formConfigUri) throws CmsException {

        // get the localized messages
        CmsModule module = OpenCms.getModuleManager().getModule(CmsForm.MODULE_NAME);
        String para = module.getParameter("message", "alkacon.mercury.webform.messages");

        // get the site message
        String siteroot = getCmsObject().getRequestContext().getSiteRoot();
        if (siteroot.startsWith(CmsResource.VFS_FOLDER_SITES)) {
            siteroot = siteroot.substring(CmsResource.VFS_FOLDER_SITES.length() + 1);
        }
        if (!CmsStringUtil.isEmptyOrWhitespaceOnly(siteroot)) {
            String fileSite = module.getParameter("message_" + siteroot);
            if (!CmsStringUtil.isEmptyOrWhitespaceOnly(fileSite)) {
                para = fileSite;
            }
        }
        // use the optional property file if configured
        String propertyFile = null;
        if (CmsStringUtil.isEmpty(formConfigUri)) {
            formConfigUri = getRequestContext().getUri();
        }
        CmsProperty cmsProperty = getCmsObject().readPropertyObject(formConfigUri, "webform.propertyfile", false);
        if (cmsProperty != null) {
            propertyFile = cmsProperty.getValue();
        }
        if (CmsStringUtil.isNotEmpty(propertyFile)) {
            addMessages(new CmsMessages(propertyFile, getRequestContext().getLocale()));
        } else {
            addMessages(new CmsMessages(para, getRequestContext().getLocale()));
        }
    }

    /**
     * Returns if the form is displayed for the first time.<p>
     *
     * @return <code>true</code> if the form is displayed for the first time, otherwise <code>false</code>
     */
    public boolean isInitial() {

        return m_initial;
    }

    /**
     * Returns if the form handler configuration has been initialized successfully.<p>
     *
     * @return <code>true</code> if the form handler configuration has been initialized successfully, otherwise <code>false</code>
     */
    public boolean isInitSuccess() {

        return m_initSuccess;
    }

    /**
     * Returns if the formaction is of predefined value.<p>
     *
     * @return <code>true</code> if the formaction is valid, otherwise <code>false</code>
     */
    public boolean isValidFormaction() {

        String formAction = getParameter(PARAM_FORMACTION);

        boolean result = false;
        if (ACTION_CONFIRMED.equalsIgnoreCase(formAction)) {
            result = true;
        } else if (ACTION_CORRECT_INPUT.equalsIgnoreCase(formAction)) {
            result = true;
        } else if (ACTION_SUBMIT.equalsIgnoreCase(formAction)) {
            result = true;
        }
        return result;
    }

    /**
     * Performs the intended redirect after a successful submission of the form.
     * @throws IOException thrown if sending the redirect or forwarding the request fails.
     * @throws ServletException thrown if forwarding the request fails.
     */
    protected void onSuccessRedirect() throws IOException, ServletException {

        if (getFormConfiguration().isForwardMode()) {
            CmsRequestUtil.forwardRequest(
                link(getFormConfiguration().getTargetUri()),
                m_parameterMap,
                getRequest(),
                getResponse());
        } else {
            // another target URI is configured, redirect to it
            getResponse().sendRedirect(link(getFormConfiguration().getTargetUri()));
        }

    }

    /**
     * Sends the confirmation mail with the form data to the specified email address.<p>
     *
     * @throws Exception if sending the confirmation mail fails
     */
    public void sendConfirmationMail() throws Exception {

        String mailTo = getFormConfiguration().getConfirmationMailEmail();
        if (CmsStringUtil.isNotEmpty(mailTo)) {
            // create the new confirmation mail message depending on the configured email type
            if (getFormConfiguration().getMailType().equals(CmsForm.MAILTYPE_HTML)) {
                // create a HTML email
                CmsHtmlMail theMail = new CmsHtmlMail();
                theMail.setCharset(getCmsObject().getRequestContext().getEncoding());
                if (CmsStringUtil.isNotEmpty(getFormConfiguration().getConfirmationMailFrom())) {
                    if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(
                        getFormConfiguration().getConfirmationMailFromName())) {
                        theMail.setFrom(
                            m_macroResolver.resolveMacros(getFormConfiguration().getConfirmationMailFrom()),
                            m_macroResolver.resolveMacros(getFormConfiguration().getConfirmationMailFromName()));
                    } else {
                        theMail.setFrom(
                            m_macroResolver.resolveMacros(getFormConfiguration().getConfirmationMailFrom()));
                    }
                } else if (CmsStringUtil.isNotEmpty(getFormConfiguration().getMailFrom())) {
                    if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(getFormConfiguration().getMailFromName())) {
                        theMail.setFrom(
                            m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()),
                            m_macroResolver.resolveMacros(getFormConfiguration().getMailFromName()));
                    } else {
                        theMail.setFrom(m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()));
                    }
                }
                theMail.setTo(createInternetAddresses(mailTo));
                theMail.setSubject(
                    m_macroResolver.resolveMacros(
                        getFormConfiguration().getMailSubjectPrefix()
                            + getFormConfiguration().getConfirmationMailSubject()));
                theMail.setHtmlMsg(createMailTextFromFields(true, true));
                // send the mail
                theMail.send();
            } else {
                // create a plain text email
                CmsSimpleMail theMail = new CmsSimpleMail();
                theMail.setCharset(getCmsObject().getRequestContext().getEncoding());
                if (CmsStringUtil.isNotEmpty(getFormConfiguration().getMailFrom())) {
                    if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(getFormConfiguration().getMailFromName())) {
                        theMail.setFrom(
                            m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()),
                            m_macroResolver.resolveMacros(getFormConfiguration().getMailFromName()));
                    } else {
                        theMail.setFrom(m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()));
                    }
                }
                theMail.setTo(createInternetAddresses(mailTo));
                theMail.setSubject(
                    m_macroResolver.resolveMacros(
                        getFormConfiguration().getMailSubjectPrefix()
                            + getFormConfiguration().getConfirmationMailSubject()));
                theMail.setMsg(createMailTextFromFields(false, true));
                // send the mail
                theMail.send();
            }
        }
    }

    /**
     * Sends the collected data due to the configuration of the form
     * (email, database or both).<p>
     * It returns the following status information:
     * <ul>
     *  <li>In case the database is configured, <code>true</code> is returned iff the form data could be stored in the database.</li>
     *  <li>In case the database is not configure, <code>true</code> is returned iff the registration email has been sent.
     * </ul>
     * This means in particular, that <code>true</code> is also returned if the confirmation mail could not be sent, or iff the data is only stored
     * in the database, even if a registration mail should be sent as well.
     *
     * @return <code>true</code> iff database is configure and data is stored in the database or iff database is not configured and the registration mail could be sent.
     */
    public boolean sendData() {

        CmsForm data = getFormConfiguration();
        data.removeCaptchaField();
        // fill the macro resolver for resolving in subject and content:
        List<I_CmsField> fields = data.getAllFields(false, true, true);
        addFieldMacros(m_macroResolver, fields, true);
        // add current date as macro
        m_macroResolver.addMacro(
            MACRO_DATE,
            CmsDateUtil.getDateTime(new Date(), DateFormat.LONG, getRequestContext().getLocale()));

        CmsUgcHandler ugcHandler = null;
        boolean isConfirmationMailSent = false;
        boolean isRegistrationMailSent = false;
        if (data.isUgcConfigured()) {
            try {
                Map<String, String> contentValues = createUgcContentValues();
                ugcHandler = new CmsUgcHandler(
                    getCmsObject(),
                    getRequest(),
                    data.getUgcConfiguration(),
                    contentValues,
                    getSubmissionStatus().isOnlyWaitlist());
                ugcHandler.saveWithStatus(false, false);
            } catch (Exception e) {
                getErrors().put(ERROR_STORE_FORMDATA, e.getMessage());
                if (null != ugcHandler) {
                    try {
                        ugcHandler.finish();
                    } catch (Exception e1) {
                        // do nothing
                    }
                }
                return false;
            }
        }
        // add waitlist macros if necessary
        String eventWatilistInfo;
        if (getSubmissionStatus().isOnlyWaitlist()) {
            eventWatilistInfo = getMessages().key(I_CmsFormMessages.EVENT_WAITLIST_INFO);
        } else {
            eventWatilistInfo = "";
        }
        m_macroResolver.addMacro(MACRO_EVENT_WAITLIST_INFO, eventWatilistInfo);
        // for backward compatibility with existing old webform configurations
        m_macroResolver.addMacro("confirm.waitlist.info", eventWatilistInfo);
        m_macroResolver.addMacro("mail.waitlist.info", eventWatilistInfo);

        // send optional confirmation mail
        if (data.isConfirmationMailEnabled()) {
            if (!data.isConfirmationMailOptional()
                || Boolean.valueOf(getParameter(CmsForm.PARAM_SENDCONFIRMATION)).booleanValue()) {
                try {
                    sendConfirmationMail();
                    isConfirmationMailSent = true;
                } catch (Exception e) {
                    // an error occured during mail creation
                    if (LOG.isErrorEnabled()) {
                        LOG.error(e.getLocalizedMessage(), e);
                    }
                    getErrors().put(ERROR_CONFIRMATION_SENT, e.getMessage());
                }
            }
        }

        // send registration information mail
        try {
            sendMail();
            isRegistrationMailSent = true;
        } catch (Exception e) {
            // an error occured during mail creation
            if (LOG.isErrorEnabled()) {
                LOG.error(e.getLocalizedMessage(), e);
            }
            getErrors().put(ERROR_REGISTRATION_SENT, e.getMessage());
        }

        if (ugcHandler != null) {
            try {
                if (isConfirmationMailSent || isRegistrationMailSent) {
                    ugcHandler.saveWithStatus(isConfirmationMailSent, isRegistrationMailSent);
                }
            } catch (Exception e) {
                LOG.warn(
                    "Could not update information status for content "
                        + ugcHandler.getContentRootPath()
                        + ", telling that registration mail was "
                        + (isRegistrationMailSent ? "" : "not ")
                        + "sent and confirmation mail was "
                        + (isConfirmationMailSent ? "" : "not ")
                        + "sent.",
                    e);
            }
            try {
                ugcHandler.finish();
            } catch (Exception e) {
                LOG.warn(
                    "Could not finish UGC session with project \""
                        + ugcHandler.getUgcProject()
                        + "\" for content "
                        + ugcHandler.getContentRootPath()
                        + ".",
                    e);
            }
        }

        return data.isUgcConfigured() || !getErrors().containsKey(ERROR_REGISTRATION_SENT);
    }

    /**
     * Sends the mail with the form data to the specified recipients.<p>
     *
     * If configured, sends also a confirmation mail to the form submitter.<p>
     *
     * @throws EmailException
     * @throws AddressException
     */
    protected void sendMail() throws EmailException, AddressException {

        // create the new mail message depending on the configured email type
        if (getFormConfiguration().getMailType().equals(CmsForm.MAILTYPE_HTML)) {
            // create a HTML email
            CmsHtmlMail theMail = new CmsHtmlMail();
            theMail.setCharset(getCmsObject().getRequestContext().getEncoding());
            if (CmsStringUtil.isNotEmpty(getFormConfiguration().getMailFrom())) {
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(getFormConfiguration().getMailFromName())) {
                    theMail.setFrom(
                        m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()),
                        m_macroResolver.resolveMacros(getFormConfiguration().getMailFromName()));
                } else {
                    theMail.setFrom(m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()));
                }
            }
            theMail.setTo(createInternetAddresses(m_macroResolver.resolveMacros(getFormConfiguration().getMailTo())));
            List<InternetAddress> ccRec = createInternetAddresses(
                m_macroResolver.resolveMacros(getFormConfiguration().getMailCC()));
            if (ccRec.size() > 0) {
                theMail.setCc(ccRec);
            }
            List<InternetAddress> bccRec = createInternetAddresses(
                m_macroResolver.resolveMacros(getFormConfiguration().getMailBCC()));
            if (bccRec.size() > 0) {
                theMail.setBcc(bccRec);
            }
            theMail.setSubject(
                m_macroResolver.resolveMacros(
                    getFormConfiguration().getMailSubjectPrefix() + getFormConfiguration().getMailSubject()));
            theMail.setHtmlMsg(createMailTextFromFields(true, false));

            // attach file uploads
            Map<String, FileItem> fileUploads = getFileUploads();
            if (fileUploads != null) {
                Iterator<FileItem> i = fileUploads.values().iterator();
                while (i.hasNext()) {
                    FileItem attachment = i.next();
                    if (attachment != null) {
                        String filename = attachment.getName().substring(
                            attachment.getName().lastIndexOf(File.separator) + 1);
                        theMail.attach(
                            new CmsByteArrayDataSource(
                                filename,
                                attachment.get(),
                                OpenCms.getResourceManager().getMimeType(filename, null, "application/octet-stream")),
                            filename,
                            filename);
                    }
                }
            }
            // send the mail
            theMail.send();
        } else {
            // create a plain text email
            CmsSimpleMail theMail = new CmsSimpleMail();
            theMail.setCharset(getCmsObject().getRequestContext().getEncoding());
            if (CmsStringUtil.isNotEmpty(getFormConfiguration().getMailFrom())) {
                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(getFormConfiguration().getMailFromName())) {
                    theMail.setFrom(
                        m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()),
                        m_macroResolver.resolveMacros(getFormConfiguration().getMailFromName()));
                } else {
                    theMail.setFrom(m_macroResolver.resolveMacros(getFormConfiguration().getMailFrom()));
                }
            }
            theMail.setTo(createInternetAddresses(m_macroResolver.resolveMacros(getFormConfiguration().getMailTo())));
            List<InternetAddress> ccRec = createInternetAddresses(
                m_macroResolver.resolveMacros(getFormConfiguration().getMailCC()));
            if (ccRec.size() > 0) {
                theMail.setCc(ccRec);
            }
            List<InternetAddress> bccRec = createInternetAddresses(
                m_macroResolver.resolveMacros(getFormConfiguration().getMailBCC()));
            if (bccRec.size() > 0) {
                theMail.setBcc(bccRec);
            }
            theMail.setSubject(
                m_macroResolver.resolveMacros(
                    getFormConfiguration().getMailSubjectPrefix() + getFormConfiguration().getMailSubject()));
            theMail.setMsg(createMailTextFromFields(false, false));
            // send the mail
            theMail.send();
        }
    }

    /**
     * Sets the form configuration.<p>
     *
     * @param configuration the form configuration
     */
    protected void setFormConfiguration(CmsForm configuration) {

        m_formConfiguration = configuration;
    }

    /**
     * Sets if the form is displayed for the first time.<p>
     *
     * @param initial true if the form is displayed for the first time, otherwise false
     */
    protected void setInitial(boolean initial) {

        m_initial = initial;
    }

    /**
    * Sets the localized messages.<p>
    *
    * @param messages the localized messages
    */
    protected void setMessages(CmsMessages messages) {

        addMessages(messages);
    }

    /**
     * Returns if the optional check page should be displayed.<p>
     *
     * @return <code>true</code> if the optional check page should be displayed, otherwise <code>false</code>
     */
    public boolean showCheck() {

        boolean result = false;

        if (getFormConfiguration().getShowCheck() && ACTION_SUBMIT.equals(getParameter(PARAM_FORMACTION))) {
            result = true;
        } else if (getFormConfiguration().captchaFieldIsOnCheckPage()
            && ACTION_CONFIRMED.equals(getParameter(PARAM_FORMACTION))
            && !validate()) {
                result = true;
            }

        return result;
    }

    /**
     * Returns if the expiration text should be shown instead of the form.<p>
     *
     * @return <code>true</code> if the expiration text should be shown, otherwise <code>false</code>
     */
    public boolean showExpired() {

        return (getFormConfiguration().getExpirationDate() > 0)
            && (System.currentTimeMillis() > getFormConfiguration().getExpirationDate());
    }

    /**
     * Returns if the input form should be displayed.<p>
     *
     * @return <code>true</code> if the input form should be displayed, otherwise <code>false</code>
     */
    public boolean showForm() {

        boolean result = false;
        String formAction = getParameter(PARAM_FORMACTION);

        if (isInitial()) {
            // initial call
            result = true;
        } else if (ACTION_CORRECT_INPUT.equalsIgnoreCase(formAction)) {
            // user decided to modify his inputs
            result = true;
        } else if (ACTION_SUBMIT.equalsIgnoreCase(formAction) && !validate()) {
            // input field validation failed
            result = true;

            if (getFormConfiguration().hasCaptchaField() && getFormConfiguration().captchaFieldIsOnCheckPage()) {
                // if there is a captcha field and a check page configured, we do have to remove the already
                // initialized captcha field from the form again. the captcha field gets initialized together with
                // the form, in this moment it is not clear yet whether we have validation errors or and need to
                // to go back to the input form...
                getFormConfiguration().removeCaptchaField();
            }
        } else if (ACTION_CONFIRMED.equalsIgnoreCase(formAction)
            && getFormConfiguration().captchaFieldIsOnCheckPage()
            && !validate()) {
                // captcha field validation on check page failed: redisplay the check page, not the input page!
                result = false;
            } else if (CmsStringUtil.isNotEmpty(getParameter(PARAM_BACK + getFormConfiguration().getConfigId()))) {
                result = true;
            } else if ((CmsStringUtil.isNotEmpty(getParameter(PARAM_PAGE + getFormConfiguration().getConfigId())))
                && CmsStringUtil.isEmpty(getParameter(PARAM_FINALPAGE))) {
                    result = true;
                }

        return result;
    }

    /**
     * Returns if the release text should be shown instead of the form.<p>
     *
     * @return <code>true</code> if the release text should be shown, otherwise <code>false</code>
     */
    public boolean showRelease() {

        return (getFormConfiguration().getReleaseDate() > 0)
            && (System.currentTimeMillis() < getFormConfiguration().getReleaseDate());
    }

    /**
     * Checks if the given field should be used in form data macros.<p>
     *
     * @param field the field to check
     *
     * @return if the given field should be used in form data macros
     */
    protected boolean useInFormDataMacro(I_CmsField field) {

        // don't show the letter of agreement (CmsPrivacyField) and captcha field value
        return !((field instanceof CmsPrivacyField) || (field instanceof CmsCaptchaField));
    }

    /**
     * Validation method that checks the given input fields.<p>
     *
     * All errors are stored in the member m_errors Map, with the input field name as key
     * and the error message String as value.<p>
     *
     * @return <code>true</code> if all necessary fields can be validated, otherwise <code>false</code>
     */
    public boolean validate() {

        if (m_isValidatedCorrect != null) {
            return m_isValidatedCorrect.booleanValue();
        }

        boolean allOk = true;

        // if the previous button was used, then no validation is necessary here
        if (CmsStringUtil.isNotEmpty(getParameter(PARAM_BACK + getFormConfiguration().getConfigId()))) {
            return true;
        }

        // iterate the form fields
        List<I_CmsField> fields = getFormConfiguration().getFields();

        int pagingPos = fields.size();
        if (CmsStringUtil.isNotEmpty(getParameter(PARAM_PAGE + getFormConfiguration().getConfigId()))) {
            int value = new Integer(getParameter(PARAM_PAGE + getFormConfiguration().getConfigId())).intValue();
            pagingPos = CmsPagingField.getLastFieldPosFromPage(this, value) + 1;
        }

        // validate each form field
        for (int i = 0, n = pagingPos; i < n; i++) {

            I_CmsField currentField = fields.get(i);

            if (CmsCaptchaField.class.isAssignableFrom(currentField.getClass())) {
                // the captcha field doesn't get validated here...
                continue;
            }

            // call the field validation
            if (!validateField(currentField)) {
                allOk = false;
            }
            if (currentField.hasCurrentSubFields()) {
                // also validate the current sub fields
                Iterator<I_CmsField> k = currentField.getCurrentSubFields().iterator();
                while (k.hasNext()) {
                    // call the sub field validation
                    if (!validateField(k.next())) {
                        allOk = false;
                    }
                }
            }
        }

        CmsCaptchaField captchaField = getFormConfiguration().getCaptchaField();
        if ((captchaField != null) && (pagingPos == fields.size())) {
            // captcha field is enabled and we are on the last page or check page
            boolean captchaFieldIsOnInputPage = getFormConfiguration().captchaFieldIsOnInputPage()
                && getFormConfiguration().isInputFormSubmitted();
            boolean captchaFieldIsOnCheckPage = getFormConfiguration().captchaFieldIsOnCheckPage()
                && getFormConfiguration().isCheckPageSubmitted();

            if (captchaFieldIsOnInputPage || captchaFieldIsOnCheckPage) {
                if (!captchaField.validateCaptchaPhrase(this, captchaField.getValue())) {
                    getErrors().put(captchaField.getName(), ERROR_VALIDATION);
                    allOk = false;
                }
            }
        }

        m_isValidatedCorrect = Boolean.valueOf(allOk);
        return allOk;
    }

    /**
     * Validates a single form field.<p>
     *
     * @param field the field to validate
     *
     * @return <code>true</code> if the field is validated, otherwise <code>false</code>
     */
    private boolean validateField(I_CmsField field) {

        if (field == null) {
            return true;
        }

        if (CmsCaptchaField.class.isAssignableFrom(field.getClass())) {
            // the captcha field doesn't get validated here...
            return true;
        }

        // check if a file upload field is empty, but it was filled out already
        String validationInfo = "";
        validationInfo = field.validateForInfo(this);
        if (CmsStringUtil.isNotEmpty(validationInfo)) {
            getInfos().put(field.getName(), validationInfo);
        }
        // check for validation errors
        String validationError = field.validate(this);
        if (CmsStringUtil.isNotEmpty(validationError)) {
            getErrors().put(field.getName(), validationError);
            return false;
        }
        return true;
    }
}
