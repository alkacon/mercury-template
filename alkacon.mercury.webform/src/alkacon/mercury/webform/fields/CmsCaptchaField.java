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
import alkacon.mercury.template.captcha.I_CmsCaptchaProvider;
import alkacon.mercury.webform.CmsFormHandler;
import alkacon.mercury.webform.captcha.CmsCaptchaServiceCache;
import alkacon.mercury.webform.captcha.CmsCaptchaSettings;
import alkacon.mercury.webform.captcha.CmsCaptchaStore;
import alkacon.mercury.webform.captcha.CmsCaptchaToken;

import org.opencms.flex.CmsFlexController;
import org.opencms.i18n.CmsMessages;
import org.opencms.json.JSONException;
import org.opencms.jsp.CmsJspActionElement;
import org.opencms.main.CmsLog;
import org.opencms.util.CmsStringUtil;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import javax.imageio.ImageIO;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;

import com.octo.captcha.CaptchaException;
import com.octo.captcha.service.CaptchaService;
import com.octo.captcha.service.CaptchaServiceException;
import com.octo.captcha.service.image.ImageCaptchaService;
import com.octo.captcha.service.text.TextCaptchaService;

/**
 * Creates captcha images and validates the phrases submitted by a request parameter.<p>
 */
public class CmsCaptchaField extends A_CmsField {

    /** Request parameter name of the captcha phrase. */
    public static final String C_PARAM_CAPTCHA_PHRASE = "captchaphrase";

