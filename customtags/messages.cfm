<cfoutput>

<cfif structKeyExists(session, 'messages')>
  <cfloop list="notice,warning,error" index="type">
    <cfif structKeyExists(session['messages'], type)>
      <cfset messages = session['messages'][type] />
      <cfloop from="1" to="#arrayLen(messages)#" index="i">
        <div class="message #type#">
          #messages[i]#<br />
          <a>Close</a> 
        </div>
      </cfloop>
    </cfif>
  </cfloop>

  <cfset structDelete(session, 'messages') />
</cfif>

</cfoutput>
