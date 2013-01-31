function AICasterFixAct takes nothing returns nothing
    local integer i1=GetSpellAbilityId()
    set AIDEBUG_LASTFUNC="AICasterFixAct"
    
    call Rem("AICasterFixAct "+I2S(i1))
    if (i1=='A0AA' or i1=='A1EV' or i1=='A0SX' or i1=='A0GJ' or i1=='A0GE' or i1=='A0GS' or i1=='A0AB' or i1=='A1HR' or i1=='A1S5' or i1=='A1IN' or i1=='A1S8' or i1=='A0AC' or i1=='A0AD' or i1=='A0AE' or i1=='A1AO' or i1=='A1UV' or i1=='A1DJ' or i1=='A1U7') or i1=='A1S7' or i1=='A0X6' or i1=='A284' or i1=='A0HM' or (i1=='A07X' or i1=='A0AL') or i1=='A07T' or i1=='A0X6' then
    elseif i1=='A14Q' then
        call KillUnit(GetTriggerUnit())
    else
        call UnitRemoveAbility(GetTriggerUnit(),i1)
    endif
endfunction
function AICasterFix takes nothing returns boolean
 local unit u=GetTriggerUnit()
    if GetUnitAbilityLevel(u,'Aloc')>0 and GetPlayerController(GetOwningPlayer(u))==MAP_CONTROL_COMPUTER then
		if GetTriggerEventId()==EVENT_PLAYER_UNIT_SPELL_ENDCAST then
			call RemoveSavedInteger(hash_aiAbilities,GetHandleId(u),'ACST')
			if GetUnitAbilityLevel(u,'A0SX')==0 and GetUnitAbilityLevel(u,'A1HW')==0 and GetUnitAbilityLevel(u,'A1HX')==0 and GetUnitAbilityLevel(u,'A1NF')==0 and GetUnitAbilityLevel(u,'A0FZ')==0 and GetUnitAbilityLevel(u,'A1FM')==0 and GetUnitAbilityLevel(u,'A1DJ')==0 and GetUnitAbilityLevel(u,'A1U7')==0 and GetUnitTypeId(u)!='h0B1' and GetUnitTypeId(u)!='e010' and GetUnitTypeId(u)!='h0C3' and GetUnitTypeId(u)!='e02P' and GetUnitTypeId(u)!='h00O' and GetUnitTypeId(u)!='e02D' and GetUnitTypeId(u)!='h081' and GetUnitTypeId(u)!='o019' then
				call Rem("For Disposable Casters")
				call Rem("must filter all the Disposable Casters" )
			    call AICasterFixAct()
			endif	
		else
			call Rem("For Reused Casters")
			if LoadInteger(hash_aiAbilities,GetHandleId(u),'ACST')!=1 then
			   call IssueImmediateOrder(u,"stop")
			endif
		endif	
    endif
set u=false	
    return false
endfunction


// Add event spell cast
    call TriggerRegisterAnyUnitEvent(t,EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    call TriggerAddCondition(t,Condition(function AICasterFix))
	
	//
	
	
	// for All the Order Issued for reused casters, store integer 1 into hash(UnitHandle,'ACST') first 