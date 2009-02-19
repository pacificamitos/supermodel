<cfset arash = createObject('component', 'supermodel2.tests.model.thief') />
<cfset arash.init('supermodel2') />
<cfset adam  = createObject('component', 'supermodel2.tests.model.mage') />
<cfset adam.init('supermodel2') />

<cfoutput>

<cfset arash.name = "Arash" />
<cfset adam.name = "Adam" />
<cfset adam.level = "99" />
<cfset arash.level = "4" />
<cfset arash.party_id = "1" />
<cfset arash.arrested = "1" />
<cfset arash.save() />
<cfset adam.school = "Disco" />
<cfset adam.party_id = "1" />
<cfset adam.save() />

  <h1>Adventurer ###arash.id#</h1>
  <p>#arash.name#, level #arash.level#</p>
  <cfif #arash.arrested#>
    <p>Currently is arrested</p>
  </cfif>
 
  <h1>Adventurer ###adam.id#</h1>
  <p>#adam.name#, level #adam.level#</p>
  <p>Studies the school of #adam.school# magic</p>

<h1>Delete Arash...</h1>

<cfquery name="check_query" datasource="supermodel2">
  SELECT * 
  FROM characters
</cfquery>
<cfdump var=#check_query# />

<cfset arash.delete() />

<p>Check that there is no arash between the last adams.</p>
<cfquery name="check_query" datasource="supermodel2">
  SELECT * 
  FROM characters
</cfquery>
<cfdump var=#check_query# />

<p>Check that arash is removed from the thieves table as well.</p>
<cfquery name="other_query" datasource="supermodel2">
  SELECT *
  FROM thieves
</cfquery>
<cfdump var=#other_query# />

</cfoutput>
