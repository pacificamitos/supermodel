<cfcomponent displayname="router">

	<cfset variables.patterns ='' />
<!-----------------------------------------------------------------------------------
	
	add: 
		adds a pattern to the router, seperates each entry with |
		
----------------------------------------------------------------------------------->
	<cffunction name="add" access="public" output="false" returntype="void">
		<cfargument name="route" required="yes" type="string">

		<cfset variables.patterns = listAppend(variables.patterns,arguments.route,'|') />

	</cffunction>

<!-----------------------------------------------------------------------------------
	
	getController: 
		Goes through the available patterns, finds the matching pattern and fills the
		Request struct with key-value pairs. Then populates a controller structure
		with name and method, and returns it.
		
----------------------------------------------------------------------------------->
	<cffunction name="getController" access="public" output="true" returntype="struct">
		
		<cfset var url_params = cgi.PATH_INFO />
		<cfset var controller = structNew() />
		<cfset var pattern_found = false />
		<cfloop list="#variables.patterns#" index="pattern" delimiters="|">
			#pattern#
			<!--- If  a matching pattern exists --->
			<cfif ListLen(pattern,'/') eq listLen(url_params,'/')>
				<cfset pattern_found = true />
				<cfset counter = 1 />
				<cfloop list="#pattern#" index="key" delimiters="/">
					<cfset structInsert(request,key,listGetAt(url_params,counter,'/')) />
					<cfset counter = counter + 1 />
				</cfloop>
			</cfif>
		</cfloop>
		
		<!--- if no matchig patterns were found, throw a CF Error --->
		<cfif not pattern_found>
			<cfthrow message="Pattern Does Not Exist!" />
		</cfif>
		<!--- build the controller structure --->
		<cfset structInsert(controller,'name',request.controller&'_controller') />
		<cfset structInsert(controller,'method',request.action) />

		<cfreturn controller />
	</cffunction>

</cfcomponent>