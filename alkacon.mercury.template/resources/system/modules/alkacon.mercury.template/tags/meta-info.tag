<%@ tag
    display-name="meta-info"
    pageEncoding="UTF-8"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Generates meta information for the page header." %>


<%@ attribute name="contentUri" type="java.lang.String" required="true"
    description="The URI of the resource currently rendered.
    This can be either the request context URI, or a detail content site path." %>

<%@ attribute name="contentPropertiesSearch" type="java.util.Map" required="true"
    description="The properties read from the URI resource with search." %>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:set var="nl" value="<%= \"\n\" %>" />

<c:set var="hasAltDesc" value="${(not empty cms.meta.ogDescriptionAlt) or (not empty cms.meta.ogDescriptionAltCaption)}" />
<c:set var="hasAltDescAndCaption" value="${hasAltDesc and (not empty cms.meta.ogDescriptionAlt) and (not empty cms.meta.ogDescriptionAltCaption)}" />

<c:set var="pagetitle"><mercury:meta-title addIntro="${true}" /></c:set>
<c:set var="pagetitle"><mercury:meta-value text="${pagetitle}" keepHtml="${true}" /></c:set>
<c:set var="titleprefix" value="${contentPropertiesSearch['mercury.title.prefix']}" />
<c:set var="titlesuffix" value="${contentPropertiesSearch['mercury.title.suffix']}" />

<title>${titleprefix}${empty titleprefix ? '' : ' '}${pagetitle}${empty titlesuffix ? '' : ' '}${titlesuffix}</title>

<%-- ###### Get the right description from the content ###### --%>
<%--
The optimal description length for Google is not 100% clear.
Sources give various information like 150, 160 or 175 chars etc.
We go for 175 chars since our cut-off algorithm will likely remove some chars
to find a sentence end.
--%>
<c:choose>
    <c:when test="${not empty cms.meta.ogDescriptionMeta}">
        <c:set var="pagedesc"><mercury:meta-value text="${cms.meta.ogDescriptionMeta}" keepHtml="${true}" /></c:set>
    </c:when>
    <c:when test="${not empty cms.meta.ogDescriptionTeaser}">
        <c:set var="pagedesc"><mercury:meta-value text="${cms.meta.ogDescriptionTeaser}" keepHtml="${true}" trim="${175}" /></c:set>
    </c:when>
    <c:when test="${not empty cms.meta.ogDescription}">
        <c:set var="pagedesc"><mercury:meta-value text="${cms.meta.ogDescription}" trim="${175}" /></c:set>
    </c:when>
    <c:when test="${hasAltDesc}">
        <c:set var="pagedesc"><mercury:meta-value text="${cms.meta.ogDescriptionAltCaption}${hasAltDescAndCaption ? ' - ' : ''}${cms.meta.ogDescriptionAlt}" trim="${175}" /></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="pagedesc"><mercury:meta-value text="${contentPropertiesSearch['Description']}" trim="${175}" /></c:set>
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${not empty cms.meta.Keywords}">
        <c:set var="pagekeywords"><mercury:meta-value text="${cms.meta.Keywords}" /></c:set>
    </c:when>
    <c:otherwise>
        <c:set var="pagekeywords"><mercury:meta-value text="${contentPropertiesSearch['Keywords']}" /></c:set>
    </c:otherwise>
</c:choose>

<%-- ###### Default page meta infos ###### --%>

<meta charset="${cms.requestContext.encoding}">
<meta http-equiv="X-UA-Compatible" content="IE=edge">

<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<c:if test="${not empty pagedesc}"><meta name="description" content="${pagedesc}">${nl}</c:if>
<c:if test="${not empty pagekeywords}"><meta name="keywords" content="${pagekeywords}">${nl}</c:if>
<meta name="robots" content="index, follow">
<meta name="revisit-after" content="7 days">

<%-- ###### Facebook open graph meta infos ###### --%>
<c:choose>
    <c:when test="${not empty cms.meta.fbTitle}">
        <c:set var="fbtitle" value="${cms.meta.fbTitle}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogTitleMeta}">
        <c:set var="fbtitle" value="${cms.meta.ogTitleMeta}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogTitleTeaser}">
        <c:set var="fbtitle" value="${cms.meta.ogTitleTeaser}" />
        <c:set var="fbintro" value="${true}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogTitle}">
        <c:set var="fbtitle" value="${cms.meta.ogTitle}" />
        <c:set var="fbintro" value="${true}" />
    </c:when>
