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
import org.opencms.jsp.parse.A_CmsConfiguredHtmlParser;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.util.I_CmsHtmlNodeVisitor;
import org.opencms.util.I_CmsMacroResolver;

import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;

import org.htmlparser.util.ParserException;

/**
 * Configured HTML parser for link replacements in mails.
 *
 */
public class CmsMailParser extends A_CmsConfiguredHtmlParser {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsMailParser.class);

    /** The context to use for performing the replacements. */
    private CmsObject m_cms;

    /** The replacements. */
    private Map<String, String> m_replacements;

    /** The resolver for macros in links. */
    private I_CmsMacroResolver m_macroResolver;

    /** Flag, indicating if absolute links should be enforced. */
    private boolean m_absoluteLinks;

    /**
     * Creates a new mail parser.
     *
     * @param cms the context to use for the replacements.
     * @param replacementMap the replacements to perform.
     * @param macroResolver resolver for macros in links to be applied before adjustments are made.
     * @param absoluteLinks a flag, indicating if absolute links should be enforced.
     */
    public CmsMailParser(
        CmsObject cms,
        Map<String, String> replacementMap,
        I_CmsMacroResolver macroResolver,
        boolean absoluteLinks) {

        m_cms = cms;
        m_replacements = replacementMap;
        m_macroResolver = macroResolver;
        m_absoluteLinks = absoluteLinks;
    }

    /**
     * Returns the result of subsequent parsing to the &lt;cms:parse&lt; tag implementation.<p>
     *
     * @param encoding the encoding to use for parsing
     * @param html the html content to parse
     * @param noAutoCloseTags a list of upper case tag names for which parsing / visiting should not correct missing closing tags.
     *
     * @return the result of subsequent parsing to the &lt;cms:parse&lt; tag implementation
     *
     * @throws ParserException if something goes wrong at parsing
     * @throws CmsException if something goes wrong at accessing OpenCms core functionality
    */
    @Override
    public String doParse(String html, String encoding, List<String> noAutoCloseTags)
    throws ParserException, CmsException {

        if (LOG.isDebugEnabled()) {
            LOG.debug("Original HTML:");
            LOG.debug(html);
        }
        String adjustedHtml = html.replaceAll(
            "<!--\\[(.+?)\\]>",
            "<div class=\"__mso_conditional_start__\"><!-- $1 -->");
        adjustedHtml = adjustedHtml.replaceAll(
            "<!\\[(.+?)\\]-->",
            "<div class=\"__mso_conditional_end__\"><!-- $1 -->");
        if (LOG.isDebugEnabled()) {
            LOG.debug("Adjusted HTML:");
            LOG.debug(html);
        }
        String parsedHtml = super.doParse(adjustedHtml, encoding, noAutoCloseTags);
        parsedHtml = parsedHtml.replaceAll("<div class=\"__mso_conditional_start__\"><!-- (.+?) -->", "<!--[$1]>");
        parsedHtml = parsedHtml.replaceAll("<div class=\"__mso_conditional_end__\"><!-- (.+?) -->", "<![$1]-->");
        if (LOG.isDebugEnabled()) {
            LOG.debug("Parsed HTML:");
            LOG.debug(html);
        }
        return parsedHtml;

    }

    /**
     * @see org.opencms.jsp.parse.A_CmsConfiguredHtmlParser#createVisitorInstance()
     */
    @Override
    protected I_CmsHtmlNodeVisitor createVisitorInstance() {

        return new CmsMailHtmlVisitor(m_cms, m_replacements, m_macroResolver, m_absoluteLinks);
    }

}
