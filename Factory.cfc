<cfcomponent>
	<cffunction name="init" access="public" returntype="void" output="false">
		<cfargument name="dsn" type="string" required="yes" />

		<cfset variables.table_manager = createObject('component', 'supermodel.TableManager') />
		<cfset variables.relation_manager = createObject('component', 'supermodel.RelationManager') />
		<cfset variables.table_manager.init(arguments.dsn) />
	</cffunction>
	
	<cffunction name="getInstance" access="public" returntype="supermodel.supermodel" output="false">
		<cfargument name="type" type="string" required="yes" />
		
		<cfset var object = createObject('component', arguments.type) />
		<cfset object.configure() />
		<cfset object.init(
			variables.table_manager,
			variables.relation_manager) />
			
		<cfset variables.table_manager.injectAttributes(object) />
		
		<cfreturn object />
	</cffunction>
</cfcomponent>