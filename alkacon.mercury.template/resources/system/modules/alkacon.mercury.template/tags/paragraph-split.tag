<%@ tag
    pageEncoding="UTF-8"
    display-name="paragraph-split"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Splits a list of paragraphs into sublists." %>


<%@ attribute name="paragraphs" type="java.util.List" required="true"
    description="The list of paragraphs to split." %>

<%@ attribute name="splitFirst" type="java.lang.Boolean" required="true"
    description="Controls if the first paragraph is split to a separate item." %>

<%@ attribute name="splitDownloads" type="java.lang.Boolean" required="true"
    description="Controls if downloads are split into a separate list." %>


<%@ variable name-given="firstParagraph" variable-class="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" declare="true"
    description="The first paragraphs of all paragraphs." %>

<%@ variable name-given="paragraphsContent" variable-class="java.util.List" declare="true"
    description="The paragraphs that contain mixed content." %>

<%@ variable name-given="paragraphsDownload" variable-class="java.util.List" declare="true"
    description="The paragraphs that contain only download links." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>


<c:set var="paragraphsContent" value="${cms:createList()}" />
<c:set var="paragraphsDownload" value="${cms:createList()}" />

<c:forEach var="paragraph" items="${paragraphs}" varStatus="status">

    <c:choose>
        <c:when test="${splitFirst and status.first}">
            <c:set var="firstParagraph" value="${paragraph}" />
        </c:when>
        <c:when test="${
            splitDownloads and
            (not paragraph.value.Caption.isSet or (empty paragraphsDownload)) and
            not paragraph.value.Text.isSet and
            not paragraph.value.Image.isSet and
            paragraph.value.Link.value.URI.isSet}">
            <%-- Paragraph that only has a link set --%>
            <c:set var="ignore" value="${paragraphsDownload.add(paragraph)}" />
        </c:when>
        <c:otherwise>
            <%-- Downloads must all be in the LAST paragraphs --%>
            <c:set var="ignore" value="${paragraphsContent.addAll(paragraphsDownload)}" />
            <c:set var="ignore" value="${paragraphsDownload.clear()}" />
            <c:set var="ignore" value="${paragraphsContent.add(paragraph)}" />
            <c:if test="${status.first}">
                <%-- Fill firstParagraph even if it is not split from rest of paragraphs --%>
                <c:set var="firstParagraph" value="${paragraph}" />
            </c:if>
        </c:otherwise>
    </c:choose>

</c:forEach>

<jsp:doBody />