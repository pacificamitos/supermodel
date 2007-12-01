<cfcomponent>
	<cffunction name="onRequestStart" returntype="void">
		<cfargument name="targetPage" type="string" required="true" />

		<cfinclude template="server_settings.cfm" />
		
		<cfset application.supermodelFactory = createObject('component', 'supermodel.Factory') />
		<cfset application.supermodelFactory.init(dsn = "supermodel") />
	</cffunction>
</cfcomponent>