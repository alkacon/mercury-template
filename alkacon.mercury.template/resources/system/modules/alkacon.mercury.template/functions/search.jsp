<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<cms:secureparams />
<mercury:init-messages reload="true">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<%-- Generate the search configuration --%>
<c:choose>
    <c:when test="${cms.element.setting.searchscope eq 'subsite'}">
        <c:set var="searchscope" value="${cms.requestContext.siteRoot}${cms.subSitePath}" />
    </c:when>
    <c:otherwise>
        <c:set var="searchscope" value="${cms.requestContext.siteRoot}/" />
    </c:otherwise>
</c:choose>
<c:set var="types"><%--
    --%>binary<%--
    --%>,containerpage<%--
    --%>,plain<%--
 --%></c:set>

<%-- automatically determine the types to search for by the availability of detail pages. --%>
<c:set var="adeManager" value="<%= org.opencms.main.OpenCms.getADEManager() %>" />
<c:set var="adeConfig" value="${adeManager.lookupConfiguration(cms.vfs.cmsObject, cms.pageResource.rootPath)}" />

<c:choose>
    <c:when test="${not empty adeConfig.defaultDetailPage}">
        <c:set var="allAvailableTypes" value="${adeConfig.resourceTypes}" />
        <c:forEach var="type" items="${allAvailableTypes}">
            <c:if test="${not type.detailPagesDisabled}">
                <c:set var="types">${types},${type.typeName}</c:set>
            </c:if>
        </c:forEach>
    </c:when>
    <c:otherwise>
    <c:set var="detailPages" value="${adeConfig.allDetailPages}" />
        <c:forEach var="page" items="${detailPages}">
            <c:if test="${not fn:startsWith(page.type,'function@')}">
                <c:set var="types">${types},${page.type}</c:set>
            </c:if>
        </c:forEach>
    </c:otherwise>
</c:choose>

<c:set var="typesRestriction" value="" />
<c:forEach var="type" items="${fn:split(types,',')}" varStatus="status">
    <c:set var="typesRestriction">${typesRestriction}${status.first ? '' : ' OR '}${fn:trim(type)}</c:set>
</c:forEach>

<c:set var="returnFields">disptitle_${cms.locale}_sort,disptitle_sort,${cms.locale}_excerpt,id,path</c:set>
<c:set var="config">
    {
        "searchforemptyquery" : true,
        "querymodifier" :       "{!type=edismax qf=\"content_${cms.locale} Title_dprop Description_dprop\"}%(query)",
        "escapequerychars" :    true,
        "extrasolrparams" :     "fq=parent-folders:\"${searchscope}\"&fq=type:(${typesRestriction})&fq=con_locales:${cms.locale}&spellcheck.dictionary=${cms.locale}&fq=-filename:\"mega.menu\"&fl=${returnFields}",
        "pagesize" :            10,
        "pagenavlength" :       5,
        "sortoptions" :         [ { "label" : "<fmt:message key='msg.page.search.sort.score.desc'/>", "solrvalue" : "score desc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.date.desc'/>", "solrvalue" : "instancedate_${cms.locale}_dt desc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.date.asc'/>", "solrvalue" : "instancedate_${cms.locale}_dt asc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.title.asc'/>", "solrvalue" : "disptitle_${cms.locale}_sort asc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.title.desc'/>", "solrvalue" : "disptitle_${cms.locale}_sort desc" }
                                ],
        "fieldfacets" :         [ { "field" : "type", "label" : "<fmt:message key="msg.page.search.facet.type"/>", "mincount" : 1, "limit" : 5 }
                                , { "field" : "category_exact", "label" : "<fmt:message key="msg.page.search.facet.category"/>", "mincount" : 1, "order" : "index" }
                                ],
        "highlighter" :         {
                                    "field" :                       "content_${cms.locale}",
                                    "alternateField":				"content_${cms.locale}",
                                    "maxAlternateFieldLength":		250,
                                    "fragsize" :                    250,
                                    "simple.pre" :                  "$$hl.begin$$",
                                    "simple.post" :                 "$$hl.end$$",
                                    "useFastVectorHighlighting" :   true
                                },
        "didYouMean" :          {
                                    "didYouMeanCollate" :   false,
                                    "didYouMeanCount" :     5
                                }
    }
