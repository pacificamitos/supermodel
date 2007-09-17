<cfcomponent>

<!---------------------------------------------------------------------------------------------- init

	Description:	Initializes the form controls object with a data object and sets up all the reserved
								arguments.
	
	Arguments:		data_object - Some component whose fields are used to populate the form values.
								This is typically an instantiated model object that inherits from the SuperModel
								class.
			
----------------------------------------------------------------------------------------------------->

<cffunction name="init" access="public" output="true">
	<cfargument name="component" type="string" required="true" />
	<cfargument name="event" type="MachII.framework.Event" required="true" />
		
	<!--- Setup the data_object --->
	<cfset variables.data_object = createObject('component', arguments.component) />
	<cfset variables.data_object.load(arguments.event.getArgs()) />
	<cfset variables.data_object.valid() />
	
	
	<cfif event.getArg('display_errors') EQ true>
		<cfset variables.display_errors = true />
	<cfelse>
		<cfset variables.display_errors = false />
	</cfif>
	
	<!--- Includes scripts and styles --->
	<cfoutput>
	<link rel="stylesheet" href="/supermodel/css/styles.css">
	<link rel="stylesheet" href="/supermodel/css/calendar.css">
	<script src="/supermodel/scripts/common.js"></script>
	<script src="/supermodel/scripts/supermodel.js"></script>
	<script src="/supermodel/scripts/window.js"></script>
	<script src="/supermodel/scripts/calendar.js"></script>
	</cfoutput>
			
	<!--- These are reserved form control arguments that will not be treated as HTML attributes --->
	<cfset Variables.reserved_arguments = "" />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "field") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "label") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "required") />
	
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "query") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "value_field") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "display_field") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "jump_to") />
	
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "position") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "empty_value") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "expandable") />
	
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "values") />
	<cfset Variables.reserved_arguments = ListAppend(Variables.reserved_arguments, "options") />
</cffunction>

<!-------------------------------------------------------------------------------------- setDataObject

	Description:	Sets the internal data_object to the passed in data_object.
	
	Arguments:		data_object - Some component whose fields are used to populate the form values.
								This is typically an instantiated model object that inherits from the SuperModel
								class.
			
----------------------------------------------------------------------------------------------------->

<cffunction name="setDataObject" access="public" output="false">
	<cfargument name="data_object" required="yes" />
	
	<cfset variables.data_object = arguments.data_object />
</cffunction>

<!------------------------------------------------------------------------------------------ preamble

	Description:	This function is called at the beginning of every form control.
	
	Arguments:		The argument collection passed to the form control
				
	Return Value:	A structure containing attributes to be added to the HTML tag
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="preamble">	
		<!--- Make sure we have a data_object first --->
		<cfif NOT IsDefined("variables.data_object")>
			<cfthrow message="Form Controls data_object not set properly." />
		</cfif>
		
		<!--- Display the label for the form field --->	
		<cfinvoke method="displayLabel" argumentcollection="#Arguments#" />
		
		<!--- Create an attributes object to store the HTML attributes for the form contol --->
		<cfobject name="attributes" component="supermodel.attributes" />
		
		<!--- Initialize the attributes with the passed-in arguments excluding the reserved ones --->
		<cfset attributes.init(
			argumentcollection = Arguments, 
			reserved_arguments = Variables.reserved_arguments) />
			
		<!--- Add some default attributes if they aren't provided as arguments --->
		<cfset attributes.set("id", Arguments.field) /> <!--- ID MUST be the field name --->
		<cfset attributes.add("name", Arguments.field) />
		
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
		<cfif IsDefined("Arguments.addtype") AND Arguments.addtype NEQ "">
			<cfinvoke method="displayAddType" argumentcollection="#Arguments#" />
		</cfif>
		<!--- Display the validation errors for this form field --->
		<cfinvoke method="displayError" argumentcollection="#Arguments#" />
		<br />
	</cffunction>
	
