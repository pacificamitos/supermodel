<cfset Arash = createObject('component', 'supermodel2.tests.User') />
<cfset Arash.init('supermodel2') />
<cfset Arash.read(2) />

<cfset Josh = createObject('component', 'supermodel2.tests.User') />
<cfset Josh.init('supermodel2') />
<cfset Josh.read(4) />

<cfoutput>
	
	<p>#Arash.name#</p>
	<p>#Arash.company.name#</p>
	<p>#Josh.name#</p>
	<p>#Josh.company.name#</p>
	
</cfoutput>