<cfset Arash = createObject('component', 'supermodel.tests.User') />
<cfset Arash.init('supermodel') />
<cfset Arash.read(2) />
<cfdump var="#Arash#">

<cfset Josh = createObject('component', 'supermodel.tests.User') />
<cfset Josh.init('supermodel') />
<cfset Josh.read(4) />
<cfdump var="#Josh#">

<cfdump var="#Arash#">