<!---------------------------------------------------------------------------------------- displayHelp

	Description:	Outputs a question mark icon which, when clicked, displays a help message for the
								given form field.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="displayHelp" access="public" output="true">
		<cfargument name="field" type="string" required="yes" />
		<cfargument name="position" type="string" default="side">
		<cfif IsDefined("variables.data_object")>
			<cfset message = variables.data_object.help(field) />
		<cfelse>
			<cfset message = "">
		</cfif>
		
		<img src="/SuperModel/images/question.gif" id="help_img_#Arguments.field#" class="helpIcon" alt="" onclick="showhide('#Arguments.field#');" />

		<div class="help" id="help_msg_#Arguments.field#" <cfif position EQ "side">style="margin-left:95px;"</cfif>> #message# </div>

		<CFIF FindNoCase("Netscape", CGI.HTTP_USER_AGENT)><div style="clear:both;"></div></CFIF>
		

	</cffunction>
	
<!--------------------------------------------------------------------------------------- displayLabel

	Description:	Every form field has a corresponding <label> tag with the English description of the
								field.
			
----------------------------------------------------------------------------------------------------->
	
<cffunction name="displayLabel" output="true">
	<cfargument name="field" required="yes" />
	<cfargument name="label" default="#Arguments.field#" />
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
				#newlabel#:
				
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
		
		<cfset var error_msg = "" />
		<cfset var errors_struct = variables.data_object.getErrors() />
		<cfset var hide_div = false />
		
		<cfif variables.display_errors EQ true>
			<cftry>
				<cfset error_msg = Evaluate("errors_struct.#Arguments.field#") />
				
				<cfcatch type="any">
					<cfset hide_div = true />
				</cfcatch>
			</cftry>

			<cfoutput>
				<div id="error_#field#" class="error" <cfif hide_div>style="display: none"</cfif>>#error_msg#</div>
			</cfoutput>
		</cfif>
	</cffunction>

