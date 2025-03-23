<%@ tag pageEncoding="UTF-8"
    display-name="heading"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a HTML heading with a specified level." %>


<%@ attribute name="text" type="java.lang.Object" required="false"
    description="The heading text. HTML in this will be escaped.
    This can be either a String or a CmsJspContentAccessValueWrapper" %>

<%@ attribute name="level" type="java.lang.Integer" required="true"
    description="The HTML level of the heading, must be from 1 to 6 to generate h1 to h6.
    If the special value 7 is used, the text will be outputted as 'div' not as HTML heading.
    If no valid level is provided, for example 0, the headline will not be outputted at all." %>

<%@ attribute name="suffix" type="java.lang.String" required="false"
    description="Optional suffix for the heading. HTML in this will NOT be escaped." %>

<%@ attribute name="prefix" type="java.lang.String" required="false"
    description="Optional prefix for the heading. HTML in this will NOT be escaped." %>

<%@ attribute name="headingAsDiv" type="java.lang.Boolean" required="false"
    description="Controls if headings are generated using regular <h1> ... <h6> tags, or as divs that contain a marker class 'h1' ... 'h6'." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes to attach to the heading tag." %>

<%@ attribute name="tabindex" type="java.lang.Boolean" required="false"
    description="Force adding 'tabindex=0' attribute to the generated markup
    If not set, use default 'true' when 'level' is in range 1 to 4, 'false' for all other sizes.
    If 'false' is set explicitly, supress genertion of tabindex attribute for all sizes" %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Optional HTML attributes to attach to the heading tag." %>

<%@ attribute name="markupText" fragment="true" required="false"
    description="Markup shown for the text if the text is not provided.
    If both attributes 'markupText' and 'text' are provided, only the 'markupText' will be displayed." %>

<%@ attribute name="escapeXml" type="java.lang.Boolean" required="false"
    description="Controls if the heading text is XML escaped. Default is 'true' if not provided." %>

<%@ attribute name="decorate" type="java.lang.Boolean" required="false"
    description="Controls if decoration - if configured - is applied to the heading.
    Default if not provided is 'false' for level 1 - 6, and 'true' for level 7 when css is 'sub-header'." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated heading.
    Default is 'false' if not provided." %>

<%@ attribute name="id" type="java.lang.String" required="false"
    description="Adds an the provided ID attribute to the heading, useful for use in anchor links." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="The heading markup will only be generated if this evaluates to 'true'." %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${(level gt 0) and (level le 7) and (empty test or test)}">

    <c:if test="${not empty markupText}">
        <jsp:invoke fragment="markupText" var="markupTextOutput" />
    </c:if>

    <c:if test="${(not empty markupTextOutput) or (not empty text)}">

        <c:set var="escapeXml"      value="${empty escapeXml ? true : escapeXml}" />
        <c:if test="${headingAsDiv}">
            <c:set var="css" value="h${level}${' '}${css}" />
            <c:set var="level" value="${7}" />
        </c:if>
        <c:set var="addTabindex"    value="${empty tabindex ? ((level ge 1) and (level le 4)) : tabindex}" />
        <c:set var="decorate"       value="${empty decorate ? ((level eq 7) and (css eq 'sub-header')) : decorate}" />

        <c:if test="${(id eq 'auto') and (not empty text)}">
            <c:set var="addId"          value="${cms.sitemapConfig.attribute['template.section.add.heading.id'].toBoolean}" />
            <c:set var="addAnchorlink"  value="${cms.sitemapConfig.attribute['template.section.add.heading.anchorlink'].toBoolean}" />
            <c:choose>
                <c:when test="${addId or addAnchorlink}">
                    <c:set var="id"><m:translate-name name="${fn:trim(text)}" />-${fn:substringBefore(cms.element.instanceId, '-')}</c:set>
                    <c:if test="${addAnchorlink and empty suffix}">
                        <c:set var="suffix"><a class="anchor-link" href="#${id}"></a></c:set>
                        <c:set var="css" value="piece-heading anchor-link-parent ${css}" />
                    </c:if>
                </c:when>
                <c:otherwise>
                    <c:set var="id" value="${null}" />
                </c:otherwise>
            </c:choose>
        </c:if>

        <c:choose>
            <c:when test="${level eq 7}">
                ${'<div'}
            </c:when>
            <c:otherwise>
                ${'<h'}${level}
            </c:otherwise>
        </c:choose>

        <c:if test="${not empty css}">${' '}class="${css}"</c:if>
        <c:if test="${not empty id}">${' id=\"'}${id}${'\"'}</c:if>
        <c:if test="${addTabindex}">${' '}tabindex="0"</c:if>
        <c:if test="${not empty attr}">${' '}${attr}</c:if>
        <c:if test="${useAde}">${' '}${text.rdfaAttr}</c:if>
        ${'>'}

            ${prefix}
            <m:decorate test="${decorate}">
                <c:choose>
                    <c:when test="${not empty markupTextOutput}">
                        ${markupTextOutput}
                    </c:when>
                    <c:when test="${not empty text}">
                        <c:set var="useAde" value="${ade and cms:isWrapper(text)}" />
                        <c:if test="${useAde}"><span${' '}${text.rdfaAttr}></c:if>
                        <m:out value="${text}" escapeXml="${escapeXml}" />
                        <c:if test="${useAde}"></span></c:if>
                    </c:when>
                </c:choose>
            </m:decorate>
            ${suffix}

        <c:choose>
            <c:when test="${level eq 7}">
                ${'</div>'}
            </c:when>
            <c:otherwise>
                 ${'</h'}${level}${'>'}
            </c:otherwise>
        </c:choose>
        <m:nl />
    </c:if>

</c:if>