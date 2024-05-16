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

import alkacon.mercury.template.mail.A_CmsDkimMailSettings;

import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.mail.CmsMailHost;

/**
 * Form mail settings.
 */
public class CmsFormMailSettings extends A_CmsDkimMailSettings {

    /** Name of the form DKIM mail host. */
    public static final String MAILHOST_DKIM_FORM = "formDkim";

    /** Name of the fallback DKIM mail host. */
    public static final String MAILHOST_DKIM_FALLBACK = "dkim";

    /** Name of the standard form mail host. */
    public static final String MAILHOST_FORM = "form";

    /** Sitemap attribute to set the DKIM sender address that overwrites all sender addresses in form configurations. */
    public static final String SITEMAP_ATTR_DKIM_MAILFROM = "webform.dkim.mailfrom";

    /** Fallback attribute for SITEMAP_ATTR_DKIM_MAILFROM. */
    public static final String SITEMAP_ATTR_DKIM_MAILFROM_FALLBACK = "dkim.mailfrom";

    /** Sitemp attribute to set the list of allowed DKIM domains. */
    public static final String SITEMAP_ATTR_DKIM_DOMAINS = "webform.dkim.domains";

    /** Fallback attribute for SITEMAP_ATTR_DKIM_DOMAINS. */
    public static final String SITEMAP_ATTR_DKIM_DOMAINS_FALLBACK = "dkim.domains";

    /** The singleton instance of this class. */
    private static CmsFormMailSettings INSTANCE;

    /**
     * Returns the singleton instance of this class.
     * @return the singleton instance of this class
     */
    public static CmsFormMailSettings getInstance() {

        if (INSTANCE == null) {
            INSTANCE = new CmsFormMailSettings();
        }
        return INSTANCE;
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getAttributeDkimDomains(org.opencms.file.CmsObject)
     */
    public String getAttributeDkimDomains(CmsObject cms) {

        return getAttributeDkimDomains(cms, SITEMAP_ATTR_DKIM_DOMAINS, SITEMAP_ATTR_DKIM_DOMAINS_FALLBACK);
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getAttributeDkimMailFrom(org.opencms.file.CmsObject)
     */
    public String getAttributeDkimMailFrom(CmsObject cms) {

        return getAttributeMailFromDkim(cms, SITEMAP_ATTR_DKIM_MAILFROM, SITEMAP_ATTR_DKIM_MAILFROM_FALLBACK);
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getAttributeDkimMailFrom(org.opencms.file.CmsObject, org.opencms.file.CmsResource)
     */
    public String getAttributeDkimMailFrom(CmsObject cms, CmsResource resource) {

        return getAttributeMailFromDkim(cms, resource, SITEMAP_ATTR_DKIM_MAILFROM, SITEMAP_ATTR_DKIM_MAILFROM_FALLBACK);
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getDkimMailHost(org.opencms.file.CmsObject)
     */
    public CmsMailHost getDkimMailHost(CmsObject cms) {

        return getDkimMailHost(cms, MAILHOST_DKIM_FORM, MAILHOST_DKIM_FALLBACK);
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getStandardMailHost(org.opencms.file.CmsObject)
     */
    public CmsMailHost getStandardMailHost(CmsObject cms) {

        return getStandardMailHost(cms, MAILHOST_FORM);
    }
}
