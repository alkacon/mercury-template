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

package alkacon.mercury.template;

import org.opencms.file.CmsFile;
import org.opencms.file.CmsObject;
import org.opencms.main.CmsException;
import org.opencms.xml.content.CmsDefaultXmlContentHandler;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.Locale;

/**
 * Content handler for the Mercury event type.
 *
 * <p>Sets the 'Kind' field to mixed/online/presence depending on which of the VirtualLocation and AddressChoice
 * nested contents exist.
 */
public class CmsEventContentHandler extends CmsDefaultXmlContentHandler {

    /**
     * @see org.opencms.xml.content.CmsDefaultXmlContentHandler#prepareForWrite(org.opencms.file.CmsObject, org.opencms.xml.content.CmsXmlContent, org.opencms.file.CmsFile)
     */
    @Override
    public CmsFile prepareForWrite(CmsObject cms, CmsXmlContent content, CmsFile file) throws CmsException {

        for (Locale locale : content.getLocales()) {
            I_CmsXmlContentValue virtualLocation = content.getValue("VirtualLocation", locale);
            I_CmsXmlContentValue addressChoice = content.getValue("AddressChoice", locale);
            String kind;
            if ((virtualLocation != null) && (addressChoice != null)) {
                kind = "mixed";
            } else if (virtualLocation != null) {
                kind = "online";
            } else if (addressChoice != null) {
                kind = "presence";
            } else {
                kind = "";
            }
            content.getValue("Kind", locale).setStringValue(cms, kind);
        }
        return super.prepareForWrite(cms, content, file);
    }

}
