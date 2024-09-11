group webform;

form_twocolumns() ::= "false"


form(formuri,enctype,errormessage,mandatorymessage,formconfig,fields,submitbutton,resetbutton,hiddenfields,prevbutton,subfieldjs,waitlistmessage) ::= <<
$! ###### Main input form ###### !$

$if(formconfig.formText)$
$! --- show form header text --- !$
$!  !$<div class="form-text form-header">$formconfig.formText$</div>
$endif$
$if(waitlistmessage)$$waitlist_notification(waitlistmessage)$$endif$
<form$!
   !$ name="emailform$formconfig.configId$"$!
   !$ id="emailform$formconfig.configId$"$!
   !$ action="$formuri$#emailform$formconfig.configId$"$!
   !$ method="post"$!
   !$ class="styled-form$if(errormessage)$ state-error$endif$$if(formconfig.extraConfig.formCssWrapper)$ $formconfig.extraConfig.formCssWrapper$$endif$"$enctype$$!
!$>

$! --- show validation errors -- !$
$if(errormessage)$
$!  !$<header class="note-error" tabindex="0">
$!    !$$errormessage$
$!  !$</header>
$endif$

<div style="display: none;">
<input type="hidden" name="formsubmit" value="$formconfig.configId$" />
<input type="hidden" name="formaction$formconfig.configId$" id="formaction$formconfig.configId$" value="submit" />
</div>

<fieldset>
$!  !$$fields$
</fieldset>

$if(formconfig.formMiddleText)$
$! --- show form middle text --- !$
$!  !$<fieldset>
$!      !$<div class="form-text form-middle">$formconfig.formMiddleText$</div>
$!  !$</fieldset>
$endif$

<footer>

$if(mandatorymessage)$
$! --- show mandatory note --- !$
$!  !$<section><div class="form-text note">$mandatorymessage$</div></section>
$endif$

$! --- show submit, reset and previous button --- !$
$if(submitbutton)$
    $hiddenfields$
$!  !$<div class="formbtn-row">
    $if(prevbutton)$
$!      !$<input type="submit" value="$prevbutton$" name="back$formconfig.configId$" id="back_$formconfig.configId$" class="btn formbtn prevbutton" />
    $endif$
    $if(resetbutton)$
$!      !$<a href="$formuri$" class="btn formbtn resetbutton">$resetbutton$</a>
    $endif$
$!      !$<input type="submit" value="$submitbutton$" id="submit_$formconfig.configId$" class="btn formbtn submitbutton" />
$!  !$</div>
$endif$

</footer>
</form>

$if(subfieldjs)$
$! --- JavaScript for sub fields --- !$
$!  !$<script type="text/javascript">$subfieldjs$</script>
$endif$

$if(formconfig.formFooterText)$
$! --- show form footer text --- !$
$!  !$<div class="form-text form-footer">$formconfig.formFooterText$</div>
$endif$

>>


form_js(formconfig,sessionjs,sessionuri,subfieldjs) ::= <<
$! ###### JAVASCRIPT for Main input form ###### !$
$if(sessionjs)$
<script type="text/javascript" src="$sessionjs$"></script>
<script type="text/javascript">
$!  !$var formgenRefreshSessionTimeout = $formconfig.refreshSessionInterval$;var formgenKeepSessionURI = "$sessionuri$";
$!  !$setTimeout("formgenKeepSession();", $formconfig.refreshSessionInterval$);
</script>
$endif$
<script type="text/javascript" src="$subfieldjs$"></script>
>>


