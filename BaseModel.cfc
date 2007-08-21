<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

	<cfparam name="variables.errors" default="#StructNew()#" />
	<cfparam name="variables.warnings" default="#StructNew()#" />
	
<!---------------------------------------------------------------------------------------------- init

	Description:	Sets the name of the model and the filesystem folder that the model's CFC file is
								stored in.  This function is called implicitly whenever a model is instantiated or
								invoked.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="package" output="false" returntype="void" 
		hint="Initializes the model">
		<cfargument name="model_name" type="string" required="yes" hint="The name of the model">

		<cfset variables.model_name = arguments.model_name />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Core Functions ------------------------------------------>
<!-------------------------------------------------------------------------------------------------->
			
<!---------------------------------------------------------------------------------------------- load

	Description:	Takes in a structure of attribute-value pairs and updates the model's attributes 
								to match those in the given structure.  If the structure contains attributes that the
								model does not have then those attributes are silently ignored.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="load" access="public" output="false" returntype="void" 
		hint="Loads parameters from a structure into the model's member variables.">
		
		<cfargument
			name="params" 
			required="yes" 
			type="struct"
			hint="Structure of parameters to load into the model" />
		
		<cfargument 
			name="fields"
			default="" 
			type="string"
			hint="List of fields to update" />
		
		<!--- 
			If the list of fields is not provided explicitly then we loop 
			over every field in the provided params structure
		--->
		<cfif arguments.fields EQ "">
			<cfset arguments.fields = StructKeyList(params) />
		</cfif>

		<!--- 
			Loop over the list of fields and copy them from the params struct 
			into the "This" struct 
		--->
		<cfloop list="#arguments.fields#" index="key">
			<cfif StructKeyExists(This, key)>
				<cfset StructInsert(This, key, StructFind(params, key), "True") />
			</cfif>
		</cfloop>
	</cffunction>	
	
<!--------------------------------------------------------------------------------------------- clear

	Description: Clears the model's attributes
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="clear" access="public" returntype="void" output="false" 
		hint="Clears all of the model's attributes">
		<cfset StructClear(This) />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- valid

	Description: Validates the model's attributes
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="valid" access="public" returntype="boolean">
		<cfset StructClear(variables.errors) />	
		<cfset StructClear(variables.warnings) />	
<!--- 		<cfinclude template="#Request.path#app/#this.folder_name#/validation.cfm" /> --->
		<cfset thisIsValid = StructIsEmpty(variables.errors)>
		<cfreturn  thisIsValid />
	</cffunction>	
	
<!---------------------------------------------------------------------------------------------- help

	Description:	Given a field name, returns the corresponding help message if one exists.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="help" access="public" returntype="string">
		<cfargument name="field" />
		
		<cfset help_message = "No help available" />	
<!--- 		<cfinclude template="#Request.path#app/#this.folder_name#/help.cfm" /> --->
		
		<cfreturn help_message />
	</cffunction>	
</cfcomponent>
