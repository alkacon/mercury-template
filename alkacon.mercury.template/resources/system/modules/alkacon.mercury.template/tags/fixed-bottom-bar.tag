<%@ tag pageEncoding="UTF-8"
    display-name="fixed-bottom-bar"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a fixed bottom bar for icon links." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="true"
    description="The properties read from the URI resource with search." %>

<%@ attribute name="contentUri" type="java.lang.String" required="true"
    description="The content URI to generate the cookie banner for." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<div id="fixed-bottom-bar">

<m:load-plugins group="fixed-bottom-bar" type="jsp" />

<c:if test="${not cms.isEditMode}">
    <m:privacy-policy-vars locatePolicyFile="${true}" contentPropertiesSearch="${contentPropertiesSearch}">

    <c:if test="${not empty policyFile}">
        <div id="privacy-policy-link-settings" class="fixed-bottom-bar-item"></div><%----%>
        <m:nl />
    </c:if>

    </m:privacy-policy-vars>
</c:if>

</div>

</cms:bundle>
