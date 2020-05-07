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

import alkacon.mercury.template.subscriptionmanagement.CmsSubscriptionParameterHandler.SubscriptionAction;

import org.opencms.i18n.CmsMessageContainer;

import java.util.Collections;
import java.util.List;

/** Dummy action, doing nothing. */
public class CmsSubscriptionActionNone implements I_CmsSubscriptionAction {

    /**
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#getName()
     */
    @Override
    public String getName() {

        return SubscriptionAction.NONE.toString();
    }

    /**
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#getParamValue()
     */
    @Override
    public String getParamValue() {

        return String.valueOf(SubscriptionAction.NONE.ordinal());
    }

    /**
     * @see alkacon.mercury.template.subscriptionmanagement.I_CmsSubscriptionAction#perform(CmsSubscriptionParameterHandler)
     */
    @Override
    public List<CmsMessageContainer> perform(CmsSubscriptionParameterHandler params) {

        //do nothing
        return Collections.emptyList();
    }

}
