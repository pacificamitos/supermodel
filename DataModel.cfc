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
		<cfargument name="object_name" type="string" required="yes" />
		<cfargument name="object_path" type="string" required="yes" />
		<cfargument name="table_manager" type="supermodel.TableManager" required="yes" />
		<cfargument name="relation_manager" type="supermodel.RelationManager" required="yes" />

		<cfset Super.init(arguments.object_name, arguments.object_path) />
		<cfset variables.table_manager = arguments.table_manager />
		<cfset variables.relation_manager = arguments.relation_manager />
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
	

	


</cfcomponent>