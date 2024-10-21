/*
 * This program is part of the Alkacon OpenCms Mercury Template.
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

package alkacon.mercury.webform.fields;

import alkacon.mercury.template.captcha.CmsCaptchaPluginLoader;

import org.opencms.ade.configuration.CmsADEConfigData;
import org.opencms.ade.configuration.plugins.CmsSitePlugin;
import org.opencms.ade.configuration.plugins.CmsTemplatePlugin;
import org.opencms.file.CmsObject;
import org.opencms.file.CmsProperty;
import org.opencms.file.CmsPropertyDefinition;
import org.opencms.file.CmsRequestContext;
import org.opencms.file.CmsResource;
import org.opencms.file.CmsResourceFilter;
import org.opencms.i18n.CmsLocaleManager;
import org.opencms.i18n.CmsMessages;
import org.opencms.loader.CmsLoaderException;
import org.opencms.main.CmsException;
import org.opencms.main.CmsIllegalArgumentException;
import org.opencms.main.CmsLog;
import org.opencms.main.OpenCms;
import org.opencms.util.CmsMacroResolver;
import org.opencms.util.CmsStringUtil;
import org.opencms.util.I_CmsMacroResolver;
import org.opencms.widgets.CmsSelectWidget;
import org.opencms.widgets.CmsSelectWidgetOption;
import org.opencms.widgets.I_CmsWidget;
import org.opencms.widgets.I_CmsWidgetDialog;
import org.opencms.widgets.I_CmsWidgetParameter;
import org.opencms.xml.CmsXmlException;
import org.opencms.xml.content.CmsXmlContent;
import org.opencms.xml.content.CmsXmlContentFactory;
import org.opencms.xml.types.A_CmsXmlContentValue;
import org.opencms.xml.types.I_CmsXmlContentValue;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.logging.Log;

/**
 *
 * A select widget that recursively collects all {@link org.opencms.xml.content.CmsXmlContent} resources of a given type
 * (name) under a given path and creates select options that contain the xmlcontents field value specified by a name
 * (xpath) as display String and the xmlcontents path (given) as the value.
 * <p>
 *
 * The configuration String has to be of the following form: <br>
 *
 * <pre>
 *    &quot;[folder=&lt;vfspath&gt;][|displayOptionMacro=&lt;macro&gt;][|resourcetypeName=&lt;typename, typename,...&gt;][|sortMacro=&lt;macro&gt;][|ignoreLocaleMatch=&lt;boolean&gt;][|propertyname=propertyvalue]*
 * </pre>
 *
 * where
 *
 * <pre>
 *    &lt;macro&gt;
 * </pre>
 *
 * is a String containing valid OpenCms macros or xpath expression in the form:
 *
 * <pre>
 * &quot;You are viewing: %(property.Title) &quot;
 * </pre>
 *
 * or
 *
 * <pre>
 * &quot;%(xpath.Firstname) %(xpath.Lastname), Nocakla inc.&quot;
 * </pre>
 *
 * in which the xpath macros will be replaced with {@link org.opencms.xml.A_CmsXmlDocument#getValue(String, Locale)}
 *
 * <pre>
 *    &lt;vfspath&gt;
 * </pre>
 *
 * is a valid resource path to a folder in the VFS where search is started from. You can use the macro "%(currentsite)"
 * to only allow results from the current site (e.g. /sites/default/");
 *
 * <pre>
 *    &lt;resourcetypeName&gt;
 * </pre>
 *
 * is a comma separated list of resource type names as defined in opencms-modules.xml,
 *
 * <pre>
 *    [|ignoreLocaleMatch=&lt;boolean&gt;]
 * </pre>
 *
 * allows to turn off the matching of the editor locale to the locale property of the resource (prio 1 if property
 * found) or the existance of that locale in the XML content (prio 2) and
 *
 *
 * <pre>
 *    [|propertyname = propertyvalue]*
 * </pre>
 *
 * is a arbitrary number of properties value mappings that have to exist on the resources to.
 * <p>
 *
 * <b>This widget has to be used with the datatype <code>OpenCmsVfsFile</code> as it references files.</b>
 * <p>
 *
 *
 * <h3>Please note</h3>
 * <p>
 * <ul>
 * <li>The widget will not offer XML contents that are in a different locale than the current page that displays it.
 * <br>
 * Only if the "matching" XML content has defined a language node for the locale that is set on the page for this widget
 * and the xpath expression to display is not empty, the XML content will be selectable. </li>
 * <li>If sortMacro is missing the values will be sorted alphabetically by their resolved display option (from the
 * displayOptionMacro).</li>
 * </ul>
 * </p>
 *
 * <h3>Localization</h3>
 * <p>
 * Standard localized OpenCms web sites do contain every resource as a sibling in every language folder. Therefore it
 * has to be prevented that this select widget shows every resource of the chosen type as duplicates (siblings) will be
 * selectable. This is case a. <br>
 * In case b this select widget is used to choose contents that are only in one place (shared tree) and exists only one
 * time. In this case a check if the editor locale matches the locale property of the resource to allow for selection
 * would fail. Therefore the localization handling works as follows:
 *
 * <ol>
 * <li><b>Case a: Localized resources with siblings: </b><br/> The resources to allow for selection are filtered. They
 * have to have the property locale set to the current XML content editor locale. This mode is detected if the resources
 * to select have the property "locale" set. </li>
 * <li><b>Case a: Shared resources with no siblings: </b><br/> The resources to allow for selection are not filtered
 * by the locale property. This mode is detected if the resources to select have the property "locale" <b>not</b>set.
 * </li>
 * </ol>
 * </p>
 *
 */
