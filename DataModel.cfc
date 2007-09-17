<!--------------------------------------- DataModel -------------------------------------------------

	Description:	Associates the model with a table in the database and reads its attributes from the 
								fields in the table.  Also adds CRUD (Create/Read/Update/Delete) methods to the model
								so that each instance of the model is tied to a single record in the database table.
			
----------------------------------------------------------------------------------------------------->	

<cfcomponent name="DataModel" extends="BaseModel">

<!---------------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating 
								private member variables for each field.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init">
		<cfargument name="dsn" type="string" required="yes" hint="The datasource name" />
		<cfargument name="model_name" type="string" required="yes" />
		<cfargument name="model_path" type="string" required="yes" />
		<cfargument name="table_name" type="string" default="#arguments.model_name#s" />
		
		<cfparam name="This.id" default="" />
		<cfparam name="variables.database_fields" default="" />
		<cfparam name="variables.table_name" default="" />

		<!--- Initiate the BaseModel --->
		<cfset Super.init(model_name, model_path) />
		
		<!--- Set the DSN and indicate which database table we'll be modelling --->
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.table_name = arguments.table_name />
		
		<!--- Create a structure to whole the data type of each field/attribute --->
		<cfset variables.field_types = StructNew() />

		<!--- Initiate all the fields (see the function's description for more info) --->
		<cfset initDatabaseFields() />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- create

	Description:	Inserts a new record into the database with values taken from this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="create" access="public" returntype="any">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before inserting it" />
		
		<cfif isDefined("arguments.params")>
			<cfinvoke method="load" params="#params#" />
		</cfif>
		
		<cfif valid()>		
				<cfset insertQuery() />
		</cfif>

		<cfreturn This />
	</cffunction>

<!---------------------------------------------------------------------------------------------- read

	Description:	Takes in an ID and reads the data from the database into this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="read" access="public">
		<cfargument name="id" required="yes" />
		<cfset This.id = arguments.id />
		
		<cfif NOT IsNumeric(This.id)>
			<cfreturn This />
		</cfif>
		
		<cfquery name="SelectObject" datasource="#variables.dsn#">
		SELECT * FROM #variables.table_name#
		WHERE #variables.table_name#.#variables.primary_key# = #This.id#
		</cfquery>

		<cfset params = StructNew() />
		<cfif SelectObject.recordcount EQ 1>
			<cfloop list="#SelectObject.columnlist#" index="column">
				<cfset StructInsert(params, column, Evaluate("SelectObject.#column#"), "True") />
			</cfloop>
		</cfif>
				
 		<cfset load(params) />

		<cfreturn This />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------- update

	Description: Saves the content of the current object into the database.
				
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="update" access="public" output="false" returntype="void">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before update it" />
		
		<cfif isDefined(arguments.params)>
			<cfinvoke method="load" params="#params#" />
		</cfif>
		
		<cfif valid()>
			<cfset updateQuery() />			
		</cfif>
	</cffunction>

<!--------------------------------------------------------------------------------------------- delete

	Description: Deletes the current record from the database and clears the model.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="delete" access="public">
		<cfinvoke method="deleteQuery" />
		<cfinvoke method="clear" />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Query Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------- insertQuery

	Description:	Insert a new record into the database with values read from the object's attributes
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="insertQuery" output="false">
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
		
		<cfset This.id = InsertData.id />
	</cffunction>


<!--------------------------------------------------------------------------------------- updateQuery

	Description:	Update an existing record in the database with values read from the object's 
								attributes
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="updateQuery">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="fields" default="#variables.database_fields#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
				
		<cfset var delimiter = "" />
		
		<cfquery datasource="#variables.dsn#">
			UPDATE #table#
			SET
			<cfloop list="#fields#" index="field_name">
					#delimiter##field_name# = 
					<cfqueryparam 
						value="#value(field_name)#" 
						null="#null(field_name)#" 
						cfsqltype="#type(field_name)#" />
					<cfset delimiter = ",">
			</cfloop>
			WHERE #arguments.primary_key# = '#Evaluate("This.#arguments.primary_key#")#'
		</cfquery>
	</cffunction>

<!--------------------------------------------------------------------------------------- deleteQuery

	Description:	Delete the record from the database whose ID matches the ID of the current object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="deleteQuery">
		<cfargument name="table" default="#variables.table_name#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />
		
		<cfquery datasource="#variables.dsn#">
			DELETE FROM #table#
			WHERE #arguments.primary_key# = '#Evaluate("This.#arguments.primary_key#")#'
		</cfquery>
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Database Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------- initDatabaseFields

	Description:	Uses the information_schema table to determine the name and data type of each
								column in the table associated with this model.  For each column found, a 
								corresponding attribute is added to the model by inserting it into the "This" 
								structure.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="initDatabaseFields">
		<cfargument name="table_name" default="#variables.table_name#" />

		<!--- Get the column names and column types for the table --->
		<cfquery name="GetColumns" datasource="#variables.dsn#" cachedwithin="#CreateTimespan(1,0,0,0)#">
			SELECT column_name, data_type, character_maximum_length, numeric_precision
			FROM information_schema.columns
			WHERE(table_name = '#arguments.table_name#')
			AND COLUMNPROPERTY(OBJECT_ID(table_name), column_name, 'isIdentity') = 0
		</cfquery>
				
		<!--- Loop over each column in the table --->
		<cfloop query="GetColumns">
			<!--- 
				The default value for an attribute is an empty string except for money 
				and bit atrributes which default to 0 instead
			--->
			<cfset column_default = "" />
			<cfif GetColumns.data_type EQ "money" OR GetColumns.data_type EQ "bit">
				<cfset column_default = 0 />
			</cfif>
			
			<!--- Insert the field name into the list of database fields --->
			<cfset variables.database_fields = ListAppend(variables.database_fields, GetColumns.column_name) />
			
			<!--- Populate the field_types structure with the column type --->
			<cfset StructInsert(
				variables.field_types, 
				GetColumns.column_name, 
				cf_sql_type(GetColumns.data_type), 
				"True") />
			
			<!--- 
				Populate this object itself with an attribute that 
				has the same name as the database column name 
			--->
			<cfset StructInsert(
				This, 
				GetColumns.column_name, 
				column_default, 
				"True") />
		</cfloop>
		
		<!--- 
			Determine the primary key of the table.  Compound primary 
			keys are not supported at this time.
		--->
		<cfquery name="getPK" datasource="#request.dsn#" cachedwithin="#CreateTimespan(1,0,0,0)#">
			SELECT col.column_name 
			FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tab   
			INNER JOIN   INFORMATION_SCHEMA.KEY_COLUMN_USAGE col   
				ON tab.constraint_name = col.constraint_name 
			WHERE tab.table_name = '#variables.table_name#' 
			AND constraint_type = 'PRIMARY KEY'
		</cfquery>
		
		<!--- Save the primary key in a private variable --->
		<cfset variables.primary_key = ValueList(getPK.Column_Name,',') />
	</cffunction>
	
<!--------------------------------------------------------------------------------------------- value

	Description:	Given a field name this function returns the corresponding value for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="value">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose value we want" />
			
		<cfset var value = StructFind(This, arguments.field_name) />
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

	<cffunction name="type">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose type we want" />
		
		<cfset var type = StructFind(variables.field_types, arguments.field_name) />
		
		<cfreturn type />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- null

	Description:	Given a field name this function returns the corresponding null flag for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="null">
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