<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------------- init

	Description: Constructor
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		<cfargument name="table_name" type="string" />
		
		<cfset configure() />
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

	<cffunction name="select" access="public" returntype="query">
		<cfargument name="columns" default="*" />
		<cfargument name="tables" default="#variables.table_name#" />
		<cfargument name="conditions" default="" />
		<cfargument name="ordering" default="" />
		
		
		<cfset var query  = "" />
		<cfset var cache_time = CreateTimespan(0,0,0,0) />
		
		<cfif structKeyExists(variables, 'cache')>
			<cfset cache_time = CreateTimeSpan(1,0,0,0) />
		</cfif>

		<cfquery name="query" datasource="#variables.dsn#" cachedwithin="#cache_time#">
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
