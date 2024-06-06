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

import org.opencms.ade.configuration.CmsADEConfigData;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.mail.CmsMailHost;
import org.opencms.mail.CmsMailSettings;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;

/**
 * Methods for DKIM mail settings.
 */
public abstract class A_CmsDkimMailSettings implements I_CmsDkimMailSettings {

    /** Sitemap attribute value that denotes to use the default sender address configured in opencms-system.xml. */
    public static final String SITEMAP_ATTRVALUE_DKIM_MAILFROM_DEFAULT = "default";

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#getMailHost(org.opencms.file.CmsObject, org.opencms.file.CmsResource)
     */
    public CmsMailHost getMailHost(CmsObject cms, CmsResource resource) {

        if (useDkimMailHost(cms, resource)) {
            return getDkimMailHost(cms);
        } else {
            return getStandardMailHost(cms);
        }
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#useDkimMailHost(org.opencms.file.CmsObject, org.opencms.file.CmsResource)
     */
    public boolean useDkimMailHost(CmsObject cms, CmsResource resource) {

        String mailFromDkim = getAttributeDkimMailFrom(cms, resource);
        return CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromDkim) && !mailFromDkim.equals("none");
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#validDkimDomains(org.opencms.file.CmsObject)
     */
    public boolean validDkimDomains(CmsObject cms) {

        return CmsStringUtil.isNotEmptyOrWhitespaceOnly(getAttributeDkimDomains(cms));
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#validDkimMailFrom(org.opencms.file.CmsObject)
     */
    public boolean validDkimMailFrom(CmsObject cms) {

        boolean valid = false;
        String mailFromDkim = getAttributeDkimMailFrom(cms);
        String dkimDomains = getAttributeDkimDomains(cms);

        if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromDkim)
            && mailFromDkim.equals(SITEMAP_ATTRVALUE_DKIM_MAILFROM_DEFAULT)) {
            return true;
        } else if (CmsStringUtil.isNotEmptyOrWhitespaceOnly(dkimDomains)
            && CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromDkim)) {
                String[] domains = dkimDomains.split("\\s+");
                for (String domain : domains) {
                    if ((domain != null) && mailFromDkim.endsWith(domain)) {
                        valid = true;
                    }
                }
                return valid;
            } else {
                return false;
            }
    }

    /**
     * @see alkacon.mercury.template.mail.I_CmsDkimMailSettings#validMailHost(org.opencms.file.CmsObject, org.opencms.file.CmsResource)
     */
    public boolean validMailHost(CmsObject cms, CmsResource resource) {

        return getMailHost(cms, resource) != null;
    }

    /**
     * Returns the allowed DKIM domains attribute value for the given context.
     * @param cms the conext
     * @param attrDkimDomains DKIM domains attribute name
     * @param attrDkimDomainsFallback DKIM domains fallback attribute name
     * @return the allowed DKIM domains attribute value
     */
    protected String getAttributeDkimDomains(CmsObject cms, String attrDkimDomains, String attrDkimDomainsFallback) {

        CmsADEConfigData sitemapConfig = OpenCms.getADEManager().lookupConfigurationWithCache(
            cms,
            cms.getRequestContext().getRootUri());
        String dkimDomains = sitemapConfig.getAttribute(attrDkimDomains, null);
        String dkimDomainsFallback = sitemapConfig.getAttribute(attrDkimDomainsFallback, null);
        return CmsStringUtil.isNotEmptyOrWhitespaceOnly(dkimDomains) ? dkimDomains : dkimDomainsFallback;
    }

    /**
     * Returns the DKIM mail from sitemap attribute value for the given context and resource.
     * @param cms the context
     * @param resource the resource
     * @param attrMailFromDkim mailfrom DKIM attribute name
     * @param attrMailFromDkimFallback fallback mailfrom DKIM attribute name
     * @return the mail from sitemap attribute value
     */
    protected String getAttributeMailFromDkim(
        CmsObject cms,
        CmsResource resource,
        String attrMailFromDkim,
        String attrMailFromDkimFallback) {

        CmsADEConfigData sitemapConfig = OpenCms.getADEManager().lookupConfigurationWithCache(
            cms,
            resource.getRootPath());
        String mailFromDkim = sitemapConfig.getAttribute(attrMailFromDkim, null);
        String mailFromDkimFallback = sitemapConfig.getAttribute(attrMailFromDkimFallback, null);
        return CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromDkim) ? mailFromDkim : mailFromDkimFallback;
    }

    /**
     * Returns the DKIM mail from sitemap attribute value for the given context.
     * @param cms the context
     * @param attrMailFromDkim mailfrom DKIM attribute name
     * @param attrMailFromDkimFallback fallback mailfrom DKIM attribute name
     * @return the mail from sitemap attribute value
     */
    protected String getAttributeMailFromDkim(CmsObject cms, String attrMailFromDkim, String attrMailFromDkimFallback) {

        CmsADEConfigData sitemapConfig = OpenCms.getADEManager().lookupConfigurationWithCache(
            cms,
            cms.getRequestContext().getRootUri());
        String mailFromDkim = sitemapConfig.getAttribute(attrMailFromDkim, null);
        String mailFromDkimFallback = sitemapConfig.getAttribute(attrMailFromDkimFallback, null);
        return CmsStringUtil.isNotEmptyOrWhitespaceOnly(mailFromDkim) ? mailFromDkim : mailFromDkimFallback;
    }

    /**
     * Returns the DKIM mail host or null if the mail from address is not valid or if a DKIM
     * mail host is not configured at all.
     * @param cms the context
     * @param mailhostDkim the name of the DKIM mail host
     * @param mailhostDkimFallback the name of the fallback DKIM mail host
     * @return the DKIM mail host
     */
    protected CmsMailHost getDkimMailHost(CmsObject cms, String mailhostDkim, String mailhostDkimFallback) {

        if (!validDkimMailFrom(cms)) {
            return null;
        }
        CmsMailSettings mailSettings = OpenCms.getSystemInfo().getMailSettings();
        CmsMailHost mailHost = mailSettings.getMailHost(mailhostDkim);
        if (mailHost == null) {
            mailHost = mailSettings.getMailHost(mailhostDkimFallback);
        }
        return mailHost;
    }

    /**
     * Returns the standard mail host or null if a standard mail host is not configured.
     * @param cms the context
     * @param mailhost the name of the standard mail host
     * @return the standard mail host
     */
    protected CmsMailHost getStandardMailHost(CmsObject cms, String mailhost) {

        CmsMailSettings mailSettings = OpenCms.getSystemInfo().getMailSettings();
        CmsMailHost mailHost = mailSettings.getMailHost(mailhost);
        if (mailHost == null) {
            mailHost = mailSettings.getDefaultMailHost();
        }
        return mailHost;
    }
}
