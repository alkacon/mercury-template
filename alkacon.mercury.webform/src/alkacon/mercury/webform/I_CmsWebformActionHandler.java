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

import alkacon.mercury.webform.CmsFormHandler;
import org.opencms.file.CmsObject;

/**
 * Interface to execute any action after the webform was sent.<p>
 */
public interface I_CmsWebformActionHandler {

    /**
     * Runs the action after the web form was sent.<p>
     *
     * @param cmsObject the current users context
     * @param formHandler the initialized web form handler
     *
     */
    void afterWebformAction(CmsObject cmsObject, CmsFormHandler formHandler);

    /**
     * Runs the action before the form is sent.<p>
     *
     * Should return <code>null</code> if the performed action was successful.
     * In error cases the returned String will be used as redirect target.<p>
     *
     * @param cmsObject the current users context
     * @param formHandler the initialized web form handler
     *
     * @return a link target URI inside OpenCms if an error occurred or <code>null</code> on success
     */
    String beforeWebformAction(CmsObject cmsObject, CmsFormHandler formHandler);
}
