<%@ tag pageEncoding="UTF-8"
    display-name="set-placename"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Set the place name from a either POI link or an embedded address." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="false"
    description="The content that contains the place information to read the name from." %>

<%@ attribute name="var" required="true" rtexprvalue="false"
    description="The name of the variable to store the place name in." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually read the place name to the calling element. If provided and false, the place name is NOT read abt the result will be 'null'." %>

<%@ variable alias="result" name-from-attribute="var" scope="AT_END" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<c:if test="${empty test or test}">

    <c:set var="loc" value="${
        content.value.AddressChoice.isSet and content.value.AddressChoice.value.PoiLink.isSet ?
        cms.vfs.readXml[content.value.AddressChoice.value.PoiLink] :
        content.value.AddressChoice.value.Address
    }" />

    <c:if test="${not empty loc}">
        <c:choose>
            <c:when test="${loc.value.Name.isSet}">
                <c:set var="result" value="${loc.value.Name}" />
            </c:when>
            <c:when test="${loc.value.Title.isSet}">
                <c:set var="result" value="${loc.value.Title}" />
            </c:when>
        </c:choose>
    </c:if>

</c:if>
