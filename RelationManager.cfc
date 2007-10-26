<cfcomponent>
<!---------------------------------------------------------------------------------------------- init

	Description:	Constructor
			
----------------------------------------------------------------------------------------------------->	

	<cffunction name="init" access="public" returntype="void" output="false">
		<cfset variables.relations = StructNew() />
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
</cfcomponent>