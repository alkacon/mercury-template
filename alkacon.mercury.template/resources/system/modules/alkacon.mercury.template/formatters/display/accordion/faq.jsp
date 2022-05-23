<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages>
<cms:formatter var="content" val="value">

<mercury:teaser-accordion
    title="${value.Question}"
    cssWrapper="type-faq"
    paragraphs="${content.valueList.Paragraph}"
    contentId="${content.id}"
/>

<c:if test="${listGeneratedJson != null}">
    <%-- listGeneratedJson is a request scoped variable of type JSONObject set in list-main.tag --%>
    <%-- NOTE: check must be for explicit null value, 'not empty listGeneratedJson' is not correct here --%>
    <c:if test="${not listGeneratedJson.object.has('mainEntity')}">
        <cms:jsonvalue key="@context" value="https://schema.org" target="${listGeneratedJson}" />
        <cms:jsonvalue key="@type" value="FAQPage" target="${listGeneratedJson}" />
        <cms:jsonarray key="mainEntity" target="${listGeneratedJson}" />
    </c:if>
    <c:set var="mainEntity" value="${listGeneratedJson.object.get('mainEntity')}" />
    <cms:jsonobject target="${mainEntity}">
        <cms:jsonvalue key="@type" value="Question" />
        <cms:jsonvalue key="name" value="${value.Question}" />
        <c:set var="answerText">
            <c:if test="${not empty value.Paragraph.value.Caption}">
                <mercury:heading level="${1}" text="${value.Paragraph.value.Caption}" />
            </c:if>
            <c:if test="${not empty value.Paragraph.value.Text}">
                ${value.Paragraph.value.Text}
            </c:if>
            <c:if test="${not empty value.Paragraph.value.Link}">
                <mercury:link link="${value.Paragraph.value.Link}" noExternalMarker="${true}" newWin="${false}" />
            </c:if>
        </c:set>
        <cms:jsonobject key="acceptedAnswer">
            <cms:jsonvalue key="@type" value="Answer" />
            <cms:jsonvalue key="text" value="${answerText}" />
        </cms:jsonobject>
    </cms:jsonobject>
</c:if>

</cms:formatter>
</mercury:init-messages>