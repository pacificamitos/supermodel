<cfcomponent>

<!---------------------------------------------------------------------------------------------- init

	Description:	Constructor
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	
<!------------------------------------------------------------------------------ getDatabaseAttributes

	Description: Returns a structure of those attribute key/value pairs which come from the database
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="getDatabaseAttributes" access="public" returntype="struct">
		<cfargument name="object" type="supermodel.DataModel" required="yes" />
		
		<cfset var attributes = StructNew() />
		<cfloop list="#variables.database_fields#" index="field">
			<cfset StructInsert(attributes, field, this[field]) />
		</cfloop>
		
		<cfreturn attributes />
	</cffunction>
	
<!---------------------------------------------------------------------------------- injectAttributes

	Description:	Uses the information_schema table to determine the name and data type of each
								column in the table associated with this object.  For each column found, a 
								corresponding attribute is added to the object by inserting it into the "this" 
								structure.
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="injectAttributes" access="public" returntype="void">
		<cfargument name="object" type="supermodel.DataModel" required="yes" />
		
		<cfset var field_types = StructNew() />
		<cfset var database_fields = "" />
		<cfset var table_columns = "" />
		
		<!--- Get the column names and column types for the table --->
		<cfquery name="table_columns" datasource="#variables.dsn#" cachedwithin="#CreateTimespan(1,0,0,0)#">
			SELECT 
				column_name, 
				data_type, 
				character_maximum_length, 
				numeric_precision
			FROM information_schema.columns
			WHERE 
				table_name = '#object.getTableName()#'
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
			<cfset database_fields = ListAppend(
				database_fields, 
				table_columns.column_name) />
			
			<!--- Insert the column type structure with the column type --->
			<cfset StructInsert(
				field_types, 
				table_columns.column_name, 
				cf_sql_type(table_columns.data_type), 
				"True") />
				
			<!--- Add the column as an attribute of the object --->
			<cfset object.addAttribute(
				name = table_columns.column_name, 
				scope = 'public') />
		</cfloop>
		
		<cfset object.database_fields = database_fields />
	</cffunction>
	
<!-------------------------------------------------------------------------------------------------->
<!-------------------------------------- Accessor Functions ---------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- setDSN

	Description:	Sets the DSN to be used for all queries to the database
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="setDSN" access="private" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />
		
		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	
<!-------------------------------------------------------------------------------------- setTableName

	Description:	Sets the database table that the object represents
			
---------------------------------------------------------------------------------------------------->	

	<cffunction name="setTableName" access="private" returntype="void">
		<cfargument name="table_name" type="string" required="yes" />
		
		<cfset variables.table_name = arguments.table_name />
	</cffunction>
	
<!----------------------------------------------------------------------------------------- setObject

	Description:	Sets the database table that the object represents
			
---------------------------------------------------------------------------------------------------->	
	
	<cffunction name="setObject">
		<cfargument name="object">
		<cfset variables.object = arguments.object />
	</cffunction>
	

</cfcomponent>