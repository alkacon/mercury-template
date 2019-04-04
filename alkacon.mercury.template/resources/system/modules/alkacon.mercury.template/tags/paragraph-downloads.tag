<%@ tag
    pageEncoding="UTF-8"
    display-name="paragraph-downloads"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates a download list from paragraphs." %>


<%@ attribute name="paragraphs" type="java.util.List" required="true"
    description="The list of paragraphs to generate the dowload list from." %>

<%@ attribute name="icon" type="java.lang.String" required="false"
    description="The font awesome icon to use." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the title displayed above the download list." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="icon" value="${empty icon ? 'cloud-download' : icon}" />

<c:if test="${not empty paragraphs}">
    <mercury:nl/>
    <div class="subelement type-linksequence ls-bullets custom-icon"><%----%>

        <mercury:heading text="${paragraphs['0'].value.Caption}" level="${empty hsize ? 3 : hsize}" />

        <ul><%----%>
        <c:forEach var="paragraph" items="${paragraphs}" varStatus="status">
            <c:set var="link" value="${paragraph.value.Link}" />
            <mercury:nl />
            <li class="fa-${icon}"><%----%>
                <mercury:link link="${link}" newWin="true" />
            </li><%----%>
        </c:forEach>
        <mercury:nl />
        </ul><%----%>

    </div><%----%>
    <mercury:nl/>
</c:if>