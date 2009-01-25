<cfcomponent>

<!--- These are reserved form control arguments that will not be treated as HTML attributes --->
<cfparam name="variables.reserved_arguments" default="" />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "field") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "label") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "required") />

<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "query") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "value_field") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "display_field") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "jump_to") />

<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "position") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "empty_value") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "expandable") />

<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "values") />
<cfset variables.reserved_arguments = ListAppend(variables.reserved_arguments, "options") />
		
<!------------------------------------------------------------------------------------------ preamble

	Description:	This function is called at the beginning of every form control.
	
	Arguments:		The argument collection passed to the form control
				
	Return Value:	A structure containing attributes to be added to the HTML tag
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="preamble">	
		<!--- Display the label for the form field --->	
		<cfinvoke method="displayLabel" argumentcollection="#Arguments#" />
		
		<!--- Create an attributes object to store the HTML attributes for the form contol --->
		<cfobject name="attributes" component="egd_billing.cfc.attributes" />
		
		<!--- Initialize the attributes with the passed-in arguments excluding the reserved ones --->
		<cfset attributes.init(
			argumentcollection = Arguments, 
			reserved_arguments = variables.reserved_arguments) />
			
		<!--- Add some default attributes if they aren't provided as arguments --->
		<cfset attributes.set("id", arguments.field) /> <!--- ID MUST be the field name --->
		<cfset attributes.add("name", arguments.field) />
		<cfset attributes.add("onfocus", "this.setAttribute('class', this.type+' focused')") />
		<cfset attributes.add("onblur", "this.setAttribute('class', this.type)") />
		
		<cfif StructKeyExists(request.model_errors, arguments.field)>
			<cfset attributes.add("class", "text invalid_field") />
		<cfelse>
			<cfset attributes.add("class", "text") />
		</cfif>
		
		<cfreturn attributes />
	</cffunction>

<!---------------------------------------------------------------------------------------- postamble

	Description:	This function gets called at the end of every form control to output the help
								icon/message and the error message if there is one.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="postamble">
		<cfif arguments.label EQ "">
			<cfset arguments.position = "none">
		</cfif>	

		<cfinvoke method="displayHelp" argumentcollection="#Arguments#" />
		<cfif IsDefined("arguments.addtype") AND arguments.addtype NEQ "">
			<cfinvoke method="displayAddTYpe" argumentcollection="#Arguments#" />
		</cfif>
		<!--- Display the validation errors for this form field --->
		<cfinvoke method="displayError" argumentcollection="#Arguments#" />
		<br />
	</cffunction>
	
<!---------------------------------------------------------------------------------------- displayAddType

	Description:	Outputs a + icon which, when clicked, opens the add data_types page for a specified data type
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="displayAddType" access="public" output="true">
		<cfargument name="addtype" type="string" required="yes" />
		
		<cfinvoke component="egd_billing.app.type_categories.typecategory"
					method="select"
					conditions="name = '#addtype#'"
					returnvariable="type" />
		<cfset link = "#request.path#app/types/create_popup.cfm?category_id=#type.id#" />
		<img src="#request.path#images/plus.gif" alt="" onclick="window.open('#link#','_blank','height=160,width=330,toolbar=no,scrollbars=no,resizable=no');" />
		

	</cffunction>
<!---------------------------------------------------------------------------------------- displayHelp

	Description:	Outputs a question mark icon which, when clicked, displays a help message for the
								given form field.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="displayHelp" access="public" output="true">
		<cfargument name="field" type="string" required="yes" />
		<cfargument name="position" type="string" default="side">
		<cfif IsDefined("request.data_object")>
			<cfset message = request.data_object.help(field) />
		<cfelse>
			<cfset message = "">
		</cfif>
		
		<img src="#request.path#images/question.gif" id="help_img_#arguments.field#" class="helpIcon" alt="" onclick="showhide('#arguments.field#');" />

		<div class="help" id="help_msg_#arguments.field#" <cfif position EQ "side">style="margin-left:95px;"</cfif>> #message# </div>

		<CFIF FindNoCase("Netscape", CGI.HTTP_USER_AGENT)><div style="clear:both;"></div></CFIF>
		

	</cffunction>
	
<!--------------------------------------------------------------------------------------- displayLabel

	Description:	Every form field has a corresponding <label> tag with the English description of the
								field.
			
----------------------------------------------------------------------------------------------------->
	
