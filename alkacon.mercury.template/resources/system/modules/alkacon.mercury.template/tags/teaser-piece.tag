<%@ tag pageEncoding="UTF-8"
    display-name="teaser-piece"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a list teaser with piece formatting."%>


<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' selectors to add to the generated teaser tag." %>

<%@ attribute name="teaserClass" type="java.lang.String" required="false"
    description="Main CSS class used to identify the generated element. By default this is 'teaser'." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attributes to add to the generated div surrounding section." %>

<%@ attribute name="pieceLayout" type="java.lang.Integer" required="false"
    description="The layout option to generate. Valid values are 0 to 9. Default is 6.
    // 0. Heading, Image, Text, Link (full width)
    // 1. Image, Heading, Text, Link (full width)
    // 2. Heading on top, Image left, Text and Link right (separate column)
    // 3. Heading on top, Image right, Text and Link left (separate column)
    // 4. Heading on top, Image left, Text and Link right (floating around image)
    // 5. Heading on top, Image right, Text and Link left (floating around image)
    // 6. Image left, Heading, Text and Link right (separate column)
    // 7. Image right, Heading, Text and Link left (separate column)
    // 8. Image left, Heading, Text and Link right (floating around image)
    // 9. Image right, Heading, Text and Link left (floating around image)
    // 10. Heading, Text, Link, Image (full width)
    // 11. Heading, Text, Image, Link (full width)
    " %>

<%@ attribute name="sizeMobile" type="java.lang.Integer" required="false"
    description="Mobile grid size for the visual. Valid values are 1 to 12. Default is 7." %>

<%@ attribute name="sizeDesktop" type="java.lang.Integer" required="false"
    description="Desktop grid size for the visual if displayed in a column. Valid values are 1 to 12. Default is 4." %>

<%@ attribute name="gridOption" type="java.lang.String" required="false"
    description="The piece grid option to generate.
    By default this will be calculated automatically from 'sizeDesktop' and 'sizeMobile'.
    If provided as attribute, the attribute value will be inserted instead verbatim without any further check.
    Note that if visual and body are not shown in columns, or if one of the columns is empty,
    the pice will fall back to full width and not use the gridOption at all. " %>

<%@ attribute name="intro" type="java.lang.String" required="false"
    description="The into text of the teaser element. HTML in this will be escaped." %>

<%@ attribute name="headline" type="java.lang.String" required="false"
    description="The headline of the teaser element. HTML in this will be escaped." %>

<%@ attribute name="headlinePrefix" type="java.lang.String" required="false"
    description="Prefix for the headline. HTML in this will NOT be escaped." %>

<%@ attribute name="headlineSuffix" type="java.lang.String" required="false"
    description="Suffix for the headline. HTML in this will NOT be escaped." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the teaser element headline. Default is 3." %>

<%@ attribute name="preface" type="java.lang.String" required="false"
    description="The preface of the teaser element. HTML in this will be escaped." %>

<%@ attribute name="paraCaption" type="java.lang.String" required="false"
    description="The first caption of of the teaser element, to use in case a 'preface' is not available.
    This text is combined with 'paraText' and shortened to contain not more chars then controlled by the 'textLength' parameter.
    Also all HTML is stripped from the text. The remaing text will be HTML-escaped." %>

<%@ attribute name="paraText" type="java.lang.String" required="false"
    description="The first text of the teaser element, to use in case a 'preface' is not available.
    This text is combined with 'paraCaption' and shortened to contain not more chars then controlled by the 'textLength' parameter.
    Also all HTML is stripped from the text. The remaing text will be HTML-escaped." %>

<%@ attribute name="textLength" type="java.lang.Integer" required="false"
    description="The maximum length of the teaser text. If no length given, full text will be used.
    If a 'preface' Text is provided, this will not be shortened." %>

<%@ attribute name="link" type="java.lang.Object" required="false"
    description="The link used in the teaser element." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed. Default is 'button'." %>

<%@ attribute name="linkNewWin" type="java.lang.Boolean" required="false"
    description="Controls if links are opened in a new browser window." %>

<%@ attribute name="linkOnHeadline" type="java.lang.Boolean" required="false"
    description="If 'true', the link will be also added to the headline. Default is 'true'." %>

<%@ attribute name="buttonText" type="java.lang.String" required="false"
    description="An optional button label used on the link button, or 'none' which means no link button will be shown.
    HTML in this will be escaped." %>

