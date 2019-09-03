<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<mercury:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="setting"                value="${cms.element.setting}" />
<c:set var="cssWrapper"             value="${setting.cssWrapper.toString}" />
<c:set var="addCssWrapper"          value="${setting.addCssWrapper.isSetNotNone ? setting.addCssWrapper.toString : null}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.useDefault('caret-right').toString}" />
<c:set var="linksequenceType"       value="${setting.linksequenceType.toString}" />

<c:choose>
    <c:when test="${iconClass eq 'default'}">
        <c:set var="listBulletStyle" value="default-icon" />
    </c:when>
    <c:when test="${iconClass eq 'none'}">
        <c:set var="listBulletStyle" value="no-icon" />
    </c:when>
    <c:when test="${iconClass eq 'line'}">
        <c:set var="listBulletStyle" value="line-icon" />
    </c:when>
    <c:otherwise>
        <c:set var="listBulletStyle" value="custom-icon" />
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${linksequenceType eq 'ls-navigation'}">
        <c:set var="ulWrapper">class="nav-side"</c:set>
        <c:if test="${listBulletStyle eq 'custom-icon'}">
            <c:set var="aWrapper">fa-${iconClass}</c:set>
        </c:if>
    </c:when>
    <c:when test="${listBulletStyle eq 'custom-icon'}">
        <c:set var="liWrapper">class="fa-${iconClass}"</c:set>
    </c:when>
</c:choose>

<mercury:nl />
<div class="element type-linksequence ${linksequenceType}${' '}${listBulletStyle}${' '}${cssWrapper}${' '}${addCssWrapper}">
<%----%>

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" />

    <c:if test="${text.isSet}">
        <div class="text-box" ${text.rdfaAttr}>${text}</div><%----%>
    </c:if>

    <ul ${ulWrapper}><%----%>
        <c:forEach var="link" items="${content.valueList.LinkEntry}" varStatus="status">
            <c:set var="linkText" value="${link.value.Text}" />
            <c:if test="${fn:startsWith(linkText, 'icon:')}">
                <c:set var="linkText"><span class="fa fa-${fn:substringAfter(linkText, 'icon:')}"></span></c:set>
            </c:if>
            <li ${liWrapper}><%----%>
                <mercury:link link="${link}" css="${aWrapper}">
                    <span class="ls-item">${linkText}</span><%----%>
                </mercury:link>
            </li><%----%>
        </c:forEach>
    </ul><%----%>

</div><%----%>
<mercury:nl />

</cms:bundle>
</cms:formatter>
</mercury:init-messages>