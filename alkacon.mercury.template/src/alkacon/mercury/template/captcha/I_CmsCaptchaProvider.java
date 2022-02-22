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

package alkacon.mercury.template.captcha;

import org.opencms.file.CmsObject;
import org.opencms.json.JSONException;

import java.io.IOException;

import javax.servlet.ServletRequest;

import org.apache.http.client.ClientProtocolException;

/**
 * Interface to be implemented by Captcha providers.
 */
public interface I_CmsCaptchaProvider {

    /**
     * Returns the Captcha widget markup.
     * @param cms the CMS context
     * @param request the servlet request
     * @param fieldName the form field name
     * @return the Captcha widget markup
     */
    public String getWidgetMarkup(CmsObject cms, ServletRequest request, String fieldName);

    /**
     * Returns a flag indicating whether this provider is disabled.
     * @param cms the CMS context
     * @return a flag indicating whether this provider is disabled
     */
    public boolean isDisabled(CmsObject cms);

    /**
     * Verifies a Captcha solution provided by the client.
     * @param cms the CMS context
     * @param solution the solution provided by the client
     * @return whether the solution could be verified or not
     * @throws IOException if request or response serialization fails
     * @throws ClientProtocolException if the HTTP request fails
     * @throws JSONException if parsing the response JSON fails
     */
    public boolean verifySolution(CmsObject cms, String solution)
    throws ClientProtocolException, IOException, JSONException;
}