public class CmsSelectWidgetXmlcontentType extends CmsSelectWidget {

    /**
     * A {@link CmsSelectWidgetOption} that is bundled with a corresponding resource that may be selected.
     * <p>
     *
     * @author Achim Westermann
     *
     * @version $Revision: 1.13 $
     *
     * @since 6.1.6
     *
     */
    private static final class CmsResourceSelectWidgetOption extends CmsSelectWidgetOption {

        /** The resource to select. */
        private CmsResource m_resource;

        /**
         *
         * Creates a select option with the resource to select, the given optionText as the display text and no help
         * text that is potentially the default selection (argument isDefault).
         * <p>
         *
         * @param cms
         *            needed to remove the site root from the resource path.
         *
         * @param resource
         *            The resource of this selection.
         *
         * @param isDefault
         *            true, if this option is the default option (preselected.
         *
         * @param optionText
         *            the text to display for this option.
         */
        public CmsResourceSelectWidgetOption(
            CmsObject cms,
            CmsResource resource,
            boolean isDefault,
            String optionText) {

            this(cms, resource, isDefault, optionText, null);

        }

        /**
         * Creates a select option with the resource to select, the given optionText as the display text and the given
         * help text that is potentially the default selection (argument isDefault).
         * <p>
         *
         * @param cms
         *            needed to remove the site root from the resource path.
         *
         * @param resource
         *            The resource of this selection.
         *
         * @param isDefault
         *            true, if this option is the default option (preselected.
         *
         * @param optionText
         *            the text to display for this option.
         *
         * @param helpText
         *            The help text to display.
         */
        public CmsResourceSelectWidgetOption(
            CmsObject cms,
            CmsResource resource,
            boolean isDefault,
            String optionText,
            String helpText) {

            super(cms.getRequestContext().removeSiteRoot(resource.getRootPath()), isDefault, optionText, helpText);
            m_resource = resource;

        }

        /**
         * Returns the resource that is selectable.
         * <p>
         *
         * @return the resource that is selectable.
         */
        CmsResource getResource() {

            return m_resource;
        }

    }

    /**
     * Compares two <code>{@link CmsSelectWidgetXmlcontentType.CmsResourceSelectWidgetOption}</code> instances by any
     * resource related value that may be accessed via a <code>{@link CmsMacroResolver}</code> (except message keys).
     * <p>
     *
     * @author Achim Westermann
     *
     * @version $Revision: 1.13 $
     *
     * @since 6.1.6
     *
     */
    private final class CmsResourceSelectWidgetOptionComparator implements Comparator<CmsResourceSelectWidgetOption> {

        /** The {@link CmsMacroResolver} compatible macro to resolve for comparison. * */
        private String m_comparatorMacro;

        /** To access resource related values with the {@link CmsMacroResolver} for comparison. * */
        private CmsObject m_macroCmsObjectInner;

        /** The {@link CmsMacroResolver} to use for macro resolvation for comparison. * */
        private CmsMacroResolver m_macroResolverInner;

        /**
         * Creates a comparator that will resolve the {@link CmsResource} related values with the given macro
         * expression.
         * <p>
         *
         * @param cms
         *            will be cloned and used for macro - resolvation.
         *
         * @param comparatorMacro
         *            the macro to use to find the resource related strings to compare.
         *
         * @throws CmsException
         *             if sth. goes wrong.
         *
         * @see CmsMacroResolver
         */
        CmsResourceSelectWidgetOptionComparator(CmsObject cms, String comparatorMacro)
        throws CmsException {

            if (CmsStringUtil.isEmpty(comparatorMacro)) {
                m_comparatorMacro = I_CmsMacroResolver.MACRO_DELIMITER
                    + ""
                    + I_CmsMacroResolver.MACRO_START
                    + "opencms.filename)";
            } else {
                m_comparatorMacro = comparatorMacro;
            }
            m_macroCmsObjectInner = OpenCms.initCmsObject(cms);
            m_macroCmsObjectInner.getRequestContext().setSiteRoot("/");
            m_macroResolverInner = new CmsMacroResolver();
            m_macroResolverInner.setCmsObject(m_macroCmsObjectInner);
        }

