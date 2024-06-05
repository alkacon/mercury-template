<%@ tag pageEncoding="UTF-8"
    display-name="facility-icons"
    body-content="tagdependent"
    trimDirectiveWhitespaces="true"
    description="Displays a list of icons for facilities." %>


<%@ attribute name="css" type="java.lang.String" required="false"
    description="Optional CSS classes added to the generated accessible icon div." %>

<%@ attribute name="useTooltip" type="java.lang.Boolean" required="false"
    description="Optional make this a Boostrap tooltip." %>

<%@ attribute name="wheelchairAccess" type="java.lang.Boolean" required="false"
    description="Show the wheelchair access icon" %>

<%@ attribute name="hearingImpaired" type="java.lang.Boolean" required="false"
    description="Show the hearing impaired icon" %>

<%@ attribute name="lowVision" type="java.lang.Boolean" required="false"
    description="Show the low vision icon" %>

<%@ attribute name="publicRestrooms" type="java.lang.Boolean" required="false"
    description="Show the public restrooms icon" %>

<%@ attribute name="publicRestroomsAccessible" type="java.lang.Boolean" required="false"
    description="Show the public restrooms accessible icon" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<c:if test="${wheelchairAccess or hearingImpaired or lowVision or publicRestrooms or publicRestroomsAccessible}">

    <c:if test="${useTooltip}">
        <c:set var="tooltip" value=" tabindex=\"0\" data-bs-toggle=\"tooltip\"" />
    </c:if>

    <div class="facility-icons${not empty css ? ' '.conact(css) : ''}"><%----%>
        <c:if test="${wheelchairAccess}">
            <div title="<fmt:message key='label.Facility.WheelchairAccess' />" class="acc-icon"${tooltip}><%----%>
                <span class="acc-inner"><%----%>
                    <m:icon icon="wheelchair" tag="span" />
                    </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${hearingImpaired}">
            <div title="<fmt:message key='label.Facility.HearingImpaired' />" class="acc-icon"${tooltip}><%----%>
                <span class="acc-inner"><%----%>
                    <m:icon icon="assistive-listening-systems" tag="span" />
                </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${lowVision}">
            <div title="<fmt:message key='label.Facility.LowVision' />" class="acc-icon"${tooltip}><%----%>
                <span class="acc-inner"><%----%>
                    <m:icon icon="low-vision" tag="span" />
                </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${publicRestrooms}">
            <div title="<fmt:message key='label.Facility.PublicRestrooms' />" class="acc-icon"${tooltip}><%----%>
                <span class="acc-inner"><%----%>
                    <m:icon icon="male" tag="span" cssWrapper="acc-male" />
                    <m:icon icon="female" tag="span" cssWrapper="acc-female" />
                </span><%----%>
            </div><%----%>
        </c:if>
        <c:if test="${publicRestroomsAccessible}">
            <div title="<fmt:message key='label.Facility.PublicRestroomsAccessible' />" class="acc-icon"${tooltip}><%----%>
                <span class="acc-inner acc-wc"><%----%>
                    <m:icon icon="wheelchair" tag="span" />
                </span><%----%>
                <span class="acc-add acc-wc"><%----%>
                    <m:icon icon="male" tag="span" cssWrapper="acc-male" />
                    <m:icon icon="female" tag="span" cssWrapper="acc-female" />
                </span><%----%>
            </div><%----%>
        </c:if>
    </div><%----%>
    <m:nl />
</c:if>