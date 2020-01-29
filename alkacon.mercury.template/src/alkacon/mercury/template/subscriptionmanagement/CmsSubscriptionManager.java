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

import org.opencms.file.CmsGroup;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsUser;
import org.opencms.json.JSONException;
import org.opencms.json.JSONObject;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.security.CmsOrganizationalUnit;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.regex.Pattern;

import javax.annotation.Nonnull;

import org.apache.commons.logging.Log;

/**
 * The subscription manager handles subscriptions in the way that web-users are created for each subscribing user.
 * The "thing" that the user subscribed to is represented by a group the user becomes member of.
 *
 * The manager supports double sign-in in the way that users are active/inactive for a specific group.
 *
 */
public class CmsSubscriptionManager {

    /** Subscription status a user can have. */
    public static enum SubscriptionStatus {
        /** The user is active. He has confirmed its registration, i.e., activated the subscription himself. */
        ACTIVATED,
        /** The user is active, but was manually added and has not registered or at least nor confirmed a registration. */
        MANUALLY_ADDED,
        /** The user is inactive. The user has requested the subscription but not confirmed the request yet. */
        INACTIVE,
        /** The user is inactive. There's no valid information on the state of the user's subscription. */
        INVALID;
    }

    /**
     * Wrapper for the activation state of a user for one specific group.
     * It is stored in the additional info in Json format.
     */
    private static class ActivationInfo {

        /**
         * Json key for the activation state.
         *
         * @deprecated setting activation time instead.
         */
        @Deprecated
        private static final String JSON_KEY_IS_ACTIVE = "active";
        /** Json key for the activation time. */
        private static final String JSON_KEY_ACTIVATION_TIME = "acTime";
        /** Json key for the (last) registration request time. */
        private static final String JSON_KEY_REGISTRATION_TIME = "regTime";
        /** Json key for the time when the user was added manually. */
        private static final String JSON_KEY_ADD_TIME = "addTime";
        /** Time of the last registration request in milliseconds. */
        private Long m_registrationTime;
        /** Time of the manual addition of the user in milliseconds. */
        private Long m_addTime;
        /** Time of the activation (confirmation of the registration) of the user in milliseconds. */
        private Long m_acTime;

        /**
         * Constructor for registration and manually adding a user.
         * It sets activated to false and the last registration time to the current time.
         * Moreover, if addManually is true, information that the user was manually added is set to true.
         *
         * @param addManually flag, indicating if the
         */
        public ActivationInfo(boolean addManually) {

            if (addManually) {
                m_addTime = new Long(System.currentTimeMillis());
            } else {
            m_registrationTime = new Long(System.currentTimeMillis());
        }
        }

        /**
         * Constructor for reading the state from the Json stored in the additional user infos.
         * @param activationInfoJson activation info as stored in the additional user infos.
         */
        public ActivationInfo(JSONObject activationInfoJson) {

            // Reading the deprecated active flag, just telling that there was some activation time.
            try {
                if (activationInfoJson.getBoolean(JSON_KEY_IS_ACTIVE)) {
                    m_acTime = new Long(0);
                }
            } catch (JSONException e) {
                // TODO: LOG?
                // Do nothing, maybe log?
            }
            try {
                long time = activationInfoJson.getLong(JSON_KEY_ADD_TIME);
                m_addTime = new Long(time);
            } catch (JSONException e) {
                // TODO: LOG?
                // Do nothing, maybe log?
            }
            try {
                long time = activationInfoJson.getLong(JSON_KEY_ACTIVATION_TIME);
                m_acTime = new Long(time);
            } catch (JSONException e) {
                // TODO: LOG?
                // Do nothing, maybe log?
            }
            try {
                long time = activationInfoJson.getLong(JSON_KEY_REGISTRATION_TIME);
                m_registrationTime = new Long(time);
            } catch (JSONException e) {
                // TODO: LOG?
                // Do nothing, registration time might not be set.
            }

        }

        /**
         * Set the activation state of the registration to <code>true</code>.
         */
        public void activate() {

            m_acTime = new Long(System.currentTimeMillis());

        }

        /**
         * Returns the time of the confirmation of the registration of the user in milliseconds.
         * @return the time of the confirmation of the registration of the user in milliseconds.
         */
        public Long getActivationTimeMs() {

            return m_acTime;
        }

        /**
         * Returns the time of the manually adding of the user in milliseconds.
         * @return the time of the manually adding of the user in milliseconds.
         */
        public Long getAddTimeMs() {

            return m_addTime;
        }

