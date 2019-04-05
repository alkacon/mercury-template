
package alkacon.mercury.test;

import org.opencms.util.CmsStringUtil;

import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestSuite;

/** Class for running all test cases. */
public class AllTests {

    /**
     * path for the test.properties file.
     */
    public static String TEST_PROPERTIES_PATH = "/home/user/workspace/mercury-template/test/";

    /** Stopwatch for the time the test run. */
    private static long m_startTime;

    /**
     * Default constructor.<p>
     */
    private AllTests() {

        // intentionally left blank
    }

    /**
     * One-time initialization code.<p>
     */
    public static void oneTimeSetUp() {

        m_startTime = System.currentTimeMillis();
        System.out.println("Starting Mercury template test run...");
    }

    /**
     * One-time cleanup code.<p>
     */
    public static void oneTimeTearDown() {

        long runTime = System.currentTimeMillis() - m_startTime;
        System.out.println(
            "... Mercury template test run finished! (Total runtime: " + CmsStringUtil.formatRuntime(runTime) + ")");
    }

    /**
     * Creates the Mercury template JUnit test suite.<p>
     *
     * @return the Mercury template test suite
     */
    public static Test suite() {

        TestSuite suite = new TestSuite("Mercury template complete tests");
        suite.addTest(alkacon.mercury.template.TestCmsJspBootstrapBean.suite());
        suite.addTest(alkacon.mercury.template.subscriptionmanagement.TestSubscriptionManager.suite());

        TestSetup wrapper = new TestSetup(suite) {

            @Override
            protected void setUp() {

                oneTimeSetUp();
            }

            @Override
            protected void tearDown() {

                oneTimeTearDown();
            }
        };

        return wrapper;
    }

}
