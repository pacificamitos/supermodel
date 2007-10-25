<!--------------------------------------- DataModel -------------------------------------------------

	Description:	Associates the object with a table in the database and reads its attributes from the 
								fields in the table.  Also adds CRUD (Create/Read/Update/Delete) methods to the object
								so that each instance of the object is tied to a single record in the database table.
			
----------------------------------------------------------------------------------------------------->	

<cfcomponent name="DataModel" extends="supermodel.SuperModel">

<!---------------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating 
								private member variables for each field.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="object_name" type="string" required="yes" />
		<cfargument name="object_path" type="string" required="yes" />
		<cfargument name="gateway" type="supermodel.gateway" required="no" />
			
		<cfset variables.table_name = "" />
		<cfset variables.relations = StructNew() />

		<!--- Initiate the SuperModel --->
		<cfset Super.init(arguments.object_name, arguments.object_path) />
		
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.table_name = arguments.table_name />
		
		<!--- Create a structure to hold the data type of each field/attribute --->
		<cfset variables.field_types = StructNew() />

		<!--- Initiate all the fields (see the function's description for more info) --->
		<cfset initDatabaseFields() />
	</cffunction>
	 
<!---------------------------------------------------------------------------------------------- save

	Description:	If the object has a value for its id then the record will be updated otherwise
                a new record will be created.
			
----------------------------------------------------------------------------------------------------->	
  
  <cffunction name="save" access="public" returntype="void" output="false">   
    <cfif this.id EQ "">
      <cfset create()>
    <cfelse>
      <cfset update()>
    </cfif>
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

		<cfreturn this />
	</cffunction>

<!---------------------------------------------------------------------------------------------- read

	Description:	Takes in an ID and reads the data from the database into this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="read" access="public">
		<cfargument name="id" required="yes" />
		<cfset this.id = arguments.id />
		
		<cfif NOT IsNumeric(this.id)>
			<cfreturn this />
		</cfif>
		
		<cfquery name="SelectObject" datasource="#variables.dsn#">
		SELECT * FROM #variables.table_name#
		WHERE #variables.table_name#.#variables.primary_key# = #this.id#
		</cfquery>

		<cfset params = StructNew() />
		<cfif SelectObject.recordcount EQ 1>
			<cfloop list="#SelectObject.columnlist#" index="column">
				<cfset StructInsert(params, column, Evaluate("SelectObject.#column#"), "True") />
			</cfloop>
		</cfif>
				
 		<cfset load(params) />
		<cfset loadRelationData() />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------- update

	Description: Saves the content of the current object into the database.
				
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="update" access="public" output="false" returntype="void">
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

	<cffunction name="delete" access="public">
		<cfinvoke method="deleteQuery" />
		<cfinvoke method="clear" />
	</cffunction>
	
<!------------------------------------------------------------------------------------------ persisted

	Description: Returns true if the object is currently tied to a database record
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="persisted" access="public" output="false" returntype="boolean">
		<cfreturn this.id NEQ "">
	</cffunction>
	
<!------------------------------------------------------------------------------ getDatabaseAttributes

	Description: Returns a structure of those attribute key/value pairs which come from the database
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="getDatabaseAttributes" access="public" output="false" returntype="struct">
		<cfset var attributes = StructNew() />
		<cfloop list="#variables.database_fields#" index="field">
			<cfset StructInsert(attributes, field, this[field]) />
		</cfloop>
		
		<cfreturn attributes />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Relational Functions --------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------------------- get

	Description:	Gets a query of data based on the name of a foreign key relation
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="get" access="public" returntype="query" output="false">
		<cfargument name="relation_name" type="string" required="yes" />
		<cfset loadRelationData(relation_name) />
		<cfreturn this[arguments.relation_name] />
	</cffunction>

<!------------------------------------------------------------------------------------------- hasMany

	Description:	Used to indicate that the object should contain a collection of foreign objects.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="hasMany" access="private" returntype="void" output="false">
		<cfargument name="foreign_table" type="string" required="yes" />
		<cfargument name="foreign_key" type="string" required="yes" />
		<cfargument name="join_table" type="string" required="no" />
		<cfargument name="join_key" type="string" required="no" />
		<cfargument name="join_columns" type="string" required="no" />
		
		<cfset StructInsert(variables.relations, arguments.foreign_table, arguments) />
		

		<cfset StructInsert(this, foreign_table, manyToManySelect(argumentcollection = arguments)) />
	</cffunction>		
	
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Basic Query Functions -------------------------------------->
<!-------------------------------------------------------------------------------------------------->

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
<!--------------------------------- Relational Query Functions ------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!---------------------------------------------------------------------------------- manyToManySelect

	Description:	This helper function performs a SELECT query from a foreign table
								to get the foreign records associated with the current object.
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="selectMany">
		<cfargument name="foreign_table" type="string" required="yes" />
		<cfargument name="foreign_key" type="string" required="yes" />
		<cfargument name="join_table" type="string" required="yes" />
		<cfargument name="join_key" type="string" required="yes" />
		<cfargument name="join_columns" type="string" required="no" />
		
		<cfquery name="SelectItems" datasource="#variables.dsn#">
			<!--- Select all columns from the foreign table --->
			SELECT #arguments.foreign_table#.*
			
			<!--- If there are non-key columns in the join table, select those as well --->
			<cfif join_table_used>
				<cfloop list="#join_columns#" index="join_column">
				, #arguments.join_table#.#join_column#
				</cfloop> 
			</cfif>
			
			FROM #arguments.foreign_table#
			
			<!--- If a join table is specified (manyToMany) then we JOIN on it --->
			<cfif arguments.join_table NEQ "">
			JOIN #arguments.join_table#
			ON #arguments.join_table#.#arguments.foreign_key# = #arguments.foreign_table#.id
			WHERE #arguments.join_table#.#arguments.join_key# = #this.id#
			
			<!--- Otherwise we join directly to the foreign table (oneToMany) --->
			<cfelse>
			WHERE #relation['foreign_table']#.#relation['join_key']# = #this.id#
			</cfif>
		</cfquery>
		
		<cfreturn SelectItems />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Core Functions ------------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------- initDatabaseFields

	Description:	Uses the information_schema table to determine the name and data type of each
								column in the table associated with this object.  For each column found, a 
								corresponding attribute is added to the object by inserting it into the "this" 
								structure.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="initDatabaseFields" access="private" returntype="void" output="false">
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
			<cfset variables.database_fields = ListAppend(
				variables.database_fields, 
				GetColumns.column_name) />
			
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
				this, 
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
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------- Relational Helper Functions ------------------------------------>
<!-------------------------------------------------------------------------------------------------->
	
<!----------------------------------------------------------------------------------- loadRelationData

	Description:	Reads a query of data into an attribute of the object
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="loadRelationData" access="private" returntype="void" output="false">
		<!--- Var scope the local function variables --->
		<cfset var relation = "" />		
		<cfset var relation_name = "" />
		<cfset var join_column = "" />
		<cfset var items = "" />
		
		<!--- Loop over the collection of relations --->
		<cfloop list="#structKeyList(variables.relations)#" index="relation_name">
			<cfset relation = variables.relations[relation_name] />
			<cfset join_table_used = structKeyExists(relation, 'join_table') />

			<cfset items = manyToManySelect(
				relation['foreign_table'],
				relation['foreign_key'],
				relation['join_table'],
				relation['join_key'],
				relation['join_columns']) />
			
			<cfset structInsert(this, relation['foreign_table'], items, true) />
		</cfloop>
	</cffunction>
	
<!----------------------------------------------------------------------------------- saveRelationData

	Description:	Reads a query of data into an attribute of the object
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="saveRelationData" access="private" returntype="void" output="false">		
		<!--- Var scope the local function variables --->
		<cfset var relation = "" />		
		<cfset var relation_name = "" />
		<cfset var query = "" />
		<cfset var join_column = "" />
		<cfset var items = "" />
		
		<!--- Loop over the collection of relations --->
		<cfloop list="#structKeyList(variables.relations)#" index="relation_name">
			<cfset relation = variables.relations[relation_name] />
			<cfset join_table_used = structKeyExists(relation, 'join_table') />

			<!--- Only continue if there is a join table --->
			<cfif join_table_used>			
				<cfquery name="DeleteItems" datasource="#variables.dsn#">
					DELETE FROM user_positions
					WHERE user_positions.position_id = #this.id#
				</cfquery>
				
				<cfset items = this[relation['foreign_table']] />
				<cfloop query="items">
					<cfquery name="InsertItems" datasource="#variables.dsn#">
						INSERT INTO user_positions (
							#relation['join_key']#,
							#relation['foreign_key']#,
						)
						VALUES (
							#this.id#,
							#items.id#)
						)
					</cfquery>
				</cfloop>
			</cfif>
					
				
			<cfquery name="query" datasource="#variables.dsn#">
				<!--- Select all columns from the foreign table --->
				SELECT #relation['foreign_table']#.*
				
				<!--- If there are non-key columns in the join table, select those as well --->
				<cfif join_table_used>
					<cfloop list="#join_columns#" index="join_column">
					, #relation['join_table']#.#join_column#
					</cfloop> 
				</cfif>
				
				FROM #relation['foreign_table']#
				
				<!--- If a join_table is specified (manyToMany) then we JOIN on it --->
				<cfif relation['join_table'] NEQ "">
				JOIN #relation['join_table']#
				ON #relation['join_table']#.#relation['foreign_key']# = #relation['foreign_table']#.id
				WHERE #relation['join_table']#.#relation['join_key']# = #this.id#
				
				<!--- Otherwise we join directly to the foreign table (oneToMany) --->
				<cfelse>
				WHERE #relation['foreign_table']#.#relation['join_key']# = #this.id#
				</cfif>
			</cfquery>
			
			<cfset structInsert(this, relation['foreign_table'], query, true) />
		</cfloop>
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Accessor Functions ---------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- setDSN

	Description:	Sets the DSN to be used for all queries to the database
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="setDSN" access="private" returntype="void" output="false">
		<cfargument name="dsn" type="string" required="yes" />
		
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	
<!-------------------------------------------------------------------------------------- setTableName

	Description:	Sets the database table that the object represents
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="setTableName" access="private" returntype="void" output="false">
		<cfargument name="table_name" type="string" required="yes" />
		
		<cfset variables.table_name = arguments.table_name />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!--------------------------------------- Helper Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!--------------------------------------------------------------------------------------------- value

	Description:	Given a field name this function returns the corresponding value for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="value">
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