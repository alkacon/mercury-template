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

package alkacon.mercury.template.mail;

import org.opencms.file.CmsObject;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsHtmlParser;
import org.opencms.util.I_CmsMacroResolver;

import java.util.Collections;
import java.util.Map;

import org.apache.commons.logging.Log;

import org.htmlparser.Node;
import org.htmlparser.Tag;
import org.htmlparser.util.NodeList;

/** Visitor of the {@link CmsMailParser}, used to perform replacements for links. */
public class CmsMailHtmlVisitor extends CmsHtmlParser {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsMailHtmlVisitor.class);

    /** Regex to match links that should just be a macro, but where manipulated by the editor. */
    private static final String REGEX_MACRO_LINK = ".*%\\((.*)\\)";

    /** Replacement for manipulated macro links, returning simply the link macro. */
    private static final String REPLACEMENT_MACRO_LINK = "%($1)";

    /** The current CmsObject. */
    private CmsObject m_cms;

    /** The map holding the replacements */
    private Map<String, String> m_replacements;

    /** Macro resolver to resolve macros in links. */
    private I_CmsMacroResolver m_macroResolver;

    /** A flag, indicating if absolute links should be enforced. */
    private boolean m_absoluteLinks;

    /**
     *
     * Constructor.<p>
     *
     * @param cms the CmsObject to get the current user request context
     * @param replacementMap the map holding the link prefix replacement pairs
     * @param macroResolver resolver to apply to macro links.
     * @param absoluteLinks a flag, indicating if absolute links should be enforced.
     */
    public CmsMailHtmlVisitor(
        CmsObject cms,
        Map<String, String> replacementMap,
        I_CmsMacroResolver macroResolver,
        boolean absoluteLinks) {

        super(true);
        m_cms = cms;
        m_replacements = null == replacementMap ? Collections.emptyMap() : replacementMap;
        m_macroResolver = macroResolver;
        m_absoluteLinks = absoluteLinks;

    }

    /**
     * @see org.opencms.util.CmsHtmlParser#visitTag(org.htmlparser.Tag)
     */
    @Override
    public void visitTag(Tag tag) {

        String tagName = tag.getTagName();
        if (tagName.equals("A") || tagName.equals("LINK")) {
            String hrefContent = tag.getAttribute("HREF");
            String absoluteHrefContent = null;
            LOG.debug(
                "[START] Link parsing on page '"
                    + m_cms.getRequestContext().getSiteRoot()
                    + m_cms.getRequestContext().getUri()
                    + "'");
            LOG.debug("Found link to '" + hrefContent + "'");

            // if there is no href value, do nothing
            if ((hrefContent != null)) {
                String finalHrefContent = hrefContent;
                if (hrefContent.matches(REGEX_MACRO_LINK)) {
                    String macroHrefContent = hrefContent.replaceFirst(REGEX_MACRO_LINK, REPLACEMENT_MACRO_LINK);
                    String resolvedHrefContent = m_macroResolver.resolveMacros(macroHrefContent);
                    if (resolvedHrefContent != macroHrefContent) {
                        absoluteHrefContent = getAbsoluteLink(resolvedHrefContent);
                        finalHrefContent = applyReplacements(absoluteHrefContent);
                        // correct absolute link to match the content element as well
                        absoluteHrefContent = macroHrefContent;
                    }
                } else {
                    absoluteHrefContent = getAbsoluteLink(hrefContent);

                    // Apply the replacements to the absolute link
                    finalHrefContent = applyReplacements(absoluteHrefContent);
                }

                // Finally replace the original link with the adjusted link
                if (!finalHrefContent.equals(hrefContent)) {
                    tag.setAttribute("href", finalHrefContent);
                    // Check if the link content is the absolute link itself - if so, adjust it as well.
                    NodeList children = tag.getChildren();
                    Node linkTextNode = (children != null) && (children.size() > 0) ? children.elementAt(0) : null;
                    if ((null != linkTextNode)
                        && (null != absoluteHrefContent)
                        && (linkTextNode.getText().equals(absoluteHrefContent)
                            || linkTextNode.getText().equals(hrefContent))) {
                        linkTextNode.setText(finalHrefContent);
                    }
                }
            }

            LOG.debug("[END] href parsing completed");
        }

        if (tagName.equals("IMG")) {
            String srcContent = tag.getAttribute("SRC");
            LOG.debug(
                "[START] Img src parsing on page '"
                    + m_cms.getRequestContext().getSiteRoot()
                    + m_cms.getRequestContext().getUri()
                    + "'");
            LOG.debug("Found img source: '" + srcContent + "'");

            // if there is no src value, do nothing
            if ((srcContent != null)) {

                String absoluteLink = getAbsoluteLink(srcContent);

                String finalLink = applyReplacements(absoluteLink);

                if (!finalLink.equals(srcContent)) {
                    tag.setAttribute("src", finalLink);
                }
            }

            LOG.debug("[END] Img parsing completed");
        }

        super.visitTag(tag);
    }

    /**
     * Applies the replacements to the link.
     *
     * @param link the link to apply the replacements to.
     *
     * @return the adjusted link.
     */
    protected String applyReplacements(String link) {

        String resultLink = link;
        for (String key : m_replacements.keySet()) {
            if (resultLink.contains(key)) {
                resultLink = resultLink.replace(key, m_replacements.get(key));
            }
        }
        return resultLink;
    }

    /**
     * Returns the absolute link (that starts with protocol and hostname) for the provided link.
     *
     * @param link the link to get the absolute link from.
     *
     * @return the absolute link that corresponds to the provided link.
     */
    private String getAbsoluteLink(String link) {

        String absoluteLink = link;
        // check if the a relative link is used, if so, change to absolute online link
        if (m_absoluteLinks && absoluteLink.startsWith("/")) {
            // tricky mechanism to deal with prefixes for links to exported an unexported resources
            String prefix = OpenCms.getLinkManager().getOnlineLink(m_cms, "/");
            // cut of everything starting at the first single slash
            prefix = prefix.replaceFirst("(([^/](//+)?)*)/.*", "$1");
            absoluteLink = prefix + absoluteLink;
            LOG.debug("Changed relative link to absolute: '" + absoluteLink + "'");
        }

        return absoluteLink;
    }

}
