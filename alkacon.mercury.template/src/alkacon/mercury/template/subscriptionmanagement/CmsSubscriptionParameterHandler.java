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

package alkacon.mercury.template.subscriptionmanagement;

import alkacon.mercury.template.CmsStringCrypter;
import org.opencms.i18n.CmsMessageContainer;
import org.opencms.main.CmsLog;
import org.opencms.util.CmsRequestUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.commons.logging.Log;

/**
 * Helper to perform subscriptions/unsubscriptions for webusers.
 *
 * The helper provides a standard way to trigger subscription/unsubscription and respective confirmation actions
 * via requests with specific parameters. It takes care of handling this parameters, checking and performing the
 * requested action and also determining inconsistent parameter configurations.
 * Moreover, it handles the encryption/decryptions of parameters. Especially confirmation link parameters for emails
 * are generated.
 *
 * The parameter handler is designed to implement a double opt-in and double opt-out for subscriptions that is legal
 * according to the General Data Protection Regulation of the European Union.
 *
 */
public class CmsSubscriptionParameterHandler {

    /** Request parameters that are examined by the bean. */
    public enum Parameter {
        /** The action to perform */
        ACTION,
        /** The email address of the subscriber to perform the action for. */
        EMAIL,
        /** The subscription groups to take an action for. */
        GROUPS,
        /** The agreement for the terms & conditions */
        AGREEMENT;

        /**
         * Extracts the subscription-relevant information from the provided request parameters.
         * @param requestParams (all) parameters of the current request
         * @return the information from the parameters relevant for the subscription action.
         */
        public static Map<Parameter, List<String>> generateValueMap(Map<String, String[]> requestParams) {

            Map<Parameter, List<String>> result = new HashMap<>(Parameter.values().length);
            for (Parameter param : Parameter.values()) {
                result.put(param, getParamValues(param, requestParams));
            }
            return result;
        }

        /**
         * Returns the values for the provided parameter stored in the given parameter map.
         * @param param the parameter to get the values for
         * @param requestParams the parameter map to search in for the parameters values.
         * @return the parameter's values as extracted from the provided parameter map.
         */
        private static List<String> getParamValues(Parameter param, Map<String, String[]> requestParams) {

            List<String> result = null;
            String paramName = param.toString();
            if ((requestParams != null) && requestParams.containsKey(paramName)) {
                String[] values = requestParams.get(paramName);
                if (null != values) {
                    result = new ArrayList<>(values.length);
                    for (String value : values) {
                        result.add(value.trim());
                    }
                } else {
                    result = Collections.emptyList();
                }
            }
            return result;
        }

        /**
         * Returns the String representation of the relevant parameters.
         * @see java.lang.Enum#toString()
         */
        @Override
        public String toString() {

            switch (this) {
                case ACTION:
                    return "a";
                case EMAIL:
                    return "b";
                case GROUPS:
                    return "c";
                case AGREEMENT:
                    return "d";
                default:
                    throw new IllegalArgumentException("The parameter has no String value defined.");
            }
        }
    }

    /** The subscription actions. */
    public enum SubscriptionAction {
        /** No action at all. */
        NONE,
        /** Subscribe for a group. */
        SUBSCRIBE,
        /** Unsubscribe for a group. */
        UNSUBSCRIBE,
        /** Confirm the subscription of a group. */
        CONFIRM_SUBSCRIPTION,
        /** Confirm the unsubscription of a group. */
        CONFIRM_UNSUBSCRIPTION;
    }

    /** Password to use for encryption/decryption of parameter values. */
    private static final String DEFAULT_ENCRYPTION_PASSPHRASE = "Ja-TPx!?npWd";

