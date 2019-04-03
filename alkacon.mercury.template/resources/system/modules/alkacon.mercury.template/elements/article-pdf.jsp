<%@page
    pageEncoding="UTF-8"
    trimDirectiveWhitespaces="true"
    buffer="none"
    session="false" %>

<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<cms:contentload collector="singleFile" param="%(opencms.uri)" >
<cms:contentaccess var="content" val="value" />

<c:set var="date">
    <c:set var="dateFormat"><fmt:message key="msg.setting.dateFormat.SHORT.format" /></c:set>
    <mercury:instancedate date="${value.Date.toInstanceDate}" format="${dateFormat}" />
</c:set>

<c:set var="themeUri"><cms:link>/system/modules/alkacon.mercury.theme/</cms:link></c:set>

<mercury:paragraph-split
    paragraphs="${content.valueList.Paragraph}"
    splitFirst="${false}"
    splitDownloads="${false}">

<c:set var="image" value="${value.Image.value.Image.isSet ? value.Image : firstParagraph.value.Image}" />


<?xml version="1.0" encoding="${cms.requestContext.encoding}"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html>
<head>
<title><c:out value="${value.Title}" /></title>

<style>
    @font-face { font-family: 'Open Sans'; font-style: normal; font-weight: 400;
      src: local("Open Sans"), local("OpenSans"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-regular.woff2") format("woff2"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-regular.woff") format("woff"); }

    @font-face { font-family: 'Open Sans'; font-style: italic; font-weight: 400;
      src: local("Open Sans Italic"), local("OpenSans-Italic"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-italic.woff2") format("woff2"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-italic.woff") format("woff"); }

    @font-face { font-family: 'Open Sans'; font-style: normal; font-weight: 700;
      src: local("Open Sans Bold"), local("OpenSans-Bold"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-700.woff2") format("woff2"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-700.woff") format("woff"); }

    @font-face { font-family: 'Open Sans'; font-style: italic; font-weight: 700;
      src: local("Open Sans Bold Italic"), local("OpenSans-BoldItalic"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-700italic.woff2") format("woff2"), url("${themeUri}/fonts/open-sans-v15-latin_latin-ext-700italic.woff") format("woff"); }

    body {
      margin: 0;
      font-family: "Open Sans", sans-serif;
      font-size: 14px;
      font-weight: 300;
      line-height: 1.4;
      color: #333;
      text-align: left;
      background-color: #fff;
    }

    .paragraph .image {
        float: left;
        margin: 0 20px 10px 0;
    }

    .intro-headline .intro {
        font-size: 16px;
        color: #b31b34;
        display: block;
    }

    .visual {
        float: right;
        margin: 0 0 10px 20px;
    }

    .author,
    .date {
        font-style: italic;
    }

    .head,
    .paragraph {
        margin-bottom: 20px;
    }

    .clearfix::after {
        content: "";
        display: table;
        clear: both;
    }

    h1, h2, h3, h4, h5, h6 {
        margin-top: 0;
    }

    a {
        color: #fff;
        background-color: #b31b34;
        text-decoration: none;
        padding: 5px 10px;
    }
</style>
</head>

<body>

    <div class="head clearfix">
        <mercury:image-vars image="${image}">
            <c:if test="${not empty imageBean}">
                <div class="visual">
                    <img ${imageBean.scaleWidth[350].imgSrc} />
                </div>
            </c:if>
        </mercury:image-vars>

        <div class="title">
            <mercury:intro-headline
                intro="${value.Intro}"
                headline="${value.Title}"
                level="${2}"
                ade="${false}"
            />
            <mercury:heading
                text="${value.Preface}"
                level="${3}"
            />

        </div>

        <c:if test="${value.Author.isSet}">
            <div class="author">
                <fmt:message key="msg.page.author.by">
                    <fmt:param>${value.Author}</fmt:param>
                </fmt:message>
            </div>
        </c:if>
        <div class="date">
            ${date}
        </div>
    </div>

    <c:forEach var="paragraph" items="${content.valueList.Paragraph}" varStatus="status">

        <div class="paragraph clearfix">
            <c:set var="pimage" value="${(status.first and not value.Image.value.Image.isSet) ? null : paragraph.value.Image}" />
            <mercury:image-vars image="${pimage}">
                <c:if test="${not empty imageBean}">
                    <div class="image">
                        <img ${imageBean.scaleWidth[250].imgSrc} />
                    </div>
                </c:if>
            </mercury:image-vars>

            <c:if test="${paragraph.value.Caption.isSet}">
                <div class="caption">
                    <h2><c:out value="${paragraph.value.Caption}" /></h2>
                </div>
            </c:if>

            <c:if test="${paragraph.value.Text.isSet}">
                <div class="text">
                    ${paragraph.value.Text}
                </div>
            </c:if>

            <c:if test="${paragraph.value.Link.exists}">
                <div class="link">
                    <mercury:link link="${paragraph.value.Link}" />
                </div>
            </c:if>
        </div>

    </c:forEach>

</body>
</html>

</mercury:paragraph-split>
</cms:contentload>
</cms:bundle>
