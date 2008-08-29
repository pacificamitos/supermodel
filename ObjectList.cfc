<cfcomponent>

<!-------------------------------------------------------------------------------------------------->
<!-------------------------------- Parameters and Initialization ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!----------------------------------------------------------------------------------------------- init

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="init" access="public" returntype="void">
		<cfargument name="object" type="supermodel" required="yes" />
		<cfargument name="query" type="query" required="yes" />

		<cfset variables.object = arguments.object />
		<cfset variables.query = arguments.query/>
		<cfset variables.length = arguments.query.recordcount />

		<cfif queryIsComplex()>

			<cfquery name="variables.chunks" dbtype="query">
				SELECT DISTINCT #variables.object.group_by#
				FROM variables.query
				WHERE #variables.object.group_by# IS NOT NULL
				<cfif structKeyExists(variables, 'order_by')>
				ORDER BY #variables.order_by#
				</cfif>
			</cfquery>

			<cfset variables.length = variables.chunks.recordcount />
		</cfif>

		<cfset reset() />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Basic List Functions --------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- current

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="current" access="public" returntype="supermodel" output="false">
		<cfreturn variables.object />
	</cffunction>

<!----------------------------------------------------------------------------------------------- next

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="next" access="public" returntype="boolean" output="false">

		<cfif variables.current_row EQ variables.length>
			<cfreturn false />
		</cfif>

		<cfset variables.current_row = variables.current_row + 1 />

		<cfset loadCurrentValues() />

		<cfreturn true />
	</cffunction>

<!----------------------------------------------------------------------------------------------- prev

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="prev" access="public" returntype="boolean" output="false">
		<cfif variables.current_row EQ 0>
			<cfreturn false />
		</cfif>

		<cfset variables.current_row = variables.current_row - 1 />

		<cfset loadCurrentValues() />

		<cfreturn true />
	</cffunction>

<!---------------------------------------------------------------------------------------------- reset

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="reset" access="public" returntype="void" output="false">
		<cfset variables.current_row = 0 />
	</cffunction>

<!--------------------------------------------------------------------------------------------- length

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="length" access="public" returntype="numeric" output="false">
		<cfreturn variables.length />
	</cffunction>

<!-------------------------------------------------------------------------------------------- isEmpty

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="isEmpty" access="public" returntype="numeric" output="false">
		<cfreturn variables.length eq 0 />
	</cffunction>

<!-------------------------------------------------------------------------------------------- copy

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="copy" access="public" returntype="supermodel.objectlist" output="false">
		<cfset var list = createObject('component', 'supermodel.objectlist') />
		<cfset list.init(variables.object, Duplicate(variables.query)) />
		<cfreturn list />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!--------------------------------- Query Manipulation Functions ----------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------------- filter

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="filter" access="public" returntype="void">
		<cfargument name="condition" type="string" required="yes" />
		<cfquery name="variables.query" dbtype="query">
			SELECT *
			FROM variables.query
			WHERE #preserveSingleQuotes(arguments.condition)#
		</cfquery>
		<cfset init(variables.object, variables.query) />
	</cffunction>

<!------------------------------------------------------------------------------------------- setOrder

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="order" access="public" returntype="void" output="false">
		<cfargument name="order_by" type="string" required="yes" />
		<cfargument name="direction" type="string" default="" />

		<cfset variables.order_by = arguments.order_by />

		<cfquery name="variables.query" dbtype="query">
			SELECT * FROM variables.query
			ORDER BY #variables.order_by#
			<cfif arguments.direction NEQ "">
			#direction#
			</cfif>
		</cfquery>

		<cfset setQuery(variables.query) />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!------------------------------------------- Accessors -------------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------ getObject

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="getObject" access="public" returntype="supermodel.datamodel" output="false">
		<cfreturn variables.object />
	</cffunction>

<!------------------------------------------------------------------------------------------- setQuery

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="setQuery" access="public" returntype="void" output="false">
		<cfargument name="query" type="query" required="yes" />

		<cfset init(variables.object,arguments.query) />
	</cffunction>