        /**
         * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
         */
        public int compare(CmsResourceSelectWidgetOption option1, CmsResourceSelectWidgetOption option2) {

            CmsResource resource1 = option1.getResource();
            CmsResource resource2 = option1.getResource();

            String sort1, sort2;

            // fool the macro resolver:
            CmsRequestContext requestContext = m_macroCmsObjectInner.getRequestContext();
            requestContext.setUri(resource1.getRootPath());
            // implant the resource name for macro "%(opencms.filename}):
            m_macroResolverInner.setResourceName(resource1.getName());
            sort1 = m_macroResolverInner.resolveMacros(m_comparatorMacro);
            requestContext.setUri(resource2.getRootPath());
            m_macroResolverInner.setResourceName(resource2.getName());
            sort2 = m_macroResolverInner.resolveMacros(m_comparatorMacro);
            int result = sort1.compareTo(sort2);
            return result;
        }

    }

    /**
     * Configuration parameter to turn off match of editor locale with resource locale or existance of locale in XML
     * content.
     */
    public static final String CONFIGURATION_IGNORE_LOCALE_MATCH = "ignoreLocaleMatch";

    /**
     * Configuration parameter to set flag for special handling of captcha options.
     */
    public static final String CONFIGURATION_IS_CAPTCHA = "isCaptcha";

    /**
     * Configuration parameter for construction of the option display value by a macro containing xpath macros for the
     * xmlcontent.
     */
    public static final String CONFIGURATION_OPTION_DISPLAY_MACRO = "displayOptionMacro";

    /**
     * Configuration parameter for choosing the macro to sort the display options by.
     */
    public static final String CONFIGURATION_OPTION_SITE = "site";

    /**
     * Configuration parameter for choosing the macro to sort the display options by.
     */
    public static final String CONFIGURATION_OPTION_SORT_MACRO = "sortMacro";

    /** Configuration parameter to set the name of the resource types to accept. */
    // TODO: Change the name to plural as a comma separated list is allowed as soon as you have time to check all xsds.
    public static final String CONFIGURATION_RESOURCETYPENAME = "resourcetypeName";

    /** Configuration parameter to set the top folder in the VFS to search for xmlcontent resources. */
    public static final String CONFIGURATION_TOPFOLDER = "folder";

