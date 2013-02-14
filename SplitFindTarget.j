globals
integer CountLimit=0
group CountEnum=CreateGroup()
unit EnumComparison=null
real SigmaHpCounted=0. //Insert in GetCountUnitsInRange
endglobals
function AlliedHerosEnum takes nothing returns boolean
    return ((IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO))and(IsUnitAlly(GetFilterUnit(),GetOwningPlayer(GetEnumUnit())))and(AIIsTargetAlive(GetFilterUnit())))
endfunction
function SplitEnumAvailable takes nothing returns boolean
    return(IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(bj_lastLoadedUnit)))and(not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)and(not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE))and(GetWidgetLife(GetFilterUnit())>.405)and(IsUnitVisible(GetFilterUnit(),GetOwningPlayer(bj_lastLoadedUnit))))
endfunction
function SplitLoadAvailable takes nothing returns boolean
    return(IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(GetEnumUnit())))and(not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)and(not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE))and(GetWidgetLife(GetFilterUnit())>.405)and(IsUnitVisible(GetFilterUnit(),GetOwningPlayer(bj_lastLoadedUnit))))
endfunction
function EvaluateSplitTargetLESSTHAN takes unit Previous,unit Compared returns boolean
local integer prelvl=GetHeroLevel(Previous)
local integer newlvl=GetHeroLevel(Compared)
local integer iClass=aiGetClass(GetUnitTypeId(Compared))
set AIDEBUG_LASTFUNC="EvaluateSplitTargetLESSTHAN"
 if iClass==c_aiClass_Carry or iClass==c_aiClass_Fighter then
	return GetUnitLifePercent(Compared)>=GetUnitLifePercent(Previous) and (newlvl>13) and (prelvl>newlvl or IAbsBJ(prelvl-newlvl)<5)
	call Rem("Where is the existed war balance func?")
endif
	return GetUnitState(Compared,UNIT_STATE_LIFE)<=400 or GetUnitLifePercent(Compared)>=GetUnitLifePercent(Previous)
endfunction 

function GetMaxiumCountUnitInRangeOfUnit_Loop takes nothing returns nothing
local integer NewCount=GetCountUnitsInRange(350,GetEnumUnit(),Condition(function SplitEnumAvailable))
local integer PreCount=GetCountUnitsInRange(350,EnumComparison,Condition(function SplitEnumAvailable))
local integer PreHero=GetCountUnitsInRange(350,EnumComparison,Condition(function AlliedHerosEnum))
local real PreHp=SigmaHpCounted
local integer NewHero=GetCountUnitsInRange(350,GetEnumUnit(),Condition(function AlliedHerosEnum))
local real NewHp=SigmaHpCounted
	if (EnumComparison==null)or (NewHero>PreHero) then
		set EnumComparison=GetEnumUnit()
	elseif NewHero==PreHero then
		set EnumComparison=aiChooseUnitOnBool(NewHp>=PreHp or NewCount>=PreCount,GetEnumUnit(),EnumComparison)
	endif
endfunction


function GetEnemyMaxiumCountUnitInRangeOfUnitCon takes real range,unit who,integer limit,boolexpr Ig returns unit

		set AIDEBUG_LASTFUNC="GetEnemyMaxiumCountUnitInRangeOfUnitCon"
	set CountLimit=limit
	set EnumComparison=null
	call GroupClear(CountEnum)
	call GroupEnumUnitsInRange(CountEnum,GetUnitX(who),GetUnitY(who),range,Ig)
	call GroupRemoveUnit(CountEnum,who)
	call ForGroup(CountEnum, function GetMaxiumCountUnitInRangeOfUnit_Loop)
	call DestroyBoolExpr(Ig)
	set Ig=null
		return EnumComparison
endfunction
function SplitFindTarget_Enum takes nothing returns nothing //Main Damaged Target //Search Real Target for Abil
local unit Target=GetEnumUnit()
local unit SubTarget
local integer Limit=0
call Rem("Limit is Temporary abilished")
   if (hy==null)or(EvaluateSplitTargetLESSTHAN(hy,Target)and GetCountUnitsInRange(350,Target,Condition(function SplitEnumAvailable))>0)  then
        set SubTarget=GetEnemyMaxiumCountUnitInRangeOfUnitCon(350,Target,Limit,Condition(function IsAllyCreep))
		set SubTarget=aiChooseUnitOnBool(SubTarget!=null,SubTarget,GetEnemyMaxiumCountUnitInRangeOfUnitCon(350,Target,Limit,Condition(function IsUnitAllyHeroEnum)))
		if IsUnitType(SubTarget,UNIT_TYPE_HERO) then
			set SubTarget=aiChooseUnitOnBool(GetUnitLifePercent(SubTarget)>GetUnitLifePercent(Target),SubTarget,Target) 
		endif
		set Real_AbilityTarget=aiChooseUnitOnBool((SubTarget!=null),SubTarget,Real_AbilityTarget)
   endif
	set Target=null
	set SubTarget=null
endfunction

function SplitFindTargetHero takes real Range, unit Master returns unit
    local boolexpr Ig=Condition(function k6)
    set AIDEBUG_LASTFUNC="SplitFindTargetHero"
    set hy=null
	set Real_AbilityTarget=null
	set bj_lastLoadedUnit=Master
    call GroupClear(iA)
    call GroupEnumUnitsInRange(iA,GetUnitX(Master),GetUnitY(Master),Range,Ig)
	call GroupRemoveUnit(iA,Master)
    call ForGroup(iA,function SplitFindTarget_Enum)
    call DestroyBoolExpr(Ig)
    set Ig=null
	set Real_SplitWanted[GetPlayerId(GetOwningPlayer(Master))]=hy
    return Real_AbilityTarget

endfunction

function SplitLoadTargetHero takes unit target returns unit
    local boolexpr Ig=Condition(function SplitLoadAvailable)
    set AIDEBUG_LASTFUNC="SplitLoadTargetHero"
	set EnumComparison=null
	set bj_lastLoadedUnit=GetEnumUnit()
    call GroupClear(iA)
    call GroupEnumUnitsInRange(iA,GetUnitX(target),GetUnitY(target),350,Ig)
	call GroupRemoveUnit(iA,target)
    call ForGroup(iA,function GetMaxiumCountUnitInRangeOfUnit_Loop)
    call DestroyBoolExpr(Ig)
    set Ig=null
	call BJDebugMsg(GetUnitName(EnumComparison))
    return EnumComparison

endfunction