<%@ attribute name="date" type="org.opencms.jsp.util.CmsJspInstanceDateBean" required="false"
    description="The date shown in the teaser." %>

<%@ attribute name="dateFormat" type="java.lang.String" required="false"
    description="The format for the date, or 'none' which means no date will be shown." %>

<%@ attribute name="dateOnTop" type="java.lang.Boolean" required="false"
    description="If 'true', the date will be displayed on top of the heading, by default it will be displayed on top of the text." %>

<%@ attribute name="preTextMarkup" required="false" type="java.lang.String"
    description="Additional markup shown above the text. HTML in this will NOT be escaped" %>

<%@ attribute name="preGroupMarkup" required="false" type="java.lang.String"
    description="Additional markup before the group. HTML in this will NOT be escaped." %>

<%@ attribute name="cssBody" type="java.lang.String" required="false"
    description="Additional css for the body." %>

<%@ attribute name="groupId" type="java.lang.String" required="false"
    description="The group ID for collecting elements with the same ID to groups in JavaScript. If not set, no group is created." %>

<%@ attribute name="noLinkOnVisual" type="java.lang.Boolean" required="false"
    description="If 'true', no link will be added to the visual." %>

<%@ attribute name="teaserType" type="java.lang.String" required="false"
    description="Type teaser to generate. Valid values are 'teaser-compact', 'teaser-elaborate' and 'teaser-text-tile'." %>

<%@ attribute name="headingInBody" type="java.lang.Boolean" required="false"
    description="If 'true', the heading will be placed inside the body text. This allows for more flexible CSS formatting, but will break the 'piece' structure." %>

<%@ attribute name="markupVisual" required="true" fragment="true"
    description="Markup shown for the visual, usually an image." %>

<%@ attribute name="markupBody" required="false" fragment="true"
    description="Markup shown for teaser body, replaces all default markup generation but grouping will be intact." %>

<%@ attribute name="markupLink" required="false" fragment="true"
    description="Markup shown for button links, replaces all default markup generation but grouping will be intact." %>

<%@ attribute name="piecePreMarkup" type="java.lang.String" required="false"
    description="Markup to add inside the piece before the heading, body and everything else." %>

<%@ attribute name="placeOption" type="java.lang.String" required="false"
    description="Controls if and how the 'placeName' is displayed." %>

<%@ attribute name="placeName" type="java.lang.String" required="false"
    description="The location name to show with the teaser. HTML in this will be escaped." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Controls if advanced direct edit is enabdled.
    Default is 'false' if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="teaserClass"        value="${empty teaserClass ? 'teaser' : teaserClass}" />
<c:set var="pieceLayout"        value="${empty pieceLayout ? 6 : pieceLayout}" />
<c:set var="hsize"              value="${empty hsize ? 3 : hsize}" />
<c:set var="headingInBody"      value="${headingInBody and ((pieceLayout eq 1) or (pieceLayout ge 6))}" />
<c:choose>
    <c:when test="${(fn:contains(teaserType, 'teaser-text-tile') or fn:contains(teaserType, 'teaser-masonry')) and not fn:contains(teaserType, '-var')}">
        <c:set var="addButtonDiv" value="${true}" />
        <c:set var="pieceLayout" value="${1}"/>
        <c:set var="sizeDesktop" value="${12}" />
        <c:set var="sizeMobile" value="${12}" />
        <c:set var="headingInBody" value="${false}" />
    </c:when>
    <c:when test="${fn:contains(teaserType, 'teaser-compact')}">
        <c:set var="hideImage"  value="${true}"/>
    </c:when>
</c:choose>
<c:set var="sizeDesktop"        value="${not empty sizeDesktop ? sizeDesktop : (((pieceLayout ge 1) and (pieceLayout != 10)) ? 4 : 12)}" />
<c:set var="buttonText"         value="${buttonText eq '-' ? null : buttonText}" /><%-- Allows to have a "none" default but still use the value from the content by setting '-' as button text. --%>
<c:set var="showButton"         value="${(buttonText ne 'none') and (linkOption ne 'none')}" />
<c:set var="addButtonDiv"       value="${showButton ? (empty groupId ? addButtonDiv : false) : false}" />
<c:set var="dateOnTop"          value="${empty dateOnTop ? false : dateOnTop}" />
<c:set var="textLength"         value="${empty textLength ? -1 : textLength}" />

