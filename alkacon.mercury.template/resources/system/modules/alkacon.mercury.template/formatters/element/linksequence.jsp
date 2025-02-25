<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<m:init-messages>

<cms:formatter var="content" val="value">
<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<m:setting-defaults>

<c:set var="addCssWrapper"          value="${setting.addCssWrapper.isSetNotNone ? ' '.concat(setting.addCssWrapper.toString) : ''}" />
<c:set var="hsize"                  value="${setting.hsize.toInteger}" />
<c:set var="iconClass"              value="${setting.iconClass.useDefault('caret-right').toString}" />
<c:set var="linksequenceType"       value="${setting.linksequenceType.toString}" />
<c:set var="expandOption"           value="${setting.expandOption.useDefault('closed disable-lg').toString}" />
<c:set var="buttonStyle"            value="${setting.buttonStyle.toString}" />

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
            <c:set var="aWrapper">${iconPrefix}${iconClass}</c:set><%-- m:icon --%>
        </c:if>
    </c:when>
    <c:when test="${linksequenceType eq 'ls-buttons'}">
        <c:set var="lsButtons" value="${true}" />
        <c:set var="ulWrapper">class="social-icons ${buttonStyle}"</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="expanding"  value="${linksequenceType eq 'ls-expand' and not emptyLinkSequence}" />
        <c:if test="${expanding}">
            <c:set var="open" value="${not fn:contains(expandOption, 'closed')}" />
            <c:set var="disableLg" value="${fn:contains(expandOption, 'disable-lg')}" />
            <c:set var="elementId"><m:idgen prefix="lsc" uuid="${cms.element.instanceId}" /></c:set>
            <c:set var="linksequenceType"  value="ls-bullets ls-expand${disableLg ? ' disable-lg' : ''}" />
            <c:set var="ulWrapper">class="collapse${open ? ' show' : ''}" id="${elementId}"</c:set>
            <c:set var="expanderMarkup">
                <button class="ls-toggle${open ? '':' collapsed'}" <%--
                --%>data-bs-toggle="collapse" type="button" <%--
                --%>aria-expanded="${open}" <%--
                --%>aria-controls="${elementId}" <%--
                --%>data-bs-target="#${elementId}"><%----%>
                    <m:out value="${value.Title}" lenientEscaping="${true}" />
                </button><%----%>
            </c:set>
        </c:if>
        <c:if test="${listBulletStyle eq 'custom-icon'}">
            <c:set var="iconPrefix" value="${fn:startsWith(iconClass, 'cif-') ? 'cif ' : 'fa-'}" />
            <c:set var="liWrapper">${iconPrefix}${iconClass}</c:set><%-- m:icon --%>
        </c:if>
    </c:otherwise>
</c:choose>

<m:nl />
<div class="element type-linksequence pivot ${linksequenceType}${' '}${listBulletStyle}${addCssWrapper}${setCssWrapperAll}"><%----%>
<m:nl />

    ${setElementPreMarkup}

    <m:heading level="${hsize}" text="${value.Title}" css="heading" ade="${ade and not expanding}" id="${not expanding ? 'auto' : ''}" tabindex="${not expanding}">
        <jsp:attribute name="markupText">${expanderMarkup}</jsp:attribute>
    </m:heading>

    <c:if test="${not expanding and value.Text.isSet}">
        <div class="text-box" ${value.Text.rdfaAttr}>${value.Text}</div><%----%>
    </c:if>

    <c:choose>
        <c:when test="${not emptyLinkSequence}">
            <ul ${ulWrapper}><%----%>
                <c:forEach var="link" items="${content.valueList.LinkEntry}" varStatus="status">
                    <c:choose>
                        <c:when test="${lsButtons}">
                            <jsp:useBean id="linkMap" class="java.util.HashMap" />
                            <m:link-icon link="${link}" inline="${false}" resultMap="${linkMap}" />
                            <c:if test="${not empty linkMap.icon}">
                                <c:set var="iconClass" value="${not fn:contains(linkMap.iconClass, '-') ? linkMap.iconClass : 'generic'}" />
                                <li class="ls-item ${iconClass}"><%----%>
                                    <m:link
                                        link="${linkMap.link}"
                                        title="${linkMap.message}"
                                        forceText="${linkMap.icon}" />
                                </li><%----%>
                            </c:if>
                            <c:if test="${false}">
                                <!-- CHECK2 -->
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <m:link-icon
                                link="${link}"
                                css="${aWrapper}"
                                addSpan="ls-item"
                                addLi="ls-li${not empty liWrapper ? ' '.concat(liWrapper) : ''}"
                            />
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </ul><%----%>
        </c:when>
        <c:otherwise>
            <!-- empty linksequence --><%----%>
        </c:otherwise>
    </c:choose>

</div><%----%>
<m:nl />

</m:setting-defaults>

</cms:bundle>
</cms:formatter>
</m:init-messages>