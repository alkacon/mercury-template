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
import org.opencms.util.I_CmsHtmlNodeVisitor;
import org.opencms.util.I_CmsMacroResolver;

import java.util.Map;

/**
 * Configured HTML parser for link replacements in mails.
 *
 */
public class CmsMailParser extends A_CmsConfiguredHtmlParser {

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
     * @see org.opencms.jsp.parse.A_CmsConfiguredHtmlParser#createVisitorInstance()
     */
    @Override
    protected I_CmsHtmlNodeVisitor createVisitorInstance() {

        return new CmsMailHtmlVisitor(m_cms, m_replacements, m_macroResolver, m_absoluteLinks);
    }

}
