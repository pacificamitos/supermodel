<cfcomponent>
  <!--- These are reserved form control arguments that will not be treated as HTML attributes --->
  <cfset variables.reserved_arguments = "field,label,required,values,options" />

<!------------------------------------------------------------------------------------------ before

	Description:	This function is called at the beginning of every form control.
	
	arguments:		The argument collection passed to the form control
				
	Return Value:	A structure containing attributes to be added to the HTML tag
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="before">	
		<!--- Display the label for the form field --->	
		<cfinvoke method="label" argumentcollection="#arguments#" />
		
		<!--- Create an attributes object to store the HTML attributes for the form contol --->
		<cfobject name="attributes" component="supermodel.attributes" />
		
		<!--- Initialize the attributes with the passed-in arguments excluding the reserved ones --->
		<cfset attributes.init(
			argumentcollection = arguments, 
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

<!---------------------------------------------------------------------------------------- after

	Description:	This function gets called at the end of every form control to output the help
								icon/message and the error message if there is one.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="after">
		<cfinvoke method="error" argumentcollection="#arguments#" />
		<br />
	</cffunction>
	
<!--------------------------------------------------------------------------------------- label

	Description:	Every form field has a corresponding <label> tag with the English description of the
								field.
			
----------------------------------------------------------------------------------------------------->
	
<cffunction name="label" output="true">
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
				<cfinvoke method="hotkey"  label="#label#" accesskey="#accesskey#"  returnvariable="newlabel">
				#newlabel#:&nbsp;
				
			</label>
			<cfif position EQ "top"><br/></cfif>
		</cfif>
	</cfoutput>
</cffunction>

<!-------------------------------------------------------------------------------------- hotkey

	Description:	Takes in a label and if the form field has an associated access key letter then it 
								underlines all occurences of that letter in the label.								
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="hotkey">
		<cfargument name="label" required="yes" />
		<cfargument name="accesskey" required="yes" />

		<cfif accesskey NEQ "">
			<cfset keyPos = FindNoCase(accesskey, label)>
			<cfset label = Insert("</em>", label, keyPos)>
			<cfset label = Insert('<em class="hotkey">', label, keyPos-1)>
		</cfif>
		
		<cfreturn label>
	</cffunction>

<!--------------------------------------------------------------------------------------- error

	Description: Outputs an error for a given field of a model.
	
	arguments: The model field of interest
				
	Description: 
				The error will be set in the Request variable only if it is meant to be displayed.  
				This function checks for the existence of the error and if it exists it gets wrapped in a 
				span with the appropriate display class and gets output.
				
	Return Value: None
			
----------------------------------------------------------------------------------------------------->
	<cffunction name="error" access="public" output="true">
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
		<cfinvoke method="before" argumentcollection="#arguments#" returnvariable="attributes" />
		
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
		
		<cfinvoke method="after" argumentcollection="#arguments#" />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- textarea

	Description:	Outputs a dynamic <textarea>
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textarea" access="public" output="true">
	
		<cfinvoke method="before" argumentcollection="#arguments#" returnvariable="attributes" />
				
		<cfset variables.value = "" />
		<cfif isDefined("request.data_object.#arguments.field#")>
			<cfset variables.value = Evaluate('request.data_object.#arguments.field#') />
		</cfif>
		
		<textarea #attributes.string()#>#variables.value#</textarea>
		
		<cfinvoke method="after" argumentcollection="#arguments#" />
	</cffunction>
</cfcomponent>
