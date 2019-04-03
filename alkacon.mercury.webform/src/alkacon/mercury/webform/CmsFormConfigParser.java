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

import static alkacon.mercury.webform.CmsFormContentUtil.getContentStringValue;

import org.opencms.file.CmsObject;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;
import org.opencms.xml.I_CmsXmlDocument;

import java.util.Locale;
import java.util.Map;

public class CmsFormConfigParser {

    private Map<String, String> m_dynamicConfig;
    private I_CmsXmlDocument m_xmlConfig;
    private CmsObject m_cms;
    private CmsMacroResolver m_resolver;
    private Locale m_locale;

    public CmsFormConfigParser(
        CmsObject cms,
        I_CmsXmlDocument xmlConfig,
        Locale locale,
        CmsMacroResolver resolver,
        Map<String, String> dynamicConfig) {
        m_cms = cms;
        m_xmlConfig = xmlConfig;
        m_locale = locale;
        m_resolver = resolver;
        m_dynamicConfig = dynamicConfig;
    }

    public String getConfigurationValue(String xpath, String defaultValue) {

        String stringValue = getValueFromDynamicConfig(xpath);
        if (stringValue == null) {
            stringValue = getContentStringValue(m_xmlConfig, m_cms, xpath, m_locale);
        }
        return null == stringValue ? defaultValue : stringValue;
    }

    public String getResolvedConfigurationValue(String xpath, String defaultValue) {

        String stringValue = getValueFromDynamicConfig(xpath);
        if (stringValue == null) {
            stringValue = getContentStringValue(m_xmlConfig, m_cms, xpath, m_locale);
        }
        return getResolvedValue(stringValue, defaultValue);
    }

    /**
     * If the given value is empty, the default value is returned, otherwise the given value is returned and if a macro resolver is given, macros in it will be resolved.<p>
     *
     * @param value the configuration value to check and resolve macros in
     * @param defaultValue the default value to return in case the value is empty
     *
     * @return the checked value
     */
    protected String getResolvedValue(String value, String defaultValue) {

        if (CmsStringUtil.isNotEmpty(value)) {
            return m_resolver != null ? m_resolver.resolveMacros(value) : value;
        }
        return defaultValue;
    }

    /**
     * Returns the value from the dynamic configuration if it is not empty or whitespace only - if so, it returns null.
     * @param key the configuration option to read
     *
     * @return If existing, the (non-whitespace-only) value of the configuration option, otherwise null
     */
    protected String getValueFromDynamicConfig(String key) {

        String value = null;
        if (m_dynamicConfig != null) {
            value = m_dynamicConfig.get(key);
            if ((value != null) && value.trim().isEmpty()) {
                value = null;
            }
        }
        return value;
    }

}
