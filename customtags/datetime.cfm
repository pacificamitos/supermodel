<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cf_date id="#attributes.id#" label="#attributes.label#">
  </cfcase>
</cfswitch>

</cfoutput>
