<%@ tag
    pageEncoding="UTF-8"
    display-name="paragraphs"
    body-content="empty"
    trimDirectiveWhitespaces="true"
    description="Displays a list of paragraphs." %>

<%@ attribute name="paragraphs" type="java.util.List" required="true"
    description="The list of paragraphs to show." %>

<%@ attribute name="pieceLayout" type="java.lang.Integer" required="true"
    description="The layout option to generate. Valid values are 0 to 9.
    // 0. Heading, Image, Text, Link (full width)
    // 1. Image, Heading, Text, Link (full width)
    // 2. Heading on top, Image left, Text and Link right (separate column)
    // 3. Heading on top, Image right, Text and Link left (separate column)
    // 4. Heading on top, Image left, Text and Link right (floating around image)
    // 5. Heading on top, Image right, Text and Link left (floating around image)
    // 6. Image left, Heading, Text and Link right (separate column)
    // 7. Image right, Heading, Text and Link left (separate column)
    // 8. Image left, Heading, Text and Link right (floating around image)
    // 9. Image right, Heading, Text and Link left (floating around image)
    " %>

<%@ attribute name="sizeMobile" type="java.lang.Integer" required="false"
    description="Mobile grid size for the visual. Valid values are 1 to 12. Default is 7." %>

<%@ attribute name="sizeDesktop" type="java.lang.Integer" required="false"
    description="Desktop grid size for the visual if displayed in a column. Valid values are 1 to 12. Default is 4." %>

<%@ attribute name="splitDownloads" type="java.lang.Boolean" required="true"
    description="Controls if downloads are displayed in a separate list." %>

<%@ attribute name="hsize" type="java.lang.Integer" required="true"
    description="The heading level of the paragraph headline." %>

<%@ attribute name="ade" type="java.lang.Boolean" required="true"
    description="Controls if ADE is enabled or not." %>

<%@ attribute name="imageRatio" type="java.lang.String" required="false"
    description="Can be used to scale the image in a specific ratio,
    Allowed valued are: '1-1', '4-3', '3-2', '16-9', '2-1' and '2,35-1'" %>

<%@ attribute name="cssWrapper" type="java.lang.String" required="false"
    description="'class' atttributes to add to the generated div surrounding section." %>

<%@ attribute name="showText" type="java.lang.Boolean" required="false"
    description="Controls if the tag body text is displayed or not. Default is 'true'." %>

<%@ attribute name="linkOption" type="java.lang.String" required="false"
    description="Controls if and how the link is displayed or not. Default is 'button'." %>

<%@ attribute name="showImageCopyright" type="java.lang.Boolean" required="false"
    description="Controls if the image copyright is displayed as image overlay. Default is 'true'." %>

<%@ attribute name="showImageSubtitle" type="java.lang.Boolean" required="false"
    description="Controls if the image subtitle is displayed below the image. Default is 'true'." %>

<%@ attribute name="showImageZoom" type="java.lang.Boolean" required="false"
    description="Controls if a zoom option for the image is displayed. Default is 'true'." %>

<%@ attribute name="showImageLink" type="java.lang.Boolean" required="false"
    description="Controls if image is linked or not. Default is 'false'." %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms" %>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>

<c:if test="${not empty paragraphs}">
    <c:set var="paragraph" value="${paragraphs.get(0)}" />
    <c:set var="textOption" value="${((empty showText) or showText) ? 'default' : 'none'}" />
    <c:set var="linkOption" value="${empty linkOption ? 'button' : linkOption}" />
    <c:choose>
        <c:when test="${cms:isWrapper(paragraph)}">
            <mercury:paragraph-split
                paragraphs="${paragraphs}"
                splitFirst="${false}"
                splitDownloads="${splitDownloads}">
                <c:forEach var="paragraph" items="${paragraphsContent}" varStatus="status">
                    <mercury:section-piece
                        heading="${paragraph.value.Caption}"
                        pieceLayout="${pieceLayout}"
                        sizeMobile="${sizeMobile}"
                        sizeDesktop="${sizeDesktop}"
                        image="${paragraph.value.Image}"
                        text="${paragraph.value.Text}"
                        link="${paragraph.value.Link}"
                        cssWrapper="${cssWrapper}"
                        hsize="${hsize}"
                        imageRatio="${imageRatio}"
                        textOption="${textOption}"
                        linkOption="${linkOption}"
                        showImageCopyright="${showImageCopyright}"
                        showImageSubtitle="${showImageSubtitle}"
                        showImageZoom="${showImageZoom}"
                        showImageLink="${showImageLink}"
                        ade="${ade}"
                    />
                </c:forEach>
                <mercury:paragraph-downloads paragraphs="${paragraphsDownload}" />
            </mercury:paragraph-split>
        </c:when>
        <c:when test="${paragraph.getClass().getSimpleName() eq 'HashMap'}">
            <mercury:section-piece
                heading="${paragraph.Caption}"
                pieceLayout="${pieceLayout}"
                sizeMobile="${sizeMobile}"
                sizeDesktop="${sizeDesktop}"
                image="${paragraph.Image}"
                text="${paragraph.Text}"
                link="${paragraph.Link}"
                cssWrapper="${cssWrapper}"
                hsize="${hsize}"
                imageRatio="${imageRatio}"
                textOption="${textOption}"
                linkOption="${linkOption}"
                showImageCopyright="${showImageCopyright}"
                showImageSubtitle="${showImageSubtitle}"
                showImageZoom="${showImageZoom}"
                showImageLink="${showImageLink}"
                ade="${ade}"
            />
        </c:when>
    </c:choose>
</c:if>
