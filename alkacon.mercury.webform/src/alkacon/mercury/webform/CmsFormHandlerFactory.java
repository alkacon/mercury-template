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

import org.opencms.i18n.CmsMessages;
import org.opencms.util.CmsStringUtil;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.PageContext;

/**
 * Provides methods to create initialized form handler objects.<p>
 */
public final class CmsFormHandlerFactory {

    /** Context attribute name for the add message attribute. */
    public static final String ATTRIBUTE_ADDMESSAGE = "addMessage";

    /** Context attribute name for the form handler attribute. */
    public static final String ATTRIBUTE_FORMHANDLER = "cmsF";

    /**
     * Hidden constructor, this is a utility class.<p>
     */
    private CmsFormHandlerFactory() {

        // nothing to initialize
    }

    /**
     * Returns a form handler instance.<p>
     *
     * If one of the parameters context, req or res is null, the form handler has to be
     * initialized manually by calling one of the following methods:<p>
     * <ul>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @return a form handler instance
     *
     * @throws Exception if initializing the form message objects fails
     */
    public static CmsFormHandler create(PageContext context, HttpServletRequest req, HttpServletResponse res)
    throws Exception {

        return create(context, req, res, null, null);
    }

    /**
     * Returns a form handler instance.<p>
     *
     * If one of the parameters context, req or res is null, the form handler has to be
     * initialized manually by calling one of the following methods:<p>
     * <ul>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @return a form handler instance
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     *
     * @throws Exception if initializing the form message objects fails
     */
    public static CmsFormHandler create(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String formConfigUri)
    throws Exception {

        return create(context, req, res, null, formConfigUri);
    }

    /**
     * Returns a form handler instance.<p>
     *
     * If one of the parameters context, req or res is null, the form handler has to be
     * initialized manually by calling one of the following methods:<p>
     * <ul>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @return a form handler instance
     * @param clazz the name of the form
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     *
     * @throws Exception if initializing the form message objects fails
     */
    public static CmsFormHandler create(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String clazz,
        String formConfigUri)
    throws Exception {

        return create(context, req, res, clazz, formConfigUri, null);
    }

    /**
     * Returns a form handler instance.<p>
     *
     * If one of the parameters context, req or res is null, the form handler has to be
     * initialized manually by calling one of the following methods:<p>
     * <ul>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @return a form handler instance
     * @param clazz the name of the form
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     *
     * @throws Exception if initializing the form message objects fails
     */
    public static CmsFormHandler create(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String clazz,
        String formConfigUri,
        Map<String, String> dynamicConfig)
    throws Exception {

        return create(context, req, res, clazz, formConfigUri, dynamicConfig, null);
    }

    /**
     * Returns a form handler instance.<p>
     *
     * If one of the parameters context, req or res is null, the form handler has to be
     * initialized manually by calling one of the following methods:<p>
     * <ul>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse)}</li>
     * <li>{@link CmsFormHandler#init(PageContext, HttpServletRequest, HttpServletResponse, String)}</li>
     * </ul>
     *
     * @param context the JSP page context object
     * @param req the JSP request
     * @param res the JSP response
     * @return a form handler instance
     * @param clazz the name of the form
     * @param formConfigUri URI of the form configuration file, if not provided, current URI is used for configuration
     * @param dynamicConfig map of configurations that can overwrite the configuration from the configuration file
     * @param extraConfig map of additional configuration values to be accessed in the string template.
     *
     * @throws Exception if initializing the form message objects fails
     */
    public static CmsFormHandler create(
        PageContext context,
        HttpServletRequest req,
        HttpServletResponse res,
        String clazz,
        String formConfigUri,
        Map<String, String> dynamicConfig,
        Map<String, String> extraConfig)
    throws Exception {

        CmsFormHandler formHandler = null;
        CmsFormHandler formHandlerFromContext = null;
        // check if there is a form handler instance in the page context, necessary for the survey module
        if (context != null) {
            formHandlerFromContext = (CmsFormHandler)context.getAttribute(ATTRIBUTE_FORMHANDLER);
        }
        if (formHandlerFromContext == null) {
            // no handler found in page context
            if (CmsStringUtil.isEmptyOrWhitespaceOnly(clazz)) {
                // no specific class name specified, create default form handler
                formHandler = new CmsFormHandler();
            } else {
                // create instance of specified form handler class name
                formHandler = (CmsFormHandler)Class.forName(clazz).newInstance();
            }
            if ((context != null) && (req != null) && (res != null)) {
                // initialize the form handler
                formHandler.init(context, req, res, formConfigUri, dynamicConfig, extraConfig);
            }

        } else {
            // use form handler found in page context
            formHandler = formHandlerFromContext;
        }

        // get localized messages from context to create the form
        if ((context != null) && (context.getAttribute(ATTRIBUTE_ADDMESSAGE) != null)) {
            formHandler.addMessages(
                new CmsMessages(
                    (String)context.getAttribute(ATTRIBUTE_ADDMESSAGE),
                    formHandler.getRequestContext().getLocale()));
        }

        return formHandler;
    }

}
