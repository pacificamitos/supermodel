<cfoutput>

<cfsavecontent variable="head_content">
  <link href="#request.path#css/#attributes.name#.css" type="text/css" rel="stylesheet" media="screen" />
</cfsavecontent>

<cfhtmlhead text="#head_content#" />

</cfoutput>