    /** The request parameter used to send the confirmation data for email links. */
    private static final String PARAM_CONFIRM = "confirmId";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsSubscriptionParameterHandler.class);

    /** The subscription manager to use. */
    private CmsSubscriptionManager m_subscriptionManager;

    /** The subscription configuration to use. */
    private I_CmsSubscriptionConfiguration m_subscriptionConfig;

    /** The current subscription action. */
    private SubscriptionAction m_action = SubscriptionAction.NONE;

    /** The email address as determined from the request parameters. */
    private String m_email;

    /** The group names as determined from the request parameters. */
    private List<String> m_requestedGroups;

    /** Flag, indicating if the user has agreed terms & conditions according to the request parameters. */
    private boolean m_hasAgreed;

    /** Flag, indicating if the requested groups are valid, i.e., can be handled by the configuration. */
    private boolean m_isValidGroups;

    /** Flag, indicating if the email address is valid. */
    private boolean m_isValidEmail;

    /** Flag, indicating if for the current action the user committed himself to the necessary terms & conditions. */
    private boolean m_isValidAgreement;

    /**
     * Default constructor for the parameter handler.
     *
     * @param manager the subscription manager to use.
     * @param subscriptionConfig the subscription configuraiton to use.
     * @param requestParameters the current request parameters.
     */
    public CmsSubscriptionParameterHandler(
        CmsSubscriptionManager manager,
        I_CmsSubscriptionConfiguration subscriptionConfig,
        Map<String, String[]> requestParameters) {

        m_subscriptionManager = manager;
        m_subscriptionConfig = subscriptionConfig;
        Map<String, String[]> requestParams;
        String encodedParams = getEncodedParams(requestParameters);
        if (null != encodedParams) {
            requestParams = decodeParamMap(encodedParams);
        } else {
            requestParams = requestParameters;
        }

        Map<Parameter, List<String>> paramMap = Parameter.generateValueMap(requestParams);
        List<String> actionValues = paramMap.get(Parameter.ACTION);
        if ((null != actionValues) && (actionValues.size() == 1)) {
            try {
                SubscriptionAction[] actions = SubscriptionAction.values();
                int actionId = Integer.parseInt(actionValues.get(0));
                if ((actionId >= 0) && (actionId < actions.length)) {
                    m_action = actions[actionId];
                }
            } catch (NumberFormatException e) {

                LOG.warn(
                    "The parameter value \"" + actionValues + "\"prespresenting the subscription action is not valid.");
            }
        }
        List<String> emailValues = paramMap.get(Parameter.EMAIL);
        if ((null != emailValues) && (emailValues.size() == 1)) {
            m_email = emailValues.get(0);
        }
        List<String> groupValues = paramMap.get(Parameter.GROUPS);
        if ((null != groupValues)) {
            if (m_action.equals(SubscriptionAction.SUBSCRIBE) || m_action.equals(SubscriptionAction.UNSUBSCRIBE)) {
                m_requestedGroups = groupValues.stream().map(
                    g -> decrypt(g, m_subscriptionConfig.getParameterEncryptionPassphrase())).collect(
                        Collectors.toList());
            } else {
                m_requestedGroups = groupValues;
            }

        } else {
            m_requestedGroups = Collections.emptyList();
        }
        m_hasAgreed = null != paramMap.get(Parameter.AGREEMENT);
        validate();
    }

    /**
     * Decrypts the provided value.
     *
     * @param value the value to decrypt.
     * @param passphrase the passphrase to use for decryption.
     * @return the decypted value.
     */
    public static String decrypt(String value, String passphrase) {

        return CmsStringCrypter.decrypt(value, null == passphrase ? DEFAULT_ENCRYPTION_PASSPHRASE : passphrase);
    }

    /**
     * Encrypts the provided value.
     *
     * @param value the value to encrypt.
     * @param passphrase the passphrase to use for encryption, if <code>null</code> a default passphrase is used.
     * @return the encypted value.
     */
    public static String encrypt(String value, String passphrase) {

        return CmsStringCrypter.encrypt(value, passphrase == null ? DEFAULT_ENCRYPTION_PASSPHRASE : passphrase);

    }

    /**
     * Returns the confirmation link parameters to add to a confirmation link for the requested action.
     *
     * @param action the action to confirm
     * @param email the email (user name) of the user to confirm the action for.
     * @param groups the groups the action is confirmed for.
     * @param encryptionPassphrase the passphrase to use for parameter encryption
     *
     * @return the confirmation link parameter for the provided action, user and group combination.
     */
    public static String getConfirmationLinkParameters(
        SubscriptionAction action,
        String email,
        List<String> groups,
        String encryptionPassphrase) {

        if (action.equals(SubscriptionAction.SUBSCRIBE) || action.equals(SubscriptionAction.UNSUBSCRIBE)) {
            StringBuffer params = new StringBuffer();
            SubscriptionAction confirmAction = action.equals(SubscriptionAction.SUBSCRIBE)
            ? SubscriptionAction.CONFIRM_SUBSCRIPTION
            : SubscriptionAction.CONFIRM_UNSUBSCRIPTION;
            params.append(Parameter.ACTION.toString()).append("=").append(confirmAction.ordinal());
            params.append('&');
            params.append(Parameter.EMAIL.toString()).append("=").append(email);
            for (String group : groups) {
                params.append('&');
                params.append(Parameter.GROUPS).append('=').append(group);
            }
            params.append('&');
            // Salt for the link
            params.append(System.currentTimeMillis());
            return PARAM_CONFIRM + "=" + encrypt(params.toString(), encryptionPassphrase);
        } else

        {
            return null;
        }
    }

    /**
     * Returns the action parameter value to use for requesting a subscription.
     * @return the action parameter value to use for requesting a subscription.
     */
    public String getActionValueSubscribe() {

        return Integer.toString(SubscriptionAction.SUBSCRIBE.ordinal());
    }

    /**
     * Returns the action parameter value to use for requesting an unsubscription.
     * @return the action parameter value to use for requesting an unsubscription.
     */
    public String getActionValueUnsubscribe() {

        return Integer.toString(SubscriptionAction.UNSUBSCRIBE.ordinal());

    }

    /**
     * Returns the current subscription action to perform that is determined by the request parameters.
     * @return the current subscription action to perform that is determined by the request parameters.
     */
    public SubscriptionAction getCurrentAction() {

        return m_action;
    }

    /**
     * Returns the email as extracted from the request parameters.
     * @return the email as extracted from the request parameters.
     */
    public String getEmail() {

        return m_email;
    }

    /**
     * Returns the name of the request parameter that should hold the value of the subscription action to perform.
     * @return the name of the request parameter that should hold the value of the subscription action to perform.
     */
    public String getParamAction() {

        return Parameter.ACTION.toString();
    }

    /**
     * Returns the name of the request parameter whose presence, indicates that the user accepted the terms & conditions.
     * @return the name of the request parameter whose presence, indicates that the user accepted the terms & conditions.
     */
    public String getParamAgreement() {

        return Parameter.AGREEMENT.toString();
    }

    /**
     * Returns the name of the request parameter that should hold the value of the email address the action should be performed for.
     * @return the name of the request parameter that should hold the value of the email address the action should be performed for.
     */
    public String getParamEmail() {

        return Parameter.EMAIL.toString();
    }

    /**
     * Returns the name of the request parameter whose presence, indicates that the user accepted the terms & conditions.
     * @return the name of the request parameter whose presence, indicates that the user accepted the terms & conditions.
     */
    public String getParamGroups() {

        return Parameter.GROUPS.toString();
    }

    /**
     * Returns the names of the groups for which the action should be performed.
     * @return the names of the groups for which the action should be performed.
     */
    public List<String> getRequestedGroups() {

        return m_requestedGroups;
    }

    /**
     * Returns a flag, indicating if the current action is to confirm a subscription.
     * @return a flag, indicating if the current action is to confirm a subscription.
     */
    public boolean isActionConfirmSubscription() {

        return m_action.equals(SubscriptionAction.CONFIRM_SUBSCRIPTION);
    }

    /**
     * Returns a flag, indicating if the current action is to confirm an unsubscription.
     * @return a flag, indicating if the current action is to confirm an unsubscription.
     */
    public boolean isActionConfirmUnsubscription() {

        return m_action.equals(SubscriptionAction.CONFIRM_UNSUBSCRIPTION);
    }

    /**
    * Returns a flag, indicating if the current action is none (and typically the form for entering the email address is rendered).
    * @return a flag, indicating if the current action is none.
    */
    public boolean isActionNone() {

        return m_action.equals(SubscriptionAction.NONE);
    }

    /**
     * Returns a flag, indicating if the current action is to request a subscription.
     * @return a flag, indicating if the current action is to request a subscription.
     */
    public boolean isActionSubscribe() {

        return m_action.equals(SubscriptionAction.SUBSCRIBE);
    }

    /**
     * Returns a flag, indicating if the current action is to request an unsubscription.
     * @return a flag, indicating if the current action is to confirm an unsubscription.
     */
    public boolean isActionUnsubscribe() {

        return m_action.equals(SubscriptionAction.UNSUBSCRIBE);
    }

    /**
     * Checks if the groups read from the request parameters are really groups managed by the subscription configuration.
     *
     * @return <code>true</code> if the parameter configuration is valid for the configuration, <code>false</code> otherwise.
     */
    public boolean isValid() {

        return m_isValidGroups && m_isValidEmail && m_isValidAgreement;
    }

    /**
     * Returns a flag, indicating if the agreement has been checked, when necessary.
     * @return a flag, indicating if the agreement has been checked, when necessary.
     */
    public boolean isValidAgreement() {

        return m_isValidAgreement;
    }

    /**
     * Returns a flag, indicating if the email address is a valid email address, assumed it is needed for the subscription action.
     * @return a flag, indicating if the email address is a valid email address, assumed it is needed for the subscription action.
     */
    public boolean isValidEmail() {

        return m_isValidEmail;
    }

    /**
     * Returns a flag, indicating if the groups the user wants to perform the action for are really managable groups.
     * @return a flag, indicating if the groups the user wants to perform the action for are really managable groups.
     */
    public boolean isValidGroups() {

        return m_isValidGroups;
    }

    /**
     * Performs the action determined by the provided request parameters.
     *
     * @return a list of errors that occurred when performing the action, the empty list in case of success.
     */
    public List<CmsMessageContainer> performAction() {

        if (isValid()) {
            return m_subscriptionConfig.getAction(m_action).perform(this);
        } else {
            return Collections.singletonList(
                new CmsMessageContainer(Messages.get(), Messages.GUI_INVALID_PARAMETERS_0));
        }
    }

    /**
     * Returns the parameters for unsubscribing the provided user from the given group configuration.
     *
     * @return the request parameters to add to the management link to perform the action, or <code>null</code> if
     *      for the provided action no mail has to be send.
     */
    protected String getConfirmationLinkParameters() {

        return getConfirmationLinkParameters(
            m_action,
            getEmail(),
            getRequestedGroups(),
            m_subscriptionConfig.getParameterEncryptionPassphrase());
    }

    /**
     * Returns the name of the request parameter to use for the confirmation parameter.
     * @return the name of the request parameter to use for the confirmation parameter.
     */
    protected String getConfirmParameter() {

        return PARAM_CONFIRM;
    }

    /**
     * Validates if the provided request parameters are suitable for the given subscription configuration.
     */
    protected void validate() {

        if (m_action.equals(SubscriptionAction.NONE)) {
            m_isValidGroups = true;
            m_isValidEmail = true;
            m_isValidAgreement = true;
        } else {
            m_isValidEmail = m_subscriptionManager.isValidEmail(getEmail());
            m_isValidGroups = (m_requestedGroups.size() > 0)
                && ((m_subscriptionConfig.getManagedGroups() == null)
                    || m_subscriptionConfig.getManagedGroups().containsAll(m_requestedGroups));
            m_isValidAgreement = !m_action.equals(SubscriptionAction.SUBSCRIBE) || m_hasAgreed;
        }
    }

    /**
     * Takes the encrypted parameter string as used for emails and converts it in the decrypted parameter map.
     *
     * @param encodedParameters the encrypted parameters
     *
     * @return the decoded parameters as map
     */
    private Map<String, String[]> decodeParamMap(String encodedParameters) {

        String decodedParams = decrypt(encodedParameters, m_subscriptionConfig.getParameterEncryptionPassphrase());
        return CmsRequestUtil.createParameterMap(decodedParams);
    }

    /**
     * Returns the encoded confirmation parameters from the request parameters if present, otherwise <code>null</code>.
     *
     * @param requestParams the current request parameters.
     *
     * @return the encoded confirmation parameters from the request parameters if present, otherwise <code>null</code>.
     */
    private String getEncodedParams(Map<String, String[]> requestParams) {

        String[] confirmValue = requestParams.get(getConfirmParameter());
        if ((null != confirmValue) && (confirmValue.length == 1)) {
            String confirmValueString = confirmValue[0];
            if ((null != confirmValueString) && !confirmValueString.isEmpty()) {
                return confirmValueString;
            }
        }
        return null;
    }
}
