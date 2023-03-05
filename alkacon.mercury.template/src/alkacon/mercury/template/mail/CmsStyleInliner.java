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

package alkacon.mercury.template.mail;

import org.opencms.main.CmsLog;

import java.io.IOException;
import java.io.Reader;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.commons.logging.Log;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.jsoup.select.Selector.SelectorParseException;
import org.w3c.css.sac.InputSource;
import org.w3c.dom.css.CSSRule;
import org.w3c.dom.css.CSSRuleList;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSStyleRule;
import org.w3c.dom.css.CSSStyleSheet;

import com.steadystate.css.parser.CSSOMParser;
import com.steadystate.css.parser.SACParserCSS3;

/** Utility class to inline CSS styles into HTML. */
public class CmsStyleInliner {

    /** The log object for this class. */
    private static final Log LOG = CmsLog.getLog(CmsStyleInliner.class);

    /** HTML attribute "style". */
    private static final String STYLE_ATTR = "style";
    /** HTML attribute "class". */
    private static final String CLASS_ATTR = "class";

    /**
     * Inlines the provided styles in the given HTML and returns the resulting HTML.
     *
     * @param html the HTML to inline styles for.
     * @param css reader for the styles to inline.
     * @param removeClasses flag, indicating if class attribures should be removed after inlining styles.
     *
     * @return the HTML with styles inlined.
     *
     * @throws IOException
     */
    public static String inlineStyles(String html, Reader css, boolean removeClasses) throws IOException {

        Document document = Jsoup.parse(html);
        CSSOMParser parser = new CSSOMParser(new SACParserCSS3());
        InputSource source = new InputSource(css);
        CSSStyleSheet stylesheet = parser.parseStyleSheet(source, null, null);

        CSSRuleList ruleList = stylesheet.getCssRules();
        Map<Element, Map<String, String>> allElementsStyles = new HashMap<>();
        for (int ruleIndex = 0; ruleIndex < ruleList.getLength(); ruleIndex++) {
            CSSRule item = ruleList.item(ruleIndex);
            if (item instanceof CSSStyleRule) {
                CSSStyleRule styleRule = (CSSStyleRule)item;
                String cssSelector = styleRule.getSelectorText();
                try {
                    Elements elements = document.select(cssSelector);
                    for (Element element : elements) {
                        Map<String, String> elementStyles = allElementsStyles.computeIfAbsent(
                            element,
                            k -> new LinkedHashMap<>());
                        CSSStyleDeclaration style = styleRule.getStyle();
                        for (int propertyIndex = 0; propertyIndex < style.getLength(); propertyIndex++) {
                            String propertyName = style.item(propertyIndex);
                            String propertyValue = style.getPropertyValue(propertyName);
                            elementStyles.put(propertyName, propertyValue);
                        }
                    }
                } catch (SelectorParseException e) {
                    if (LOG.isInfoEnabled()) {
                        String errorMessage = "CSS selector "
                            + styleRule.getSelectorText()
                            + " cannot be inlined and thus is ignored.";
                        if (LOG.isDebugEnabled()) {
                            LOG.debug(errorMessage, e);
                        } else {
                            LOG.info(errorMessage);
                        }
                    }
                }
            }
        }

        for (Map.Entry<Element, Map<String, String>> elementEntry : allElementsStyles.entrySet()) {
            Element element = elementEntry.getKey();
            StringBuilder builder = new StringBuilder();
            for (Map.Entry<String, String> styleEntry : elementEntry.getValue().entrySet()) {
                builder.append(styleEntry.getKey()).append(":").append(styleEntry.getValue()).append(";");
            }
            builder.append(element.attr(STYLE_ATTR));
            element.attr(STYLE_ATTR, builder.toString());
            if (removeClasses) {
                element.removeAttr(CLASS_ATTR);
            }
        }

        document.outputSettings().prettyPrint(true);
        document.outputSettings().indentAmount(0);
        return document.html();
    }
}