<cffunction name="displayLabel" output="true">
	<cfargument name="field" required="yes" />
	<cfargument name="label" default="#arguments.field#" />
	<cfargument name="required" default="true" />
	<cfargument name="position" default="side" />
	<cfargument name="accesskey" default="" />
	
	<cfoutput>
		<cfif label NEQ "">
			<label for="#field#" <cfif position EQ "top">style="margin-bottom: 0;"<cfelseif position EQ "textfield">style="margin-bottom: 25pt;"</cfif>>
				<cfif required>
					<span class="reqField">*</span>&nbsp;
				</cfif>
				<cfinvoke method="displayHotkey"  label="#label#" accesskey="#accesskey#"  returnvariable="newlabel">
				#newlabel#:&nbsp;
				
			</label>
			<cfif position EQ "top"><br/></cfif>
		</cfif>
	</cfoutput>
</cffunction>

<!-------------------------------------------------------------------------------------- displayHotkey

	Description:	Takes in a label and if the form field has an associated access key letter then it 
								underlines all occurences of that letter in the label.								
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="displayHotkey">
		<cfargument name="label" required="yes" />
		<cfargument name="accesskey" required="yes" />

		<cfif accesskey NEQ "">
			<cfset keyPos = FindNoCase(accesskey, label)>
			<cfset label = Insert("</em>", label, keyPos)>
			<cfset label = Insert('<em class="hotkey">', label, keyPos-1)>
		</cfif>
		
		<cfreturn label>
	</cffunction>

<!--------------------------------------------------------------------------------------- displayError

	Description: Outputs an error for a given field of a model.
	
	Arguments: The model field of interest
				
	Description: 
				The error will be set in the Request variable only if it is meant to be displayed.  
				This function checks for the existence of the error and if it exists it gets wrapped in a 
				span with the appropriate display class and gets output.
				
	Return Value: None
			
----------------------------------------------------------------------------------------------------->
	<cffunction name="displayError" access="public" output="true">
		<cfargument name="field" type="string" required="yes" />
		<cfargument name="position" type="string" default="side">

		<cfoutput>
			<cfif StructKeyExists(request.model_errors, arguments.field)>
				<div id="error_#field#" class="error" <cfif position EQ "side">style="margin-left:95px;"</cfif>>#Evaluate("request.model_errors.#arguments.field#")#</div>
			<cfelse>
				<div id="error_#field#" class="error" style="<cfif position EQ "side">margin-left:95px;</cfif>display:none;"></div>
			</cfif>
		</cfoutput>
	</cffunction>

<!----------------------------------------------------------------------------------------- textfield

	Description:	Output a dynamic <input> field
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textfield" access="public" output="true">
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		
		<cfset variables.value = "" />
		<cfif isDefined("request.data_object.#arguments.field#")>
			<cfset variables.value = Evaluate('request.data_object.#arguments.field#') />
		</cfif>
		
		<cfset attributes.set("value", variables.value) />
		<cfset attributes.add("type", "text") />
		<cfset attributes.set("autocomplete", "off") />
		<cfif IsDefined("request.data_object.field_lengths") AND
			  StructKeyExists(request.data_object.field_lengths, arguments.field)>
			<cfset attributes.set("maxlength", StructFind(request.data_object.field_lengths, arguments.field)) />
		</cfif>
		<input #attributes.string()# />
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>
	
