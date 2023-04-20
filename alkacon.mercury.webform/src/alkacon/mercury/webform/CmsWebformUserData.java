/*
 * This library is part of OpenCms -
 * the Open Source Content Management System
 *
 * Copyright (c) Alkacon Software GmbH & Co. KG (http://www.alkacon.com)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * For further information about Alkacon Software, please see the
 * company website: http://www.alkacon.com
 *
 * For further information about OpenCms, please see the
 * project website: http://www.opencms.org
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

package alkacon.mercury.webform;

import org.opencms.configuration.CmsParameterConfiguration;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.file.CmsUser;
import org.opencms.jsp.userdata.CmsUserDataRequestType;
import org.opencms.jsp.userdata.I_CmsUserDataDomain;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.search.fields.CmsSearchField;
import org.opencms.search.solr.CmsSolrIndex;
import org.opencms.search.solr.CmsSolrQuery;
import org.opencms.search.solr.CmsSolrResultList;
import org.opencms.util.CmsStringUtil;
import org.opencms.xml.CmsXmlUtils;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.mail.internet.InternetAddress;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;

import org.jsoup.nodes.Element;

/**
 * Presents webform data for a given email address as user data for the user data app.
 *
 * <p>The content types to search can be configured via the 'types' parameter, which can contain
 * a comma-separated list of resource type names.
 *
 * <p>
 * The underlying assumptions for what this class does are:
 * <ul>
 * <li>All form data resources are XML contents where 'Data' is a multivalued nested content field with 'Key'/'Value' subfields
 * <li>All form data resources get published
 * <li>A webform data resource contains just the email to search for in one of its Data/Value fields, possibly with leading/trailing whitespace but no other text
 * </ul>
 */
public class CmsWebformUserData implements I_CmsUserDataDomain {

    /** Configuration parameter for configuring the set of resource types to read. */
    private static final String PARAM_TYPES = "types";

    /** Comma-separated list of types to read by default. */
    private static final String DEFAULT_TYPES = "m-webform-data";

    /** Logger instance for this class. */
    private static final Log LOG = CmsLog.getLog(CmsWebformUserData.class);

    /** The parameter configuration. */
    private CmsParameterConfiguration m_config = new CmsParameterConfiguration();

    /** The CMS context. */
    private CmsObject m_cms;

    /**
     * @see org.opencms.configuration.I_CmsConfigurationParameterHandler#addConfigurationParameter(java.lang.String, java.lang.String)
     */
    public void addConfigurationParameter(String paramName, String paramValue) {

        m_config.add(paramName, paramValue);
    }

    /**
     * @see org.opencms.jsp.userdata.I_CmsUserDataDomain#appendInfoHtml(org.opencms.file.CmsObject, org.opencms.jsp.userdata.CmsUserDataRequestType, java.util.List, org.jsoup.nodes.Element)
     */
    public void appendInfoHtml(CmsObject cms, CmsUserDataRequestType reqType, List<CmsUser> user, Element element) {

        // do nothing
    }

    /**
     * @see org.opencms.jsp.userdata.I_CmsUserDataDomain#appendlInfoForEmail(org.opencms.file.CmsObject, java.lang.String, java.util.List, org.jsoup.nodes.Element)
     */

    public void appendlInfoForEmail(
        CmsObject currentCms,
        String emailParam,
        List<String> searchStrings,
        Element element) {

        final String email = CmsStringUtil.isEmptyOrWhitespaceOnly(emailParam) ? null : emailParam;
        if (email != null) {
            try {
                InternetAddress addr = new InternetAddress(email);
                addr.validate();
            } catch (Exception e) {
                LOG.info(e.getLocalizedMessage(), e);
                return;
            }
        }

        try {
            CmsObject cms = OpenCms.initCmsObject(m_cms);
            // search resources (offline)
            Set<CmsResource> allResources = searchCandidateResourcesForEmail(email, searchStrings);
            for (CmsResource resource : allResources) {
                try {
                    // unmarshal resource (online)
                    CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
                    Map<String, String> dataEntries = readValues(content);
                    if (matchContent(email, searchStrings, dataEntries)) {
                        String title = LogMessages.get().getBundle(currentCms.getRequestContext().getLocale()).key(
                            LogMessages.GUI_FORMDATA_HEADING_1,
                            content.getFile().getRootPath());
                        Element div = element.appendElement("div");
                        div.appendElement("h2").text(title);
                        Element dl = div.appendElement("dl");
                        for (Map.Entry<String, String> entry : dataEntries.entrySet()) {
                            dl.appendElement("dt").text(entry.getKey());
                            dl.appendElement("dd").text(entry.getValue());
                        }
                    }
                } catch (Exception e) {
                    LOG.error(e.getLocalizedMessage(), e);
                }
            }
        } catch (Exception e) {
            LOG.error(e.getLocalizedMessage(), e);
        }
    }

    /**
     * @see org.opencms.configuration.I_CmsConfigurationParameterHandler#getConfiguration()
     */

    public CmsParameterConfiguration getConfiguration() {

        return m_config;
    }

    /**
     * @see org.opencms.configuration.I_CmsConfigurationParameterHandler#initConfiguration()
     */

    public void initConfiguration() {

        // do nothing
    }

    /**
     * @see org.opencms.jsp.userdata.I_CmsUserDataDomain#initialize(org.opencms.file.CmsObject)
     */

    public void initialize(CmsObject cms) {

        try {
            m_cms = OpenCms.initCmsObject(cms);
        } catch (CmsException e) {
            LOG.error(e.getLocalizedMessage(), e);
            m_cms = cms;
        }

    }

