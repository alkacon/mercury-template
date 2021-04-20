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

import java.awt.image.BufferedImage;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Date;

import org.apache.commons.logging.Log;

/**
 * Class representing a captcha token.
 */
public class CmsCaptchaToken {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCaptchaToken.class);

    /** The token validity time in seconds. */
    static final long VALIDITY = 60 * 15;

    /** The captcha image belonging to this token. */
    BufferedImage m_image;

    /** The date when this token expires. */
    Date m_expiresAt;

    /**
     * Creates a new captcha token.
     * <p>
     *
     * @param image The captcha image
     */
    public CmsCaptchaToken(BufferedImage image) {

        m_image = image;
        setExpiresAt();
    }

    /**
     * Returns the expiration date.
     * <p>
     *
     * @return The expiration date
     */
    public Date getExpiresAt() {

        return m_expiresAt;
    }

    /**
     * Returns the captcha image attached to this token.
     * <p>
     *
     * @return The captcha image
     */
    public BufferedImage getImage() {

        return m_image;
    }

    /**
     * Whether this token is still valid.
     * <p>
     *
     * @return Whether valid or not
     */
    public boolean isValid() {

        Date now = Date.from(LocalDateTime.now().atZone(ZoneId.systemDefault()).toInstant());
        LOG.info("Comparing actual date " + now + " with expiration date " + m_expiresAt + ".");
        return now.before(m_expiresAt);
    }

    /**
     * Sets the expiration date of this token in an immutable way.
     * <p>
     *
     */
    public void setExpiresAt() {

        if (m_expiresAt != null) {
            return;
        }
        LocalDateTime localDateTime = LocalDateTime.now().plus(Duration.of(VALIDITY, ChronoUnit.SECONDS));
        m_expiresAt = Date.from(localDateTime.atZone(ZoneId.systemDefault()).toInstant());
        LOG.info("Set immutable expiration date to " + m_expiresAt + ".");
    }
}
