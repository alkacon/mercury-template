<%@ tag pageEncoding="UTF-8"
    display-name="data-cookies"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates privacy policy cookie data for elements." %>


<%@ attribute name="message" type="java.lang.String" required="true"
    description="Element depended messsage for the generated cookie alert box." %>

<%@ attribute name="heading" type="java.lang.String" required="false"
    description="Heading for the generated cookie alert box
    Will be read from the global configuration if not provided." %>

<%@ attribute name="footer" type="java.lang.String" required="false"
    description="Footer for the generated cookie alert box
    Will be read from the global configuration if not provided." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<cms:jsonobject var="cookieData">
    <cms:jsonvalue key="message" value="${message}" />
    <c:if test="${not empty heading}">
        <cms:jsonvalue key="heading" value="${heading}" />
    </c:if>
    <c:if test="${not empty footer}">
        <cms:jsonvalue key="footer" value="${footer}" />
    </c:if>
</cms:jsonobject>

<%----%>data-external-cookies='${cookieData.compact}'<%----%>