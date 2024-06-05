<%@ tag pageEncoding="UTF-8"
    display-name="data-event"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for events." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ attribute name="date" type="org.opencms.jsp.util.CmsJspInstanceDateBean" required="true"
    description="The selected instance date."%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<%-- Using the same logic as the elaborate display teaser --%>
<c:set var="value"      value="${content.value}" />
<c:choose>
    <c:when test="${value['MetaInfo/Title'].isSet}">
        <c:set var="intro"      value="${null}" />
        <c:set var="title"      value="${value['MetaInfo/Title']}" />
    </c:when>
    <c:otherwise>
        <c:set var="intro"      value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
        <c:set var="title"      value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
    </c:otherwise>
</c:choose>
<c:choose>
    <c:when test="${value['MetaInfo/Description'].isSet}">
        <c:set var="preface"    value="${value['MetaInfo/Description']}" />
    </c:when>
    <c:otherwise>
        <c:set var="preface"    value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : (value.Preface.isSet ? value.Preface : null)}" />
    </c:otherwise>
</c:choose>
<c:set var="image"      value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (value.Image.isSet ? value.Image : value.Paragraph.value.Image)}" />

<c:set var="url">${cms.site.url}<cms:link>${content.filename}</cms:link>?instancedate=${date.start.time}</c:set>

<%--
# JSON-LD Generation for Mercury event.
# See: https://schema.org/Event
# See: https://developers.google.com/search/docs/data-types/event
--%>
<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="Event" />
    <cms:jsonvalue key="url" value="${url}" />
    <cms:jsonvalue key="mainEntityOfPage" value="${url}" />

    <cms:jsonvalue key="name">
        <c:if test="${intro.isSet}">
            <c:out value="${intro.toString.concat(': ')}" />
        </c:if>
        <c:out value="${title}" />
    </cms:jsonvalue>

    <c:if test="${not empty date}">
        <c:set var="pattern">
            <c:choose>
                <c:when test="${date.wholeDay}">yyyy-MM-dd</c:when>
                <c:otherwise>yyyy-MM-dd'T'HH:mm:ssXXX</c:otherwise>
            </c:choose>
        </c:set>
        <c:if test="${not empty date.start}">
            <cms:jsonvalue key="startDate"><fmt:formatDate value="${date.start}" pattern="${pattern}" /></cms:jsonvalue>
        </c:if>
        <c:if test="${not empty date.end and not (date.end eq date.start)}">
            <cms:jsonvalue key="endDate"><fmt:formatDate value="${date.end}" pattern="${pattern}" /></cms:jsonvalue>
        </c:if>
    </c:if>

    <c:if test="${preface.isSet}">
        <cms:jsonvalue key="description" value="${preface}" />
    </c:if>

    <c:if test="${value.Performer.isSet}">
        <cms:jsonobject key="performer">
            <cms:jsonvalue key="@type" value="Person" />
            <cms:jsonvalue key="name" value="${value.Performer}" />
        </cms:jsonobject>
    </c:if>

    <c:if test="${image.isSet}">
        <m:image-vars image="${image}" createJsonLd="${true}">
            <cms:jsonvalue key="image" value="${imageJsonLd}" />
        </m:image-vars>
    </c:if>

    <m:location-vars data="${value.AddressChoice}" onlineUrl="${value.VirtualLocation}" fallbackOnlineUrl="${url}" createJsonLd="${true}">
        <cms:jsonvalue key="location" value="${locJsonLd}" />
        <cms:jsonvalue key="eventAttendanceMode" value="${locAttendanceMode}" />
        <cms:jsonvalue key="eventStatus" value="https://schema.org/EventScheduled" />
    </m:location-vars>

    <c:if test="${value.Costs.isSet}">
        <cms:jsonarray key="offers">
        <c:forEach var="costs" items="${content.valueList.Costs}">
            <cms:jsonobject>
                <cms:jsonvalue key="@type" value="Offer" />
                <cms:jsonvalue key="description" value="${costs.value.Label.toString}" />
                <cms:jsonvalue key="price" value="${fn:replace(costs.value.Price.toString, ',', '.')}" />
                <cms:jsonvalue key="priceCurrency" value="${costs.value.Currency.isSet ? costs.value.Currency.toString : 'EUR'}" />
                <cms:jsonvalue key="url" value="${costs.value.LinkToPaymentService.value.URI.isSet ? costs.value.LinkToPaymentService.value.URI.toLink : null}" />
            </cms:jsonobject>
        </c:forEach>
        </cms:jsonarray>
    </c:if>
</cms:jsonobject>

<m:nl /><%----%>
<script type="application/ld+json">
    ${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}
</script><%----%>
<m:nl />