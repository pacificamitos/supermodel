<!--------------------------------------- model -----------------------------------------------

	Description:	Adds CRUD (Create/Read/Update/Delete) methods to the object so that each instance
								of the object is tied to a single record in the database table.

---------------------------------------------------------------------------------------------->

<cfcomponent>

<!-------------------------------------------------------------------------------------------->
<!----------------------------------- Core Functions ----------------------------------------->
<!-------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------------- init

	Description:	Constructs the object by reading all the columns from the database and creating
								private member variables for each field.

---------------------------------------------------------------------------------------------->

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset variables.collections = '' />
		<cfset this.errors  = structNew() />
		<cfset this.parents = structNew() />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.primary_key = 'id' />
		<cfset configure() />
	</cffunction>

<!---------------------------------------------------------------------------------------- load

	Description: Loads values from the given data structure into corresponding fields in the object

---------------------------------------------------------------------------------------------->

	<cffunction name="load" access="public"  returntype="void">
		<cfargument	name="data" required="yes" type="any" />
		<cfargument name="fields"	default="" type="string" />

		<cfset var key = "" />
		<cfset var params = structNew() />
		<cfset var params_key = "" />
		<cfset var prefix_stripped = true />
		<cfset var query = "" />
		<cfset var num_updated_fields = 0 />

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
				The columns may be prefixed if they are part of a JOIN in which case 'id' might be
				something like 'position_id' or 'name' might be 'position_name' in the query.  In
				this case, the key we use to index the object must have the prefix stripped off.
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


<!---------------------------------------------------------------------------------------- save

	Description:	If the object has a value for its id then the record will be updated otherwise
                a new record will be created.

---------------------------------------------------------------------------------------------->

  <cffunction name="save" access="public" returntype="boolean">
		<cfif NOT persisted()>
			<cfreturn create() />
  	<cfelse>
    	<cfreturn update()>
    </cfif>
  </cffunction>

<!-------------------------------------------------------------------------------------- create

	Description:	Inserts a new record into the database with values taken from this object.

---------------------------------------------------------------------------------------------->

	<cffunction name="create" access="public" returntype="boolean">
		<cfargument name="params" required="no" type="struct"
			hint="A params struct can be used to load new values into the object before inserting it" />

		<cfif structKeyExists(arguments, 'params')>
			<cfset load(arguments.params) />
		</cfif>
		<cfset validate() />
		<cfif valid()>
				<cfset insertQuery() />
				<cfset read(this.id) />
        <cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

<!---------------------------------------------------------------------------------------- read

	Description:	Takes in an ID and reads the data from the database into this object.

---------------------------------------------------------------------------------------------->

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
 
<!-------------------------------------------------------------------------------------- update

	Description: Saves the content of the current object into the database.

---------------------------------------------------------------------------------------------->

	<cffunction name="update" access="public" returntype="boolean">
		<cfargument name="params" required="no" type="struct" />

		<cfif structKeyExists(arguments, 'params')>
			<cfset load(arguments.params) />
		</cfif>
		<cfset validate() />
		<cfif valid()>
			<cfset updateQuery() />
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

<!-------------------------------------------------------------------------------------- delete

	Description: Deletes the current record from the database and clears the object.

---------------------------------------------------------------------------------------------->

	<cffunction name="delete" access="public" returntype="void">
		<cfinvoke method="deleteQuery" />
	</cffunction>

<!-------------------------------------------------------------------------------------------->
<!---------------------------------- Relationship Helpers ------------------------------------>
<!-------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------- hasMany

	Description:	Takes in a component path and sets up an objectList of those components

---------------------------------------------------------------------------------------------->

	<cffunction name="hasMany" access="private" returntype="void">
		<cfargument name="name" type="string" required="yes" />
		<cfargument name="component" type="string" required="yes" />
		<cfargument name="prefix" type="string" required="yes" />

		<cfset var object_name = ListLast(arguments.component, '.') />
		<cfset var object_list = '' />

		<cfif not structKeyExists(request, arguments.component)>
			<cfset structInsert(request,
                          arguments.component,
                          createObject('component', arguments.component)) />
			<cfset request[arguments.component].init(variables.dsn) />
		</cfif>

		<cfset request[arguments.component].prefix = arguments.prefix & '_' />
		<cfset request[arguments.component].group_by = request[arguments.component].prefix & 'id' />

		<cfset object_list = createObject('component', 'supermodel2.list') />
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

<!----------------------------------------------------------------------------------- belongsTo

	Description:

---------------------------------------------------------------------------------------------->

	<cffunction name="belongsTo" access="private" returntype="void">
		<cfargument name="name" type="string" required="yes" />
		<cfargument name="component" type="string" required="no" />

    <cfif not structKeyExists(arguments, 'component')>
      <cfset arguments['component'] = replace(getMetaData(this).name,
                                              listLast(getMetaData(this).name, "."),
                                              arguments['name']) />
    </cfif>

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

		<cfset variables.children = listAppend(variables.children, arguments.name) /> </cffunction>

