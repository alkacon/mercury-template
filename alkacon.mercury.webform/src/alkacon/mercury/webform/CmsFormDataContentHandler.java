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

import alkacon.mercury.webform.CmsFormDataBean;
import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsProperty;
import org.opencms.file.CmsPropertyDefinition;
import org.opencms.file.CmsResource;
import org.opencms.main.CmsException;
import org.opencms.xml.content.CmsDefaultXmlContentHandler;
import org.opencms.xml.content.CmsXmlContent;

import java.util.Collections;
import java.util.Date;

/** Extension of the {@link CmsDefaultXmlContentHandler} that takes care of the special title mapping and the expiration date. */
public class CmsFormDataContentHandler extends CmsDefaultXmlContentHandler {

    /**
     * @see org.opencms.xml.content.CmsDefaultXmlContentHandler#prepareForWrite(org.opencms.file.CmsObject, org.opencms.xml.content.CmsXmlContent, org.opencms.file.CmsFile)
     */
    @Override
    public CmsFile prepareForWrite(CmsObject cms, CmsXmlContent content, CmsFile file) throws CmsException {

        file = super.prepareForWrite(cms, content, file);
        CmsFormDataBean formDataBean = new CmsFormDataBean(content);

        // set the title property
        cms.writePropertyObjects(
            file,
            Collections.singletonList(
                new CmsProperty(CmsPropertyDefinition.PROPERTY_TITLE, formDataBean.getTitleProperty(), null)));

        // adjust the expiration date
        long currentExpirationDate = file.getDateExpired();
        if (formDataBean.isCancelled()) {
            long now = (new Date()).getTime();
            if (currentExpirationDate > now) {
                file.setDateExpired(now);
            }
        } else {
            if (currentExpirationDate != CmsResource.DATE_EXPIRED_DEFAULT) {
                file.setDateExpired(CmsResource.DATE_EXPIRED_DEFAULT);
            }
        }
        return file;
    }

}
