<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.Collection"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Map"%>
<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true" %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams replaceInvalid="bad_param" />

<m:set-siteroot siteRoot="${param.siteroot}" sitePath="${param.sitepath}" />

<fmt:setLocale value="${cms.locale}" />

<c:set var="conf" value="${cms.vfs.readXml[param.contentpath]}" />

<c:if test="${not empty conf}">

    <%!
        public static class Helper {

            private HttpServletRequest m_req;

            private Map<String,Set<String>> m_map;

            public Helper(HttpServletRequest request) {
                m_req = request;
                m_map = new HashMap<>(5);
                addParamToMap("s");
                addParamToMap("f");
                addParamToMap("a");
                addParamToMap("c");
                addParamToMap("d");
            }

            private void addParamToMap(String paramKey) {
                Set<String> valueSet = new HashSet<>();
                m_map.put(paramKey, valueSet);
                String[] vals = m_req.getParameterValues(paramKey);
                if(vals != null && vals.length > 0) {
                    for(int i = 0; i < vals.length; i++) {
                        valueSet.add(vals[i]);
                    }
                }
            }

            public Set<String> getFolderFilters() {
                return m_map.get("f");
            }
            public Set<String> getCategoryFilters() {
                return m_map.get("c");
            }
            public Set<String> getArchiveFilters() {
                return m_map.get("a");
            }
            public Set<String> getSearchFilters() {
                return m_map.get("s");
            }
            public Set<String> getCalendarFilters() {
                return m_map.get("d");
            }

            public Set<String> getExcludeTags(String filterId, String filterType) {
                Set<String> tags = new HashSet<>();
                for (String key : m_map.keySet()) {
                    if(!key.equals(filterType) && m_map.get(key).contains(filterId)) {
                        tags.add(key.equals("s") ? "q" : (filterId + "_" + key));
                    }
                }
                return tags;
            }

            public Set<String> getElementIds() {
                return m_map.values().stream().flatMap(Collection::stream).collect(Collectors.toSet());
            }
}
    %>
    <c:set var="helper" value="<%= new Helper(request) %>" />
    <%-- make sure the 'en' locale is used to read the values of the list configuration --%>
    <c:set var="ignore" value="${conf.init(conf.cmsObject, cms.wrap['en'].toLocale, conf.rawContent, conf.file)}" />
    <c:set var="multiDay" value="${conf.value['FilterMultiDay'] eq 'true'}" />
    <c:choose>
    <c:when test="${multiDay}">
        <c:set var="rangeField">instancedaterange_${cms.locale}_dr</c:set>
    </c:when>
    <c:otherwise>
        <c:set var="rangeField">instancedate_${cms.locale}_dt</c:set>
    </c:otherwise>
    </c:choose>
    <cms:jsonarray var="fieldFacets">
        <c:forEach var="ff" items="${helper.folderFilters}">
            <cms:jsonobject>
                <cms:jsonvalue key="field">parent-folders</cms:jsonvalue>
                <cms:jsonvalue key="name">${ff}_f</cms:jsonvalue>
                <cms:jsonvalue key="mincount">1</cms:jsonvalue>
                <cms:jsonvalue key="limit" value="${500}"/>
                <cms:jsonvalue key="isAndFacet" value="${false}"/>
                <cms:jsonarray key="excludeTags">
                    <c:forEach var="tag" items="${helper.getExcludeTags(ff,'f')}">
                        <cms:jsonvalue>${tag}</cms:jsonvalue>
                    </c:forEach>
                </cms:jsonarray>
            </cms:jsonobject>
        </c:forEach>
        <c:forEach var="fc" items="${helper.categoryFilters}">
           <cms:jsonobject>
                <cms:jsonvalue key="field">category_exact</cms:jsonvalue>
                <cms:jsonvalue key="name">${fc}_c</cms:jsonvalue>
                <cms:jsonvalue key="mincount">1</cms:jsonvalue>
                <cms:jsonvalue key="limit" value="${500}"/>
                <cms:jsonarray key="excludeTags">
                    <c:forEach var="tag" items="${helper.getExcludeTags(fc,'c')}">
                        <cms:jsonvalue>${tag}</cms:jsonvalue>
                    </c:forEach>
                </cms:jsonarray>
            </cms:jsonobject>
        </c:forEach>
    </cms:jsonarray>
    <c:set var="facetConfig">"fieldfacets" : ${fieldFacets}</c:set>
    <c:if test="${not empty helper.archiveFilters or not empty helper.calendarFilters}">
        <cms:jsonarray var="rangeFacets">
            <c:if test="${not empty helper.archiveFilters}">
                <c:forEach var="fa" items="${helper.archiveFilters}">
                    <cms:jsonobject>
                        <cms:jsonvalue key="range">${rangeField}</cms:jsonvalue>
                        <cms:jsonvalue key="name">${fa}_a</cms:jsonvalue>
                        <cms:jsonvalue key="start">NOW/YEAR-20YEARS</cms:jsonvalue>
                        <cms:jsonvalue key="end">NOW/MONTH+5YEARS</cms:jsonvalue>
                        <cms:jsonvalue key="gap">+1MONTHS</cms:jsonvalue>
                        <cms:jsonvalue key="hardend">false</cms:jsonvalue>
                        <cms:jsonvalue key="mincount" value="1" />
                        <cms:jsonvalue key="isAndFacet" value="${false}"/>
                        <cms:jsonarray key="excludeTags">
                            <c:forEach var="tag" items="${helper.getExcludeTags(fa,'a')}">
                                <cms:jsonvalue>${tag}</cms:jsonvalue>
                            </c:forEach>
                        </cms:jsonarray>
                    </cms:jsonobject>
                </c:forEach>
            </c:if>
            <c:if test="${not empty helper.calendarFilters}">
                <c:forEach var="fd" items="${helper.calendarFilters}">
                    <cms:jsonobject>
                        <cms:jsonvalue key="range">${rangeField}</cms:jsonvalue>
                        <cms:jsonvalue key="name">${fd}_d</cms:jsonvalue>
                        <cms:jsonvalue key="start">NOW/YEAR-20YEARS</cms:jsonvalue>
                        <cms:jsonvalue key="end">NOW/MONTH+5YEARS</cms:jsonvalue>
                        <cms:jsonvalue key="gap">+1DAYS</cms:jsonvalue>
                        <cms:jsonvalue key="hardend">false</cms:jsonvalue>
                        <cms:jsonvalue key="mincount" value="1" />
                        <cms:jsonvalue key="isAndFacet" value="${false}"/>
                        <cms:jsonarray key="excludeTags">
                            <c:forEach var="tag" items="${helper.getExcludeTags(fd,'d')}">
                                <cms:jsonvalue>${tag}</cms:jsonvalue>
                            </c:forEach>
                        </cms:jsonarray>
                    </cms:jsonobject>
                </c:forEach>
            </c:if>
        </cms:jsonarray>
        <c:set var="facetConfig">${facetConfig}, "rangefacets" : ${rangeFacets}</c:set>
    </c:if>
    <%-- ####### Perform the search ################ --%>
    <m:list-search
        config="${conf}"
        subsite="${param.subsite}"
        count="0"
        addContentInfo="false"
        multiDayRangeFacet="${multiDay}"
        facetConfig="${facetConfig}"
    />

