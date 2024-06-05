<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="formInfo"               value="${param.formInfo}" />
<c:set var="bookingInfo"            value="${param.bookingInfo}" />
<c:set var="bookingOption"          value="${param.bookingOption}" />
<c:set var="bookingFormId"          value="${param.bookingFormId}" />

<c:if test="${not empty formInfo and not empty bookingInfo}">

    <c:set var="formContent"        value="${cms.vfs.readXml[formInfo]}" />
    <c:set var="bookingContent"     value="${cms.vfs.readXml[bookingInfo]}" />

    <c:if test="${not (bookingOption eq 'none')}">
        <div class="subelement pivot detail-bookingstatus"><%----%>
            <m:webform-booking-status
                bookingContent="${bookingContent}"
                style="${bookingOption}"
                hideFullOrClosed="${true}"
            />
        </div><%----%>
    </c:if>
    <div class="subelement pivot type-webform"><%----%>
        <m:webform
            webform="${formContent}"
            bookingInfo="${bookingContent}"
            formId="${bookingFormId}"
        />
    </div><%----%>
</c:if>