<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description:	Sets the name of the object and the filesystem folder that the object's CFC file
								is stored in.  this function is called implicitly whenever an object
								is instantiated or invoked.

---------------------------------------------------------------------------------------------------->

	<cffunction name="init" access="public" returntype="void"
		hint="Initializes the object">
		<cfset variables.errors  = structNew() />
		<cfset variables.loaded = false />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Core Functions ------------------------------------------>
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- load

	Description:	Takes in a structure of attribute-value pairs and updates the object's attributes
								to match those in the given structure.  If the structure contains
								attributes that the object does not have then those attributes are
								silently ignored.

---------------------------------------------------------------------------------------------------->

	<cffunction name="load" access="public"  returntype="void"
		hint="Loads a structure of attributes into the model">
		<cfargument	name="params" required="yes" type="struct" />
		<cfargument name="fields"	default="" type="string" />

		<!---
			If the list of fields is not provided explicitly then we loop
			over every field in the provided params structure
		--->
		<cfif arguments.fields EQ "">
			<cfset arguments.fields = structKeyList(params) />
		</cfif>

		<!---
			Loop over the list of fields and copy them from the params struct
			into the "this" struct
		--->
		<cfloop list="#arguments.fields#" index="key">
			<cfif structKeyExists(this, key)>
				<cfset structInsert(this, key, structFind(params, key), "True") />
			</cfif>
		</cfloop>
	</cffunction>

<!----------------------------------------------------------------------------------------- validate

	Description: Runs the object's validation criteria

---------------------------------------------------------------------------------------------------->

	<cffunction name="validate" access="public" returntype="void">
    <!--- Implemented in child --->
	</cffunction>

<!---------------------------------------------------------------------------------------- hasErrors 

	Description: Validates the object's attributes

---------------------------------------------------------------------------------------------------->

	<cffunction name="hasErrors" access="public" returntype="boolean">
		<cfreturn structIsEmpty(variables.errors) />
	</cffunction>

<!----------------------------------------------------------------------------------------- getErrors

	Description:	Creates deep copies (i.e. clones) of all complex member variables

---------------------------------------------------------------------------------------------------->

	<cffunction name="getErrors" access="public" returntype="struct">
		<cfreturn variables.errors />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Helper Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------- defined

	Description:	A wrapper around the structKeyExists method to make checking for variables a
								little cleaner

---------------------------------------------------------------------------------------------------->

	<cffunction name="defined" access="private" returntype="boolean">
		<cfargument name="property" type="string" required="yes" />

		<cfreturn structKeyExists(variables, arguments.property) />
	</cffunction>
</cfcomponent>
