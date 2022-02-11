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

import org.opencms.file.CmsObject;
import org.opencms.file.CmsRequestContext;

import javax.servlet.http.HttpServletRequest;

/**
 * Compatibility interface.
 */
public interface I_CmsFormHandler {

    /**
     * Returns the CMS object.
     * @return the CMS object
     */
    public CmsObject getCmsObject();

    /**
     * Returns the form configuration.
     * @return the form configuration
     */
    public I_CmsForm getFormConfiguration();

    /**
     * Returns the HTTP servlet request.
     * @return the HTTP servlet request
     */
    public HttpServletRequest getRequest();

    /**
     * Returns the request context.
     * @return the request context
     */
    public CmsRequestContext getRequestContext();
}
