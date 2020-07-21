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

import static alkacon.mercury.webform.CmsFormContentUtil.getContentValues;

import alkacon.mercury.template.CmsFunctionLinkResolver;
import alkacon.mercury.webform.captcha.CmsCaptchaSettings;
import alkacon.mercury.webform.fields.A_CmsField;
import alkacon.mercury.webform.fields.CmsCaptchaField;
import alkacon.mercury.webform.fields.CmsCheckboxField;
import alkacon.mercury.webform.fields.CmsEmailField;
import alkacon.mercury.webform.fields.CmsEmptyField;
import alkacon.mercury.webform.fields.CmsFieldFactory;
import alkacon.mercury.webform.fields.CmsFieldItem;
import alkacon.mercury.webform.fields.CmsFieldText;
import alkacon.mercury.webform.fields.CmsFileUploadField;
import alkacon.mercury.webform.fields.CmsHiddenField;
import alkacon.mercury.webform.fields.CmsPrivacyField;
import alkacon.mercury.webform.fields.I_CmsField;

import org.opencms.ade.detailpage.CmsDetailPageInfo;
import org.opencms.configuration.CmsConfigurationException;
import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsRequestContext;
import org.opencms.i18n.CmsMessages;
import org.opencms.jsp.CmsJspActionElement;
import org.opencms.mail.CmsMailHost;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;
import org.opencms.workplace.CmsWorkplace;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;
import java.util.StringTokenizer;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.logging.Log;

/**
 * Represents an input form with all configured fields and options.<p>
 *
 * Provides the necessary information to create an input form, email messages and confirmation outputs.<p>
 */
