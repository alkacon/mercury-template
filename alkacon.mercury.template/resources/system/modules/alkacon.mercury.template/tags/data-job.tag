<%@ tag pageEncoding="UTF-8"
    display-name="data-job"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates schema.org data for jobs." %>


<%@ attribute name="content" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The XML content to use for data generation."%>

<%@ attribute name="showSummary" type="java.lang.Boolean" required="false"
    description="If 'true', a summary of the data is displayed on the page."%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<%-- Using the same logic as the elaborate display teaser --%>
<c:set var="value"              value="${content.value}" />

<c:set var="paragraphIntro"     value="${value.Introduction}" />
<c:set var="paragraphText"      value="${content.valueList.Text['0']}" />

<c:choose>
    <c:when test="${value['MetaInfo/Title'].isSet}">
        <c:set var="intro"          value="${null}" />
        <c:set var="title"          value="${value['MetaInfo/Title']}" />
    </c:when>
    <c:otherwise>
        <c:set var="intro"          value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
        <c:set var="title"          value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
    </c:otherwise>
</c:choose>
<c:choose>
    <c:when test="${value['MetaInfo/Description'].isSet}">
        <c:set var="description"    value="${value['MetaInfo/Description']}" />
    </c:when>
    <c:otherwise>
        <c:set var="description"    value="${paragraphIntro.value.Text.isSet ? paragraphIntro.value.Text : paragraphText.value.Text}" />
    </c:otherwise>
</c:choose>
<c:choose>
    <c:when test="${value['MetaInfoJob/ValidThrough'].isSet}">
        <c:set var="validThrough"   value="${value['MetaInfoJob/ValidThrough']}" />
    </c:when>
    <c:when test="${value['Availability/Expiration'].isSet}">
        <c:set var="validThrough"   value="${value['Availability/Expiration']}" />
    </c:when>
</c:choose>
<c:choose>
    <c:when test="${value.Date.isSet}">
        <c:set var="datePosted"     value="${value.Date}" />
    </c:when>
    <c:when test="${value['Availability/Release'].isSet}">
        <c:set var="datePosted"     value="${value['Availability/Release']}" />
    </c:when>
</c:choose>

<c:set var="image"                  value="${paragraphIntro.value.Image.isSet ? paragraphIntro.value.Image : paragraphText.value.Image}" />

<c:set var="url">${cms.site.url}<cms:link>${content.filename}</cms:link></c:set>

<%--
# JSON-LD Generation for Mercury job posting.
# See: https://schema.org/JobPosting
# See: https://developers.google.com/search/docs/data-types/job-posting
--%>
<cms:jsonobject var="jsonLd">
    <cms:jsonvalue key="@context" value="http://schema.org" />
    <cms:jsonvalue key="@type" value="JobPosting" />
    <cms:jsonvalue key="url" value="${url}" />
    <cms:jsonvalue key="mainEntityOfPage" value="${url}" />

    <cms:jsonvalue key="title">
        <c:if test="${not empty intro}">
            <c:out value="${intro.toString.concat(': ')}" />
        </c:if>
        <c:out value="${title}" />
    </cms:jsonvalue>
    <c:set var="hasTitle" value="${not empty title}" />

    <c:if test="${not empty datePosted}">
        <cms:jsonvalue key="datePosted"><fmt:formatDate value="${cms:convertDate(datePosted)}" pattern="yyyy-MM-dd" /></cms:jsonvalue>
        <c:set var="hasDatePosted" value="${true}" />
    </c:if>

    <c:if test="${not empty validThrough}">
        <cms:jsonvalue key="validThrough"><fmt:formatDate value="${cms:convertDate(validThrough)}" pattern="yyyy-MM-dd" /></cms:jsonvalue>
        <c:set var="hasValidThrough" value="${true}" />
    </c:if>

    <c:if test="${description.isSet}">
        <cms:jsonvalue key="description" value="${description}" />
        <c:set var="hasDescription" value="${true}" />
    </c:if>

    <c:if test="${image.isSet}">
        <mercury:image-vars image="${image}" createJsonLd="${true}">
            <cms:jsonvalue key="image" value="${imageJsonLd}" />
        </mercury:image-vars>
    </c:if>

    <mercury:location-vars data="${value.AddressChoice}" createJsonLd="${true}">
        <cms:jsonvalue key="jobLocation" value="${locJsonLd}" />
        <c:set var="hasJobLocation" value="${(not empty locJsonLd) and (not empty locJsonLd.opt('address'))}" />
    </mercury:location-vars>

    <c:if test="${value['MetaInfoJob/EmploymentType'].isSet}">
        <cms:jsonarray key="employmentType">
            <c:forEach var="employmentType" items="${content.valueList['MetaInfoJob/EmploymentType']}">
                 <cms:jsonvalue value="${employmentType.toString}" />
                <c:set var="hasEmploymentType" value="${true}" />
            </c:forEach>
        </cms:jsonarray>
    </c:if>

    <c:set var="salary" value="${value['MetaInfoJob/BaseSalary']}" />
    <c:if test="${salary.isSet}">
        <cms:jsonobject key="baseSalary">
            <cms:jsonvalue key="@type" value="MonetaryAmount" />
            <cms:jsonvalue key="currency" value="${salary.value.Currency.isSet ? salary.value.Currency.toString : 'EUR'}" />
            <cms:jsonobject key="value">
                <cms:jsonvalue key="@type" value="QuantitativeValue" />
                <cms:jsonvalue key="unitText" value="${salary.value.UnitText.isSet ? salary.value.UnitText.toString : 'YEAR'}" />
                <c:set var="minValue" value="${salary.value.MinValue.isSet ? salary.value.MinValue.toString : null}" />
                <c:set var="maxValue" value="${salary.value.MaxValue.isSet ? salary.value.MaxValue.toString : null}" />
                <c:choose>
                    <c:when test="${empty maxValue}">
                        <cms:jsonvalue key="value" value="${minValue}" />
                    </c:when>
                    <c:otherwise>
                        <cms:jsonvalue key="minValue" value="${minValue}" />
                        <cms:jsonvalue key="maxValue" value="${maxValue}" />
                    </c:otherwise>
                </c:choose>
            </cms:jsonobject>
        </cms:jsonobject>
    </c:if>
    <c:set var="hasBaseSalary" value="${not empty minValue}" />

    <c:choose>
        <c:when test="${value['MetaInfoJob/HiringOrganization'].isSet}">
            <mercury:data-organization content="${value['MetaInfoJob/HiringOrganization'].toResource.toXml}" showContactAndImage="${false}" useSameAsUrl="${true}" storeOrgJsonLdObject="${true}" />
            <cms:jsonvalue key="hiringOrganization" value="${orgJsonLd}" />
            <c:set var="hasHringOrganization" value="${(not empty orgJsonLd) and (not empty orgJsonLd.opt('name'))}" />
        </c:when>
        <c:otherwise>
            <mercury:data-organization-vars content="${content}">
                <cms:jsonvalue key="hiringOrganization" value="${orgJsonLd}" />
                <c:set var="hasHringOrganization" value="${(not empty orgJsonLd) and (not empty orgJsonLd.opt('name'))}" />
            </mercury:data-organization-vars>
        </c:otherwise>
    </c:choose>
