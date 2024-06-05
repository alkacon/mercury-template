<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<m:webform
    webform="${param.content}"
    bookingInfo="${param.bookingInfo}"
    formId="${param.formId}"
    include="${false}"
/>