field_captcha(field,formconfig,attributes,errormessage,mandatory,captcha,readonly,captchawidget) ::= <<
$! ###### CAPTCHA field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
$if(captcha)$
$!  !$<div class="input $if(errormessage)$state-error$endif$">
$!       !$<div class="captcha">
$!       !$$captcha$
$!       !$</div>
$!       !$<input type="text" id="$field.name$" name="$field.name$" value="$field.valueEscaped$" $readonly$/>
$!  !$</div>
$elseif(captchawidget)$
$!  !$<div class="input">
$!      !$<input type="hidden" id="$field.name$" name="$field.name$"/>
$!      !$$captchawidget$
$!  !$</div>
$endif$
$if(errormessage)$
    <div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_checkbox(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### Checkbox field ###### !$
$row_start(field=field)$
<label for="$field.name$_box" class="label" tabindex="0">
$!  !$$field.label$ $mandatory$
</label>
$if(field.parameters)$$if(field.parameters.full)$$else$<div class="inline-group">$endif$$else$<div class="inline-group">$endif$
$!  !$<div id="$field.name$_box">
$!  !$$field.items:{
$!      !$<label for="$field.name$_$i0$" class="$if(field.parameters)$$if(field.parameters.toggle)$toggle$else$checkbox$endif$$else$checkbox$endif$$if(errormessage)$ state-error$endif$">
$!          !$<input id="$field.name$_$i0$" type="checkbox" name="$field.name$" value="$it.value$" class="check"$if(it.selected)$ checked="checked"$endif$/><i></i>$it.label$
$!      !$</label>
$!  !$}$
$!  !$</div>
$if(field.parameters)$$if(field.parameters.full)$$else$</div>$endif$$else$</div>$endif$
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_email(field,formconfig,errormessage,mandatory) ::= <<
$! ###### EMAIL field ###### !$
$field_text(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
>>


field_empty(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### EMPTY field ###### !$
$row_start(field=field)$
$!  !$<label class="label">&nbsp;</label>
$!  !$<div class="input">
$!      !$$if(field.valueEscaped)$
$!          !$$field.valueEscaped$
$!      !$$else$
$!          !$&nbsp;
$!      !$$endif$
$!  !$</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_file(field,formconfig,attributes,errormessage,mandatory,infomessage) ::= <<
$! ###### FILE UPLOAD field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input input-file$if(errormessage)$ state-error$endif$$if(infomessage)$ state-info$endif$">
$!  !$<div class="button">
$!      !$<input type="file" name="$field.name$" id="$field.name$" onchange="document.getElementById('$field.name$-Visible').value = this.value" value="$field.valueEscaped$"/>
$!      !$$if(field.parameters)$$if(field.parameters.buttontext)$$field.parameters.buttontext$$else$Browse$endif$$else$Browse$endif$
$!  !$</div>
$!  !$<label for="$field.name$-Visible" class="sr-only">$field.label$ $mandatory$</label>
$!  !$<input type="text" id="$field.name$-Visible" readonly=""$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$if(infomessage)$
$!  !$<div class="note note-info">$infomessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_hidden(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### HIDDEN field ###### !$
<div style="display: none;"><input type="hidden" name="$field.name$" value="$field.valueEscaped$"/></div>
$subtext(field=field,formconfig=formconfig)$
>>


field_paging(field,formconfig,attributes,errormessage,mandatory,hiddenfields,prevbutton,nextbutton,page) ::= <<
$! ###### PAGING field ###### !$
$row_start(field=field)$
<div class="webform_label">&nbsp;</div>
<div class="webform_field">
$!  !$$hiddenfields$
$!  !$<div class="formbtn-row">
$!      !$$if(prevbutton)$
$!      !$<input type="submit" value="$prevbutton$" name="back$formconfig.configId$" class="btn formbtn prevbutton" />&nbsp;
$!      !$$endif$
$!      !$<input type="submit" value="$nextbutton$" class="btn formbtn nextbutton" />
$!      !$<input type="hidden" name="page$formconfig.configId$" value="$page$" />
$!  !$</div>
</div>
$row_end(field=field,formconfig=formconfig)$
>>


field_password(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### PASSWORD field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<input type="password" name="$field.name$" id="$field.name$" value="$field.valueEscaped$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$/>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_privacy(field,formconfig,attributes,errormessage,mandatory,label,link,linktext) ::= <<
$! ###### PRIVACY field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="inline-group">
$!  !$$field.items:{
$!      !$<label class="checkbox$if(errormessage)$ state-error$endif$">
$!          !$<input type="checkbox" name="$field.name$" id="$field.name$" value="$it.value$" class="check"$if(it.selected)$ checked="checked"$endif$/><i></i><a href="$link$" target="_blank">$linktext$</a>
$!      !$</label>
$!  !$}$
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_radio(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### RADIO BUTTONS field ###### !$
$row_start(field=field)$
<label for="$field.name$_box" class="label" tabindex="0">$field.label$ $mandatory$</label>
$!  !$<div id="$field.name$_box">
$!      !$$field.items:{
$!          !$<label for="$field.name$_$i0$" class="$if(field.parameters)$$if(field.parameters.toggle)$toggle$else$radio$endif$$else$radio$endif$$if(errormessage)$ state-error$endif$">
$!              !$<input type="radio" name="$field.name$" id="$field.name$_$i0$" value="$it.value$" class="radio"$if(it.selected)$ checked="checked"$endif$$if(field.hasSubFields)$ onchange="toggleWebformSubFields(this);"$endif$/><i></i>$it.label$
$!          !$</label>
$!      !$}$
$!  !$</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_select(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### SELECT field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="select$if(errormessage)$ state-error$endif$">
$!  !$<select name="$field.name$" id="$field.name$" $if(field.hasSubFields)$ onchange="toggleWebformSubFields(this);"$endif$>
$!  !$$field.items:{
$!      !$<option value="$it.value$" $if(it.selected)$ selected="selected"$endif$>$it.label$</option>
$!  !$}$
$!  !$</select>
$!  !$<i></i>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_email_select(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### SELECT field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="select$if(errormessage)$ state-error$endif$">
$!  !$<select name="$field.name$" id="$field.name$" $if(field.hasSubFields)$ onchange="toggleWebformSubFields(this);"$endif$>
$!      !$$field.items:{
$!          !$<option value="$it.valueHash$" $if(it.selected)$ selected="selected"$endif$>$it.label$</option>
$!      !$}$
$!  !$</select>
$!  !$<i></i>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_text(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### TEXT field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<input type="text" id="$field.name$" name="$field.name$" value="$field.valueEscaped$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$/>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_date(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### DATE field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<input type="text" class="datepicker" data-datepicker='{$if(field.parameters.dateFormat)$"dateFormat": "$field.parameters.dateFormat$"$endif$}' id="$field.name$" name="$field.name$" value="$field.valueEscaped$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$/>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_time(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### TIME field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<input type="text" class="datepicker" data-datepicker='{"time_24hr": true, "noCalendar":true,"enableTime":true$if(field.parameters.dateFormat)$, "dateFormat": "$field.parameters.dateFormat$"$endif$}' id="$field.name$" name="$field.name$" value="$field.valueEscaped$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$/>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_datetime(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### DATETIME field ###### !$
$row_start(field=field)$
$label(field=field,formconfig=formconfig,errormessage=errormessage,mandatory=mandatory)$
<div class="input$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<input type="text" class="datepicker" data-datepicker='{"time_24hr": true, "enableTime":true$if(field.parameters.dateFormat)$, "dateFormat": "$field.parameters.dateFormat$"$endif$}' id="$field.name$" name="$field.name$" value="$field.valueEscaped$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$/>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


field_textarea(field,formconfig,attributes,errormessage,mandatory) ::= <<
$! ###### TEXTAREA field ###### !$
$row_start(field=field)$
<label for="$field.name$" class="label">$field.label$ $mandatory$</label>
<div class="textarea$if(errormessage)$ state-error$endif$">
$!  !$$if(field.parameters)$
$!      !$$if(field.parameters.icon)$
$!          !$<span class="icon-$if(field.parameters.position)$$field.parameters.position$$else$prepend$endif$ fa fa-$field.parameters.icon$"></span>$! m:icon !$
$!      !$$endif$
$!  !$$endif$
$!  !$<textarea cols="50" rows="$if(field.parameters.rows)$$field.parameters.rows$$else$5$endif$" id="$field.name$" name="$field.name$"$if(field.parameters)$$if(field.parameters.placeholder)$ placeholder="$field.parameters.placeholder$"$endif$$endif$ $attributes$>$field.valueEscaped$</textarea>
</div>
$if(errormessage)$
$!  !$<div class="note note-error" tabindex="0">$errormessage$</div>
$endif$
$row_end(field=field,formconfig=formconfig)$
>>


label(field,formconfig,errormessage,mandatory) ::= <<
$! ###### Standard LABEL for a field ###### !$
<label for="$field.name$" class="label">$field.label$ $mandatory$</label>
>>


row_start(field) ::= <<
$! ###### Standard start row for a field ###### !$
$if(field.showRowStart)$
$!  !$<section class="form-field-$field.type$">
$endif$
>>


row_end(field,formconfig) ::= <<
$! ###### Standard end row for a field ###### !$
$if(field.showRowEnd)$
$!  !$</section>
$endif$
$subtext(field=field,formconfig=formconfig)$
>>


subfieldwrapper(subfields,style,id) ::= <<
$! ###### Sub field wrapper ###### !$
<div class="webform_subfields" id="$id$" style="$style$"><fieldset>
$subfields$
</fieldset></div>
>>


subtext(field,formconfig) ::= <<
$! ###### Intermediate texts for the fields ###### !$
$if(field.hasText)$
$!  !$$if(field.showRowStart)$
$!      !$<section>
$!  !$$endif$
$!  !$$if(field.text.columnLeft)$
$!      !$<div class="pull-left">
$!          !$$field.text.text$
$!      !$</div><div class="clearfix"></div>
$!  !$$elseif(field.text.columnRight)$
$!      !$<div class="pull-right">
$!          !$$field.text.text$
$!      !$</div><div class="clearfix"></div>
$!  !$$else$
$!      !$<div>$field.text.text$</div>
$!  !$$endif$
$!  !$$if(field.showRowEnd)$
$!      !$</section>
$!  !$$endif$
$endif$
>>


checkpage(formuri,formconfig,checktext,captchafield,captchawidget,captchaerror,captchaimagelink,captchatokenid,checkfields,hiddenfields,checkbutton,correctbutton,captchatext) ::= <<
$! ###### CHECK page of the form ###### !$
$checktext$
<table class="webform-input table table-responsive table-bordered table-striped">
$checkfields:{$!
    !$<tr>$!
        !$<td class="label">$it.label$</td>$!
        !$<td class="value">$it.value$</td>$!
    !$</tr>
}$</table>

<div class="styled-form checkpage$if(captchaerror)$ state-error$endif$">

$if(captchafield)$
$!  !$<script>
$!      !$function runConfirmValues() {
$!          !$document.getElementById("webformconfirmvalues$formconfig.configId$").elements["$captchafield.name$"].value = "" + document.getElementById("webformcaptcha$formconfig.configId$").elements["$captchafield.name$"].value;
$!          !$return updateAction("webformconfirmvalues$formconfig.configId$");
$!      !$}
$!      !$function updateAction(formElementId) {
$!          !$var newaction = document.getElementById(formElementId).action;
$!          !$var separator = newaction.indexOf('?') !== -1 ? "&" : "?";
$!          !$document.getElementById(formElementId).action=newaction + separator + "formsubmit=$formconfig.configId$";
$!          !$return true;
$!      !$}
$!  !$</script>
$!  !$<form id="webformcaptcha$formconfig.configId$" action="" method="post" enctype="multipart/form-data">
$!  !$<fieldset>
$!  !$$row_start(field=captchafield)$
$!  !$<label class="label">$captchafield.label$</label>
$!  !$$if(captchawidget)$
$!      !$<div class="input">
$!          !$<input type="hidden" id="$captchafield.name$" name="$captchafield.name$" value="" />
$!          !$$captchawidget$
$!      !$</div>
$!  !$$else$
$!      !$<div class="input">
$!          !$<div class="captcha">
$!              !$$if (captchaimagelink)$
$!                 !$<img src="$captchaimagelink$" class="img-responsive" alt="" />
$!              !$$endif$
$!              !$$if (captchatext)$
$!                 !$<div>$captchatext$</div>
$!              !$$endif$
$!          !$</div>
$!          !$<input type="hidden" id="$captchafield.C_PARAM_CAPTCHA_TOKEN_ID$" name="$captchafield.C_PARAM_CAPTCHA_TOKEN_ID$" value="$captchatokenid$"/>
$!      !$</div>
$!      !$<label class="input$if(captchaerror)$ state-error$endif$">
$!          !$<input type="text" name="$captchafield.name$" value="" />
$!      !$</label>
$!  !$$endif$
$!  !$$if(captchaerror)$
$!      !$<div class="note note-error" tabindex="0">$captchaerror$</div>
$!  !$$endif$
$!  !$$row_end(field=captchafield,formconfig=formconfig)$
$!  !$</fieldset>
$!  !$</form>
$endif$

$!  !$<footer class="formbtn-row">
$!  !$<form id="webformdisplayvalues$formconfig.configId$" method="post" enctype="multipart/form-data" action="$formuri$" class="formbtn correctaction" onsubmit="return updateAction('webformdisplayvalues$formconfig.configId$');">
$!  !$<div style="display: none;">
$!      !$<input type="hidden" name="formsubmit" value="$formconfig.configId$" />
$!      !$<input type="hidden" name="formaction$formconfig.configId$" value="correct" />
$!      !$$hiddenfields$
$!  !$</div>
$!  !$<input type="submit" value="$correctbutton$" class="btn submitbutton"/>
$!  !$</form>
$!  !$<form id="webformconfirmvalues$formconfig.configId$" method="post" enctype="multipart/form-data" action="$formuri$" class="formbtn submitaction" onsubmit="return runConfirmValues();">
$!  !$<div style="display: none;">
$!      !$<input type="hidden" name="formsubmit" value="$formconfig.configId$" />
$!      !$<input type="hidden" name="formaction$formconfig.configId$" value="confirmed" />
$!      !$<input type="hidden" name="captchaphrase$formconfig.configId$" value="" />
$!      !$<input type="hidden" name="$captchafield.C_PARAM_CAPTCHA_TOKEN_ID$" value="$captchatokenid$"/>
$!      !$$hiddenfields$
$!  !$</div>
$!  !$<input type="submit" value="$checkbutton$" class="btn submitbutton" />
$!  !$</form>
$!  !$</footer>

</div>
>>


confirmationpage(formconfig,confirmtext,confirmfields) ::= <<
$! ###### CONFIRMATION page of the form ###### !$
<div class="form-text form-confirm">$confirmtext$</div>
<table class="webform-input table table-responsive table-bordered table-striped matomo-goal">
$confirmfields:{$!
    !$<tr>$!
        !$<td class="label">$it.label$</td>$!
        !$<td class="value">$it.value$</td>$!
    !$</tr>
}$</table>
>>

fullybooked(headline,text) ::= <<
$! ###### FULLYBOOKED page hint of the form ###### !$
<div class="online-warn">
$!  !$<div class="webform_fullybooked_headline warn-head h2">$headline$</div>
$!  !$<div class="webform_fullybooked_text warn-text">$text$</div>
</div>
>>

waitlist_notification(message) ::= <<
$! ###### wait list notification used by the FORM template ###### !$
<div class="online-warn">
$!  !$<div class="webform_fullybooked_headline warn-head h2">$message$</div>
</div>
>>

htmlemail(mailcss,mailtext,errorheadline,errors,icalinfo) ::= <<
$! ###### HTML email for the form ###### !$
<html><head>
<style type="text/css">
$if(mailcss)$
$!  !$$mailcss$
$else$
* { font-family: Verdana, Arial, Helvetica, sans-serif;  font-size: 12px; color: #000; }
h1 { font-size: 16px; font-weight: bold; }
p.foot { font-size: 9px; color: #555; }
table.dataform { border-collapse: collapse; border: 1px solid #333; }
table.dataform tr td { border-top: 1px solid #ccc; vertical-align:top; padding: 8px; }
table.dataform tr td.first { border-top: none; }
td.data { font-weight: bold; }
table.table-wf-label { vertical-align: top; }
table.table-wf-label tr th, table.table-wf-label tr td, table.table-wf-field tr th, table.table-wf-field tr td { white-space: nowrap; }
td.table-wf-label { vertical-align: top; }
table.table-wf-field thead, table.table-wf-field tbody, table.table-wf-label thead { margin: 0; padding: 0; }
table.table-wf-label tr th, table.table-wf-field tr td, table.table-wf-field tr th { height: 25px; }
table.table-wf-field tr td { padding-top: 0 !important; padding-bottom: 0 !important; }
table.wtable-wf-label tr th:first-child { vertical-align: middle; }
$endif$
</style>
</head><body>
$mailtext$
$if(icalinfo)$
$!  !$<p><a href="$icalinfo.link$" download="$icalinfo.fileName$">$icalinfo.label$</a></p>
$endif$
$if(errorheadline)$
$!  !$<h1>$errorheadline$</h1>
$!  !$<p>
$!  !$$errors:{
$!      !$$it$<br/>
$!  !$}$
$!  !$</p>
$endif$
</body></html>
>>


htmlemailfields(mailcss,fields) ::= <<
$! ###### FIELDS for the HTML email ###### !$
<table border="0" class="dataform$if(!mailcss)$ fields$endif$">
$first(fields):{
$!  !$<tr>
$!      !$<td class="first$if(!mailcss)$ fieldlabel$endif$"> $it.label$</td>
$!      !$<td class="first$if(mailcss)$ data$else$ fieldvalue$endif$">$it.value$</td>
$!  !$</tr>
}$
$rest(fields):{
$!  !$<tr>
$!      !$<td class="$if(!mailcss)$fieldlabel$endif$"> $it.label$</td>
$!      !$<td class="$if(mailcss)$data$else$fieldvalue$endif$">$it.value$</td>
$!  !$</tr>
}$
</table>
>>


submissionerror(headline,text,error) ::= <<
$! ###### EMAIL error message ###### !$
<div class="oct-alert oct-alert-error">
$!  !$<div class="head">$headline$</div>
$!  !$<div class="text">$text$</div>
$!  !$<!--
$!      !$Error description: $error$
$!  !$-->
</div>
>>


initerror(headline,text) ::= <<
$! ###### Initialization error message ###### !$
<div class="oct-alert oct-alert-error">
$!  !$<div class="head">$headline$</div>
$!  !$<div class="text">$text$</div>
</div>
>>
