<%@ tag
    display-name="display"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Wrapper for cms:display with error handling." %>


<%@ attribute name="file" type="java.lang.String" required="true"
    description="The file to display." %>

<%@ attribute name="formatter" type="java.lang.String" required="false"
    description="The display formatter to use. If not specified the default formatter for the given file is used." %>

<%@ attribute name="baseUri" type="java.lang.String" required="false"
    description="The base URI to use the sitemap configuration from. If not set the current context URI is used." %>

<%@ attribute name="settings" type="java.util.Map" required="false"
    description="Settings for the display formatter." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:catch var="displayException">
    <c:choose>
        <c:when test="${not empty formatter}">
            <c:set var="paramFormatter" value="${formatter}" />
            <cms:simpledisplay
                value="${file}"
                formatter="${formatter}"
                editable="false">
                <c:forEach var="setting" items="${settings}">
                    <cms:param name="${setting.key}" value="${setting.value}" />
                </c:forEach>
            </cms:simpledisplay>
        </c:when>
        <c:otherwise>
            <c:set var="paramFormatter" value="${baseUri}" />
            <cms:display
                value="${file}"
                baseUri="${baseUri}"
                editable="false">
                <c:forEach var="setting" items="${settings}">
                    <cms:param name="${setting.key}" value="${setting.value}" />
                </c:forEach>
            </cms:display>
        </c:otherwise>
    </c:choose>
</c:catch>

<c:if test="${(displayException != null) and not cms.isOnlineProject}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
        <c:set var="errorMsg">
            <fmt:message key="msg.error.display.text">
                <fmt:param>${file}</fmt:param>
                <fmt:param>${paramFormatter}</fmt:param>
                <fmt:param>${displayException}</fmt:param>
            </fmt:message>
        </c:set>
        <c:if test="${false}">
            <%-- Enable logging manually here if required --%>
            <mercury:log message="${errorMsg}" exception="${displayException}" channel="error" />
        </c:if>
        <c:choose>
            <c:when test="${cms.isEditMode}">
                <mercury:alert type="error">
                    <jsp:attribute name="head">
                        <fmt:message key="msg.error.display.head" />
                    </jsp:attribute>
                    <jsp:attribute name="text">
                        <c:out value="${errorMsg}" escapeXml="false" />
                    </jsp:attribute>
                </mercury:alert>
            </c:when>
            <c:otherwise>
                <!--<mercury:nl />
                <fmt:message key="msg.error.display.head" />
                <mercury:nl />
                <c:out value="${errorMsg}" escapeXml="false" />
                <mercury:nl />--><mercury:nl />
            </c:otherwise>
        </c:choose>
    </cms:bundle>
</c:if>