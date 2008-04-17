<!--- This component can be used to elegantly construct a list of conditions for a WHERE clause --->

<cfcomponent>
	<cfparam name="Variables.conditions" default="1=1" />
	
<!----------------------------------------------------------------------------------------------- add

	Description:	Adds a condition for inserting into the WHERE clause of a SELECT statement
	
	Arguments:		column - The database column name and the name of the Request variable
								type - The data type of the value
								operator - A comparison operator
								value - The value to restrict the column
								table - Table that the column belongs to
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="add">
		<cfargument name="column" required="yes" />
		<cfargument name="type" default="integer" />
		<cfargument name="operator" default="=" />
		<cfargument name="value" default="" />
		<cfargument name="table" default="" />
		<cfargument name="structure" default="#Request#" />
		<cfargument name="check_type" default="yes" />
			
		<cfif Arguments.value EQ "" AND StructKeyExists(Arguments.structure, Arguments.column)>
			<cfset Arguments.value = StructFind(Arguments.structure, Arguments.column) />
			<cfif isDefined("Arguments.structure.Field_Types")>
				<cfset type = StructFind(Arguments.structure.Field_Types,Arguments.column) />
			</cfif>
			<cfif Arguments.value neq "">
				<cfif type EQ "cf_sql_timestamp">
					<cfset Arguments.value = ParseDateTime(Arguments.value) />
				<cfelseif NOT (isNumeric(Arguments.value) OR isDate(Arguments.value))>
					<cfset Arguments.value ="'#Arguments.value#'" />
				</cfif>
			</cfif>
		</cfif>
		
		<cfif Arguments.table NEQ "">
			<cfset Arguments.column = Arguments.table & "." & Arguments.column />
		</cfif>
		
		<cfif (Arguments.value NEQ "") AND ((NOT Arguments.check_type) OR IsValid(Arguments.type, Arguments.value)) >
			<cfset Variables.conditions = Variables.conditions & " AND #Arguments.column# #operator# #Arguments.value#" />
		</cfif>
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- get

	Description:	Gets the conditions string
	
	Arguments:		None
				
	Return Value:	The string of conditions to be placed after the WHERE keyword
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="get">	
		<cfreturn preserveSingleQuotes(Variables.conditions) />
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- set

	Description:	Sets the initial condition appearing after the WHERE keyword
	
	Arguments:		conditions - The initial condition string
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="set">
		<cfargument name="conditions" required="yes" />
		
		<cfset Variables.conditions = Arguments.conditions />
	</cffunction>
	
</cfcomponent>