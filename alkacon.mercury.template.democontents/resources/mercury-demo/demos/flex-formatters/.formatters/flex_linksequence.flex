<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.linksequence)]]></NiceName>
    <Type><![CDATA[m-linksequence]]></Type>
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
  <span class="badge">Flex link sequence formatter</span>
</div>
%endif%

<div class="headline">
  <h2>%content.value.Title%</h2>
</div>

<ul>
%content.valueList.LinkEntry:{item|
  <li>
    <a href="%item.value.URI.toLink%">
      %item.value.Text% (%i%)
    </a>
  </li>
}%
</ul>

<div>
  There are %length(content.valueList.LinkEntry)% links in this sequence.
</div>

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
