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

import alkacon.mercury.test.AllTests;

import org.opencms.file.CmsGroup;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsUser;
import org.opencms.main.CmsException;
import org.opencms.main.OpenCms;
import org.opencms.security.CmsOrganizationalUnit;
import org.opencms.test.OpenCmsTestCase;
import org.opencms.test.OpenCmsTestProperties;

import java.util.Collection;
import java.util.List;

import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestSuite;

/** Tests for the subscription manager. */
public class TestSubscriptionManager extends OpenCmsTestCase {

    /**
     * Default JUnit constructor.<p>
     *
     * @param arg0 JUnit parameters
     */
    public TestSubscriptionManager(String arg0) {

        super(arg0);
    }

    /**
     * Test suite for this test class.<p>
     *
     * @return the test suite
     */
    public static Test suite() {

        TestSuite suite = new TestSuite();
        suite.setName(TestSubscriptionManager.class.getName());
        OpenCmsTestProperties.initialize(AllTests.TEST_PROPERTIES_PATH);

        suite.addTest(new TestSubscriptionManager("testUserActions"));
        suite.addTest(new TestSubscriptionManager("testRegistrationTimeout"));

        TestSetup wrapper = new TestSetup(suite) {

            @Override
            protected void setUp() {

                // just initialize the test data path
                // initTestDataPath();
                setupOpenCms("simpletest", "/");

            }

            @Override
            protected void tearDown() {

                removeOpenCms();
            }
        };

        return wrapper;
    }

    /**
     * Tests if activation is possible only iff the timeout is not reached yet.
     * @throws CmsException
     * @throws InterruptedException
     */
    @SuppressWarnings("null")
    public void testRegistrationTimeout() throws CmsException, InterruptedException {

        echo("Testing registration timeout");
        echo("============================");
        echo("");
        echo("Preparing OU and getting subscription manager ...");

        CmsObject cms = getCmsObject();

        String email = "test@test.de";
        String ou = "nl_test_registration";
        CmsOrganizationalUnit testOU = OpenCms.getOrgUnitManager().createOrganizationalUnit(
            cms,
            ou,
            "Test OU for webusers",
            CmsOrganizationalUnit.FLAG_WEBUSERS | CmsOrganizationalUnit.FLAG_HIDE_LOGIN,
            null);
        OpenCms.getOrgUnitManager().writeOrganizationalUnit(getCmsObject(), testOU);
        String group = ou + "/webuser_group";
        String userLoginName = ou + "/" + email;

        CmsSubscriptionManager manager = new CmsSubscriptionManager(cms, 100);

        boolean actionResult = manager.registerUser(email, group);
        assertTrue(actionResult);
        // wait till registration timeout is reached
        Thread.sleep(100L);
        actionResult = manager.activateUser(email, group);
        assertFalse(actionResult);
        CmsGroup createdGroup = cms.readGroup(group);
        assertTrue(createdGroup != null);
        List<CmsUser> createdUsers = cms.getUsersOfGroup(group);
        assertTrue((createdUsers != null) && (createdUsers.size() == 1));
        assertEquals(createdUsers.get(0).getName(), userLoginName);
        Collection<CmsUser> activeUsers = manager.getActiveUsers(group);
        assertTrue(activeUsers.isEmpty());

        // re-register
        actionResult = manager.registerUser(email, group);
        assertTrue(actionResult);
        // activate the user before the timeout is reached
        actionResult = manager.activateUser(email, group);
        assertTrue(actionResult);
        createdGroup = cms.readGroup(group);
        assertTrue(createdGroup != null);
        createdUsers = cms.getUsersOfGroup(group);
        assertTrue((createdUsers != null) && (createdUsers.size() == 1));
        assertEquals(createdUsers.get(0).getName(), userLoginName);
        activeUsers = manager.getActiveUsers(group);
        assertTrue(activeUsers.size() == 1);
        assertEquals(activeUsers.iterator().next().getName(), userLoginName);

    }

