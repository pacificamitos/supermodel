<cfoutput>

<cfset company = createObject('component', 'company') />
<cfset company.init('supermodel') />
<cfset company.group_by = 'company_id' />

<cfset someBody = createObject('component', 'hr_staffing.model.users.user') />
<cfset someBody.init('human_resources') />
<cfdump var="#someBody#">

<cfquery name="companies" datasource="supermodel">
	SELECT 
		companies.id,
		companies.name,
		users.id AS user_id,
		users.name AS user_name,
		companies.id AS company_id,
		weapons.id AS weapon_id,
		weapons.name AS weapon_name
  FROM companies
	JOIN users
		ON users.company_id = companies.id
	LEFT JOIN weapons
		ON users.id = weapons.user_id
</cfquery>

<cfset list = createObject('component', 'supermodel.objectlist') />
<cfset list.init(company, companies) />

<cfloop condition="#list.next()#">
	<cfset current_company = list.current() />
	
	<h1>#current_company.name#</h1>
	
	<cfloop condition="#current_company.users.next()# ">
		<cfset current_user = current_company.users.current() />
		
		<h2>#current_user.name#</h2>
		
		<cfloop condition="#current_user.weapons.next()#">
			<cfset current_weapon = current_user.weapons.current() />
			
			<p>#current_weapon.name#</p>
			
		</cfloop>
	</cfloop>
</cfloop>

</cfoutput>