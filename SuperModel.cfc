<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description:	Sets the name of the object and the filesystem folder that the object's CFC file is
								stored in.  This function is called implicitly whenever an object is instantiated or
								invoked.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="package" output="false" returntype="void" 
		hint="Initializes the object">
		<cfset variables.errors  = StructNew() />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Core Functions ------------------------------------------>
<!-------------------------------------------------------------------------------------------------->
			
<!---------------------------------------------------------------------------------------------- load

	Description:	Takes in a structure of attribute-value pairs and updates the object's attributes 
								to match those in the given structure.  If the structure contains attributes that the
								object does not have then those attributes are silently ignored.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="load" access="public" output="false" returntype="void" 
		hint="Loads parameters from a structure into the object's member variables.">
		
		<cfargument
			name="params" 
			required="yes" 
			type="struct"
			hint="Structure of parameters to load into the object" />
		
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

	Description: Clears the object's attributes
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="clear" access="public" returntype="void" output="false" 
		hint="Clears all of the object's attributes">
		<cfset StructClear(This) />
	</cffunction>
		
<!--------------------------------------------------------------------------------------------- valid

	Description: Validates the object's attributes
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="valid" access="public" returntype="boolean">
		<cfset var validation_file = GetDirectoryFromPath(GetCurrentTemplatePath()) & "validation.cfm" />
		
		<cfset StructClear(variables.errors) />	
		
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
	
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Accessor Functions ---------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!------------------------------------------------------------------------------------- setObjectPath

	Description:	Sets the path to the object's cfc
			
---------------------------------------------------------------------------------------------------->	
	
	<cffunction name="setObjectPath" access="private" output="false" returntype="void">
		<cfargument name="object_path" type="string" required="yes" />
		
		<cfset variables.object_path = arguments.object_path />
	</cffunction>
	
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Helper Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!------------------------------------------------------------------------------------- getIncludePath

	Description:	Converts a object_path of the form "folder1.folder2.objectname" to a directory path
								that can be used by <cfinclude>
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="getIncludePath" access="private" output="false" returntype="string">
		<cfset var include_path = "/" />
		<cfset include_path = include_path & Replace(variables.object_path, ".", "/", "all") />
		<cfset include_path = ListDeleteAt(include_path, ListLen(include_path, "/"), "/") />
		
		<cfreturn include_path />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- assert

	Description:	Asserts the given condition by throwing an exception if the condition is false
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="assert" access="private" returntype="void" output="false">
		<cfargument name="condition" type="boolean" required="yes" />
		<cfargument name="message" type="string" default="Assertion Failed" />
		
		<cfif NOT condition>
			<cfthrow message="#arguments.message#">
		</cfif>
	</cffunction>
</cfcomponent>