<!-------------------------------------------------------------------------------------- decimalfield

	Description:	Outputs a dynamic <input> field with the value formatted to two decimal places.
								Typically used for displaying money values.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="decimalfield" access="public" output="true">
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		
		<cfset variables.value = "" />
		<cfif isDefined("request.data_object.#arguments.field#") AND isNumeric(Evaluate('request.data_object.#arguments.field#'))>
			<cfset variables.value = NumberFormat(Evaluate('request.data_object.#arguments.field#'), ".99") />
		</cfif>
		
		<cfset attributes.set("value", variables.value) />
		<cfset attributes.set("type", "text") />		
		<cfset attributes.set("autocomplete", "off") />
		<cfif StructKeyExists(request.data_object.field_lengths, arguments.field)>
			<cfset attributes.set("maxlength", StructFind(request.data_object.field_lengths, arguments.field)) />
		</cfif>
		
		<input #attributes.string()# />
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- datefield

	Description:	Outputs three <input> fields for month, day, and year.  Also creates a hidden field 
								that contains the combined date value.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="datefield" access="public" output="true">
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		
		<cfset field = attributes.get('id') />
		
		<cfset variables.value = "" />
		<cfset variables.value_dd = "" />
		<cfset variables.value_mm = "" />
		<cfset variables.value_yyyy = "" />
		<cfif isDefined("request.data_object.#arguments.field#")> 
			<cfif isDate(Evaluate('request.data_object.#arguments.field#'))>
				<cfset variables.value = DateFormat(ParseDateTime(Evaluate('request.data_object.#arguments.field#')), "yyyy-mm-dd") />
				<cfset variables.value_dd = DateFormat(variables.value,'dd') />
				<cfset variables.value_mm = DateFormat(variables.value,'mm') />
				<cfset variables.value_yyyy = DateFormat(variables.value,'yyyy') />
			<cfelse>
				<cfset variables.value = Evaluate('request.data_object.#arguments.field#') />
				<cfset variables.value_dd = Evaluate('request.data_object.#arguments.field#_dd') />
				<cfset variables.value_mm = Evaluate('request.data_object.#arguments.field#_mm') />
				<cfset variables.value_yyyy = Evaluate('request.data_object.#arguments.field#_yyyy') />
			</cfif>
		</cfif>
			
		<!--- Popup calendar --->
		<a href="###field#Cal" 
			id="#field#Anchor" 
			onfocus="createCal(
				'#field#',
				'#field#Anchor',
				'#arguments.label#')" >
			
			<img src="#request.path#images/calendar.gif" alt="calendar" />
			
		</a>
		<!--- Hidden Date field --->
		<cfset attributes.set("value", "#variables.value#") />
		<cfset attributes.set("type", "hidden") />
		<input #attributes.string()# />
		
		<!--- Common attributes for the month, day, and year fields --->
		<cfif StructKeyExists(request.model_errors, arguments.field)>
			<cfset attributes.set("class", "date invalid_field") />
		<cfelse>
			<cfset attributes.set("class", "date") />
		</cfif>
		<cfset attributes.set("type", "text") />	
		<cfset attributes.set("autocomplete", "off") />
		<cfset attributes.set("onchange", "updateDate('#field#');" & attributes.get("onchange")) />
		<cfset attributes.set("onkeypress", "jfKeyCounter('down');" & attributes.get("onkeypress")) />
		<cfset attributes.set("onfocus", "jfKeyCounter('clear');this.setAttribute('class','date focused');") />
		<cfset attributes.set("onblur", "this.setAttribute('class','date');") />

		<!--- Day field --->
		<cfset attributes.set("value", variables.value_dd) />
		<cfset attributes.set("id", "#field#_dd") />
		<cfset attributes.set("name", "#field#_dd") />	
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_dd','#field#_mm',2);") />	
		<input #attributes.string()# />
		
		<!--- Month field  --->
		<cfset attributes.set("value", variables.value_mm) />
		<cfset attributes.set("id", "#field#_mm") />
		<cfset attributes.set("name", "#field#_mm") />
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','#field#_yyyy',2);") />	
		<input #attributes.string()# />
		
		
		<!--- Year field --->
		<cfset attributes.set("value", variables.value_yyyy) />
		<cfset attributes.set("id", "#field#_yyyy") />
		<cfset attributes.set("name", "#field#_yyyy") />
		<cfif IsDefined("arguments.jump_to") AND NOT arguments.jump_to EQ "">
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_yyyy','#arguments.jump_to#',4);") />	
		<cfelse>
			<cfset attributes.set("onkeyup", "jumpField(event, 'no','#field#_yyyy','none',4);") />	
		</cfif>
		<input #attributes.string()# />

		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- timefield

	Description:	Outputs separate <input> fields for hour and minute as well as a hidden field with the
								combined value.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="timefield" access="public" output="true">
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		
		<cfset field = attributes.get('id') />

		<cfset variables.value = "" />
		<cfset variables.value_hh = "" />
		<cfset variables.value_mm = "" />
		
		<cfif isDefined("request.data_object.#arguments.field#")>
			<cfif isDate(Evaluate('request.data_object.#arguments.field#'))>
				<cfset variables.value = EGDTimeFormat(ParseDateTime(Evaluate('request.data_object.#arguments.field#')), 'HH:mm') />
				<cfset variables.value_hh = EGDTimeFormat(variables.value, 'HH') />
				<cfset variables.value_mm = EGDTimeFormat(variables.value, 'mm') />
			<cfelse>
				<cfset variables.value = Evaluate("request.data_object.#arguments.field#") />
				<cfset variables.value_hh = Evaluate("request.data_object.#arguments.field#_hh") />
				<cfset variables.value_mm = Evaluate("request.data_object.#arguments.field#_mm") />
			</cfif>
		</cfif>
		
		<span class="time_fields">
		<!--- Hidden Time field --->
		<cfset attributes.set("value", variables.value) />
		<cfset attributes.set("type", "hidden") />
		<input #attributes.string()# />
		
		<!--- Common attributes for Hour and Minute fields --->
		<cfset attributes.set("type", "text") />
		<cfset attributes.set("maxlength", 2) />
		<cfif StructKeyExists(request.model_errors, arguments.field)>
			<cfset attributes.set("class", "time invalid_field") />
		<cfelse>
			<cfset attributes.set("class", "time") />
		</cfif>
		<cfset attributes.set("autocomplete", "off") />
		<cfset attributes.set("onkeypress", "jfKeyCounter();" & attributes.get("onkeypress")) />
		<cfset attributes.set("onfocus", "jfKeyCounter('clear');this.setAttribute('class','time focused');") />
		<cfset attributes.set("onblur", "this.setAttribute('class','time');") />

		<!--- Hour field --->
		<cfset attributes.set("value", variables.value_hh) />
		<cfset attributes.set("id", "#field#_hh") />
		<cfset attributes.set("name", "#field#_hh") />	
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_hh','#field#_mm',2)") />	
		<input #attributes.string()# />		
		
		<!--- The colon separator --->
		:	
		
		<!--- Minute field --->
		<cfset attributes.set("value", variables.value_mm) />
		<cfset attributes.set("id", "#field#_mm") />
		<cfset attributes.set("name", "#field#_mm") />	
		<cfif IsDefined("arguments.jump_to") AND NOT arguments.jump_to EQ "">
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','#arguments.jump_to#',2)") />	
		<cfelse>
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','none',2)") />
		</cfif>
		<input #attributes.string()# />
		</span>
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

	
<!-------------------------------------------------------------------------------------- selectfield

	Description:	Outputs a <select> tag with options provided by the query argument.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="selectfield" access="public" output="true">
		<cfargument name="query" required="yes" />
		<cfargument name="value_field" default="#arguments.field#" />
		<cfargument name="display_field" default="#arguments.field#" />
		<cfargument name="multiple" default="false" />
		<cfargument name="empty_value" default="Select One" />
		<cfargument name="expandable" default="yes" />
		
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		<cfset multiple_size = '' />
		<cfif arguments.multiple eq 'false'>
			<cfset is_multiple = "" />
		<cfelse>
			<cfset is_multiple = "Multiple" />
			<cfset attributes.add("size", "10") />
			<cfset attributes.set("style",attributes.get("style")&"margin-bottom: 10px;") />
		</cfif>
		<cfset max_width=0>
		<cfloop query="query">
			<cfset max_width = Max(len(Evaluate("query.#display_field#")), max_width)>
		</cfloop>
		<cfif max_width GT 26 and expandable neq "no"> 
			<!---<cfif max_width GT 37 AND expandable eq "no">
				<cfset attributes.set("style",attributes.get("style")&"width:250px;") />--->
			<!---<cfif max_width GT 33 AND expandable eq "no">
				<cfset attributes.set("style",attributes.get("style")&"width:227px;") />
			<cfelse>--->
				<cfset attributes.set("style",attributes.get("style")&"width:auto;") />
			<!---</cfif>--->
		</cfif>
