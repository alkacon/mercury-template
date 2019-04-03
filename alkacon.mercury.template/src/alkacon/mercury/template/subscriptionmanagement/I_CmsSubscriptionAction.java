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

package alkacon.mercury.template.subscriptionmanagement;

import org.opencms.i18n.CmsMessageContainer;

import java.util.List;

/** Interface for subscription actions, mainly providing a method to perform the action. */
public interface I_CmsSubscriptionAction {

    /**
     * Returns a human readable name of the action.
     * @return a human readable name of the action.
     */
    String getName();

    /**
     * Returns the value of the action request parameter that corresponds to the action.
     * @return the value of the action request parameter that corresponds to the action.
     */
    String getParamValue();

    /**
     * Performs the action.
     *
     * @param params the subscription parameters extracted from the current request parameters.
     *
     * @return a list of error messages if something went wrong. An empty list, if no errors occurred.
     */
    List<CmsMessageContainer> perform(CmsSubscriptionParameterHandler params);
}
