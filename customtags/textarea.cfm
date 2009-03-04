<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <cfset thistag.attributes.add('rows', 5) />
    <cfset thistag.attributes.add('cols', 30) />
    <textarea #thistag.attributes.string()#>#request.data_object[attributes.id]#</textarea>
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
