<%@ tag pageEncoding="UTF-8"
    display-name="webform-booking-status"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the booking status for the provided content,
    if the content contains booking information." %>


<%@ attribute name="bookingContent" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The content for which the booking information should be shown." %>

<%@ attribute name="style" type="java.lang.String" required="false"
    description="The style of the booking status." %>

<%@ attribute name="dateFormat" type="java.lang.String" required="false"
    description="The date format used to display the final registration date." %>

<%@ attribute name="noDivWrapper" type="java.lang.Boolean" required="false"
    description="If 'true, the outer div wrapper is omitted from the returned markup." %>

<%@ attribute name="hideRegistrationClosed" type="java.lang.Boolean" required="false"
    description="If 'true, do not show the 'registration closed' message." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${bookingContent.value.Booking.value.Webform.isSet}">

    <mercury:webform-vars
        webform="${bookingContent.value.Booking.value.Webform.toString}"
        bookingInfo="${bookingContent}"
        dateFormat="${dateFormat}">

    <fmt:setLocale value="${cms.locale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <c:set var="status" value="${form.submissionStatus}" />

    <c:choose>
    <c:when test="${not empty status.maxRegularSubmissions}">

        <c:set var="numRemainingSubmissions" value="${status.numRemainingRegularSubmissions}"/>
        <c:set var="numRemainingWaitlistSubmissions" value="${status.numRemainingWaitlistSubmissions}" />

        <c:choose>
            <c:when test="${style eq 'simple'}">
                <%-- ###### Simple booking overview - places available / no places available only ###### --%>
                <c:choose>
                    <c:when test="${status.fullyBooked}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.none" /></c:set>
                    </c:when>
                    <c:when test="${formBookingHasFinalRegistrationDate and formBookingRegistrationClosed}">
                        <c:if test="${not hideRegistrationClosed}">
                            <c:set var="bookMsg"><fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline" /></c:set>
                        </c:if>
                    </c:when>
                    <c:when test="${status.onlyWaitlist}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.waitlist" /></c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places" /></c:set>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:when test="${style eq 'date' and formBookingHasFinalRegistrationDate and not status.fullyBooked}">
                <%-- ###### Final registration date overview - shown only if not fully booked ###### --%>
                <c:choose>
                    <c:when test="${formBookingRegistrationClosed}">
                        <c:if test="${not hideRegistrationClosed}">
                            <c:set var="bookMsg"><fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline" /></c:set>
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <c:set var="bookMsg">
                            <fmt:message key="msg.page.form.bookingstatus.registrationClosesOn">
                                <fmt:param>${formBookingFinalRegistrationDateStr}</fmt:param>
                            </fmt:message>
                        </c:set>
                    </c:otherwise>
                </c:choose>
            </c:when>
            <c:otherwise>
                <%-- ###### More details booking overview - more then / less then X places available ###### --%>
                <c:choose>
                    <c:when test="${formBookingHasFinalRegistrationDate and formBookingRegistrationClosed and not status.fullyBooked}">
                        <c:if test="${not hideRegistrationClosed}">
                            <c:set var="bookMsg"><fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline" /></c:set>
                        </c:if>
                    </c:when>
                    <c:when test="${empty numRemainingSubmissions}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places" /></c:set>
                    </c:when>
                    <c:when test="${numRemainingSubmissions >= 10}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.morethan">
                            <fmt:param>10</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:when test="${numRemainingSubmissions >= 5}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.morethan">
                            <fmt:param>5</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:when test="${numRemainingSubmissions > 0}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.lessthan">
                            <fmt:param>5</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:when test="${numRemainingWaitlistSubmissions >= 10}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.waitlist.morethan">
                            <fmt:param>10</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:when test="${numRemainingWaitlistSubmissions >= 5}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.waitlist.morethan">
                            <fmt:param>5</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:when test="${numRemainingWaitlistSubmissions > 0}">
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.waitlist.lessthan">
                            <fmt:param>5</fmt:param>
                        </fmt:message></c:set>
                    </c:when>
                    <c:otherwise>
                        <c:set var="bookMsg"><fmt:message key="msg.page.form.remaining.places.none" /></c:set>
                    </c:otherwise>
                </c:choose>
            </c:otherwise>
        </c:choose>

        <mercury:div css="book-info" test="${not noDivWrapper}">
            <c:if test="${not empty bookMsg}">
                <span class="book-msg">${bookMsg}</span><%----%>
            </c:if>
            <c:if test="${cms.isEditMode and form.userCanManage}">
                <span class="oct-meta-info"><%----%>
                    <fmt:message key="msg.page.form.submissions.overview">
                        <fmt:param>${status.numTotalSubmissions}</fmt:param>
                        <fmt:param>${status.maxRegularSubmissions}</fmt:param>
                    </fmt:message>
                </span><%----%>
            </c:if>
        </mercury:div>
        <mercury:nl />

    </c:when>
    <c:otherwise>

         <mercury:div css="book-info" test="${not noDivWrapper}">
            <span class="book-msg"><fmt:message key="msg.page.form.remaining.places" /></span><%----%>
            <c:if test="${cms.isEditMode and form.userCanManage}">
            <span class="oct-meta-info"><%----%>
                <fmt:message key="msg.page.form.bookingstatus.places.unlimited" />
            </span><%----%>
            </c:if>
        </mercury:div>
        <mercury:nl />

    </c:otherwise>
    </c:choose>


    </cms:bundle>
    </mercury:webform-vars>

</c:if>
