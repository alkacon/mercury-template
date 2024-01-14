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

<mercury:setting-defaults>

<c:set var="addCssWrapper"          value="${setting.addCssWrapper.isSetNotNone ? ' '.concat(setting.addCssWrapper.toString) : null}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.useDefault('caret-right').toString}" />
<c:set var="linksequenceType"       value="${setting.linksequenceType.toString}" />

<c:set var="emptyLinkSequence"      value="${empty content.valueList.LinkEntry}" />
<c:set var="ade"                    value="${cms.isEditMode}" />

<c:choose>
    <c:when test="${emptyLinkSequence}">
        <c:set var="listBulletStyle" value="empty-sequence" />
    </c:when>
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
            <c:set var="iconPrefix" value="${fn:startsWith(iconClass, 'cif-') ? 'cif ' : 'fa-'}" />
            <c:set var="aWrapper">${iconPrefix}${iconClass}</c:set><%-- mercury:icon --%>
        </c:if>
    </c:when>
    <c:when test="${listBulletStyle eq 'custom-icon'}">
        <c:set var="iconPrefix" value="${fn:startsWith(iconClass, 'cif-') ? 'cif ' : 'fa-'}" />
        <c:set var="liWrapper">${iconPrefix}${iconClass}</c:set><%-- mercury:icon --%>
    </c:when>
</c:choose>

<mercury:nl />
<div class="element type-linksequence pivot ${linksequenceType}${' '}${listBulletStyle}${addCssWrapper}${setCssWrapperAll}"><%----%>
<mercury:nl />

    <mercury:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade}" id="auto" />

    <c:if test="${value.Text.isSet}">
        <div class="text-box" ${value.Text.rdfaAttr}>${value.Text}</div><%----%>
    </c:if>

    <c:choose>
        <c:when test="${not emptyLinkSequence}">
            <ul ${ulWrapper}><%----%>
                <c:forEach var="link" items="${content.valueList.LinkEntry}" varStatus="status">
                    <mercury:link-icon link="${link}" css="${aWrapper}" addSpan="ls-item" addLi="ls-li${not empty liWrapper ? ' '.concat(liWrapper) : ''}" />
                </c:forEach>
            </ul><%----%>
        </c:when>
        <c:otherwise>
            <!-- empty linksequence --><%----%>
        </c:otherwise>
    </c:choose>

</div><%----%>
<mercury:nl />

</mercury:setting-defaults>

</cms:bundle>
</cms:formatter>
</mercury:init-messages>