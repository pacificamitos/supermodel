<cfcomponent name="Attributes">
	<cfparam name="variables.attributes" default="" />
	
<!-------------------------------------------------------------------------------------------- init

	Description:	Initialize the attributes structure from the Arguments collection.  Known arguments
								are ignored while unrecognized arguments are added to the attributes structure.
	
	Arguments:		A structure containing an arbitrary number of Arguments
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="init">
		<cfargument name="reserved_arguments" default="" />

		<!--- Setup a structure to hold the (key,value) attributes for the HTML tag --->
		<cfset variables.attributes = StructNew() />
		
		<!--- Loop over the argument collection and place unrecognized keys into the attributes struct --->
		<cfloop collection="#Arguments#" item="key">
			<cfset key = LCase(key) />
			<cfif key NEQ "reserved_arguments" AND NOT ListFind(arguments.reserved_arguments, key)>
				<cfset StructInsert(variables.attributes, key, StructFind(Arguments, key), "true") />
			</cfif>
		</cfloop>	
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- add

	Description:	Add an attribute to the list if it is not already present.  If the attribute exists
								then it does not get updated.
	
	Arguments:		key - The name of the attribute
								value - The value of the attribute
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="add">
		<cfargument name="key" />
		<cfargument name="value" />
		
		<cfif NOT StructKeyExists(variables.attributes, arguments.key)>
			<cfset StructInsert(attributes, arguments.key, arguments.value) />
		</cfif>
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- get

	Description:	Gets the value of an existing attribute.
	
	Arguments:		key - The name of the attribute
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="get">
		<cfargument name="key" />
		
		<cfif StructKeyExists(attributes, key)>
			<cfreturn StructFind(attributes, key) />
		<cfelse>
			<cfreturn "" />
		</cfif>
		
	</cffunction>
	
<!---------------------------------------------------------------------------------------------- set

	Description:	Sets the value of an existing attribute.
	
	Arguments:		key - The name of the attribute
								value - The value of the attribute
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="set">
		<cfargument name="key" />
		<cfargument name="value" />
		
		<cfset StructInsert(attributes, arguments.key, arguments.value, "true") />
	</cffunction>
<!---------------------------------------------------------------------------------------------- remove

	Description:	Sets the value of an existing attribute.
	
	Arguments:		key - The name of the attribute
								value - The value of the attribute
				
	Return Value:	None
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="remove">
		<cfargument name="key" />
		
		<cfif StructKeyExists(attributes,arguments.key)>
			<cfset StructDelete(attributes, arguments.key) />
		</cfif>
	</cffunction>
		
<!------------------------------------------------------------------------------------------- string

	Description:	Gets the string of attributes.  The string is of the form:
	
								attribute1="value1" attribute2="value2" ...
	
	Arguments:		None
				
	Return Value:	The string of attributes to be placed within the HTML tag
			
----------------------------------------------------------------------------------------------------->

	<cffunction name="string">
		<cfset attribute_string = "" />
		<cfloop collection="#attributes#" item="key">
			<cfif key neq "multiple">
				<cfset attribute_string = attribute_string & ' #key#="#StructFind(attributes,key)#"' />
			</cfif>
		</cfloop>
		
		<cfreturn attribute_string />
	</cffunction>
	
	
</cfcomponent>
