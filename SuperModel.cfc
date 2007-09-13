<cfcomponent extends="MachII.framework.Plugin">
	<cffunction name="preView" returntype="void" access="public" output="true">
		<cfargument name="eventContext" type="MachII.framework.EventContext" required="yes" />
		<cfoutput>WHAT!?</cfoutput>
		<cfinclude template="/SuperModel/FormControls.cfm" />

		<cfoutput>HUH!?</cfoutput>
	</cffunction>
</cfcomponent>