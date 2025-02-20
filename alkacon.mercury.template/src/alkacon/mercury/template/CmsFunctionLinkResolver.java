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

import org.opencms.ade.detailpage.CmsDetailPageInfo;
import org.opencms.file.CmsObject;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.jsp.util.CmsJspStandardContextBean;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;

import org.apache.commons.logging.Log;

/**
 * This class resolves <code>opencms://</code> links.<p>
 */
public final class CmsFunctionLinkResolver {

    /** The 'opencms://' prefix. */
    private static final String OPENCMS_PREFIX = "opencms://";

    /** Prefix 'function@' for links to function detail pages. */
    private static final String LINK_FUNCTION = CmsDetailPageInfo.FUNCTION_PREFIX;

    /** Prefix 'login' for links to the workplace login page. */
    private static final String LINK_LOGIN = "login";

    /** Prefix 'locale@' for links to the current page in another locale. */
    private static final String LINK_LOCALE = "locale@";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFunctionLinkResolver.class);

    /**
     * Hides the public constructor for this utility class.<p>
     */
    private CmsFunctionLinkResolver() {

        // hide constructor
    }

    /**
     * Resolves an internal <code>opencms://</code> link.<p>
     * In case the link does not have the prefix, it will be returned unaltered.<p>
     *
     * This version is for use from the JSP tag <code>mercury:link-opencms</code>.<p>
     *
     * @param cmsBean the currents page {@link CmsJspStandardContextBean}
     * @param link the link to resolve
     *
     * @return the resolved link
     *
     * @see CmsFunctionLinkResolver#resolveFunction(CmsObject, String)
     */
    public static String resolve(CmsJspStandardContextBean cmsBean, String link) {

        String result = link;
        try {

            if ((link != null)
                && (cmsBean != null)
                && (link.startsWith(OPENCMS_PREFIX) || link.startsWith(LINK_FUNCTION))) {

                CmsObject cms = cmsBean.getVfs().getCmsObject();

                if (cms != null) {

                    // remove prefix
                    String iLink = link.startsWith(OPENCMS_PREFIX)
                    ? link.substring(OPENCMS_PREFIX.length()).trim()
                    : link.trim();

                    // remove and store #hash suffix
                    String anchor = "";
                    int apos = iLink.indexOf('#');
                    if (apos != -1) {
                        anchor = iLink.substring(apos);
                        iLink = iLink.substring(0, apos - 1);
                    }

                    if (iLink.startsWith(LINK_FUNCTION)) {

                        // link to a function detail page
                        String targetFunction = iLink.substring(LINK_FUNCTION.length());
                        String functionLink = cmsBean.getFunctionDetailPage().get(targetFunction);
                        if (!functionLink.contains("No detail page")) {
                            result = functionLink;
                        }
                    } else if (iLink.equals(LINK_LOGIN)) {

                        // link to the workplace server login page
                        result = org.opencms.main.OpenCms.getSiteManager().getWorkplaceServer() + "/system/login/";
                    } else if (iLink.startsWith(LINK_LOCALE)) {

                        // link to another locale version of the current page
                        String targetLocale = iLink.substring(LINK_LOCALE.length());
                        if (cmsBean.isDetailRequest()) {
                            // links between localized detail pages
                            String targetLink = cmsBean.getDetailContent().getSitePath();
                            String baseUri = cmsBean.getLocaleResource().get(targetLocale).getSitePath();
                            if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(baseUri)) {
                                // this content is available in the other locale
                                cms = OpenCms.initCmsObject(cms);
                                if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(baseUri)) {
                                    cms.getRequestContext().setUri(baseUri);
                                }
                                cms.getRequestContext().setLocale(CmsLocaleManager.getLocale(targetLocale));
                            }
                            result = OpenCms.getLinkManager().substituteLinkForUnknownTarget(
                                cms,
                                targetLink,
                                null,
                                false);
                        } else {
                            // links between localized regular pages
                            result = cmsBean.getLocaleResource().get(targetLocale).getLink();
                        }
                    }
                    if ((result != null) && (anchor != null)) {
                        result = result + anchor;
                    }
                }
            }

        } catch (Exception e) {
            LOG.error("Unable to resolve link '" + link + "'", e);
        }
        return result;
    }

    /**
     * Resolves a <code>function@</code> link.<p>
     *
     * In case the link does not have this prefix, it will be returned unaltered.<p>
     *
     * This version is for use from another class.
     * It behaves the same as {@link #resolve(CmsJspStandardContextBean, String)} for lnks to function detail pages.<p>
     *
     * @param cms the current OpenCms context
     * @param link the link to resolve
     *
     * @return the resolved link
     *
     * @see CmsFunctionLinkResolver#resolve(CmsJspStandardContextBean, String)
     */
    public static String resolveFunction(CmsObject cms, String link) {

        String result = link;
        try {
            if ((link != null) && (cms != null) && link.startsWith(LINK_FUNCTION)) {

                // link to a function detail page
                String targetFunction = link.substring(LINK_FUNCTION.length());
                String functionLink = CmsJspStandardContextBean.getFunctionDetailLink(
                    cms,
                    LINK_FUNCTION,
                    targetFunction,
                    false);
                if (!functionLink.contains("No detail page")) {
                    result = functionLink;
                }
            }

        } catch (Exception e) {
            LOG.error("Unable to resolve link '" + link + "'", e);
        }
        return result;
    }
}
