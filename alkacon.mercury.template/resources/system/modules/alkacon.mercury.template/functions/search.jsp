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

<cms:secureparams replaceInvalid="bad_param" />
<mercury:init-messages reload="true">

<c:set var="id"><mercury:idgen prefix="" uuid="${cms.element.id}" /></c:set>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<mercury:setting-defaults>

<c:set var="searchSubsite"          value="${setting.searchscope.toString eq 'subsite'}" />
<c:set var="searchForEmptyQuery"    value="${setting.searchForEmptyQuery.toBoolean}" />
<c:set var="numFacetItems"          value="${empty setting.numFacetItems.toInteger ? 10 : setting.numFacetItems.toInteger}" />
<c:set var="pageSize"               value="${empty setting.pageSize.toInteger ? 10 : setting.pageSize.toInteger}" />
<c:set var="showTypeBadge"          value="${setting.showTypeBadge.useDefault('true').toBoolean}" />
<c:set var="showExcerpt"            value="${setting.showExcerpt.useDefault('true').toBoolean}" />
<c:set var="dateFormat"             value="${setting.dateFormat.useDefault('none').toString}" />
<c:set var="datePrefix"             value="${fn:substringBefore(dateFormat, '|')}" />
<c:set var="dateFormat"             value="${empty datePrefix ? dateFormat : fn:substringAfter(dateFormat, '|')}" />
<c:set var="showDateLastModified"   value="${dateFormat ne 'none'}" />
<c:set var="slotText"               value="${setting.slotText.toString}" />
<c:set var="slotButton"             value="${setting.slotButton.toString}" />

<c:if test="${empty slotText}">
    <c:set var="slotText"><fmt:message key='msg.page.search.enterquery' /></c:set>
</c:if>

<c:choose>
    <c:when test="${empty slotButton}">
        <c:set var="slotButton"><fmt:message key="msg.page.search.submit" /></c:set>
    </c:when>
    <c:when test="${fn:startsWith(slotButton, 'icon:')}">
        <c:set var="icon" value="${fn:substringAfter(slotButton, 'icon:')}" />
        <c:set var="slotButton"><mercury:icon icon="${icon}" tag="span" cssWrapper="icon-image" inline="${true}" /></c:set>
    </c:when>
</c:choose>

<c:set var="showFacets"             value="${numFacetItems != 0}" />

<%-- Generate the search configuration --%>
<c:choose>
    <c:when test="${searchSubsite}">
        <c:set var="searchscope" value="${cms.requestContext.siteRoot}${cms.subSitePath}" />
    </c:when>
    <c:otherwise>
        <c:set var="searchscope" value="${cms.requestContext.siteRoot}/" />
    </c:otherwise>
</c:choose>
<c:set var="searchscope">\"${searchscope}\"</c:set>
<c:set var="additionalScopes" value="${cms.vfs.propertySearch[cms.requestContext.uri]['search.scope.additional']}"/>
<c:if test="${not empty additionalScopes}">
    <c:forEach var="scope" items="${fn:split(additionalScopes,',')}">
        <c:set var="searchscope">${searchscope}${' OR '}\"${scope}\"</c:set>
    </c:forEach>
    <c:set var="searchscope">(${searchscope})</c:set>
</c:if>
<c:set var="types"><%--
    --%>binary<%--
    --%>,containerpage<%--
    --%>,plain<%--
 --%></c:set>

<c:set var="additionalTypes" value="${cms.vfs.propertySearch[cms.requestContext.uri]['search.types.additional']}"/>
<c:if test="${not empty additionalTypes}">
    <c:set var="types">${types},${additionalTypes}</c:set>
</c:if>

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

