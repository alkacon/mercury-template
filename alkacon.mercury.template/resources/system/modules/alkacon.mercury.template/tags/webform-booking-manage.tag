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
            <td><fmt:message key="msg.page.form.bookingstatus.participant.label" />:</td><%----%>
            <c:choose>
            <c:when test="${status.hasUnlimitedPlaces}">
                <td>${status.numParticipants} (<fmt:message key="msg.page.form.bookingstatus.places.unlimited" />)</td><%----%>
            </c:when>
            <c:otherwise>
                <td><%----%>
                    <fmt:message key="msg.page.form.submissions.overview">
                        <fmt:param>${status.numParticipants}</fmt:param>
                        <fmt:param>${status.maxRegularPlaces}</fmt:param>
                    </fmt:message>
                </td><%----%>
            </c:otherwise>
            </c:choose>
        </tr><%----%>
        <c:if test="${not status.hasUnlimitedPlaces}">
        <tr><%----%>
            <td><fmt:message key="msg.page.form.bookingstatus.waitlist.label" />:</td><%----%>
            <td><%----%>
                <fmt:message key="msg.page.form.submissions.overview">
                    <fmt:param>${status.numWaitlistCandidates}</fmt:param>
                    <fmt:param>${status.maxWaitlistPlaces}</fmt:param>
                </fmt:message>
            </td><%----%>
        </tr><%----%>
        </c:if>
        <tr><%----%>
            <td><fmt:message key="msg.page.form.bookingstatus.cancelledSubmissions.label" />:</td><%----%>
            <td>${status.numCancelledSubmissions}</td><%----%>
        </tr><%----%>

        <c:if test="${formBookingHasFinalRegistrationDate}">
            <tr><%----%>
               <td><fmt:message key="msg.page.form.bookingstatus.registrationClosed.headline"/>:</td><%----%>
               <td>${formBookingFinalRegistrationDateStr}</td><%----%>
            </tr><%----%>
        </c:if>
        </table><%----%>
        <mercury:nl />
        <c:if test="${status.numMoveUpPlaces gt 0 and status.numWaitlistCandidates gt 0}">
            <div class="subelement oct-meta-info severe box"><%----%>
                <fmt:message key="msg.page.bookingmanage.info.moveupcandidates">
                    <fmt:param>${status.numMoveUpPlaces}</fmt:param>
                </fmt:message>
            </div><%----%>
        </c:if>
        <c:if test="${status.fullyBooked}">
            <div class="subelement oct-meta-info severe box"><%----%>
                <fmt:message key="msg.page.form.remaining.places.none" /><%----%>
            </div><%----%>
        </c:if>

        <c:if test="${not empty form.submissions or status.numOtherSubmissions gt 0}">

            <c:set var="formHandler" value="${form.createFormHandler(pageContext)}" />
            <c:choose>
            <c:when test="${not empty param.action and not empty param.uuid}">
                <mercury:icalendar-vars content="${formBookingXml}">
                ${formHandler.setICalInfo(iCalLink, iCalFileName, iCalLabel)}
                </mercury:icalendar-vars>
                <c:set var="formDataHandler" value="${form.createFormDataHandler(pageContext, formHandler)}" />
                <c:choose>
                    <c:when test="${param.action eq 'cancel'}">
                        <c:set var="result" value="${formDataHandler.cancelRegistration(param.uuid)}" />
                    </c:when>
                    <c:when test="${param.action eq 'add'}">
                        <c:set var="result" value="${formDataHandler.moveUpFromWaitingList(param.uuid)}" />
                    </c:when>
                    <c:when test="${param.action eq 'delete'}">
                        <c:set var="result" value="${formDataHandler.deleteSubmission(param.uuid)}" />
                    </c:when>
                    <c:when test="${param.action eq 'deleteAll'}">
                        <c:set var="result" value="${formDataHandler.deleteAllSubmissions(param.uuid)}" />
                    </c:when>
                </c:choose>
                <c:choose>
                    <c:when test="${not empty formDataHandler.error}">
                        <div class="submissions-action-error"><%----%>
                            <fmt:message key="${formDataHandler.error}" />
                        </div><%----%>
                    </c:when>
                    <c:when test="${not empty formDataHandler.info}">
                        <div class="submissions-action-info"><%----%>
                            <fmt:message key="${formDataHandler.info}" />
                        </div><%----%>
                    </c:when>
                </c:choose>
                <div class="subelement"><%----%>
                    <a class="btn btn-block oct-meta-info" href="<cms:link>${adminLink}?formmanage=${param.formmanage}</cms:link>"><%----%>
                        <fmt:message key="msg.page.form.button.submissions.manage" />
                    </a><%----%>
                </div><%----%>
            </c:when>
            <c:otherwise>
            <c:set var="id1"><mercury:idgen prefix="wf1" uuid="${cms.element.id}" /></c:set>
            <div class="subelement"><%----%>
                <h3><%----%>
                    <c:choose>
                        <c:when test="${status.hasUnlimitedPlaces}">
                            <fmt:message key="msg.page.form.bookingstatus.participant.label" /> (${status.numParticipants})<%----%>
                        </c:when>
                        <c:otherwise>
                            <fmt:message key="msg.page.form.bookingstatus.participant.label" /> (${status.numParticipants}/${status.maxRegularPlaces})<%----%>
                        </c:otherwise>
                    </c:choose>
                </h3><%----%>
                <div class=list-box><%----%>
                    <div class="list-entries accordion-items" id="${id1}"><%----%>
                        <c:forEach var="dataBean" items="${status.participants}" varStatus="stat">
                            <cms:display value="${dataBean.file.structureId}" editable="true" delete="false">
                               <cms:param name="index" value="${stat.index}"/>
                               <cms:param name="id" value="${id1}" />
                               <cms:param name="fullyBooked" value="${status.fullyBooked}" />
                               <cms:param name="hasFreeParticipantPlaces" value="${status.hasFreeParticipantPlaces}" />
                               <cms:param name="confirmationMailEnabled" value="${formHandler.formConfiguration.confirmationMailEnabled}" />
                            </cms:display>
                        </c:forEach>
                        <c:forEach var="otherParticipant" begin="1" end="${status.numOtherSubmissions}">
                            <div class="accordion"><%----%>
                                <div class="acco-header"><%----%>
                                    <a class="acco-toggle collapsed" data-bs-toggle="collapse" data-bs-parent="#${id1}" href="#other${id1}${otherParticipant}"><%----%>
                                        <div><fmt:message key="msg.page.form.bookingstatus.reservedplace.label" /></div><%----%>
                                    </a><%----%>
                                </div><%----%>
                                <div id="other${id1}${otherParticipant}" class="acco-body collapse" data-bs-parent="#${id1}"><%----%>
                                    <fmt:message key="msg.page.bookingmanage.info.reservedplace" /><%----%>
                                </div><%----%>
                            </div><%----%>
                        </c:forEach>
                    </div><%----%>
                </div><%----%>
            </div><%----%>
            <mercury:nl />
            
            <c:if test="${status.numWaitlistCandidates gt 0}">
                <c:set var="id2"><mercury:idgen prefix="wf2" uuid="${cms.element.id}" /></c:set>
                <div class="subelement"><%----%>
                    <h3><fmt:message key="msg.page.form.bookingstatus.waitlist.label" /> (${status.numWaitlistCandidates}/${status.maxWaitlistPlaces})</h3><%----%>
                    <div class=list-box><%----%>
                        <div class="list-entries accordion-items" id="${id2}"><%----%>
                            <c:forEach var="dataBean" items="${status.waitlistCandidates}" varStatus="stat">
                                <cms:display value="${dataBean.file.structureId}" editable="true" delete="false">
                                   <cms:param name="index" value="${stat.index}"/>
                                   <cms:param name="id" value="${id2}" />
                                   <cms:param name="fullyBooked" value="${status.fullyBooked}" />
                                   <cms:param name="hasFreeParticipantPlaces" value="${status.hasFreeParticipantPlaces}" />
                                   <cms:param name="confirmationMailEnabled" value="${formHandler.formConfiguration.confirmationMailEnabled}" />
                                </cms:display>
                            </c:forEach>
                        </div><%----%>
                    </div><%----%>
                </div>
            </c:if>
            <c:if test="${status.numCancelledSubmissions gt 0}">
                <c:set var="id3"><mercury:idgen prefix="wf3" uuid="${cms.element.id}" /></c:set>
                <div class="subelement"><%----%>
                    <h3><fmt:message key="msg.page.form.bookingstatus.cancelledSubmissions.label" /> (${status.numCancelledSubmissions})</h3><%----%>
                    <div class=list-box><%----%>
                        <div class="list-entries accordion-items" id="${id3}"><%----%>
                            <c:forEach var="dataBean" items="${status.cancelledSubmissions}" varStatus="stat">
                                <cms:display value="${dataBean.file.structureId}" editable="true" delete="false">
                                   <cms:param name="index" value="${stat.index}"/>
                                   <cms:param name="id" value="${id3}" />
                                   <cms:param name="fullyBooked" value="${status.fullyBooked}" />
                                   <cms:param name="hasFreeParticipantPlaces" value="${status.hasFreeParticipantPlaces}" />
                                   <cms:param name="confirmationMailEnabled" value="${formHandler.formConfiguration.confirmationMailEnabled}" />
                                </cms:display>
                            </c:forEach>
                        </div><%----%>
                    </div><%----%>
               </div><%----%>
           </c:if>
           <mercury:nl />
           <div class="subelement"><%----%>
               <h3><fmt:message key="msg.page.form.bookingstatus.export.label" /></h3><%----%>
               <c:set var="formId">${formXml.file.structureId}</c:set>
               <c:set var="bookingId">${formBookingXml.file.structureId}</c:set>
               <c:set var="csvLink">/system/modules/alkacon.mercury.webform/elements/formdata.csv?f=${formId}&b=${bookingId}&__locale=${cms.locale}</c:set>
               <c:set var="excelLink">/system/modules/alkacon.mercury.webform/elements/formdata.xlsx?f=${formId}&b=${bookingId}&__locale=${cms.locale}</c:set>
               <c:set var="csvExportConfig" value="${cms.readAttributeOrProperty[cms.requestContext.uri]['webform.exportbean.csv']}" />
               <c:set var="excelExportConfig" value="${cms.readAttributeOrProperty[cms.requestContext.uri]['webform.exportbean.excel']}" />
               <div class="pull-right"><%----%>
                   <span class="mr-5"><%----%>
                       <fmt:message key="msg.page.form.label.submissions.export" />
                   </span><%----%>
                   <c:set var="link"><cms:link>${csvLink}</cms:link></c:set>
                   <mercury:link link="${link}" css="btn btn-xs oct-meta-info mr-5">
                       <fmt:message key="msg.page.form.button.submissions.csv" />
                   </mercury:link><%----%>
                   <c:set var="link"><cms:link>${excelLink}</cms:link></c:set>
                   <mercury:link link="${link}" css="btn btn-xs oct-meta-info mr-5">
                       <fmt:message key="msg.page.form.button.submissions.excel" />
                   </mercury:link><%----%>
                   <c:if test="${not empty csvExportConfig}">
                       <c:set var="csvExportBean" value="${fn:substringBefore(csvExportConfig, ':')}" />
                       <c:set var="csvExportLabel" value="${fn:substringAfter(csvExportConfig, ':')}" />
                       <c:set var="additionalCsvLink" value="${csvLink}&exportBean=${csvExportBean}" />
                       <c:set var="link"><cms:link>${additionalCsvLink}</cms:link></c:set>
                       <mercury:link link="${link}" css="btn btn-xs oct-meta-info mr-5">${csvExportLabel}</mercury:link><%----%>
                   </c:if>
                   <c:if test="${not empty excelExportConfig}">
                       <c:set var="excelExportBean" value="${fn:substringBefore(excelExportConfig, ':')}" />
                       <c:set var="excelExportLabel" value="${fn:substringAfter(excelExportConfig, ':')}" />
                       <c:set var="additionaExcelLink" value="${excelLink}&exportBean=${excelExportBean}" />
                       <c:set var="link"><cms:link>${additionaExcelLink}</cms:link></c:set>
                       <mercury:link link="${link}" css="btn btn-xs oct-meta-info mr-5">${excelExportLabel}</mercury:link><%----%>
                   </c:if>
               </div><%----%>
            </div><%----%>
            <mercury:nl />
            <c:if test="${not empty bookingId and not empty form.submissions}">
                <div class="submission-actions subelement">
                    <h3><fmt:message key="msg.page.form.bookingstatus.delete.label" /></h3><%----%>
                    <p><fmt:message key="msg.page.form.label.submissions.deleteAll" /><button id="deleteAll_button_${bookingId}" class="btn btn-xs oct-meta-info ml-5"><fmt:message key="msg.page.form.submission.action.deleteAll" /></button><%----%></p>
                    <dialog id="deleteAll_dialog_${bookingId}"><%----%>
                        <form method="dialog"><%----%>
                            <h3><fmt:message key="msg.page.form.bookingstatus.dialog.confirm.label" /></h3><%----%>
                            <div><fmt:message key="msg.page.form.submission.ask.deleteAll" /></div><%----%>
                            <div class="buttons"><%----%>
                                <button value="cancel" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.dialog.cancel" />
                                </button><%----%>
                                <button value="confirm" class="btn"><%----%>
                                    <fmt:message key="msg.page.form.submission.confirm.deleteAll" />
                                </button><%----%>
                            </div><%----%>
                        </form><%----%>
                    </dialog><%----%>
                    <script>new SubmissionsDialog("deleteAll", "${bookingId}", "${bookingId}")</script><%----%>
                </div>
            </c:if>
            <mercury:nl />
            </c:otherwise>
            </c:choose>
        </c:if>
    </div><%----%>
    <mercury:nl />

    </cms:bundle>
</c:if>

</mercury:webform-vars>