<!-------------------------------------------------------------------------------------------->
<!---------------------------------------- Accessors ----------------------------------------->
<!-------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------ validate

	Description: Runs the object's validation criteria

---------------------------------------------------------------------------------------------->

	<cffunction name="validate" access="public" returntype="void">
    <!--- Implemented in child --->
	</cffunction>

<!----------------------------------------------------------------------------------- hasErrors

	Description: Validates the object's attributes

---------------------------------------------------------------------------------------------->

	<cffunction name="hasErrors" access="public" returntype="boolean">
		<cfreturn not valid() />
	</cffunction>

<!--------------------------------------------------------------------------------------- valid

	Description: Validates the object's attributes

---------------------------------------------------------------------------------------------->

	<cffunction name="valid" access="public" returntype="boolean">
		<cfreturn structIsEmpty(this.errors) />
	</cffunction>

<!----------------------------------------------------------------------------------- persisted

	Description: Returns true if the object is currently tied to a database record

---------------------------------------------------------------------------------------------->

	<cffunction name="persisted" access="public" returntype="boolean">
		<cfreturn structKeyExists(this, 'id') AND this.id NEQ "" AND this.id NEQ 0>
	</cffunction>

<!------------------------------------------------------------------------------------- getArgs

	Description:

---------------------------------------------------------------------------------------------->

	<cffunction name="getArgs" access="public" returntype="struct">
		<cfreturn variables.database_fields />
	</cffunction>


<!-------------------------------------------------------------------------------------------->
<!---------------------------------- Basic Query Functions ----------------------------------->
<!-------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------- selectQuery

	Description:	Private function that executes a SELECT SQL query

---------------------------------------------------------------------------------------------->

  <cffunction name="selectQuery" access="private" returntype="query">
		<cfargument name="columns" default="*" />
		<cfargument name="tables" />
		<cfargument name="conditions" default="" />
		<cfargument name="ordering" default="" />

		<cfset var query  = "" />
    <cfif not IsStruct(variables.database_fields)>
      <cfreturn />
    </cfif>
    <cfset props = variables.database_fields />
    <cfset props_keys = StructKeyArray(props) />

    <cfif arguments.columns eq "*">
      <!--- If default, create the amalgamated list of column names --->
      <cfset arguments.columns = "" />
      <cfloop index="i" from="1" to="#ArrayLen(props_keys)#">
          <cfset table = props_keys[i] />
          <cfset list = StructFind(props, table) />
          <cfloop list="#list#" index="column_name">
            <cfset arguments.columns = ListAppend(arguments.columns, "#table#.#column_name#") />
          </cfloop>
      </cfloop>
    </cfif>

    <cfif not IsDefined('arguments.tables')>
      <!--- If default, create joined list of tables --->
      <cfset arguments.tables = "" />
      <cfloop index="k" from="2" to="#ArrayLen(props_keys)#">
        <cfset new_string = " INNER JOIN " & props_keys[k] & " ON " />
        <cfset new_string = new_string & props_keys[1] & "." & variables.primary_key & " = " />
        <cfset new_string = new_string & props_keys[k] & "." & variables.primary_key />
        <cfset arguments.tables = arguments.tables & new_string />
      </cfloop>
      <cfset arguments.tables = props_keys[1] & arguments.tables />
    </cfif>

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

<!--------------------------------------------------------------------------------- insertQuery

	Description:	Insert a new record into the database with values read from the object's
					attributes

