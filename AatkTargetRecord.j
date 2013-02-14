//The code is a simple alternatives for getting present Attacking target/Attackers
// For Towers
// the hero-based part is in HeroAI_Attacked_Main
globals
trigger AttackerMonitor=CreateTrigger()
constant integer IndexTopAatk=StringHash("listtop1")
constant integer IndexTopTarget=StringHash("listtop2")
constant integer IndexOffsetAtk=StringHash("attack")
hashtable hash_list=InitHashtable()
unit array ListHandle
integer array ListState
constant integer STATE_ForAttacker=1
constant integer STATE_ForTarget=2
integer Atk_ListTop=0
integer Atk_ListLoop=0
integer Atk_Count=0
integer Atk_Pointer=0
real Atk_dTime
integer Atk_Cache=0
integer List_Loop=0
endglobals
//ListHandle_Attacker
//ListState
//top unit/real
// ---top value
//handleId of stack unit --->bool

function AatkPool_RefreshTargets takes nothing returns boolean
local integer top=LoadInteger(hash_list,Atk_Cache,IndexTopTarget)-1
local unit TopUnit
local real TopTime
call Rem("take global Atk_ListLoop as the parameter")
set List_Loop=0
	loop
		exitwhen List_Loop>top 
		if Atk_dTime-LoadReal(hash_list,Atk_Cache,List_Loop)>2 or IsUnit(LoadUnitHandle(hash_list,Atk_Cache,List_Loop),null) then
			
			set TopUnit=LoadUnitHandle(hash_list,Atk_Cache,top) //get tops` data
			set TopTime=LoadReal(hash_list,Atk_Cache,top)
			call RemoveSavedBoolean(hash_list,Atk_Cache,GetHandleId(LoadUnitHandle(hash_list,Atk_Cache,List_Loop))) //Remove Boolean and the childkey address
			call RemoveSavedInteger(hash_list,Atk_Cache,GetHandleId(LoadUnitHandle(hash_list,Atk_Cache,List_Loop)))
			
			call SaveUnitHandle(hash_list,Atk_Cache,List_Loop,TopUnit) //OverWrite
			call SaveReal(hash_list,Atk_Cache,List_Loop,TopTime) 
			
			call RemoveSavedHandle(hash_list,Atk_Cache,top) //Remove Tops`
			call RemoveSavedReal(hash_list,Atk_Cache,top)
			
			call SaveInteger(hash_list,Atk_Cache,GetHandleId(TopUnit),List_Loop)
			call SaveInteger(hash_list,Atk_Cache,IndexTopTarget,top)
			set top=top-1
		endif
		set List_Loop=List_Loop+1
	endloop	
	set TopUnit=null
	return top==-1
endfunction
function AatkPool_RefreshAttackers takes nothing returns boolean //
local integer top=LoadInteger(hash_list,Atk_Cache,IndexTopAatk)-1
local integer end=top+IndexOffsetAtk
local unit TopUnit
local real TopTime
set List_Loop=IndexOffsetAtk
	loop
		exitwhen List_Loop>end
		if Atk_dTime-LoadReal(hash_list,Atk_Cache,List_Loop)>4 or IsUnit(LoadUnitHandle(hash_list,Atk_Cache,List_Loop),null) then
			set TopUnit=LoadUnitHandle(hash_list,Atk_Cache,top) //get tops` data
			set TopTime=LoadReal(hash_list,Atk_Cache,top)
			call RemoveSavedBoolean(hash_list,Atk_Cache,IndexOffsetAtk+GetHandleId(LoadUnitHandle(hash_list,Atk_Cache,List_Loop))) //Remove Boolean and the childkey address
			call RemoveSavedInteger(hash_list,Atk_Cache,IndexOffsetAtk+GetHandleId(LoadUnitHandle(hash_list,Atk_Cache,List_Loop)))
			
			call SaveUnitHandle(hash_list,Atk_Cache,List_Loop,TopUnit) //OverWrite
			call SaveReal(hash_list,Atk_Cache,List_Loop,TopTime) 
			
			call RemoveSavedHandle(hash_list,Atk_Cache,top) //Remove Tops`
			call RemoveSavedReal(hash_list,Atk_Cache,top)
			
	
			call Rem("Refresh current key ")
			call SaveInteger(hash_list,Atk_Cache,IndexOffsetAtk+GetHandleId(TopUnit),List_Loop)
			call SaveInteger(hash_list,Atk_Cache,IndexTopAatk,top)
			set top=top-1
		endif
		set List_Loop=List_Loop+1
	endloop	
	set TopUnit=null
		return top==-1
