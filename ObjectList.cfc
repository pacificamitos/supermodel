<cfcomponent>

<!----------------------------------------------------------------------------------------------- init

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="object" type="supermodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />
		
		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		<cfset variables.length = arguments.query.recordcount />
		<cfif variables.query.recordcount GT 0 AND structKeyExists(variables.object, 'group_by')>

			<cfquery name="variables.distinct_rows" dbtype="query">
				SELECT #variables.object.group_by#
				FROM variables.query
				GROUP BY #variables.object.group_by#
			</cfquery>
			
			<cfset variables.length = variables.distinct_rows.recordcount />
		</cfif>
		
		<cfset reset() />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- filter

	Description:
			
----------------------------------------------------------------------------------------------------->

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
	
<!------------------------------------------------------------------------------------------- setOrder

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="setOrder" access="public" returntype="void" output="false">
		<cfargument name="fields" type="string" required="yes" />
		
		<cfquery name="variables.query" dbtype="query">
			SELECT * 
			FROM variables.query
			ORDER BY #fields#
		</cfquery>
		
		<cfset reset() />
	</cffunction>
	
<!------------------------------------------------------------------------------------------ getObject

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="getObject" access="public" returntype="supermodel.datamodel" output="false">
		<cfreturn variables.object />
	</cffunction>
	
<!------------------------------------------------------------------------------------------- paginate

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="paginate" access="public" returntype="void">
		<cfargument name="page" type="numeric" required="yes" />
		<cfargument name="offset" type="numeric" required="yes" />
		
		<cfset variables.current_row = (arguments.page - 1) * (arguments.offset) />
		<cfset variables.length = min(variables.query.recordcount, (arguments.offset) * (arguments.page)) />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- reset

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="reset" access="public" returntype="void" output="false">
		<cfset variables.current_row = 0 />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- length

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="length" access="public" returntype="numeric" output="false">
		<cfreturn variables.length />
	</cffunction>

<!-------------------------------------------------------------------------------------------- current

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="current" access="public" returntype="supermodel" output="false">
		<cfreturn variables.object />
	</cffunction>

<!--------------------------------------------------------------------------------------- currentIndex

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="currentIndex" access="public" returntype="numeric" output="false">
		<cfreturn variables.current_row />
	</cffunction>

<!-------------------------------------------------------------------------------------------- jump_to

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="jump_to" access="public" returntype="void" output="false">
		<cfargument name="row" type="numeric" required="yes" />
		
		<cfset current_row = arguments.row />
		
		<cfset loadCurrentValues() />
	</cffunction>

<!----------------------------------------------------------------------------------------------- next

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="next" access="public" returntype="boolean" output="false">
		
		<cfif variables.current_row EQ variables.length>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row + 1 />
			
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>

<!----------------------------------------------------------------------------------------------- prev

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="prev" access="public" returntype="boolean" output="false">
		<cfset var row_values = StructNew() />
		
		<cfif variables.current_row EQ 0>
			<cfreturn false />
		</cfif>
		
		<cfset variables.current_row = variables.current_row - 1 />
		
		<cfset loadCurrentValues() />
		
		<cfreturn true />
	</cffunction>

<!-------------------------------------------------------------------------------------------- toArray

	Description:
			
----------------------------------------------------------------------------------------------------->
	
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
	
<!-------------------------------------------------------------------------------------------- toQuery

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="toQuery" access="public" returntype="query" output="false">
		<cfreturn variables.query />
	</cffunction>

<!------------------------------------------------------------------------------------------ toOptions

	Description:
			
----------------------------------------------------------------------------------------------------->
	
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

<!---------------------------------------------------------------------------------- loadCurrentValues

	Description:
			
----------------------------------------------------------------------------------------------------->
		
	<cffunction name="loadCurrentValues" access="private" returntype="void" output="false">		
		<cfset var subquery = "" />
		
		<cfif structKeyExists(variables.object, 'group_by')>
		
			<cfquery name="subquery" dbtype="query">
				SELECT *
				FROM variables.query
				<cfif variables.distinct_rows[variables.object.group_by][variables.current_row] NEQ "">
				WHERE #variables.object.group_by# = 
				#variables.distinct_rows[variables.object.group_by][variables.current_row]#
				</cfif>
			</cfquery>
			
			<cfset variables.object.load(subquery) />
		<cfelse>
			<cfset variables.object.load(rowToStruct(variables.query)) />
		</cfif>
	</cffunction>

<!------------------------------------------------------------------------------------------- setQuery

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="setQuery" access="public" returntype="void" output="false">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset init(variables.object,arguments.query) />
	</cffunction>
	
	<cffunction name="rowToStruct" access="private" returntype="struct" output="false">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset var struct = structNew() />
		
		<cfloop list="#query.columnlist#" index="column">
			<cfset struct[column] = query[column][variables.current_row] />
		</cfloop>
		
		<cfreturn struct />
	</cffunction>
</cfcomponent>