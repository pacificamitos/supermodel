<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="object" type="supermodel.datamodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		
		<cfset variables.current_row = 0 />
	</cffunction>
	
	<cffunction name="current" access="public" returntype="supermodel.datamodel" output="false">
		<cfreturn variables.object />
	</cffunction>
	
	<cffunction name="jump_to" access="public" returntype="void" output="false">
		<cfargument name="row" type="numeric" required="yes" />
		
		<cfset current_row = arguments.row />
		
		<cfset loadCurrentValues() />
	</cffunction>
	
	<cffunction name="next" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ query.recordcount>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row + 1 />
			
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="prev" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ 0>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row - 1 />
		
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>
		
	<cffunction name="loadCurrentValues" access="private" returntype="void" output="false">
		<cfloop list="#query.columnlist#" index="column">
			<cfset row_values[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfset variables.object.id = row_values['id'] />
		<cfset variables.object.load(row_values) />
	</cffunction>
</cfcomponent>