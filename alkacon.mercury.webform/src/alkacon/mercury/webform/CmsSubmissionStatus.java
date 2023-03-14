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

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.main.CmsException;
import org.opencms.main.OpenCms;
import org.opencms.ugc.CmsUgcConfiguration;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;

import java.util.ArrayList;
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

    /** The list of participants, either registered via a regular submission or moved up from the waitlist. */
    private List<CmsFormDataBean> m_participants = new ArrayList<>();

    /** The list of candidates currently waiting for a regular participant place. */
    private List<CmsFormDataBean> m_waitlistCandidates = new ArrayList<>();

    /** The CmsObject to use for status requests. */
    private CmsObject m_cms;

    /** Default constructor. The status is unlimited submissions allowed, no waitlist and nothing submitted yet. */
    public CmsSubmissionStatus() {

        // do nothing, keep defaults.
    }

    /**
     * Generate a submission status object for the form.
     * @param cms the cms object used to read the submission data sets.
     * @param ugcConfig the ugc configuration for the form.
     * @throws CmsException thrown if the submitted data sets could not be read.
     */
    public CmsSubmissionStatus(CmsObject cms, CmsFormUgcConfiguration ugcConfig)
    throws CmsException {

        if (null != ugcConfig) {
            m_maxRegularSubmissions = ugcConfig.getMaxRegularDataSets();
            m_maxWaitlistSubmissions = ugcConfig.getMaxWaitlistDataSets();
            m_numOtherSubmissions = ugcConfig.getNumOtherDataSets();
            m_cms = CmsWebformModuleAction.getAdminCms(cms);
            readSubmissionResources(ugcConfig);
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
     * Returns the number of free places where waitlist candidates can move up.
     * @return the number of free places where waitlist candidates can move up
     */
    public int getNumMoveUpPlaces() {

        if (m_maxRegularSubmissions == null) {
            return 0;
        } else {
            return m_maxRegularSubmissions.intValue() - getNumParticipants();
        }
    }

    /**
     * Returns the number of submissions made not via the form.
     * @return the number of submissions made not via the form.
     */
    public int getNumOtherSubmissions() {

        return m_numOtherSubmissions;
    }

    /**
     * Returns the number of regular participants, either registered via a regular submission or moved up from the
     * waitlist.
     * @return the number of regular participants
     */
    public int getNumParticipants() {

        return m_participants.size() + m_numOtherSubmissions;
    }

    /**
     * Returns the number of submissions that are still possible. Not including the submissions for the waitlist.
     * <code>null</code> means unlimited.
     * @return the number of submissions that are still possible. Not including the submissions for the waitlist.
     * <code>null</code> means unlimited.
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
     * Returns the number of candidates currently waiting for a regular participant place.
     * @return the number of candidates currently waiting for a regular participant place
     */
    public int getNumWaitlistCandidates() {

        return m_waitlistCandidates.size();
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
     * @throws CmsException thrown if reading fails.
     */
    private void readSubmissionResources(CmsUgcConfiguration ugcConfig) throws CmsException {

        if (ugcConfig.getContentParentFolder() != null) {
            List<CmsResource> resources = m_cms.readResources(
                ugcConfig.getContentParentFolder(),
                CmsResourceFilter.DEFAULT.addRequireType(
                    OpenCms.getResourceManager().getResourceType(ugcConfig.getResourceType())),
                false);
            if (resources != null) {
                m_numFormSubmissions = resources.size();
                for (CmsResource resource : resources) {
                    CmsFile file = m_cms.readFile(resource);
                    CmsXmlContent content = CmsXmlContentFactory.unmarshal(m_cms, file);
                    CmsFormDataBean bean = new CmsFormDataBean(content);
                    if (bean.isWaitlist()) {
                        m_waitlistCandidates.add(bean);
                    } else {
                        m_participants.add(bean);
                    }
                }
            }
        }
    }

}
