<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfinclude template="common.cfm" />
    <cfinvoke method="before" argumentcollection="#attributes#" />
	  <input name="#attributes.id#" id="#attributes.id#" type="text" class="whole_date" maxlength="0" value="#DateFormat(request.data_object[attributes.id], "yyyy-mm-dd")#" autocomplete="off"/>
 	<div class="date" id="#attributes.id#">  
	  <input id="#attributes.id#_yyyy" class="year" type="text" maxlength="4"  autocomplete="off"/>
	  <input id="#attributes.id#_mm" class="month" type="text" maxlength="2" autocomplete="off" />
	  <input id="#attributes.id#_dd" class="day" type="text" maxlength="2" autocomplete="off"/> (yyyy-mm-dd) 
    </div>
    <cfinvoke method="after" argumentcollection="#attributes#" />
  </cfcase>
</cfswitch>

</cfoutput>