<!----------------------------------------------------------------------------------------- textfield

	Description:	Output a dynamic <input> field
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textfield" access="public" output="true">
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		
		<cfset Variables.value = "" />
		<cfif isDefined("variables.data_object.#Arguments.field#")>
			<cfset Variables.value = Evaluate('variables.data_object.#Arguments.field#') />
		</cfif>
		
		<cfset attributes.set("value", Variables.value) />
		<cfset attributes.add("type", "text") />
		<cfset attributes.set("autocomplete", "off") />
		<cfif IsDefined("variables.data_object.field_lengths") AND
			  StructKeyExists(variables.data_object.field_lengths, Arguments.field)>
			<cfset attributes.set("maxlength", StructFind(variables.data_object.field_lengths, Arguments.field)) />
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
		
		<cfset Variables.value = "" />
		<cfif isDefined("variables.data_object.#Arguments.field#") AND isNumeric(Evaluate('variables.data_object.#Arguments.field#'))>
			<cfset Variables.value = NumberFormat(Evaluate('variables.data_object.#Arguments.field#'), ".99") />
		</cfif>
		
		<cfset attributes.set("value", Variables.value) />
		<cfset attributes.set("type", "text") />		
		<cfset attributes.set("autocomplete", "off") />
		<cfif StructKeyExists(variables.data_object.field_lengths, Arguments.field)>
			<cfset attributes.set("maxlength", StructFind(variables.data_object.field_lengths, Arguments.field)) />
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
		
		<cfset Variables.value = "" />
		<cfset Variables.value_dd = "" />
		<cfset Variables.value_mm = "" />
		<cfset Variables.value_yyyy = "" />
		<cfif isDefined("variables.data_object.#Arguments.field#")> 
			<cfif isDate(Evaluate('variables.data_object.#Arguments.field#'))>
				<cfset Variables.value = DateFormat(ParseDateTime(Evaluate('variables.data_object.#Arguments.field#')), "yyyy-mm-dd") />
				<cfset Variables.value_dd = DateFormat(Variables.value,'dd') />
				<cfset Variables.value_mm = DateFormat(Variables.value,'mm') />
				<cfset Variables.value_yyyy = DateFormat(Variables.value,'yyyy') />
			</cfif>
		</cfif>
			
		<!--- Popup calendar --->
		<a href="###field#Cal" 
			id="#field#Anchor" 
			onfocus="createCal(
				'#field#',
				'#field#Anchor',
				'#Arguments.label#')" >
			
			<img src="/supermodel/images/calendar.gif" alt="calendar" />
			
		</a>
		<!--- Hidden Date field --->
		<cfset attributes.set("value", "#Variables.value#") />
		<cfset attributes.set("type", "hidden") />
		<input #attributes.string()# />
		
		<!--- Common attributes for the month, day, and year fields --->
		<cfset attributes.set("class", "date") />
		<cfset attributes.set("type", "text") />	
		<cfset attributes.set("autocomplete", "off") />
		<cfset attributes.set("onchange", "updateDate('#field#');" & attributes.get("onchange")) />
		<cfset attributes.set("onkeypress", "jfKeyCounter('down')") />
		<cfset attributes.set("onfocus", "jfKeyCounter('clear')") />

		<!--- Day field --->
		<cfset attributes.set("value", Variables.value_dd) />
		<cfset attributes.set("id", "#field#_dd") />
		<cfset attributes.set("name", "#field#_dd") />	
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_dd','#field#_mm',2);") />	
		<input #attributes.string()# />
		
		<!--- Month field  --->
		<cfset attributes.set("value", Variables.value_mm) />
		<cfset attributes.set("id", "#field#_mm") />
		<cfset attributes.set("name", "#field#_mm") />
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','#field#_yyyy',2)") />	
		<input #attributes.string()# />
		
		
		<!--- Year field --->
		<cfset attributes.set("value", Variables.value_yyyy) />
		<cfset attributes.set("id", "#field#_yyyy") />
		<cfset attributes.set("name", "#field#_yyyy") />
		<!---<cfif IsDefined("Arguments.jump_to") AND NOT Arguments.jump_to EQ "">
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_yyyy','#Arguments.jump_to#',4)") />	
		<cfelse>--->
			<cfset attributes.set("onkeyup", "jumpField(event, 'no','#field#_yyyy','none',4)") />	
		<!---</cfif>--->
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

		<cfset Variables.value = "" />
		<cfset Variables.value_hh = "" />
		<cfset Variables.value_mm = "" />
		
		<cfif isDefined("variables.data_object.#Arguments.field#")>
			<cfif isDate(Evaluate('variables.data_object.#Arguments.field#'))>
				<cfset Variables.value = TimeFormat(ParseDateTime(Evaluate('variables.data_object.#Arguments.field#')), 'HH:mm') />
				<cfset Variables.value_hh = TimeFormat(Variables.value, 'HH') />
				<cfset Variables.value_mm = TimeFormat(Variables.value, 'mm') />
			<cfelse>
				<cfset Variables.value = Evaluate("variables.data_object.#Arguments.field#") />
				<cfset Variables.value_hh = Evaluate("variables.data_object.#Arguments.field#_hh") />
				<cfset Variables.value_mm = Evaluate("variables.data_object.#Arguments.field#_mm") />
			</cfif>
		</cfif>
		
		
		
		<!--- Hidden Time field --->
		<cfset attributes.set("value", Variables.value) />
		<cfset attributes.set("type", "hidden") />
		<input #attributes.string()# />
		
		<!--- Common attributes for Hour and Minute fields --->
		<cfset attributes.set("type", "text") />
		<cfset attributes.set("maxlength", 2) />
		<cfset attributes.set("class", "time") />
		<cfset attributes.set("autocomplete", "off") />
		<cfset attributes.set("onchange", "updateTime('#field#');" & attributes.get("onchange")) />
		<cfset attributes.set("onkeypress", "jfKeyCounter()") />

		<!--- Hour field --->
		<cfset attributes.set("value", Variables.value_hh) />
		<cfset attributes.set("id", "#field#_hh") />
		<cfset attributes.set("name", "#field#_hh") />	
		<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_hh','#field#_mm',2)") />	
		<input #attributes.string()# />		
		
		<!--- The colon separator --->
		:	
		
		<!--- Minute field --->
		<cfset attributes.set("value", Variables.value_mm) />
		<cfset attributes.set("id", "#field#_mm") />
		<cfset attributes.set("name", "#field#_mm") />	
		<!---<cfif IsDefined("Arguments.jump_to") AND NOT Arguments.jump_to EQ "">
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','#Arguments.jump_to#',2)") />	
		<cfelse>--->
			<cfset attributes.set("onkeyup", "jumpField(event, 'yes','#field#_mm','none',2)") />
		<!---</cfif>--->	
		<input #attributes.string()# />
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

	
<!-------------------------------------------------------------------------------------- selectfield

	Description:	Outputs a <select> tag with options provided by the query argument.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="selectfield" access="public" output="true">
		<cfargument name="query" required="yes" />
		<cfargument name="value_field" default="#Arguments.field#" />
		<cfargument name="display_field" default="#Arguments.field#" />
		<cfargument name="multiple" default="false" />
		<cfargument name="empty_value" default="Select One" />
		<cfargument name="expandable" default="yes" />
		
		<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
		<cfset multiple_size = '' />
		<cfif Arguments.multiple eq 'false'>
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
			<option value="">#Arguments.empty_value#</option>
			<cfloop query="query">
				<option value="#Evaluate('query.#value_field#')#" <cfif IsDefined("variables.data_object") AND ListFindNoCase(Evaluate('variables.data_object.#Arguments.field#'),Evaluate('query.#value_field#'))>selected="selected"</cfif>>
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
				
		<cfset Variables.value = "" />
		<cfif isDefined("variables.data_object.#Arguments.field#")>
			<cfset Variables.value = Evaluate('variables.data_object.#Arguments.field#') />
		</cfif>
		
		<!---<cfset attributes.add("rows", 5) />
		<cfset attributes.add("cols", 26) />--->
		<cfif StructKeyExists(variables.data_object.field_lengths, Arguments.field)>
			<cfset attributes.set("maxlength", StructFind(variables.data_object.field_lengths, Arguments.field)) />
		</cfif>
	
		<textarea #attributes.string()#>#Variables.value#</textarea>
		
		<cfinvoke method="postamble" argumentcollection="#Arguments#" />
	</cffunction>

