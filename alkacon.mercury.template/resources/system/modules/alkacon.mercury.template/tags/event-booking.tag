<%@ tag pageEncoding="UTF-8"
    display-name="event-booking"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates event booking information." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the booking information should be shown." %>

<%@ attribute name="bookingOption" type="java.lang.String" required="true"
    description="The selected booking option." %>

<%@ attribute name="formatter" type="java.lang.String" required="false"
    description="Link to the formatter to use for the overview display." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="Can be used to defer the decision to actually create the booking information markup around the body to the calling element.
    If not set or 'true', the booking information markup from this tag is generated around the body of the tag.
    Otherwise everything is ignored and the output is generated as if there is no booking information available." %>


<%@ variable name-given="bookingInformation" declare="true"
    description="The booking information to show on the output page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="generateBoookingInfo" value="${empty test or test}" />
<c:set var="formatter" value="${not empty formatter ? formatter : '/system/modules/alkacon.mercury.template/formatters/display/event-compact.xml'}" />


<c:if test="${generateBoookingInfo}">
    <c:set var="hasBookingForm" value="${content.value.Booking.value.Webform.isSet}" />
    <c:if test="${hasBookingForm}">
        <c:set var="bookingsFormId" value="${cms.element.id}" />
        <c:set var="bookingsFormIdHash" value="${bookingsFormId.hashCode()}" />
        <c:set var="showBookingsList" value="${(not cms.isOnlineProject) and (param.formmanage eq bookingsFormIdHash)}" />
        <c:set var="showBookingsFormResult" value="${param.formsubmit eq bookingsFormIdHash}" />
    </c:if>

    <c:if test="${showBookingsList or showBookingsFormResult}">
    <%-- ###### Booking form actions, display short version of detail content only ###### --%>
        <cms:simpledisplay
            value="${content.id}"
            formatter="${formatter}"
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
                formId="${bookingsFormId}"
            />
        </div>
    </c:when>
    <c:otherwise>
        <%-- ###### Display regular detail page ###### --%>
        <c:set var="bookingInformation">
            <c:if test="${hasBookingForm}">
                <c:if test="${not (bookingOption eq 'none')}">
                    <div class="subelement detail-bookingstatus"><%----%>
                        <mercury:webform-booking-status
                            bookingContent="${content}"
                            style="${bookingOption}"
                        />
                    </div><%----%>
                </c:if>
                <div class="subelement type-webform"><%----%>
                    <mercury:webform
                        webform="${content.value.Booking.value.Webform}"
                        bookingInfo="${content}"
                        formId="${bookingsFormId}"
                    />
                </div><%----%>
            </c:if>
        </c:set>
        <jsp:doBody />
    </c:otherwise>
</c:choose>