    /** Request parameter name of the captcha token id. */
    public static final String C_PARAM_CAPTCHA_TOKEN_ID = "captcha_token_id";

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsCaptchaField.class);

    /** HTML field type: captcha image. */
    private static final String TYPE = "captcha";

    /** The settings to render captcha images. */
    private CmsCaptchaSettings m_captchaSettings;

    /**
     * Creates a new captcha field.
     * <p>
     *
     * @param captchaSettings the settings to render captcha images
     * @param fieldLabel the localized label of this field
     * @param fieldValue the submitted value of this field
     */
    public CmsCaptchaField(CmsCaptchaSettings captchaSettings, String fieldLabel, String fieldValue) {

        super();

        m_captchaSettings = captchaSettings;

        setName(C_PARAM_CAPTCHA_PHRASE + m_captchaSettings.getConfigId());
        setValue(fieldValue);
        setLabel(fieldLabel);
        setMandatory(true);
    }

    /**
     * Returns the type of the input field, e.g. "text" or "select".
     * <p>
     *
     * @return the type of the input field
     */
    public static String getStaticType() {

        return TYPE;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#buildHtml(CmsFormHandler, CmsMessages, String, boolean, String)
     */
    @Override
    public String buildHtml(
        CmsFormHandler formHandler,
        CmsMessages messages,
        String errorKey,
        boolean showMandatory,
        String infoKey) {

        StringBuffer captchaHtml = new StringBuffer(256);
        String errorMessage = createStandardErrorMessage(errorKey, messages);

        Map<String, Object> stAttributes = new HashMap<>();
        CmsCaptchaPluginLoader captchaPluginLoader = new CmsCaptchaPluginLoader(formHandler.getRequest());
        I_CmsCaptchaProvider captchaProvider = captchaPluginLoader.loadCaptchaProvider(formHandler.getCmsObject());
        if (captchaProvider != null) {
            String widgetMarkup = captchaProvider.getWidgetMarkup(
                formHandler.getCmsObject(),
                formHandler.getRequest(),
                getName());
            stAttributes.put("captchawidget", widgetMarkup);
        } else {
            CmsCaptchaSettings captchaSettings = getCaptchaSettings();
            String tokenId = formHandler.getParameter(C_PARAM_CAPTCHA_TOKEN_ID);
            if (tokenId.isEmpty()) {
                tokenId = UUID.randomUUID().toString();
            }
            CmsCaptchaStore captchaStore = new CmsCaptchaStore(formHandler);
            String hiddenInput = "<input type=\"hidden\" id=\""
                + C_PARAM_CAPTCHA_TOKEN_ID
                + "\" name=\""
                + C_PARAM_CAPTCHA_TOKEN_ID
                + "\" value=\""
                + tokenId
                + "\">\n";
            captchaHtml.append(hiddenInput);

            if (m_captchaSettings.isMathField()) {
                // this is a math captcha, print the challenge directly
                captchaHtml.append("<div style=\"margin: 0 0 2px 0;\">");
                if (captchaStore.contains(tokenId)) {
                    captchaHtml.append(captchaStore.get(tokenId).getText());
                } else {
                    TextCaptchaService service = (TextCaptchaService)CmsCaptchaServiceCache.getSharedInstance().getCaptchaService(
                        m_captchaSettings,
                        formHandler.getCmsObject());
                    String captchaChallenge = service.getTextChallengeForID(
                        tokenId,
                        formHandler.getCmsObject().getRequestContext().getLocale());
                    captchaHtml.append(captchaChallenge);
                    captchaStore.put(tokenId, new CmsCaptchaToken(captchaChallenge));
                }
                captchaHtml.append("</div>\n");
            } else {
                // image captcha, insert image
                captchaHtml.append("<img id=\"form_captcha_id\" src=\"").append(
                    formHandler.link(
                        "/system/modules/alkacon.mercury.webform/elements/captcha.jsp?"
                            + captchaSettings.toRequestParams(formHandler.getCmsObject())
                            + "&"
                            + C_PARAM_CAPTCHA_TOKEN_ID
                            + "="
                            + tokenId
                            + "#"
                            + System.currentTimeMillis())).append("\" width=\"").append(
                                captchaSettings.getImageWidth()).append("\" height=\"").append(
                                    captchaSettings.getImageHeight()).append("\" alt=\"\"/>").append("\n");
                captchaHtml.append("<br/>\n");
            }

            // set captcha HTML code as additional attribute
            stAttributes.put("captcha", captchaHtml.toString());
            if (captchaStore.isPhraseValid(tokenId)) {
                stAttributes.put("readonly", "readonly");
            }
        }

        return createHtml(formHandler, messages, stAttributes, getType(), null, errorMessage, showMandatory);
    }

    /**
     * Returns the captcha settings of this field.
     * <p>
     *
     * @return the captcha settings of this field
     */
    public CmsCaptchaSettings getCaptchaSettings() {

        return m_captchaSettings;
    }

    /**
     * @see alkacon.mercury.webform.fields.I_CmsField#getType()
     */
    @Override
    public String getType() {

        return TYPE;
    }

    /**
     * Validates the captcha phrase entered by the user.
     * <p>
     *
     * @param formHandler the Cms form handler
     * @param captchaPhrase the captcha phrase to be validate
     * @return true, if the captcha phrase entered by the user is correct, false otherwise
     */
    public boolean validateCaptchaPhrase(CmsFormHandler formHandler, String captchaPhrase) {

        boolean result = false;
        CmsCaptchaPluginLoader captchaPluginLoader = new CmsCaptchaPluginLoader(formHandler.getRequest());
        I_CmsCaptchaProvider captchaProvider = captchaPluginLoader.loadCaptchaProvider(formHandler.getCmsObject());
        if (captchaProvider != null) {
            try {
                result = captchaProvider.verifySolution(formHandler.getCmsObject(), captchaPhrase);
            } catch (IOException | JSONException e) {
                LOG.error("Error when validating the client's captcha solution.", e);
                result = false;
            }
        } else {
            String tokenId = formHandler.getParameter(C_PARAM_CAPTCHA_TOKEN_ID);
            CmsCaptchaStore captchaStore = new CmsCaptchaStore(formHandler);
            if (captchaStore.isPhraseValid(tokenId)) {
                return true;
            }
            CmsCaptchaSettings settings = m_captchaSettings;
            if (CmsStringUtil.isNotEmpty(captchaPhrase)) {
                // try to validate the phrase
                captchaPhrase = captchaPhrase.toLowerCase();
                try {
                    CaptchaService captchaService = CmsCaptchaServiceCache.getSharedInstance().getCaptchaService(
                        settings,
                        formHandler.getCmsObject());
                    if (captchaService != null) {
                        result = captchaService.validateResponseForID(tokenId, captchaPhrase).booleanValue();
                        if (result == false) {
                            captchaStore.remove(tokenId);
                            formHandler.getFormConfiguration().getCaptchaField().setValue("");
                        } else {
                            captchaStore.setPhraseValid(tokenId);
                            formHandler.getFormConfiguration().getCaptchaField().setParameters("readonly");
                        }
                    }
                } catch (CaptchaServiceException cse) {
                    // most often this will be
                    // "com.octo.captcha.service.CaptchaServiceException: Invalid ID, could not validate unexisting or already validated captcha"
                    // in case someone hits the back button and submits again
                    captchaStore.remove(tokenId);
                    formHandler.getFormConfiguration().getCaptchaField().setValue("");
                }
            }
        }
        return result;
    }

    /**
     * Writes a Captcha JPEG image to the servlet response output stream.
     * <p>
     *
     * @param cms an initialized Cms JSP action element
     * @throws IOException if something goes wrong
     */
    public void writeCaptchaImage(CmsJspActionElement cms) throws IOException {

        String tokenId = cms.getRequest().getParameter(C_PARAM_CAPTCHA_TOKEN_ID);
        CmsCaptchaStore captchaStore = new CmsCaptchaStore(cms);
        BufferedImage captchaImage = null;
        if (captchaStore.contains(tokenId)) {
            captchaImage = captchaStore.get(tokenId).getImage();
        } else {
            Locale locale = cms.getRequestContext().getLocale();
            int maxTries = 10;
            do {
                try {
                    maxTries--;
                    captchaImage = ((ImageCaptchaService)CmsCaptchaServiceCache.getSharedInstance().getCaptchaService(
                        m_captchaSettings,
                        cms.getCmsObject())).getImageChallengeForID(tokenId, locale);
                } catch (CaptchaException cex) {
                    // image size is too small, increase dimensions and try it again
                    if (LOG.isInfoEnabled()) {
                        LOG.info(cex);
                        LOG.info(
                            Messages.get().getBundle().key(
                                Messages.LOG_ERR_CAPTCHA_CONFIG_IMAGE_SIZE_2,
                                new Object[] {m_captchaSettings.getPresetPath(), new Integer(maxTries)}));
                    }
                    m_captchaSettings.setImageHeight((int)(m_captchaSettings.getImageHeight() * 1.1));
                    m_captchaSettings.setImageWidth((int)(m_captchaSettings.getImageWidth() * 1.1));
                }
            } while ((captchaImage == null) && (maxTries > 0));
            LOG.info("Creating new captcha token for token ID " + tokenId + ".");
            captchaStore.put(tokenId, new CmsCaptchaToken(captchaImage));
        }

        ServletOutputStream out = null;
        try {
            CmsFlexController controller = CmsFlexController.getController(cms.getRequest());
            HttpServletResponse response = controller.getTopResponse();
            response.setHeader("Cache-Control", "no-store");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            response.setContentType("image/jpeg");

            ByteArrayOutputStream captchaImageOutput = new ByteArrayOutputStream();
            ImageIO.write(captchaImage, "jpg", captchaImageOutput);
            out = cms.getResponse().getOutputStream();
            out.write(captchaImageOutput.toByteArray());
            out.flush();
        } catch (Exception e) {
            if (LOG.isErrorEnabled()) {
                LOG.error(e.getLocalizedMessage(), e);
            }
            cms.getResponse().sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            try {
                if (out != null) {
                    out.close();
                }
            } catch (Throwable t) {
                // intentionally left blank
            }
        }
    }
}