    /**
     * @see org.opencms.jsp.userdata.I_CmsUserDataDomain#matchesUser(org.opencms.file.CmsObject, org.opencms.jsp.userdata.CmsUserDataRequestType, org.opencms.file.CmsUser)
     */

    public boolean matchesUser(CmsObject cms, CmsUserDataRequestType reqType, CmsUser user) {

        return false;
    }

    /**
     * Gets the list of resource types to read.
     *
     * @return the list of resource types to read
     */
    private List<String> getTypesToRead() {

        String typesStr = m_config.getString(PARAM_TYPES, DEFAULT_TYPES);
        return Stream.of(typesStr.split(",")).map(type -> type.trim()).collect(Collectors.toList());
    }

    /**
     * Helper function to check if a content matches the given search parameters.
     *
     * @param email the email
     * @param searchFilters the additional search strings
     * @param dataValues the key-value pairs from the content
     * @return true if the content matches the search parameters
     */
    private boolean matchContent(String email, List<String> searchFilters, Map<String, String> dataValues) {

        // - use exact match (minus whitespace) for email and substring match for all other search filters
        // - using case insensitive matching for email is fine, because email addresses that only differ in case are equivalent
        if (email != null) {
            if (dataValues.values().stream().anyMatch(val -> email.equalsIgnoreCase(val.trim()))) {
                return true;
            }
        }

        if (searchFilters.size() > 0) {
            for (String searchString : searchFilters) {
                if (!dataValues.values().stream().anyMatch(val -> StringUtils.containsIgnoreCase(val, searchString))) {
                    return false;
                }
            }
            return true;
        }

        // if email doesn't match and there are no search filters, we shouldn't get any results
        return false;
    }

    /**
     * Reads key-value pairs from the webform data content and returns them as a map.
     *
     * @param content the content
     * @return the map of key-value data from the webform
     */
    private Map<String, String> readValues(CmsXmlContent content) {

        Map<String, String> result = new LinkedHashMap<>();
        for (Locale locale : content.getLocales()) {
            List<I_CmsXmlContentValue> entries = content.getValues("Data", locale);
            for (I_CmsXmlContentValue entry : entries) {
                String keyPath = CmsXmlUtils.concatXpath(entry.getPath(), "Key");
                String valuePath = CmsXmlUtils.concatXpath(entry.getPath(), "Value");
                String keyStr = content.getValue(keyPath, locale).getStringValue(m_cms);
                String valueStr = content.getValue(valuePath, locale).getStringValue(m_cms);
                result.put(keyStr, valueStr);
            }
        }
        return result;
    }

    /**
     * Searches the candidate resources for a given email.
     *
     * <p>This may return some false positives for two reasons:
     * <ul>
     * <li>
     * First, the @ character is treated as whitespace by the tokenizer, so searching for john.doe@company.com would also find a content that contains "john.doe company.com".
     * <li>
     * Second, the search may also find contents that contain the email address as part of a larger text.
     * </ul>
     *
     * We filter out these false positives later.
     *
     * @param email the email address to search for
     * @param searchStrings the other search strings
     * @return the set of resources which have been found
     * @throws Exception if something goes wrong
     */
    private Set<CmsResource> searchCandidateResourcesForEmail(String email, List<String> searchStrings)
    throws Exception {

        CmsObject cms = OpenCms.initCmsObject(m_cms);

        // we can only use a Solr query if we have an email address but no additional search strings,
        // in other cases we have to read all the form data resources

        if ((email != null) && (searchStrings.size() == 0)) {
            Map<String, String[]> params = new HashMap<>();
            CmsSolrQuery query = new CmsSolrQuery(cms, params);
            query.addFilterQuery(CmsSearchField.FIELD_CONTENT, Arrays.asList(email), true, true);
            query.addFilterQuery(CmsSearchField.FIELD_TYPE, getTypesToRead(), false, false);
            query.removeExpiration();
            // use offline index, since expired resources are not indexed in the online index! We still use a CmsObject in the Online project, since the offline
            // and online contents should be identical.
            CmsSolrIndex index = (CmsSolrIndex)OpenCms.getSearchManager().getIndex(
                CmsSolrIndex.DEFAULT_INDEX_NAME_OFFLINE);
            final int pageSize = 400;
            query.setRows(Integer.valueOf(pageSize));
            int page = 0;
            CmsSolrResultList res = null;
            Set<CmsResource> searchResources = new HashSet<>();
            do {
                query.setStart(Integer.valueOf(page * pageSize));
                res = index.search(cms, query, true, null, true, CmsResourceFilter.IGNORE_EXPIRATION);
                searchResources.addAll(res);
                page += 1;
            } while (res.size() > 0);
            return searchResources;
        } else {
            cms.getRequestContext().setSiteRoot("");
            Set<CmsResource> resources = new HashSet<>();
            for (String type : getTypesToRead()) {
                if (OpenCms.getResourceManager().hasResourceType(type)) {
                    CmsResourceFilter filter = CmsResourceFilter.IGNORE_EXPIRATION.addRequireType(
                        OpenCms.getResourceManager().getResourceType(type));
                    try {
                        List<CmsResource> typeResources = cms.readResources("/", filter, true);
                        resources.addAll(typeResources);
                    } catch (Exception e) {
                        LOG.warn(e.getLocalizedMessage(), e);
                    }

                }
            }
            return resources;
        }
    }
}
