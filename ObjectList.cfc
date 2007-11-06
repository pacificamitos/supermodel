<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="object" type="supermodel.datamodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset setObject(arguments.object) />
		<cfset setQuery(arguments.query) />
		
		<cfset variables.current_row = 0 />
	</cffunction>
		
	<cffunction name="setObject" access="public" returntype="void" output="false">
		<cfargument name="object" type="supermodel.datamodel" required="yes" />
		
		<cfset variables.object = arguments.object />
	</cffunction>
	
	<cffunction name="setQuery" access="public" returntype="void" output="false">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.query = arguments.query/>
	</cffunction>
	
	<cffunction name="next" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ query.recordcount>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row + 1 />
			
		<cfloop list="#query.columnlist#" index="column">
			<cfset row_values[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfset variables.object.id = row_values['id'] />
		<cfset variables.object.load(row_values) />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="prev" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ 0>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row - 1 />
		
		<cfloop list="#query.columnlist#" index="column">
			<cfset row_values[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfset variables.object.id = row_values['id'] />
		<cfset variables.object.load(row_values) />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="current" access="public" returntype="supermodel.datamodel" output="false">
		<cfreturn variables.object />
	</cffunction>
</cfcomponent>