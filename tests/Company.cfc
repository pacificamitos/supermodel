<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure" access="private" returntype="void">
		<cfset variables.table_name = "companies" />
		<cfset hasMany('users', 'supermodel.tests.User', 'user') />
	</cffunction>
	
	<cffunction name="selectQuery" access="private" returntype="query">
		<cfset var query = "" />
		
		<cfquery name="query" datasource="#variables.dsn#">
			SELECT 
				companies.id,
				companies.name,
				users.id AS user_id,
				users.name AS user_name
			FROM companies
			JOIN users
				ON companies.id = users.company_id
			WHERE companies.id = 
				<cfqueryparam value="#this.id#" cfsqltype="cf_sql_integer" />
		</cfquery>
		
		<cfreturn query />
	</cffunction>
</cfcomponent>