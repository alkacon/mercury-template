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

import alkacon.mercury.webform.CmsFormUgcConfiguration;
import alkacon.mercury.webform.CmsWebformModuleAction;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.main.CmsException;
import org.opencms.main.OpenCms;
import org.opencms.ugc.CmsUgcConfiguration;

import java.util.List;

/** Class that encapsulates the submission status of a form. */
public class CmsSubmissionStatus {

    /** The maximally allowed regular submissions. <code>null</code> for unlimited submissions. */
    private Integer m_maxRegularSubmissions;
    /** The maximal number of submissions on the waitlist. Defaults to 0. */
    private int m_maxWaitlistSubmissions;
    /** The number of submissions that are not made via the form (specified in the form's configuration content). */
    private int m_numOtherSubmissions;
    /** The number of submissions via the form (the number of contents with submission data). */
    private int m_numFormSubmissions;
    /** The CmsObject to use for status requests. */
    private CmsObject m_cms;

    /** Default constructor. The status is unlimited submissions allowed, no waitlist and nothing submitted yet. */
    public CmsSubmissionStatus() {

        // do nothing, keep defaults.
    }

    /**
     * Generate a submission status object for the form.
     *
     * @param cms the cms object used to read the submission data sets.
     * @param ugcConfig the ugc configuration for the form.
     *
     * @throws CmsException thrown if the submitted data sets could not be read.
     */
    public CmsSubmissionStatus(CmsObject cms, CmsFormUgcConfiguration ugcConfig)
    throws CmsException {

        if (null != ugcConfig) {
            m_maxRegularSubmissions = ugcConfig.getMaxRegularDataSets();
            m_maxWaitlistSubmissions = ugcConfig.getMaxWaitlistDataSets();
            m_numOtherSubmissions = ugcConfig.getNumOtherDataSets();
            m_cms = CmsWebformModuleAction.getAdminCms(cms);
            m_numFormSubmissions = readSubmissionResources(ugcConfig).size();
        } // else keep default values.
    }

    /**
     * Returns the number of regular submissions that are allowed. <code>null</code> means unlimited.
     * @return the number of regular submissions that are allowed. <code>null</code> means unlimited.
     */
    public Integer getMaxRegularSubmissions() {

        return m_maxRegularSubmissions;
    }

    /**
     * Returns the number of waitlist submissions that are allowed.
     * @return the number of waitlist submissions that are allowed.
     */
    public int getMaxWaitlistSubmissions() {

        return m_maxWaitlistSubmissions;
    }

    /**
     * Returns the number of already submitted form datasets.
     * @return the number of already submitted form datasets.
     */
    public int getNumFormSubmissions() {

        return m_numFormSubmissions;
    }

    /**
     * Returns the number of submissions made not via the form.
     * @return the number of submissions made not via the form.
     */
    public int getNumOtherSubmissions() {

        return m_numOtherSubmissions;
    }

    /**
     * Returns the number of submissions that are still possible. Not including the submissions for the waitlist. <code>null</code> means unlimited.
     * @return the number of submissions that are still possible. Not including the submissions for the waitlist. <code>null</code> means unlimited.
     */
    public Integer getNumRemainingRegularSubmissions() {

        return m_maxRegularSubmissions != null
        ? Integer.valueOf(Math.max(m_maxRegularSubmissions.intValue() - getNumTotalSubmissions(), 0))
        : null;
    }

    /**
     * Returns the number of submissions for the waitlist that are still possible.
     * @return the number of submissions for the waitlist that are still possible.
     */
    public int getNumRemainingWaitlistSubmissions() {

        if ((m_maxRegularSubmissions == null)
            || ((m_maxRegularSubmissions.intValue() - getNumTotalSubmissions()) >= 0)) {
            return m_maxWaitlistSubmissions;
        } else {
            return Math.max(
                0,
                m_maxWaitlistSubmissions - (getNumTotalSubmissions() - m_maxRegularSubmissions.intValue()));
        }
    }

    /**
     * Returns the number of submissions already made (via form or otherwise).
     * @return the number of submissions already made (via form or otherwise).
     */
    public int getNumTotalSubmissions() {

        return m_numFormSubmissions + m_numOtherSubmissions;
    }

    /**
     * Returns a flag, indicating that no submissions are possible anymore (not even on the waitlist).
     * @return a flag, indicating that no submissions are possible anymore (not even on the waitlist).
     */
    public boolean isFullyBooked() {

        return (null != m_maxRegularSubmissions)
            && ((m_maxRegularSubmissions.intValue() + m_maxWaitlistSubmissions) <= getNumTotalSubmissions());
    }

    /**
     * Returns a flag, indicating that submissions are possible, but only for the waitlist.
     * @return a flag, indicating that submissions are possible, but only for the waitlist.
     */
    public boolean isOnlyWaitlist() {

        return (null != m_maxRegularSubmissions)
            && (m_maxRegularSubmissions.intValue() <= getNumTotalSubmissions())
            && !isFullyBooked();
    }

    /**
     * Reads the resources with the submitted data that are not cancelled (i.e. expired).
     * @param ugcConfig the ugc configuration, containing information on  which data has to be read.
     * @return the resources with the submitted data.
     * @throws CmsException thrown if reading fails.
     */
    private List<CmsResource> readSubmissionResources(CmsUgcConfiguration ugcConfig) throws CmsException {

        return m_cms.readResources(
            ugcConfig.getContentParentFolder(),
            CmsResourceFilter.DEFAULT.addRequireType(
                OpenCms.getResourceManager().getResourceType(ugcConfig.getResourceType())),
            false);
    }

}
