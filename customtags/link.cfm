<cfif not structKeyExists(attributes, 'title')>
  <cfset attributes['title'] = attributes['text'] />
</cfif>
<cfif not structKeyExists(attributes, 'root')>
  <cfset attributes['root'] = request.path&'index.cfm/' />
</cfif>

<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
  <cfset reserved_arguments = "href" />
  <cfobject name="thistag.attributes" component="supermodel2.attributes" />

  <cfset thistag.attributes.init(
    argumentcollection = attributes,
    reserved_arguments = reserved_arguments) />

    <a #thistag.attributes.string()# href="#attributes.root##attributes.path#">#attributes.text#</a> 
  </cfcase>
</cfswitch>

</cfoutput>