        /**
         * Returns the time of the last registration request in milliseconds.
         * @return the time of the last registration request in milliseconds.
         */
        public Long getRegistrationTimeMs() {

            return m_registrationTime;
        }

        /**
         * Returns a flag, indicating if the user activated his registration.
         * @return a flag, indicating if the user activated his registration.
         */
        public boolean isActive() {

            return m_acTime != null;
        }

        /**
         * Returns a flag, indicating if the user was manually added.
         * @return a flag, indicating if the user was manually added.
         */
        public boolean isManuallyAdded() {

            return m_addTime != null;
        }

        /**
         * Returns a flag, indicating if the user already requested a registration.
         * @return a flag, indicating if the user already requested a registration.
         */
        public boolean requestedRegistration() {

            return m_registrationTime != null;
        }

        /**
         * Returns the Json representation of the activation data.
         *
         * @see java.lang.Object#toString()
         */
        @Override
        public String toString() {

            String result = "";
            if (null != getActivationTimeMs()) {
                result = (result.isEmpty() ? "\"" : ", \"")
                    + JSON_KEY_ACTIVATION_TIME
                + "\" : "
                    + getActivationTimeMs();
            }
            if (null != getRegistrationTimeMs()) {
                result += (result.isEmpty() ? "\"" : ", \"")
                + JSON_KEY_REGISTRATION_TIME
                + "\" : "
                    + getRegistrationTimeMs();
            }
            if (null != getAddTimeMs()) {
                result += (result.isEmpty() ? "\"" : ", \"") + JSON_KEY_ADD_TIME + "\" : " + getAddTimeMs();
            }
            result = "{" + result + "}";
            return result;
        }

