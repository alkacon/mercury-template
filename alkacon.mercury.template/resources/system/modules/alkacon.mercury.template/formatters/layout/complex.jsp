<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:formatter var="content" val="value">

<c:choose>
<c:when test="${(not value.ParentTypes.isSet) or (value.ParentTypes.isSet
  and (fn:containsIgnoreCase(cms.container.type, value.ParentTypes)
      or ((cms.container.type eq 'locked') and !cms.dragMode)))}">
    <%-- Element matches the configured parent container --%>

    <c:set var="setting"            value="${cms.element.setting}" />
    <c:set var="cssWrapper"         value="${setting.cssWrapper.toString}" />

    <mercury:container-box label="${value.Title}" boxType="model-start" />

    <c:if test="${value.PreMarkup.isSet}">
        <c:choose>
            <c:when test="${not empty cssWrapper and fn:contains(value.PreMarkup, '$(cssWrapper)')}">
                <c:set var="preMarkup" value="${fn:replace(value.PreMarkup, '$(cssWrapper)', cssWrapper)}" />
                <c:set var="cssWrapper"         value="${null}" />
            </c:when>
            <c:otherwise>
                <c:set var="preMarkup" value="${value.PreMarkup}" />
            </c:otherwise>
        </c:choose>
        ${preMarkup}
    </c:if>

    <c:forEach var="container" items="${content.valueList.Container}" varStatus="loop">
        <mercury:container value="${container.value}" title="${value.Title}" css="${cssWrapper}" />
    </c:forEach>

    <c:if test="${value.PostMarkup.isSet}">
        ${value.PostMarkup}
    </c:if>

    <mercury:container-box label="${value.Title}" boxType="model-end" />

</c:when>

<c:otherwise>
    <%-- Element does not match parent container, don't generate any output --%>
    <%-- This will cause the OpenCms page editor to not accept this layout in the parent container --%>
</c:otherwise>
</c:choose>

</cms:formatter>