</c:choose>
<c:if test="${not empty fbtitle}">
    <c:set var="fbSet" value="true" />
    <c:set var="fbtitle"><mercury:meta-title title="${fbtitle}" addIntro="${fbintro}" trim="${75}" /></c:set>
    <c:set var="fbtitle"><mercury:meta-value text="${fbtitle}" keepHtml="${true}" /></c:set>
    <meta property="og:title" content="${fbtitle}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.fbDescription}">
        <c:set var="fbdesc"><mercury:meta-value text="${cms.meta.fbDescription}" keepHtml="${true}" /></c:set>
    </c:when>
    <c:when test="${not empty cms.meta.ogDescriptionMeta}">
        <c:set var="fbdesc"><mercury:meta-value text="${cms.meta.ogDescriptionMeta}" keepHtml="${true}" /></c:set>
    </c:when>
    <c:when test="${not empty cms.meta.ogDescriptionTeaser}">
        <c:set var="fbdesc"><mercury:meta-value text="${cms.meta.ogDescriptionTeaser}" trim="${400}" keepHtml="${true}" /></c:set>
    </c:when>
    <c:when test="${not empty cms.meta.ogDescription}">
        <c:set var="fbdesc"><mercury:meta-value text="${cms.meta.ogDescription}" trim="${400}" /></c:set>
    </c:when>
    <c:when test="${hasAltDesc}">
        <c:set var="fbdesc"><mercury:meta-value text="${cms.meta.ogDescriptionAltCaption}${hasAltDescAndCaption ? ' - ' : ''}${cms.meta.ogDescriptionAlt}" trim="${400}" /></c:set>
    </c:when>
</c:choose>
<c:if test="${not empty fbdesc}">
    <c:set var="fbSet" value="true" />
    <meta property="og:description" content="${fbdesc}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.fbImage}">
        <c:set var="fbimage" value="${cms.meta.fbImage}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageMeta}">
        <c:set var="fbimage" value="${cms.meta.ogImageMeta}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageTeaser}">
        <c:set var="fbimage" value="${cms.meta.ogImageTeaser}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImage}">
        <c:set var="fbimage" value="${cms.meta.ogImage}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageAlt}">
        <c:set var="fbimage" value="${cms.meta.ogImageAlt}" />
    </c:when>
</c:choose>

<%-- Facebook recommends images with a ratio of 1,91:1, see https://developers.facebook.com/docs/sharing/best-practices/#images --%>
<%-- Facebook recommends images with a size of at least 1200 x 630 pixel width, so we target 2400 that as max width --%>
<c:set var="solcalImageMaxWidth" value="${2400}" />
<c:if test="${not empty fbimage}">
    <cms:scaleImage var="imgBean" src="${fbimage}">
        <c:if test="${not empty imgBean}">
            <c:set var="fbSet" value="true" />
            <c:set target="${imgBean}" property="quality" value="${85}" />
            <c:set var="ib" value="${imgBean.scaleRatio['191-100']}" />
            <c:if test="${ib.scaler.width > solcalImageMaxWidth}">
                <c:set var="ib" value="${ib.scaleWidth[solcalImageMaxWidth]}" />
            </c:if>
            <c:set var="imageSet" value="${true}" />
            <meta property="og:image:width" content="${ib.scaler.width}">${nl}
            <meta property="og:image:height" content="${ib.scaler.height}">${nl}
            <meta property="og:image" content="${cms.site.url}${ib.srcUrl}">${nl}
        </c:if>
    </cms:scaleImage>
</c:if>

<%-- Optional external image, used by media element to link to YouTube Images --%>
<c:if test="${(not imageSet) and (not empty cms.meta.ogImageExt)}">
<meta property="og:image" content="${cms.meta.ogImageExt}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.fbType}">
        <c:set var="fbtype" value="${cms.meta.fbType}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogType}">
        <c:set var="fbtype" value="${cms.meta.ogType}" />
    </c:when>
</c:choose>
<c:if test="${not empty fbtype}">
    <c:set var="fbSet" value="true" />
    <meta property="og:type" content="${fbtype}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.fbSite}">
        <c:set var="fbsite" value="${cms.meta.fbSite}" />
    </c:when>
    <c:when test="${fbSet}">
        <c:set var="fbsite" value="${contentPropertiesSearch['social.facebook.site']}" />
    </c:when>
</c:choose>
<c:if test="${not empty fbSite}">
    <c:set var="fbSet" value="true" />
    <meta property="og:site_name" content="${fbSite}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.fbUrl}">
        <c:set var="fburl" value="${cms.meta.fbUrl}" />
    </c:when>
    <c:when test="${fbSet}">
        <c:set var="fburl">${cms.site.url}<cms:link>${contentUri}</cms:link></c:set>
    </c:when>
