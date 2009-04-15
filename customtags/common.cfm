<!---------------------------------------------------------------------------------------------- label

	Description:	Every form id has a corresponding <label> tag with the English description of the
								id.

----------------------------------------------------------------------------------------------------->

<cffunction name="label" access="private" returntype="void">
	<cfargument name="id" required="yes" />
	<cfargument name="label" default="#arguments.id#" />
	<cfargument name="required" default="true" />
	<cfargument name="accesskey" default="" />

  <cfset var pos = 0 />

  <cfif arguments.label EQ "">
    <cfreturn />
  </cfif>

  <cfif accesskey NEQ "">
    <cfset pos = findNoCase(accesskey, arguments.label) />
    <cfset arguments.label = insert('</em>', arguments.label, pos) />
    <cfset arguments.label = insert('<em class="accesskey">', arguments.label, pos - 1) />
  </cfif>

	<cfoutput>
    <label for="#id#" <cfif arguments.required>class="required"</cfif>>
      #arguments.label#:
    </label>
	</cfoutput>
</cffunction>

<!---------------------------------------------------------------------------------------------- error

	Description: Outputs an error for a given id of a model.

----------------------------------------------------------------------------------------------------->
<cffunction name="error" access="private" returntype="void">
  <cfargument name="id" type="string" required="yes" />

  <cfif structKeyExists(request, 'data_object') AND structKeyExists(request.data_object.errors, arguments.id)>
    <cfoutput>
      <span id="error_#id#" class="error">#request.data_object.errors[arguments.id]#</span>
    </cfoutput>
  </cfif>
</cffunction>

<!--------------------------------------------------------------------------------------------- before

	Description:	This function is called at the beginning of every form control.

----------------------------------------------------------------------------------------------------->

<cffunction name="before" access="private" returntype="void">
  <cfset variables.reserved_arguments = "id,label,required,value,break" />

  <!--- Display the label for the form id --->
  <cfinvoke method="label" argumentcollection="#arguments#" />

  <!--- Create an thistag.attributes object to store the HTML thistag.attributes for the form contol --->
  <cfobject name="thistag.attributes" component="supermodel2.attributes" />

  <!--- Initialize the thistag.attributes with the passed-in arguments excluding the reserved ones --->
  <cfset thistag.attributes.init(
    argumentcollection = arguments,
    reserved_arguments = variables.reserved_arguments) />

  <!--- Add some default thistag.attributes if they aren't provided as arguments --->
  <cfset thistag.attributes.set("id", arguments.id) /> <!--- ID MUST be the id name --->
  <cfset thistag.attributes.add("name", arguments.id) />
</cffunction>

<!---------------------------------------------------------------------------------------------- after

	Description:	This function gets called at the end of every form control

----------------------------------------------------------------------------------------------------->

<cffunction name="after" access="private" returntype="void">
  <cfinvoke method="error" argumentcollection="#arguments#" />
  <cfif NOT structKeyExists(arguments, 'break') OR arguments.break EQ "yes">
    <br />
  </cfif>
</cffunction>
