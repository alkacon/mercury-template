<%@ tag pageEncoding="UTF-8"
    display-name="intro-headline"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a headline with optional intro prefix." %>


<%@ attribute name="intro" type="java.lang.Object" required="false"
    description="The heading intro. HTML in this will be escaped.
    This can be either a String or a CmsJspContentAccessValueWrapper" %>

<%@ attribute name="headline" type="java.lang.Object" required="true"
    description="The main headline. HTML in this will be escaped.
    This can be either a String or a CmsJspContentAccessValueWrapper" %>

<%@ attribute name="level" type="java.lang.Integer" required="true"
    description="The HTML level of the heading, must be from 1 to 6 to generate h1 to h6.
    If the special value 7 is used, the text will be outputted as 'div' not as HTML heading.
    If no valid level is provided, for example 0, the headline will not be outputted at all." %>

<%@ attribute name="suffix" type="java.lang.String" required="false"
    description="Optional suffix for the heading. HTML in this will NOT be escaped." %>

<%@ attribute name="prefix" type="java.lang.String" required="false"
    description="Optional prefix for the heading. HTML in this will NOT be escaped." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes to attach to the heading tag." %>

<%@ attribute name="tabindex" type="java.lang.Boolean" required="false"
    description="Force adding 'tabindex=0' attribute to the generated markup
    If not set, use default 'true' for h1 and h2, 'false' for all other sizes.
    If 'false' is set explicitly, supress genertion of tabindex attribute even for h1 and h2." %>

<%@ attribute name="attr" type="java.lang.String" required="false"
    description="Optional HTML attributes to attach to the heading tag." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="false"
    description="Enables advanced direct edit for the generated heading.
    Default is 'false' if not provided." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="The heading markup will only be generated if this evaluates to 'true'." %>

<%@ attribute name="escapeXml" type="java.lang.Boolean" required="false"
    description="Similar to c:out escapeXml. Default is 'true'." %>


<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="escapeXml" value="${empty escapeXml or escapeXml ? true : false}" />

<c:if test="${((not empty intro) or (not empty headline)) and (empty test or test)}">

    <m:heading
        css="${empty css ? '' : css.concat(' ')}intro-headline"
        level="${level}"
        tabindex="${tabindex}"
        attr="${attr}">

        <jsp:attribute name="markupText">
            <c:if test="${not empty intro}">
                <span class="intro"><%----%>
                    <c:set var="adeIntro" value="${ade and cms:isWrapper(intro)}" />
                    ${adeIntro ? '<span '.concat(intro.rdfaAttr).concat('>') : ''}
                        <m:out value="${intro}" escapeXml="${escapeXml}" />
                    ${adeIntro ? '</span>' : ''}
                    <span class="sr-only">:</span><%----%>
                </span><%----%>
            </c:if>
            <c:if test="${not empty headline}">
                <span class="headline"><%----%>
                    <c:set var="adeHeadline" value="${ade and cms:isWrapper(headline)}" />
                    ${prefix}
                    ${adeHeadline ? '<span '.concat(headline.rdfaAttr).concat('>') : ''}
                        <m:out value="${headline}" escapeXml="${escapeXml}" />
                    ${adeHeadline ? '</span>' : ''}
                    ${suffix}
                </span><%----%>
            </c:if>
        </jsp:attribute>

    </m:heading>

</c:if>