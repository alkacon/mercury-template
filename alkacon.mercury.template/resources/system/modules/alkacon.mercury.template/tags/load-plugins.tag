<%@ tag pageEncoding="UTF-8"
    display-name="load-plugins"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Loads template plugins." %>

<%@ attribute name="type" type="java.lang.String" required="true"
    description="Type of plugins to load." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:set var="plugin" value="${cms.sitemapConfig.attribute[type]}" />
<c:if test="${plugin.isSetNotNone and cms.vfs.exists[plugin]}">
    <cms:include file="${plugin}" cacheable="false" />
</c:if>

