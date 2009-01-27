<cfset lois = createObject('component', 'supermodel.tests.model.druid') />
<cfset lois.init('supermodel') />
<cfset lois.read(85) />

<cfset joao = createObject('component', 'supermodel.tests.model.fighter') />
<cfset joao.init('supermodel') />
<cfset joao.read(91) />

<cfoutput>

  <h1>Adventurer ###lois.id#</h1>
  <p>#lois.name#, level #lois.level#</p>
  <p>Belongs to party "#lois.party.name#"</p>
  <cfif ListContains(getMetadata(lois).name, 'druid')>
    <p>Worships #lois.god.name# and has the power of #lois.god.power#</p>
  </cfif>

  <h1>Adventurer ###joao.id#</h1>
  <p>#joao.name#, level #joao.level#</p>
  <cfif ListContains(getmetadata(joao).name, 'druid')>
    <p>Worships #joao.god.name# and has the power of #joao.god.power#</p>
  </cfif>

</cfoutput>