<cms:jsonobject var="result">
    <c:forEach var="filterId" items="${helper.elementIds}">
        <cms:jsonobject key="${filterId}" target="${result}">
            <c:forEach var="f" items="${search.fieldFacets}">
                    <c:set var="name" value="${f.name}"/>
                    <c:set var="fId" value="${name.substring(0,fn:length(name) - 2)}"/>
                    <c:if test="${fId eq filterId}">
                        <c:set var="filterType" value="${name.substring(fn:length(name) - 1)}"/>
                        <cms:jsonobject key="${filterType}">
                                <c:forEach var="c" items="${f.values}">
                                    <cms:jsonvalue key="${c.name}">${c.count}</cms:jsonvalue>
                                </c:forEach>
                        </cms:jsonobject>
                    </c:if>
            </c:forEach>
            <c:forEach var="f" items="${search.rangeFacets}">
                    <c:set var="name" value="${f.name}"/>
                    <c:set var="fId" value="${name.substring(0,fn:length(name) - 2)}"/>
                    <c:set var="filterType" value="${name.substring(fn:length(name) - 1)}"/>
                    <c:if test="${fId eq filterId}">
                        <cms:jsonobject key="${filterType}">
                                <c:forEach var="c" items="${f.counts}">
                                    <cms:jsonvalue key="${c.value}">${c.count}</cms:jsonvalue>
                                </c:forEach>
                        </cms:jsonobject>
                    </c:if>
            </c:forEach>
        </cms:jsonobject>
    </c:forEach>
</cms:jsonobject>
${result}
</c:if>