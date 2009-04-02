<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <div class="time">
      <input id="#attributes.id#" name="#attributes.id#" type="hidden" />
      <input id="#attributes.id#_hh" class="hour" type="text" maxlength="2" />
      <input id="#attributes.id#_mm" class="minute" type="text" maxlength="2" />
    </div>
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
