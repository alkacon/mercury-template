<%@ tag pageEncoding="UTF-8"
    display-name="icalendar"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates output in the iCalendar format from the data provided by the attributes." %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for calendar data generation."%>

<%@ attribute name="locale" type="java.util.Locale" required="true"
    description="The locale of the calendar entry'." %>

<%@ attribute name="title" type="java.lang.String" required="true"
    description="The title (summary) of the calendar entry'." %>

<%@ attribute name="dateStart" type="java.lang.Object" required="true"
    description="The start date of the calendar entry'." %>

<%@ attribute name="dateEnd" type="java.lang.Object" required="false"
    description="The optional end date of the calendar entry'." %>

<%@ attribute name="description" type="java.lang.String" required="false"
    description="The description of the calendar entry'." %>

<%@ attribute name="image" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="false"
    description="An optional image for the calendar entry." %>

<%@ attribute name="location" type="java.lang.String" required="false"
    description="The location of the calendar entry'." %>

<%@ attribute name="url" type="java.lang.String" required="false"
    description="Optional URL of the calendar entry'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${locale}" />
<fmt:setTimeZone var="utcTime" value="UTC" />

<c:if test="${not empty description}">
    <c:set var="desc" value="${cms:stripHtml(description)}" scope="request" />
    <%
        String desc = (String)request.getAttribute("desc");
        desc = desc.replaceAll("\\r\\n", "\\\\n");
        desc = desc.replaceAll("\\n", "\\\\n");
        desc = desc.replaceAll(",", "\\\\,");
        request.setAttribute("descriptionConverted", desc);
    %>
</c:if>

<c:if test="${not empty location}">
    <c:set var="loc" value="${cms:stripHtml(location)}" scope="request" />
    <%
        String loc = (String)request.getAttribute("loc");
        loc = loc.replaceAll(",", "\\\\,");
        request.setAttribute("locationConverted", loc);
    %>
</c:if>

<c:set var="fullname">${title}-<fmt:formatDate value="${cms:convertDate(dateStart)}" pattern="yyyy-MM-dd" /></c:set>
<m:set-content-disposition name="${fullname}" suffix=".ics" /><%--

--%>BEGIN:VCALENDAR
VERSION:2.0
PRODID:${cms.requestContext.requestMatcher}
BEGIN:VEVENT
UID:${content.file.structureId}-${dateStart}-${locale}
DTSTAMP:<fmt:formatDate value="${cms:convertDate(content.file.dateCreated)}" pattern="yyyyMMdd'T'HHmmss'Z'" timeZone="${utcTime}" />
DTSTART:<fmt:formatDate value="${cms:convertDate(dateStart)}" pattern="yyyyMMdd'T'HHmmss'Z'" timeZone="${utcTime}" />

<c:if test="${not empty dateEnd}">
DTEND:<fmt:formatDate value="${cms:convertDate(dateEnd)}" pattern="yyyyMMdd'T'HHmmss'Z'" timeZone="${utcTime}" />
</c:if>
SUMMARY;LANGUAGE=${locale}:${title}

<c:if test="${not empty description}">
DESCRIPTION;LANGUAGE=${locale}:${descriptionConverted}
</c:if>

<c:if test="${not empty location}">
LOCATION;LANGUAGE=${locale}:${locationConverted}
</c:if>

<c:if test="${not empty image and image.isSet}">
IMAGE;VALUE=URI;DISPLAY=BADGE;FMTTYPE=image/jpeg:${cms.requestContext.requestMatcher}<cms:link>${image}</cms:link>
</c:if>

<c:if test="${not empty url}">
   <c:if test="${not empty param.instancedate}">
       <c:set var="url">${url}?instancedate=${param.instancedate}</c:set>
   </c:if>
URL:${cms.requestContext.requestMatcher}<cms:link>${url}</cms:link>
</c:if>
END:VEVENT
END:VCALENDAR
