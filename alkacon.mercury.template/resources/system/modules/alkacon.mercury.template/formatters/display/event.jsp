<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="m" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams replaceInvalid="bad_param" />
<m:init-messages>

<cms:formatter var="content" val="value">
<m:teaser-settings content="${content}">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="bookingOption"          value="${setting.bookingOption.useDefault('none').toString}" />
<c:set var="kindOption"             value="${setting.kindOption.isSetNotNone ? setting.kindOption.useDefault('online').toString : null}" />
<c:set var="showBtnOnlyForBooking"  value="${setting.showButtonOnlyForBooking.toBoolean}" />
<c:set var="instancedate"           value="${param.instancedate}" />
<c:set var="seriesInfo"             value="${value.Dates.toDateSeries}" />
<c:set var="date"                   value="${seriesInfo.instanceInfo.get(instancedate)}" />

<m:list-badge var="badge" seriesInfo="${seriesInfo}" test="${cms.isEditMode}" />

<c:if test="${setShowCalendar}">
    <c:set var="groupId">event-<fmt:formatDate value='${date.start}' pattern='d-MM-yyyy' type='date' /></c:set>
    <c:choose>
        <c:when test="${(setRatio eq 'none') and ((displayType eq 'teaser-compact') or (displayType eq 'teaser-elaborate'))}">
            <c:set var="smallCalendarSheet" value="${true}" />
        </c:when>
        <c:otherwise>
            <%-- calendar sheet in mobile does NOT use the ratio anyway, so setRatio for the calendar sheet must always use the desktop ratio if available --%>
            <c:set var="setRatio" value="${not empty setRatioLg ? setRatioLg : setRatio}" />
            <c:set var="setRatio" value="${setRatio eq 'none' ? '4-3' : setRatio}" />
        </c:otherwise>
    </c:choose>
</c:if>

<%-- Show the booking status if the event is bookable --%>
<c:if test="${(seriesInfo.isSingleDate or seriesInfo.isExtractedDate) and ((bookingOption ne 'none') or showBtnOnlyForBooking)}">
    <c:set var="bookingMarkup">
        <m:webform-booking-status
            bookingContent="${content}"
            style="${bookingOption}"
            dateFormat="${setDateFormat}"
            noDivWrapper="${true}"
        />
    </c:set>
    <c:set var="isBookable" value="${not empty bookingMarkup}" />
    <c:if test="${bookingOption eq 'none'}">
        <c:set var="bookingMarkup" value="" />
    </c:if>
</c:if>

<c:if test="${showBtnOnlyForBooking}">
    <c:choose>
        <c:when test="${not isBookable}">
            <c:set var="setButtonText" value="none" />
        </c:when>
        <c:when test="${empty setButtonText}">
            <c:set var="setButtonText">
                <fmt:message key="msg.page.bookingLink" />
            </c:set>
        </c:when>
    </c:choose>
</c:if>

<c:if test="${not empty kindOption}">
    <c:set var="eventKind"><m:event-kind content="${content}"/></c:set>
    <c:set var="showEventKind" value="${kindOption eq 'all' ? true : (eventKind eq 'online' or eventKind eq 'mixed')}" />
</c:if>

<c:if test="${(not empty bookingMarkup) or showEventKind}">
    <c:set var="labelMarkup">
        <div class="book-info"><%----%>
            <c:if test="${showEventKind}">
                <span class="book-msg kind-msg kind-${eventKind}"><fmt:message key="msg.page.event.kind.${eventKind}" /></span><%----%>
            </c:if>
            <c:if test="${not empty bookingMarkup}">
                ${bookingMarkup}
            </c:if>
        </div><%----%>
    </c:set>
</c:if>

<c:set var="link"><cms:link baseUri="${pageUri}">${content.filename}?instancedate=${instancedate}</cms:link></c:set>
<c:set var="intro"   value="${value['TeaserData/TeaserIntro'].isSet ? value['TeaserData/TeaserIntro'] : value.Intro}" />
<c:set var="title"   value="${value['TeaserData/TeaserTitle'].isSet ? value['TeaserData/TeaserTitle'] : value.Title}" />
<c:set var="preface" value="${value['TeaserData/TeaserPreface'].isSet ? value['TeaserData/TeaserPreface'] : value.Preface}" />

<m:teaser-piece
    cssWrapper="type-event${setShowCalendar ? ' calendar-sheet-piece ' : ' '}${setCssWrapperAll}"
    gridOption="${setShowCalendar and smallCalendarSheet ? ' fixed' : ''}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    headlineSuffix="${badge}"
    preface="${preface}"
    date="${date}"
    paraCaption="${paragraph.value.Caption}"
    paraText="${paragraph.value.Text}"
    piecePreMarkup="${setElementPreMarkup}"
    preTextMarkup="${labelMarkup}"
    groupId="${groupId}"
    noLinkOnVisual="${setShowCalendar}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setShowCalendar ? 12 : setSizeMobile}"

    teaserType="${displayType}"
    link="${link}"
    linkOption="${setLinkOption}"
    linkNewWin="${setLinkNewWin}"
    hsize="${setHsize}"
    dateFormat="${setDateFormat}"
    textLength="${value['TeaserData/TeaserPreface'].isSet ? -1 : setTextLength}"
    headingInBody="${setHeadingInBody}"
    buttonText="${setButtonText}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <c:choose>
                <c:when test="${setShowCalendar}">
                    <m:calendar-sheet date="${date.start}" ratio="${setRatio}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="image" value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (value.Image.isSet ? value.Image : (paragraph.value.Image.isSet ? paragraph.value.Image : null))}" />
                    <m:image-animated
                        image="${image}"
                        ratio="${setRatio}"
                        ratioLg="${setRatioLg}"
                        test="${not empty image}"
                        setTitle="${false}"
                        showCopyright="${setShowCopyright}"
                    />
                </c:otherwise>
            </c:choose>
        </c:if>
    </jsp:attribute>

</m:teaser-piece>

</cms:bundle>

</m:teaser-settings>
</cms:formatter>
</m:init-messages>