    /**
     * Tests registering, activating and unregistering users.<p>
     *
     * @throws Throwable if something goes wrong
     */
    @SuppressWarnings("null")
    public void testUserActions() throws Throwable {

        echo("Testing subscription manager");
        echo("============================");
        echo("");
        echo("Preparing OU and getting subscription manager ...");

        CmsObject cms = getCmsObject();

        String email = "test@test.de";
        String ou = "nl_test";
        CmsOrganizationalUnit testOU = OpenCms.getOrgUnitManager().createOrganizationalUnit(
            cms,
            ou,
            "Test OU for webusers",
            CmsOrganizationalUnit.FLAG_WEBUSERS | CmsOrganizationalUnit.FLAG_HIDE_LOGIN,
            null);
        OpenCms.getOrgUnitManager().writeOrganizationalUnit(getCmsObject(), testOU);
        String group = ou + "/webuser_group";
        String userLoginName = ou + "/" + email;

        CmsSubscriptionManager manager = new CmsSubscriptionManager(cms);

        boolean actionResult;
        echo("Testing user registration");
        actionResult = manager.registerUser(email, group);
        assertTrue(actionResult);
        CmsGroup createdGroup = cms.readGroup(group);
        assertTrue(createdGroup != null);
        List<CmsUser> createdUsers = cms.getUsersOfGroup(group);
        assertTrue((createdUsers != null) && (createdUsers.size() == 1));
        assertEquals(createdUsers.get(0).getName(), userLoginName);
        Collection<CmsUser> activeUsers = manager.getActiveUsers(group);
        assertTrue(activeUsers.isEmpty());

        echo("Testing user activation");
        assertTrue(manager.getActiveUsers(group).isEmpty());
        actionResult = manager.activateUser(email, group);
        assertTrue(actionResult);
        activeUsers = manager.getActiveUsers(group);
        assertTrue(activeUsers.size() == 1);
        assertEquals(activeUsers.iterator().next().getName(), userLoginName);

        echo("Testing registration of user to second group");
        String group2 = ou + "/webusers_group2";
        actionResult = manager.registerUser(email, group2);
        assertTrue(actionResult);
        CmsGroup createdGroup2 = cms.readGroup(group2);
        assertTrue(createdGroup2 != null);
        List<CmsUser> createdUsers2 = cms.getUsersOfGroup(group2);
        assertTrue((createdUsers2 != null) && (createdUsers2.size() == 1));
        assertEquals(createdUsers2.get(0).getName(), userLoginName);

        echo("Testing registration of user2 to second group");
        String email2 = "test2@test.de";
        String userLoginName2 = ou + "/" + email2;
        actionResult = manager.registerUser(email2, group2);
        assertTrue(actionResult);
        createdGroup2 = cms.readGroup(group2);
        assertTrue(createdGroup2 != null);
        createdUsers2 = cms.getUsersOfGroup(group2);
        assertTrue((createdUsers2 != null) && (createdUsers2.size() == 2));

        echo("Testing unregistration of inactive user2 from second group");
        createdGroup2 = cms.readGroup(group2);
        boolean groupPresent = createdGroup2 != null;
        assertTrue(groupPresent);

        actionResult = manager.unregisterUser(email2, group2);
        assertTrue(actionResult);

        // check if the group is still present
        try {
            createdGroup2 = cms.readGroup(group2);
            groupPresent = createdGroup2 != null;
        } catch (CmsException e) {
            groupPresent = false;
        }
        // group should still be there since there's another user registered for the group.
        assertTrue(groupPresent);

        // check if the user is still present
        CmsUser user = null;
        try {
            user = cms.readUser(userLoginName2);
        } catch (CmsException e) {
            user = null;
        }
        // the user should not be present anymore, since he is registered in no other group.
        assertTrue(user == null);

        echo("Testing unregistration of inactive user from second group");
        createdGroup2 = cms.readGroup(group2);
        groupPresent = createdGroup2 != null;
        assertTrue(groupPresent);
        actionResult = manager.unregisterUser(email, group2);
        assertTrue(actionResult);
        try {
            createdGroup2 = cms.readGroup(group2);
            groupPresent = createdGroup2 != null;
        } catch (CmsException e) {
            groupPresent = false;
        }
        assertFalse(groupPresent);
        try {
            user = cms.readUser(userLoginName);
        } catch (CmsException e) {
            user = null;
        }
        assertTrue(user != null);

        echo("Testing registration of already active user for the first group");
        actionResult = manager.registerUser(email, group);
        assertTrue(actionResult);
        activeUsers = manager.getActiveUsers(group);
        assertTrue(activeUsers.size() == 1);
        assertEquals(activeUsers.iterator().next().getName(), userLoginName);

        echo("Testing unregistration of active user from first (and last) group");
        createdGroup = cms.readGroup(group);
        groupPresent = createdGroup != null;
        assertTrue(groupPresent);
        actionResult = manager.unregisterUser(email, group);
        assertTrue(actionResult);
        try {
            createdGroup = cms.readGroup(group);
            groupPresent = createdGroup != null;
        } catch (CmsException e) {
            groupPresent = false;
        }
        assertFalse(groupPresent);
        try {
            user = cms.readUser(userLoginName);
        } catch (CmsException e) {
            user = null;
        }
        assertTrue(user == null);
    }
}
