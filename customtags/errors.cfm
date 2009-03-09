<cfoutput>
<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
		<ul class="errors">
			<cfloop collection="#request.data_object['errors']#" item="field">
				<li>#request.data_object['errors'][field]#</li>
			</cfloop>
		</ul>
	</cfcase>
</cfswitch>
</cfoutput>
