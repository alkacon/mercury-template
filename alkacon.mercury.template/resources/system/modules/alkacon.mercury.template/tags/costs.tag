<%@ tag pageEncoding="UTF-8"
    display-name="costs"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays cost data in form of a responsive table" %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The event content to show the costs data for." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="false"
    description="The heading level of the contact headline. Default is '2'." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:set var="hsize"              value="${empty hsize ? 2 : hsize}"/>
<c:set var="showCosts"          value="${content.value.Costs.isSet and (content.value.Costs.value.Price.isSet or content.value.Costs.value.Label.isSet)}" />
<c:set var="showLabelOnly"      value="${content.valueList.Costs.size() eq 1 and not content.value.Costs.value.Price.isSet}" />

<c:if test="${showCosts}">

<div class="detail-content event-costs pivot"><%----%>

    <fmt:message key="msg.page.event.costs" var="costsHeading" />
    <m:heading level="${hsize+1}" text="${costsHeading}" css="ev-cost-heading" />

    <div class="cost-table"><%----%>
        <c:choose>
            <c:when test="${showLabelOnly}">
                <div>${content.value.Costs.value.Label}</div>
            </c:when>
            <c:otherwise>
                <c:forEach var="costs" items="${content.valueList.Costs}">
                    <div class="ct-category"><%----%>
                        <div class="ct-price"><%----%>
                            <c:set var="priceVal" value="${cms.wrap[fn:replace(costs.value.Price.toString, ',', '.')].toFloat}" />
                            <c:set var="currencyVal" value="${empty costs.value.Currency ? 'EUR' : costs.value.Currency}" />
                            <c:catch var="formatException">
                                <fmt:formatNumber value="${priceVal}" currencyCode="${currencyVal}" type="currency" />
                            </c:catch>
                            <c:if test="${not empty formatException}">
                                <fmt:formatNumber value="${priceVal}" currencyCode="EUR" type="currency" />
                            </c:if>
                        </div><%----%>
                        <div class="ct-class"><%----%>
                            <c:out value="${costs.value.Label}" />
                        </div><%----%>
                        <c:if test="${costs.value.LinkToPaymentService.isSet}">
                            <div class="ct-link"><%----%>
                                <m:link link="${costs.value.LinkToPaymentService}" />
                            </div><%----%>
                        </c:if>
                    </div><%----%>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div><%----%>
</div><%----%>
<m:nl />

</c:if>