public class CmsForm {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsForm.class);

    /** The macro to determine that field items for radio buttons and check boxes should be shown in a row. */
    public static final String MACRO_SHOW_ITEMS_IN_ROW = "%(row)";

    /** Macro name for the title set in the content. */
    public static final String MACRO_CONTENT_TITLE = "content.Title";

    /** Mail type: html mail. */
    public static final String MAILTYPE_HTML = "html";

    /** Mail type: text mail. */
    public static final String MAILTYPE_TEXT = "text";

    /** The module name. */
    public static final String MODULE_NAME = CmsForm.class.getPackage().getName();

    /** Name of the module parameter for the configuration of the prefix list of system readable fonts like 'arial|serif'. */
    public static final String MODULE_PARAM_FONT_PREFIX = "font-prefix";

    /** Name of the template file parameter that is used as default HTML template for the form. */
    public static final String MODULE_PARAM_TEMPLATE_FILE = "templatefile";

    /** Name of the upload folder module parameter. */
    public static final String MODULE_PARAM_UPLOADFOLDER = "uploadfolder";

    /** Name of the upload project module parameter. */
    public static final String MODULE_PARAM_UPLOADPROJECT = "uploadproject";

    /** Name of the upload VFS module parameter. */
    public static final String MODULE_PARAM_UPLOADVFS = "uploadvfs";

    /** Configuration node name for the optional webform action class. */
    public static final String NODE_ACTION_CLASS = "ActionClass";

    /** Configuration node name for the optional captcha. */
    public static final String NODE_CAPTCHA = "FormCaptcha";

    /** Configuration node name for the optional captcha. */
    public static final String NODE_CAPTCHA_PRESET = "Preset";

    /** Configuration node name for the column to show the text. */
    public static final String NODE_COLUMN = "Column";

    /** Configuration node name for the confirmation mail checkbox label text. */
    public static final String NODE_CONFIRMATIONMAILCHECKBOXLABEL = "ConfirmationCheckboxLabel";

    /** Configuration node name for the confirmation mail enabled node. */
    public static final String NODE_CONFIRMATIONMAILENABLED = "ConfirmationMailEnabled";

    /** Configuration node name for the confirmation mail input field node. */
    public static final String NODE_CONFIRMATIONMAILFIELD = "ConfirmationField";

    /** Configuration node name for the option confirmation mail from node. */
    public static final String NODE_CONFIRMATIONMAILFROM = "ConfirmationMailFrom";

    /** Configuration node name for the option confirmation mail from name node. */
    public static final String NODE_CONFIRMATIONMAILFROMNAME = "ConfirmationMailFromName";

    /** Configuration node name for the confirmation mail optional flag node. */
    public static final String NODE_CONFIRMATIONMAILOPTIONAL = "ConfirmationMailOptional";

    /** Configuration node name for the confirmation mail subject node. */
    public static final String NODE_CONFIRMATIONMAILSUBJECT = "ConfirmationMailSubject";

    /** Configuration node name for the confirmation mail text node. */
    public static final String NODE_CONFIRMATIONMAILTEXT = "ConfirmationMailText";

    /** Configuration node name for the date. */
    public static final String NODE_DATE = "Date";

    /** Configuration node name for the Email node. */
    public static final String NODE_EMAIL = "Email";

    /** Configuration node name for the field value node. */
    public static final String NODE_FIELDDEFAULTVALUE = "FieldDefault";

    /** Configuration node name for the field error message node. */
    public static final String NODE_FIELDERRORMESSAGE = "FieldErrorMessage";

    /** Configuration node name for the field item node. */
    public static final String NODE_FIELDITEM = "FieldItem";

    /** Configuration node name for the field description node. */
    public static final String NODE_FIELDLABEL = "FieldLabel";

    /** Configuration node name for the field mandatory node. */
    public static final String NODE_FIELDMANDATORY = "FieldMandatory";

    /** Configuration node name for the field params node. */
    public static final String NODE_FIELDPARAMS = "FieldParams";

    /** Configuration node name for the field type node. */
    public static final String NODE_FIELDTYPE = "FieldType";

    /** Configuration node name for the field validation node. */
    public static final String NODE_FIELDVALIDATION = "FieldValidation";

    /** Configuration node name for the form check page text node. */
    public static final String NODE_FORMCHECKTEXT = "CheckText";

    /** Configuration node name for the form confirmation text node. */
    public static final String NODE_FORMCONFIRMATION = "FormConfirmation";

    /** Configuration node name for the form footer text node. */
    public static final String NODE_FORMFOOTERTEXT = "FormFooterText";

    /** Configuration node name for the form middle text node. */
    public static final String NODE_FORMMIDDLETEXT = "FormMiddleText";

    /** Configuration node name for the form text node. */
    public static final String NODE_FORMTEXT = "FormText";

    /** Configuration node name for the optional forward mode. */
    public static final String NODE_FORWARD_MODE = "ForwardMode";

    /** Configuration node name for the input field node. */
    public static final String NODE_INPUTFIELD = "InputField";

    /** Configuration node name for the instant redirect node. */
    public static final String NODE_INSTANTREDIRECT = "InstantRedirect";

    /** Configuration node name for the item description node. */
    public static final String NODE_ITEMDESCRIPTION = "ItemDescription";

    /** Configuration node name for the item selected node. */
    public static final String NODE_ITEMSELECTED = "ItemSelected";

    /** Configuration node name for the item value node. */
    public static final String NODE_ITEMVALUE = "ItemValue";

    /** Configuration node name for the optional keep session node. */
    public static final String NODE_KEEPSESSION = "KeepSession";

    /** Configuration node name for the optional link node. */
    public static final String NODE_LINK = "Link";

    /** Configuration node name for the email BCC recipient(s) node. */
    public static final String NODE_MAILBCC = "MailBCC";

    /** Configuration node name for the email CC recipient(s) node. */
    public static final String NODE_MAILCC = "MailCC";

    /** Configuration node name for the email CSS style sheet node. */
    public static final String NODE_MAILCSS = "MailCSS";

    /** Configuration node name for the email sender address node. */
    public static final String NODE_MAILFROM = "MailFrom";

    /** Configuration node name for the email sender name node. */
    public static final String NODE_MAILFROMNAME = "MailFromName";

    /** Configuration node name for the email subject node. */
    public static final String NODE_MAILSUBJECT = "MailSubject";

    /** Configuration node name for the email text node. */
    public static final String NODE_MAILTEXT = "MailText";

    /** Configuration node name for the email recipient(s) node. */
    public static final String NODE_MAILTO = "MailTo";

    /** Configuration node name for the email type node. */
    public static final String NODE_MAILTYPE = "MailType";

    /** Parent node for a nested web form. */
    public static final String NODE_NESTED_FORM = "Form";

    /** Configuration node name for the optional form configuration. */
    public static final String NODE_OPTIONALCONFIGURATION = "OptionalFormConfiguration";

    /** Configuration node name for the optional confirmation mail configuration. */
    public static final String NODE_OPTIONALCONFIRMATION = "OptionalConfirmationMail";

    /** Configuration node name for the optional form expiration configuration. */
    public static final String NODE_OPTIONALEXPIRATION = "OptionalFormExpiration";

    /** Configuration node name for the optional field text configuration. */
    public static final String NODE_OPTIONALFIELDTEXT = "OptionalFieldText";

    /** Configuration node name for the optional form max submissions configuration. */
    public static final String NODE_OPTIONALMAXSUBMISSIONS = "OptionalFormMaxSubmissions";

    /** Configuration node name for the optional form release configuration. */
    public static final String NODE_OPTIONALRELEASE = "OptionalFormRelease";

    /** Configuration node name for the optional sub field configuration. */
    public static final String NODE_OPTIONALSUBFIELD = "OptionalSubField";

    /** Configuration node name for the parent field. */
    public static final String NODE_PARENTFIELD = "ParentField";

    /** Configuration node name for the Show check page node. */
    public static final String NODE_SHOWCHECK = "ShowCheck";

    /** Configuration node name for the Show mandatory markings node. */
    public static final String NODE_SHOWMANDATORY = "ShowMandatory";

    /** Configuration node name for the Show reset button node. */
    public static final String NODE_SHOWRESET = "ShowReset";

    /** Configuration node name for the optional target URI. */
    public static final String NODE_TARGET_URI = "TargetUri";

    /** Configuration node name for the optional HTML template file. */
    public static final String NODE_TEMPLATE_FILE = "TemplateFile";

    /** Configuration node name for the text node. */
    public static final String NODE_TEXT = "Text";

    /** Configuration node name for the title node. */
    public static final String NODE_TITLE = "Title";

    /** Configuration node name for the value. */
    public static final String NODE_VALUE = "Value";

    /** Request parameter name for the optional send confirmation email checkbox. */
    public static final String PARAM_SENDCONFIRMATION = "sendconfirmation";

    /** Mailto property: can be attached to container page. Overwrites the "Mail to" field from the webform. */
    public static final String PROPERTY_MAILTO = "webform.mailto";

    /** Privacy link property: defines the link to the privacy notes page. Is used for the automatic privacy check field configuration. */
    public static final String PROPERTY_PRIVACYLINK = "webform.privacy.link";

    /** The path to the default HTML templates for the form. */
    public static final String VFS_PATH_DEFAULT_TEMPLATEFILE = CmsWorkplace.VFS_PATH_MODULES
        + MODULE_NAME
        + "/resources/formtemplates/default.st";

    /** The path to the error HTML templates for the form. */
    public static final String VFS_PATH_ERROR_TEMPLATEFILE = CmsWorkplace.VFS_PATH_MODULES
        + CmsForm.MODULE_NAME
        + "/resources/formtemplates/error.st";

    /** The type name of the XML content with the form contiguration. */
    public static final String TYPE_FORM_CONFIG = "m-webform";

    /** Special key in the dynamic configuration to overwrite the form id. */
    public static final String CONFIG_KEY_FORM_ID = "formid";

    /** The webform action class name. */
    protected String m_actionClass;

    /** The captcha field. */
    protected CmsCaptchaField m_captchaField;

    /** The form configuration ID. */
    protected int m_configId;

    /** Map with additional values passed to the form. */
    protected Map<String, String> m_extraConfig;

    /** The list of possible configuration errors. */
    protected List<String> m_configurationErrors;

    /** The form configuration URI. */
    protected String m_configUri;

    /** configuration value. */
    protected String m_confirmationMailCheckboxLabel;

    /** configuration value. */
    protected boolean m_confirmationMailEnabled;

    /** configuration value. */
    protected int m_confirmationMailField;

    /** configuration value. */
    protected String m_confirmationMailFieldDbLabel;

    /** configuration value. */
    protected String m_confirmationMailFrom;

    /** configuration value. */
    protected String m_confirmationMailFromName;

    /** configuration value. */
    protected boolean m_confirmationMailOptional;

    /** configuration value. */
    protected String m_confirmationMailSubject;

    /** configuration value. */
    protected String m_confirmationMailText;

    /** configuration value. */
    protected String m_confirmationMailTextPlain;

    /** Stores the form dynamic input fields. */
    protected List<I_CmsField> m_dynaFields;

    /** The optional form expiration date. */
    protected long m_expirationDate;

    /** The form expiration text. */
    protected String m_expirationText;

    /** Stores the form input fields. */
    protected List<I_CmsField> m_fields;

    /** Allows to access form fields internally by name. */
    protected Map<String, I_CmsField> m_fieldsByName;

    /** configuration value. */
    protected String m_formAction;

    /** configuration value. */
    protected String m_formCheckText;

    /** configuration value. */
    protected String m_formConfirmationText;

    /** configuration value. */
    protected String m_formFooterText;

    /** configuration value. */
    protected String m_formMiddleText;

    /** configuration value. */
    protected String m_formText;

    /** If there is at least one mandatory field. */
    protected boolean m_hasMandatoryFields;

    /** Flag if there is a privacy field defined. */
    protected boolean m_hasPrivacyField;

    /** indicates if an instant redirect is configured. */
    protected boolean m_instantRedirect;

    /** The current jsp action element. */
    protected CmsJspActionElement m_jspAction;

    /** configuration value. */
    protected String m_mailBCC;

    /** configuration value. */
    protected String m_mailCC;

    /** The optional email CSS style sheet. */
    protected String m_mailCSS;

    /** The mail sender address. */
    protected String m_mailFrom;

    /** The mail sender name. */
    protected String m_mailFromName;

    /** configuration value. */
    protected String m_mailSubject;

    /** configuration value. */
    protected String m_mailSubjectPrefix;

    /** configuration value. */
    protected String m_mailText;

    /** configuration value. */
    protected String m_mailTextPlain;

    /** configuration value. */
    protected String m_mailTo;

    /** The email type, either HTML or text mail. */
    protected String m_mailType;

    /** The optional form max submissions. */
    protected long m_maxSubmissions;

    /** The optional form max submissions text. */
    protected String m_maxSubmissionsText;

    /** The map of request parameters. */
    protected Map<String, String[]> m_parameterMap;

    /** Interval to refresh the session. */
    protected int m_refreshSessionInterval;

    /** The optional form release date. */
    protected long m_releaseDate;

    /** The optional form release text. */
    protected String m_releaseText;

    /** Flag if the check page has to be shown. */
    protected boolean m_showCheck;

    /** Flag if the text to explain mandatory fields has to be shown. */
    protected boolean m_showMandatory;

    /** Flag if the reset button has to be shown. */
    protected boolean m_showReset;

    /** The form target URI. */
    protected String m_targetUri;

    /** The optional HTML template file URI. */
    protected String m_templateFile;

    /** The form title. */
    protected String m_title;

    /** The forward mode. */
    private boolean m_forwardMode;

    /** The UGC configuration for storing form data as XML content. */
    protected CmsFormUgcConfiguration m_ugcConfig;

    /**
     * Default constructor which parses the configuration file.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the configuration file, otherwise from the request
     * @throws Exception if parsing the configuration fails
     */
    public CmsForm(CmsFormHandler jsp, CmsMessages messages, boolean initial)
    throws Exception {

        this(jsp, messages, initial, null, null);
    }

    /**
     * Constructor which parses the configuration file using a given configuration file URI.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the configuration file, otherwise from the request
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     *
     * @throws Exception if parsing the configuration fails
     */
    public CmsForm(CmsFormHandler jsp, CmsMessages messages, boolean initial, String formConfigUri, String formAction)
    throws Exception {

        // for backwards compatibility, not calling the next constructor with additional parameter
        init(jsp, messages, initial, formConfigUri, formAction);
    }

    /**
     * Constructor which parses the configuration file using a given configuration file URI.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the configuration file, otherwise from the request
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     *
     * @throws Exception if parsing the configuration fails
     */
    public CmsForm(
        CmsFormHandler jsp,
        CmsMessages messages,
        boolean initial,
        String formConfigUri,
        String formAction,
        Map<String, String> dynamicConfig)
    throws Exception {

        init(jsp, messages, initial, formConfigUri, formAction, dynamicConfig);
    }

    /**
     * Constructor which parses the configuration file using a given configuration file URI.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the configuration file, otherwise from the request
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     * @param extraConfig additional map accessible in the string template of the form
     *
     * @throws Exception if parsing the configuration fails
     */
    public CmsForm(
        CmsFormHandler jsp,
        CmsMessages messages,
        boolean initial,
        String formConfigUri,
        String formAction,
        Map<String, String> dynamicConfig,
        Map<String, String> extraConfig)
    throws Exception {

        init(jsp, messages, initial, formConfigUri, formAction, dynamicConfig, extraConfig);
    }

    /**
     * Tests, if the captcha field (if configured at all) should be displayed on the check page.<p>
     *
     * @return true, if the captcha field should be displayed on the check page
     */
    public boolean captchaFieldIsOnCheckPage() {

        return getShowCheck();
    }

    /**
     * Tests, if the captcha field (if configured at all) should be displayed on the input page.<p>
     *
     * @return true, if the captcha field should be displayed on the input page
     */
    public boolean captchaFieldIsOnInputPage() {

        return !getShowCheck();
    }

    /**
     * Returns the action class.
     * <p>
     *
     * @return the action class.
     */
    public String getActionClass() {

        return m_actionClass;
    }

    /**
     * Returns a list of field objects, exclusive sub fields, inclusive dynamic fields, for the online form.<p>
     *
     * @return a list of field objects, exclusive sub fields, inclusive dynamic fields
     */
    public List<I_CmsField> getAllFields() {

        return getAllFields(false, false, true);
    }

    /**
     * Returns a list of field objects, depending on the given parameters.<p>
     * @param includeShownSubFields indicates if only the shown sub fields should be included
     * @param includeAllSubFields indicates if all possible sub fields should be included
     * @param includeDynamicFields indicates if the dynamic fields should be included
     *
     * @return a list of field objects, depending on the given parameters
     */
    public List<I_CmsField> getAllFields(
        boolean includeShownSubFields,
        boolean includeAllSubFields,
        boolean includeDynamicFields) {

        List<I_CmsField> result = new ArrayList<>(m_fields.size() + 16);
        if (includeAllSubFields) {
            // all sub fields have to be added
            Iterator<I_CmsField> i = m_fields.iterator();
            while (i.hasNext()) {
                I_CmsField field = i.next();
                result.add(field);
                if (field.isHasSubFields()) {
                    Iterator<Entry<String, List<I_CmsField>>> k = field.getSubFields().entrySet().iterator();
                    while (k.hasNext()) {
                        Map.Entry<String, List<I_CmsField>> entry = k.next();
                        result.addAll(entry.getValue());
                    }
                }
            }
        } else if (includeShownSubFields) {
            // only shown sub fields have to be added
            Iterator<I_CmsField> i = m_fields.iterator();
            while (i.hasNext()) {
                I_CmsField field = i.next();
                result.add(field);
                if (field.hasCurrentSubFields()) {
                    result.addAll(field.getCurrentSubFields());
                }
            }
        } else {
            // no sub fields have to be added
            result = new ArrayList<>(m_fields);
        }

        if (includeDynamicFields) {
            result.addAll(m_dynaFields);
        }

        return result;
    }

    /**
     * Returns the (opt.) captcha field of this form.<p>
     *
     * @return the (opt.) captcha field of this form
     */
    public CmsCaptchaField getCaptchaField() {

        return m_captchaField;
    }

    /**
     * Returns the configuration ID of this form.<p>
     *
     * This ID is used as suffix for form field names and other field specific stuff,
     * making it possible to have more than one form on a page.<p>
     *
     * @return the configuration ID of this form
     */
    public int getConfigId() {

        if (m_configId == 0) {
            m_configId = getConfigUri().hashCode();
        }
        return m_configId;
    }

    /**
     * Returns the form configuration errors.<p>
     *
     * @return the form configuration errors
     */
    public List<String> getConfigurationErrors() {

        return m_configurationErrors;
    }

    /**
     * Returns the configuration Uri.<p>
     *
     * @return the configuration Uri
     */
    public String getConfigUri() {

        return m_configUri;
    }

    /**
     * Returns the label for the optional confirmation mail checkbox on the input form.<p>
     *
     * @return the label for the optional confirmation mail checkbox on the input form
     */
    public String getConfirmationMailCheckboxLabel() {

        return m_confirmationMailCheckboxLabel;
    }

    /**
     * Returns the confirmation mail receiver email address.<p>
     *
     * @return the confirmation mail receiver email address or <code>null</code> if not found
     */
    public String getConfirmationMailEmail() {

        if (getConfirmationMailField() != -1) {
            try {
                I_CmsField mailField = getFields().get(getConfirmationMailField());
                return mailField.getValue();
            } catch (Exception e) {
                // field not found
            }
        } else if (CmsStringUtil.isNotEmpty(getConfirmationMailFieldDbLabel())) {
            I_CmsField mailField = getFieldByDbLabel(getConfirmationMailFieldDbLabel());
            if (mailField != null) {
                return mailField.getValue();
            }
        }
        return null;
    }

    /**
     * Returns the index number of the input field containing the email address for the optional confirmation mail.<p>
     *
     * @return the index number of the input field containing the email address for the optional confirmation mail
     *
     * @deprecated use {@link #getConfirmationMailFieldDbLabel()} instead
     */
    @Deprecated
    public int getConfirmationMailField() {

        return m_confirmationMailField;
    }

    /**
     * Returns the DB label of the input field containing the email address for the optional confirmation mail.<p>
     *
     * @return the DB label of the input field containing the email address for the optional confirmation mail
     */
    public String getConfirmationMailFieldDbLabel() {

        return m_confirmationMailFieldDbLabel;
    }

    /**
     * Returns the optional confirmation mail from.<p>
     *
     * @return the optional confirmation mail from
     */
    public String getConfirmationMailFrom() {

        return m_confirmationMailFrom;
    }

    /**
     * Returns the optional confirmation mail from name.<p>
     *
     * @return the optional confirmation mail from name
     */
    public String getConfirmationMailFromName() {

        return m_confirmationMailFromName;
    }

    /**
     * Returns the subject of the optional confirmation mail.<p>
     *
     * @return the subject of the optional confirmation mail
     */
    public String getConfirmationMailSubject() {

        return m_confirmationMailSubject;
    }

    /**
     * Returns the text of the optional confirmation mail.<p>
     *
     * @return the text of the optional confirmation mail
     */
    public String getConfirmationMailText() {

        return m_confirmationMailText;
    }

    /**
     * Returns the plain text of the optional confirmation mail.<p>
     *
     * @return the plain text of the optional confirmation mail
     */
    public String getConfirmationMailTextPlain() {

        return m_confirmationMailTextPlain;
    }

    /**
     * Returns the optional form expiration date.<p>
     *
     * @return the optional form expiration date
     */
    public long getExpirationDate() {

        return m_expirationDate;
    }

    /**
     * Returns the form expiration text.<p>
     *
     * @return the form expiration text
     */
    public String getExpirationText() {

        return m_expirationText;
    }

    /**
     * Returns a map of additional configuration values to be accessed in the string template.
     * @return a map of additional configuration values to be accessed in the string template.
     */
    public Map<String, String> getExtraConfig() {

        return m_extraConfig;
    }

    /**
     * Returns the field with the given database label.<p>
     *
     * @param dbLabel the database label
     *
     * @return the field with the given database label or <code>null</code> if not found
     */
    public I_CmsField getFieldByDbLabel(String dbLabel) {

        Iterator<I_CmsField> it = getAllFields(false, true, true).iterator();
        while (it.hasNext()) {
            I_CmsField field = it.next();
            if (field.getDbLabel().equals(dbLabel)) {
                return field;
            }
        }
        return null;
    }

    /**
     * Returns the field specified by it's name (Xpath).<p>
     *
     * @param fieldName the field's name (Xpath)
     *
     * @return the field, or null
     */
    public I_CmsField getFieldByName(String fieldName) {

        return m_fieldsByName.get(fieldName);
    }

    /**
     * Returns a list of field objects for the online form.<p>
     *
     * @return a list of field objects for the online form
     */
    public List<I_CmsField> getFields() {

        return m_fields;
    }

    /**
     * Returns the value for a field specified by it's name (Xpath).<p>
     *
     * @param fieldName the field's name (Xpath)
     *
     * @return the field value, or null
     */
    public String getFieldStringValueByName(String fieldName) {

        I_CmsField field = m_fieldsByName.get(fieldName);
        if (field != null) {
            String fieldValue = field.getValue();
            return (fieldValue != null) ? fieldValue.trim() : "";
        }

        return "";
    }

    /**
     * Returns the form check text.<p>
     *
     * @return the form check text
     */
    public String getFormCheckText() {

        return m_formCheckText;
    }

    /**
     * Returns the form confirmation text.<p>
     *
     * @return the form confirmation text
     */
    public String getFormConfirmationText() {

        return m_formConfirmationText;
    }

    /**
     * Returns the form footer text.<p>
     *
     * @return the form footer text
     */
    public String getFormFooterText() {

        return m_formFooterText;
    }

    /**
     * Returns the form middle text.<p>
     *
     * @return the form middle text
     */
    public String getFormMiddleText() {

        return m_formMiddleText;
    }

    /**
     * Returns the form text.<p>
     *
     * @return the form text
     */
    public String getFormText() {

        return m_formText;
    }

    /**
     * Returns the current jsp action element.<p>
     *
     * @return the jsp action element
     */
    public CmsJspActionElement getJspAction() {

        return m_jspAction;
    }

    /**
     * Returns the mail bcc recipient(s).<p>
     *
     * @return the mail bcc recipient(s)
     */
    public String getMailBCC() {

        return m_mailBCC;
    }

    /**
     * Returns the mail cc recipient(s).<p>
     *
     * @return the mail cc recipient(s)
     */
    public String getMailCC() {

        return m_mailCC;
    }

    /**
     * Returns the optional email CSS style sheet.<p>
     *
     * @return the optional email CSS style sheet
     */
    public String getMailCSS() {

        return m_mailCSS;
    }

    /**
     * Returns the mail sender address.<p>
     *
     * @return the mail sender address
     */
    public String getMailFrom() {

        return m_mailFrom;
    }

    /**
     * Returns the mail sender name.<p>
     *
     * @return the mail sender name
     */
    public String getMailFromName() {

        return m_mailFromName;
    }

    /**
     * Returns the mail subject.<p>
     *
     * @return the mail subject
     */
    public String getMailSubject() {

        return m_mailSubject;
    }

    /**
     * Returns the mail subject prefix.<p>
     *
     * @return the mail subject prefix
     */
    public String getMailSubjectPrefix() {

        return m_mailSubjectPrefix;
    }

    /**
     * Returns the mail text.<p>
     *
     * @return the mail text
     */
    public String getMailText() {

        return m_mailText;
    }

    /**
     * Returns the mail text as plain text.<p>
     *
     * @return the mail text as plain text
     */
    public String getMailTextPlain() {

        return m_mailTextPlain;
    }

    /**
     * Returns the mail recipient(s).<p>
     *
     * @return the mail recipient(s)
     */
    public String getMailTo() {

        return m_mailTo;
    }

    /**
     * Returns the mail type ("text" or "html").<p>
     *
     * @return the mail type
     */
    public String getMailType() {

        return m_mailType;
    }

    /**
     * Returns the optional form maximum submissions number.<p>
     *
     * @return the optional form maximum submissions number
     */
    public long getMaximumSubmissions() {

        return m_maxSubmissions;
    }

    /**
     * Returns the form maximum submissions text.<p>
     *
     * @return the form maximum submissions text
     */
    public String getMaximumSubmissionsText() {

        return m_maxSubmissionsText;
    }

    /**
     * Returns the interval to refresh the session.<p>
     *
     * @return the interval to refresh the session
     */
    public int getRefreshSessionInterval() {

        return m_refreshSessionInterval;
    }

    /**
     * Returns the optional form release date.<p>
     *
     * @return the optional form release date
     */
    public long getReleaseDate() {

        return m_releaseDate;
    }

    /**
     * Returns the form release text.<p>
     *
     * @return the form release text
     */
    public String getReleaseText() {

        return m_releaseText;
    }

    /**
     * Returns if the check page should be shown.<p>
     *
     * @return true if the check page should be shown, otherwise false
     */
    public boolean getShowCheck() {

        return m_showCheck;
    }

    /**
     * Returns the target URI of this form.<p>
     *
     * This optional target URI can be used to redirect the user to an OpenCms page instead of displaying a confirmation
     * text from the form's XML content.<p>
     *
     * @return the target URI
     */
    public String getTargetUri() {

        return m_targetUri;
    }

    /**
     * Returns the optional HTML template file.<p>
     *
     * @return the optional HTML template file
     */
    public String getTemplateFile() {

        return m_templateFile;
    }

    /**
     * Returns the form title.<p>
     *
     * @return the form title
     */
    public String getTitle() {

        return m_title;
    }

    /**
     * Returns the UGC configuration for saving form data in XML contents.
     * @return the UGC configuration for saving form data in XML contents.
     */
    public CmsFormUgcConfiguration getUgcConfiguration() {

        return m_ugcConfig;
    }

    /**
         * Tests if a captcha field is configured for this form.<p>
         *
         * @return true, if a captcha field is configured for this form
         */
    public boolean hasCaptchaField() {

        return m_captchaField != null;
    }

    /**
     * Returns if the form has configuration errors.<p>
     *
     * @return true if the form has configuration errors, otherwise false
     */
    public boolean hasConfigurationErrors() {

        return m_configurationErrors.size() > 0;
    }

    /**
     * Returns true if at least one of the configured fields is mandatory.<p>
     *
     * @return true if at least one of the configured fields is mandatory, otherwise false
     */
    public boolean hasMandatoryFields() {

        return m_hasMandatoryFields;
    }

    /**
     * Returns true if a privacy field is configured manually.<p>
     *
     * @return true if a privacy field is configured manually
     */
    public boolean hasPrivacyField() {

        return m_hasPrivacyField;
    }

    /**
     * Tests if this form has a target URI specified.<p>
     *
     * This optional target URI can be used to redirect the user to an OpenCms page instead of displaying a confirmation
     * text from the form's XML content.<p>
     *
     * @return the target URI
     */
    public boolean hasTargetUri() {

        return CmsStringUtil.isNotEmpty(m_targetUri);
    }

    /**
     * Initializes the form configuration and creates the necessary form field objects.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the XML configuration
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     *
     * @throws Exception if parsing the configuration fails
     */
    public void init(CmsFormHandler jsp, CmsMessages messages, boolean initial, String formConfigUri, String formAction)
    throws Exception {

        init(jsp, messages, initial, formConfigUri, formAction, null, null);
    }

    /**
     * Initializes the form configuration and creates the necessary form field objects.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the XML configuration
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     *
     * @throws Exception if parsing the configuration fails
     */
    public void init(
        CmsFormHandler jsp,
        CmsMessages messages,
        boolean initial,
        String formConfigUri,
        String formAction,
        Map<String, String> dynamicConfig)
    throws Exception {

        init(jsp, messages, initial, formConfigUri, formAction, dynamicConfig, null);
    }

    /**
     * Initializes the form configuration and creates the necessary form field objects.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the XML configuration
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param formAction the desired action submitted by the form
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     * @param extraConfig additional map accessible in the string template for the form.
     *
     * @throws Exception if parsing the configuration fails
     */
    public void init(
        CmsFormHandler jsp,
        CmsMessages messages,
        boolean initial,
        String formConfigUri,
        String formAction,
        Map<String, String> dynamicConfig,
        Map<String, String> extraConfig)
    throws Exception {

        if ((null != dynamicConfig) && dynamicConfig.containsKey(CONFIG_KEY_FORM_ID)) {
            setConfigId(dynamicConfig.get(CONFIG_KEY_FORM_ID));
        }
        if ((null != extraConfig)) {
            m_extraConfig = extraConfig;
        } else {
            m_extraConfig = Collections.emptyMap();
        }
        m_parameterMap = jsp.getParameterMap();
        // read the form configuration file from VFS
        if (CmsStringUtil.isEmpty(formConfigUri)) {
            formConfigUri = jsp.getRequestContext().getUri();
        }
        m_configUri = formConfigUri;
        CmsObject cms = jsp.getCmsObject();
        CmsFile file = cms.readFile(formConfigUri);
        CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, file);

        CmsRequestContext requestContext = cms.getRequestContext();
        Locale locale = OpenCms.getLocaleManager().getBestMatchingLocale(
            requestContext.getLocale(),
            OpenCms.getLocaleManager().getDefaultLocales(cms, requestContext.getUri()),
            content.getLocales());

        // init member variables
        initMembers();

        m_formAction = formAction;
        m_fields = new ArrayList<>();
        m_dynaFields = new ArrayList<>();
        m_fieldsByName = new HashMap<>();
        m_jspAction = jsp;

        // initialize general form configuration
        initFormGlobalConfiguration(content, cms, locale, messages, dynamicConfig);

        // initialize the form input fields
        initInputFields(content, jsp, locale, messages, initial);

        // init. the optional captcha field
        initCaptchaField(jsp, content, locale, initial);

        // add the captcha field to the list of all fields, if the form has no check page
        if (captchaFieldIsOnInputPage() && (m_captchaField != null)) {
            addField(m_captchaField);
        }
    }

    /**
     * Tests if the check page was submitted.<p>
     *
     * @return true, if the check page was submitted
     */
    public boolean isCheckPageSubmitted() {

        return CmsFormHandler.ACTION_CONFIRMED.equals(m_formAction);
    }

    /**
     * Returns if the optional confirmation mail is enabled.<p>
     *
     * @return true if the optional confirmation mail is enabled, otherwise false
     */
    public boolean isConfirmationMailEnabled() {

        return m_confirmationMailEnabled;
    }

    /**
     * Returns if the confirmation mail if optional, i.e. selectable by the form submitter.<p>
     *
     * @return true if the confirmation mail if optional, i.e. selectable by the form submitter, otherwise false
     */
    public boolean isConfirmationMailOptional() {

        return m_confirmationMailOptional;
    }

    /**
     * Returns <code>true</code> if the request should be forwarded to
     * the given target URI, <code>false</code> otherwise.<p>
     *
     * @return the <code>true</code> if the request should be forwarded
     */
    public boolean isForwardMode() {

        return m_forwardMode;
    }

    /**
     * Tests if the input page was submitted.<p>
     *
     * @return true, if the input page was submitted
     */
    public boolean isInputFormSubmitted() {

        return CmsFormHandler.ACTION_SUBMIT.equals(m_formAction);
    }

    /**
     * Returns the flag if an instant redirect to the configured target URI should be executed.<p>
     *
     * @return the flag if an instant redirect to the configured target URI should be executed
     */
    public boolean isInstantRedirect() {

        return m_instantRedirect;
    }

    /**
     * Returns if the session should be refreshed when displaying the form.<p>
     *
     * @return <code>true</code> if the session should be refreshed, otherwise <code>false</code>
     */
    public boolean isRefreshSession() {

        return m_refreshSessionInterval > 0;
    }

    /**
     * Returns if the mandatory marks and text should be shown.<p>
     *
     * @return true if the mandatory marks and text should be shown, otherwise false
     */
    public boolean isShowMandatory() {

        return m_showMandatory;
    }

    /**
     * Returns if the reset button should be shown.<p>
     *
     * @return true if the reset button should be shown, otherwise false
     */
    public boolean isShowReset() {

        return m_showReset;
    }

    /**
     * Returns <code>true</code>, iff UGC is configured, i.e., if the data from the form should be stored in XML files.
     * @return <code>true</code>, iff UGC is configured, i.e., if the data from the form should be stored in XML files.
     */
    public boolean isUgcConfigured() {

        return null != m_ugcConfig;
    }

    /**
     * Removes the captcha field from the list of all fields, if present.<p>
     */
    public void removeCaptchaField() {

        Iterator<I_CmsField> it = m_fields.iterator();
        while (it.hasNext()) {
            I_CmsField field = it.next();
            if (field instanceof CmsCaptchaField) {
                it.remove();
                m_fieldsByName.remove(field.getName());
            }
        }
    }

    /**
     * Sets the form text.<p>
     *
     * @param formText the form text
     */
    public void setFormText(String formText) {

        m_formText = formText;
    }

    /**
     * Sets if the mandatory marks and text should be shown.<p>
     *
     * @param showMandatory the setting for the mandatory marks
     */
    public void setShowMandatory(boolean showMandatory) {

        m_showMandatory = showMandatory;
    }

    /**
     * Sets if the reset button should be shown.<p>
     *
     * @param showReset the setting for the reset button
     */
    public void setShowReset(boolean showReset) {

        m_showReset = showReset;
    }

    /**
     * Sets the HTML template file.<p>
     *
     * This is public to be able to set the template file from a formatter JSP file.<p>
     *
     * @param templateFile the HTML template file
     */
    public void setTemplateFile(final String templateFile) {

        m_templateFile = templateFile;
    }

    /**
     * Sets the form title.<p>
     *
     * @param title the form title
     */
    public void setTitle(String title) {

        m_title = title;
    }

    /**
     * Adds a field to the form.<p>
     *
     * @param field the field to be added to the form
     */
    protected void addField(I_CmsField field) {

        m_fields.add(field);
        // store information about privacy field
        if (field instanceof CmsPrivacyField) {
            m_hasPrivacyField = true;
        }
        // the fields are also internally backed in a map keyed by their field name
        m_fieldsByName.put(field.getName(), field);
    }

    /**
     * Creates the checkbox field to activate the confirmation mail in the input form.<p>
     *
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the XML configuration, otherwise values are read from the request
     *
     * @return the checkbox field to activate the confirmation mail in the input form
     */
    protected I_CmsField createConfirmationMailCheckbox(CmsMessages messages, boolean initial) {

        A_CmsField field = new CmsCheckboxField();
        field.setName(PARAM_SENDCONFIRMATION + getConfigId());
        field.setDbLabel(PARAM_SENDCONFIRMATION);
        field.setLabel(messages.key(I_CmsFormMessages.FORM_CONFIRMATION_LABEL));
        // check the field status
        boolean isChecked = false;
        if (!initial && Boolean.valueOf(getParameter(PARAM_SENDCONFIRMATION + getConfigId())).booleanValue()) {
            // checkbox is checked by user
            isChecked = true;
        }
        // create item for field
        CmsFieldItem item = new CmsFieldItem(
            Boolean.toString(true),
            getConfirmationMailCheckboxLabel(),
            isChecked,
            false);
        List<CmsFieldItem> items = new ArrayList<>(1);
        items.add(item);
        field.setItems(items);
        return field;
    }

    /**
     * Instantiates a new type instance of the given field type.<p>
     *
     * @param fieldType the field type to instantiate
     *
     * @return the instantiated field type or <code>null</code> is fails
     */
    protected I_CmsField getField(String fieldType) {

        return CmsFieldFactory.getSharedInstance().getField(fieldType);
    }

    /**
     * Returns the request parameter with the specified name.<p>
     *
     * @param parameter the parameter to return
     *
     * @return the parameter value
     */
    protected String getParameter(String parameter) {

        try {
            return (m_parameterMap.get(parameter))[0];
        } catch (NullPointerException e) {
            return "";
        }
    }

    /**
     * Initializes the optional captcha field.<p>
     *
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param content the XML configuration content
     * @param locale the currently active Locale
     * @param initial if true, field values are filled with values specified in the XML configuration, otherwise values are read from the request
     */
    protected void initCaptchaField(CmsJspActionElement jsp, CmsXmlContent content, Locale locale, boolean initial) {

        boolean captchaFieldIsOnInputPage = captchaFieldIsOnInputPage();
        boolean displayCheckPage = captchaFieldIsOnCheckPage() && isInputFormSubmitted();
        boolean submittedCheckPage = captchaFieldIsOnCheckPage() && isCheckPageSubmitted();

        // Todo: read the captcha settings here, don't provide xmlcontent with form!!!
        if (captchaFieldIsOnInputPage || displayCheckPage || submittedCheckPage) {

            CmsObject cms = jsp.getCmsObject();

            I_CmsXmlContentValue xmlValueCaptcha = CmsFormContentUtil.getContentValue(content, NODE_CAPTCHA, locale);
            if (xmlValueCaptcha != null) {

                // get the field label
                String xPathCaptcha = xmlValueCaptcha.getPath() + "/";
                String stringValue = content.getStringValue(cms, xPathCaptcha + NODE_FIELDLABEL, locale);
                String fieldLabel = null != stringValue ? stringValue : "";

                // get the field value
                String fieldValue = "";
                if (!initial) {
                    fieldValue = getParameter(CmsCaptchaField.C_PARAM_CAPTCHA_PHRASE + getConfigId());
                    if (fieldValue == null) {
                        fieldValue = "";
                    }
                }

                // get the image settings from the XML content
                CmsCaptchaSettings captchaSettings = CmsCaptchaSettings.getInstance(jsp);
                captchaSettings.init(cms, content, locale, getConfigId());
                m_captchaField = new CmsCaptchaField(captchaSettings, fieldLabel, fieldValue);
            }
        }
    }

    /**
    * Initializes the general online form settings.<p>
    *
    * @param content the XML configuration content
    * @param cms the CmsObject to access the content values
    * @param locale the currently active Locale
    * @param messages the localized messages
    * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
    *
    * @throws Exception if initializing the form settings fails
    *
    */
    protected void initFormGlobalConfiguration(
        CmsXmlContent content,
        CmsObject cms,
        Locale locale,
        CmsMessages messages,
        Map<String, String> dynamicConfig)
    throws Exception {

        // create a macro resolver with the cms object
        CmsMacroResolver resolver = CmsMacroResolver.newInstance().setCmsObject(cms).setKeepEmptyMacros(true);

        CmsFormConfigParser configParser = new CmsFormConfigParser(cms, content, locale, resolver, dynamicConfig);

        // get the form title
        setTitle(configParser.getConfigurationValue(NODE_TITLE, ""));
        resolver.addMacro(MACRO_CONTENT_TITLE, getTitle());
        // get the form text
        setFormText(configParser.getResolvedConfigurationValue(NODE_FORMTEXT, null));
        // get the form middle text
        setFormMiddleText(configParser.getResolvedConfigurationValue(NODE_FORMMIDDLETEXT, null));
        // get the form footer text
        setFormFooterText(configParser.getResolvedConfigurationValue(NODE_FORMFOOTERTEXT, null));
        // get the form confirmation text
        setFormConfirmationText(configParser.getResolvedConfigurationValue(NODE_FORMCONFIRMATION, ""));
        // get the mail type
        setMailType(configParser.getConfigurationValue(NODE_MAILTYPE, MAILTYPE_HTML));
        // get the mail from address
        setMailFrom(configParser.getConfigurationValue(NODE_MAILFROM, ""));
        // get the mail from name
        setMailFromName(configParser.getConfigurationValue(NODE_MAILFROMNAME, ""));
        // get the mail to address(es)
        String mailto = (cms.readPropertyObject(cms.getRequestContext().getUri(), PROPERTY_MAILTO, false)).getValue("");
        if (CmsStringUtil.isNotEmpty(mailto)) {
            setMailTo(mailto);
        } else {
            setMailTo(configParser.getConfigurationValue(NODE_MAILTO, ""));
        }
        // get the mail CC recipient(s)
        setMailCC(configParser.getConfigurationValue(NODE_MAILCC, ""));
        // get the mail BCC recipient(s)
        setMailBCC(configParser.getConfigurationValue(NODE_MAILBCC, ""));
        // get the mail CSS style sheet
        setMailCSS(configParser.getConfigurationValue(NODE_MAILCSS, ""));
        // get the mail subject
        setMailSubject(configParser.getResolvedConfigurationValue(NODE_MAILSUBJECT, ""));
        // get the optional mail subject prefix from localized messages
        String subjectPrefix = messages.key(I_CmsFormMessages.FORM_MAILSUBJECT_PREFIX);
        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(subjectPrefix)) {
            // prefix present, set it
            setMailSubjectPrefix(subjectPrefix + " ");
        } else {
            // no prefix present
            setMailSubjectPrefix("");
        }
        // get the mail text.
        String mailText = configParser.getResolvedConfigurationValue(NODE_MAILTEXT, "");
        setMailText(mailText);
        // get the mail text as plain text
        mailText = CmsHtmlToTextConverter.htmlToText(mailText, cms.getRequestContext().getEncoding());
        setMailTextPlain(mailText);

        String pathPrefix = "";

        if (content.hasValue(NODE_OPTIONALCONFIGURATION, locale)) {
            // optional configuration options
            pathPrefix = NODE_OPTIONALCONFIGURATION + "/";

            // get the form check page flag
            setShowCheck(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(pathPrefix + NODE_SHOWCHECK, Boolean.FALSE.toString())));
            // get the check page text
            setFormCheckText(configParser.getResolvedConfigurationValue(pathPrefix + NODE_FORMCHECKTEXT, ""));
            // get the optional HTML template file
            String defaultTemplateFile = OpenCms.getModuleManager().getModule(MODULE_NAME).getParameter(
                MODULE_PARAM_TEMPLATE_FILE,
                VFS_PATH_DEFAULT_TEMPLATEFILE);
            setTemplateFile(configParser.getConfigurationValue(pathPrefix + NODE_TEMPLATE_FILE, defaultTemplateFile));
            // get the optional web form action class
            setActionClass(configParser.getConfigurationValue(pathPrefix + NODE_TEMPLATE_FILE, ""));
            // get the show mandatory setting
            setShowMandatory(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(pathPrefix + NODE_SHOWMANDATORY, Boolean.TRUE.toString())));
            // get the show reset button setting
            setShowReset(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(pathPrefix + NODE_SHOWRESET, Boolean.TRUE.toString())));

            // get the refresh session interval
            String refreshSessionInterval = configParser.getConfigurationValue(pathPrefix + NODE_KEEPSESSION, "");
            if (CmsStringUtil.isNotEmpty(refreshSessionInterval)) {
                try {
                    setRefreshSessionInterval(Integer.parseInt(refreshSessionInterval) * 1000);
                } catch (NumberFormatException nfe) {
                    // invalid value found, just do not set value
                }
            }

            // get the optional target URI
            setTargetUri(configParser.getConfigurationValue(pathPrefix + NODE_TARGET_URI, ""));
            // get the optional forward mode
            setForwardMode(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(pathPrefix + NODE_FORWARD_MODE, Boolean.FALSE.toString())));
            // get the optional instant redirect
            setInstantRedirect(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(pathPrefix + NODE_INSTANTREDIRECT, Boolean.FALSE.toString())));
        }

        // optional confirmation mail nodes
        pathPrefix = NODE_OPTIONALCONFIRMATION + "/";

        // get the confirmation mail enabled flag
        setConfirmationMailEnabled(
            Boolean.parseBoolean(
                configParser.getConfigurationValue(
                    pathPrefix + NODE_CONFIRMATIONMAILENABLED,
                    Boolean.FALSE.toString())));
        // get other confirmation mail nodes only if confirmation mail is enabled
        if (isConfirmationMailEnabled()) {
            // get the optional confirmation mail from
            setConfirmationMailFrom(configParser.getConfigurationValue(pathPrefix + NODE_CONFIRMATIONMAILFROM, ""));
            // get the optional confirmation mail from name
            setConfirmationMailFromName(
                configParser.getConfigurationValue(pathPrefix + NODE_CONFIRMATIONMAILFROMNAME, ""));

            // get the confirmation mail subject
            setConfirmationMailSubject(
                configParser.getResolvedConfigurationValue(pathPrefix + NODE_CONFIRMATIONMAILSUBJECT, ""));
            // get the confirmation mail text
            String confirmationMailText = configParser.getResolvedConfigurationValue(
                pathPrefix + NODE_CONFIRMATIONMAILTEXT,
                "");
            setConfirmationMailText(confirmationMailText);
            // get the confirmation mail text as plain text
            confirmationMailText = CmsHtmlToTextConverter.htmlToText(
                confirmationMailText,
                cms.getRequestContext().getEncoding());
            setConfirmationMailTextPlain(confirmationMailText);

            // get the confirmation mail field index number
            String confirmationField = configParser.getConfigurationValue(
                pathPrefix + NODE_CONFIRMATIONMAILFIELD,
                "nonumber");
            int fieldIndex = -1;
            try {
                fieldIndex = Integer.parseInt(confirmationField) - 1;
            } catch (Exception e) {
                // no field number given, store DB label
                if (confirmationField.contains("|")) {
                    confirmationField = confirmationField.substring(confirmationField.indexOf("|") + 1);
                }
                setConfirmationMailFieldDbLabel(confirmationField);
            }
            setConfirmationMailField(fieldIndex);
            // get the confirmation mail optional flag
            setConfirmationMailOptional(
                Boolean.parseBoolean(
                    configParser.getConfigurationValue(
                        pathPrefix + NODE_CONFIRMATIONMAILOPTIONAL,
                        Boolean.FALSE.toString())));
            // get the confirmation mail checkbox label text
            setConfirmationMailCheckboxLabel(
                configParser.getConfigurationValue(
                    pathPrefix + NODE_CONFIRMATIONMAILCHECKBOXLABEL,
                    messages.key(I_CmsFormMessages.FORM_CONFIRMATION_CHECKBOX)));
        }

        if (content.hasValue(NODE_OPTIONALEXPIRATION, locale)) {
            // optional confirmation mail nodes
            pathPrefix = NODE_OPTIONALEXPIRATION + "/";
            try {
                setExpirationDate(Long.parseLong(configParser.getConfigurationValue(pathPrefix + NODE_DATE, "")));
            } catch (Exception e) {
                // no valid expiration date defined, ignore setting
            }
            setExpirationText(configParser.getConfigurationValue(pathPrefix + NODE_TEXT, ""));
        }

        if (content.hasValue(NODE_OPTIONALRELEASE, locale)) {
            // optional form release nodes
            pathPrefix = NODE_OPTIONALRELEASE + "/";
            try {
                setReleaseDate(Long.parseLong(configParser.getConfigurationValue(pathPrefix + NODE_DATE, "")));
            } catch (Exception e) {
                // no valid release date defined, ignore setting
            }
            setReleaseText(configParser.getConfigurationValue(pathPrefix + NODE_TEXT, ""));
        }

        if (content.hasValue(NODE_OPTIONALCONFIGURATION + "/" + NODE_OPTIONALMAXSUBMISSIONS, locale)) {
            // optional form release nodes
            pathPrefix = NODE_OPTIONALCONFIGURATION + "/" + NODE_OPTIONALMAXSUBMISSIONS + "/";
            try {
                setMaximumSubmissions(Long.parseLong(configParser.getConfigurationValue(pathPrefix + NODE_VALUE, "")));
            } catch (Exception e) {
                // no valid release date defined, ignore setting
            }
            setMaximumSubmissionsText(configParser.getConfigurationValue(pathPrefix + NODE_TEXT, ""));
        }

        // init the UGC configuration
        try {
            m_ugcConfig = (new CmsFormUgcConfigurationReader()).readConfiguration(cms, content, locale, dynamicConfig);
        } catch (Exception e) {
            LOG.error("Reading the UGC configuration failed.", e);
        }
    }

    /**
     * Initializes the field objects of the form.<p>
     *
     * @param content the XML configuration content
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param locale the currently active Locale
     * @param messages the localized messages
     * @param initial if true, field values are filled with values specified in the XML configuration, otherwise values are read from the request
     * @throws CmsConfigurationException if parsing the configuration fails
     */
    protected void initInputFields(
        CmsXmlContent content,
        CmsJspActionElement jsp,
        Locale locale,
        CmsMessages messages,
        boolean initial)
    throws CmsConfigurationException {

        // initialize the optional field texts
        Map<String, CmsFieldText> fieldTexts = new HashMap<>();
        List<I_CmsXmlContentValue> textValues = getContentValues(content, NODE_OPTIONALFIELDTEXT, locale);
        for (Iterator<I_CmsXmlContentValue> i = textValues.iterator(); i.hasNext();) {
            I_CmsXmlContentValue textField = i.next();
            String textFieldPath = textField.getPath() + "/";
            String fieldLabel = content.getStringValue(jsp.getCmsObject(), textFieldPath + NODE_INPUTFIELD, locale);
            int pos = fieldLabel.indexOf('|') + 1;
            // Adjust field label to be the dbLabel if it is provided.
            if (pos > 0) {
                fieldLabel = pos < fieldLabel.length() ? fieldLabel.substring(pos) : fieldLabel.substring(0, pos - 1);
            }
            String fieldText = content.getStringValue(jsp.getCmsObject(), textFieldPath + NODE_TEXT, locale);
            String column = content.getStringValue(jsp.getCmsObject(), textFieldPath + NODE_COLUMN, locale);
            fieldTexts.put(fieldLabel, new CmsFieldText(fieldText, column));
        }

        // store the xPaths to the sub field definitions
        Map<String, List<String>> subFieldPaths = new HashMap<>();
        List<I_CmsXmlContentValue> subFieldValues = getContentValues(content, NODE_OPTIONALSUBFIELD, locale);
        for (Iterator<I_CmsXmlContentValue> i = subFieldValues.iterator(); i.hasNext();) {
            I_CmsXmlContentValue subField = i.next();
            String fieldLabel = content.getStringValue(
                jsp.getCmsObject(),
                subField.getPath() + "/" + NODE_PARENTFIELD,
                locale);
            if (fieldLabel.contains("|")) {
                fieldLabel = fieldLabel.substring(fieldLabel.indexOf("|") + 1);
            }
            List<String> storedPaths = subFieldPaths.get(fieldLabel);
            if (storedPaths == null) {
                storedPaths = new ArrayList<>();
            }
            storedPaths.add(subField.getPath());
            subFieldPaths.put(fieldLabel, storedPaths);
        }

        // get the file uploads stored in the session
        @SuppressWarnings("unchecked")
        Map<String, FileItem> fileUploads = (Map<String, FileItem>)jsp.getRequest().getSession().getAttribute(
            CmsFormHandler.ATTRIBUTE_FILEITEMS);

        // initialize the defined input fields
        List<I_CmsXmlContentValue> fieldValues = getContentValues(content, NODE_INPUTFIELD, locale);
        for (Iterator<I_CmsXmlContentValue> i = fieldValues.iterator(); i.hasNext();) {
            // add the initialized field
            addField(
                createInputField(
                    i.next().getPath(),
                    content,
                    jsp,
                    locale,
                    messages,
                    fieldTexts,
                    subFieldPaths,
                    fileUploads,
                    "",
                    initial,
                    false));
        }

        // assure privacy field presence
        initPrivacyField(initial, messages);

        if (!jsp.getRequestContext().getCurrentProject().isOnlineProject()) {
            // validate the form configuration in offline project
            validateFormConfiguration(messages);
        }

        if (isConfirmationMailEnabled() && isConfirmationMailOptional()) {
            // add the checkbox to activate confirmation mail for customer
            I_CmsField confirmationMailCheckbox = createConfirmationMailCheckbox(messages, initial);
            addField(confirmationMailCheckbox);
        }
    }

    /**
     * Initializes the member variables.<p>
     */
    protected void initMembers() {

        setConfigurationErrors(new ArrayList<String>());
        setFormCheckText("");
        setFormConfirmationText("");
        setFormText("");
        setFormFooterText("");
        setMailBCC("");
        setMailCC("");
        setMailFrom("");
        setMailSubject("");
        setMailText("");
        setMailTextPlain("");
        setMailTo("");
        setMailType(MAILTYPE_HTML);
        setConfirmationMailSubject("");
        setConfirmationMailText("");
        setConfirmationMailTextPlain("");
        setRefreshSessionInterval(-1);
        setShowMandatory(true);
        setShowReset(true);
        String tempfilePath = OpenCms.getModuleManager().getModule(MODULE_NAME).getParameter(
            MODULE_PARAM_TEMPLATE_FILE,
            VFS_PATH_DEFAULT_TEMPLATEFILE);
        setTemplateFile(tempfilePath);
        setTitle("");
    }

    /**
     * Initializes the automatically shown privacy field if none is configured manually.<p>
     *
     * @param initial if true, field values are filled with values specified in the XML configuration, otherwise values are read from the request
     * @param messages the localized messages
     */
    protected void initPrivacyField(boolean initial, CmsMessages messages) {

        if (!hasPrivacyField()) {
            // if no privacy field has been configured manually, add one automatically if configured in privacy policy content
            CmsObject cms = getJspAction().getCmsObject();
            // check property for privacy policy configuration
            String policyPath = "";
            try {
                policyPath = cms.readPropertyObject(
                    cms.getRequestContext().getUri(),
                    PROPERTY_PRIVACYLINK,
                    true).getValue("none");
            } catch (CmsException e) {
                // failed to read policy link property
                LOG.error(
                    "Failed to read property '" + PROPERTY_PRIVACYLINK + "' for " + cms.getRequestContext().getUri(),
                    e);
            }
            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(policyPath) && !"none".equals(policyPath)) {

                // check if function page and/or path is given as link
                String functionPart = "";
                String pathPart = policyPath;
                if (policyPath.contains("|")) {
                    String[] parts = CmsStringUtil.splitAsArray(policyPath, '|');
                    functionPart = parts[0].trim();
                    pathPart = parts[1].trim();
                } else if (policyPath.startsWith(CmsDetailPageInfo.FUNCTION_PREFIX)) {
                    functionPart = policyPath;
                    pathPart = "";
                }

                String linkToPolicy = CmsFunctionLinkResolver.resolveFunction(cms, functionPart);
                if (linkToPolicy == functionPart) {
                    // in case the function could not be resolved functionPart is returned
                    linkToPolicy = "";
                }

                if (CmsStringUtil.isEmpty(linkToPolicy) && CmsStringUtil.isNotEmpty(pathPart)) {
                    // function not found, check absolute path
                    if (cms.existsResource(pathPart)) {
                        linkToPolicy = OpenCms.getLinkManager().substituteLink(cms, pathPart);
                    }
                }

                if (CmsStringUtil.isNotEmpty(linkToPolicy)) {
                    CmsPrivacyField pField = new CmsPrivacyField();
                    // set the field values
                    pField.setMandatory(true);
                    String fieldLabel = messages.key("form.privacy.label");
                    pField.setLabel(fieldLabel);
                    pField.setDbLabel(fieldLabel);
                    pField.setName(fieldLabel + getConfigId());
                    pField.setMandatory(true);
                    // generate checkbox item for field
                    String label = linkToPolicy;
                    String value = messages.key("form.privacy.linktext");
                    String selected = "false";
                    if (!initial) {
                        // get selected flag from request for current item
                        selected = readSelectedFromRequest(pField, value);
                    }
                    List<CmsFieldItem> items = new ArrayList<>(1);
                    // add new item object
                    items.add(new CmsFieldItem(value, label, Boolean.valueOf(selected).booleanValue(), false));
                    pField.setItems(items);
                    addField(pField);
                }
            }
        }
    }

    /**
     * Marks the individual items of checkboxes, selectboxes and radiobuttons as selected depending on the given request parameters.<p>
     *
     * @param field the current field
     * @param value the value of the input field
     *
     * @return <code>"true"</code> if the current item is selected or checked, otherwise false
     */
    protected String readSelectedFromRequest(I_CmsField field, String value) {

        String result = "";
        if (field.needsItems()) {
            // select box or radio button or checkbox
            try {
                String[] values = m_parameterMap.get(field.getName());
                for (int i = 0; i < values.length; i++) {
                    if (CmsStringUtil.isNotEmpty(values[i]) && values[i].equals(value)) {
                        // mark this as selected
                        result = Boolean.toString(true);
                    }
                }
            } catch (Exception e) {
                // keep value null;
            }

        } else {
            // always display fields value arrays
            result = Boolean.toString(true);
        }
        return result;
    }

    /**
     * Sets the action class.
     * <p>
     *
     * @param actionClass the action class.
     */
    protected void setActionClass(final String actionClass) {

        m_actionClass = actionClass;
    }

    /**
     * Sets the form configuration errors.<p>
     *
     * @param configurationErrors the form configuration errors
     */
    protected void setConfigurationErrors(List<String> configurationErrors) {

        m_configurationErrors = configurationErrors;
    }

    /**
     * Sets the label for the optional confirmation mail checkbox on the input form.<p>
     *
     * @param confirmationMailCheckboxLabel the label for the optional confirmation mail checkbox on the input form
     */
    protected void setConfirmationMailCheckboxLabel(String confirmationMailCheckboxLabel) {

        m_confirmationMailCheckboxLabel = confirmationMailCheckboxLabel;
    }

    /**
     * Sets if the optional confirmation mail is enabled.<p>
     *
     * @param confirmationMailEnabled true if the optional confirmation mail is enabled, otherwise false
     */
    protected void setConfirmationMailEnabled(boolean confirmationMailEnabled) {

        m_confirmationMailEnabled = confirmationMailEnabled;
    }

    /**
     * Sets the index number of the input field containing the email address for the optional confirmation mail.<p>
     *
     * @param confirmationMailFieldName the name of the input field containing the email address for the optional confirmation mail
     *
     * @deprecated use {@link #setConfirmationMailFieldDbLabel(String)} instead
     */
    @Deprecated
    protected void setConfirmationMailField(int confirmationMailFieldName) {

        m_confirmationMailField = confirmationMailFieldName;
    }

    /**
     * Sets the DB label of the input field containing the email address for the optional confirmation mail.<p>
     *
     * @param confirmationMailFieldDbLabel the DB label of the input field containing the email address for the optional confirmation mail
     */
    protected void setConfirmationMailFieldDbLabel(String confirmationMailFieldDbLabel) {

        m_confirmationMailFieldDbLabel = confirmationMailFieldDbLabel;
    }

    /**
     * Sets the optional confirmation mail from.<p>
     *
     * @param confirmationMailFrom the optional confirmation mail from
     */
    protected void setConfirmationMailFrom(String confirmationMailFrom) {

        m_confirmationMailFrom = confirmationMailFrom;
    }

    /**
     * Sets the optional confirmation mail from name.<p>
     *
     * @param confirmationMailFromName the optional confirmation mail from
     */
    protected void setConfirmationMailFromName(String confirmationMailFromName) {

        m_confirmationMailFromName = confirmationMailFromName;
    }

    /**
     * Sets if the confirmation mail if optional, i.e. selectable by the form submitter.<p>
     *
     * @param confirmationMailOptional true if the confirmation mail if optional, i.e. selectable by the form submitter, otherwise false
     */
    protected void setConfirmationMailOptional(boolean confirmationMailOptional) {

        m_confirmationMailOptional = confirmationMailOptional;
    }

    /**
     * Sets the subject of the optional confirmation mail.<p>
     *
     * @param confirmationMailSubject the subject of the optional confirmation mail
     */
    protected void setConfirmationMailSubject(String confirmationMailSubject) {

        m_confirmationMailSubject = confirmationMailSubject;
    }

    /**
     * Sets the text of the optional confirmation mail.<p>
     *
     * @param confirmationMailText the text of the optional confirmation mail
     */
    protected void setConfirmationMailText(String confirmationMailText) {

        m_confirmationMailText = confirmationMailText;
    }

    /**
     * Sets the plain text of the optional confirmation mail.<p>
     *
     * @param confirmationMailTextPlain the plain text of the optional confirmation mail
     */
    protected void setConfirmationMailTextPlain(String confirmationMailTextPlain) {

        m_confirmationMailTextPlain = confirmationMailTextPlain;
    }

    /**
     * Sets the optional form expiration date.<p>
     *
     * @param expirationDate the optional form expiration date
     */
    protected void setExpirationDate(long expirationDate) {

        m_expirationDate = expirationDate;
    }

    /**
     * Sets the form expiration text.<p>
     *
     * @param expirationText the form expiration text
     */
    protected void setExpirationText(String expirationText) {

        m_expirationText = expirationText;
    }

    /**
     * Sets the form check text.<p>
     *
     * @param formCheckText the form confirmation text
     */
    protected void setFormCheckText(String formCheckText) {

        m_formCheckText = formCheckText;
    }

    /**
     * Sets the form confirmation text.<p>
     *
     * @param formConfirmationText the form confirmation text
     */
    protected void setFormConfirmationText(String formConfirmationText) {

        m_formConfirmationText = formConfirmationText;
    }

    /**
     * Sets the form footer text.<p>
     *
     * @param formFooterText the form text
     */
    protected void setFormFooterText(String formFooterText) {

        m_formFooterText = formFooterText;
    }

    /**
     * Sets the form middle text.<p>
     *
     * @param formMiddleText the form text
     */
    protected void setFormMiddleText(String formMiddleText) {

        m_formMiddleText = formMiddleText;
    }

    /**
     * Sets the optional forward mode.<p>
     *
     * @param isForward
     */
    protected void setForwardMode(boolean isForward) {

        m_forwardMode = isForward;
    }

    /**
     * Sets if at least one of the configured fields is mandatory.<p>
     *
     * @param hasMandatoryFields true if at least one of the configured fields is mandatory, otherwise false
     */
    protected void setHasMandatoryFields(boolean hasMandatoryFields) {

        m_hasMandatoryFields = hasMandatoryFields;
    }

    /**
     * Sets the flag if an instant redirect to the configured target URI should be executed.<p>
     *
     * @param instantRedirect the flag if an instant redirect to the configured target URI should be executed
     */
    protected void setInstantRedirect(boolean instantRedirect) {

        m_instantRedirect = instantRedirect;
    }

    /**
     * Sets the mail bcc recipient(s).<p>
     *
     * @param mailBCC the mail bcc recipient(s)
     */
    protected void setMailBCC(String mailBCC) {

        m_mailBCC = mailBCC;
    }

    /**
     * Sets the mail cc recipient(s).<p>
     *
     * @param mailCC the mail cc recipient(s)
     */
    protected void setMailCC(String mailCC) {

        m_mailCC = mailCC;
    }

    /**
     * Sets the optional email CSS style sheet.<p>
     *
     * @param mailCSS the optional email CSS style sheet
     */
    protected void setMailCSS(String mailCSS) {

        m_mailCSS = mailCSS;
    }

    /**
     * Sets the mail sender address.<p>
     *
     * @param mailFrom the mail sender address
     */
    protected void setMailFrom(String mailFrom) {

        m_mailFrom = mailFrom;
    }

    /**
     * Sets the mail sender name.<p>
     *
     * @param mailFromName the mail sender name
     */
    protected void setMailFromName(String mailFromName) {

        m_mailFromName = mailFromName;
    }

    /**
     * Sets the mail subject.<p>
     *
     * @param mailSubject the mail subject
     */
    protected void setMailSubject(String mailSubject) {

        m_mailSubject = mailSubject;
    }

    /**
     * Sets the mail subject prefix.<p>
     *
     * @param mailSubjectPrefix the mail subject prefix
     */
    protected void setMailSubjectPrefix(String mailSubjectPrefix) {

        m_mailSubjectPrefix = mailSubjectPrefix;
    }

    /**
     * Sets the mail text.<p>
     *
     * @param mailText the mail text
     */
    protected void setMailText(String mailText) {

        m_mailText = mailText;
    }

    /**
     * Sets the mail text as plain text.<p>
     *
     * @param mailTextPlain the mail text as plain text
     */
    protected void setMailTextPlain(String mailTextPlain) {

        m_mailTextPlain = mailTextPlain;
    }

    /**
     * Sets the mail recipient(s).<p>
     *
     * @param mailTo the mail recipient(s)
     */
    protected void setMailTo(String mailTo) {

        m_mailTo = mailTo;
    }

    /**
     * Sets the mail type ("text" or "html").<p>
     *
     * @param mailType the mail type
     */
    protected void setMailType(String mailType) {

        m_mailType = mailType;
    }

    /**
     * Sets the optional form max submissions number.<p>
     *
     * @param maxSubmissions the optional form max submissions number
     */
    protected void setMaximumSubmissions(long maxSubmissions) {

        m_maxSubmissions = maxSubmissions;
    }

    /**
     * Sets the form max submissions text.<p>
     *
     * @param maxSubmissionsText the form release text
     */
    protected void setMaximumSubmissionsText(String maxSubmissionsText) {

        m_maxSubmissionsText = maxSubmissionsText;
    }

    /**
     * Sets the interval to refresh the session.<p>
     *
     * @param refreshSessionInterval the interval to refresh the session
     */
    protected void setRefreshSessionInterval(int refreshSessionInterval) {

        m_refreshSessionInterval = refreshSessionInterval;
    }

    /**
     * Sets the optional form release date.<p>
     *
     * @param releaseDate the optional form release date
     */
    protected void setReleaseDate(long releaseDate) {

        m_releaseDate = releaseDate;
    }

    /**
     * Sets the form release text.<p>
     *
     * @param releaseText the form release text
     */
    protected void setReleaseText(String releaseText) {

        m_releaseText = releaseText;
    }

    /**
     * Sets if the check page should be shown.<p>
     *
     * @param showCheck true if the check page should be shown, otherwise false
     */
    protected void setShowCheck(boolean showCheck) {

        m_showCheck = showCheck;
    }

    /**
     * Sets the target URI of this form.<p>
     *
     * This optional target URI can be used to redirect the user to an OpenCms page instead of displaying a confirmation
     * text from the form's XML content.<p>
     *
     * @param targetUri the target URI
     */
    protected void setTargetUri(String targetUri) {

        m_targetUri = targetUri;
    }

    /**
     * Validates the loaded online form configuration and creates a list of error messages, if necessary.<p>
     *
     * @param messages the localized messages
     */
    protected void validateFormConfiguration(CmsMessages messages) {

        if (isConfirmationMailEnabled()) {
            // confirmation mail is enabled, make simple field check to avoid errors
            I_CmsField confirmField = null;
            if (getConfirmationMailField() != -1) {
                try {
                    // try to get the confirmation email field
                    confirmField = getFields().get(getConfirmationMailField());
                } catch (IndexOutOfBoundsException e) {
                    // specified confirmation email field does not exist
                    getConfigurationErrors().add(
                        messages.key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAILFIELD_NOTFOUND));
                    setConfirmationMailEnabled(false);
                    return;
                }
            } else if (CmsStringUtil.isNotEmpty(getConfirmationMailFieldDbLabel())) {
                confirmField = getFieldByDbLabel(getConfirmationMailFieldDbLabel());
                if (confirmField == null) {
                    getConfigurationErrors().add(
                        messages.key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAILFIELD_NOTFOUND));
                    setConfirmationMailEnabled(false);
                    return;
                }
            }
            if ((confirmField != null) && !CmsEmailField.class.isAssignableFrom(confirmField.getClass())) {
                // specified confirmation mail input field has wrong field type
                getConfigurationErrors().add(messages.key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAILFIELD_TYPE));
            }
        }
        // check mail configuration
        CmsMailHost host = OpenCms.getSystemInfo().getMailSettings().getDefaultMailHost();
        if ("my.smtp.server".equals(host.getHostname())) {
            getConfigurationErrors().add(messages.key(I_CmsFormMessages.FORM_CONFIGURATION_ERROR_EMAIL_HOST));
        }
    }

    /**
     * Initializes the field objects of the form.<p>
     *
     * @param xPath the xPath of the input field to initialize
     * @param content the XML configuration content
     * @param jsp the initialized CmsJspActionElement to access the OpenCms API
     * @param locale the currently active Locale
     * @param messages the localized messages
     * @param fieldTexts the optional field texts
     * @param subFieldPaths the optional sub field xPaths
     * @param fileUploads the uploaded files
     * @param subFieldNameSuffix the suffix for the sub field name used to create the HTML code and request parameter names
     * @param initial if true, field values are filled with values specified in the XML configuration, otherwise values are read from the request
     * @param subField indicates if a sub field should be created
     *
     * @return an initialized input field
     *
     * @throws CmsConfigurationException if parsing the configuration fails
     */
    private I_CmsField createInputField(
        String xPath,
        CmsXmlContent content,
        CmsJspActionElement jsp,
        Locale locale,
        CmsMessages messages,
        Map<String, CmsFieldText> fieldTexts,
        Map<String, List<String>> subFieldPaths,
        Map<String, FileItem> fileUploads,
        String subFieldNameSuffix,
        boolean initial,
        boolean subField)
    throws CmsConfigurationException {

        CmsObject cms = jsp.getCmsObject();

        // create the xPath prefix
        String inputFieldPath = xPath + "/";

        // get the field from the factory for the specified type
        // important: we don't use getContentStringValue, since the path comes directly from the input field
        String stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDTYPE, locale);
        I_CmsField field = getField(stringValue);

        // get the field labels
        stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDLABEL, locale);

        String locLabel = null != stringValue ? stringValue : "";
        String dbLabel = locLabel;
        boolean useDbLabel = false;
        int pos = locLabel.indexOf('|');
        if (pos > -1) {
            locLabel = locLabel.substring(0, pos);
            if ((pos + 1) < dbLabel.length()) {
                dbLabel = dbLabel.substring(pos + 1);
                useDbLabel = true;
            }
        }
        field.setLabel(locLabel);
        field.setDbLabel(dbLabel);

        // create the field name
        String fieldName = xPath;
        // cut off the XML content index ("[number]")
        int indexStart = fieldName.lastIndexOf('[') + 1;
        String index = fieldName.substring(indexStart, fieldName.length() - 1);
        if (useDbLabel) {
            // set field name to db label
            fieldName = dbLabel;
            field.setName(fieldName + getConfigId());
        } else {
            // set the field name to generic value "InputField-number"
            // replace the index ("[number]") of the xmlcontent field by "-number":
            fieldName = new StringBuffer(fieldName.substring(0, indexStart - 1)).append('-').append(index).toString();
            // cut off initial path all but the last path segments
            // (make sure there is a slash in the string first).
            fieldName = "/" + fieldName;
            int slashIndex = fieldName.lastIndexOf("/");
            fieldName = fieldName.substring(slashIndex + 1);
            field.setName(fieldName + subFieldNameSuffix + getConfigId());
        }

        // get the optional text that is shown below the field
        CmsFieldText fieldText = fieldTexts.get(dbLabel);
        if (fieldText != null) {
            field.setText(fieldText);
        }

        // get the optional subfields
        if (!subField) {
            List<String> subFieldPathList = subFieldPaths.get(dbLabel);
            if (subFieldPathList != null) {
                // there are sub fields defined for this input field
                for (Iterator<String> i = subFieldPathList.iterator(); i.hasNext();) {
                    String subPath = i.next() + "/";
                    String fieldValue = content.getStringValue(cms, subPath + NODE_VALUE, locale);
                    if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(fieldValue)) {
                        // a field value is specified, add the sub fields for the value
                        String suffix = new StringBuffer("-").append(index).append("-").append(
                            fieldValue.hashCode()).toString();
                        List<I_CmsXmlContentValue> fieldValues = content.getValues(subPath + NODE_INPUTFIELD, locale);
                        for (Iterator<I_CmsXmlContentValue> k = fieldValues.iterator(); k.hasNext();) {
                            field.addSubField(
                                fieldValue,
                                createInputField(
                                    k.next().getPath(),
                                    content,
                                    jsp,
                                    locale,
                                    messages,
                                    fieldTexts,
                                    subFieldPaths,
                                    fileUploads,
                                    suffix,
                                    initial,
                                    true));
                        }
                    }
                }
            }
        } else {
            // mark this field as sub field
            field.setSubField(subField);
        }

        // get the field parameters
        stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDPARAMS, locale);
        field.setParameters(stringValue);

        // validation error message
        stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDERRORMESSAGE, locale);
        field.setErrorMessage(stringValue);

        // fill object members in case this is no hidden field
        if (!CmsHiddenField.class.isAssignableFrom(field.getClass())) {
            // get the field validation regular expression
            stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDVALIDATION, locale);
            if (CmsEmailField.class.isAssignableFrom(field.getClass()) && CmsStringUtil.isEmpty(stringValue)) {
                // set default email validation expression for confirmation email address input field
                field.setValidationExpression(CmsEmailField.VALIDATION_REGEX);
            } else {
                field.setValidationExpression(null != stringValue ? stringValue : "");
            }
            if (CmsFileUploadField.class.isAssignableFrom(field.getClass())) {
                if (fileUploads != null) {
                    FileItem attachment = fileUploads.get(field.getName());
                    if (attachment != null) {
                        ((CmsFileUploadField)field).setFileSize(attachment.get().length);
                    }
                }
            }

            // get the field mandatory flag
            stringValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDMANDATORY, locale);
            boolean isMandatory = Boolean.valueOf(stringValue).booleanValue();
            field.setMandatory(isMandatory);
            if (isMandatory) {
                // set flag that determines if mandatory fields are present
                setHasMandatoryFields(true);
            }

            if (field.needsItems()) {
                // create items for checkboxes, radio buttons and selectboxes
                String fieldValue = content.getStringValue(

                    cms,
                    inputFieldPath + NODE_FIELDDEFAULTVALUE,
                    locale);
                if (CmsStringUtil.isNotEmpty(fieldValue)) {
                    // substitute eventual macros
                    CmsMacroResolver resolver = CmsMacroResolver.newInstance().setCmsObject(cms).setJspPageContext(
                        jsp.getJspContext());
                    fieldValue = resolver.resolveMacros(fieldValue);
                    // get items from String
                    boolean showInRow = false;
                    if (fieldValue.startsWith(MACRO_SHOW_ITEMS_IN_ROW)) {
                        showInRow = true;
                        fieldValue = fieldValue.substring(MACRO_SHOW_ITEMS_IN_ROW.length());
                    }
                    StringTokenizer T = new StringTokenizer(fieldValue, "|");
                    List<CmsFieldItem> items = new ArrayList<>(T.countTokens());
                    while (T.hasMoreTokens()) {
                        String part = T.nextToken();
                        // check pre selection of current item
                        boolean isPreselected = part.indexOf('*') != -1;
                        String value = "";
                        String label = "";
                        String selected = "";
                        int delimPos = part.indexOf(':');
                        if (delimPos != -1) {
                            // a special label text is given
                            value = part.substring(0, delimPos);
                            label = part.substring(delimPos + 1);
                        } else {
                            // no special label text present, use complete String
                            value = part;
                            label = value;
                        }

                        if (isPreselected) {
                            // remove preselected flag marker from Strings
                            value = CmsStringUtil.substitute(value, "*", "");
                            label = CmsStringUtil.substitute(label, "*", "");
                        }

                        if (initial) {
                            // only fill in values from configuration file if called initially
                            if (isPreselected) {
                                selected = Boolean.toString(true);
                            }
                        } else {
                            // get selected flag from request for current item
                            selected = readSelectedFromRequest(field, value);
                        }

                        // add new item object
                        items.add(new CmsFieldItem(value, label, Boolean.valueOf(selected).booleanValue(), showInRow));

                    }
                    field.setItems(items);
                } else {
                    // no items specified for checkbox, radio button or selectbox
                    throw new CmsConfigurationException(
                        LogMessages.get().container(
                            LogMessages.ERR_INIT_INPUT_FIELD_MISSING_ITEM_2,
                            field.getName(),
                            field.getType()));
                }
            }
        }
        // get the field value
        if (initial && CmsStringUtil.isEmpty(getParameter(field.getName()))) {
            // only fill in values from configuration file if called initially
            if (!field.needsItems()) {
                String fieldValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDDEFAULTVALUE, locale);
                if (CmsStringUtil.isNotEmpty(fieldValue)) {
                    CmsMacroResolver resolver = CmsMacroResolver.newInstance().setCmsObject(cms).setJspPageContext(
                        jsp.getJspContext());
                    fieldValue = resolver.resolveMacros(fieldValue);
                    field.setValue(fieldValue.trim());
                }
            } else {
                // for field that needs items,
                // the default value is used to set the items and not really a value
                field.setValue(null);
            }
        } else if (CmsFileUploadField.class.isAssignableFrom(field.getClass())) {
            // specific handling for file upload fields, because if they are filled out
            // they also shall be filled out if there are empty because there was an
            // other mandatory field not filled out or there was browsed through
            // different pages with the "prev" and the "next" buttons
            // here are also used hidden fields on the current page, that is why
            // it is possible that there are tow fields with the same name, one field
            // is the file upload field, the second one is the hidden field
            // the file upload field is the first one, the hidden field is the second one
            String[] parameterValues = m_parameterMap.get(field.getName());
            StringBuffer value = new StringBuffer();
            if (parameterValues != null) {
                if (parameterValues.length == 1) {
                    // there file upload field value is empty, so take the hidden field value
                    value.append(parameterValues[0]);
                } else {
                    // there are two fields with the same name
                    if (parameterValues[0].isEmpty()) {
                        // the file upload field is empty, so take the hidden field value
                        value.append(parameterValues[1]);
                    } else {
                        // the file upload field is not empty, so take this value, because
                        // so the user choosed another file than before (in the hidden field)
                        value.append(parameterValues[0]);
                    }
                }
            }
            field.setValue(value.toString());
        } else if (CmsEmptyField.class.isAssignableFrom(field.getClass())) {
            String fieldValue = content.getStringValue(cms, inputFieldPath + NODE_FIELDDEFAULTVALUE, locale);
            field.setValue(fieldValue);
        } else {
            // get field value from request for standard fields
            String[] parameterValues = m_parameterMap.get(field.getName());
            StringBuffer value = new StringBuffer();
            if (parameterValues != null) {
                for (int j = 0; j < parameterValues.length; j++) {
                    if (j != 0) {
                        value.append(", ");
                    }
                    value.append(parameterValues[j]);
                }
            }
            field.setValue(field.decodeValue(value.toString()));
        }
        return field;
    }

    /**
     * Sets the configuration ID for this form.<p>
     *
     * @param configIdObj the hashCode of the given Object is used a configuration ID for this form
     */
    private void setConfigId(Object configIdObj) {

        if (configIdObj != null) {
            m_configId = configIdObj.hashCode();
        }
    }
}
