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

package alkacon.mercury.template.content;

import org.opencms.ade.configuration.CmsADEConfigData;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsResource;
import org.opencms.i18n.CmsMessages;
import org.opencms.json.JSONArray;
import org.opencms.json.JSONException;
import org.opencms.json.JSONObject;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsStringUtil;
import org.opencms.widgets.CmsSelectWidget;
import org.opencms.widgets.CmsSelectWidgetOption;
import org.opencms.widgets.I_CmsWidget;
import org.opencms.xml.types.A_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.apache.commons.logging.Log;

/**
 * Simple widget to select a type for the organization.<p>
 *
 * The widget can be configured as sitemap attribute "OrgTypes" like this:.<p>
 *
 * [{ type: "standard", label: "Standard", default: true }, { type: "staff", label: "Staff", default: false }]
 */
public class CmsOrgTypeSelectWidget extends CmsSelectWidget {

    /** The sitemap attribute key to define the organization types. */
    public static final String ATTRIBUTE_ORGTYPES = "OrgTypes";

    /** The JSON Key for organization default. */
    public static final String JSON_KEY_DEFAULT = "default";

    /** The JSON Key for organization label. */
    public static final String JSON_KEY_LABEL = "label";

    /** The JSON Key for organization type. */
    public static final String JSON_KEY_TYPE = "type";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsOrgTypeSelectWidget.class);

    /**
     * Empty constructor.<p>
     */
    public CmsOrgTypeSelectWidget() {

        super();
    }

    /**
     * Creates a ou widget with the specified select options.<p>
     *
     * @param configuration the configuration (possible options) for the select box
     */
    public CmsOrgTypeSelectWidget(String configuration) {

        super(configuration);
    }

    /**
     * @see org.opencms.widgets.A_CmsSelectWidget#getConfiguration(org.opencms.file.CmsObject, org.opencms.xml.types.A_CmsXmlContentValue, org.opencms.i18n.CmsMessages, org.opencms.file.CmsResource, java.util.Locale)
     */
    @Override
    public String getConfiguration(
        CmsObject cms,
        A_CmsXmlContentValue schemaType,
        CmsMessages messages,
        CmsResource resource,
        Locale contentLocale) {

        CmsDummyWidgetDialog widgetDialog = new CmsDummyWidgetDialog(messages.getLocale(), messages);
        widgetDialog.setResource(resource);
        CmsADEConfigData config = OpenCms.getADEManager().lookupConfigurationWithCache(cms, resource.getRootPath());
        List<CmsSelectWidgetOption> options = generateSelectOptions(cms, config);
        String result = CmsSelectWidgetOption.createConfigurationString(options);
        return result;
    }

    /**
     * @see org.opencms.widgets.I_CmsWidget#newInstance()
     */
    @Override
    public I_CmsWidget newInstance() {

        return new CmsOrgTypeSelectWidget();
    }

    /**
     * Generates the select options.<p>
     *
     * @param cms the current context.
     * @param config the configuration for the current sitemap.
     * @return the select options.
     *
     */
    protected List<CmsSelectWidgetOption> generateSelectOptions(CmsObject cms, CmsADEConfigData config) {

        List<CmsSelectWidgetOption> options = new ArrayList<>();

        // add empty option with select text
        options.add(
            new CmsSelectWidgetOption(
                "",
                false,
                Messages.get().getBundle(OpenCms.getWorkplaceManager().getWorkplaceLocale(cms)).key(
                    Messages.GUI_ORGANIZATION_SELECT_PLEASE_SELECT_0)));

        if ((config != null) && CmsStringUtil.isNotEmpty(config.getAttribute(ATTRIBUTE_ORGTYPES, ""))) {
            // found configuration, create options
            try {
                JSONArray jsonOrgTypes = new JSONArray(config.getAttribute(ATTRIBUTE_ORGTYPES, ""));
                for (int i = 0; i < jsonOrgTypes.length(); i++) {
                    JSONObject jsonOrgType = jsonOrgTypes.getJSONObject(i);
                    String label = jsonOrgType.getString(JSON_KEY_LABEL);
                    String type = jsonOrgType.getString(JSON_KEY_TYPE);
                    boolean isDefault = jsonOrgType.getBoolean(JSON_KEY_DEFAULT);
                    options.add(new CmsSelectWidgetOption(type, isDefault, label));
                }
            } catch (JSONException e) {
                // error parsing the JSON
            }
        } else {
            // no configuration found, create standard & staff type options
            options.add(
                new CmsSelectWidgetOption(
                    "standard",
                    true,
                    Messages.get().getBundle(OpenCms.getWorkplaceManager().getWorkplaceLocale(cms)).key(
                        Messages.GUI_ORGANIZATION_SELECT_TYPE_STANDARD_0)));
            options.add(
                new CmsSelectWidgetOption(
                    "staff",
                    false,
                    Messages.get().getBundle(OpenCms.getWorkplaceManager().getWorkplaceLocale(cms)).key(
                        Messages.GUI_ORGANIZATION_SELECT_TYPE_STAFF_0)));
            LOG.debug("No organization types configured as sitemap attibute.");
        }

        return options;

    }

}
