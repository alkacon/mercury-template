<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.section.bgimage)]]></NiceName>
    <Type><![CDATA[m-section]]></Type>
    <Rank><![CDATA[250]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element %settings.cssWrapper%"
%if (content.value.Image/Image.isSet)%
  style="
  background-image: url('%content.value.Image/Image.toLink%'); background-size: cover; background-position: center;
  %if (!fn.(settings.boxheight).isEqual.("initial"))%
    height: auto; min-height: %settings.boxheight%;
  %endif%
  "
%endif%
>

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex  content section background image formatter</span>
</div>
%endif%

<h1 style="text-transform: uppercase; font-size: 40px;">
  %content.value.Headline%
</h1>

<div class="lead">
  %content.value.Text%
</div>

</div>
]]></StringTemplate>
    <Setting>
      <PropertyName><![CDATA[cssWrapper]]></PropertyName>
      <DisplayName><![CDATA[%(key.msg.setting.cssWrapper)]]></DisplayName>
      <Description><![CDATA[%(key.msg.setting.cssWrapper.help)]]></Description>
      <Widget><![CDATA[string]]></Widget>
    </Setting>
    <Setting>
      <PropertyName><![CDATA[boxheight]]></PropertyName>
      <DisplayName><![CDATA[Box minimum height]]></DisplayName>
      <Widget><![CDATA[selectcombo]]></Widget>
      <Default><![CDATA[initial]]></Default>
      <WidgetConfig><![CDATA[initial:Use default content height|250px:250 Pixel|500px:500 Pixel|750px:750 Pixel]]></WidgetConfig>
    </Setting>
    <Setting>
      <PropertyName><![CDATA[showname]]></PropertyName>
      <DisplayName><![CDATA[Show formatter name]]></DisplayName>
      <Widget><![CDATA[checkbox]]></Widget>
      <Default><![CDATA[true]]></Default>
    </Setting>
  </FlexFormatter>
</FlexFormatters>
