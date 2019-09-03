<?xml version="1.0" encoding="UTF-8"?>

<FlexFormatters xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="opencms://system/modules/org.opencms.ade.config/schemas/formatters/flex_formatter.xsd">
  <FlexFormatter language="en">
    <NiceName><![CDATA[%(key.type.flex.formatter.demo)]]></NiceName>
    <Type><![CDATA[m-article]]></Type>
    <Type><![CDATA[m-contact]]></Type>
    <Type><![CDATA[m-event]]></Type>
    <Type><![CDATA[m-section]]></Type>
    <Type><![CDATA[m-faq]]></Type>
    <Type><![CDATA[m-linksequence]]></Type>
    <Type><![CDATA[m-job]]></Type>
    <Rank><![CDATA[200]]></Rank>
    <Match>
      <Types>
        <ContainerType><![CDATA[element]]></ContainerType>
      </Types>
    </Match>
    <AutoEnabled>false</AutoEnabled>
    <StringTemplate><![CDATA[<div class="element %settings.cssWrapper%">
%! This is a comment !%

%if (settings.showname.toBoolean)%
<div class="mb-10">
  <span class="badge">Flex demo formatter</span>
</div>
%endif%

<h2 class="mb-5">%content.typeName%</h2>
<div class="mb-20">%content.filename%</div>

%! Content value access !%
<div>
  %if (content.value.Headline.isSet)%
    %! isSet will be true if a value is available !%
    <h3>Headline: %content.value.Headline%</h3>
  %endif%
  %if (content.value.Headline.isEmpty)%
    %! isEmpty will be true if NO value is available !%
    <h3>This content has no Headline</h3>
  %endif%
  %if (! content.value.Title.isEmpty)%
    %! There is support for 'if not' !%
    <h3>Title: %content.value.Title%</h3>
  %endif%
  %if (content.value.Title.IsEmptyOrWhitespaceOnly)%
    %! IsEmptyOrWhitespaceOnly will be true if there is either no value or the value is all whitespace !%
    <h3>This content has no Title</h3>
  %endif%

  %if (content.value.Paragraph.isSet)%
    %! This content has paragraphs !%
    <h3>There are %length(content.valueList.Paragraph)% paragraphs in this content.

    %content.valueList.Paragraph:{pg|
      <h3>Paragraph %i%:</h3>
      <ul>

        %if (pg.value.Headline.isSet)%
          <li>Headline: %pg.value.Headline%</li>
        %endif%
        %if (pg.value.Text.isSet)%
          <li>Text:<br>%pg.value.Text%</li>
          <li>Text (truncated):<br>%fn.(fn.(pg.value.Text.stripHtml)).trimToSize.("100")%</li>
        %endif%
        %if (pg.value.Image.value.Image.isSet)%
          <li>
            Image:<br>
            <img %pg.value.Image.value.Image.toImage.imgSrc% class="img-responsive">
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
</div>

%! Settings access !%
<div>
  <h3>Setting selected:
    %if (fn.(settings.selectdemo).isEqual.("one"))%
      Option one
    %elseif (fn.(settings.selectdemo).isEqual.("two"))%
      The second
    %elseif (fn.(settings.selectdemo).isEqual.("three"))%
      Number three
    %elseif (fn.(settings.selectdemo).isEqual.("four"))%
      Four (the last)
    %endif%
  </h3>
</div>

<div>
  Information from the context:<br>
  Current user: %content.vfs.currentUser.name%<br>
  Request time: %fn.(content.vfs.context.requestTime).toDate; format="EEEE, dd.MM.yyyy hh:mm a"%
</div>

</div>]]></StringTemplate>
    <Setting>
      <PropertyName><![CDATA[cssWrapper]]></PropertyName>
      <DisplayName><![CDATA[%(key.msg.setting.cssWrapper)]]></DisplayName>
      <Description><![CDATA[%(key.msg.setting.cssWrapper.help)]]></Description>
      <Widget><![CDATA[string]]></Widget>
    </Setting>
    <Setting>
      <PropertyName><![CDATA[selectdemo]]></PropertyName>
      <DisplayName><![CDATA[Settings select demo]]></DisplayName>
      <Widget><![CDATA[select]]></Widget>
      <Default><![CDATA[one]]></Default>
      <WidgetConfig><![CDATA[one:This is option one|two:The next option is two|three:Another option is three|four:The last option is four]]></WidgetConfig>
    </Setting>
    <Setting>
      <PropertyName><![CDATA[showname]]></PropertyName>
      <DisplayName><![CDATA[Show formatter name]]></DisplayName>
      <Widget><![CDATA[checkbox]]></Widget>
      <Default><![CDATA[true]]></Default>
    </Setting>
  </FlexFormatter>
</FlexFormatters>
