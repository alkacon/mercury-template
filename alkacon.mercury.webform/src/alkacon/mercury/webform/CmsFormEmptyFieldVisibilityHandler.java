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

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.main.CmsException;
import org.opencms.main.CmsLog;
import org.opencms.util.CmsStringUtil;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.content.I_CmsXmlContentVisibilityHandler;
import org.opencms.xml.types.I_CmsXmlContentValue;
import org.opencms.xml.types.I_CmsXmlSchemaType;

import java.util.Locale;

import org.apache.commons.logging.Log;

/**
 * Handler to hide a form field in the editor if its value is empty.
 */
public class CmsFormEmptyFieldVisibilityHandler implements I_CmsXmlContentVisibilityHandler {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsFormEmptyFieldVisibilityHandler.class);

    /**
     * @see org.opencms.xml.content.I_CmsXmlContentVisibilityHandler#isValueVisible(org.opencms.file.CmsObject, org.opencms.xml.types.I_CmsXmlSchemaType, java.lang.String, java.lang.String, org.opencms.file.CmsResource, java.util.Locale)
     */
    public boolean isValueVisible(
        CmsObject cms,
        I_CmsXmlSchemaType value,
        String elementPath,
        String params,
        CmsResource resource,
        Locale contentLocale) {

        if (CmsFormMailSettings.getInstance().useDkimMailHost(cms, resource)) {
            try {
                CmsFile file = cms.readFile(resource);
                CmsXmlContent content = CmsXmlContentFactory.unmarshal(cms, file);
                I_CmsXmlContentValue contentValue = content.getValue(elementPath, contentLocale);
                if ((contentValue != null)
                    && CmsStringUtil.isNotEmptyOrWhitespaceOnly(contentValue.getStringValue(cms))) {
                    return true;
                }
            } catch (CmsException e) {
                LOG.error(e.getLocalizedMessage(), e);
            }
            return false;
        } else {
            return true;
        }
    }
}
