<cfcomponent extends="mxunit.framework.TestCase">  
  <cffunction name="testConfigureCanBeCalled" access="public" returntype="void">  
		<cfscript>  
			object = createObject('component', 'supermodel.datamodel');
			object.configure = configure;
			object.configure();
		 </cfscript>    
	</cffunction>
</cfcomponent> 