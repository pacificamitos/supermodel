<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description: Constructor
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" output="false" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="table_name" type="string" />
		
		<cfset variables.dsn = arguments.dsn />
		<cfif structKeyExists(arguments, 'table_name')>
			<cfset variables.table_name = arguments.table_name />
		</cfif>
	</cffunction>
			
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Gateway Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------------- select

	Description:	Executes a SELECT query
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="select" access="public" returntype="query" output="false">
		<cfargument name="columns" default="*" />
		<cfargument name="tables" default="#variables.table_name#" />
		<cfargument name="conditions" default="" />
		<cfargument name="ordering" default="" />
		
		
		<cfset var query  = "" />

		<cfquery name="query" datasource="#variables.dsn#">
			SELECT #arguments.columns# 
			FROM #arguments.tables#
			<cfif arguments.conditions NEQ "">
			WHERE #PreserveSingleQuotes(arguments.conditions)#
			</cfif>
			<cfif arguments.ordering NEQ "">
			ORDER BY #arguments.ordering#
			</cfif>
		</cfquery>
		
		<cfreturn query />
	</cffunction>
</cfcomponent>
