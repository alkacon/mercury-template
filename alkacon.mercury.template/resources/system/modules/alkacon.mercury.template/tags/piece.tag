<%@ tag pageEncoding="UTF-8"
    display-name="section"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a piece of content." %>


<%@ attribute name="pieceLayout" type="java.lang.Integer" required="true"
    description="The layout option to generate. Valid values are 0 to 9.
    // 0.  Heading, Image, Text, Link (full width)
    // 1.  Image, Heading, Text, Link (full width)
    // 2.  Heading on top, Image left, Text and Link right (separate column)
    // 3.  Heading on top, Image right, Text and Link left (separate column)
    // 4.  Heading on top, Image left, Text and Link right (floating around image)
    // 5.  Heading on top, Image right, Text and Link left (floating around image)
    // 6.  Image left, Heading, Text and Link right (separate column)
    // 7.  Image right, Heading, Text and Link left (separate column)
    // 8.  Image left, Heading, Text and Link right (floating around image)
    // 9.  Image right, Heading, Text and Link left (floating around image)
    // 10. Heading, Text, Link, Image (full width)
    // 11. Heading, Text, Image, Link (full width)
    " %>

<%@ attribute name="sizeMobile" type="java.lang.Integer" required="false"
    description="Mobile grid size for the visual. Valid values are 1 to 12, 0 and 99.
    The special value 0 means 'hide the visual'.
    The special value 99 means 'use the default'
    The default will depend on the desktop size, e.g. for destop 4 this would be mobile 8." %>

<%@ attribute name="sizeDesktop" type="java.lang.Integer" required="false"
    description="Desktop grid size for the visual if displayed in a column. Valid values are 1 to 12, 0 and 99.
    The special value 0 means 'hide the visual'.
    The special value 99 means 'use the default'.
    The default normally is 4." %>

<%@ attribute name="pieceTag" type="java.lang.String" required="false"
    description="The tag to generate. Defaults to 'div' if not provided." %>

<%@ attribute name="pieceClass" type="java.lang.String" required="false"
    description="The class to generate. Defaults to 'piece' if not provided." %>

<%@ attribute name="gridOption" type="java.lang.String" required="false"
    description="The piece grid option to generate.
    By default this will be calculated automatically from 'sizeDesktop' and 'sizeMobile'.
    If provided as attribute, the attribute value will be inserted instead verbatim without any further check.
    Note that if visual and body are not shown in columns, or if one of the columns is empty,
    the pice will fall back to full width and not use the gridOption at all. " %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' selectors to add to the generated piece tag." %>

<%@ attribute name="attrWrapper" type="java.lang.String" required="false"
    description="Attributes to add to the generated piece tag." %>

<%@ attribute name="heading" fragment="true" required="false"
    description="Markup shown for the content piece heading." %>

<%@ attribute name="attrHeading" type="java.lang.String" required="false"
    description="Attributes to add to the tag surrounding the heading, for example RDFA." %>

<%@ attribute name="cssHeading" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the heading." %>

<%@ attribute name="visual" fragment="true" required="false"
    description="Markup shown for the content piece visual." %>

<%@ attribute name="attrVisual" type="java.lang.String" required="false"
    description="Attributes to add to the tag surrounding the visual, for example RDFA." %>

<%@ attribute name="cssVisual" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the visual." %>

<%@ attribute name="text" fragment="true" required="false"
    description="Markup shown for the content piece text." %>

<%@ attribute name="attrText" type="java.lang.String" required="false"
    description="Attributes to add to the tag surrounding the text, for example RDFA." %>

<%@ attribute name="cssText" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the text." %>

<%@ attribute name="textAlignment" type="java.lang.String" required="false"
    description="Controls the alignment of the text elements. Default is left aligned." %>

<%@ attribute name="link" fragment="true" required="false"
    description="Markup shown for the content piece link." %>

<%@ attribute name="attrLink" type="java.lang.String" required="false"
    description="Attributes to add to the tag surrounding the link, for example RDFA." %>

<%@ attribute name="cssLink" type="java.lang.String" required="false"
    description="'class' selectors to add to the tag surrounding the link." %>

<%@ attribute name="inlineLink" type="java.lang.Boolean" required="false"
    description="Indicates if the link should be placed inside the text div. Default is 'true'." %>

<%@ attribute name="allowEmptyBodyColumn" type="java.lang.Boolean" required="false"
    description="Indicates an empty body column should be kept. Default is 'false'.
    If this is 'false' then the visual column will use the whole available space in case
    the body column is empty. If 'true' the visual column will only use the width set,
    not extending to the space of the empty body column. This can be useful in case
    you have floating visuals, e.g. on detail pages." %>

<%@ attribute name="attrBody" type="java.lang.String" required="false"
    description="Attributes to add to the generated body div." %>

<%@ attribute name="cssBody" type="java.lang.String" required="false"
    description="'class' selectors to add to the generated body div." %>

<%@ attribute name="bodyPreMarkup" type="java.lang.String" required="false"
    description="Markup to append before the body content." %>

