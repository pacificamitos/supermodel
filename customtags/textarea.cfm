<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <textarea #thistag.attributes.string()#>#object[attributes.id]#</textarea>
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
