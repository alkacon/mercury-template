<%@ tag pageEncoding="UTF-8"
    display-name="paragraphs-alternating"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Helper for lists of paragraphs with alternating images." %>


<%@ attribute name="paragraphs" type="java.util.List" required="true"
    description="The list of paragraphs to show." %>

<%@ attribute name="baseLayout" type="java.lang.Integer" required="true"
    description="The basic layout option for the paragraphs.
    If the image is displayed left or right this may be alternated.
    The calculated layout option to use is stored in the body variable 'paragraphLayout'." %>

<%@ attribute name="layoutAlternating" type="java.lang.Boolean" required="true"
    description="Controls if the paragraph images are alternating or not." %>

<%@ attribute name="skipFirstParagraphImage" type="java.lang.Boolean" required="false"
    description="Controls if the image in the first paragraph is ignored for the alternation.
    This is required e.g. in case the first image is displayed as a key visual on detail pages
    and not in the paragraph." %>


<%@ variable name-given="paragraphLayout" declare="true"
    description="The piece layout option to use in the body." %>

<%@ variable name-given="paragraph" declare="true"
    description="." %>

<%@ variable name-given="status" declare="true"
    description="Is 'true' in case the iterated paragraph is the first." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${not empty paragraphs}">

    <c:set var="imageCount" value="${0}" />
    <c:set var="paragraphLayout" value="${baseLayout}" />

    <c:forEach var="paragraph" items="${paragraphs}" varStatus="status">

        <c:if test="${layoutAlternating}">
            <c:if test="${
                paragraph.value.Image.isSet
                and not (status.first and skipFirstParagraphImage)
                and not (empty paragraph.value.Caption and empty paragraph.value.Text and empty paragraph.value.Link)
                }">
                <c:set var="imageCount" value="${imageCount + 1}" />
            </c:if>
            <c:set var="paragraphLayout" value="${(imageCount % 2) eq 1 ? baseLayout : [0,1,3,2,5,4,7,6,9,8,10,11].get(baseLayout)}" />
        </c:if>

        <jsp:doBody />

    </c:forEach>
</c:if>
