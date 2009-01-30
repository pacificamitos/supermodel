<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
		<select #thistag.attributes.string()#>
  </cfcase>

  <cfcase value="end">
		</select>
		<cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
