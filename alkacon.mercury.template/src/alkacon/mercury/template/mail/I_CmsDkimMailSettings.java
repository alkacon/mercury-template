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

package alkacon.mercury.template.mail;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.mail.CmsMailHost;

/**
 * Interface for DKIM mail settings.
 */
public interface I_CmsDkimMailSettings {

    /**
     * Returns the allowed DKIM domains attribute value for the given context.
     * @param cms the conext
     * @return the allowed DKIM domains attribute value
     */
    String getAttributeDkimDomains(CmsObject cms);

    /**
     * Returns the DKIM mail from sitemap attribute value for the given context.
     * @param cms the context
     * @return the mail from sitemap attribute value
     */
    String getAttributeDkimMailFrom(CmsObject cms);

    /**
     * Returns the DKIM mail from sitemap attribute value for the given context and resource.
     * @param cms the context
     * @param resource the resource
     * @return the mail from sitemap attribute value
     */
    String getAttributeDkimMailFrom(CmsObject cms, CmsResource resource);

    /**
     * Returns the DKIM mail host or null if the mail from address is not valid or if a DKIM
     * mail host is not configured at all.
     * @param cms the context
     * @return the DKIM mail host
     */
    CmsMailHost getDkimMailHost(CmsObject cms);

    /**
     * Returns the standard or the DKIM mail host depending on whether DKIM is activated.
     * @param cms the context
     * @param resource the resource
     * @return the mail host
     */
    CmsMailHost getMailHost(CmsObject cms, CmsResource resource);

    /**
     * Returns the standard mail host or null if a standard mail host is not configured.
     * @param cms the context
     * @return the standard mail host
     */
    CmsMailHost getStandardMailHost(CmsObject cms);

    /**
     * Returns whether to use a DKIM mail host in the given context. This is the case
     * if a DKIM mail from address sitemap attribute is set at the (sub-)site where
     * the resource is stored and the attribute's value is not 'none'.
     * @param cms the context
     * @param resource the resource
     * @return whether to use the DKIM mail host in the given context
     */
    boolean useDkimMailHost(CmsObject cms, CmsResource resource);

    /**
     * Returns whether there is a valid list of allowed DKIM domains available.
     * @param cms the context
     * @return whether there is a valid list of allowed DKIM domains available
     */
    boolean validDkimDomains(CmsObject cms);

    /**
     * Returns whether the configured DKIM mail from address has a valid DKIM domain.
     * @param cms the context
     * @return whether the configured DKIM mail from address has a valid DKIM domain
     */
    boolean validDkimMailFrom(CmsObject cms);

    /**
     * Returns whether there is either a valid DKIM mail host or a valid standard mail host available.
     * @param cms the context
     * @param resource the resource
     * @return whether there is either a valid DKIM mail host or a valid standard mail host available
     */
    boolean validMailHost(CmsObject cms, CmsResource resource);
}
