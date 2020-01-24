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


<c:set var="anchor" value="${fn:trim(cms.element.setting.anchor)}" />

<mercury:nl />

<c:choose>
<c:when test="${cms.isEditMode}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <div class="oct-anchor"><%----%>
        <c:choose>
            <c:when test="${not empty anchor}">
                <div class="target"><%----%>
                    <fmt:message key="msg.page.anchor" /> #${anchor}
                </div><%----%>
                <div id="${anchor}" class="oct-anchor-set"></div><%----%>
            </c:when>
            <c:otherwise>
                <div class="empty"><%----%>
                    <fmt:message key="msg.page.anchor.empty" />
                </div><%----%>
            </c:otherwise>
        </c:choose>
    </div><%----%>

    </cms:bundle>
</c:when>
<c:when test="${not empty anchor and not cms.isEditMode}">
    <div id="${anchor}" class="oct-anchor-set"></div><%----%>
</c:when>
<c:otherwise>
<div class="oct-anchor-none"><%----%>
    <!-- No Anchor set --><%----%>
</div><%----%>
</c:otherwise>
</c:choose>

<mercury:nl />
