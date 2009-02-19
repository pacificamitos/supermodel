<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfset attributes['break'] = false />
    <cfset attributes['label'] = '' />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <cfset thistag.attributes.set("value", request.data_object[attributes.id]) />
    <cfset thistag.attributes.add("type", "hidden") />
    <input #thistag.attributes.string()# />
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
