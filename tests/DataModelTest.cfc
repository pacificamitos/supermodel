<!-------------------------------------------------------------------------------------- DataModelTest
	
	In order to test the model we'll be borrowing a simplified scenario from the HR Staffing project
	
	A manager is a user who has many positions
	A position belongs to a manager
	A position may belong to a process
	A process has many positions
	
	Since the model object is used for connecting to a database, we have to have some database
	tables setup in order to test it properly.  The database is called 'supermodel2' and resides on
	gtisdev.
	
	Here is our users table:
	
	id	|	name
	1		|	George
	2		|	Randy
	3		|	Dan
	
	Here is our positions table:
	
	id	|	title							|	manager_id	|	process_id
	1		|	Systems Analyst		|	1						|	1
	2		|	Administrator			|	2						|	2
	3		|	Engineer					|	2						|	3
	4		|	Billing Clerk			|	3						|	3
	
	Here is our processes table:
	
	id	|	number						
	1		|	2007-IA-12345
	2		|	2007-IA-98765
	3		|	2008-EA-12345
	4		|	2008-EA-98765
	
				
----------------------------------------------------------------------------------------------------->	

<cfcomponent extends="mxunit.framework.TestCase">  
  <cffunction name="testConfigureCanBeCalled" access="public" returntype="void">  
		<cfscript>  
			object = createObject('component', 'supermodel2.model');
			object.configure = configure;
			object.configure();
		 </cfscript>    
	</cffunction>
	
	<cffunction name="configure" access="private" returntype="void">
		<cfset variables.table_name = 'positions' />
	</cffunction>
</cfcomponent> 