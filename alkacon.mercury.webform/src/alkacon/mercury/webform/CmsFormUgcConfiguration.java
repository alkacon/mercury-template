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

import org.opencms.file.CmsGroup;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsUser;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.ugc.CmsUgcConfiguration;
import org.opencms.util.CmsUUID;

import java.util.List;

import com.google.common.base.Optional;

/** Extension of {@link CmsUgcConfiguration} that is fitted for the webform module.
 * It allows for easier construction and saves some more configuration values concerning the waitlist.
 */
public class CmsFormUgcConfiguration extends CmsUgcConfiguration {

    /** The name pattern to use for form data contents. */
    public static final String DEFAULT_NAME_PATTERN = "formdata_%(number).xml";

    /** The resource type for db entry XML contents. */
    public static final String CONTENT_TYPE_FORM_DATA = "m-webform-data";

    /** The maximally allowed submissions without waitlist. */
    private Integer m_maxRegularDataSets;
    /** The number of submissions added otherwise (i.e., where the submitted data is stored differently). */
    private int m_numOtherDataSets;
    /** The maximal number of additional data sets accepted on a waitlist. */
    private int m_maxWaitlistDataSets;
    /** The title property for datasets which can contain macros for form fields. */
    private String m_datasetTitle;

    /**
     * Creates a new form configuration.
     *
     * @param id the id for the form configuration
     * @param userForGuests the user to use for VFS operations caused by guests who submit the XML content form
     * @param projectGroup the group to be used as the manager group for projects based on this configuration
     * @param contentParentFolder the parent folder for XML contents
     * @param maxRegularDataSets the maximally allowed submissions without waitlist.
     * @param numOtherDataSets the number of submissions added otherwise (i.e., where the submitted data is stored differently)
     * @param maxWaitlistDataSets the maximal number of additional data sets accepted on a waitlist.
     * @param datasetTitle the title for XML contents that store form data (possibly with macros for values of form fields).
     */
    public CmsFormUgcConfiguration(
        CmsUUID id,
        Optional<CmsUser> userForGuests,
        CmsGroup projectGroup,
        CmsResource contentParentFolder,
        Optional<Integer> maxRegularDataSets,
        Optional<Integer> numOtherDataSets,
        Optional<Integer> maxWaitlistDataSets,
        String datasetTitle) {

        super(
            id,
            userForGuests,
            projectGroup,
            CONTENT_TYPE_FORM_DATA,
            contentParentFolder,
            DEFAULT_NAME_PATTERN,
            CmsLocaleManager.MASTER_LOCALE,
            Optional.<CmsResource> absent(), // uploadParent
            Optional.<Long> absent(), //maxUploadSize
            calculateMaxNumDataSets(maxRegularDataSets, numOtherDataSets, maxWaitlistDataSets),
            Optional.<Long> absent(), //queueTimeout
            Optional.<Integer> absent(), //maxQueueLength
            true, //autoPublish
            Optional.<List<String>> absent()); //validExtensions

        m_maxRegularDataSets = maxRegularDataSets.isPresent() ? maxRegularDataSets.get() : null;
        m_numOtherDataSets = numOtherDataSets.isPresent() ? numOtherDataSets.get().intValue() : 0;
        m_maxWaitlistDataSets = maxWaitlistDataSets.isPresent() ? maxWaitlistDataSets.get().intValue() : 0;
        m_datasetTitle = null == datasetTitle ? "" : datasetTitle;
    }

    /**
     * Calculates the maximal number of data sets that can be added via UGC.
     * @param maxRegularDataSets the maximally allowed regular data sets (without the waitlist).
     * @param numOtherDataSets the otherwise added data sets (that are not in the folder where UGC stores in.
     * @param maxWaitlistDataSets the maximal number of additional data sets for a waitlist.
     * @return the maximal number of data sets that can be added via UGC.
     */
    protected static Optional<Integer> calculateMaxNumDataSets(
        Optional<Integer> maxRegularDataSets,
        Optional<Integer> numOtherDataSets,
        Optional<Integer> maxWaitlistDataSets) {

        Optional<Integer> maxNumContents;
        if (maxRegularDataSets.isPresent()) {
            if (numOtherDataSets.isPresent()) {
                maxNumContents = Optional.<Integer> of(
                    Integer.valueOf(
                        Math.max((maxRegularDataSets.get().intValue() - numOtherDataSets.get().intValue()), 0)));
            } else {
                maxNumContents = maxRegularDataSets;
            }
            if (maxWaitlistDataSets.isPresent()) {
                maxNumContents = Optional.<Integer> of(
                    Integer.valueOf(maxNumContents.get().intValue() + maxWaitlistDataSets.get().intValue()));
            }
        } else {
            maxNumContents = Optional.absent();
        }
        return maxNumContents;
    }

    /**
     * Returns the title for dataset XML contents (possibly with macros for form fields).
     * @return the title for dataset XML contents (possibly with macros for form fields).
     */
    public String getDatasetTitle() {

        return m_datasetTitle;
    }

    /**
     * Returns the maximal number of regular submissions. If not specified, <code>null</code> is returned.
     * @return the maximal number of regular submissions. If not specified, <code>null</code> is returned.
     */
    public Integer getMaxRegularDataSets() {

        return m_maxRegularDataSets;
    }

    /**
     * Returns the maximal number of waitlist submissions. If not specified, <code>null</code> is returned.
     * @return the maximal number of waitlist submissions. If not specified, <code>null</code> is returned.
     */
    public int getMaxWaitlistDataSets() {

        return m_maxWaitlistDataSets;
    }

    /**
     * Returns the number of differently submitted data sets. If not specified, <code>0</code> is returned.
     * @return the number of differently submitted data sets. If not specified, <code>0</code> is returned.
     */
    public int getNumOtherDataSets() {

        return m_numOtherDataSets;
    }
}
