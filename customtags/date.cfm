<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
    <div class="date">
	  <input name="#attributes.id#" id="#attributes.id#" type="text" class="whole_date" maxlength="0"/>
      <input id="#attributes.id#_dd" class="day" type="text" maxlength="2" />
      <input id="#attributes.id#_mm" class="month" type="text" maxlength="2" />
      <input id="#attributes.id#_yyyy" class="year" type="text" maxlength="4" />
	  
	  
    </div>
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