<!---		<cfif max_width GT 26  AND expandable eq "yes"> 
			<cfset attributes.set("style",attributes.get("style")&"width:auto;") />
		</cfif>   --->
		
		<select #is_multiple# #attributes.string()# >
			<option value="">#arguments.empty_value#</option>
			<cfloop query="query">
				<option value="#Evaluate('query.#value_field#')#" <cfif IsDefined("request.data_object") AND ListFindNoCase(Evaluate('request.data_object.#arguments.field#'),Evaluate('query.#value_field#'))>selected="selected"</cfif>>
					#HTMLEditFormat(Evaluate("query.#display_field#"))#
				</option>
			</cfloop>
		</select>
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- textarea

	Description:	Outputs a dynamic <textarea>
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textarea" access="public" output="true">
	
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
				
		<cfset variables.value = "" />
		<cfif isDefined("request.data_object.#arguments.field#")>
			<cfset variables.value = Evaluate('request.data_object.#arguments.field#') />
		</cfif>
		
		<!---<cfset attributes.add("rows", 5) />
		<cfset attributes.add("cols", 26) />--->
		<cfif StructKeyExists(request.data_object.field_lengths, arguments.field)>
			<cfset attributes.set("maxlength", StructFind(request.data_object.field_lengths, arguments.field)) />
		</cfif>
	
		<textarea #attributes.string()#>#variables.value#</textarea>
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

