<cfset Arash = createObject('component', 'supermodel.tests.User') />
<cfset Arash.init('supermodel') />
<cfset Arash.read(2) />

<cfset Josh = createObject('component', 'supermodel.tests.User') />
<cfset Josh.init('supermodel') />
<cfset Josh.read(4) />

<cfoutput>
	
	<p>#Arash.name#</p>
	<p>#Arash.company.name#</p>
	<p>#Josh.name#</p>
	<p>#Josh.company.name#</p>
	
</cfoutput>