    /** Macro key used to specify current site folder requested. */
    public static final String MACROKEY_CURRENT_SITE = "currentsite";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsSelectWidgetXmlcontentType.class);

    /** Only used for the macro resolver to resolve macros for the collected XML contents. */
    protected CmsObject m_macroCmsObject;

    /** The macro resolver to use. */
    protected CmsMacroResolver m_macroResolver;

    /**
     * The macro to search for the display String of the options in xmlcontent files found below the folder to search
     * in.
     */
    private String m_displayOptionMacro;

    /** A map filled with properties and their values that have to exist on values to display. */
    private Map<String, String> m_filterProperties;

    /**
     * If true it is not tried to match the editor locale with the existence of the locale in the XML content or as
     * locale property of the corresponding resource.
     */
    private boolean m_ignoreLocaleMatching;

    /** If true the options for the captcha presets will be determined. */
    private boolean m_captcha;

    /** The resource folder under which the xmlcontent resources will be searched. */
    private CmsResource m_resourceFolder;

    /** The List of type id of xmlcontent resources to use. */
    private List<Integer> m_resourceTypeIDs;

    /**
     * The macro that describes the {@link CmsResource} - related value to use for sorting of the select widget options.
     */
    private String m_sortMacro;

    /**
     * Creates an unconfigured widget that has to be configured by
     * {@link org.opencms.widgets.A_CmsWidget#setConfiguration(String)} before any html output API call is triggered.
     * <p>
     *
     */
    public CmsSelectWidgetXmlcontentType() {

        this("");
    }

    /**
     * Creates an instance with the given configuration.
     * <p>
     *
     * @param configuration
     *            see the class description for the format.
     */
    public CmsSelectWidgetXmlcontentType(String configuration) {

        super(configuration);
        m_filterProperties = new HashMap<>();

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

        String result = "";
        CmsDummyWidgetDialog widgetDialog = new CmsDummyWidgetDialog(messages.getLocale(), messages);
        List<CmsSelectWidgetOption> options = parseSelectOptions(
            cms,
            resource,
            contentLocale,
            widgetDialog,
            schemaType);
        Iterator<CmsSelectWidgetOption> it = options.iterator();
        int i = 0;
        while (it.hasNext()) {
            CmsSelectWidgetOption option = it.next();
            if (i > 0) {
                result += "|";
            }
            result += option.toString();
            i++;
        }
        return result;
    }

    /**
     * Returns the displayOptionXpathMacro.
     * <p>
     *
     * @return the displayOptionXpathMacro
     */
    public String getDisplayOptionMacro() {

        return m_displayOptionMacro;
    }

    /**
     * Returns the resourceFolder under which xmlcontent resources will be investigated recursively.
     * <p>
     *
     * @return the resourceFolder
     */
    public CmsResource getResourceFolder() {

        return m_resourceFolder;
    }

    /**
     * Returns the list of resource type ids (Integer).
     * <p>
     *
     * @return the List of resource type ids
     */
    public List<Integer> getResourceTypeIDs() {

        return m_resourceTypeIDs;
    }

    /**
     * Returns if the configuration for captcha options should be generated.<p>
     *
     * @return if the configuration for captcha options should be generated
     */
    public boolean isCaptcha() {

        return m_captcha;
    }

    /**
     * Returns the ignoreLocaleMatching.
     * <p>
     *
     * @return the ignoreLocaleMatching
     */
    public boolean isIgnoreLocaleMatching() {

        return m_ignoreLocaleMatching;
    }

    /**
     * @see org.opencms.widgets.CmsSelectWidget#newInstance()
     */
    @Override
    public I_CmsWidget newInstance() {

        return new CmsSelectWidgetXmlcontentType(getConfiguration());
    }

    /**
     * Sets the flag if the configuration for captcha options should be generated.<p>
     *
     * @param captcha if the configuration for captcha options should be generated
     */
    public void setCaptcha(boolean captcha) {

        m_captcha = captcha;
    }

    /**
     * Sets the ignoreLocaleMatching.
     * <p>
     *
     * @param ignoreLocaleMatching
     *            the ignoreLocaleMatching to set
     */
    public void setIgnoreLocaleMatching(boolean ignoreLocaleMatching) {

        m_ignoreLocaleMatching = ignoreLocaleMatching;
    }

    /**
     * Checks if the given XML content resource contains the given locale.
     *
     * @param cms
     *            needed to add
     *
     * @param resource
     *            the XML content resource to check
     *
     * @param dialogContentLocale
     *            the locale to search for
     *
     * @return true if the XML content specified by the resource parameter contains the given resource or false if not
     *         or anything happens (the resource is no xml content,...)
     */
    private boolean containsLocale(CmsObject cms, CmsResource resource, Locale dialogContentLocale) {

        boolean result = false;
        try {
            CmsXmlContent xmlcontent = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
            result = xmlcontent.getLocales().contains(dialogContentLocale);
        } catch (CmsXmlException e) {
            // nop
        } catch (CmsException e) {
            // nop
        }
        return result;
    }

    /**
     * Returns <code>true</code> if given resource matches any configured filter property.
     * If no property configured the default return is also <code>true</code>.<p>
     *
     * @param resource the resource
     * @param cms the cms context
     *
     * @return <code>true</code> if given resource matches any configured filter property
     *
     * @throws CmsException if something goes wrong
     */
    private boolean hasFilterProperty(CmsResource resource, CmsObject cms) throws CmsException {

        boolean result = false;
        Iterator<Map.Entry<String, String>> itFilterProperties;
        Map.Entry<String, String> entry;
        CmsProperty property;
        // filter out unwanted resources - if no filter properties are defined, every
        // resource collected here is ok:
        if (m_filterProperties.size() > 0) {
            itFilterProperties = m_filterProperties.entrySet().iterator();
            while (itFilterProperties.hasNext()) {
                entry = itFilterProperties.next();
                property = cms.readPropertyObject(resource, entry.getKey(), true);
                if (property == CmsProperty.getNullProperty()) {
                    continue;
                } else {
                    // check if value is ok:
                    if (property.getValue().equals(entry.getValue())) {
                        // Ok, resource granted:
                        result = true;
                        break;

                    } else {
                        // Failed, try further filter properties for match:
                    }
                }
            }
        } else {
            // don't filter if no filter props configured
            result = true;
        }

        return result;
    }

    /**
     * Parses the configuration and puts it to the member variables.<p>
     *
     * Only invoked if options were not parsed before in this instance.<p>
     *
     * @param configuration the configuration (with resolved macros).
     * @param cms needed to read the resource folder to use.
     * @param contentResource the edited resource
     * @param param allows to access the resource currently being rendered.
     *
     * @throws CmsIllegalArgumentException if the configuration is invalid.
     */
    private void parseConfigurationInternal(
        String configuration,
        CmsObject cms,
        CmsResource contentResource,
        I_CmsWidgetParameter param) {

        /*
         *  prepare for macro resolvation of property value against the resource currently rendered
         *  implant the uri to the special cms object for resolving macros from the collected xml contents:
         */
        m_macroCmsObject.getRequestContext().setUri(contentResource.getRootPath());
        List<String> mappings = CmsStringUtil.splitAsList(configuration, '|');
        Iterator<String> itMappings = mappings.iterator();
        String mapping;
        String[] keyValue;
        String key;
        String value;
        boolean displayMacroFound = false, sortMacroFound = false, folderFound = false, typeFound = false;
        //   LOG.info("Setting macro %(currentsite) to: " + cms.getRequestContext().getSiteRoot());
        m_macroResolver.addMacro(MACROKEY_CURRENT_SITE, cms.getRequestContext().getSiteRoot());
        while (itMappings.hasNext()) {
            mapping = itMappings.next();
            keyValue = CmsStringUtil.splitAsArray(mapping, '=');
            if (keyValue.length != 2) {
                throw new CmsIllegalArgumentException(
                    Messages.get().container(Messages.ERR_SELECTWIDGET_CONFIGURATION_KEYVALUE_LENGTH_1, mapping));
            }
            key = keyValue[0].trim();
            value = keyValue[1].trim();

            // implant the resource for macro "%(opencms.filename)"
            m_macroResolver.setResourceName(contentResource.getName());
            // check key
            if (CONFIGURATION_OPTION_DISPLAY_MACRO.equals(key)) {
                if (displayMacroFound) {
                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_DUPLICATE_2,
                            key,
                            configuration));
                }

                m_displayOptionMacro = CmsMacroResolver.formatMacro(value);
                displayMacroFound = true;
            } else if (CONFIGURATION_OPTION_SORT_MACRO.equals(key)) {
                if (sortMacroFound) {
                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_DUPLICATE_2,
                            key,
                            configuration));
                }
                m_sortMacro = CmsMacroResolver.formatMacro(value);
                sortMacroFound = true;

            } else if (CONFIGURATION_RESOURCETYPENAME.equals(key)) {
                if (typeFound) {
                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_DUPLICATE_2,
                            key,
                            configuration));
                }
                // check if resource type name is OK
                // if setResourceType will be implemented copy here and invoke that one
                String resType = "n/a";
                try {
                    m_resourceTypeIDs = new LinkedList<>();
                    List<String> types = CmsStringUtil.splitAsList(value, ',');
                    Iterator<String> itTypes = types.iterator();
                    while (itTypes.hasNext()) {
                        resType = itTypes.next();
                        m_resourceTypeIDs.add(
                            new Integer(OpenCms.getResourceManager().getResourceType(resType).getTypeId()));
                    }
                } catch (CmsLoaderException e) {
                    throw new CmsIllegalArgumentException(
                        org.opencms.file.Messages.get().container(
                            org.opencms.file.Messages.ERR_UNKNOWN_RESOURCE_TYPE_1,
                            resType),
                        e);
                }
                typeFound = true;

            } else if (CONFIGURATION_TOPFOLDER.equals(key)) {
                if (folderFound) {
                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_DUPLICATE_2,
                            key,
                            configuration));
                }

                // allow collector path to contain macros relative to the current resource:
                value = m_macroResolver.resolveMacros(value);

                try {
                    CmsRequestContext context = cms.getRequestContext();
                    String oldSiteRoot = context.getSiteRoot();
                    context.setSiteRoot("/");
                    CmsResource resource = cms.readResource(value);
                    context.setSiteRoot(oldSiteRoot);
                    if (resource.isFile()) {
                        throw new CmsIllegalArgumentException(
                            Messages.get().container(
                                Messages.ERR_SELECTWIDGET_CONFIGURATION_RESOURCE_NOFOLDER_2,
                                value,
                                configuration));
                    }
                    m_resourceFolder = resource;
                } catch (CmsException e) {
                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_RESOURCE_INVALID_2,
                            value,
                            configuration),
                        e);
                }

                folderFound = true;

            } else if (CONFIGURATION_IGNORE_LOCALE_MATCH.equals(key)) {
                m_ignoreLocaleMatching = Boolean.valueOf(value).booleanValue();

            } else if (CONFIGURATION_IS_CAPTCHA.equals(key)) {
                m_captcha = Boolean.valueOf(value).booleanValue();

            } else {
                // a property=value definition???

                CmsPropertyDefinition propDef;
                try {
                    propDef = cms.readPropertyDefinition(key);
                } catch (CmsException e) {

                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_UNKNOWN_2,
                            key,
                            getClass().getName()),
                        e);
                }
                if (propDef != null) {
                    // a valid property - value combination to filter resources for:
                    // value is potentially a macro that will be compared to the current xml content
                    // resource!
                    value = m_macroResolver.resolveMacros(value);
                    m_filterProperties.put(key, value);

                } else {

                    throw new CmsIllegalArgumentException(
                        Messages.get().container(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_UNKNOWN_2,
                            key,
                            getClass().getName()));
                }
            }
        }

        // final check wether all has been set
        if (!displayMacroFound) {
            throw new CmsIllegalArgumentException(
                Messages.get().container(
                    Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_MISSING_3,
                    CONFIGURATION_OPTION_DISPLAY_MACRO,
                    configuration,
                    getClass().getName()));
        }
        if (!folderFound) {
            throw new CmsIllegalArgumentException(
                Messages.get().container(
                    Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_MISSING_3,
                    CONFIGURATION_TOPFOLDER,
                    configuration,
                    getClass().getName()));
        }
        if (!typeFound) {
            throw new CmsIllegalArgumentException(
                Messages.get().container(
                    Messages.ERR_SELECTWIDGET_CONFIGURATION_KEY_MISSING_3,
                    CONFIGURATION_RESOURCETYPENAME,
                    configuration,
                    getClass().getName()));
        }
    }

    /**
     * Resolves xpath macros of the form <code>"%(xpath.XPATHEXPRESSION)"</code> by the field value of the XML content
     * denoted by the given resource. <p>
     *
     * File loading and unmarshalling is only done if the given String contains xpath macros.
     * <p>
     *
     * @param cms to access values in the cmsobject.
     *
     * @param resource the resource pointing to an xmlcontent containing the macro values to resolve.
     *
     * @param value the unresolved macro string.
     *
     * @return a String with resolved xpath macros that have been read from the xmlcontent.
     *
     * @throws CmsException if something goes wrong
     */
    private String resolveXpathMacros(CmsObject cms, CmsResource resource, final String value) throws CmsException {

        String work = value;
        StringBuffer result = new StringBuffer();

        String startMacro = new StringBuffer(I_CmsMacroResolver.MACRO_DELIMITER + "").append(
            I_CmsMacroResolver.MACRO_START).append("xpath.").toString();

        int startmacroIndex = work.indexOf(startMacro);
        int stopmacro = 0;
        String xpath;
        if (startmacroIndex != -1) {

            // for the option value we have to unmarshal...
            CmsXmlContent xmlcontent = CmsXmlContentFactory.unmarshal(cms, cms.readFile(resource));
            // we read the locale node of the xmlcontent instance matching the resources
            // locale property (or top level locale).
            Locale locale = CmsLocaleManager.getLocale(
                cms.readPropertyObject(xmlcontent.getFile(), CmsPropertyDefinition.PROPERTY_LOCALE, true).getValue());

            while (startmacroIndex != -1) {
                stopmacro = work.indexOf(I_CmsMacroResolver.MACRO_END);
                if (stopmacro == 0) {
                    // TODO: complain about missing closing macro bracket!
                }

                // first cut the prefix of the macro to put it to the result:
                result.append(work.substring(0, startmacroIndex));
                // now replace the macro:
                xpath = work.substring(startmacroIndex + 8, stopmacro);

                try {
                    result.append(xmlcontent.getValue(xpath, locale).getPlainText(cms));
                } catch (Exception ex) {
                    if (LOG.isErrorEnabled()) {
                        LOG.error(
                            Messages.get().getBundle().key(
                                Messages.LOG_ERR_SELECTWIDGET_XPATH_INVALID_4,
                                new Object[] {
                                    xpath,
                                    locale.toString(),
                                    xmlcontent.getFile().getRootPath(),
                                    ex.getLocalizedMessage()}));
                    }
                }
                // skip over the consumed String of value:
                work = work.substring(stopmacro + 1);

                // take a new start for macro:
                startmacroIndex = work.indexOf(startMacro);
            }
        }
        // append trailing value
        result.append(work);
        return result.toString();

    }

    /**
     * Returns the list of configured select options, parsing the configuration String if required.<p>
     *
     * @param cms the current users OpenCms context.
     * @param contentResource the edited resource
     * @param contentLocale the content locale
     * @param widgetDialog the dialog of this widget.
     * @param param the widget parameter of this dialog.
     *
     * @see org.opencms.widgets.A_CmsSelectWidget#parseSelectOptions(org.opencms.file.CmsObject,
     *      org.opencms.widgets.I_CmsWidgetDialog, org.opencms.widgets.I_CmsWidgetParameter)
     *
     * @return the list of configured select options.
     *
     * @throws CmsIllegalArgumentException if the "folder" property of the configuration does not denote a folder within the VFS.
     */
    protected List<CmsSelectWidgetOption> parseSelectOptions(
        CmsObject cms,
        CmsResource contentResource,
        Locale contentLocale,
        I_CmsWidgetDialog widgetDialog,
        I_CmsWidgetParameter param)
    throws CmsIllegalArgumentException {

        if (contentLocale == null) {
            contentLocale = ((I_CmsXmlContentValue)param).getLocale();
        }

        if (m_macroCmsObject == null) {
            try {
                m_macroCmsObject = OpenCms.initCmsObject(cms);
                m_macroCmsObject.getRequestContext().setSiteRoot("/");
            } catch (CmsException e) {
                // should never happen
                if (LOG.isErrorEnabled()) {
                    LOG.error(
                        Messages.get().getBundle().key(
                            Messages.ERR_SELECTWIDGET_INTERNAL_CONFIGURATION_2,
                            new Object[] {getClass().getName(), getConfiguration()}));
                }
                return Collections.emptyList();

            }
        }
        if (m_macroResolver == null) {
            m_macroResolver = new CmsMacroResolver();
            m_macroResolver.setCmsObject(m_macroCmsObject);
            m_macroResolver.setKeepEmptyMacros(true);
        }

        List<CmsSelectWidgetOption> selectOptions = getSelectOptions();
        if (selectOptions == null) {
            String configuration = getConfiguration();
            if (configuration == null) {
                // workaround: use the default value to parse the options
                configuration = param.getDefault(cms);
            }
            List<CmsResourceSelectWidgetOption> resourceOptions = null;
            try {
                // parse configuration to members
                if (contentResource == null) {
                    contentResource = ((I_CmsXmlContentValue)param).getDocument().getFile();
                }
                parseConfigurationInternal(configuration, cms, contentResource, param);
                if (isCaptcha()) {
                    // special handling for captcha preset options
                    String uriForSiteConfig = null;
                    if (!cms.getRequestContext().getUri().contains("/system/workplace/")
                        && !cms.getRequestContext().getUri().contains(".gwt")) {
                        if (cms.existsResource(cms.getRequestContext().getUri(), CmsResourceFilter.IGNORE_EXPIRATION)) {
                            uriForSiteConfig = cms.getRequestContext().addSiteRoot(cms.getRequestContext().getUri());
                        }
                    }
                    if (uriForSiteConfig == null) {
                        uriForSiteConfig = contentResource.getRootPath();
                    }
                    // get sitemap configuration
                    CmsADEConfigData configData = OpenCms.getADEManager().lookupConfigurationWithCache(
                        cms,
                        uriForSiteConfig);
                    List<CmsSitePlugin> plugins = configData.getSitePlugins();
                    // check plugins
                    for (CmsSitePlugin plugin : plugins) {
                        for (CmsTemplatePlugin templatePlugin : plugin.getPlugins()) {
                            if (templatePlugin.getGroup().equals(CmsCaptchaPluginLoader.PLUGIN_WEBFORM_CAPTCHA)) {
                                // found external captcha plugin, create option containing hint to captcha provider
                                addSelectOption(
                                    new CmsSelectWidgetOption(
                                        "",
                                        false,
                                        widgetDialog.getMessages().key("form.captchapreset.option.useprovider")));
                                selectOptions = getSelectOptions();
                                return selectOptions;
                            }
                        }
                    }
                }

                // build the set of sorted options
                List<CmsResourceSelectWidgetOption> sortOptions = new ArrayList<>();
                CmsResourceSelectWidgetOption option;
                List<CmsResource> resources;
                List<CmsResource> allResources = new LinkedList<>();
                // collect all subresources of resource folder.
                // As a CmsResourceFilter is somewhat limited we have to do several reads
                // for each resourceType we allow:
                int resType;
                Iterator<Integer> itResTypes = m_resourceTypeIDs.iterator();
                while (itResTypes.hasNext()) {
                    resType = (itResTypes.next()).intValue();
                    CmsResourceFilter filter = CmsResourceFilter.ALL.addRequireType(resType);
                    CmsRequestContext context = cms.getRequestContext();
                    String oldSiteroot = context.getSiteRoot();
                    context.setSiteRoot("/");
                    resources = cms.readResources(m_resourceFolder.getRootPath(), filter, true);
                    context.setSiteRoot(oldSiteroot);
                    if (resources.size() == 0) {
                        if (LOG.isErrorEnabled()) {
                            LOG.error(
                                Messages.get().getBundle().key(
                                    Messages.LOG_ERR_SELECTWIDGET_NO_RESOURCES_FOUND_3,
                                    configuration,
                                    m_resourceFolder.getRootPath(),
                                    OpenCms.getResourceManager().getResourceType(resType).getTypeName()));
                        }
                    } else {
                        allResources.addAll(resources);
                    }

                }

                Iterator<CmsResource> itResources = allResources.iterator();
                CmsResource resource;

                String displayName;
                // inner loop vars :
                while (itResources.hasNext()) {

                    resource = itResources.next();
                    // don't make resources selectable that have a different locale than the
                    // we read the locale node of the xmlcontent instance matching the resources
                    // locale property (or top level locale).
                    CmsProperty resourceLocaleProperty = cms.readPropertyObject(
                        resource,
                        CmsPropertyDefinition.PROPERTY_LOCALE,
                        true);
                    Locale resourceLocale = OpenCms.getLocaleManager().getDefaultLocale(cms, cms.getSitePath(resource));

                    // We allow all resources without locale property and only the
                    // resources with locale property that match the current XML content editor locale.
                    if (isIgnoreLocaleMatching()
                        || ((resourceLocaleProperty.isNullProperty() && containsLocale(cms, resource, contentLocale))
                            || contentLocale.equals(resourceLocale))) {
                        // macro resolvation within hasFilterProperty will resolve values to the
                        // current request
                        if (hasFilterProperty(resource, cms)) {

                            // implant the uri to the special cms object for resolving macros from
                            // the collected xml contents:
                            m_macroCmsObject.getRequestContext().setUri(resource.getRootPath());
                            // implant the resource for macro "%(opencms.filename)"
                            m_macroResolver.setResourceName(resource.getName());
                            // implant the messages
                            m_macroResolver.setMessages(widgetDialog.getMessages());
                            // filter out unwanted resources - if no filter properties are defined,
                            // every
                            // resource collected here is ok:
                            displayName = m_macroResolver.resolveMacros(getDisplayOptionMacro());
                            // deal with a bug of the macro resolver: it will return "" if it gets
                            // "%(unknown.thin)":
                            if (CmsStringUtil.isEmptyOrWhitespaceOnly(displayName)) {
                                // it was a "%(xpath.field})" expression only and swallowed by macro
                                // resolver:
                                displayName = resolveXpathMacros(cms, resource, getDisplayOptionMacro());
                            } else {
                                // there was more than one xpath macro: allow further replacements
                                // within partly resolved macro:
                                displayName = resolveXpathMacros(cms, resource, displayName);
                            }
                            // final check:
                            if (CmsStringUtil.isEmpty(displayName)) {
                                displayName = resource.getName();
                            }

                            displayName = resolveXpathMacros(cms, resource, displayName);

                            if (!CmsStringUtil.isEmpty(displayName)) {

                                // now everything required is there:
                                option = new CmsResourceSelectWidgetOption(cms, resource, false, displayName);
                                sortOptions.add(option);
                            }
                        }
                    }
                }
                resourceOptions = new LinkedList<>(sortOptions);
                // sort the found resources according to their file name (without path information)
                Collections.sort(
                    resourceOptions,
                    new CmsResourceSelectWidgetOptionComparator(m_macroCmsObject, m_sortMacro));

            } catch (Exception e) {
                if (LOG.isErrorEnabled()) {
                    LOG.error(
                        Messages.get().getBundle().key(
                            Messages.ERR_SELECTWIDGET_CONFIGURATION_2,
                            getClass(),
                            configuration),
                        e);
                }
            }

            if (resourceOptions == null) {
                resourceOptions = Collections.emptyList();
            }

            Iterator<CmsResourceSelectWidgetOption> it = resourceOptions.iterator();
            while (it.hasNext()) {
                addSelectOption(it.next());
            }
            selectOptions = getSelectOptions();
        }
        return selectOptions;
    }

    /**
     * Returns the list of configured select options, parsing the configuration String if required.<p>
     *
     * @param cms the current users OpenCms context.
     * @param widgetDialog the dialog of this widget.
     * @param param the widget parameter of this dialog.
     *
     * @see org.opencms.widgets.A_CmsSelectWidget#parseSelectOptions(org.opencms.file.CmsObject,
     *      org.opencms.widgets.I_CmsWidgetDialog, org.opencms.widgets.I_CmsWidgetParameter)
     *
     * @return the list of configured select options.
     *
     * @throws CmsIllegalArgumentException if the "folder" property of the configuration does not denote a folder within the VFS.
     */
    @Override
    protected List<CmsSelectWidgetOption> parseSelectOptions(
        CmsObject cms,
        I_CmsWidgetDialog widgetDialog,
        I_CmsWidgetParameter param)
    throws CmsIllegalArgumentException {

        return parseSelectOptions(cms, null, null, widgetDialog, param);
    }

}
