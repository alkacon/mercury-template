<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.section.ade)]]></NiceName>
    <Type><![CDATA[m-section]]></Type>
    <Rank><![CDATA[240]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element box %settings.cssWrapper%">

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex content section formatter with ADE support</span>
</div>
%endif%

%if (content.value.Headline.isSet)%
  <h1 style="text-transform: uppercase; font-size: 40px;" %content.value.Headline.rdfaAttr%>
    %! ###### Add "(textvalue).rdfaAttr to a surrounding block element to enable ADE ###### !%
    %content.value.Headline%
  </h1>
%endif%

%if (content.value.Text.isSet)%
  <div class="lead" %content.value.Text.rdfaAttr%>
    %! ###### Add "(textvalue).rdfaAttr to a surrounding block element to enable ADE ###### !%
    %content.value.Text%
  </div>
%endif%

%if (content.value.Image/Image.isSet)%
  <div %content.value.Image/Image.imageDndAttr%>
    %! ###### Add "(imagevalue).imageDndAttr" to a surrounding block element to enable drag & drop of the image ###### !%
    <img %content.value.Image/Image.toImage.imgSrc% class="img-responsive">
  </div>
%endif%

%if (content.value.Link.isSet)%
  <div class="lead mt-20" %content.value.Link.rdfaAttr%>
    %! ###### If "(textvalue).rdfaAttr is added to a combined value, an edit menu is made available ###### !%
    <a href="%content.value.Link.value.URI.toLink%" class="btn">%content.value.Link.value.Text%</a>
  </div>
%endif%

</div>
]]></StringTemplate>
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