<c:set var="returnFields">disptitle_${cms.locale}_sort,disptitle_sort,lastmodified,${cms.locale}_excerpt,id,path,mercury.detail.link_dprop</c:set>
<c:set var="config">
    {
        "searchforemptyquery" : ${searchForEmptyQuery},
        "querymodifier" :       "{!type=edismax qf=\"content_${cms.locale} Title_dprop Description_dprop\"}%(query)",
        "escapequerychars" :    true,
        "extrasolrparams" :     "fq=parent-folders:${searchscope}&fq=type:(${typesRestriction})&fq=con_locales:${cms.locale}&spellcheck.dictionary=${cms.locale}&fq=-filename:\"mega.menu\"&fl=${returnFields}",
        "pagesize" :            ${pageSize},
        "pagenavlength" :       5,
        "sortoptions" :         [ { "label" : "<fmt:message key='msg.page.search.sort.score.desc'/>", "solrvalue" : "score desc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.date.desc'/>", "solrvalue" : "instancedate_${cms.locale}_dt desc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.date.asc'/>", "solrvalue" : "instancedate_${cms.locale}_dt asc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.title.asc'/>", "solrvalue" : "disptitle_${cms.locale}_sort asc" }
                                , { "label" : "<fmt:message key='msg.page.search.sort.title.desc'/>", "solrvalue" : "disptitle_${cms.locale}_sort desc" }
                                ],
        <c:if test="${showFacets}">
        "fieldfacets" :         [
                                  { "field" : "type", "label" : "<fmt:message key="msg.page.search.facet.type"/>", "mincount" : 1, "limit" : ${numFacetItems} }
                                , { "field" : "category_exact", "label" : "<fmt:message key="msg.page.search.facet.category"/>", "mincount" : 1, "order" : "index" }
                                ],
        </c:if>
        "highlighter" :         {
                                    "field" :                       "content_${cms.locale}",
                                    "alternateField":               "content_${cms.locale}",
                                    "maxAlternateFieldLength":      250,
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

<mercury:nl/>
<div class="element type-search pivot${setCssWrapperAll}"><%----%>
    <mercury:nl/>

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
        <c:set var="hasFacets" value="${(cms:getListSize(search.fieldFacets) > 0) or (not empty search.facetQuery)}" />

        <mercury:nl/>
        <div class="search-result-row"><%----%>

            <%-- Search query --%>
            <div class="search-query ${hasFacets ? ' has-facets' : ' no-facets'}"><%----%>
                <section class="input-group"><%----%>
                    <div class="input button"><%----%>
                        <label for="searchFormQuery" class="sr-only"><fmt:message key="msg.page.search" /></label><%----%>
                        <input id="searchFormQuery" name="${common.config.queryParam}" <%--
                            --%>value="${escapedQuery}" class="form-control" type="text" autocomplete="off" <%--
                            --%>placeholder="<c:out value="${slotText}" />" /><%----%>
                        <button class="btn btn-submit-search" type="submit" title="<fmt:message key="msg.page.search" />">${slotButton}</button><%----%>
                    </div><%----%>
                </section><%----%>
            </div><%----%>
            <mercury:nl/>

            <%-- Search facets --%>
            <c:if test="${hasFacets}">
                <%-- Facets --%>
                <mercury:nl/>
                <div class="search-facets"><%----%>
                <div class="type-list-filter"><%----%>

                    <%-- Query facet --%>
                    <c:if test="${(not empty controllers.queryFacet) and (not empty search.facetQuery)}">
                        <c:set var="facetController" value="${controllers.queryFacet}" />
                        <div class="filterbox facet-query">
                            <button type="button" <%--
                            --%>class="btn btn-block li-label" <%--
                            --%>data-bs-target="#qf${id}" <%--
                            --%>aria-controls="qf${id}" <%--
                            --%>aria-expanded="true" <%--
                            --%>data-bs-toggle="collapse"><%--
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
                                --%>data-bs-target="#ff${id}_${status.index}" <%--
                                --%>aria-controls="ff${id}_${status.index}" <%--
                                --%>aria-expanded="true" <%--
                                --%>data-bs-toggle="collapse"><%--
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

            <c:if test="${hasSortOptions}">
                <div class="search-sort ${hasFacets ? ' has-facets' : ' no-facets'}"><%----%>
                    <section><%----%>
                    <c:set var="sort" value="${controllers.sorting}" />
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
                    </section>
                </div>
                <mercury:nl/>
            </c:if>

            <%-- Search results --%>
            <div class="search-results ${hasFacets ? ' has-facets' : ' no-facets'}"><%----%>
                <c:choose>
                    <c:when test="${not empty search.exception}">
                        <div class="search-exception">
                            <h3 tabindex="0"><fmt:message key="msg.page.search.failed" /></h3><%----%>
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
                        <c:when test="${not common.config.searchForEmptyQueryParam && empty common.state.query}">
                            <div class="search-no-result"><%----%>
                                <h3 tabindex="0"><fmt:message key="msg.page.search.noResults.enterQuery" /></h3><%----%>
                            </div><%----%>
                        </c:when>
                        <c:when test="${not empty controllers.didYouMean.config}" >
                            <c:set var="suggestion" value="${search.didYouMeanSuggestion}" />
                            <c:choose>
                            <c:when test="${controllers.didYouMean.config.collate && not empty search.didYouMeanCollated}">
                                <div class="search-suggestion"><%----%>
                                    <h3 tabindex="0"><%----%>
                                        <fmt:message key="msg.page.search.didyoumean_1">
                                            <fmt:param><a href="<cms:link>${cms.requestContext.uri}?${search.stateParameters.newQuery[search.didYouMeanCollated]}</cms:link>">${search.didYouMeanCollated}</a></fmt:param>
                                        </fmt:message>
                                    </h3><%----%>
                                </div><%----%>
                            </c:when>
                            <c:when test="${not controllers.didYouMean.config.collate and not empty suggestion.alternatives and cms:getListSize(suggestion.alternatives) > 0}">
                                <div class="search-suggestion"><%----%>
                                    <h3 tabindex="0"><fmt:message key="msg.page.search.didyoumean_0" /></h3><%----%>
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
                                    <h3 tabindex="0"><fmt:message key="msg.page.search.noResult" /></h3><%----%>
                                </div><%----%>
                            </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:otherwise>
                            <div class="search-no-result"><%----%>
                                <h3 tabindex="0"><fmt:message key="msg.page.search.noResult" /></h3><%----%>
                            </div><%----%>
                        </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <div class="search-results-header"><%----%>
                            <h3 class="search-results-head" tabindex="0"><%----%>
                                <fmt:message key="msg.page.search.result.heading"/>
                            </h3><%----%>
                            <div class="search-results-count" tabindex="0"><%----%>
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

                                <c:if test="${showTypeBadge}">
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
                                </c:if>

                                <h4 class="search-result-heading"><%----%>
                                    <c:set var="resultLink" value="${empty searchResult.fields['mercury.detail.link_dprop'] ? searchResult.fields['path'] : searchResult.fields['mercury.detail.link_dprop']}" />
                                    <a href='<cms:link>${resultLink}</cms:link>'><%----%>
                                        <span class="result-title">${title}</span><%----%>
                                        <c:out value="${showTypeBadge ? typeName : ''}" escapeXml="${false}" />
                                    </a><%----%>
                                </h4><%----%>
                                <mercury:nl/>

                                <c:if test="${showDateLastModified}">
                                    <div class="search-result-date"><%----%>
                                        <c:out value="${empty datePrefix ? '' : datePrefix.concat(' ')}" />
                                        <mercury:instancedate date="${cms.wrap[searchResult.dateFields['lastmodified']].toInstanceDate}" format="${dateFormat}"/>
                                    </div><%----%>
                                    <mercury:nl/>
                                </c:if>

                                <c:if test="${showExcerpt}">
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
                                    <mercury:nl/>
                                </c:if>

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
            <mercury:nl />

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

</mercury:setting-defaults>

</cms:bundle>
</mercury:init-messages>
