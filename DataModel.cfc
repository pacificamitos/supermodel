<!--------------------------------------- DataModel -------------------------------------------------

	Description:	Adds CRUD (Create/Read/Update/Delete) methods to the object so that each instance of 
								the object is tied to a single record in the database table.
			
----------------------------------------------------------------------------------------------------->	

<cfcomponent name="DataModel" extends="supermodel.SuperModel">

<!---------------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating 
								private member variables for each field.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset super.init() />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.primary_key = 'id' />
		<cfset injectAttributes() />
	</cffunction>
	 
<!---------------------------------------------------------------------------------------------- save

	Description:	If the object has a value for its id then the record will be updated otherwise
                a new record will be created.
			
----------------------------------------------------------------------------------------------------->	
  
  <cffunction name="save" access="public" returntype="void" output="false">   
    <cfif NOT persisted()>
      <cfset create()>
    <cfelse>
      <cfset update()>
    </cfif>
  </cffunction>
	
<!--------------------------------------------------------------------------------------------- create

	Description:	Inserts a new record into the database with values taken from this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="create" access="public" returntype="supermodel.DataModel" output="false">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before inserting it" />
		
		<cfif structKeyExists(arguments, 'params')>
			<cfinvoke method="load" params="#params#" />
		</cfif>
		
		<cfif valid()>		
				<cfset insertQuery() />
		</cfif>

		<cfreturn this />
	</cffunction>

<!---------------------------------------------------------------------------------------------- read

	Description:	Takes in an ID and reads the data from the database into this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="read" access="public" returntype="void" output="false">
		<cfargument name="id" required="yes" />
		
		<cfset var query = "" />
		<cfset var params = StructNew() />
		
		<cfset assert(isNumeric(arguments.id), "id must be a numeric value") />
		
		<cfset this.id = arguments.id />
		<cfset query = selectQuery(conditions = "#table_name#.id = #this.id#") />
		
		<cfif query.recordcount EQ 1>
			<cfloop list="#query.columnlist#" index="column">
				<cfset StructInsert(params, column, Evaluate("query.#column#"), true) />
			</cfloop>
		</cfif>
				
 		<cfset load(params) />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------- update

	Description: Saves the content of the current object into the database.
				
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="update" access="public" returntype="void" output="false">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before update it" />
		
		<cfif isDefined("arguments.params")>
			<cfinvoke method="load" params="#params#" />
		</cfif>
		
		<cfif valid()>
			<cfset updateQuery() />			
		</cfif>
	</cffunction>

<!--------------------------------------------------------------------------------------------- delete

	Description: Deletes the current record from the database and clears the object.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="delete" access="public" returntype="void" output="false">
		<cfinvoke method="deleteQuery" />
		<cfinvoke method="clear" />
	</cffunction>
	
<!------------------------------------------------------------------------------------------ persisted

	Description: Returns true if the object is currently tied to a database record
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="persisted" access="public" returntype="boolean" output="false">
		<cfreturn structKeyExists(this, 'id') AND this.id NEQ "">
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Basic Query Functions -------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------- selectQuery

	Description:	Private function that executes a SELECT SQL query
			
----------------------------------------------------------------------------------------------------->	

<cffunction name="selectQuery" access="private" returntype="query" output="false">
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

<!--------------------------------------------------------------------------------------- insertQuery

	Description:	Insert a new record into the database with values read from the object's attributes
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="insertQuery" access="private" returntype="void" output="false">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="fields" default="#variables.database_fields#" />

		<cfset var delimiter = "" />

		<cfquery name="InsertData" datasource="#variables.dsn#">
			SET nocount ON		
			INSERT INTO #arguments.table# (#arguments.fields#)
			VALUES (
				<cfloop list="#arguments.fields#" index="field_name">					
					#delimiter#
					<cfqueryparam 
						value="#value(field_name)#" 
						null="#null(field_name)#" 
						cfsqltype="#type(field_name)#" />
					<cfset delimiter = ",">
				</cfloop>
				);
			SET nocount OFF
			
			SELECT SCOPE_IDENTITY() as id;
		</cfquery> 
		
		<cfset this.id = InsertData.id />
	</cffunction>


