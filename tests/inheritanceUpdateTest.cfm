<cfset lois = createObject('component', 'supermodel.tests.model.druid') />
<cfset lois.init('supermodel') />
<cfset lois.read(85) />

<cfoutput>

  <h1>Adventurer ###lois.id#</h1>
  <p>#lois.name#, level #lois.level#</p>
  <p>Belongs to party "#lois.party.name#"</p>
  <cfif ListContains(getMetadata(lois).name, 'druid')>
    <p>Worships #lois.god.name# and has the power of #lois.god.power#</p>
  </cfif>

</cfoutput>

<cfset lois.level++  />
<cfset lois.update() />

<cfoutput>
  <p>#lois.name# is now level #lois.level#!</p>

</cfoutput>

