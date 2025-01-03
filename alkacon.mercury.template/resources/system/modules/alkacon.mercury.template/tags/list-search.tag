<%@ tag pageEncoding="UTF-8"
    display-name="list-search"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates the list search configuration and triggers the search."%>

<%@ attribute name="config" type="org.opencms.jsp.util.CmsJspContentAccessBean" required="true"
    description="The list configuration." %>

<%@ attribute name="subsite" type="java.lang.String" required="false"
    description="The subsite the current request comes from. Is needed for AJAX requests because of a then differing context." %>

<%@ attribute name="count" type="java.lang.String" required="false"
    description="The amount of elements per page, if different for multiple pages, pass the page sizes hyphen separated for each page.
     The last size will be the page size for all remaining pages. E.g., use '5-8' to get the first page with five elements, all others with 8." %>

<%@ attribute name="addContentInfo" type="java.lang.Boolean" required="false"
    description="Controls if the list content info required for finding deleted items when publishing 'this page' is added to the generated HTML. Default is 'false'." %>

<%@ attribute name="multiDayRangeFacet" type="java.lang.Boolean" required="false"
    description="Whether the range facet shall return all days of a multi-day event or the start day only." %>

<%@ attribute name="facetConfig" type="java.lang.String" required="false"
    description="If provided, we overwrite the facet config. We do not return results, but only use this to determine the facet counts." %>

<%@ variable name-given="search" scope="AT_END" declare="true" variable-class="org.opencms.jsp.search.result.I_CmsSearchResultWrapper"
    description="The results of the search" %>

<%@ variable name-given="searchConfig" scope="AT_END" declare="true"
    description="The configuration string that was used in the search." %>


<%@ variable name-given="categoryPaths" scope="AT_END" declare="true" %>
<%@ variable name-given="categoryFacetField" scope="AT_END" declare="true" %>
<%@ variable name-given="rangeFacetField" scope="AT_END" declare="true" %>
<%@ variable name-given="categoryFacetController" scope="AT_END" declare="true" variable-class="org.opencms.jsp.search.controller.I_CmsSearchControllerFacetField" %>
<%@ variable name-given="categoryFacetResult" scope="AT_END" declare="true" variable-class="org.apache.solr.client.solrj.response.FacetField" %>
<%@ variable name-given="folderFacetController" scope="AT_END" declare="true" variable-class="org.opencms.jsp.search.controller.I_CmsSearchControllerFacetField" %>
<%@ variable name-given="folderFacetResult" scope="AT_END" declare="true" variable-class="org.apache.solr.client.solrj.response.FacetField" %>
<%@ variable name-given="rangeFacetController" scope="AT_END" declare="true" variable-class="org.opencms.jsp.search.controller.I_CmsSearchControllerFacetRange" %>
<%@ variable name-given="rangeFacet" scope="AT_END" declare="true" variable-class="org.apache.solr.client.solrj.response.RangeFacet" %>
<%@ variable name-given="folderpath" scope="AT_END" declare="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>

<c:set var="multiDay" value="${not empty multiDayRangeFacet and multiDayRangeFacet eq true}" />
<c:set var="isFacetCountQuery" value="${not empty facetConfig}"/>
<c:set var="categoryFacetField">category_exact</c:set>
<c:set var="rangeFacetField">instancedate</c:set>
<c:set var="folderFacetField">parent-folders</c:set>
<c:set var="coordinatesField">geocoords_loc</c:set>
<c:set var="isSortGeodist" value="${not empty param.geodist and not empty param.coordinates}" />
<c:set var="geodistAdditionalParams">{ "param" : "coordinates", "solrquery" : "sfield=${coordinatesField}&pt=${param.coordinates}&d=${param.radius}&fl=_geodist_:geodist()" }</c:set>
<c:set var="geodistSortOptions">"sortoptions" : [{"solrvalue" : "geodist() asc" }]</c:set>
<c:choose>
    <c:when test="${multiDay eq true}">
        <c:set var="instancedaterangefield">instancedaterange_${cms.locale}_dr</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="instancedaterangefield">instancedate_${cms.locale}_dt</c:set>
    </c:otherwise>
</c:choose>

<c:set var="pageSize">100</c:set>
<c:if test="${not empty count}"><c:set var="pageSize">${count}</c:set></c:if>


<%-- ########################################### --%>
<%-- ####### Build search config JSON   ######## --%>
<%-- ########################################### --%>

<c:set var="searchConfig">
{
    "pagesize" : "${pageSize}",
    "pagenavlength" : 5,
    "additionalrequestparams" : [
        { "param" : "calendarday", "solrquery" : "fq={!tag%3Dcalendarday}${instancedaterangefield}:(%(value))" }
        <c:if test="${isSortGeodist}">, ${geodistAdditionalParams}</c:if>
    ],
    "geofilter" : {
        "coordinates": "${param.coordinates}",
        "radius" : "${param.radius}"
    },
    "rangefacets": [
        <c:if test="${not empty param.calendarday}">
        {
            "range": "${instancedaterangefield}",
            "name": "calendarday",
            "start": "NOW",
            "end": "NOW",
            "gap" : "+1DAYS",
            "mincount": 1
        }
        </c:if>
    ]
    <c:if test="${isSortGeodist}">, ${geodistSortOptions}</c:if>
    <c:if test="${isFacetCountQuery}">, ${facetConfig}</c:if>
}
</c:set>

<%-- ############################################# --%>
<%-- ####### Perform search based on JSON ######## --%>
<%-- ############################################# --%>
<cms:simplesearch
    var="searchResultWrapper"
    configFile="${config.filename}"
    configString="${searchConfig}"
    addContentInfo="${addContentInfo}"
/>

<c:set var="search" value="${searchResultWrapper}" />
<c:set var="categoryFacetController" value="${search.controller.fieldFacets.fieldFacetController[categoryFacetField]}" />
<c:set var="categoryFacetResult" value="${search.fieldFacet[categoryFacetField]}" />
<c:set var="rangeFacetController" value="${search.controller.rangeFacets.rangeFacetController[rangeFacetField]}" />
<c:set var="rangeFacet" value="${search.rangeFacet[rangeFacetField]}" />
<c:set var="folderFacetController" value="${search.controller.fieldFacets.fieldFacetController[folderFacetField]}" />
<c:set var="folderFacetResult" value="${search.fieldFacet[folderFacetField]}" />
