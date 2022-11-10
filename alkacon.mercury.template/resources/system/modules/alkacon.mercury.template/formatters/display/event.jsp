<%@page
    pageEncoding="UTF-8"
    buffer="none"
    session="false"
    trimDirectiveWhitespaces="true"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="cms" uri="http://www.opencms.org/taglib/cms"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="mercury" tagdir="/WEB-INF/tags/mercury" %>


<cms:secureparams />
<mercury:init-messages>

<cms:formatter var="content" val="value">
<mercury:teaser-settings content="${content}">

<fmt:setLocale value="${cms.locale}" />
<cms:bundle basename="alkacon.mercury.template.messages">

<c:set var="bookingOption"          value="${setting.bookingOption.useDefault('none').toString}" />
<c:set var="kindOption"             value="${setting.kindOption.isSetNotNone ? setting.kindOption.useDefault('online').toString : null}" />
<c:set var="showBtnOnlyForBooking"  value="${setting.showButtonOnlyForBooking.toBoolean}" />
<c:set var="instancedate"           value="${param.instancedate}" />
<c:set var="seriesInfo"             value="${value.Dates.toDateSeries}" />
<c:set var="date"                   value="${seriesInfo.instanceInfo.get(instancedate)}" />

<c:if test="${cms.isEditMode}">
    <c:choose>
        <c:when test="${seriesInfo.isSeries}">
            <c:set var="badge"><wbr><span class="list-badge oct-meta-info" title="<fmt:message key="msg.page.dateseries.series"><fmt:param>${seriesInfo.title}</fmt:param></fmt:message>"><span class="fa fa-refresh"></span></span></c:set>
        </c:when>
        <c:when test="${seriesInfo.isExtractedDate}">
            <c:set var="badge"><wbr><span class="list-badge oct-meta-info" title="<fmt:message key="msg.page.dateseries.extracted"><fmt:param>${seriesInfo.parentSeries.title}</fmt:param></fmt:message>"><span class="fa fa-scissors"></span></span></c:set>
        </c:when>
    </c:choose>
</c:if>

<c:if test="${setShowCalendar}">
    <c:set var="groupId">event-<fmt:formatDate value='${date.start}' pattern='d-MM-yyyy' type='date' /></c:set>
    <c:choose>
        <c:when test="${(setRatio eq 'none') and ((displayType eq 'teaser-compact') or (displayType eq 'teaser-elaborate'))}">
            <c:set var="smallCalendarSheet" value="${true}" />
        </c:when>
        <c:otherwise>
            <c:set var="setRatio" value="${setRatio eq 'none' ? '4-3' : setRatio}" />
        </c:otherwise>
    </c:choose>
</c:if>

<%-- Show the booking status if the event is bookable --%>
<c:if test="${(seriesInfo.isSingleDate or seriesInfo.isExtractedDate) and ((bookingOption ne 'none') or showBtnOnlyForBooking)}">
    <c:set var="bookingMarkup">
        <mercury:webform-booking-status
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
    <c:set var="eventKind"><mercury:event-kind content="${content}"/></c:set>
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

<mercury:teaser-piece
    cssWrapper="type-event${setShowCalendar ? ' calendar-sheet-piece ' : ' '}${setCssWrapper}${setEffect}"
    gridOption="${setShowCalendar and smallCalendarSheet ? ' fixed' : ''}"
    intro="${setShowIntro ? intro : null}"
    headline="${title}"
    headlineSuffix="${badge}"
    preface="${preface}"
    date="${date}"
    paraCaption="${paragraph.value.Caption}"
    paraText="${paragraph.value.Text}"
    preTextMarkup="${labelMarkup}"
    groupId="${groupId}"
    noLinkOnVisual="${setShowCalendar}"
    pieceLayout="${setPieceLayout}"
    sizeDesktop="${setSizeDesktop}"
    sizeMobile="${setShowCalendar ? 12 : setSizeMobile}"

    teaserType="${displayType}"
    link="${link}"
    linkOption="${setLinkOption}"
    hsize="${setHsize}"
    dateFormat="${setDateFormat}"
    textLength="${value['TeaserData/TeaserPreface'].isSet ? -1 : setTextLength}"
    buttonText="${setButtonText}">

    <jsp:attribute name="markupVisual">
        <c:if test="${setShowVisual}">
            <c:choose>
                <c:when test="${setShowCalendar}">
                    <mercury:calendar-sheet date="${date.start}" ratio="${setRatio}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="image" value="${value['TeaserData/TeaserImage'].isSet ? value['TeaserData/TeaserImage'] : (value.Image.isSet ? value.Image : (paragraph.value.Image.isSet ? paragraph.value.Image : null))}" />
                    <mercury:image-animated
                        image="${image}"
                        ratio="${setRatio}"
                        test="${not empty image}"
                        setTitle="${false}"
                        showCopyright="${setShowCopyright}"
                    />
                </c:otherwise>
            </c:choose>
        </c:if>
    </jsp:attribute>

</mercury:teaser-piece>

</cms:bundle>

</mercury:teaser-settings>
</cms:formatter>
</mercury:init-messages>
