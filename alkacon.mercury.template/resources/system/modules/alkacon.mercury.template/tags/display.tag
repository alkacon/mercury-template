<%@ tag
    display-name="display"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Wrapper for cms:display with error handling." %>


<%@ attribute name="file" type="java.lang.String" required="true"
    description="The file to display." %>

<%@ attribute name="formatter" type="java.lang.String" required="true"
    description="The display formatter to use." %>

<%@ attribute name="settings" type="java.util.Map" required="false"
    description="Settings for the display formatter." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:catch var="displayException">
    <cms:simpledisplay
        value="${file}"
        formatter="${formatter}"
        editable="false">
        <c:forEach var="setting" items="${settings}">
            <cms:param name="${setting.key}" value="${setting.value}" />
        </c:forEach>
    </cms:simpledisplay>
</c:catch>

<c:if test="${(displayException != null) and not cms.isOnlineProject}">
    <fmt:setLocale value="${cms.workplaceLocale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">
    <c:choose>
        <c:when test="${cms.isEditMode}">
            <mercury:alert type="error">
                <jsp:attribute name="head">
                    <fmt:message key="msg.error.display.head" />
                </jsp:attribute>
                <jsp:attribute name="text">
                    <fmt:message key="msg.error.display.text">
                        <fmt:param>${file}</fmt:param>
                        <fmt:param>${type}:${formatter}</fmt:param>
                        <fmt:param>${displayException}</fmt:param>
                    </fmt:message>
                </jsp:attribute>
            </mercury:alert>
        </c:when>
        <c:otherwise>
            <!--
            <fmt:message key="msg.error.display.head" />
            <fmt:message key="msg.error.display.text">
                    <fmt:param>${file}</fmt:param>
                    <fmt:param>${type}:${formatter}</fmt:param>
                    <fmt:param>${displayException}</fmt:param>
            </fmt:message>
            -->
        </c:otherwise>
    </c:choose>
    </cms:bundle>
</c:if>