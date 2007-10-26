<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description: Constructor
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="table_name" type="string" required="yes" />
		
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.table_name = arguments.table_name />
	</cffunction>
			
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Gateway Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- select

	Description: Returns a query of all objects in this table or a subset if conditions are provided

----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="select" access="public" returntype="query">
		<cfargument name="columns" type="string" />
		<cfargument name="tables" type="string" />
		<cfargument name="conditions" type="string"/>
		<cfargument name="ordering" type="string" />
		
		<cfset var selectObject = "" />
		
		<cfif arguments.sort_direction EQ "">
			<cfif IsDefined("variables.sort_direction")>
				<cfset arguments.sort_direction = variables.sort_direction />
			<cfelse>
				<cfset arguments.sort_direction = "ASC" />
			</cfif>
		</cfif>
		
		<cfset selectObject = selectQuery(
			arguments.order_by, 
			arguments.sort_direction, 
			arguments.conditions, 
			arguments.columns) />

		<cfreturn selectObject />
	</cffunction>
</cfcomponent>
