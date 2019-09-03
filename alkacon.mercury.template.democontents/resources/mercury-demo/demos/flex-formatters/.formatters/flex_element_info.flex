<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.element.info)]]></NiceName>
    <Type><![CDATA[m-article]]></Type>
    <Type><![CDATA[m-contact]]></Type>
    <Type><![CDATA[m-event]]></Type>
    <Type><![CDATA[m-section]]></Type>
    <Type><![CDATA[m-faq]]></Type>
    <Type><![CDATA[m-linksequence]]></Type>
    <Type><![CDATA[m-job]]></Type>
    <Rank><![CDATA[225]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element %settings.cssWrapper%">

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex element info formatter</span>
</div>
%endif%

<div class="headline">
<h2>
%if (content.value.Headline.isSet)%
  %! some content elements e.g. m-section use "Headline" !%
  %content.value.Headline%<br>
%elseif (content.value.Title.isSet)%
  %! Most other content elements e.g. m-article, m-event use "Title" !%
  %content.value.Title%<br>
%endif%
</h2>
</div>

<div class="lead">
  Information about the element<br>
  <small>
    %content.filename%<br>
    Type: %content.typeName%
  </small>
</div>

<div>
<h3>Content structure</h3>
<small>
  %content.printStructure%
</small>
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
