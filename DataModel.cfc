<!--------------------------------------- DataModel -------------------------------------------------

	Description:	Adds CRUD (Create/Read/Update/Delete) methods to the object so that each instance of 
								the object is tied to a single record in the database table.
			
----------------------------------------------------------------------------------------------------->	

<cfcomponent name="DataModel" extends="supermodel.SuperModel">
	<cfset this.parents = structNew() />
	
<!---------------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating 
								private member variables for each field.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset variables.collections = '' />
		<cfset super.init() />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.primary_key = 'id' />
		<cfset configure() />
		<cfset injectAttributes() />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- load

	Description:
	
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="load" access="public"  returntype="void">
		<cfargument	name="data" required="yes" type="any" />
		<cfargument name="fields"	default="" type="string" />
		
		<cfset var key = "" />
		<cfset var params = structNew() />
		<cfset var params_key = "" />
		<cfset var prefix_stripped = true />
		<cfset var query = "" />
		<cfset var num_updated_fields = 0 />
				
		<!--- Clear any lazily-initialized variables to force them to be recalculated --->
		<cfset clear() />
		
		<!--- If we've received a recordset, we only need a single row right now --->		
		<cfif isQuery(data)>
			<cfloop list="#data.columnlist#" index="column">
				<cfset params[column] = data[column][1] />
			</cfloop>
		<cfelse>
			<cfset params = arguments.data />
		</cfif>
		
		<cfif arguments.fields EQ "">
			<cfset arguments.fields = structKeyList(params) />
		</cfif>
		
		<!--- 
			Loop over the list of fields and copy them from the params struct 
			into the "this" struct 
		--->
		<cfloop list="#arguments.fields#" index="params_key">
			<cfset prefix_stripped = true />
			<cfset params_key = LCase(params_key) />
			
			<!--- 
				The columns may be prefixed if they are part of a JOIN in which case 'id' might be something 
				like 'position_id' or 'name' might be 'position_name' in the query.  In this case, the key
				we use to index the object must have the prefix stripped off.
			--->
			<cfif structKeyExists(this, 'prefix')>
				<cfset key = Replace(params_key, this.prefix, "") />
				
				<cfif key EQ params_key>
					<cfset prefix_stripped = false />
				</cfif>
			<cfelse>
				<cfset key = params_key />
			</cfif>
			
			<cfif structKeyExists(this, key) AND prefix_stripped>
				<cfif NOT isObject(params[params_key]) AND this[key] NEQ params[params_key]>
					<cfset structInsert(this, key, structFind(params, params_key), true) />
					<cfset num_updated_fields = num_updated_fields + 1 />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- 
			If the load had no effect, we stop now to prevent an infinite loop
		 --->
		<cfif num_updated_fields EQ 0>
			<cfreturn />
		</cfif>

		<!--- 
			Load all the single objects from belongsTo relations
		 --->

		<cfif structKeyExists(variables, 'children')>
			<cfloop list="#variables.children#" index="object">		
				<cfset this[object].load(params) />
			</cfloop>
		</cfif>
		
		<!--- 
			Load all the object lists from hasMany relations
		--->
		
		<cfif structKeyExists(variables, 'collections') AND isQuery(data)>							
			<cfloop list="#variables.collections#" index="collection">
				<cfset this[collection].setQuery(data) />
			</cfloop>
		</cfif>
	</cffunction>

	 
<!---------------------------------------------------------------------------------------------- save

	Description:	If the object has a value for its id then the record will be updated otherwise
                a new record will be created.
			
----------------------------------------------------------------------------------------------------->	
  
  <cffunction name="save" access="public" returntype="void">   
		<cfif NOT persisted()>
      <cfset create()>
    <cfelse>
      <cfset update()>
    </cfif>
  </cffunction>
	
<!--------------------------------------------------------------------------------------------- create

	Description:	Inserts a new record into the database with values taken from this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="create" access="public" returntype="supermodel.DataModel">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before inserting it" />
		
		<cfif structKeyExists(arguments, 'params')>
			<cfset load(arguments.params) />
		</cfif>
		
		<cfif valid()>		
				<cfset insertQuery() />
				<cfset read(this.id) />
		</cfif>

		<cfreturn this />
	</cffunction>

