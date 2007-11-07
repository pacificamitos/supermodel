<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset variables.dsn = arguments.dsn />
	</cffunction>
	
	<cffunction name="getInstance" access="public" returntype="supermodel.supermodel" output="false">
		<cfargument name="type" type="string" required="yes" />
		
		<cfset var object = createObject('component', arguments.type) />
		<cfset object.configure() />
		<cfset object.init(variables.dsn) />
		
		<cfreturn object />
	</cffunction>
</cfcomponent>