<!------------------------------------------------------------------------------------------ setObject

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="setObject" access="public" returntype="void" output="false">
		<cfargument name="object" type="supermodel.datamodel" required="yes" />

		<cfset init(arguments.object,variables.query) />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!------------------------------------------ Pagination -------------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!------------------------------------------------------------------------------------------- paginate

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="paginate" access="public" returntype="void">
		<cfargument name="page" type="numeric" required="yes" />
		<cfargument name="offset" type="numeric" required="yes" />

		<cfset variables.current_row = (arguments.page - 1) * (arguments.offset) />
		<cfset variables.length = min(variables.query.recordcount, (arguments.offset) * (arguments.page)) />
	</cffunction>

<!--------------------------------------------------------------------------------------- currentIndex

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="currentIndex" access="public" returntype="numeric" output="false">
		<cfreturn variables.current_row />
	</cffunction>


<!-------------------------------------------------------------------------------------------------->
<!------------------------------------- Conversion Functions --------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!-------------------------------------------------------------------------------------------- toArray

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="toArray" access="public" returntype="array" output="false">
		<cfset var array = ArrayNew(1) />
		<cfset var saved_current_row = variables.current_row />
		<cfset var i = 1 />

		<cfset variables.current_row = 0 />

		<cfloop condition="#next()#">
			<cfset array[i] = current().clone() />
			<cfset i = i + 1 />
		</cfloop>

		<cfset variables.current_row = saved_current_row />

		<cfreturn array />
	</cffunction>

<!-------------------------------------------------------------------------------------------- toQuery

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="toQuery" access="public" returntype="query" output="false">
		<cfreturn variables.query />
	</cffunction>

<!------------------------------------------------------------------------------------------ toOptions

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="toOptions" access="public" returntype="query" output="false">
		<cfargument name="value_field" type="string" required="yes" />
		<cfargument name="label_field" type="string" required="yes" />

		<cfset var result = "" />

		<cfquery name="result" dbtype="query">
			SELECT
				#arguments.value_field# as [value],
				#arguments.label_field# as [label]
			FROM variables.query
		</cfquery>

		<cfreturn result />
	</cffunction>

<!-------------------------------------------------------------------------------------------------->
<!---------------------------------------- Private Helpers ----------------------------------------->
<!-------------------------------------------------------------------------------------------------->

<!---------------------------------------------------------------------------------- loadCurrentValues

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="loadCurrentValues" access="private" returntype="void">
		<cfset var subquery = "" />

		<cfif queryIsComplex()>

			<cfquery name="subquery" dbtype="query">
				SELECT *
				FROM variables.query
				<cfif variables.chunks[variables.object.group_by][variables.current_row] NEQ "">
				WHERE #variables.object.group_by# =
				#variables.chunks[variables.object.group_by][variables.current_row]#
				</cfif>
				<cfif structKeyExists(variables, 'order_by')>
				ORDER BY #variables.order_by#
				</cfif>
			</cfquery>

			<cfset variables.object.load(subquery) />
		<cfelse>
			<cfset variables.object.load(rowToStruct(variables.query)) />
		</cfif>
	</cffunction>

<!---------------------------------------------------------------------------------------- rowToStruct

	Description:

----------------------------------------------------------------------------------------------------->

	<cffunction name="rowToStruct" access="private" returntype="struct" output="false">
		<cfargument name="query" type="query" required="yes" />

		<cfset var struct = structNew() />

		<cfloop list="#query.columnlist#" index="column">
			<cfset struct[column] = query[column][variables.current_row] />
		</cfloop>

		<cfreturn struct />
	</cffunction>

<!------------------------------------------------------------------------------------- queryIsComplex

	Description:

----------------------------------------------------------------------------------------------------->

<cffunction name="queryIsComplex" access="private" returntype="boolean">
		<cfreturn structKeyExists(variables.object, 'group_by') AND
			structKeyExists(variables.query, variables.object.group_by) />
	</cffunction>
</cfcomponent>
