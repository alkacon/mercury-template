<%@ tag pageEncoding="UTF-8"
    display-name="list-badge"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a list badge." %>


<%@ attribute name="type" type="java.lang.String" required="false"
    description="Selects the bage type to generate." %>

<%@ attribute name="seriesInfo" type="org.opencms.jsp.util.CmsJspDateSeriesBean" required="false"
    description="Date series info for event-type badges." %>

<%@ attribute name="title" type="java.lang.String" required="false"
    description="Text to use in the generated 'title' attribute." %>

<%@ attribute name="markup" type="java.lang.String" required="false"
    description="Markup to use for the generated badge." %>

<%@ attribute name="test" type="java.lang.Boolean" required="false"
    description="The badge will only be generated in case this test returns 'true'." %>

<%@ attribute name="var" type="java.lang.String" required="true" rtexprvalue="false"
    description="The name of the variable to store the generated badge markup in." %>

<%@ variable alias="result" name-from-attribute="var" scope="AT_END" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${empty test or test}">

    <fmt:setLocale value="${cms.locale}" />
    <cms:bundle basename="alkacon.mercury.template.messages">

    <c:choose>
        <c:when test="${not empty seriesInfo and seriesInfo.isSeries}">
            <c:set var="result">
                <wbr><%----%>
                <span class="list-badge list-badge-series oct-meta-info" title="<%--
                --%><fmt:message key="msg.page.dateseries.series"><fmt:param>${seriesInfo.title}</fmt:param></fmt:message><%--
                --%>${empty title ? '' : ' ('.concat(title).concat(')')}<%--
                --%>"><%----%>
                    <m:icon icon="refresh" tag="span" />
                    ${empty markup ? '' : ' '.concat(markup)}
                </span><%----%>
            </c:set>
        </c:when>
        <c:when test="${not empty seriesInfo and seriesInfo.isExtractedDate}">
            <c:set var="result">
                <wbr><%----%>
                <span class="list-badge list-badge-extracted-date oct-meta-info" title="<%--
                --%><fmt:message key="msg.page.dateseries.extracted"><fmt:param>${seriesInfo.parentSeries.title}</fmt:param></fmt:message><%--
                --%>${empty title ? '' : ' ('.concat(title).concat(')')}<%--
                --%>"><%----%>
                    <m:icon icon="scissors" tag="span" />
                    ${empty markup ? '' : ' '.concat(markup)}
                </span><%----%>
            </c:set>
        </c:when>
        <c:when test="${type eq 'decoy'}">
            <c:set var="result">
                <wbr><%----%>
                <span class="list-badge list-badge-decoy oct-meta-info" title="<%--
                --%><fmt:message key="type.m-decoy.name" /><%--
                --%>${empty title ? '' : ' ('.concat(title).concat(')')}<%--
                --%>"><%----%>
                     <m:icon icon="external-link-square" tag="span" />
                     ${empty markup ? '' : ' '.concat(markup)}
                </span><%----%>
            </c:set>
        </c:when>
        <c:when test="${type eq 'order'}">
            <c:set var="result">
                <wbr><%----%>
                <span class="list-badge list-badge-order oct-meta-info" title="<%--
                --%><fmt:message key="label.Order" /><%--
                --%>">${markup}
                </span><%----%>
            </c:set>
        </c:when>
        <c:when test="${not empty title and not empty markup}">
            <c:set var="result">
                <wbr><%----%>
                <span class="list-badge list-badge-general oct-meta-info" title="${title}">${markup}</span><%----%>
            </c:set>
        </c:when>
    </c:choose>

    </cms:bundle>

</c:if>