<!--------------------------------------------------------------------------------------- radiobutton

	Description:	Outputs dynamic <input type="radio"> buttons based on the given query argument.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="radiobutton" access="public" output="true">
		<cfargument name="values" required="yes" />
		<cfargument name="options" required="yes" />
		<cfargument name="field" required="yes" />
   		<cfargument name="label" default="#arguments.field#" />
    	<cfargument name="required" default="true" />


	<cfset option_index = 1 />
	
	<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
	<cfset attributes.set("type", "radio")>
	<cfif StructKeyExists(request.model_errors, arguments.field)>
		<cfset attributes.add("class", "radio invalid_field") />
	<cfelse>
		<cfset attributes.set("class", "radio")>
	</cfif>
	
	<div class="input">
	<cfloop list="#arguments.values#" index="value">
	  <cfset option = ListGetAt(arguments.options,option_index) />
	  <cfset option_no_space = Replace(option, ' ', '', 'ALL') />
	  	<cfset attributes.set("id", "#field#_#option_no_space#")>
	  	<cfset attributes.set("value", value)>
	    <label for="#field#_#option_no_space#" class="radio">#option#</label>
		<input #attributes.string()# <cfif Evaluate('request.data_object.#field#') eq value>checked="checked"</cfif>  />
		
	  <cfset option_index = option_index+1 />
	</cfloop>
	</div>
	<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

<!--------------------------------------------------------------------------------------- checkbox

	Description:	Outputs a single dynamic <input type="checkbox"> buttons based on the given query argument.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="checkbox" access="public" output="true">
		<cfargument name="field" required="yes" />
    	<cfargument name="label" default="#arguments.field#" />
    	<cfargument name="required" default="false" />


		<cfinvoke method="preamble" argumentcollection="#Arguments#" />

		<cfif isDefined("request.data_object.#arguments.field#") AND (Evaluate('request.data_object.#arguments.field#') OR Evaluate('request.data_object.#arguments.field#') EQ 1) >
			<cfset attributes.set("checked", "checked") />
			<cfset attributes.set("value", 1) />
		<cfelse>
			<cfset attributes.set("value", 1) />
		</cfif>

		<cfset attributes.set("type", "checkbox") />
		<cfif StructKeyExists(request.model_errors, arguments.field)>
			<cfset attributes.set("class", "checkbox invalid_field") />
		<cfelse>
			<cfset attributes.set("class", "checkbox") />
		</cfif>

		<input #attributes.string()# />
			
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>
	
<!--------------------------------------------------------------------------------------- checkbox_group

	Description:	Outputs a group of dynamic <input type="checkbox"> buttons based on the given query argument.
	Arguments: 		Field is a dummy value for the preamble, etc to use. values is the list of fields. label is the label for the group, Options are the labels 
					for the individual boxes
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="checkbox_group" access="public" output="true">
		<cfargument name="values" required="yes">
		<cfargument name="field" default="#ListFirst(arguments.values)#" />
    	<cfargument name="label" required="yes" />
		<cfargument name="options" required="yes" />
    	<cfargument name="required" default="false" />

		
		<cfinvoke method="preamble" argumentcollection="#Arguments#" />

		<cfset attributes.set("type", "checkbox") />
		<cfif StructKeyExists(request.model_errors, arguments.field)>
			<cfset attributes.set("class", "checkbox error") />
		<cfelse>
			<cfset attributes.set("class", "checkbox") />
		</cfif>

		<cfset option_index = 1 />
		<div class="input">

		<cfloop list="#arguments.values#" index="value">
			<cfset option = ListGetAt(arguments.options,option_index) />
			<cfset option_no_space = Replace(option, ' ', '', 'ALL') />
			<cfif isDefined("request.data_object.#value#") AND (Evaluate('request.data_object.#value#') OR Evaluate('request.data_object.#value#') EQ 1) >
				<cfset attributes.set("checked", "checked") />
				<cfset attributes.set("value", 1) />
			<cfelse>
				<cfset attributes.remove("checked") />
				<cfset attributes.set("value", 1) />
			</cfif>
			<cfset attributes.set("id", "#value#")>
			<cfset attributes.set("name", "#value#")>
			<label for="#value#" class="radio">#option#</label>
			<input #attributes.string()# />
	  		<cfset option_index = option_index+1 />
		</cfloop>
		</div>
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

</cfcomponent>
