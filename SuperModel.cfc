<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description:	Sets the name of the object and the filesystem folder that the object's CFC file is
								stored in.  This function is called implicitly whenever an object is instantiated or
								invoked.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void" 
		hint="Initializes the object">
		<cfset variables.errors  = StructNew() />
		<cfset variables.lazy_variables = StructNew() />
		<cfset variables.loaded = false />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Core Functions ------------------------------------------>
<!-------------------------------------------------------------------------------------------------->
			
<!---------------------------------------------------------------------------------------------- load

	Description:	Takes in a structure of attribute-value pairs and updates the object's attributes 
								to match those in the given structure.  If the structure contains attributes that the
								object does not have then those attributes are silently ignored.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="load" access="public"  returntype="void"
		hint="Loads a structure of attributes into the model">
		<cfargument	name="params" required="yes" type="struct" />
		<cfargument name="fields"	default="" type="string" />
		
		<!--- Clear any lazily-initialized variables to force them to be recalculated --->
		<cfset clear() />
		
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
	
<!--------------------------------------------------------------------------------------------- isValid

	Description: Validates the object's attributes
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="isVerified" access="public" returntype="boolean">
		
		<cfreturn structIsEmpty(variables.errors) />

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
	
<!------------------------------------------------------------------------------------------- toStruct

	Description:	Returns a shallow copy of this object
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="toStruct" access="public" returntype="struct">
		<cfset var copy = structNew() />
		<cfset var attribute = "" />
				
		<!--- Copy all attributes/keys from the current object into the copy --->
		<cfloop list="#structKeyList(this)#" index="attribute">
			<cfset attribute = LCase(attribute) />
			<cfif NOT isCustomFunction(this[attribute])>
				<cfif isObject(this[attribute])>
					<cfset copy[attribute] = this[attribute].toStruct() />
				<cfelse>
					<cfset copy[attribute] = this[attribute] />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn copy />
	</cffunction>
	
<!------------------------------------------------------------------------------------------ getErrors

	Description:	Creates deep copies (i.e. clones) of all complex member variables
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="getErrors" access="public" returntype="struct">
		<cfreturn variables.errors />
	</cffunction>
		
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Accessor Functions ---------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!------------------------------------------------------------------------------------- setObjectPath

	Description:	Sets the path to the object's cfc
			
---------------------------------------------------------------------------------------------------->	
	
	<cffunction name="setObjectPath" access="private" returntype="void">
		<cfargument name="object_path" type="string" required="yes" />
		
		<cfset variables.object_path = arguments.object_path />
	</cffunction>
	
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Helper Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->


<!------------------------------------------------------------------------------------- getIncludePath

	Description:	Returns the dot-separated path of the component
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="getObjectPath" access="private" returntype="string">
		<cfreturn getMetaData(this).name />
	</cffunction>
	
<!------------------------------------------------------------------------------------- getIncludePath

	Description:	Converts a object_path of the form "folder1.folder2.objectname" to a directory path
								that can be used by <cfinclude>
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="getIncludePath" access="private" returntype="string">
		<cfset var include_path = "/" />
		<cfset include_path = include_path & Replace(getObjectPath(), ".", "/", "all") />
		<cfset include_path = ListDeleteAt(include_path, ListLen(include_path, "/"), "/") />
		
		<cfreturn include_path />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- assert

	Description:	Asserts the given condition by throwing an exception if the condition is false
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="assert" access="private" returntype="void">
		<cfargument name="condition" type="boolean" required="yes" />
		<cfargument name="message" type="string" default="Assertion Failed" />
		
		<cfif NOT condition>
			<cfthrow message="#arguments.message#">
		</cfif>
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- clear

	Description:	Get rid of all lazy-loaded variables
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="clear" access="public" returntype="void">		
		
		<cfloop list="#StructKeyList(variables.lazy_variables)#" index="property">
			<cfset StructDelete(variables, property) />
		</cfloop>
		
		<cfset variables.loaded = false />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- define

	Description:	Indicate that the given property was defined via lazy-loading
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="define" access="private" returntype="void">
		<cfargument name="property" type="string" required="yes" />
		<cfargument name="value" type="any" required="yes" />
		
		<cfset variables.lazy_variables[arguments.property] = true />
		<cfset variables[arguments.property] = arguments.value />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------- defined

	Description:	A wrapper around the structKeyExists method to make checking for variables a little
								cleaner
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="defined" access="private" returntype="boolean">
		<cfargument name="property" type="string" required="yes" />
		
		<cfreturn structKeyExists(variables, arguments.property) />
	</cffunction>
</cfcomponent>