---------------------------------------------------------------------------------------------->

	<cffunction name="insertQuery" access="private" returntype="void">
		<cfargument name="table" required="no"/>
		<cfargument name="fields" required="no"/>

		<cfset var delimiter = "" />

    <cfset var props = variables.database_fields />

    <cfif IsDefined('arguments.table')>
      <cfset table_name = arguments.table />
    <cfelse>
      <!--- If table is not passed in, assume tables listed in properties --->
      <cfset table_name = ListGetAt(variables.tables, 1) />
    </cfif>

    <cfif IsDefined('arguments.fields')>
      <cfset cols = arguments.fields />
    <cfelse>
      <!--- Get fields from the properties struct --->
      <cfset cols = StructFind(props, table_name) />
    </cfif>

    <!--- Insert into the first table in the list to get the primary key --->
    <cfquery name="primary_query" datasource="#variables.dsn#">
      SET nocount ON
      INSERT INTO #table_name# (#cols#)
        VALUES (
          <cfloop list="#cols#" index="field_name">
            #delimiter#
            <cfset delimiter = ",">
            <cfqueryparam
              value="#value(field_name)#"
              null="#null(field_name)#"
              cfsqltype="#type(field_name)#" />
            <cfset delimiter = ",">
          </cfloop>
        )
        SET nocount OFF

        SELECT SCOPE_IDENTITY() AS id;
    </cfquery>

    <cfif not IsDefined('arguments.table')>

      <!--- If no table was specified, insert into the rest of the tables using the
            same key --->
      <cfset rest_tables = ListRest(variables.tables) />
      <cfif listLen(rest_tables) gt 0>

       <cfquery name="query" datasource="#variables.dsn#">
         <cfloop list="#rest_tables#" index="table_name">
           <cfset cols = StructFind(props, table_name) />
           <cfset delimiter = "" />
           SET nocount ON
           INSERT INTO #table_name# (id <cfif cols neq "">, #cols#</cfif>)
           VALUES (
             <cfqueryparam
               value="#primary_query.id#"
               cfsqltype="cf_sql_integer" />
             <cfloop list="#cols#" index="field_name">
               , <cfqueryparam
                 value="#value(field_name)#"
                 null="#null(field_name)#"
                 cfsqltype="#type(field_name)#" />
             </cfloop>
           )
           SET nocount OFF
         </cfloop>
       </cfquery>
      </cfif>
    </cfif>

    <cfset this.id = primary_query.id />
	</cffunction>


<!--------------------------------------------------------------------------------- updateQuery

	Description:	Update an existing record in the database with values read from the object's
								attributes

---------------------------------------------------------------------------------------------->

	<cffunction name="updateQuery" access="private" returntype="void">
		<cfargument name="tables" required="no" default="#variables.tables#" />
		<cfargument name="fields" required="no" />
		<cfargument name="primary_key" default="#variables.primary_key#" />

		<cfset var delimiter = "" />

    <cfset props = variables.database_fields />

    <cfquery name="query" datasource="#variables.dsn#">
      <cfloop list="#tables#" index="table_name">
        <cfset delimiter = "" />
        <cfif not IsDefined('arguments.fields')>
          <cfset cols = StructFind(props,table_name) />
        </cfif>
        UPDATE #table_name#
        SET
        <cfloop list="#cols#" index="field_name">
            #delimiter#[#field_name#] =
            <cfqueryparam
              value="#value(field_name)#"
              null="#null(field_name)#"
              cfsqltype="#type(field_name)#" />
            <cfset delimiter = ",">
        </cfloop>
        WHERE #arguments.primary_key# = '#Evaluate("this.#arguments.primary_key#")#'
      </cfloop>
    </cfquery>

	</cffunction>

<!--------------------------------------------------------------------------------- deleteQuery

	Description:	Delete the record from the database whose ID matches the ID of the current
					object.

---------------------------------------------------------------------------------------------->

	<cffunction name="deleteQuery" access="private" returntype="void">
		<cfargument name="tables" default="#variables.tables#" />
		<cfargument name="primary_key" default="#variables.primary_key#" />

		<cfquery datasource="#variables.dsn#">
		  <cfloop list="#arguments.tables#" index="table_name">	
        DELETE FROM #table_name#
		 	  WHERE #arguments.primary_key# = '#Evaluate("this.#arguments.primary_key#")#'
		  </cfloop>
    </cfquery><!---either i put back the list thing, or i separate the --->
	</cffunction>

<!-------------------------------------------------------------------------------------------->
<!------------------------------------ Helper Functions -------------------------------------->
<!-------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------ property

	Description:  This function is used to manually add properties to a model rather than
                introspecting them from the database information_schema.

