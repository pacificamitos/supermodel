<cfcomponent>
<!---------------------------------------------------------------------------------- manyToManySelect

	Description:	This function performs a SELECT query from a foreign table
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
</cfcomponent>