<!---------------------------------------------------------------------------------------------- read

	Description:	Takes in an ID and reads the data from the database into this object.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="read" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="yes" />
		
		<cfset var query = "" />
		<cfset var params = StructNew() />
		<cfset var child_id = "" />
		<cfset var temp_prefix = '' />
		
		<!---
			prefix needs to be deleted for the load function. because the load function will try to 
			load, for example id not process_id.
		--->
		<cfif structKeyExists(this,'prefix')>
			<cfset temp_prefix = this.prefix />
		</cfif>
		
		<cfset this.id = arguments.id />
		<cfset query = selectQuery(conditions = "#table_name#.id = #this.id#") />
		<cfset structDelete(this,'prefix') />
 		<cfset load(rowToStruct(query)) />
		
		<!--- 
			if there was a prefix to begin with, put it back in the object, now that
			the load function has finished executing
		--->
		<cfif temp_prefix neq ''>
			<cfset structInsert(this,'prefix',temp_prefix) />
		</cfif>
		
		<!--- 
			Read all the single objects from belongTo relations
		 --->
		 		
		<cfif structKeyExists(variables, 'children')>
			<cfloop list="#variables.children#" index="object">			
				<cfset child_id = this[this[object].prefix & 'id'] />
				<cfif isNumeric(child_id)>
					<cfset this[object].read(child_id) />
				</cfif>
			</cfloop>
		</cfif>

		<!--- 
			Read all the collections from the hasMany relations
		 --->
		 
		 <cfif structKeyExists(variables, 'collections')>
		 	<cfloop list="#variables.collections#" index="collection">			
				<cfset this[collection].setQuery(query) />
			</cfloop>
		 </cfif>
	</cffunction>
		
<!--------------------------------------------------------------------------------------------- update

	Description: Saves the content of the current object into the database.
				
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="update" access="public" returntype="void">
		<cfargument name="params" required="no" type="struct" />
		
		<cfif structKeyExists(arguments, 'params')>
			<cfset load(arguments.params) />
		</cfif>
		
		<cfif valid()>
			<cfset updateQuery() />			
		</cfif>
	</cffunction>

<!--------------------------------------------------------------------------------------------- delete

	Description: Deletes the current record from the database and clears the object.
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="delete" access="public" returntype="void">
		<cfinvoke method="deleteQuery" />
	</cffunction>
		
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Relationship Helpers --------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!-------------------------------------------------------------------------------------------- hasMany

	Description:	Takes in a component path and sets up an objectList of those components
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="hasMany" access="private" returntype="void">
		<cfargument name="name" type="string" required="yes" />
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="prefix" type="string" required="yes" />

		<cfset var object_name = ListLast(arguments.component, '.') />
		<cfset var object_list = '' />
		
		<cfif not structKeyExists(request, arguments.component)>
			<cfset structInsert(request, arguments.component, createObject('component', arguments.component)) />
			<cfset request[arguments.component].init(variables.dsn) />
		</cfif>
		
		<cfset request[arguments.component].prefix = arguments.prefix & '_' />
		<cfset request[arguments.component].group_by = request[arguments.component].prefix & 'id' />
		
		<cfset object_list = createObject('component', 'supermodel.objectlist') />
		<cfset object_list.init(request[arguments.component], QueryNew('')) />
		<cfset structInsert(this, arguments.name, object_list) />
		
		<cfif NOT structKeyExists(this, 'group_by')>
			<cfset structInsert(this, 'group_by', 'id') />
		</cfif>
		
		<cfif NOT structKeyExists(variables, 'collections')>
			<cfset variables.collections = "" />
		</cfif>
		
		<cfset variables.collections = listAppend(variables.collections, arguments.name) />
	</cffunction>

<!------------------------------------------------------------------------------------------ belongsTo

	Description:
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="belongsTo" access="private" returntype="void">
		<cfargument name="name" type="string" required="yes" />
		<cfargument name="component" type="string" required="yes" />
		
			<cfif structKeyExists(this['parents'], arguments.component)>
				<cfset this[arguments.name] = structFind(this['parents'], arguments.component) />
			<cfelse>
				<cfset structInsert(this, arguments.name, createObject('component', arguments.component), true) />
				<cfset this[arguments.name].init(variables.dsn) />
				<cfset this[arguments.name].prefix = arguments.name & '_' />
				<cfif NOT structKeyExists(this[arguments.name]['parents'], getMetaData(this).name)>
					<cfset structInsert(this[arguments.name]['parents'], getMetaData(this).name, this, true) />
				</cfif>
			</cfif>

		<cfif NOT structKeyExists(variables, 'children')>
			<cfset variables.children = "" />
		</cfif>
		
		<cfset variables.children = listAppend(variables.children, arguments.name) />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------------- Accessors -------------------------------------------->
<!-------------------------------------------------------------------------------------------------->
	
