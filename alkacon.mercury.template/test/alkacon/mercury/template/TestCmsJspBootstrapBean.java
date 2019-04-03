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

package alkacon.mercury.template;

import org.opencms.test.OpenCmsTestProperties;

import alkacon.mercury.test.AllTests;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit tests for the <code>{@link CmsJspBootstrapBean}</code>.<p>
 *
 */
public class TestCmsJspBootstrapBean extends TestCase {

    /**
     * Default JUnit constructor.<p>
     *
     * @param arg0 JUnit parameters
     */
    public TestCmsJspBootstrapBean(String arg0) {

        super(arg0);
    }

    /**
     * Test suite for this test class.<p>
     *
     * @return the test suite
     */
    public static Test suite() {

        TestSuite suite = new TestSuite();
        suite.setName(TestCmsJspBootstrapBean.class.getName());
        OpenCmsTestProperties.initialize(AllTests.TEST_PROPERTIES_PATH);

        suite.addTest(new TestCmsJspBootstrapBean("testMercuryClasses"));
        suite.addTest(new TestCmsJspBootstrapBean("testBootstrapBean"));
        suite.addTest(new TestCmsJspBootstrapBean("testHiddenColumns"));

        return suite;
    }

    /**
     * Tests if the correct grid sizes are calculated for default bootstrap CSS classes.
     */
    @org.junit.Test
    public void testBootstrapBean() {

        CmsJspBootstrapBean bb = new CmsJspBootstrapBean();

        // manual bean construction
        bb.addLayer("col-sm-6 col-md-4 col-lg-3");
        bb.addLayer("col-sm-6 hidden-md");
        bb.addLayer("col-xs-6");
        System.out.println(bb.toString());
        assertEquals("xs=158px(50.00%) sm=38px(12.50%) md=0px(0.00%) lg=31px(6.25%) xl=44px(6.25%)", bb.toString());

        // parse a String encountered in the wild
        bb = new CmsJspBootstrapBean();
        bb.setCss(":area-body:ap-row-wrapper:col-md-8:col-md-4");
        System.out.println(bb.toString());
        System.out.println("Size SM " + bb.getSizeSm() + "px");
        System.out.println("Size MD " + bb.getSizeMd() + "px");
        System.out.println("Size LG " + bb.getSizeLg() + "px");
        System.out.println("Size XL " + bb.getSizeXl() + "px");
        assertEquals(510, bb.getSizeSm());
        assertEquals(137, bb.getSizeMd());
        assertEquals(186, bb.getSizeLg());
        assertEquals(230, bb.getSizeXl());

        // parse another String
        bb = new CmsJspBootstrapBean();
        bb.setCss("col-md-4");
        System.out.println(bb.toString());
        System.out.println("Size SM " + bb.getSizeSm() + "px");
        System.out.println("Size MD " + bb.getSizeMd() + "px");
        System.out.println("Size LG " + bb.getSizeLg() + "px");
        System.out.println("Size XL " + bb.getSizeXl() + "px");
        assertEquals(510, bb.getSizeSm());
        assertEquals(220, bb.getSizeMd());
        assertEquals(294, bb.getSizeLg());
        assertEquals(360, bb.getSizeXl());
    }

    /**
     * Tests if the correct grid sizes are calculated for hidden columns.
     */
    @org.junit.Test
    public void testHiddenColumns() {

        CmsJspBootstrapBean bb = new CmsJspBootstrapBean();

        bb.addLayer("col-xs-12");
        bb.addLayer("hidden-md");
        System.out.println(bb.toString());
        assertEquals("xs=345px(100.00%) sm=510px(100.00%) md=0px(0.00%) lg=940px(100.00%) xl=1140px(100.00%)", bb.toString());
    }

    /**
     * Tests if the correct grid sizes are calculated for special Mercury CSS classes.
     */
    @org.junit.Test
    public void testMercuryClasses() {

        CmsJspBootstrapBean bb = new CmsJspBootstrapBean();
        bb.addLayer("col-xs-12");
        bb.addLayer("tile-sm-6 tile-md-3 tile-lg-3");
        System.out.println(bb.toString());
        assertEquals("xs=345px(100.00%) sm=240px(50.00%) md=158px(25.00%) lg=213px(25.00%) xl=263px(25.00%)", bb.toString());

        bb = new CmsJspBootstrapBean();
        bb.addLayer("col-md-8 hidden-md");
        bb.addLayer("tile-sm-6 tile-md-3 tile-lg-3");
        System.out.println(bb.toString());
        assertEquals("xs=345px(100.00%) sm=240px(50.00%) md=0px(0.00%) lg=132px(16.67%) xl=165px(16.67%)", bb.toString());

        bb = new CmsJspBootstrapBean();
        bb.addLayer("col-lg-6");
        bb.addLayer("square-md-6 square-lg-6");
        System.out.println(bb.toString());
        assertEquals("xs=345px(100.00%) sm=510px(100.00%) md=345px(50.00%) lg=213px(25.00%) xl=263px(25.00%)", bb.toString());
    }

}