<!--------------------------------------------------------------------------------------- updateQuery

	Description:	Update an existing record in the database with values read from the object's 
								attributes
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="updateQuery" access="private" returntype="void" output="false">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="fields" default="#variables.database_fields#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
				
		<cfset var delimiter = "" />
		
		<cfquery datasource="#variables.dsn#">
			UPDATE #table#
			SET
			<cfloop list="#fields#" index="field_name">
					#delimiter#[#field_name#] = 
					<cfqueryparam 
						value="#value(field_name)#" 
						null="#null(field_name)#" 
						cfsqltype="#type(field_name)#" />
					<cfset delimiter = ",">
			</cfloop>
			WHERE #arguments.primary_key# = '#Evaluate("this.#arguments.primary_key#")#'
		</cfquery>
	</cffunction>

<!--------------------------------------------------------------------------------------- deleteQuery

	Description:	Delete the record from the database whose ID matches the ID of the current object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="deleteQuery" access="private" returntype="void" output="false">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
		
		<cfquery datasource="#variables.dsn#">
			DELETE FROM #table#
			WHERE #arguments.primary_key# = '#Evaluate("this.#arguments.primary_key#")#'
		</cfquery>
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Helper Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------- injectAttributes

	Description:	Uses the information_schema table to determine the name and data type of each
								column in the table associated with this object.  For each column found, a 
								corresponding attribute is added to the object by inserting it into the "this" 
								structure.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="injectAttributes" access="private" returntype="void" output="false">	
		<cfargument name="dsn" type="string" default="#variables.dsn#" />
		<cfargument name="table_name" type="string" default="#variables.table_name#" />
		
		<cfset var table_columns = "" />
		<cfset variables.database_fields = "" />
		<cfset variables.field_types = StructNew() />
		
		<!--- Get the column names and column types for the table --->
		<cfquery name="table_columns" datasource="#arguments.dsn#" cachedwithin="#CreateTimespan(1,0,0,0)#">
			SELECT 
				column_name, 
				data_type, 
				character_maximum_length, 
				numeric_precision
			FROM information_schema.columns
			WHERE 
				table_name = '#arguments.table_name#'
			AND COLUMNPROPERTY(
				OBJECT_ID(table_name), 
				column_name, 
				'isIdentity') = 0
		</cfquery>
				
		<!--- Loop over each column in the table --->
		<cfloop query="table_columns">
			<!--- 
				The default value for an attribute is an empty string except for money 
				and bit atrributes which default to 0 instead
			--->
			<cfset column_default = "" />
			<cfif table_columns.data_type EQ "money" OR table_columns.data_type EQ "bit">
				<cfset column_default = 0 />
			</cfif>
			
			<!--- Insert the column name into the list of database fields --->
			<cfset variables.database_fields = ListAppend(
				variables.database_fields, 
				table_columns.column_name) />
			
			<!--- Insert the column type structure with the column type --->
			<cfset StructInsert(
				field_types, 
				table_columns.column_name, 
				cf_sql_type(table_columns.data_type), 
				"True") />
				
			<!--- Add the column as an attribute of the object --->
			<cfif NOT structKeyExists(this, table_columns.column_name)>
				<cfset structInsert(this, table_columns.column_name, "", true) />
			</cfif>
		</cfloop>
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- value

	Description:	Given a field name this function returns the corresponding value for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="value" access="private" returntype="string" output="false">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose value we want" />
			
		<cfset var value = StructFind(this, arguments.field_name) />
		<cfset var type = type(arguments.field_name) />

		<!--- If the value is a date we must convert it to an ODBC date --->
		<cfif (type eq 'cf_sql_time' or type eq 'cf_sql_timestamp' or type eq 'cf_sql_date') and value NEQ "">
			<cfset value = createODBCDate(value) />
		</cfif>
		
		<cfreturn value />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- type

	Description:	Given a field name this function returns the corresponding type for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="type" access="private" returntype="string" output="false">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose type we want" />
		
		<cfset var type = StructFind(variables.field_types, arguments.field_name) />
		
		<cfreturn type />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- null

	Description:	Given a field name this function returns the corresponding null flag for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="null" access="private" returntype="string" output="false">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose null flag we want" />
			
		<cfset var value = value(arguments.field_name) />
		<cfset var type = type(arguments.field_name) />
		<cfset var null = "no" />
		
		<!--- The value is null if it is blank and not a string --->
		<cfif value EQ "" AND type NEQ "cf_sql_varchar">
			<cfset null = "yes" />
		</cfif>
		
		<cfreturn null />
	</cffunction>
	
<!---------------------------------------------------------------------------------------- cf_sql_type

	Description:	Takes in a SQL Server column type and returns the corresponding ColdFusion type
								to be used by the <cfqueryparam> tag.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="cf_sql_type" access="private" returntype="string" output="false">
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