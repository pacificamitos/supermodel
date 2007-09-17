<cfcomponent extends="MachII.framework.Plugin">
	<cffunction name="preView" returntype="void" access="public" output="true">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="yes" />
		<cfinclude template="/SuperModel/FormControls.cfm" />
	</cffunction>
</cfcomponent>