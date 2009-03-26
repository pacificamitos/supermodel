<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
      <cfset caller[attributes.object] = caller[attributes.in].current() />
  </cfcase>
  <cfcase value="end">
      <cfdump var="#thistag#">
  </cfcase>
</cfswitch>
