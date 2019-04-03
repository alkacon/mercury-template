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

import java.io.PrintWriter;
import java.io.StringWriter;

import org.antlr.stringtemplate.StringTemplateErrorListener;

/**
 * An implementation of the error listener for the string templates.<p>
 */
public class CmsStringTemplateErrorListener implements StringTemplateErrorListener {

    /** The error output. */
    private StringBuffer m_errorOutput = new StringBuffer(512);

    /** The amount of warnings and errors. */
    private int m_number;

    /**
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object o) {

        String me = toString();
        String them = o.toString();
        return me.equals(them);
    }

    /**
     * @see org.antlr.stringtemplate.StringTemplateErrorListener#error(java.lang.String, java.lang.Throwable)
     */
    @Override
    public void error(String msg, Throwable e) {

        m_number++;
        if (m_number > 1) {
            m_errorOutput.append('\n');
        }
        if (e != null) {
            StringWriter st = new StringWriter();
            e.printStackTrace(new PrintWriter(st));
            m_errorOutput.append(msg + ": " + st.toString());
        } else {
            m_errorOutput.append(msg);
        }
    }

    /**
     *
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {

        return m_errorOutput.hashCode();
    }

    /**
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {

        return m_errorOutput.toString();
    }

    /**
     * @see org.antlr.stringtemplate.StringTemplateErrorListener#warning(java.lang.String)
     */
    @Override
    public void warning(String msg) {

        m_number++;
        m_errorOutput.append(msg);
    }
}