endfunction
function PopListCurrentIndex takes boolean do returns nothing
		if do then
			call FlushChildHashtable(hash_list,Atk_Cache)
			set ListHandle[Atk_ListLoop]=ListHandle[Atk_ListTop-1]
			set ListState[Atk_ListLoop]=ListState[Atk_ListTop-1]
			set ListHandle[Atk_ListTop-1]=null
			set ListState[Atk_ListTop-1]=0
		endif	
endfunction
function AatkPool_Loop takes nothing returns boolean
set Atk_Count=Atk_Count+1
set Atk_ListLoop=0
set Atk_dTime=TimerGetElapsed(udg_GameTimer)
loop
	exitwhen Atk_ListLoop>Atk_ListTop
	set Atk_Cache=GetHandleId(ListHandle[Atk_ListLoop])

		if 	IsUnit(ListHandle[Atk_ListLoop],null) or GetWidgetLife(ListHandle[Atk_ListLoop])<=0.405 then
			call PopListCurrentIndex(true)
		else
			if ListState[Atk_ListLoop]==STATE_ForTarget then
				call PopListCurrentIndex(AatkPool_RefreshTargets())
			elseif ListState[Atk_ListLoop]==STATE_ForAttacker and Atk_Count-Atk_Count/4*4==0 then
				call PopListCurrentIndex(AatkPool_RefreshAttackers())
			endif	
		endif
set Atk_ListLoop=Atk_ListLoop+1
endloop	
	return false
endfunction

function Push_AttakerList takes unit target ,unit attacker returns nothing //store attackers who attack the target
local integer Cache=GetHandleId(target)
local integer top
local integer index=GetHandleId(attacker)
if not LoadBoolean(hash_list,Cache,index+IndexOffsetAtk) then
	set top=LoadInteger(hash_list,Cache,IndexTopAatk)
	if top==0 then
		set ListHandle[Atk_ListTop]=(target)
		set ListState[Atk_ListTop]=STATE_ForAttacker
		set Atk_ListTop=Atk_ListTop+1
	endif
	call SaveUnitHandle(hash_list,Cache,IndexOffsetAtk+top,attacker)
	call SaveInteger(hash_list,Cache,IndexTopAatk,top+1) //top++ 
	call SaveBoolean(hash_list,Cache,IndexOffsetAtk+index,true)  // bool of Existence
	call SaveInteger(hash_list,Cache,IndexOffsetAtk+index,top)	  //TopId
else
	set top=LoadInteger(hash_list,Cache,index+IndexOffsetAtk)
endif
	call SaveReal(hash_list,Cache,IndexOffsetAtk+top,TimerGetElapsed(udg_GameTimer)) //Attk time

endfunction
function Push_TargetList takes unit attacker ,unit target returns nothing
local integer Cache=GetHandleId(attacker)
local integer top
local integer index=GetHandleId(target)
if not LoadBoolean(hash_list,Cache,index) then
	set top=LoadInteger(hash_list,Cache,IndexTopTarget)
	if top==0 then
		set ListHandle[Atk_ListTop]=(attacker)
		set Atk_ListTop=Atk_ListTop+1
	endif
	call SaveUnitHandle(hash_list,Cache,top,attacker)
	call SaveInteger(hash_list,Cache,IndexTopTarget,top+1)
	call SaveBoolean(hash_list,Cache,index,true)
	call SaveInteger(hash_list,Cache,index,top)
else
	set top=LoadInteger(hash_list,Cache,index)
endif	
	call SaveReal(hash_list,Cache,top,TimerGetElapsed(udg_GameTimer))
endfunction
function Aatk_ForTower takes nothing returns boolean
	local unit Attacker
	local unit Target
	local integer pointerid
call Rem("if (not IsUnitScourgeTower()) and (not IsUnitSentinelTower()) then")
	set Attacker=GetAttacker()
	set Target=GetTriggerUnit()
	call Push_AttakerList(Target,Attacker)
	call Push_TargetList(Attacker,Target)
	set Attacker=null
	set Target=null
