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

<%@page import="java.lang.String"%>
<%@page import="org.opencms.file.CmsResource"%>

<%-- TODO: Improve backlink --%>
<%--
<c:set var="backlink" value="${cms.typeDetailPage['m-article']}" />
<% pageContext.setAttribute("backlink", CmsResource.getFolderPath((String)pageContext.getAttribute("backlink"))); %>
 --%>
<% pageContext.setAttribute("backlink", CmsResource.getFolderPath("/mercury-demo/blog/articles/")); %>

<mercury:init-messages reload="true">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<cms:formatter var="content">

<div class="element type-ugc-form">
    <c:set var="errorHead"></c:set>
    <mercury:alert-online css="disp-n ugc-error">
        <jsp:attribute name="head">
            <fmt:message key="msg.error.ugc.validation" />
        </jsp:attribute>
        <jsp:attribute name="text">
            ${'<!-- filled automatically via JavaScript -->'}
        </jsp:attribute>
    </mercury:alert-online>

    <cms:ugc var="ugcId" editId="${param.fileId}" configPath="${content.filename}" />
    <div id="postFormLoading" style="display: none"></div>
    <form id="ugcForm" <c:out value='ugc-id="${ugcId}" back-link="${backlink}"' escapeXml="false" /> method="post" role="form" class="styled-form">
        <fieldset>
        <section>
            <label for="title" class="label"><fmt:message key="msg.page.ugc.form.title"/></label>
            <div class="input">
                <input type="text" name="title" />
            </div>
        </section>
        <section>
            <label for="text" class="label"><fmt:message key="msg.page.ugc.form.text"/></label>
            <div class="textarea">
                <textarea class="form-control" rows="5" name="text"></textarea>
            </div>
        </section>
        <section>
            <label for="image" class="label"><fmt:message key="msg.page.ugc.form.image"/></label>
            <div class="input input-file">
                <div class="button btn">
                    <input type="file" name="imagefile" id="imagefile" onchange="document.getElementById('image').value = this.value">
                    <fmt:message key="msg.page.ugc.form.browse"/>
                </div>
                <label for="image" class="sr-only">
                    <fmt:message key="msg.page.ugc.form.upload"/>
                </label>
                <input type="text" id="image" readonly placeholder="<fmt:message key="msg.page.ugc.form.image.placeholder"/>">
            </div>
        </section>
        <section id="imageOptions" style="display: none">
            <%-- Option to remove an image, will be displayed only if an image is available --%>
            <div class="input">
                <label for="imageuri" class="label"><fmt:message key="msg.page.ugc.form.image.current"/></label>
                <input disabled type="text" name="imageuri">
            </div>
            <div class="checkbox">
                <label class="label">
                    <input type="checkbox" name="imageremove"><i></i>
                    <fmt:message key="msg.page.ugc.form.image.remove"/>
                </label>
            </div>
        </section>

        <section>
            <label for="imagetitle" class="label"><fmt:message key="msg.page.ugc.form.image.title"/></label>
            <div  class="input">
                <input type="text" name="imagetitle">
            </div>
        </section>
        <section class="input">
            <label for="imagecopyright" class="label"><fmt:message key="msg.page.ugc.form.image.copyright"/></label>
            <div  class="input">
                <input type="text" name="imagecopyright">
            </div>
        </section>
        <section class="input">
            <label for="author" class="label"><fmt:message key="msg.page.ugc.form.author.name"/></label>
            <div  class="input">
                <input type="text" name="author">
            </div>
        </section>
        <section class="input">
            <label for="authormail" class="label"><fmt:message key="msg.page.ugc.form.author.email"/></label>
            <div  class="input">
                <input type="email" name="authormail">
            </div>
        </section>
        <section class="input">
            <label for="webpageurl" class="label"><fmt:message key="msg.page.ugc.form.link"/></label>
            <div  class="input">
                <input type="text" name="webpageurl">
            </div>
        </section>
        <section class="input">
            <label for="webpagenice" class="label"><fmt:message key="msg.page.ugc.form.link.description"/></label>
            <div  class="input">
                <input type="text" name="webpagenice">
            </div>
        </section>
        </fieldset>
        <fieldset>
        <input type="submit" style="display: none;">
        <div class="form-group">
            <div class="row">
                <div class="col-md-6">
                    <button id="saveButton" type="button"
                        class="btn btn-block btn-primary"><fmt:message key="msg.page.ugc.form.save"/></button>
                </div>
                <div class="col-md-3">
                    <button id="validateButton" type="button"
                        class="btn btn-block btn-default"><fmt:message key="msg.page.ugc.form.validate"/></button>
                </div>
                <div class="col-md-3">
                    <button id="cancelButton" type="button"
                        class="btn btn-block btn-default"><fmt:message key="msg.page.ugc.form.cancel"/></button>
                </div>
            </div>
        </div>
        </fieldset>
    </form>
</div>

</cms:formatter>
</cms:bundle>
</mercury:init-messages>