<%-- These are currently not configurable, maybe add this later --%>
<c:set var="linkOnHeadline"     value="${empty linkOnHeadline ? true : linkOnHeadline}" />
<c:set var="linkOnText"         value="${true}" />
<c:set var="useButton"          value="${false}" />

<c:if test="${not empty markupBody}">
    <jsp:invoke fragment="markupBody" var="markupBodyOutput" />
</c:if>

<c:choose>
    <c:when test="${not empty preface}">
        <c:set var="pText" value="${preface}" />
    </c:when>
    <c:when test="${empty preface and empty markupBodyOutput}">
        <%-- Set default for preface if not available --%>
        <%-- If markupBodyOutput is available, preface is not shown from body anyway so we can skip this --%>
        <c:if test="${not empty paraText}">
            <c:set var="paraText" value="${fn:trim(cms:stripHtml(paraText))}" />
        </c:if>
        <c:if test="${not empty paraCaption}">
            <c:set var="paraCaption" value="${fn:trim(cms:stripHtml(paraCaption))}" />
        </c:if>
        <c:set var="pText" value="${paraCaption}${not empty paraText and not empty paraCaption ? ' - ' : ''}${paraText}" />
    </c:when>
</c:choose>

<c:choose>
    <c:when test="${placeOption eq 'intro'}">
        <%-- No check for empty placeName here because in this case the intro must be empty if the place name is empty --%>
        <c:set var="intro" value="${placeName}" />
    </c:when>
    <c:when test="${not empty placeName and placeOption eq 'above'}">
        <c:set var="placeAboveMarkup">
            <div class="teaser-place"><m:out value="${placeName}" /></div><%----%>
        </c:set>
    </c:when>
    <c:when test="${not empty placeName and placeOption eq 'prefix'}">
        <c:set var="placeInlineMarkup">
            <span class="teaser-place-inline"><m:out value="${placeName}" /></span><%----%>
        </c:set>
    </c:when>
</c:choose>

<c:if test="${not empty groupId}">
    <c:set var="bodyPreMarkup">
        ${preGroupMarkup}
        ${'<div class=\"type-list-group\" listgroup=\"'}${groupId}${'\">'}
    </c:set>
    <c:set var="bodyPostMarkup">${'</div>'}</c:set>
</c:if>

<c:if test="${not empty headline or not empty intro}">
    <c:set var="linkTitle">
        <m:out value="${intro}" />
        ${not empty intro ? ': ' : ''}
        <m:out value="${headline}" />
    </c:set>
    <c:set var="linkHeadline" value="${linkOnHeadline and not headingInBody and (hsize > 0)}" />
</c:if>

<c:if test="${(not empty date) and date.isSet and (dateFormat ne 'none')}">
    <c:set var="dateMarkup">
        <div class="teaser-date"><%----%>
            <m:instancedate date="${date}" format="${dateFormat}" />
        </div><%----%>
    </c:set>
</c:if>

<c:if test="${empty markupBodyOutput}">
    <c:set var="markupTextOutput">

        <c:if test="${headingInBody}">
            <c:if test="${dateOnTop and not empty dateMarkup}">
                ${dateMarkup}
            </c:if>

            <c:if test="${not empty headline or not empty intro}">
                <m:intro-headline
                    intro="${intro}"
                    headline="${headline}"
                    prefix="${headlinePrefix}"
                    suffix="${headlineSuffix}"
                    level="${hsize}"
                    tabindex="${not linkHeadline}"
                    ade="${ade}" />
            </c:if>
        </c:if>

        <c:if test="${not empty preTextMarkup}">
            ${preTextMarkup}
        </c:if>

        <c:if test="${not dateOnTop and not empty dateMarkup}">
            ${dateMarkup}
        </c:if>

        <c:if test="${not empty placeAboveMarkup}">
            ${placeAboveMarkup}
        </c:if>

        <c:if test="${(not empty pText) and (textLength != 0)}">
            <%-- textLength of -2 outputs the whole text without HTML escaping --%>
            <%-- textLength of < 0 outputs the whole text --%>
            <%-- textLength of 0 completely hides the text --%>
            <%-- textLength of > n outputs the text trimmed down to max n chars --%>
            <c:set var="prefaceInBody" value="${true}" />
            <div class="teaser-text"><%----%>
                <c:if test="${not empty placeInlineMarkup}">
                    ${placeInlineMarkup}
                </c:if>
                <c:choose>
                    <c:when test="${textLength == -2}">
                        ${pText}
                    </c:when>
                    <c:when test="${textLength < 0}">
                        <c:out value="${pText}" />
                    </c:when>
                    <c:otherwise>
                        <c:out value="${cms:trimToSize(pText, textLength)}" />
                    </c:otherwise>
                </c:choose>
            </div><%----%>
        </c:if>

    </c:set>
