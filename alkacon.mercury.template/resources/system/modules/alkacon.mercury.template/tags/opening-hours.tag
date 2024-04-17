<%@ tag pageEncoding="UTF-8"
    display-name="opening-hours"
    body-content="scriptless"
    trimDirectiveWhitespaces="true"
    description="Displays opening hours." %>

<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessValueWrapper" required="true"
    description="The opening hours to display. Must be a nested opening hours content."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<div class="opening-hours">
    <div class="hours-table"><%----%>
        <c:forEach var="openingHour" items="${content.valueList.OpeningHour}">
            <div class="hours-hr"><%----%>
                <div class="hours-days"><%----%>
                    <c:set var="daysOfWeek" value="${openingHour.value.DaysOfWeek}" />
                    <c:choose>
                        <c:when test="${fn:contains(daysOfWeek, '-')}">
                            <c:set var="opnDays" value="${fn:split(daysOfWeek, '-')}" />
                            <span><fmt:message key="msg.weekday${opnDays[0]}" /></span><%----%>
                            <span> - </span><%----%>
                            <span><fmt:message key="msg.weekday${opnDays[1]}" /></span><%----%>
                        </c:when>
                        <c:when test="${fn:contains(daysOfWeek, '+')}">
                            <c:set var="opnDays" value="${fn:split(daysOfWeek, '+')}" />
                            <span><fmt:message key="msg.weekday${opnDays[0]}" /></span><%----%>
                            <span>, </span><%----%>
                            <span><fmt:message key="msg.weekday${opnDays[1]}" /></span><%----%>
                        </c:when>
                        <c:when test="${not empty daysOfWeek and daysOfWeek.toString.matches('[1-7]+')}">
                            <span><fmt:message key="msg.weekday${daysOfWeek}" /></span><%----%>
                        </c:when>
                        <c:otherwise>
                            <span>${daysOfWeek}</span>
                        </c:otherwise>
                    </c:choose>
                </div><%----%>
                <div class="hours-times"><%----%>
                    <c:forEach var="openingTime" items="${openingHour.valueList.OpeningTime}">
                        <div class="hours-time"><%----%>
                            <c:if test="${openingTime.value.Opens.isSet or openingTime.value.Closes.isSet}">
                                <span><%----%>
                                    <span class="hours-opens">${openingTime.value.Opens}</span><%----%>
                                    <span> - </span><%----%>
                                    <span class="hours-closes">${openingTime.value.Closes}</span><%----%>
                                </span><%----%>
                            </c:if>
                            <c:if test="${openingTime.value.OpenCloseLabel.isSet}">
                                <c:set var="label" value="${openingTime.value.OpenCloseLabel}" />
                                <c:choose>
                                    <c:when test="${label eq 'all-day-opened'}">
                                        <span><%----%>
                                            <fmt:message key="msg.option.allDayOpened" />
                                        </span><%----%>
                                    </c:when>
                                    <c:when test="${label eq 'all-day-closed'}">
                                        <span><%----%>
                                            <fmt:message key="msg.option.allDayClosed" />
                                        </span><%----%>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="hours-label">${label}</span><%----%>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                        </div><%----%>
                    </c:forEach>
                </div><%----%>
            </div><%----%>
        </c:forEach>
    </div><%----%>
    <c:if test="${not empty content.value.OpeningNote}">
        <div class="hours-note">${content.value.OpeningNote}</div><%----%>
    </c:if>
</div>
