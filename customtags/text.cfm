<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <cfset thistag.attributes.set("value", object[attributes.id]) />
    <cfset thistag.attributes.add("type", "text") />
    <input #thistag.attributes.string()# />
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
