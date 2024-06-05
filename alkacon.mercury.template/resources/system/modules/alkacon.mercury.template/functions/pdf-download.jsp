<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:if test="${not empty cms.detailContent}">
    <c:set var="content" value="${cms.detailContent.toXml}" />
    <c:set var="value" value="${content.value}" />
    <c:set var="hasPdfSupport" value="${content.typeName eq 'm-article'}" />
</c:if>

<c:choose>

    <c:when test="${hasPdfSupport}">
        <m:set-content-disposition name="${value.Title}" suffix=".pdf" setFilenameOnly="${true}" />
        <c:set var="pdfLink">
            <cms:pdf
                format='%(link.weak:/system/modules/alkacon.mercury.template/elements/article-pdf.jsp:d6a236ad-4558-4628-b211-bcc7cff695b5)'
                content='${content.filename}'
                locale='${cms.locale}'
                filename="${contentDispositionFilename}"
            />
        </c:set>

        <m:nl />
        <div class="element pdf-download"><%----%>
            <a href="${pdfLink}"class="btn btn-block" target="pdf"><%----%>
                <fmt:message key="msg.page.button.pdf-download" />
            </a><%----%>
        </div><%----%>
        <m:nl />

    </c:when>

    <c:otherwise>
        <m:alert type="warning">
            <jsp:attribute name="head"><fmt:message key="msg.page.button.pdf-download" /></jsp:attribute>
            <jsp:attribute name="text"><fmt:message key="msg.page.button.pdf-download.disabled" /></jsp:attribute>
        </m:alert>
    </c:otherwise>

</c:choose>

</cms:bundle>