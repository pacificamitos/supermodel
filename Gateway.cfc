<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

	<cfparam name="This.order_by" default="" />
	<cfparam name="This.sort_direction" default="" />

<!---------------------------------------------------------------------------------------------- init

	Description: Private constructor.  Called implicitly.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init">
		<cfargument name="dsn" type="string" required="yes" hint="The datasource name" />
		<cfargument name="model_name" type="string" required="yes">
		<cfargument name="table_name" type="string" default="#arguments.model_name#s">

		<cfset variables.table_name = arguments.table_name />
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
			
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Gateway Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- select

	Description: Returns a query of all objects in this table or a subset if conditions are provided

----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="select" access="public" returntype="query">
		<cfargument name="order_by" default="#This.order_by#" />
		<cfargument name="sort_direction" default="" />
		<cfargument name="conditions" default="" />
		<cfargument name="columns" default="*" />
		<cfif arguments.sort_direction EQ "">
			<cfif IsDefined("This.sort_direction")>
				<cfset arguments.sort_direction = This.sort_direction />
			<cfelse>
				<cfset arguments.sort_direction = "ASC" />
			</cfif>
		</cfif>
		<cfset selectObject = selectQuery(
			arguments.order_by, 
			arguments.sort_direction, 
			arguments.conditions, 
			arguments.columns) />

		<cfreturn  selectObject />
			
	</cffunction>
	
<!--------------------------------------------------------------------------------------- selectQuery

	Description:	@TODO
	
	arguments:		@TODO
				
	Return Value:	@TODO
			
----------------------------------------------------------------------------------------------------->	
<cffunction name="selectQuery">
		<cfargument name="order_by" required="yes" />
		<cfargument name="sort_direction" required="yes" />
		<cfargument name="conditions" required="yes" />
		<cfargument name="columns" required="yes" />
				
		<cfset order_by = upperOrderBy(order_by)>

		<cfquery name="SelectObject" datasource="#variables.dsn#">
			SELECT * <cfif arguments.order_by NEQ "">, #order_by# AS sort</cfif>
			FROM #variables.table_name#
			<cfif arguments.conditions NEQ "">
			WHERE #PreserveSingleQuotes(arguments.conditions)#
			</cfif>
			<cfif arguments.order_by NEQ "">
			ORDER BY sort #sort_direction#
			</cfif>
		</cfquery>
		
		<cfreturn SelectObject />
	</cffunction>
	
<!-------------------------------------------------------------------------------------- upperOrderBy

	Description:	Call this function within a query of queries to prevent case-sensitive sorting
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="upperOrderBy">
		<cfargument name="order_by" required="yes">
		<cfif order_by NEQ "">
			<cfset column_name = ListLast(order_by, '.') />
			<cfif ListLen(order_by, '.') EQ 1>
				<cfset table_name = '#variables.table_name#' />
			<cfelse>
				<cfset table_name = ListFirst(order_by, '.') />
			</cfif>
			<cfif getColumnType(column_name, table_name) EQ 'cf_sql_varchar'>
				<cfset order_by = 'upper(#order_by#)'>
			</cfif>
		</cfif>
		<cfreturn order_by />
	</cffunction>
	
<!------------------------------------------------------------------------------------ getColumnType

	Description:	A helper method that takes in the name of a column and returns the type of the column
								as a cf_sql_type
			
----------------------------------------------------------------------------------------------------->


	<cffunction name="getColumnType">
		<cfargument name="column_name" required="yes">
		<cfargument name="table_name" default="#variables.table_name#">
		
		<cfquery name="GetColumns" datasource="#variables.dsn#" cachedwithin="#CreateTimespan(1,0,0,0)#">
			SELECT data_type
			FROM information_schema.columns
			WHERE(table_name = '#arguments.table_name#')
			AND (column_name = '#arguments.column_name#')
		</cfquery>
		
		<cfset type = cf_sql_type(GetColumns.data_type)>
		<cfreturn type />

	</cffunction>

<!---------------------------------------------------------------------------------------- cf_sql_type

	Description:	Takes in a SQL Server column type and returns the corresponding ColdFusion type
								to be used by the <cfqueryparam> tag.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="cf_sql_type">
		<cfargument name="type" required="yes" />
		<cfswitch expression="#type#">
			<cfcase value="int">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="money">
				<cfreturn "cf_sql_money" />
			</cfcase>
			<cfcase value="decimal">
				<cfreturn "cf_sql_decimal" />
			</cfcase>
			<cfcase value="double">
				<cfreturn "cf_sql_double" />
			</cfcase>
			<cfcase value="date">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="datetime">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="time">
				<cfreturn "cf_sql_timestamp" />
			</cfcase>
			<cfcase value="bit">
				<cfreturn "cf_sql_bit" />
			</cfcase>
			<cfdefaultcase>
				<cfreturn "cf_sql_varchar" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>	
</cfcomponent>
