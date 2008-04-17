<!--------------------------------------- CachingModel -----------------------------------------------

	Description:	Caches a master query and then subsequent queries are done using ColdFusions query of
								queries functionality.
								
								This is generally more efficient than using a regular DataModel but if the table being
								cached contains too many records then caching may be infeasible.
			
----------------------------------------------------------------------------------------------------->	

<cfcomponent extends="supermodel.DataModel">

<!---------------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating 
								private member variables for each field.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset super.init(arguments.dsn) />
	</cffunction>
	
<!---------------------------------------------------------------------------------------- masterQuery

	Description:	Select all records from the table
			
----------------------------------------------------------------------------------------------------->	

	
	<cffunction name="masterQuery" access="private" returntype="query">
		<cfargument name="flush" type="boolean" default="false" />
		
		<cfset var query = "" />
		<cfset var timespan = CreateTimeSpan(1,0,0,0) />
		
		<cfif arguments.flush>
			<cfset timespan = CreateTimeSpan(0,0,0,0) />
		</cfif>
		
		<cfquery name="query" datasource="#variables.dsn#" cachedwithin="#timespan#">
			SELECT * FROM #variables.table_name#
		</cfquery>
		
		<cfreturn query />
	</cffunction>
	
	<!--------------------------------------------------------------------------------------- selectQuery

	Description:	Private function that executes a SELECT SQL query
			
----------------------------------------------------------------------------------------------------->	

<cffunction name="selectQuery" access="private" returntype="query">
		<cfargument name="columns" default="*" />
		<cfargument name="tables" default="#variables.table_name#" />
		<cfargument name="conditions" default="" />
		<cfargument name="ordering" default="" />
			
		<cfset var query  = "" />
		
		<cfset columns = REReplace(columns, "#variables.table_name#.", "", "all")>
		<cfset conditions = REReplace(conditions, "#variables.table_name#.", "", "all")>

		<cfquery name="query" dbtype="query">
			SELECT #arguments.columns# 
			FROM application.#variables.table_name#
			<cfif arguments.conditions NEQ "">
			WHERE #PreserveSingleQuotes(arguments.conditions)#
			</cfif>
			<cfif arguments.ordering NEQ "">
			ORDER BY #arguments.ordering#
			</cfif>
		</cfquery>
		
		<cfreturn query />
	</cffunction>

<!--------------------------------------------------------------------------------------- insertQuery

	Description:	Insert a new record into the database with values read from the object's attributes
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="insertQuery" access="private" returntype="void">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="fields" default="#variables.database_fields#" />

		<cfset super.insertQuery(table, fields) />
		<cfset flush() />
	</cffunction>


<!--------------------------------------------------------------------------------------- updateQuery

	Description:	Update an existing record in the database with values read from the object's 
								attributes
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="updateQuery" access="private" returntype="void">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="fields" default="#variables.database_fields#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
					
		<cfset super.updateQuery(table, fields, primary_key) />
		<cfset flush() />
	</cffunction>

<!--------------------------------------------------------------------------------------- deleteQuery

	Description:	Delete the record from the database whose ID matches the ID of the current object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="deleteQuery" access="private" returntype="void">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
		
		<cfset super.deleteQuery(table, primary_key) />
		<cfset flush() />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- flush

	Description:	Remove the master query from the application scope
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="flush" access="private" returntype="void">
		<cfset masterQuery(true) />
	</cffunction>
</cfcomponent>