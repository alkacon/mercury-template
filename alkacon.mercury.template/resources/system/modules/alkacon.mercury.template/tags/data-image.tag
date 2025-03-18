<%@ tag pageEncoding="UTF-8"
    display-name="data-image"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for image copryright." %>


<%@ attribute name="imageBean" type="org.opencms.jsp.util.CmsJspImageBean" required="true"
    description="The image bean to generate the copyright information for."%>

<%@ attribute name="copyright" type="java.lang.String" required="true"
    description="Copyright information to generate for the image. If this is emtpy, no copyright will be generated." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${not empty imageBean and not empty copyright}">
<script type="application/ld+json"><%--
--%>{"@context":"https://schema.org","@type":"ImageObject","contentUrl":"${imageBean.resource.toLink.onlineLink}","copyrightNotice":"<m:out value="${copyright}" />"}<%--
--%></script><%----%>
</c:if>