</c:if>

<m:piece
    cssWrapper="${teaserClass}${' '}${teaserType}${empty cssWrapper ? '' : ' '.concat(cssWrapper)}${headingInBody ? ' hib' : ''}${prefaceInBody ? ' pib' : ''}"
    attrWrapper="${attrWrapper}"
    pieceLayout="${pieceLayout}"
    sizeDesktop="${sizeDesktop}"
    sizeMobile="${sizeMobile}"
    gridOption="${gridOption}"
    inlineLink="${not addButtonDiv}"
    cssBody="${cssBody}"
    piecePreMarkup="${piecePreMarkup}"
    bodyPreMarkup="${bodyPreMarkup}"
    bodyPostMarkup="${bodyPostMarkup}">

    <jsp:attribute name="heading">
        <c:if test="${not headingInBody}">
            <c:if test="${dateOnTop and not empty dateMarkup}">
                ${dateMarkup}
            </c:if>
            <c:if test="${not empty headline or not empty intro}">
                <m:link
                    link="${link}"
                    newWin="${linkNewWin}"
                    test="${linkHeadline}">

                    <m:intro-headline
                        intro="${intro}"
                        headline="${headline}"
                        prefix="${headlinePrefix}"
                        suffix="${headlineSuffix}"
                        level="${hsize}"
                        tabindex="${not linkHeadline}"
                        ade="${ade}" />

                </m:link>
            </c:if>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="visual">
        <c:if test="${not hideImage}">
            <jsp:invoke fragment="markupVisual" var="markupVisualOutput" />
        </c:if>
        <m:link
            link="${link}"
            newWin="${linkNewWin}"
            title="${linkHeadline ? null : linkTitle}"
            attr="${linkHeadline ? 'tabindex=\"-1\"' : null}"
            test="${not empty markupVisualOutput and not noLinkOnVisual}">
            ${markupVisualOutput}
        </m:link>
    </jsp:attribute>

    <jsp:attribute name="text">
        <c:choose>
            <c:when test="${empty markupBodyOutput}">
                <m:link
                    link="${link}"
                    newWin="${linkNewWin}"
                    title="${linkHeadline ? null : linkTitle}"
                    css='uncolored'
                    attr="${linkHeadline ? 'tabindex=\"-1\"' : null}"
                    test="${linkOnText and not empty markupTextOutput}">
                    ${markupTextOutput}
                </m:link>
            </c:when>
            <c:otherwise>
                ${markupBodyOutput}
            </c:otherwise>
        </c:choose>
    </jsp:attribute>

    <jsp:attribute name="link">
        <c:choose>
            <c:when test="${empty markupLink}">
                <c:if test="${showButton and not empty link}">
                    <c:set var="forceText" value="${buttonText}" />
                    <c:if test="${empty forceText}">
                        <c:set var="buttonText">
                            <fmt:setLocale value="${cms.locale}" />
                            <cms:bundle basename="alkacon.mercury.template.messages">
                                <fmt:message key="msg.page.moreLink" />
                            </cms:bundle>
                        </c:set>
                    </c:if>
                    <c:choose>
                        <c:when test="${linkOption eq 'button-full'}">
                            <c:set var="linkCss" value="btn btn-block piece-btn" />
                        </c:when>
                        <c:when test="${linkOption eq 'button-sm'}">
                            <c:set var="linkCss" value="btn btn-sm piece-btn" />
                        </c:when>
                        <c:when test="${linkOption eq 'text'}">
                            <c:set var="linkCss" value="piece-text-link" />
                        </c:when>
                        <c:otherwise>
                            <%-- default is 'button' --%>
                            <c:set var="linkCss" value="btn piece-btn teaser-btn" />
                        </c:otherwise>
                    </c:choose>
                    <m:link
                        link="${link}"
                        newWin="${linkNewWin}"
                        css="${linkCss}"
                        text="${buttonText}"
                        forceText="${forceText}"
                        title="${linkTitle}"
                        noExternalMarker="${true}" />
                </c:if>
            </c:when>
            <c:otherwise>
                <jsp:invoke fragment="markupLink" />
            </c:otherwise>
        </c:choose>
    </jsp:attribute>

</m:piece>

