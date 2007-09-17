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
		<cfargument name="model_path" type="string" required="yes" />

		<cfset variables.model_name = arguments.model_name />
		<cfset variables.model_path = arguments.model_path />
	</cffunction>
	
	<cffunction name="getErrors">
		<cfreturn variables.errors>
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
		<cfset var validation_file = GetDirectoryFromPath(GetCurrentTemplatePath()) & "validation.cfm" />
		
		<cfset StructClear(variables.errors) />	
		<cfset StructClear(variables.warnings) />	
		
		<cfif FileExists(validation_file)>
			<cfinclude template="#getIncludePath()#/validation.cfm" />
		</cfif>
		<cfset thisIsValid = StructIsEmpty(variables.errors)>
		<cfreturn  thisIsValid />
	</cffunction>	
	
<!---------------------------------------------------------------------------------------------- help

	Description:	Given a field name, returns the corresponding help message if one exists.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="help" access="public" returntype="string">
		<cfargument name="field" type="string" required="yes" hint="The field we want help for" />
		
		<cfset var validation_file = GetDirectoryFromPath(GetCurrentTemplatePath()) & "help.cfm" />
		
		<cfset help_message = "No help available" />	
		
		<cfif FileExists(validation_file)>
			<cfinclude template="#getIncludePath()#/help.cfm" />
		</cfif>
		
		<cfreturn help_message />
	</cffunction>	
	
<!------------------------------------------------------------------------------------- getIncludePath

	Description:	Converts a model_path of the form "folder1.folder2.modelname" to a directory path
								that can be used by <cfinclude>
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="getIncludePath">
		<cfset var include_path = "/" />
		<cfset include_path = include_path & Replace(variables.model_path, ".", "/", "all") />
		<cfset include_path = ListDeleteAt(include_path, ListLen(include_path, "/"), "/") />
		
		<cfreturn include_path />
	</cffunction>
</cfcomponent>
