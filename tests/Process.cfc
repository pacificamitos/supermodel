<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "processes" />
		<cfset variables.group_by_column = 'process_id' />
		<!--- <cfset hasMany('supermodel.tests.position') /> --->
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