<%@ attribute name="bodyPostMarkup" type="java.lang.String" required="false"
    description="Markup to append after the body content." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="pieceTag"       value="${empty pieceTag ? 'div' : pieceTag}" />
<c:set var="fullWidth"      value="${(pieceLayout <= 1) or (pieceLayout == 10) or (pieceLayout == 11)}" />
<c:set var="inlineLink"     value="${empty inlineLink ? not fullWidth : inlineLink}" />

<c:set var="inlineHeading"  value="${(pieceLayout == 1) or (pieceLayout >= 6)}" />
<c:set var="visualLast"     value="${pieceLayout == 10 or (pieceLayout == 11)}" />
<c:set var="linkLast"       value="${pieceLayout == 11}" />

<c:choose>
    <c:when test="${fullWidth}">
        <c:set var="pieceIsFull"    value="${true}" />
        <c:set var="sizeDesktop"    value="${(empty sizeDesktop or (sizeDesktop == 99)) ? 12 : (sizeDesktop > 12 ? 12 : (sizeDesktop < 0 ? 0 : sizeDesktop))}" />
    </c:when>
    <c:otherwise>
        <c:set var="pieceIsFlex"    value="${(pieceLayout == 2) or (pieceLayout == 3) or (pieceLayout == 6) or (pieceLayout == 7)}" />
        <c:set var="pieceIsFloat"   value="${not fullWidth and not pieceIsFlex}" />
        <c:set var="pieceDirection" value="${not fullWidth ? (pieceLayout % 2 == 0 ? 'left' : 'right') : ''}" />
        <c:set var="sizeDesktop"    value="${(empty sizeDesktop or (sizeDesktop == 99) or (sizeDesktop > 12)) ? 4 : (sizeDesktop < 0 ? 0 : sizeDesktop)}" />
    </c:otherwise>
</c:choose>

<c:set var="sizeMobile"     value="${(empty sizeMobile or (sizeMobile == 99) or (sizeMobile > 12)) ? (sizeDesktop < 10 ? (sizeDesktop > 3 ? 12 : sizeDesktop * 2) : 12) : (sizeMobile < 0 ? 0 : sizeMobile)}" />

<c:set var="useVisual"      value="${(sizeMobile != 0) or (sizeDesktop != 0)}" />

<c:choose>
    <c:when test="${((sizeDesktop > 0) and (sizeDesktop < 12)) or ((sizeDesktop == 0) and (sizeMobile > 0) and (sizeMobile < 12))}">
        <%-- Only use grid in case desktop image size is not 12 columns i.e. 100%. --%>
        <c:set var="pieceOption">${pieceIsFlex ? 'flex ' : ''}${pieceIsFloat ? 'float ' : ''}${pieceIsFull ? 'full ' : ''}${pieceDirection}</c:set>
    </c:when>
    <c:otherwise>
        <%-- If image uses all 12 columns on desktop, treat this as using layout option 0 or 1. --%>
        <c:set var="pieceOption" value="full" />
    </c:otherwise>
</c:choose>

<c:if test="${empty gridOption}">
    <c:if test="${sizeMobile < 12}">
        <c:set var="gridOption" value="${'p-xs-'}${sizeMobile}" />
    </c:if>
    <c:if test="${sizeDesktop < 12}">
        <c:set var="gridOption" value="${empty gridOption ? '' : gridOption.concat(' ')}${'p-md-'}${sizeDesktop}" />
    </c:if>
</c:if>

<c:if test="${not empty heading}">
    <jsp:invoke fragment="heading" var="pieceHeading" />
</c:if>
<c:set var="showHeading"    value="${not empty pieceHeading}" />

<c:if test="${not empty text}">
    <jsp:invoke fragment="text" var="pieceText" />
</c:if>
<c:set var="showText"       value="${not empty pieceText}" />

<c:if test="${not empty link}">
    <jsp:invoke fragment="link" var="pieceLink" />
</c:if>
<c:set var="showLink"       value="${not empty pieceLink}" />

<c:if test="${useVisual and not empty visual}">
    <%-- It is important to make this check AFTER the body because the grid size must be 12 if there is no body. --%>
    <cms:addparams>
        <cms:param name="cssgrid" value="${'col-xs-'.concat(sizeMobile).concat(sizeDesktop < 12 ? ' col-md-'.concat(sizeDesktop) : '')}" />
        <jsp:invoke fragment="visual" var="pieceVisual" />
    </cms:addparams>
</c:if>
<c:set var="showVisual"     value="${not empty pieceVisual}" />

<c:if test="${not showVisual}">
    <%-- If there is no visual and we get 'full' piece, make sure the div structure for does not use inline heading or link. --%>
    <%-- These are required only in case there is a visual. --%>
    <c:set var="inlineLink"     value="${false}" />
    <c:set var="inlineHeading"  value="${false}" />
</c:if>

<c:set var="showBody"           value="${showText or (showHeading and inlineHeading) or (showLink and inlineLink)}" />

