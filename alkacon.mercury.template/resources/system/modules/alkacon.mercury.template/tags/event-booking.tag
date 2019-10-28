<%@ tag pageEncoding="UTF-8"
    display-name="event-booking"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Generates event booking information." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the booking information should be shown." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="true"
    description="Can be used to scale the image in a specific ratio,
    Example values are: '1-1', '4-3', '3-2', '16-9', '2-1', '2,35-1' or 3-1." %>

<%@ attribute name="effect" type="java.lang.String" required="true"
    description="'class' atttributes to add to the preview for effects." %>

<%@ attribute name="bookingOption" type="java.lang.String" required="true"
    description="The selected booking option." %>

<%@ variable name-given="bookingInformation" declare="true"
    description="The booking information to show on the output page." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


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
        formatter="%(link.weak:/system/modules/alkacon.mercury.template/formatters/display/event-elaborate.xml:514d402e-bd6f-4a32-90bc-bb3a84db9931)"
        editable="false">
            <cms:param name="dateFormat" value="${dateFormat}" />
            <cms:param name="imageRatio" value="${imageRatio}" />
            <cms:param name="effect" value="${effect}" />
            <cms:param name="hideLink" value="true" />
            <cms:param name="titleOption" value="showIntro" />
            <cms:param name="pieceLayout" value="4" />
            <cms:param name="bookingOption" value="hide" />
    </cms:simpledisplay>
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
