<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.blog.teaser)]]></NiceName>
    <Type><![CDATA[m-article]]></Type>
    <Rank><![CDATA[250]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element %settings.cssWrapper%">

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex blog teaser formatter</span>
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

<a href="%content.fileLink%" class="btn btn-sm mv-10">Read more</a>

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
