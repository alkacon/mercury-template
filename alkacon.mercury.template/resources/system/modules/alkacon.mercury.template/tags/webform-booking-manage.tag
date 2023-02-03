<%@ tag pageEncoding="UTF-8"
    display-name="webform-booking-manage"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the booking management overview for the provided content,
    if the content contains booking information." %>


<%@ attribute name="webform" type="java.lang.Object" required="true"
    description="The object to initialze the form with.
    This can be an XML content or a CmsResource representing a form, or a path to a form XML configuration." %>

<%@ attribute name="bookingInfo" type="java.lang.Object" required="false"
    description="For booking forms, an object thet points to the additional booking settings.
    This can be an XML content or a path to a XML configuration that contains booking information." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<%-- ###### Generate the management overview ###### --%>

<mercury:webform-vars
    webform="${webform}"
    bookingInfo="${bookingInfo}" >

<c:if test="${form.userCanManage and not cms.isOnlineProject}">

    <c:set var="status" value="${form.submissionStatus}" />
    <fmt:setLocale value="${cms.locale}"/>
    <cms:bundle basename="alkacon.mercury.template.messages">

    <mercury:nl />
    <div class="subelement"><%----%>

        <div class="subelement"><%----%>
            <mercury:link link="${adminLink}" css="btn btn-block oct-meta-info">
                <fmt:message key="msg.page.form.button.submissions.back" />
            </mercury:link>
        </div><%----%>
        <mercury:nl />

        <h3><%----%>
            <fmt:message key="msg.page.form.bookingstatus.headline.1">
                <fmt:param>${formTitle}</fmt:param>
            </fmt:message>
        </h3><%----%>
        <mercury:nl />

        <table class="subelement submissions"><%----%>
        <tr><%----%>
           <td><fmt:message key="msg.page.form.bookingstatus.submissions.label"/>:</td><%----%>
           <td><%----%>
                <c:choose>
                <c:when test="${status.numTotalSubmissions == status.numFormSubmissions}">
                     ${status.numTotalSubmissions}
                </c:when>
                <c:otherwise>
                    <fmt:message key="msg.page.form.bookingstatus.submissions.status.3">
                        <fmt:param>${status.numTotalSubmissions}</fmt:param>
                        <fmt:param>${status.numFormSubmissions}</fmt:param>
                        <fmt:param>${status.numOtherSubmissions}</fmt:param>
                    </fmt:message>
                </c:otherwise>
                </c:choose>
           </td><%----%>
        </tr><%----%>

        <c:if test="${formBookingHasFinalRegistrationDate}">
            <tr><%----%>
               <td><fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline"/>:</td><%----%>
               <td>${formBookingFinalRegistrationDateStr}</td><%----%>
            </tr><%----%>
        </c:if>

        <tr><%----%>
           <td><fmt:message key="msg.page.form.bookingstatus.places.label"/>:</td><%----%>
           <td><%----%>
                <c:choose>
                <c:when test="${empty status.maxRegularSubmissions}">
                     <fmt:message key="msg.page.form.bookingstatus.places.unlimited"/>
                </c:when>
                <c:otherwise>
                    <c:choose>
                    <c:when test="${status.maxWaitlistSubmissions == 0}">
                        <fmt:message key="msg.page.form.bookingstatus.maxsubmission.nowaitlist.1">
                            <fmt:param>${status.maxRegularSubmissions}</fmt:param>
                        </fmt:message>
                    </c:when>
                    <c:otherwise>
                        <fmt:message key="msg.page.form.bookingstatus.maxsubmission.waitlist.2">
                            <fmt:param>${status.maxRegularSubmissions}</fmt:param>
                            <fmt:param>${status.maxWaitlistSubmissions}</fmt:param>
                        </fmt:message>
                    </c:otherwise>
                    </c:choose>
                </c:otherwise>
            </c:choose>
           </td><%----%>
        </tr><tr><%----%>
        <td><fmt:message key="msg.page.form.bookingstatus.freeplaces.label"/>:</td><%----%>
        <td><%----%>
            <c:choose>
            <c:when test="${status.fullyBooked}">
                <fmt:message key="msg.page.form.bookingstatus.fullybooked"/>
            </c:when>
            <c:when test="${status.onlyWaitlist}">
                <fmt:message key="msg.page.form.bookingstatus.onlywaitlist.1">
                    <fmt:param>${status.numRemainingWaitlistSubmissions}</fmt:param>
                </fmt:message>
            </c:when>
            <c:otherwise>
                <c:choose>
                <c:when test="${status.maxWaitlistSubmissions == 0}">
                    <fmt:message key="msg.page.form.bookingstatus.remainingsubmissions.nowaitlist.1">
                        <fmt:param>${status.numRemainingRegularSubmissions}</fmt:param>
                    </fmt:message>
                </c:when>
                <c:otherwise>
                    <fmt:message key="msg.page.form.bookingstatus.remainingsubmissions.waitlist.2">
                        <fmt:param>${status.numRemainingRegularSubmissions}</fmt:param>
                        <fmt:param>${status.numRemainingWaitlistSubmissions}</fmt:param>
                    </fmt:message>
                </c:otherwise>
                </c:choose>
            </c:otherwise>
            </c:choose>
        </td><%----%>
        </tr><%----%>
        </table><%----%>

        <c:if test="${not empty form.submissions}">

            <div class="row"><%----%>
                <div class="col-sm-6"><%----%>
                    <c:set var="id"><mercury:idgen prefix="wf" uuid="${cms.element.id}" /></c:set>
                    <h3><fmt:message key="msg.page.form.bookingstatus.submissiondata.heading"/></h3><%----%>
                </div><%----%>
                <div class="col-sm-6"><%----%>
                    <div class="subelement clearfix"><%----%>
                        <c:set var="formId">${formXml.file.structureId}</c:set>
                        <c:set var="bookingId">${formBookingXml.file.structureId}</c:set>
                        <c:set var="csvLink"><cms:link>/system/modules/alkacon.mercury.webform/elements/formdata.csv?f=${formId}&b=${bookingId}&__locale=${cms.locale}</cms:link></c:set>
                        <c:set var="excelLink"><cms:link>/system/modules/alkacon.mercury.webform/elements/formdata.xlsx?f=${formId}&b=${bookingId}&__locale=${cms.locale}</cms:link></c:set>
                        <div class="pull-right"><%----%>
                            <small class="mr-5">
                                <fmt:message key="msg.page.form.label.submissions.export" />
                            </small><%----%>
                            <mercury:link link="${csvLink}" css="btn btn-xs oct-meta-info mr-5">
                                <fmt:message key="msg.page.form.button.submissions.csv" />
                            </mercury:link><%----%>
                            <mercury:link link="${excelLink}" css="btn btn-xs oct-meta-info">
                                <fmt:message key="msg.page.form.button.submissions.excel" />
                            </mercury:link><%----%>
                        </div><%----%>
                    </div><%----%>
                    <mercury:nl />
                </div><%----%>
            </div><%----%>
            <mercury:nl />
            <div class=list-box><%----%>
                <div class="list-entries accordion-items" id="${id}"><%----%>
                    <c:forEach var="submission" items="${form.submissions}" varStatus="stat">
                        <cms:display value="${submission.structureId}" editable="true" delete="true">
                           <cms:param name="index" value="${stat.index}"/>
                           <cms:param name="id" value="${id}" />
                           <cms:param name="fullyBooked" value="${status.fullyBooked}" />
                        </cms:display>
                    </c:forEach>
                </div><%----%>
            </div><%----%>
            <mercury:nl />

        </c:if>
    </div><%----%>
    <mercury:nl />

    </cms:bundle>
</c:if>

</mercury:webform-vars>
