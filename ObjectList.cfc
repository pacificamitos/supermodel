<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="object" type="supermodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		<cfset variables.length = arguments.query.recordcount />
		
		<cfset reset() />
	</cffunction>
	
	<cffunction name="filter" access="public" returntype="supermodel.objectlist" output="false">
		<cfargument name="condition" type="string" required="yes" />
		<cfset var list = createObject('component', 'supermodel.objectlist') />
		<cfset var query = "" />
		
		<cfquery name="query" dbtype="query">
			SELECT *
			FROM variables.query
			WHERE #preserveSingleQuotes(arguments.condition)#
		</cfquery>
		
		<cfset list.init(variables.object, query) />
		
		<cfreturn list />
	</cffunction>
	
	<cffunction name="setOrder" access="public" returntype="void" output="false">
		<cfargument name="fields" type="string" required="yes" />
		
		<cfquery name="variables.query" dbtype="query">
			SELECT * 
			FROM variables.query
			ORDER BY #fields#
		</cfquery>
		
		<cfset reset() />
	</cffunction>
	
	<cffunction name="paginate" access="public" returntype="void" output="false">
		<cfargument name="page" type="numeric" required="yes" />
		<cfargument name="offset" type="numeric" required="yes" />
		
		<cfset variables.current_row = (arguments.page - 1) />
		<cfset variables.length = min(variables.query.recordcount, arguments.offset) />
	</cffunction>
	
	<cffunction name="reset" access="public" returntype="void" output="false">
		<cfset variables.current_row = 0 />
	</cffunction>
	
	<cffunction name="length" access="public" returntype="numeric" output="false">
		<cfreturn variables.length />
	</cffunction>
	
	<cffunction name="current" access="public" returntype="supermodel" output="false">
		<cfreturn variables.object />
	</cffunction>
	
	<cffunction name="currentIndex" access="public" returntype="numeric" output="false">
		<cfreturn variables.current_row />
	</cffunction>
	
	<cffunction name="jump_to" access="public" returntype="void" output="false">
		<cfargument name="row" type="numeric" required="yes" />
		
		<cfset current_row = arguments.row />
		
		<cfset loadCurrentValues() />
	</cffunction>
	
	<cffunction name="next" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />

		<cfif variables.current_row EQ variables.length>
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
	
	<cffunction name="toArray" access="public" returntype="array" output="false">
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
	
	<cffunction name="toQuery" access="public" returntype="query" output="false">
		<cfreturn variables.query />
	</cffunction>
	
	<cffunction name="toOptions" access="public" returntype="query" output="false">
		<cfargument name="value_field" type="string" required="yes" />
		<cfargument name="label_field" type="string" required="yes" />
		
		<cfset var result = "" />
				
		<cfquery name="result" dbtype="query">
			SELECT 
				#arguments.value_field# as [value], 
				#arguments.label_field# as [label]
			FROM variables.query
		</cfquery>
		
		<cfreturn result />
	</cffunction>
		
	<cffunction name="loadCurrentValues" access="private" returntype="void" output="false">
		<cfloop list="#query.columnlist#" index="column">
			<cfset row_values[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfset variables.object.load(row_values) />
	</cffunction>
	
	<cffunction name="setQuery" access="public" returntype="void" output="false">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset init(variables.object,arguments.query) />
	</cffunction>
</cfcomponent>