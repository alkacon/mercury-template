<%@ tag pageEncoding="UTF-8"
    display-name="event-booking"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates event booking information." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the booking information should be shown." %>

<%@ attribute name="bookingOption" type="java.lang.String" required="true"
    description="The selected booking option." %>

<%@ attribute name="formatterKey" type="java.lang.String" required="false"
    description="The key for the formatter to use for the comapct display on form result pages." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the booking information markup around the body to the calling element.
    If not set or 'true', the booking information markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and the output is generated as if there is no booking information available." %>


<%@ variable name-given="showBookingForm" declare="true"
    description="Indicates if the booking form should be shown on the output page." %>

<%@ variable name-given="bookingFormId" declare="true"
    description="The element id of the parent element containing the booking form." %>

<%@ variable name-given="bookingFormIdHash" declare="true"
    description="The hash code for the element id of the parent element containing the booking form." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="bookingFormId"          value="${cms.element.id.toString()}" />
<c:set var="bookingFormIdHash"      value="${bookingFormId.hashCode()}" />

<c:set var="generateBoookingInfo"   value="${empty test or test}" />
<c:set var="formatterKey"           value="${not empty formatterKey ? formatterKey : 'm/display/event-compact'}" />

<c:if test="${generateBoookingInfo}">
    <c:set var="hasBookingForm" value="${content.value.Booking.value.Webform.isSet}" />
    <c:if test="${hasBookingForm}">
        <c:set var="showBookingsList" value="${(not cms.isOnlineProject) and (param.formmanage eq bookingFormIdHash)}" />
        <c:set var="showBookingsFormResult" value="${param.formsubmit eq bookingFormIdHash}" />
    </c:if>

    <c:if test="${showBookingsList or showBookingsFormResult}">
    <%-- ###### Booking form actions, display short version of detail content only ###### --%>
        <cms:simpledisplay
            value="${content.id}"
            formatterKey="${formatterKey}"
            editable="false">
                <cms:param name="cssWrapper" value="box" />
                <cms:param name="dateFormat" value="${dateFormat}" />
                <cms:param name="titleOption" value="showIntro" />
                <cms:param name="buttonText" value="none" />
                <cms:param name="bookingOption" value="none" />
        </cms:simpledisplay>
    </c:if>
</c:if>

<c:choose>
    <c:when test="${showBookingsList}">
        <%-- ###### Booking form action: Display list of submissions ###### --%>
        <div class="element type-webform-manage"><%----%>
            <mercury:webform-booking-manage
                webform="${content.value.Booking.value.Webform}"
                bookingInfo="${content}"
            />
        </div><%----%>
    </c:when>
    <c:when test="${showBookingsFormResult}">
        <%-- ###### Booking form action: Display posted form ###### --%>
        <div class="subelement type-webform"><%----%>
            <mercury:webform
                webform="${content.value.Booking.value.Webform}"
                bookingInfo="${content}"
                formId="${bookingFormId}"
                include="${true}"
            />
        </div>
    </c:when>
    <c:otherwise>
        <%-- ###### Display regular detail page ###### --%>
        <c:set var="showBookingForm" value="${hasBookingForm}" />
        <jsp:doBody />
    </c:otherwise>
</c:choose>
