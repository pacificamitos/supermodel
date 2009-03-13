<cfif not structKeyExists(attributes, 'media')>
  <cfset attributes.media = 'screen' />
</cfif>

<cfoutput>

<cfsavecontent variable="head_content">
  <link href="#request.path#css/#attributes.name#.css" type="text/css" rel="stylesheet" media="#attributes.media#" />
</cfsavecontent>

<cfhtmlhead text="#head_content#" />

</cfoutput>