<c:if test="${(not showVisual or not showBody) and not allowEmptyBodyColumn}">
    <%-- In this case there are no columns, so we revert to layout option 0 i.e. full with output. --%>
    <c:set var="pieceOption"    value="full" />
    <c:set var="gridOption"     value="" />
</c:if>

<c:choose>
    <c:when test="${empty textAlignment or (textAlignment eq 'pal')}">
        <%-- Default alignment, no css class added --%>
    </c:when>
    <c:when test="${(textAlignment eq 'par') or (textAlignment eq 'pac') or (textAlignment eq 'paj')}">
        <c:set var="pieceAlignment" value="${' '}${textAlignment}" />
    </c:when>
</c:choose>

<c:choose>
    <c:when test="${showHeading and not showVisual and not showBody and not showLink}">
        <c:set var="pieceFeatureMarker" value=" only-heading" />
        <c:set var="onlyHeading" value="${true}" />
    </c:when>
    <c:when test="${showVisual and not showHeading and not showBody and not showLink}">
        <c:set var="pieceFeatureMarker" value=" only-visual" />
        <c:set var="onlyVisual" value="${true}" />
    </c:when>
    <c:when test="${showBody and not showHeading and not showVisual and not showLink}">
        <c:set var="pieceFeatureMarker" value=" only-text" />
        <c:set var="onlyText" value="${true}" />
    </c:when>
    <c:when test="${showLink and not showHeading and not showVisual and not showBody}">
        <c:set var="pieceFeatureMarker" value=" only-link" />
        <c:set var="onlyLink" value="${true}" />
    </c:when>
    <c:otherwise>
        <%-- "phh" means "piece has heading", "phv" means "piece has visual" and so on... --%>
        <%-- "pvl" means "piece visual last". --%>
        <c:set var="pieceFeatureMarker" value="${showHeading ? ' phh': ''}${showVisual ? ' phv': ''}${visualLast ? ' pvl': ''}${showBody ? ' phb': ''}${showLink ? ' phl': ''}" />
    </c:otherwise>
</c:choose>

<c:if test="${showLink}">
    <c:set var="linkMarkup">
        <div class="link${empty cssLink ? '' : ' '.concat(cssLink)}"${empty attrLink ? '' : ' '.concat(attrLink)}><%----%>
            ${pieceLink}
        </div><%----%>
        <mercury:nl />
    </c:set>
</c:if>

<c:if test="${showVisual}">
    <c:set var="visualMarkup">
        <div class="visual${empty cssVisual ? '' : ' '.concat(cssVisual)}"${empty attrVisual ? '' : ' '.concat(attrVisual)}><%----%>
            ${pieceVisual}
        </div><%----%>
        <mercury:nl />
    </c:set>
</c:if>

<c:if test="${showHeading}">
    <c:set var="headingMarkup">
        <div class="heading${empty cssHeading ? '' : ' '.concat(cssHeading)}"${empty attrHeading ? '' : ' '.concat(attrHeading)}><%----%>
            ${pieceHeading}
        </div><%----%>
        <mercury:nl />
    </c:set>
</c:if>

${'<'}${pieceTag}${' '}
    ${'class=\"'}
        ${empty cssWrapper ? '' : cssWrapper.concat(' ')}
        ${empty pieceClass ? 'piece' : pieceClass}
        ${empty pieceOption ? '' : ' '.concat(pieceOption)}
        ${empty pieceFeatureMarker ? '' : pieceFeatureMarker}
        ${empty pieceAlignment ? '' : pieceAlignment}
        ${empty gridOption ? '' : ' '.concat(gridOption)}
    ${'\"'}
    ${empty attrWrapper ? '' : ' '.concat(attrWrapper)}
${'>'}
<mercury:nl />

<c:if test="${showHeading and not inlineHeading}">
    ${headingMarkup}
</c:if>

<c:if test="${showVisual and not visualLast}">
    ${visualMarkup}
</c:if>

<c:if test="${showBody}">
    <div class="body${empty cssBody ? '' : ' '.concat(cssBody)}"${empty attrBody ? '' : ' '.concat(attrBody)}><%----%>
        ${bodyPreMarkup}
        <c:if test="${showHeading and inlineHeading}">
            ${headingMarkup}
        </c:if>
        <c:if test="${showText}">
            <div class="text${empty cssText ? '' : ' '.concat(cssText)}"${empty attrText ? '' : ' '.concat(attrText)}><%----%>
                ${pieceText}
            </div><%----%>
            <mercury:nl />
        </c:if>
        <c:if test="${showLink and inlineLink}">
            ${linkMarkup}
        </c:if>
        ${bodyPostMarkup}
    </div><%----%>
    <mercury:nl />
</c:if>

<c:if test="${showLink and not inlineLink and not linkLast}">
    ${linkMarkup}
</c:if>

<c:if test="${showVisual and visualLast}">
    ${visualMarkup}
</c:if>

<c:if test="${showLink and not inlineLink and linkLast}">
    ${linkMarkup}
</c:if>


${'</'}${pieceTag}${'>'}
<mercury:nl />
