<%@ tag pageEncoding="UTF-8"
    display-name="div"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays decorated text." %>


<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="The decoration will only be done if this is empty or 'true'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:if test="${not cms.isEditMode and (empty test or test)}">
    <c:set var="decoratorConfig" value="${cms.sitemapConfig.attribute['template.decorator.config']}" />
    <c:if test="${decoratorConfig.isSetNotNone}">
        <c:set var="decoratorConfigFile" value="${decoratorConfig.toResource}" />
    </c:if>
</c:if>

<c:choose>
    <c:when test="${not empty decoratorConfigFile}">
        <cms:decorate file="${decoratorConfigFile.rootPath}" locale="${cms.locale}">
            <jsp:doBody />
        </cms:decorate>
    </c:when>
    <c:otherwise>
        <jsp:doBody />
    </c:otherwise>
</c:choose>