call Rem("endif")
	return false
endfunction

function Aatk_RegisterTower takes unit whichtower returns nothing
	local trigger t=null
	if IsUnit(whichtower,null)==false then
		set t=CreateTrigger()
		call TriggerRegisterUnitEvent(t,whichtower,EVENT_UNIT_ATTACKED)
		call TriggerAddCondition(t,Condition(function Aatk_ForTower))
		set t=null	
	endif
endfunction
function GetAttackingSourceCount takes unit who returns integer
	return LoadInteger(hash_list,GetHandleId(who),IndexTopAatk)
endfunction
function GetSourceIsAttackedByHeroOrTower takes unit who returns boolean
local integer i
local integer end
local integer index
	if LoadInteger(hash_list,GetHandleId(who),IndexTopAatk)==0 then
		return false
	endif
	set i=IndexOffsetAtk
	set end=IndexOffsetAtk+LoadInteger(hash_list,GetHandleId(who),IndexTopAatk)
	set index=GetHandleId(who)
	loop
		exitwhen i>=end
		if IsUnitType(LoadUnitHandle(hash_list,index,i),UNIT_TYPE_HERO)==true or IsUnitType(LoadUnitHandle(hash_list,index,i),UNIT_TYPE_STRUCTURE)==true then
			return true
		endif	
		set i=i+1
	endloop
	return false
endfunction
function GetSourceIsAttackingHeroOrTower takes unit who returns boolean
local integer i
local integer end
local integer index
	if LoadInteger(hash_list,GetHandleId(who),IndexTopTarget)==0 then
		return false
	endif
	set i=0
	set end=LoadInteger(hash_list,GetHandleId(who),IndexTopTarget)
	set index=GetHandleId(who)
	loop
		exitwhen i>=end
		if IsUnitType(LoadUnitHandle(hash_list,index,i),UNIT_TYPE_HERO)==true or IsUnitType(LoadUnitHandle(hash_list,index,i),UNIT_TYPE_STRUCTURE)==true then
			return true
		endif	
		set i=i+1
	endloop
	return false
endfunction
function InitAttackTargetList takes nothing returns nothing
local integer i=0
	call TriggerRegisterTimerEvent(AttackerMonitor,2,true)
	call TriggerAddCondition(AttackerMonitor,Condition(function AatkPool_Loop))
	loop 
		exitwhen i>8191
		set ListHandle[i]=null
		set ListState[i]=0
		set i=i+1
	endloop	
endfunction

function InitTowerRegister takes nothing returns nothing
    call Aatk_RegisterTower(SentinelBuilding_Tower1Top)
    call Aatk_RegisterTower(SentinelBuilding_Tower1Mid)
    call Aatk_RegisterTower(SentinelBuilding_Tower1Bot)
    call Aatk_RegisterTower(SentinelBuilding_Tower2Top)
    call Aatk_RegisterTower(SentinelBuilding_Tower2Mid)
    call Aatk_RegisterTower(SentinelBuilding_Tower2Bot)
    call Aatk_RegisterTower(SentinelBuilding_Tower3Top)
    call Aatk_RegisterTower(SentinelBuilding_Tower3Mid)
    call Aatk_RegisterTower(SentinelBuilding_Tower3Bot)
    call Aatk_RegisterTower(SentinelBuilding_Tower4Left)
    call Aatk_RegisterTower(SentinelBuilding_Tower4Right)
	call Aatk_RegisterTower(ScourgeBuilding_Tower1Top)
    call Aatk_RegisterTower(ScourgeBuilding_Tower1Mid)
    call Aatk_RegisterTower(ScourgeBuilding_Tower1Bot)
    call Aatk_RegisterTower(ScourgeBuilding_Tower2Top)
    call Aatk_RegisterTower(ScourgeBuilding_Tower2Mid)
    call Aatk_RegisterTower(ScourgeBuilding_Tower2Bot)
    call Aatk_RegisterTower(ScourgeBuilding_Tower3Top)
    call Aatk_RegisterTower(ScourgeBuilding_Tower3Mid)
    call Aatk_RegisterTower(ScourgeBuilding_Tower3Bot)
    call Aatk_RegisterTower(ScourgeBuilding_Tower4Left)
    call Aatk_RegisterTower(ScourgeBuilding_Tower4Right)
endfunction