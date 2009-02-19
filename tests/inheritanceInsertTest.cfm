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

</cfoutput>
