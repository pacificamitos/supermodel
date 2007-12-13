<cfcomponent>
	<cffunction name="init" access="public" returntype="void">
		<cfargument name="object" type="supermodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		
		<cfset reset() />
	</cffunction>
	
	<cffunction name="reset" access="public" returntype="void">
		<cfset variables.current_row = 0 />
	</cffunction>
	
	<cffunction name="length" access="public" returntype="numeric">
		<cfreturn variables.query.recordcount />
	</cffunction>
	
	<cffunction name="current" access="public" returntype="supermodel">
		<cfreturn variables.object />
	</cffunction>
	
	<cffunction name="jump_to" access="public" returntype="void">
		<cfargument name="row" type="numeric" required="yes" />
		
		<cfset current_row = arguments.row />
		
		<cfset loadCurrentValues() />
	</cffunction>
	
	<cffunction name="next" access="public" returntype="boolean">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ variables.query.recordcount>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row + 1 />
			
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="prev" access="public" returntype="boolean">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ 0>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row - 1 />
		
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="toArray" access="public" returntype="array">
		<cfset var array = ArrayNew(1) />
		<cfset var saved_current_row = variables.current_row />
		<cfset var i = 1 />
		
		<cfset variables.current_row = 0 />

		<cfloop condition="#next()#">
			<cfset array[i] = current().clone() />
			<cfset i = i + 1 />
		</cfloop>
		
		<cfset variables.current_row = saved_current_row />
		
		<cfreturn array />
	</cffunction>
	
	<cffunction name="toQuery" access="public" returntype="query">
		<cfreturn variables.query />
	</cffunction>
		
	<cffunction name="loadCurrentValues" access="private" returntype="void">
		<cfloop list="#query.columnlist#" index="column">
			<cfset row_values[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfset variables.object.load(row_values) />
	</cffunction>
</cfcomponent>