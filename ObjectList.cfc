<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="true">
		<cfargument name="object" type="supermodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		<cfset variables.length = arguments.query.recordcount />
		
		<cfif variables.query.recordcount GT 0 AND structKeyExists(variables.object, 'filter_key')>

			<cfquery name="variables.distinct_rows" dbtype="query">
				SELECT #variables.object.filter_key#
				FROM variables.query
				GROUP BY #variables.object.filter_key#
			</cfquery>
			
			<cfset variables.length = variables.distinct_rows.recordcount />
			
		</cfif>
		
		<cfset reset() />
	</cffunction>
	
	<cffunction name="filter" access="public" returntype="supermodel.objectlist">
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
	
	<cffunction name="setOrder" access="public" returntype="void">
		<cfargument name="fields" type="string" required="yes" />
		
		<cfquery name="variables.query" dbtype="query">
			SELECT * 
			FROM variables.query
			ORDER BY #fields#
		</cfquery>
		
		<cfset reset() />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="supermodel.datamodel">
		<cfreturn variables.object />
	</cffunction>
	
	<cffunction name="paginate" access="public" returntype="void">
		<cfargument name="page" type="numeric" required="yes" />
		<cfargument name="offset" type="numeric" required="yes" />
		
		<cfset variables.current_row = (arguments.page - 1) />
		<cfset variables.length = min(variables.query.recordcount, arguments.offset) />
	</cffunction>
	
	<cffunction name="reset" access="public" returntype="void">
		<cfset variables.object.clear() />
		<cfset variables.current_row = 0 />
	</cffunction>
	
	<cffunction name="length" access="public" returntype="numeric">
		<cfreturn variables.length />
	</cffunction>
	
	<cffunction name="current" access="public" returntype="supermodel">
		<cfreturn variables.object />
	</cffunction>
	
	<cffunction name="currentIndex" access="public" returntype="numeric">
		<cfreturn variables.current_row />
	</cffunction>
	
	<cffunction name="jump_to" access="public" returntype="void">
		<cfargument name="row" type="numeric" required="yes" />
		
		<cfset current_row = arguments.row />
		
		<cfset loadCurrentValues() />
	</cffunction>
	
	<cffunction name="next" access="public" returntype="boolean">
		
		<cfif variables.current_row EQ variables.length>
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
	
	<cffunction name="toOptions" access="public" returntype="query">
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
		
	<cffunction name="loadCurrentValues" access="private" returntype="void">		
		<cfset var subquery = "" />
		
		<cfif structKeyExists(variables.object, 'filter_key')>
		
			<cfquery name="subquery" dbtype="query">
				SELECT *
				FROM variables.query
				WHERE #variables.object.filter_key# = #variables.distinct_rows[variables.object.filter_key][variables.current_row]#
			</cfquery>
			<cfset variables.object.clear() />
			<cfset variables.object.load(subquery) />
		<cfelse>
			<cfset variables.object.load(rowToStruct(variables.query)) />
		</cfif>
	</cffunction>
	
	<cffunction name="setQuery" access="public" returntype="void">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset init(variables.object,arguments.query) />
	</cffunction>
	
	<cffunction name="rowToStruct" access="private" returntype="struct">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset var struct = structNew() />
		
		<cfloop list="#query.columnlist#" index="column">
			<cfset struct[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfreturn struct />
	</cffunction>
</cfcomponent>