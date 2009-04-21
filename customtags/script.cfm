<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <cfsavecontent variable="head_content">
      <script src="#request.path#scripts/#attributes.name#.js" type="text/javascript"></script>
    </cfsavecontent>

    <cfhtmlhead text="#head_content#" />
  </cfcase>
</cfswitch>

</cfoutput>