</c:choose>
<c:if test="${not empty fburl}">
    <meta property="og:url" content="${fburl}">
</c:if>

<c:if test="${fbSet}">
    <c:set var="fblocale" value="${not empty contentPropertiesSearch['social.facebook.locale'] ? contentPropertiesSearch['social.facebook.locale'] : cms.locale}" />
    <meta property="og:locale" content="${fblocale}">
</c:if>

<c:set var="fbpages" value="${not empty contentPropertiesSearch['social.facebook.pages'] ? contentPropertiesSearch['social.facebook.pages'] : 'false'}" />
<c:if test="${fbpages ne 'false'}"><meta property="fb:pages" content="${fbpages}"></c:if>


<%-- ###### Twitter card meta infos ###### --%>
<%-- ###### Apparently Twitter is reusing OG meta info if provided ###### --%>
<%-- ###### There fore certain elements are only output in case of different content ###### --%>

<c:choose>
    <c:when test="${not empty cms.meta.twTitle}">
        <c:set var="twtitle" value="${cms.meta.twTitle}" />
    </c:when>
</c:choose>
<c:if test="${not empty twtitle}">
    <c:set var="twSet" value="true" />
    <meta name="twitter:title" content="${twtitle}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.twDescription}">
        <c:set var="twdesc"><mercury:meta-value text="${cms.meta.twDescription}" /></c:set>
    </c:when>
    <%-- Twitter reuses facebook og:decription if no special Twitter description is set --%>
</c:choose>
<c:if test="${not empty twdesc}">
    <c:set var="twSet" value="true" />
    <meta name="twitter:description" content="${twdesc}">
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.twImage}">
        <c:set var="twimage" value="${cms.meta.twImage}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageMeta}">
        <c:set var="twimage" value="${cms.meta.ogImageMeta}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageTeaser}">
        <c:set var="twimage" value="${cms.meta.ogImageTeaser}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImage}">
        <c:set var="twimage" value="${cms.meta.ogImage}" />
    </c:when>
    <c:when test="${not empty cms.meta.ogImageAlt}">
        <c:set var="twimage" value="${cms.meta.ogImageAlt}" />
    </c:when>
</c:choose>

<c:choose>
    <c:when test="${not empty cms.meta.twCard}">
        <c:set var="twcard" value="${cms.meta.twCard}" />
    </c:when>
    <c:when test="${twSet or fbSet}">
        <c:set var="twcard" value="${empty twimage ? 'summary' : 'summary_large_image'}" />
    </c:when>
</c:choose>
<c:if test="${not empty twimage}">
    <meta name="twitter:card" content="${twcard}">
</c:if>

<%-- Twitter recommends images with a ratio of 2:1 or 1:1, depending on card type, see https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/summary --%>
<%-- Twitter images must not be smaller then 300x157 and not be larger then 4096x4096 --%>
<c:if test="${not empty twimage}">
    <cms:scaleImage var="imgBean" src="${twimage}">
        <c:if test="${not empty imgBean}">
            <c:set var="twSet" value="true" />
            <c:set target="${imgBean}" property="quality" value="${85}" />
            <c:choose>
                <c:when test="${twcard == 'summary_large_image'}">
                    <c:set var="twImageRatio" value="2-1" />
                </c:when>
                <c:otherwise>
                    <c:set var="twImageRatio" value="1-1" />
                </c:otherwise>
            </c:choose>
            <c:set var="ib" value="${imgBean.scaleRatio[twImageRatio]}" />
            <c:if test="${ib.scaler.width > solcalImageMaxWidth}">
                <c:set var="ib" value="${ib.scaleWidth[solcalImageMaxWidth]}" />
            </c:if>
            <meta name="twitter:image" content="${cms.site.url}${ib.srcUrl}">${nl}
        </c:if>
    </cms:scaleImage>
</c:if>

<c:choose>
    <c:when test="${not empty cms.meta.twSite}">
        <c:set var="twsite" value="${cms.meta.twSite}" />
    </c:when>
    <c:when test="${twSet or fbSet}">
        <c:set var="twsite" value="${contentPropertiesSearch['social.twitter.site']}" />
    </c:when>
</c:choose>
<c:if test="${not empty twsite}">
    <c:set var="twSet" value="true" />
    <meta name="twitter:site" content="${twsite}">
</c:if>

