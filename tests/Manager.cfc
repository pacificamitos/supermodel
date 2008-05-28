<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset variables.group_by_column = 'user_id' />
		<cfset hasMany('supermodel.tests.process') />
	</cffunction>
	
	<cffunction name="load" access="public"  returntype="void">
		<cfargument	name="data" required="yes" type="any" />
		<cfargument name="fields"	default="" type="string" />
		
		<cfset var params = structNew() />
		
		<!--- Clear any lazily-initialized variables to force them to be recalculated --->
		<cfset clear() />
		<!--- 
			If the list of fields is not provided explicitly then we loop 
			over every field in the provided params structure
		--->
		
		<cfif isQuery(data)>
			<cfloop list="#data.columnlist#" index="column">
				<cfset params[column] = data[column][1] />
			</cfloop>
			
			<cfquery name="processes_query" dbtype="query">
				SELECT distinct number, process_id
				FROM data
			</cfquery>
			
			<cfset this.processes.setQuery(processes_query) />
		<cfelse>
			<cfset params = arguments.data />
		</cfif>
		
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

</cfcomponent>