</cms:jsonobject>


<mercury:nl />
<script type="application/ld+json">${cms.isOnlineProject ? jsonLd.compact : jsonLd.pretty}</script><%----%>
<mercury:nl />

<c:if test="${showSummary and cms.isEditMode}">
    <c:set var="parentId"><mercury:idgen prefix="-" uuid="${cms.element.instanceId}" /></c:set>
    <c:set var="isValid" value="${hasTitle and hasDatePosted and hasDescription and hasJobLocation and hasHringOrganization}" />
    <c:set var="hasAllOptions" value="${hasValidThrough and hasEmploymentType and hasBaseSalary}" />
    <div class="subelement oct-meta-infos box ${isValid ? (hasAllOptions ? 'box-oct-info' : 'box-oct-warning') : 'box-oct-error'}"><%----%>
        <div><%----%>
            <c:choose>
                <c:when test="${not isValid}">
                    <div class="h3"><fmt:message key="msg.page.meta-info.options-invalid" /></div><%----%>
                </c:when>
                <c:when test="${not hasAllOptions}">
                    <div class="h3"><fmt:message key="msg.page.meta-info.options-missing" /></div><%----%>
                </c:when>
                <c:otherwise>
                    <button class="btn" type="button" data-bs-toggle="collapse" data-bs-target="#metaInfos${parentId}" aria-expanded="false" aria-controls="metaInfos${parentId}"><%----%>
                        <fmt:message key="msg.page.meta-info.show" />
                    </button><%----%>
                </c:otherwise>
            </c:choose>
        </div><%----%>
        <div class="collapse mt-sm${not isValid or not hasAllOptions ? ' show' : ''}" id="metaInfos${parentId}"><%----%>
            <div class="box box-body"><%----%>
                <mercury:data-meta-check valid="${hasTitle}" label="label.Title" />
                <mercury:data-meta-check valid="${hasDatePosted}" label="label.Job.Date" />
                <mercury:data-meta-check valid="${hasDescription}" label="label.Description" />
                <mercury:data-meta-check valid="${hasJobLocation}" label="label.AddressChoice" />
                <mercury:data-meta-check valid="${hasHringOrganization}" label="label.Job.HiringOrganization" />
                <mercury:data-meta-check valid="${hasValidThrough}" optional="${true}" label="label.Job.ValidThrough" />
                <mercury:data-meta-check valid="${hasEmploymentType}" optional="${true}" label="label.Job.EmploymentType" />
                <mercury:data-meta-check valid="${hasBaseSalary}" optional="${true}" label="label.Job.BaseSalary" />
            </div><%----%>
            <div class="mt-sm"><%----%>
                <div><%----%>
                    <button class="btn btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#metaInfoPre${parentId}" aria-expanded="false" aria-controls="metaInfoPre${parentId}"><%----%>
                        <fmt:message key="msg.page.meta-info.show-json" />
                    </button><%----%>
                </div><%----%>
                <div class="collapse box box-body mt-sm" id="metaInfoPre${parentId}"><%----%>
                    <pre><c:out value="${jsonLd.pretty}" /></pre><%----%>
                </div><%----%>
            </div><%----%>
        </div><%----%>
    </div><%----%>
    <mercury:nl />
</c:if>