---------------------------------------------------------------------------------------------->

  <cffunction name="property" access="private" returntype="void">
    <cfargument name="name" type="string" required="yes" />
    <cfargument name="type" type="string" required="yes" />
    <!--- Determise whether arg is persisted in the db. Deprecated --->
    <cfargument name="persisted" type="boolean" required="no" default="yes" />

    <cfset structInsert(this, arguments.name, "", true) />

    <cfparam name="variables.field_types" default="#StructNew()#" />

    <cfset structInsert(variables.field_types,
                        arguments.name,
                        cf_sql_type(arguments.type),
                        true) />
    <!--- Add argument to the persisted fields list unless otherwise noted;
          this should be deprecated --->
    <cfif arguments.persisted>
      <cfset persist(arguments.name) />
    </cfif>
  </cffunction>

  <cffunction name="table" access="private" returntype="void">
    <cfargument name="name" type="string" required="yes" />

    <cfset variables.table_name = arguments.name />
  </cffunction>

  <cffunction name="default" access="private" returntype="void">
    <cfargument name="property" type="string" required="yes" />
    <cfargument name="value" type="string" required="yes" />

    <cfset this[arguments.property] = arguments.value />
  </cffunction>

  <cffunction name="persist" access="private" returntype="void">
    <cfargument name="persisted_fields" type="string" required="yes" />
    
    <cfparam name="variables.database_fields" default="#StructNew()#" />
    <cfparam name="variables.tables" default="" />
   
    <!--- Record the table_name if it's not in there already --->
    <cfif not ListFindNoCase(variables.tables, variables.table_name, ',')>
      <cfset variables.tables = ListAppend(variables.tables, variables.table_name) />
    </cfif>

    <!--- Insert the property into the fields struct according to what table
          it belongs to --->
    <!--- remove 'id' field --->
    <cfset args = REReplaceNoCase(arguments.persisted_fields, '\bid\b', '', 'all') />
    <cfif StructKeyExists(variables.database_fields, variables.table_name)>
      <cfset list = StructFind(variables.database_fields, variables.table_name) />
    <cfelse>
      <cfset list = "" />
    </cfif>

    <cfset list = ListAppend(list, args) />

    <!--- Remove duplicates --->
    <cfset temp_struct = StructNew() />
    <cfloop list="#list#" index="i" delimiters=",">
      <cfset temp_struct[i]="" />
    </cfloop>
    <cfset list = StructKeyList(temp_struct) />

    <cfset StructInsert(variables.database_fields,
                        variables.table_name,
                        list,
                        true) />
  </cffunction>

<!--------------------------------------------------------------------------------------- value

	Description:	Given a field name this function returns the corresponding value for the
								<cfqueryparam> tag

---------------------------------------------------------------------------------------------->

	<cffunction name="value" access="private" returntype="string">
		<cfargument name="field_name" type="string" required="yes"
			hint="The field whose value we want" />

		<cfset var value = StructFind(this, arguments.field_name) />
		<cfset var type = type(arguments.field_name) />

		<!--- If the value is a date we must convert it to an ODBC date --->
		<cfif isDate(value) 
          OR (type eq 'cf_sql_time' or type eq 'cf_sql_timestamp' or type eq 'cf_sql_date') 
          AND value NEQ "">
			<cfset value = makeDate(value) />
		</cfif>

		<cfreturn value />
	</cffunction>

<!------------------------------------------------------------------------------------ makeDate

	Description:	Tries to convert a string into a date that can be inserted into the database

---------------------------------------------------------------------------------------------->

	<cffunction name="makeDate" access="private" returntype="string">
		<cfargument name="value" type="string" required="yes" />

		<!--- First, see if we can create a valid date right off the bat --->
		<cftry>
			<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") 
                     & " " 
                     & LSTimeFormat(value, "HH:mm:ss")) />
			<cfcatch>
				<!--- Next, try parsing the value as a timestamp formatted in the current locale --->
				<cftry>
					<cfset value = LSParseDateTime(value) />
					<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") 
                         & " " 
                         & LSTimeFormat(value, "HH:mm:ss")) />

					<!--- Finally, try assuming that it's a timestamp string that's not formatted for 
                the current locale --->
					<cfcatch>
						<cfset value = ParseDateTime(value) />
						<cfset value = createODBCDateTime(LSDateFormat(value, "yyyy-mm-dd") 
                           & " " 
                           & LSTimeFormat(value, "HH:mm:ss")) />
					</cfcatch>
				</cftry>
			</cfcatch>
		</cftry>

		<cfreturn value />
	</cffunction>

<!---------------------------------------------------------------------------------------- type

	Description:	Given a field name this function returns the corresponding type for the
								<cfqueryparam> tag

---------------------------------------------------------------------------------------------->

	<cffunction name="type" access="private" returntype="string">
		<cfargument name="field_name" type="string" required="yes"
			hint="The field whose type we want" />

		<cfset var type = StructFind(variables.field_types, arguments.field_name) />

		<cfreturn type />
	</cffunction>

<!---------------------------------------------------------------------------------------- null

	Description:	Given a field name this function returns the corresponding null flag for the
								<cfqueryparam> tag

---------------------------------------------------------------------------------------------->

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

<!--------------------------------------------------------------------------------- cf_sql_type

	Description:	Takes in a SQL Server column type and returns the corresponding ColdFusion type
								to be used by the <cfqueryparam> tag.

---------------------------------------------------------------------------------------------->

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

<!--------------------------------------------------------------------------------- rowToStruct

	Description:

---------------------------------------------------------------------------------------------->

	<cffunction name="rowToStruct" access="private" returntype="struct">
		<cfargument name="query" type="query" required="yes" />

		<cfset var struct = structNew() />

		<cfloop list="#query.columnlist#" index="column">
			<cfset struct[column] = query[column][query.currentrow] />
		</cfloop>

		<cfreturn struct />
	</cffunction>

</cfcomponent>
