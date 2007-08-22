<cfcomponent extends="MachII.framework.Plugin">
	<cffunction name="preView" returntype="void" access="public" output="false">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="yes" />
		<cfset eventContext.setArg('test', 'wtf') />
	</cffunction>
</cfcomponent>