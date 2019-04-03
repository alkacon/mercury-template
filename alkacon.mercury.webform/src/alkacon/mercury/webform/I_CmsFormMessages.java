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

import alkacon.mercury.webform.CmsForm;

/** Interface with constants for all message keys used by forms. These should be contained in the bundle "{@link CmsForm#MODULE_NAME}.workplace". */
public interface I_CmsFormMessages {

    /** Text on the button confirming that the user checked all input. */
    final String FORM_BUTTON_CHECKED = "form.button.checked";
    /** Text on the button for correcting the input. */
    final String FORM_BUTTON_CORRECT = "form.button.correct";
    /** Text on the "next" button. */
    final String FORM_BUTTON_NEXT = "form.button.next";
    /** Text on the "previous" button. */
    final String FORM_BUTTON_PREV = "form.button.prev";
    /** Text on the "reset" button. */
    final String FORM_BUTTON_RESET = "form.button.reset";
    /** Text on the "submit" button. */
    final String FORM_BUTTON_SUBMIT = "form.button.submit";
    /** Message to tell that the email host is not correctly configured. */
    final String FORM_CONFIGURATION_ERROR_EMAIL_HOST = "form.configuration.error.email.host";
    /** Message telling, that the input field that should contain the confirmation email address does not exist. */
    final String FORM_CONFIGURATION_ERROR_EMAILFIELD_NOTFOUND = "form.configuration.error.emailfield.notfound";
    /** Message telling, that the input field that should contain the confirmation email address does not have type of an email field. */
    final String FORM_CONFIGURATION_ERROR_EMAILFIELD_TYPE = "form.configuration.error.emailfield.type";
    /** Headline rendered when writing configuration errors into mails. */
    final String FORM_CONFIGURATION_ERROR_HEADLINE = "form.configuration.error.headline";
    /** Text for the checkbox for "Send an confirmation email". */
    final String FORM_CONFIRMATION_CHECKBOX = "form.confirmation.checkbox";
    /** Label of the "Confirmation" field. */
    final String FORM_CONFIRMATION_LABEL = "form.confirmation.label";
    /** Message used as headline in the submission failure feedback if the data could not be stored. */
    final String FORM_ERROR_DB_HEADLINE = "form.error.db.headline";
    /** Message used as text in the submission failure feedback if the data could not be stored. */
    final String FORM_ERROR_DB_TEXT = "form.error.db.text";
    /** Message used as headline in the submission failure feedback if the registration mail could not be sent. */
    final String FORM_ERROR_MAIL_HEADLINE = "form.error.mail.headline";
    /** Message used as text in the submission failure feedback if the registration mail could not be sent. */
    final String FORM_ERROR_MAIL_TEXT = "form.error.mail.text";
    /** Error message shown on an empty mandatory field. */
    final String FORM_ERROR_MANDATORY = "form.error.mandatory";
    /** Error message typically shown above a form when the validation failed. */
    final String FORM_ERROR_MESSAGE = "form.error.message";
    /** Error message shown on an field when the validation of the value failed. */
    final String FORM_ERROR_VALIDATION = "form.error.validation";
    /** Message shown when a file should be uploaded, e.g., "Selected file\: {0}", takes the filename as parameter. */
    final String FORM_HTML_INFO_FILEUPLOADNAME = "form.html.info.fileuploadname";
    /** The marker for mandatory fields, e.g., "*". */
    final String FORM_HTML_MANDATORY = "form.html.mandatory";
    /** The number of lines for a multiline field. 0 means default. */
    final String FORM_HTML_MULTILINE_PLACEHOLDER = "form.html.multiline.placeholder";
    /** Message shown as description if the form can not be initialized. */
    final String FORM_INIT_ERROR_DESCRIPTION = "form.init.error.description";
    /** Message shown as headline if the form can not be initialized. */
    final String FORM_INIT_ERROR_HEADLINE = "form.init.error.headline";
    /** Prefix for mail subjects. */
    final String FORM_MAILSUBJECT_PREFIX = "form.mailsubject.prefix";
    /** Hint on mandatory fields shown above the form, e.g., "All fields marked with an asterisk (*) are mandatory." */
    final String FORM_MESSAGE_MANDATORY = "form.message.mandatory";
    /** The heading of the fully-booked information when the form should be rendered. */
    final String FORM_FULLYBOOKED_HEADLINE = "form.fullybooked.headline";
    /** The text of the fully booked information when the form should be rendered. */
    final String FORM_FULLYBOOKED_TEXT = "form.fullybooked.text";
    /** Message shown above forms if the form is filled out to register for the waitlist. */
    final String FORM_MESSAGE_WAITLIST = "form.message.waitlist";
    /** Message shown in the registration mail if the registration was for the waitlist. */
    final String MAIL_WAITLIST_INFO = "mail.waitlist.info";
    /** Message shown in the confirmation mail if the registration was for the waitlist. */
    final String CONFIRM_WAITLIST_INFO = "confirm.waitlist.info";
    /** Message shown in paramter selection field select box if nothing is selected, e.g, something like "Please select" */
    final String PARAMETER_FIELD_SELECTBOX = "parameterfield.selectbox";

}
