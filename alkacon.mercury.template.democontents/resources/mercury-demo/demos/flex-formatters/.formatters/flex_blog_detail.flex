<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.blog.detail)]]></NiceName>
    <Type><![CDATA[m-article]]></Type>
    <Rank><![CDATA[240]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element %settings.cssWrapper%">

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex blog DETAIL formatter</span>
</div>
%endif%

<div class="headline">
  <h2>%content.value.Title%</h2>
</div>

<div class="lead">
  <span class="fa fa-calendar-o"></span>
  %content.value.Date.toDate; format="EEE dd.MM.YYY"%<br>
  <span class="fa fa-user-o"></span>
  %content.value.Author%
</div>

<img %content.value.Paragraph/Image/Image.toImage.imgSrc% class="img-responsive" />

<div>
%if (content.value.Teaser.isSet)%
  %content.value.Teaser%
%elseif (content.value.Paragraph/Text.isSet)%
  %fn.(fn.(content.value.Paragraph/Text.stripHtml)).trimToSize.("400")%
%endif%
</div>

%if (content.value.Paragraph.isSet)%
  %! This content has paragraphs !%
  <h3>There are %length(rest(content.valueList.Paragraph))% additional paragraphs in this content.</h3>

  %rest(content.valueList.Paragraph):{pg|
    <h3>%pg.path%:</h3>
    <ul>

      %if (pg.value.Headline.isSet)%
        <li>
          Headline:<br>
          <h4>%pg.value.Headline%</h4>
        </li>
      %endif%

      %if (pg.value.Text.isSet)%
        <li>Text:<br>%pg.value.Text%</li>
        <li>Text (truncated):<br>%fn.(fn.(pg.value.Text.stripHtml)).trimToSize.("100")%</li>
      %endif%

      %if (pg.value.Image.value.Image.isSet)%
        <li>
          Image:<br>
          <img %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").imgSrc% class="img-responsive">
          <br>Image source: %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").imgSrc%
          <br>Image original height: %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").height%
          <br>Image original width: %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").width%
          <br>Image scaled height: %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").scaler.height%
          <br>Image scaled width: %pg.value.Image.value.Image.toImage.scaleRatio.("3-1").scaler.width%
          %if (pg.value.Image.value.Title.isSet)%
            <br>Image Title: %pg.value.Image.value.Title%
          %endif%
          %if (pg.value.Image.value.Copyright.isSet)%
            <br>Image Copyright: %pg.value.Image.value.Copyright%
          %endif%
        </li>
      %endif%

      %if (pg.value.Link.value.URI.isSet)%
        <li>Link: <a href="%pg.value.Link.value.URI%">%pg.value.Link.value.Text%</a></li>
      %endif%

    </ul>
  }%
%endif%


</div>]]></StringTemplate>
    <Setting>
      <PropertyName><![CDATA[cssWrapper]]></PropertyName>
      <DisplayName><![CDATA[%(key.msg.setting.cssWrapper)]]></DisplayName>
      <Description><![CDATA[%(key.msg.setting.cssWrapper.help)]]></Description>
      <Widget><![CDATA[string]]></Widget>
    </Setting>
    <Setting>
      <PropertyName><![CDATA[showname]]></PropertyName>
      <DisplayName><![CDATA[Show formatter name]]></DisplayName>
      <Widget><![CDATA[checkbox]]></Widget>
      <Default><![CDATA[true]]></Default>
    </Setting>
  </FlexFormatter>
</FlexFormatters>