</c:set>

<%-- get the search form object containing results and controller --%>
<cms:search var="search" configString="${config}" />

<%-- short cut to access the controllers --%>
<c:set var="controllers" value="${search.controller}" />

<%-- short cut to access the controller for common search settings --%>
<c:set var="common" value="${controllers.common}" />
<c:set var="id"><mercury:idgen prefix="" uuid="${cms.element.id}" /></c:set>

<mercury:nl/>
<div class="element type-search ${cms.element.settings.cssWrapper}"><%----%>
    <mercury:nl/>

    <%-- Uncomment the following div for debugging --%>
    <%--<div>locale: ${cms.locale}</div>

        <pre>${config}</pre>
        <div>${cms:escapeHtml(search.finalQuery)}</div>
     --%>
    <%-- The search form --%>
    <%-- search action: link to the current page --%>
    <form<%--
        --%> id="search-form"<%--
        --%> role="form"<%--
        --%> class="styled-form no-border"<%--
        --%> action="<cms:link>${cms.requestContext.uri}</cms:link>"<%--
        --%>><%----%>

        <%-- important: send this hidden field to have proper resetting of checked facet values and pagination --%>
        <c:set var="escapedQuery">${fn:replace(common.state.query,'"','&quot;')}</c:set>
        <input type="hidden" name="${common.config.lastQueryParam}" value="${escapedQuery}" /><%----%>
        <input type="hidden" name="${common.config.reloadedParam}" /><%----%>

        <%-- choose layout dependent on the presence of search options --%>
        <c:set var="hasSortOptions" value="${cms:getListSize(controllers.sorting.config.sortOptions) > 0}" />
        <c:set var="colWidthInput" value="${hasSortOptions?4:12}" />

        <mercury:nl/>
        <div class="row search-options-row"><%----%>
            <mercury:nl/>
            <div class="col-12 col-md-${colWidthInput} search-input"><%----%>
                <section class="input-group"><%----%>
                    <div class="input button"><%----%>
                        <label for="searchFormQuery" class="sr-only">Search</label><%----%>
                        <input id="searchFormQuery" name="${common.config.queryParam}" <%--
                            --%>value="${escapedQuery}" class="form-control blur-focus" type="text" autocomplete="off" <%--
                            --%>placeholder="<fmt:message key='msg.page.search.enterquery' />" /><%----%>
                        <button class="btn" type="submit"><fmt:message key="msg.page.search.submit" /></button><%----%>
                    </div><%----%>
                </section><%----%>
            </div><%----%>
            <c:if test="${hasSortOptions}">
                <mercury:nl/>
                <c:set var="sort" value="${controllers.sorting}" />
                <div class="col-12 col-md-8 search-sort-options"><%----%>
                    <div class="select"><%----%>
                        <%-- Display select box with sort options where the currently chosen option is selected --%>
                        <select name="${sort.config.sortParam}" class="form-control" onchange="submitSearchForm()"><%----%>
                        <mercury:nl/>
                            <c:forEach var="option" items="${sort.config.sortOptions}">
                                <option value="${option.paramValue}" ${sort.state.checkSelected[option]?"selected":""}>${option.label}</option><%----%>
                                <mercury:nl/>
                            </c:forEach>
                        </select><%----%>
                        <i></i><%----%>
                    </div><%----%>
                </div><%----%>
            </c:if>
        </div><%----%>
        <mercury:nl/>

        <div class="row search-result-row"><%----%>
            <c:set var="hasFacets" value="${(cms:getListSize(search.fieldFacets) > 0) or (not empty search.facetQuery)}" />
            <c:if test="${hasFacets}">
                <%-- Facets --%>
                <mercury:nl/>
                <div class="col-md-4 col-12 search-facets"><%----%>
                <div class="type-list-filter"><%----%>

                    <%-- Query facet --%>
                    <c:if test="${(not empty controllers.queryFacet) and (not empty search.facetQuery)}">
                        <c:set var="facetController" value="${controllers.queryFacet}" />
                        <div class="filterbox facet-query">
                            <button type="button" <%--
                            --%>class="btn btn-block li-label" <%--
                            --%>data-target="#qf${id}" <%--
                            --%>aria-controls="qf${id}" <%--
                            --%>aria-expanded="true" <%--
                            --%>data-toggle="collapse"><%--
                            --%>${facetController.config.label}<%--
                         --%></button><%----%>
                            <div id="qf${id}" class="collapse show"><%----%>
                                <mercury:nl/>
                                <c:forEach var="entry" items="${facetController.config.queryList}" varStatus="status">
                                    <c:if test="${not empty search.facetQuery[entry.query]}">
                                        <label class="checkbox"> <input type="checkbox" <%--
                                        --%>name="${facetController.config.paramKey}" <%--
                                        --%>value="${entry.query}" <%--
                                        --%>onclick="submitSearchForm()" <%--
                                        --%>${facetController.state.isChecked[entry.query] ? 'checked' : ''} /><%--
                                            --%><i></i><%--
                                            --%>${entry.label} (${search.facetQuery[entry.query]})<%--
                                        --%></label><%----%>
                                        <mercury:nl/>
                                    </c:if>
                                </c:forEach>
                            </div><%----%>
                        </div><%----%>
                    </c:if>

                    <mercury:nl/>
                    <c:set var="fieldFacetControllers" value="${controllers.fieldFacets}" />
                    <c:forEach var="facet" items="${search.fieldFacets}" varStatus="status">
                        <c:set var="facetController" value="${fieldFacetControllers.fieldFacetController[facet.name]}" />
                        <c:if test="${cms:getListSize(facet.values) > 0}">
                            <div class="filterbox facet-field">
                                <c:set var="flabel"><fmt:message key="msg.page.search.facet.${fn:toLowerCase(facetController.config.label)}" /></c:set>
                                <c:if test="${fn:contains(flabel, '???')}"><c:set var="flabel">${facetController.config.label}</c:set></c:if>
                                <button type="button" <%--
                                --%>class="btn btn-block li-label" <%--
                                --%>data-target="#ff${id}_${status.index}" <%--
                                --%>aria-controls="ff${id}_${status.index}" <%--
                                --%>aria-expanded="true" <%--
                                --%>data-toggle="collapse"><%--
                                --%>${facetController.config.label}<%--
                             --%></button><%----%>
                                <mercury:nl/>
                                <div id="ff${id}_${status.index}" class="collapse show"><%----%>
                                    <mercury:nl/>
                                    <c:forEach var="facetItem" items="${facet.values}">
                                        <c:choose>
                                            <c:when test='${facet.name eq "type"}'>
                                                <c:set var="itemName">${facetItem.name}</c:set>
                                                <c:choose>
                                                <c:when test='${itemName eq "containerpage"}'>
                                                    <c:set var="label"><fmt:message key="msg.page.search.type.containerpage" /></c:set>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="label"><cms:label>type.${itemName}.name</cms:label></c:set>
                                                </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:when test='${facet.name eq "category_exact"}'>
                                                <c:set var="label"></c:set>
                                                <c:forEach var="category" items="${cms.readPathCategories[facetItem.name]}" varStatus="status">
                                                    <c:set var="label">${label}${category.title}</c:set>
                                                    <c:if test="${not status.last}"><c:set var="label">${label}&nbsp;/&nbsp;</c:set></c:if>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="label" value="${facetItem.name}" />
                                            </c:otherwise>
                                        </c:choose>
                                        <label class="checkbox"><input type="checkbox" <%--
                                        --%>name="${facetController.config.paramKey}" <%--
                                        --%>value="${facetItem.name}" <%--
                                        --%>onclick="submitSearchForm()"<%--
                                        --%>${facetController.state.isChecked[facetItem.name] ? ' checked' : ''} /><%--
                                            --%><i></i><%--
                                            --%>${label} (${facetItem.count})<%--
                                    --%></label><%----%>
                                        <mercury:nl/>
                                    </c:forEach>

                                    <%-- Show option to show more facet entries --%>
                                    <c:if test="${not empty facetController.config.limit && cms:getListSize(facet.values) ge facetController.config.limit}">
                                        <mercury:nl/>
                                        <div class="show-more"><%----%>
                                            <c:choose>
                                            <c:when test="${facetController.state.useLimit}">
                                                <a href="<cms:link>${cms.requestContext.uri}?${search.stateParameters.addIgnoreFacetLimit[facet.name]}</cms:link>"><fmt:message key="msg.page.search.facet.link.more" /></a><%----%>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="<cms:link>${cms.requestContext.uri}?${search.stateParameters.removeIgnoreFacetLimit[facet.name]}</cms:link>"><fmt:message key="msg.page.search.facet.link.less" /></a><%----%>
                                                <input type="hidden" name="${facetController.config.ignoreMaxParamKey}" /><%----%>
                                            </c:otherwise>
                                            </c:choose>
                                        </div><%----%>
                                    </c:if>
                                </div><%----%>
                            </div><%----%>
                            <mercury:nl/>
                        </c:if>
                    </c:forEach>
                </div><%----%>
                </div><%----%>
                <mercury:nl/>
            </c:if>

            <%-- Search results --%>
            <c:set var="colWidthResults" value="${hasFacets ? 8 : 12}" /><%----%>
            <div class="col-md-${colWidthResults} col-12 search-results"><%----%>
                <mercury:nl/>
                <c:choose>
                    <c:when test="${not empty search.exception}">
                        <div class="search-exception">
                            <h3><fmt:message key="msg.page.search.failed" /></h3><%----%>
                            <p><%----%>
                                <fmt:message key="msg.page.search.query.changed">
                                    <fmt:param>${common.state.query}</fmt:param>
                                    <fmt:param>${search.finalQuery.query}</fmt:param>
                                </fmt:message>
                            </p><%----%>
                        </div><%----%>
                    </c:when>
                    <c:when test="${empty search.searchResults && empty search.exception}">
                        <c:choose>
                        <c:when test="${not empty controllers.didYouMean.config}" >
                            <c:set var="suggestion" value="${search.didYouMeanSuggestion}" />
                            <c:choose>
                            <c:when test="${controllers.didYouMean.config.collate && not empty search.didYouMeanCollated}">
                                <div class="search-suggestion"><%----%>
                                    <h3><%----%>
                                        <fmt:message key="msg.page.search.didyoumean_1">
                                            <fmt:param><a href="<cms:link>${cms.requestContext.uri}?${search.stateParameters.newQuery[search.didYouMeanCollated]}</cms:link>">${search.didYouMeanCollated}</a></fmt:param>
                                        </fmt:message>
                                    </h3><%----%>
                                </div><%----%>
                            </c:when>
                            <c:when test="${not controllers.didYouMean.config.collate and not empty suggestion.alternatives and cms:getListSize(suggestion.alternatives) > 0}">
                                <div class="search-suggestion"><%----%>
                                    <h3><fmt:message key="msg.page.search.didyoumean_0" /></h3><%----%>
                                    <ul><%----%>
                                        <mercury:nl/>
                                        <c:forEach var="alternative" items="${suggestion.alternatives}" varStatus="status">
                                            <li><%----%>
                                                <a href='<cms:link>${cms.requestContext.uri}?${search.stateParameters.newQuery[alternative]}</cms:link>'>${alternative} (${suggestion.alternativeFrequencies[status.index]})</a><%----%>
                                            </li><%----%>
                                            <mercury:nl/>
                                        </c:forEach>
                                    </ul><%----%>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="search-no-result"><%----%>
                                    <h3><fmt:message key="msg.page.search.noResult" /></h3><%----%>
                                </div><%----%>
                            </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <div class="search-no-result"><%----%>
                                <h3><fmt:message key="msg.page.search.noResult" /></h3><%----%>
                            </div><%----%>
                        </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <div class="search-results-header"><%----%>
                            <h3 class="search-results-head"><%----%>
                                <fmt:message key="msg.page.search.result.heading"/>
                            </h3><%----%>
                            <div class="search-results-count"><%----%>
                                <fmt:message key="msg.page.search.result.info">
                                    <fmt:param value="${search.start}"/>
                                    <fmt:param value="${search.end}"/>
                                    <fmt:param value="${search.numFound}"/>
                                    <fmt:param value="${search.maxScore}"/>
                                </fmt:message>
                            </div><%----%>
                        </div><%----%>
                        <mercury:nl/>

                        <%-- show search results --%>
                        <c:forEach var="searchResult" items="${search.searchResults}">
                            <div class="search-result"><%----%>
                                <c:set var="localizedTitleField">disptitle_${cms.locale}_sort</c:set>
                                <c:set var="title">${searchResult.fields[localizedTitleField]}</c:set>
                                <c:if test="${empty title}">
                                    <c:set var="title">${searchResult.fields["disptitle_sort"]}</c:set>
                                </c:if>

                                <c:set var="resultType">${searchResult.fields["type"]}</c:set>
                                <c:choose>
                                    <c:when test="${resultType eq 'containerpage'}">
                                        <c:set var="typeName"><fmt:message key="msg.page.search.type.containerpage" /></c:set>
                                    </c:when>
                                    <c:when test="${not empty resultType}">
                                        <c:set var="typeName"><cms:label>type.${resultType}.name</cms:label></c:set>
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="typeName" value="" />
                                    </c:otherwise>
                                </c:choose>
                                <c:if test="${not empty typeName}">
                                    <c:set var="typeName">
                                        <span class="search-badge">${typeName}</span>
                                    </c:set>
                                </c:if>
                                <mercury:nl/>

                                <h4 class="search-result-heading"><%----%>
                                    <a href='<cms:link>${searchResult.fields["path"]}</cms:link>'>${title}</a><%----%>
                                    <c:out value="${typeName}" escapeXml="${false}" />
                                </h4><%----%>
                                <mercury:nl/>

                                <div class="search-result-text"><%----%>
                                    <%-- if highlighting is returned - show it; otherwise show content_en (up to 250 characters) --%>
                                    <c:choose>
                                        <c:when test="${not empty search.highlighting and not empty common.state.query}">
                                            <%-- To avoid destroying the HTML, if the highlighted snippet contains unbalanced tag, use the htmlConverter for cleaning the HTML. --%>
                                            <c:set var="highlightSnippet" value='${
                                                search.highlighting
                                                    [searchResult.fields["id"]]
                                                    [search.controller.highlighting.config.hightlightField]
                                                    [0]
                                                }'
                                            />
                                            <c:if test="${not empty highlightSnippet}">
                                                ${fn:replace(fn:replace(cms:stripHtml(highlightSnippet), '$$hl.begin$$', '<strong>'), '$$hl.end$$', '</strong>')}${' ...'}
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="localeContentField">${cms.locale}_excerpt</c:set>
                                            <c:if test="${not empty searchResult.fields[localeContentField]}">
                                                ${cms:trimToSize(cms:stripHtml(searchResult.fields[localeContentField]), 250)}
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                </div><%----%>
                            </div><%----%>
                            <mercury:nl/>
                        </c:forEach>

                        <c:set var="onclickAction"><cms:link>${cms.requestContext.uri}?$(LINK)</cms:link></c:set>
                        <mercury:list-pagination
                            search="${search}"
                            singleStep="true"
                            onclickAction='window.location.href="${onclickAction}"'
                        />
                    </c:otherwise>
                </c:choose>
            </div><%----%>
        </div><%----%>
    </form><%----%>

    <mercury:nl />
    <script type="text/javascript"><%--
    --%>var searchForm = document.forms["search-form"];<%--
    --%>function submitSearchForm() {<%--
        --%>searchForm.submit();<%--
    --%>}<%--
    --%></script><%----%>
    <mercury:nl />

</div><%----%>
<mercury:nl />

</cms:bundle>

</mercury:init-messages>