        /**
         * Sets the last registration request time or the add time to the current time.
         * @param manually iff <code>true</code> the add time is updated, otherwise the registration request time.
         */
        public void updateTime(boolean manually) {

            if (manually) {
                m_addTime = new Long(System.currentTimeMillis());
            } else {
            m_registrationTime = new Long(System.currentTimeMillis());
            }

        }
    }

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsSubscriptionManager.class);

    /** The default password for all newsletter users, can/should be overwritten in the module parameter. */
    private static final String DEFAULT_PASSWORD_USER = "QaNbyzUw82-Qn!";

    /** Name of the additional user info: flag to determine if the newsletter user is active. */
    protected static final String USER_ADDITIONALINFO = "SubscriptionManager_SubscriptionState";

    /** The admin CmsObject that is used for user/group operations. */
    private CmsObject m_adminCms;

    /** Pattern to use for email validation. If not provided, the default validation of the OpenCms core is used. */
    private Pattern m_emailPattern;

    /** The password to use for the users the manager creates. */
    private String m_userPassword;

    /** The maximal time between registration and activation. */
    private long m_maxActivationTime;

    /**
     * Default constructor, where the cms object to use for the user handling must be provided. This is typically an
     * admin cms object.
     *
     * @param adminCms the cms object to use for user management.
     */
    public CmsSubscriptionManager(CmsObject adminCms) {

        this(adminCms, 0L);
    }

    /**
     * Default constructor, where the cms object to use for the user handling must be provided. This is typically an
     * admin cms object.
     *
     * @param adminCms the cms object to use for user management.
     * @param maxActivationTime the maximal time between registration and activation (in milliseconds)
     */
    public CmsSubscriptionManager(CmsObject adminCms, long maxActivationTime) {

        m_adminCms = adminCms;
        m_maxActivationTime = maxActivationTime;
    }

    /**
     * Activates the user with the given email address in the given group.<p>
     *
     * @param email the email address of the user
     * @param groupName the name of the group to activate the user for
     * @return true if the user was activated, otherwise false
     */
    public boolean activateUser(String email, String groupName) {

        try {
            CmsUser user = m_adminCms.readUser(m_adminCms.readGroup(groupName).getOuFqn() + email);
            Map<String, ActivationInfo> activationInfos = readRegistrationInfo(user);
            final ActivationInfo activationInfo = activationInfos.get(groupName);
            if (null == activationInfo) {
                return false;
            }
            if (isUserActive(user, groupName, activationInfo)) {
                return true;
            }
            if (!isActivationInTime(activationInfo.getRegistrationTimeMs())) {
                return false;
            }

            // mark the user as active
            activationInfo.activate();
            writeRegistrationInfo(user, activationInfos);
            m_adminCms.writeUser(user);
            return true;
        } catch (JSONException | CmsException e) {
            // error reading or writing user
            LOG.error("Error accessing user with email " + email + " in order to activate for " + groupName, e);
            return false;
        }
    }

    /**
     * Creates a new user with the specified email address if it does not already exist.
     * Furthermore, adds it to the provided group to the user and writes additional infos about the registration time.<p>
     * Moreover, the additional infos contain information that the user was added manually.
     * He will directly be counted as active.
     * In case the user is already marked active for the provided group, nothing is done.
     *
     * @param email the email address of the user to register
     * @param groupName the name of the group the user should be registered for
    
     * @return <code>true</code> if the user either is already active in the group or the user was created and got the
     *  correct registration information attached. <code>false</code> otherwise.
     */
    public boolean addUserManually(String email, String groupName) {

        return addUser(email, groupName, true);
    }

    /**
     * Returns all active users for the provided group
     * @param groupName the group name
     * @return the active users for the group.
     * @throws CmsException thrown if reading the users fails.
     */
    public Set<CmsUser> getActiveUsers(String groupName) throws CmsException {

        List<CmsUser> usersOfGroup = m_adminCms.getUsersOfGroup(groupName);
        // now add those users that are activated for this subscription
        Set<CmsUser> result = new HashSet<>(usersOfGroup.size());
        for (CmsUser user : usersOfGroup) {
            if (isUserActive(user, groupName)) {
                result.add(user);
            }
        }

        return result;
    }

    /**
     * Returns the pattern used to validate email adresses.
     * @return the pattern used to validate email adresses.
     */
    public Pattern getEmailValidationPattern() {

        return m_emailPattern;
    }

    public SubscriptionStatus getSubscriptionStatus(CmsUser user, String groupName) {

        ActivationInfo activationInfo = readRegistrationInfo(user).get(groupName);
        if (null == activationInfo) {
            return SubscriptionStatus.INVALID;
        }
        if (activationInfo.isActive()) {
            return SubscriptionStatus.ACTIVATED;
        }
        if (activationInfo.isManuallyAdded()) {
            return SubscriptionStatus.MANUALLY_ADDED;
        }
        if (activationInfo.requestedRegistration()) {
            return SubscriptionStatus.INACTIVE;
        }
        return SubscriptionStatus.INVALID;
    }

    /**
     * Checks if an email address is valid.
     * @param email the address to check.
     * @return <code>true</code> if it is valid, otherwise <code>false</code>.
     */
    public boolean isValidEmail(String email) {

        if (null == m_emailPattern) {
            try {
                OpenCms.getValidationHandler().checkEmail(email);
            } catch (Exception e) {
                return false;
            }
            return true;
        } else {
            return m_emailPattern.matcher(email).matches();
        }
    }

    /**
     * Creates a new user with the specified email address if it does not already exist.
     * Furthermore, adds it to the provided group to the user and writes additional infos about the registration time.<p>
     * In case the user is already marked active for the provided group, nothing is done.
     *
     * @param email the email address of the user to register
     * @param groupName the name of the group the user should be registered for
    
     * @return <code>true</code> if the user either is already active in the group or the user was created and got the
     *  correct registration information attached. <code>false</code> otherwise.
     */
    public boolean registerUser(String email, String groupName) {

        return addUser(email, groupName, false);
    }

    /**
     * Sets the email validation pattern.
     * @param pattern the pattern to set.
     */
    public void setEmailValidationPattern(Pattern pattern) {

        m_emailPattern = pattern;
    }

    /**
     * Set the password to use for the users created by the manager.
     * @param userPassword the password to set.
     */
    public void setUserPassword(String userPassword) {

        m_userPassword = userPassword;

    }

    /**
     * Deletes a subscribed user with given email address from the specified group.<p>
     *
     * @param email the email address of the user to delete
     * @param groupName the name of the group the user should be deleted from
     *
     * @return true if deletion was successful, otherwise false
     */
    public boolean unregisterUser(String email, String groupName) {

        CmsUser user = null;
        // create additional infos containing the active flag set to passed parameter

        String ouFqn = CmsOrganizationalUnit.getParentFqn(groupName);
        try {
            // first try to read the user
            user = m_adminCms.readUser(ouFqn + email);
        } catch (CmsException e) {
            // user does not exist
        }
        // if the user is null, he does not exist, so he is definitely not registered,
        // otherwise unregister him.
        return (null == user) || unregisterExistingUser(user, groupName);
    }

    /**
     * Returns the maximal time that can be between registration and activation/confirmation (in milliseconds).
     * If the time is less or equal than zero, the time is not restricted at all.
     *
     * @return the maximal time between registration and activation in milliseconds,
     *  which is assumed to be infinity for non-possitive numbers.
     */
    protected long getMaxActivationTime() {

        return m_maxActivationTime;
    }

    /**
     * Returns the password the user should get.
     * @return the password the user should get.
     */
    protected String getUserPassword() {

        return null != m_userPassword ? m_userPassword : DEFAULT_PASSWORD_USER;
    }

    /**
     * Creates a new user with the specified email address if it does not already exist.
     * Furthermore, adds it to the provided group to the user and writes additional infos about the registration time.<p>
     * In case the user is already marked active for the provided group, nothing is done.
     *
     * @param email the email address of the user to register
     * @param groupName the name of the group the user should be registered for
     * @param manually flag, indicating iff the user is added manually (iff false, he's registering himself)
     * @return <code>true</code> if the user either is already active in the group or the user was created and got the
     *  correct registration information attached. <code>false</code> otherwise.
     */
    @SuppressWarnings("null")
    private boolean addUser(String email, String groupName, boolean manually) {

        CmsUser user = null;
        // create additional infos containing the active flag set to passed parameter

        try {
            String ouFqn = CmsOrganizationalUnit.getParentFqn(groupName);
            Map<String, ActivationInfo> activationInfos = null;
            ActivationInfo activationInfo = null;
            try {
                // first try to read the user
                user = m_adminCms.readUser(ouFqn + email);
                activationInfos = readRegistrationInfo(user);
                activationInfo = activationInfos.get(groupName);

            } catch (CmsException e) {
                // user does not exist
            }
            if ((user == null)
                || !isUserActive(user, groupName, activationInfo) // this is only true if activationInfo != null
                || (!manually && !activationInfo.isActive())) { // if the user was only manually added but now wants to register himself, we want to adjust the information

                // create the group the user should be added to
                createGroupIfNecessary(groupName);

                // create/adjust the user information
                if (user == null) {
                    // create the user with additional infos
                    user = m_adminCms.createUser(
                        ouFqn + email,
                        getUserPassword(),
                        "",
                        Collections.<String, Object> emptyMap());
                    // set the users email address
                    user.setEmail(email);
                    activationInfos = new HashMap<>(1);
                    activationInfo = new ActivationInfo(manually);
                    activationInfos.put(groupName, activationInfo);

                } else {
                    if ((null == activationInfo)) {
                        activationInfo = new ActivationInfo(manually);
                        activationInfos.put(groupName, activationInfo);
                    } else {
                        activationInfo.updateTime(manually);
                    }
                }

                writeRegistrationInfo(user, activationInfos);
                m_adminCms.writeUser(user);
                // add the user to the given mailing list group
                m_adminCms.addUserToGroup(user.getName(), groupName);
            }
        } catch (JSONException | CmsException e) {
            LOG.error("Error while registering user " + email + " for group " + groupName + ".", e);
            return false;
        }
        return true;
    }

    /**
     * Creates the group if necessary.
     *
     * @param groupName name of the group.
     *
     * @throws CmsException thrown if creation fails.
     */
    private void createGroupIfNecessary(String groupName) throws CmsException {

        try {
            m_adminCms.readGroup(groupName);
        } catch (CmsException e) {
            m_adminCms.createGroup(groupName, groupName, 0, null);
        }

    }

    /**
     * Checks if an activation now is in time.
     * @param registrationTime the time the user registered.
     * @return <code>true</code> if the time elapsed since the registration
     *  is less than or equal to the maximal activation time.
     */
    private boolean isActivationInTime(Long registrationTime) {

        return (null != registrationTime)
            && ((getMaxActivationTime() <= 0)
                || ((System.currentTimeMillis() - registrationTime.longValue()) <= getMaxActivationTime()));
    }

    /**
     * Checks if the provided user is already active for the provided group.
     * @param user the user to check.
     * @param groupName the name of the group to check.
     * @return <code>true</code> if the user has an active subscription for the group.
     */
    private boolean isUserActive(CmsUser user, String groupName) {

        ActivationInfo activationInfo = readRegistrationInfo(user).get(groupName);
        return isUserActive(user, groupName, activationInfo);
    }

    /**
     * Checks if the provided user is already active for the provided group.
     * @param user the user to check.
     * @param groupName the name of the group to check.
     * @param activationInfo the activation information for this group that is stored in the additional user info of the user.
     * @return <code>true</code> if the user has an active subscription for the group.
     */
    private boolean isUserActive(CmsUser user, String groupName, ActivationInfo activationInfo) {

        try {
            return (null != activationInfo)
                && (activationInfo.isActive() || activationInfo.isManuallyAdded())
                && m_adminCms.userInGroup(user.getName(), groupName);
        } catch (CmsException e) {
            // The group the user should be in might not exist and therefor an exception might be thrown.
            LOG.error(
                "Exception when determining if user "
                    + user.getName()
                    + " is active for group "
                    + groupName
                    + ". This should not happen, since it means that the user is active for a group that does not exist. To go on and possibly repair the inconsistent situation, false is returned by the check if the user is active.",
                e);
            return false;
        }
    }

    /**
     * Reads the registration information for the provided user from the additional user info.
     * @param user the user to read the registration information for.
     * @return the user's registration information.
     */
    @Nonnull
    private Map<String, ActivationInfo> readRegistrationInfo(CmsUser user) {

        Map<String, ActivationInfo> result = new HashMap<>();
        String additionalInfo = (String)user.getAdditionalInfo(USER_ADDITIONALINFO);
        if ((null != additionalInfo) && !additionalInfo.isEmpty()) {
            try {
                JSONObject activationInfos = new JSONObject(additionalInfo);

                for (String group : activationInfos.keySet()) {
                    JSONObject activationInfoJson = activationInfos.getJSONObject(group);
                    ActivationInfo activationInfo = new ActivationInfo(activationInfoJson);
                    result.put(group, activationInfo);
                }
                return result;
            } catch (JSONException e) {
                //TODO: Log
            }
        }
        return result;
    }

    /**
     * Unregisters a user. This means the user is removed from the group, specific additional information is removed,
     * and, if the user is not member of any other group, the user is deleted.
     *
     * @param user the user to unregister
     * @param groupName the group from which the user should be unregistered.
     * @return <code>true</code> if the user is not registered for the group after executing this method,
     *  <code>false</code> otherwise.
     */
    private boolean unregisterExistingUser(CmsUser user, String groupName) {

        // if group or user are not present, the user can't be registered for the group, hence he is unregistered.
        if ((user == null) || (groupName == null)) {
            return true;
        }

        boolean success = false;
        try {

            List<CmsGroup> groupsOfUser = m_adminCms.getGroupsOfUser(user.getName(), true);
            boolean isUserInGroup = m_adminCms.userInGroup(user.getName(), groupName);

            // if the user is not member of any groups or only in the group he should be removed,
            // delete the user and return.
            if ((groupsOfUser.size() < 1) || ((groupsOfUser.size() == 1) && isUserInGroup)) {
                m_adminCms.deleteUser(user.getId());
                success = true;
            } else {

                // The user is at least in a group where he should not be unregistered for,
                // so remove the registration information and the group membership for the group
                // we want to unregister him.
                Map<String, ActivationInfo> activationInfos = readRegistrationInfo(user);
                if (activationInfos.containsKey(groupName)) {
                    activationInfos.remove(groupName);
                    writeRegistrationInfo(user, activationInfos);
                    m_adminCms.writeUser(user);
                }
                success = true;
                if (isUserInGroup) {
                    m_adminCms.removeUserFromGroup(user.getName(), groupName);
                }
            }
            if (m_adminCms.getUsersOfGroup(groupName).isEmpty()) {
                m_adminCms.deleteGroup(groupName);
            }
        } catch (JSONException | CmsException e) {
            LOG.error("Error when unregistering user " + user.getName() + " from group " + groupName, e);
        }
        return success;
    }

    /**
     * Writes the registration information to the additional user data of the user.
     * @param user the user to write the information to.
     * @param info the information to write.
     * @throws JSONException thrown if writing the information fails, should never happen.
     */
    private void writeRegistrationInfo(CmsUser user, Map<String, ActivationInfo> info) throws JSONException {

        JSONObject json = new JSONObject();
        for (Entry<String, ActivationInfo> entry : info.entrySet()) {
            json.put(entry.getKey(), new JSONObject(entry.getValue().toString()));
        }
        user.setAdditionalInfo(USER_ADDITIONALINFO, json.toString());
    }
}
