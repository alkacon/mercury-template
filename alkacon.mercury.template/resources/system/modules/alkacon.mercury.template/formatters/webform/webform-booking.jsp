<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:formatter var="content">

<c:set var="bookingInfo"            value="${cms.element.setting.bookingInfo.toString}" />
<c:set var="bookingOption"          value="${cms.element.setting.bookingOption.toString}" />
<c:set var="bookingFormId"          value="${cms.element.setting.bookingFormId.toString}" />

<c:if test="${not empty bookingInfo}">

    <c:set var="bookingContent"     value="${cms.vfs.readXml[bookingInfo]}" />

    <c:if test="${not (bookingOption eq 'none')}">
        <div class="subelement detail-bookingstatus"><%----%>
            <mercury:webform-booking-status
                bookingContent="${bookingContent}"
                style="${bookingOption}"
            />
        </div><%----%>
    </c:if>
    <div class="subelement type-webform"><%----%>
        <mercury:webform
            webform="${content}"
            bookingInfo="${bookingContent}"
            formId="${bookingFormId}"
        />
    </div><%----%>
</c:if>

</cms:formatter>
