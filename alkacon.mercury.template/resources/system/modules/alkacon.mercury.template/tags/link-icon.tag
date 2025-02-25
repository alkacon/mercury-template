<%@ tag pageEncoding="UTF-8"
    display-name="icon-link"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a link with optional icon prefix.
    The link text is parsed to check for special 'icon:' and 'id:' parts." %>


<%@ attribute name="link" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="A XML value wrapper that contains the link." %>

<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated href tag." %>

<%@ attribute name="addSpan" type="java.lang.String" required="false"
    description="If provided, adds a SPAN tag around the generated href tag with a class containing the argument value." %>

<%@ attribute name="addLi" type="java.lang.String" required="false"
    description="If provided, adds an LI tag around the generated href tag with a class containing the argument value." %>

<%@ attribute name="inline" type="java.lang.Boolean" required="false"
    description="Controls if the icon should be inlined as SVG (the default),
    or rendered from an icon font." %>

<%@ attribute name="resultMap" type="java.util.HashMap" required="false"
    description="If provided, store the results in this map and do NOT generate any HTML output." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="linkText" value="${link.value.Text}" />
<c:set var="autoLi" value="${addLi ne 'none'}" />
<c:set var="addLi" value="${autoLi ? addLi : null}" />
<c:set var="inline" value="${empty inline or inline}" />

<c:set var="linkParts" value="${fn:split(linkText, '||')}" />
<c:forEach var="linkPart" items="${linkParts}">
    <c:choose>
        <c:when test="${fn:startsWith(linkPart, 'icon:')}">
            <c:set var="iconClass" value="${fn:substringAfter(linkPart, 'icon:')}" />
            <c:set var="linkIcon"><m:icon icon="${iconClass}" tag="span" cssWrapper="ls-icon" inline="${inline}" /></c:set>
        </c:when>
        <c:when test="${fn:startsWith(linkPart, 'icon-last:')}">
            <c:set var="iconClass" value="${fn:substringAfter(linkPart, 'icon-last:')}" />
            <c:set var="linkIcon"><m:icon icon="${iconClass}" tag="span" cssWrapper="ls-icon icon-last" inline="${inline}" /></c:set>
            <c:if test="${not empty addSpan}">
                <c:set var="addSpan" value="${addSpan} icon-last" />
            </c:if>
        </c:when>
        <c:when test="${fn:startsWith(linkPart, 'image:')}">
            <c:set var="imagePath" value="${fn:substringAfter(linkPart, 'image:')}" />
            <c:set var="linkIcon"><m:icon icon="${imagePath}" tag="span" cssWrapper="ls-icon" fromImage="${true}" /></c:set>
        </c:when>
        <c:when test="${fn:startsWith(linkPart, 'id:')}">
            <c:set var="linkAttr">id="${fn:substringAfter(linkPart, 'id:')}"</c:set>
        </c:when>
        <c:when test="${fn:startsWith(linkPart, 'class:')}">
            <c:set var="cssWrapper">${fn:substringAfter(linkPart, 'class:')}</c:set>
            <c:if test="${autoLi}">
                <c:set var="addLi" value="${empty addLi ? 'li-'.concat(cssWrapper) : addLi.concat(' li-').concat(cssWrapper)}" />
            </c:if>
        </c:when>
        <c:when test="${fn:startsWith(linkPart, 'title:')}">
            <c:set var="linkTitle">${fn:substringAfter(linkPart, 'title:')}</c:set>
        </c:when>
        <c:otherwise>
            <c:set var="linkMessage">${empty linkMessage ? '' : linkMessage.concat(' ')}${linkPart}</c:set>
        </c:otherwise>
    </c:choose>
</c:forEach>

<c:if test="${not empty linkMessage and (resultMap == null)}">
    <c:set var="linkMessage"><span>${linkMessage}</span></c:set>
</c:if>

<c:choose>
    <c:when test="${resultMap != null}">
        <c:set var="ignore">
            ${resultMap.clear()}
            ${resultMap.putAll(
                {
                    "link": link,
                    "message": linkMessage,
                    "icon": linkIcon,
                    "iconClass": iconClass,
                    "title": linkTitle,
                    "css": cssWrapper,
                    "attr": linkAttr
                }
            )}
        </c:set>
    </c:when>
    <c:otherwise>
        ${empty addLi ? '' : '<li class=\"'.concat(addLi).concat('\">')}
            <m:link
                link="${link}"
                title="${linkTitle}"
                css="${css}${not empty css and not empty cssWrapper ? ' ' : ''}${cssWrapper}"
                attr="${linkAttr}">
                    ${empty addSpan ? '' : '<span class=\"'.concat(addSpan).concat('\">')}
                        ${linkIcon}${linkMessage}
                    ${empty addSpan ? '' : '</span>'}
            </m:link>
        ${empty addLi ? '' : '</li>'}
    </c:otherwise>
</c:choose>


