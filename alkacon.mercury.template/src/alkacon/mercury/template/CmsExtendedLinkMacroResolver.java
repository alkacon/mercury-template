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

import org.opencms.jsp.util.CmsJspStandardContextBean;
import org.opencms.util.CmsMacroResolver;

/**
 * Extended macro resolver that is capable of resolving <code>opencms://</code> links in macros.<p>
 */
public class CmsExtendedLinkMacroResolver extends CmsMacroResolver {

    /** The standard context bean is needed to resolve  <code>opencms://</code> links in macros. */
    private CmsJspStandardContextBean m_cmsJspBean;

    /**
     * Factory method to create a new {@link CmsExtendedLinkMacroResolver} instance.<p>
     *
     * @return a new instance of a {@link CmsExtendedLinkMacroResolver}
     */
    public static CmsExtendedLinkMacroResolver newInstance() {

        return new CmsExtendedLinkMacroResolver();
    }

    /**
     * Adds the capability to resolve macros starting with <code>opencms://</code>.<p>
     *
     * @see org.opencms.util.I_CmsMacroResolver#getMacroValue(java.lang.String)
     */
    @Override
    public String getMacroValue(String macro) {

        String result = CmsFunctionLinkResolver.resolve(m_cmsJspBean, macro);
        if ((result != null) && !result.equals(macro)) {
            return result;
        }
        return super.getMacroValue(macro);
    }

    /**
     * Resolves the macros in the given input.<p>
     *
     * Adds the capability to resolve links starting with <code>opencms://</code>.<p>
     *
     * @see org.opencms.util.CmsMacroResolver#resolveMacros(java.lang.String)
     */
    @Override
    public String resolveMacros(String input) {

        // add macro delimiters in case we have a standard context bean instance available
        if (m_cmsJspBean != null) {
            // this is necessary because links in OpenCms HTML fields cannot be wrapped with macro delimiters
            input = input.replaceAll("=\"(opencms://[^\"]*)\"", "=\"%($1)\"");
        }
        return super.resolveMacros(input);
    }

    /**
     * Provides a JSP page context to this macro resolver, required to resolve certain macros.<p>
     *
     * @param jspPageContext the JSP page context to use
     *
     * @return this instance of the macro resolver
     */
    public CmsExtendedLinkMacroResolver setJspBean(CmsJspStandardContextBean cmsJspBean) {

        m_cmsJspBean = cmsJspBean;
        return this;
    }
}