<!------------------------------------------------------------------------------------------ persisted

	Description: Returns true if the object is currently tied to a database record
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="persisted" access="public" returntype="boolean">
		<cfreturn structKeyExists(this, 'id') AND this.id NEQ "" AND this.id NEQ 0>
	</cffunction>
	
<!--------------------------------------------------------------------------------------- getTableName

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="getTableName" access="public" returntype="string">
		<cfreturn variables.table_name />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- getColumns

	Description:
			
----------------------------------------------------------------------------------------------------->
	
	<cffunction name="getColumns" access="public" returntype="string">
		<cfreturn variables.database_fields />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Basic Query Functions -------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------- selectQuery

	Description:	Private function that executes a SELECT SQL query
			
----------------------------------------------------------------------------------------------------->	

<cffunction name="selectQuery" access="private" returntype="query">
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
	
	<cffunction name="insertQuery" access="private" returntype="void">
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

	<cffunction name="updateQuery" access="private" returntype="void">
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
	
	<cffunction name="deleteQuery" access="private" returntype="void">
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
	
	<cffunction name="injectAttributes" access="private" returntype="void">	
		<cfargument name="dsn" type="string" default="#variables.dsn#" />
		<cfargument name="table_name" type="string" default="#variables.table_name#" />
		<cfargument name="field_list" type="string" default="database_fields" />
		
		<cfset var table_columns = "" />
		<cfset variables[arguments.field_list] = "" />
		<cfset variables['field_types'] = StructNew() />
		
		<cfif Find('..', table_name)>
			<cfset table_name = Right(table_name, Len(table_name) - (Find('..', table_name) + 1)) />
		</cfif>

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
			<cfif table_columns.column_name NEQ "id">
				<cfset variables[arguments.field_list] = ListAppend(
					variables[arguments.field_list], 
					table_columns.column_name) />
			</cfif>
			
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

	<cffunction name="value" access="private" returntype="string">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose value we want" />
			
		<cfset var value = StructFind(this, arguments.field_name) />
		<cfset var type = type(arguments.field_name) />

		<!--- If the value is a date we must convert it to an ODBC date --->
		<cfif isDate(value) OR (type eq 'cf_sql_time' or type eq 'cf_sql_timestamp' or type eq 'cf_sql_date') and value NEQ "">
			<cfset value = makeDate(value) />
		</cfif>

		<cfreturn value />
	</cffunction>
	
<!------------------------------------------------------------------------------------------- makeDate

	Description:	Tries to convert a string into a date that can be inserted into the database
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="makeDate" access="private" returntype="string">
		<cfargument name="value" type="string" required="yes" />
		
		<!--- First, see if we can create a valid date right off the bat --->
		<cftry>
			<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") & " " & LSTimeFormat(value, "HH:mm:ss")) />
			<cfcatch>
				<!--- Next, try parsing the value as a timestamp formatted in the current locale --->
				<cftry>
					<cfset value = LSParseDateTime(value) />		
					<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") & " " & LSTimeFormat(value, "HH:mm:ss")) />
					
					<!--- Finally, try assuming that it's a timestamp string that's not formatted for the current locale --->
					<cfcatch>
						<cfset value = ParseDateTime(value) />
						<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") & " " & LSTimeFormat(value, "HH:mm:ss")) />
					</cfcatch>
				</cftry>
			</cfcatch>
		</cftry>
		
		<cfreturn value />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- type

	Description:	Given a field name this function returns the corresponding type for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="type" access="private" returntype="string">
		<cfargument name="field_name" type="string" required="yes" 
			hint="The field whose type we want" />
		
		<cfset var type = StructFind(variables.field_types, arguments.field_name) />
		
		<cfreturn type />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- null

	Description:	Given a field name this function returns the corresponding null flag for the 
								<cfqueryparam> tag
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="null" access="private" returntype="string">
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
	
	<cffunction name="cf_sql_type" access="private" returntype="string">
		<cfargument name="type" required="yes" />
		<cfswitch expression="#type#">
			<cfcase value="int">
				<cfreturn "cf_sql_integer" />
			</cfcase>
			<cfcase value="varchar">
				<cfreturn "cf_sql_varchar" />
			</cfcase>
			<cfcase value="char">
				<cfreturn "cf_sql_char" />
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
	
<!---------------------------------------------------------------------------------------- rowToStruct

	Description:	
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="rowToStruct" access="private" returntype="struct">
		<cfargument name="query" type="query" required="yes" />
		
		<cfset var struct = structNew() />
		
		<cfloop list="#query.columnlist#" index="column">
			<cfset struct[column] = query[column][query.currentrow] />
		</cfloop>
		
		<cfreturn struct />
	</cffunction>
</cfcomponent>
