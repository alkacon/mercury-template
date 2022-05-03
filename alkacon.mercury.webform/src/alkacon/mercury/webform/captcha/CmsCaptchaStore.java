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

import org.opencms.main.CmsLog;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;

/**
 * Class that gives access to a concurrent captcha token store.
 */
public class CmsCaptchaStore {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCaptchaStore.class);

    /** The token store. */
    private static final Map<String, CmsCaptchaToken> STORE = new HashMap<String, CmsCaptchaToken>();

    /**
     * Whether a valid captcha token is stored for a given token ID.
     * <p>
     *
     * @param tokenId The token ID.
     * @return Whether a captcha token is available.
     */
    public static synchronized boolean contains(String tokenId) {

        LOG.debug(tokenId + ": Store contains key " + STORE.containsKey(tokenId));
        if (STORE.containsKey(tokenId)) {
            LOG.debug(tokenId + ": Token is valid " + STORE.get(tokenId).isValid());
        }
        return STORE.containsKey(tokenId) && STORE.get(tokenId).isValid();
    }

    /**
     * Returns the stored captcha token for a given token ID if valid, null otherwise.
     * Silently removes all invalid tokens from the store.
     * <p>
     *
     * @param tokenId The token ID
     * @return The stored captcha token.
     */
    public static synchronized CmsCaptchaToken get(String tokenId) {

        if (!contains(tokenId)) {
            LOG.debug(tokenId + ": Token is not stored, returning null.");
            return null;
        }
        clean();
        LOG.debug(tokenId + ": Token is stored.");
        return STORE.get(tokenId);
    }

    /**
     * For a given token ID, returns whether the associated captcha phrase was
     * evaluated successfully.
     * <p>
     *
     * @param tokenId the token ID
     * @return Whether the captcha phrase was evaluated successfully
     */
    public static synchronized boolean isPhraseValid(String tokenId) {

        CmsCaptchaToken captchaToken = get(tokenId);
        if (captchaToken == null) {
            LOG.debug(tokenId + ": Phrase is assumed invalid because token is null.");
        } else {
            LOG.debug(tokenId + ": Phrase is valid " + captchaToken.isPhraseValid());
        }
        return (captchaToken != null) && captchaToken.isPhraseValid();
    }

    /**
     * Adds a captcha token for a given token ID to the store.
     * <p>
     *
     * @param tokenId The token ID
     * @param captchaToken The captcha token
     */
    public static synchronized void put(String tokenId, CmsCaptchaToken captchaToken) {

        if (captchaToken != null) {
            LOG.debug(tokenId + ": Adding token to store.");
        } else {
            LOG.debug(tokenId + ": Adding null token to store.");
        }
        STORE.put(tokenId, captchaToken);
    }

    /**
     * Removes a captcha token for a given token ID.
     * <p>
     *
     * @param tokenId The token ID of the captcha token to remove
     */
    public static synchronized void remove(String tokenId) {

        LOG.debug(tokenId + ": Removing token from store.");
        STORE.remove(tokenId);
    }

    /**
     * For a given token ID, flags the associated captcha token as successfully evaluated.
     * <p>
     *
     * @param tokenId the token ID
     */
    public static synchronized void setPhraseValid(String tokenId) {

        CmsCaptchaToken captchaToken = get(tokenId);
        if (captchaToken != null) {
            LOG.debug(tokenId + ": Set phrase valid.");
            captchaToken.setPhraseValid();
        } else {
            LOG.debug(tokenId + ": Trying to set phrase valid to a null token.");
        }
    }

    /**
     * Removes all invalid tokens from the store.
     * <p>
     *
     */
    private static synchronized void clean() {

        LOG.debug("Stored token IDs before cleaning: " + STORE.keySet() + ", size is " + STORE.size());
        STORE.entrySet().removeIf(entry -> !entry.getValue().isValid());
        LOG.debug("Stored token IDs after cleaning: " + STORE.keySet() + ", size is " + STORE.size());
    }
}
