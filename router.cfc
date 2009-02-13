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
	<cffunction name="getController" access="public" output="false" returntype="struct">
		
		<cfset var url_params = cgi.PATH_INFO />
		<cfset var controller = structNew() />

		<cfloop list="#variables.patterns#" index="pattern" delimiters="|">
			
			<!--- If  a matching pattern exists --->
			<cfif ListLen(pattern,'/') eq listLen(url_params,'/')>
				<cfset counter = 1 />
				<cfloop list="#pattern#" index="key" delimiters="/">
					<cfset structInsert(request,key,listGetAt(url_params,counter,'/')) />
					<cfset counter = counter + 1 />
				</cfloop>
			<!--- Otherwise, throw an error --->
			<cfelse>
				<cfthrow message="Pattern does not exist" />
			</cfif>
		</cfloop>
		
		<!--- build the controller structure --->
		<cfset structInsert(controller,'name',request.controller&'_controller') />
		<cfset structInsert(controller,'method',request.action) />

		<cfreturn controller />
	</cffunction>

</cfcomponent>