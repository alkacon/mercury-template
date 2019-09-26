<%@ tag display-name="meta-title"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the page / nav title based on meta mappings." %>


<%@ attribute name="title" type="java.lang.String" required="false"
    description="The title to use. In case no title is given, the title is read from the page meta values." %>

<%@ attribute name="intro" type="java.lang.String" required="false"
    description="The intro to use instead of reading it from the page meta values." %>

<%@ attribute name="addIntro" type="java.lang.Boolean" required="false"
    description="Add intro to title. If this is 'true' but no 'intro' has been given,
    the intro is read from the page meta values." %>

<%@ attribute name="trim" type="java.lang.Integer" required="false"
    description="Reduce the text length to a maximum of chars, default is unlimited." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="resultTitle" value="${title}" />
<c:set var="addIntro" value="${empty addIntro and (not empty intro) ? true : addIntro}" />

<c:if test="${empty resultTitle}">
    <c:choose>
        <c:when test="${not empty cms.meta.ogTitle}">
            <c:set var="resultTitle" value="${cms.meta.ogTitle}" />
        </c:when>
        <c:otherwise>
            <c:set var="resultTitle" value="${cms.title}" />
        </c:otherwise>
    </c:choose>
</c:if>

<c:if test="${cms.detailRequest and (not empty param.instancedate) and (cms.meta.titleAppendInstanceDate eq 'true')}">
    <c:set var="startDate" value="${cms:convertDate(param.instancedate)}" />
    <c:if test="${startDate.time != 0}">
        <fmt:setLocale value="${cms:vfs(pageContext).requestContext.locale}" />
        <c:set var="resultTitle">
             ${resultTitle} - <%----%>
             <c:if test="${empty trim}">
                <%-- In case trim is active we probably want a short title, so don't add full name of day --%>
                <fmt:formatDate value="${startDate}" pattern="EEEE" type="date" />${' '}
             </c:if>
             <fmt:formatDate value="${startDate}" dateStyle="SHORT" timeStyle="SHORT" type="both" />
         </c:set>
    </c:if>
</c:if>

<c:if test="${addIntro}">
    <c:if test="${empty intro}">
        <c:choose>
            <c:when test="${not empty cms.meta.ogIntroTeaser}">
                <c:set var="intro" value="${cms.meta.ogIntroTeaser}" />
            </c:when>
            <c:when test="${not empty cms.meta.ogIntro}">
                <c:set var="intro" value="${cms.meta.ogIntro}" />
            </c:when>
        </c:choose>
    </c:if>
    <c:if test="${not empty intro}">
         <c:if test="${empty trim or ((fn:length(resultTitle) + fn:length(intro)) < trim)}" >
            <c:set var="resultTitle">${intro}: ${resultTitle}</c:set>
         </c:if>
    </c:if>
</c:if>

<c:out value="${resultTitle}" escapeXml="false" />


