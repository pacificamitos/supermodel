<cfcomponent extends="mxunit.framework.testcase">
  <cffunction name="testLoad">
    <cfset var manager = createObject('component', 'supermodel.tests.manager') />
    <cfset var struct = structNew() />

    <cfset struct.name = 'Phil' />

    <cfset manager.init('supermodel_test') />
    <cfset manager.load(struct) />

    <cfset assertEquals('Phil', manager.name) />
  </cffunction>
</cfcomponent>
