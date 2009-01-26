<cfcomponent>
  <!--- These are reserved form control arguments that will not be treated as HTML attributes --->
  <cfset variables.reserved_arguments = "field,label,required,value" />

<!----------------------------------------------------------------------------------------- textfield

	Description:	Outputs an <input type="text"> field
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textfield" access="public" output="true">
		<cfinvoke method="before" argumentcollection="#arguments#" />
		
		<cfset attributes.set("value", object[arguments.field]) />
		<cfset attributes.add("type", "text") />

		<input #attributes.string()# />
		
		<cfinvoke method="after" argumentcollection="#arguments#" />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- textarea

	Description:	Outputs a <textarea> field
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="textarea" access="public" output="true">
		<cfinvoke method="before" argumentcollection="#arguments#" />
				
		<textarea #attributes.string()#>#object[arguments.field]#</textarea>
		
		<cfinvoke method="after" argumentcollection="#arguments#" />
	</cffunction>
  
<!------------------------------------------------------------------------------------------ before

	Description:	This function is called at the beginning of every form control.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="before" access="private" returntype="void">	
    <cfset variables.object = request.data_object />

		<!--- Display the label for the form field --->	
		<cfinvoke method="label" argumentcollection="#arguments#" />
		
		<!--- Create an attributes object to store the HTML attributes for the form contol --->
		<cfobject name="variables.attributes" component="supermodel.attributes" />
		
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
	</cffunction>

<!---------------------------------------------------------------------------------------- after

	Description:	This function gets called at the end of every form control
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="after" access="private" returntype="void">
		<cfinvoke method="error" argumentcollection="#arguments#" />
  </cffunction>

<!--------------------------------------------------------------------------------------- label

	Description:	Every form field has a corresponding <label> tag with the English description of the
								field.
			
----------------------------------------------------------------------------------------------------->
	
<cffunction name="label" access="private" returntype="void"> 
	<cfargument name="field" required="yes" />
	<cfargument name="label" default="#arguments.field#" />
	<cfargument name="required" default="true" />
	<cfargument name="accesskey" default="" />

  <cfset var pos = 0 />

  <cfif accesskey NEQ "">
    <cfset pos = findNoCase(accesskey, arguments.label) />
    <cfset arguments.label = insert('</em>', arguments.label, pos) /> 
    <cfset arguments.label = insert('<em class="accesskey">', arguments.label, pos - 1) /> 
  </cfif>

	<cfoutput>
    <label for="#field#" <cfif arguments.required>class="required"</cfif>>
      #arguments.label#:
    </label>
	</cfoutput>
</cffunction>

<!--------------------------------------------------------------------------------------- error

	Description: Outputs an error for a given field of a model.

----------------------------------------------------------------------------------------------------->
	<cffunction name="error" access="private" returntype="void">
		<cfargument name="field" type="string" required="yes" />

    <cfset var errors = object.getErrors() />
    <cfset var error = errors[arguments.field] />

    <cfoutput>
      <div id="error_#field#" class="error">#error#</div>
    </cfoutput>
	</cffunction>
</cfcomponent>
