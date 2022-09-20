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
<c:if test="${not empty anchor}">
    <mercury:set-content-disposition name="${anchor}" suffix="" setFilenameOnly="${true}" />
    <c:set var="anchor" value="${contentDispositionFilename}" />
</c:if>

<mercury:nl />

<c:choose>
<c:when test="${cms.isEditMode}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <mercury:alert-meta icon="bookmark">
        <jsp:attribute name="text">
            <c:choose>
                <c:when test="${not empty anchor}">
                    <fmt:message key="msg.page.anchor" /><%----%>
                    ${' '}<a href="<cms:link>${cms.requestContext.uri}#${anchor}</cms:link>">#${anchor}</a><%----%>
                    <div id="${anchor}" class="oct-anchor-set"></div><%----%>
                </c:when>
                <c:otherwise>
                    <fmt:message key="msg.page.anchor.empty" />
                </c:otherwise>
            </c:choose>
        </jsp:attribute>
    </mercury:alert-meta>

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