<!--------------------------------------------------------------------------------------- radiobutton

	Description:	Outputs dynamic <input type="radio"> buttons based on the given query argument.
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="radiobutton" access="public" output="true">
		<cfargument name="values" required="yes" />
		<cfargument name="options" required="yes" />
		<cfargument name="field" required="yes" />
   		<cfargument name="label" default="#Arguments.field#" />
    	<cfargument name="required" default="true" />


	<cfset option_index = 1 />
	
	<!---<span class="radio_label">#label#</span>--->
	<cfinvoke method="preamble" argumentcollection="#Arguments#" returnvariable="attributes" />
	<cfset attributes.set("type", "radio")>
	<cfset attributes.set("class", "radio")>
	
	<div class="input">
	<cfloop list="#Arguments.values#" index="value">
	  <cfset option = ListGetAt(Arguments.options,option_index) />
	  <cfset option_no_space = REReplace(option, "\s", "") />
	  <!---<div class="indent_form" style="float:left; widows:100px;">--->
	  	<cfset attributes.set("id", "#field#_#option_no_space#")>
	  	<cfset attributes.set("value", value)>
	    <label for="#field#_#option_no_space#" class="radio">#option#</label>
		<input #attributes.string()# <cfif Evaluate('variables.data_object.#field#') eq value>checked="checked"</cfif>  />
		
	  <!---</div>--->
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
    	<cfargument name="label" default="#Arguments.field#" />
    	<cfargument name="required" default="false" />


		<cfinvoke method="preamble" argumentcollection="#Arguments#" />

		<cfif isDefined("variables.data_object.#Arguments.field#") AND (Evaluate('variables.data_object.#Arguments.field#') OR Evaluate('variables.data_object.#Arguments.field#') EQ 1) >
			<cfset attributes.set("checked", "checked") />
			<cfset attributes.set("value", 1) />
		<cfelse>
			<cfset attributes.set("value", 1) />
		</cfif>

		<cfset attributes.set("type", "checkbox") />
		<cfset attributes.set("class", "checkbox") />

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
		<cfset attributes.set("class", "checkbox") />

		<cfset option_index = 1 />
		<div class="input">

		<cfloop list="#Arguments.values#" index="value">
			<cfset option = ListGetAt(Arguments.options,option_index) />
			<cfset option_no_space = REReplace(option, "\s", "") />
			<cfif isDefined("variables.data_object.#value#") AND (Evaluate('variables.data_object.#value#') OR Evaluate('variables.data_object.#value#') EQ 1) >
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
