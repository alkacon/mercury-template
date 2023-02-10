<%@ tag pageEncoding="UTF-8"
    display-name="icalendar-vars"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Extracts iCalendar information from an event content and sets a series of variables for quick acess." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="Must be a content element of type 'event'." %>


<%@ variable name-given="iCalLink" declare="true"
    description="The contact kind. Can be 'org' or 'person'. Default is 'person'." %>

<%@ variable name-given="iCalFileName" declare="true"
    description="The name to display for the contact." %>

<%@ variable name-given="iCalLabel" declare="true"
    description="The position to display for the contact." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>


<c:set var="iCalLink">
    <cms:link>/system/modules/alkacon.mercury.template/elements/event.ics<%--
        --%>?id=${cms.element.id}<%--
        --%>&instancedate=${param.instancedate}<%--
        --%>&url=<cms:link>${content.file.rootPath}</cms:link><%--
        --%>&__locale=${cms.locale}<%--
    --%></cms:link>
</c:set>
<c:set var="iCalFileName" value="${fn:escapeXml(fn:replace(value.Title, '\"', ''))}" />
<c:set var="iCalLabel">
    <fmt:message key="msg.page.icalendar" />
</c:set>

<jsp:doBody/>