<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<mercury:webform
    webform="${param.content}"
    bookingInfo="${param.bookingInfo}"
    formId="${param.formId}"
    include="${false}"
/>