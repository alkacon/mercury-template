<%@ tag pageEncoding="UTF-8"
    display-name="link"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Resolves an opencms:// link." %>


<%@ attribute name="targetLink" type="java.lang.String" required="true"
    description="A String that contains the link." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:if test="${not empty targetLink}">

    <c:set var="targetLink">
        <%= alkacon.mercury.template.CmsFunctionLinkResolver.resolve(
                (org.opencms.jsp.util.CmsJspStandardContextBean)getJspContext().findAttribute("cms"),
                (String)getJspContext().getAttribute("targetLink")
            )
        %>
    </c:set>

    <c:out escapeXml="${false}" value="${targetLink}" />

</c:if>

