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

package alkacon.mercury.webform.captcha;

import org.opencms.jsp.CmsJspActionElement;
import org.opencms.main.CmsLog;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.jsp.PageContext;

import org.apache.commons.logging.Log;

/**
 * Class that gives access to a concurrent captcha token store
 * on the application context level.
 */
public class CmsCaptchaStore {

    /** Name of the captcha store attribute */
    public static final String ATTRIBUTE_CAPTCHASTORE = CmsCaptchaStore.class.getName();

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCaptchaStore.class);

    /** The JSP context. */
    CmsJspActionElement m_jspActionElement;

    /**
     * Creates a new captcha store.
     * <p>
     *
     * @param jsp The JSP context
     */
    public CmsCaptchaStore(CmsJspActionElement jsp) {

        m_jspActionElement = jsp;
    }

    /**
     * Whether a valid captcha token is stored for a given token ID.
     * <p>
     *
     * @param tokenId The token ID.
     * @return Whether a captcha token is available.
     */
    public boolean contains(String tokenId) {

        return getStore().containsKey(tokenId) && getStore().get(tokenId).isValid();
    }

    /**
     * Returns the stored captcha token for a given token ID if valid, null otherwise.
     * Silently removes all invalid tokens from the store.
     * <p>
     *
     * @param tokenId The token ID
     * @return The stored captcha token.
     */
    public CmsCaptchaToken get(String tokenId) {

        clean();
        if (!contains(tokenId)) {
            return null;
        }
        return getStore().get(tokenId);
    }

    /**
     * For a given token ID, returns whether the associated captcha phrase was
     * evaluated successfully.
     * <p>
     *
     * @param tokenId the token ID
     * @return Whether the captcha phrase was evaluated successfully
     */
    public boolean isPhraseValid(String tokenId) {

        CmsCaptchaToken captchaToken = get(tokenId);
        return (captchaToken != null) && captchaToken.isPhraseValid();
    }

    /**
     * Adds a captcha token for a given token ID to the store.
     * <p>
     *
     * @param tokenId The token ID
     * @param captchaToken The captcha token
     */
    public void put(String tokenId, CmsCaptchaToken captchaToken) {

        getStore().put(tokenId, captchaToken);
    }

    /**
     * Removes a captcha token for a given token ID.
     * <p>
     *
     * @param tokenId The token ID of the captcha token to remove
     */
    public void remove(String tokenId) {

        getStore().remove(tokenId);
    }

    /**
     * For a given token ID, flags the associated captcha token as successfully evaluated.
     * <p>
     *
     * @param tokenId the token ID
     */
    public void setPhraseValid(String tokenId) {

        CmsCaptchaToken captchaToken = get(tokenId);
        if (captchaToken != null) {
            captchaToken.setPhraseValid();
        }
    }

    /**
     * Returns the size of this store.
     * <p>
     *
     * @return The size of the store
     */
    public int size() {

        return getStore().size();
    }

    /**
     * Removes all invalid tokens from the store.
     * <p>
     *
     */
    private void clean() {

        getStore().entrySet().removeIf(entry -> !entry.getValue().isValid());
    }

    /**
     * Returns the internal captcha token store with lazy initialization.
     * <p>
     *
     * @return The concurrent hash map storing the captcha tokens.
     */
    @SuppressWarnings("unchecked")
    private synchronized Map<String, CmsCaptchaToken> getStore() {

        PageContext context = m_jspActionElement.getJspContext();
        if (context.getAttribute(ATTRIBUTE_CAPTCHASTORE, PageContext.APPLICATION_SCOPE) == null) {
            context.setAttribute(
                ATTRIBUTE_CAPTCHASTORE,
                new ConcurrentHashMap<String, CmsCaptchaToken>(),
                PageContext.APPLICATION_SCOPE);
        }
        return (Map<String, CmsCaptchaToken>)context.getAttribute(
            ATTRIBUTE_CAPTCHASTORE,
            PageContext.APPLICATION_SCOPE);
    }
}
