---integer dH
dH[PlayerId] - ItemBuild step
---integer eY
eY[id]=1 - State Attack
eY[id]=2 - State At Fountain
eY[id]=3 - -d defense
eY[id]=4 - -sd stay defense
eY[id]=10 - Jingling
eY[id]=11 - Roshan attack
eY[32+O5]=8 - Visible Hero
eY[32+O5]=-1 - Invisible Hero
eY[64+O5] - lanes (real intended lane)
eY[80+O5] - lanes (buffer to auto-laning; what is visible to others)

    set eY[128+O5]= ability 1
    set eY[144+O5]= ability 2
    set eY[160+O5]= ability 3
    set eY[172+O5]= ability 4
    set eY[188+O5]= ability 5
	
eY[208+O5] - changing lane, TP if possible
eY[224+O5] = TP cooldown
eY[240+O5] = missed from lane

eY[256+O5]=GetIssuedOrderId() when AI issued order
eY[272+   = ganking phase
eY[288+   = ganking lane
eY[304+	  = current lane
eY[320+	  = allies around (aiWarBalance)

eY[336+   = last lane before missed from lane

    set eY[336+O5]= ability 1 for cd
    set eY[352+O5]= ability 2 for cd
    set eY[368+O5]= ability 3 for cd
	(the rests are using eY[172+O5] and eY[188+O5])

eY[384    = order of jungling camp (left = -1 ; right = +1)

eY[400    = unit ID of Rubick's copied spell
eY[416    = abl ID of Rubick's copied spell
eY[432    = abl priority of Rubick's current copied spell
eY[448    = abl ID of Rubick's delayed spell copy

eY[464    = last order ID
eY[480	  = last order X
eY[496    = last order Y

eY[512    = last item operation result (0 = waiting, 1 = success, 2 = failed, DelayedItemCreation is called)
eY[528    = attempt of item pick
eY[544    = extension of eY[O5]==1 in lane-oriented actions
			0 = free mode
			1 = tower defense
			2 = helping ally


---unit h4
h4[O5] = hero main target
h4[16+O5]
h4[48 	= defense target
h4[96+O5]=next target creep deny
h4[144+  = target of chlane/gank
h4[272+ = Elune Arrow before dodge

h4[304   = nearby enemy tower
h4[320   = target of delayed spell copy

h4[336   = target of last order (eY[464)
h4[352   = caster of last dodged spell

---unit waypoint h8
h8[id] - Next point to forward
h8[16+id] - Endpoint to attack... center of enemy base
h8[32+id] - Return point after jungling
h8[48+id] - Backward point?
h8[64	- defense point
h8[80   - last stepped-on waypoint
h8[96   - gank final target
h8[112   - gank final waypoint
h8[128   - gank creep waypoint (same as h8[32+] on changing lane)
h8[160   - gank last position (target's h8[80]')

h8[144   - tele target
h8[160   - Io's tele target

---unit waypoint h9
h9[id] - Previous point to retreat
h9[16+id] - End point to retreat (base???)
h9[32     - ??
h9[48+id  - Techies' bomb spot
h9[64+    - tower to defend

---real hq
hq[416+O5] - issued help signal for nearby allies
hq[448+O5]=Bz+3. - cooldown of issued AI order
hq[480+O5] - the unit attacked enemy by help signal
hq[528+O5] - cooldown of defense system

hq[560+O5] - AI is visible on counting attack force in T8v
hq[592+O5] - cooldown of AI returning to base for item buy
hq[608+O5] - cooldown of chasing fogged hero
hq[624+O5] - gallant mode (for gank only, ignores all condition which is potential to cancel gank

hq[640+O5] - timer to start force-move (851986) on gank/chlane start
hq[656+O5] - timer to wait target gank to get closer

hq[672+O5  - aiMobTower cooldown

hq[688     - last life percent
hq[704     - last 2 second life percent change
hq[720     - last 10 seconds greatest 1-sec-lifepercent-change
hq[736     - time to greatest 1-sec damage

hq[752     - EHP Modifier

hq[768     - cooldown of fleeing cancel in defense mode
hq[784     - cooldown of "not fleeing" in def mode

hq[800     - cooldown of ping on attack disadvantage
hq[816     - remaining time of Rubicks' spellsteal'

hq[832     - FREE MODE (e.g. picking/destroying items), ignores all AI orders

hq[848     - CD of gank system (in lane-lock func)
hq[864     - waypoint side offset


---integer hG (item related)
hG[O5] = current item ID
hG[32+ = next item price
hG[128  dropped item
hG[144 item set 1 (deprecated)
hG[160 item set 2 (deprecated)
hG[256+ = bear item ID
hG[272+ = bear item ID?

hG[176+  = is simulating item buy
hG[192+  = simulated item ID
hG[208+  = next item price for sim
hG[224+  = total price stashed

hG[290(288?)+ = bear item sim ID

---item HW
HW[16+  = misc items

---location HC
HC[O5] - last hero order location (updated every point or target order)

---boolean G0
G0[64+id]=true - Moving to h9[id] (retreating)
G0[32+O5]=true - Used Healing Salve, Tango
G0[48+O5]      - activated g_taAITriggers[64+O5] (temporary back-off)
G0[128+			= have chance to win based on T8v
G0[176	= changelane reached invisible point
G0[192	= gank set waiting time (hq[652])
G0[208+O5] = allow use of closer forest gankpoint on ganking riverside


G0[224    = hit once against an attacking unit (mobbing)
G0[240    = is relocating

G0[256    = is winning based on aiWarBalance
G0[272	  = bypassing channeling effect on function J3

G0[288    = Rubick's ability function call
G0[304    = Rubick's ability function call, skip other non-ability function

G0[320    = returning to base for item purpose
G0[336	  = gank issue kill signal

---boolean GZ
GZ[16+O5]=true - AI Issued Order
GZ[64+O5]=true - -aid command used
GZ[128+O5]=true - permission to attack (  GZ[128+O5]=(m5!=null)and((GetHeroLevel(Wqv)>5)or(AIIsHeroKillable(m5)))  )
GZ[160+O5]=true - retreating

GZ[176+O5 = true  - no permission to continue with item build (waiting TriggerAddCondition(t,Condition(function eme)) )
GZ[192+O5         - item reset order
GZ[208            - war mode

GZ[224		  - Io's temporary tether
GZ[304+     - "OrbOn" doubled for AI

GZ[320+		- false = 1-hero deny
--boolean udg_bAIMsg
udg_bAIMsg[O5 - AI main messaging
udg_bAIMsg[16+ - AI missing report
udg_bAIMsg[32+ - AI board display (udg_bAIMsg[64+ and udg_bAIMsg[48+)
udg_bAIMsg[48+ - AI board init (can be displayed or not)
udg_bAIMsg[64+ - AI board display (user preference)
udg_bAIMsg[80+ - AI board show DE/DG
udg_bAIMsg[96+ - AI board DEDG init (can be displayed or not)
udg_bAIMsg[112+ - AI board DEDG display (user preference)

--integer aiDefInt
aiDefInt[0-3  = defense score. 0 = mid, 1 = left, 2 = right, 3 = tree/throne
aiDefInt[4+   = number of enemy heroes
aiDefInt[8+   = number of allied heroes required

aiDefInt[12+   = number of allied heroes defending

aiDefInt[48	= order of defense priority (+1-5 = Sent, +7-11 = scrg)
aiDefInt[64+O5] = lane of defense
aiDefInt[80	= template of order of defense priority (+1-5 = Sent, +7-11 = scrg)
aiDefInt[96	= 1 -> AI is participating in defense

aiDefInt[112	= laning data (set by aiUpdateLaneData, using eY[80)

aiDefInt[128	= laning data with regard of visibility (set by aiUpdateLaneData, using eY[80)

aiDefInt[144    = ch-lane CD (lane aspect)

--trigger g_taAITriggers
g_taAITriggers[O5]    =
g_taAITriggers[16+O5] =
g_taAITriggers[64+O5] = backing off
g_taAITriggers[80+O5] =first item buy
g_taAITriggers[96+O5] =chasing through fog
g_taAITriggers[112+O5] = for use per step of new item system

---laning priority:
hq[528+O5] = defense
hq[320+O5] = tower defense
hq[480+O5] = udv asking help
hq[576+O5] = changing lane
hq[848+O5] = gank cd (for lane-lock system)

new item system:
=================================================================
--item array g_aiItemsBuff
g_aiItemsBuff[O5*24+slotID] = temporary
g_aiItemsBuff[288+O5] = last delayed created item
g_aiItemsBuff[304+O5] = AI's boots
g_aiItemsBuff[320+O5] = item just dropped by AIDropMutedAct
g_aiItemsBuff[336+O5] = target item for aiRespondDroppedItem_uyv (substituting HW[32+ )


--integer array g_aiItemIDBuff
g_aiItemIDBuff[O5*24 + slotID]


--integer array g_aiItemInt
g_aiItemInt[O5] = first misc item (defensive)
g_aiItemInt[16+O5] = sec misc item (tactical consumable)

g_aiItemInt[32+O5] = core build step
g_aiItemInt[48+O5] = core build step (sim mode)

g_aiItemInt[64+O5] = callstack
g_aiItemInt[80+O5] = empty inventory

g_aiItemInt[96+O5] = terget single item
g_aiItemInt[112+O5] = target recipe item

g_aiItemInt[128+O5] = current ID of empty item buffer

g_aiItemInt[144+O5] = item phase

g_aiItemInt[160+O5] = substituting aiFinishedBuying by Bz (new item func only)
g_aiItemInt[176+O5] = substituting isUnitAtFountain by Bz (new item func only)

g_aiItemInt[192+O5] = total gold spent in sim mode

g_aiItemInt[208+O5] = child identifier for simulation mode's Sv/LdBool
g_aiItemInt[224+O5] = child identifier for sell mode's Sv/LdInt (prevent selling of fresh items, prevent double item combines)
g_aiItemInt[240+O5] = total core item step
g_aiItemInt[256+O5] = child identifier for bear items Sv/LdBool

g_aiItemInt[272+O5] = Bz based variable for per item step

g_aiItemInt[288+O5] = item with this index id will be ignored from AIDropMutedAct. Used for item picking.
g_aiItemInt[304+O5] = Bz based variable To reconsider sideshopping

g_aiItemInt[320+O5] = number of Ironwood Branches used To fill empty slots. These branches can be sold in sideshopping
g_aiItemInt[336+O5] = item to be sold if at least one part of upgrades is obtained
g_aiItemInt[352+O5] = child identifier for item counter's Sv/LdInt
g_aiItemInt[368+O5] = child identifier for item counter's Sv/LdInt (copy from 352+O5)

g_aiItemInt[384+O5] = default PT. 0 = no PT
g_aiItemInt[400+O5] = current PT
g_aiItemInt[416+O5] = mana percent to reach before switching back from Int PT.


--boolean array g_aiItemBool
g_aiItemBool[O5] = enable new item system
g_aiItemBool[16+ = has orb effect
g_aiItemBool[32+ = has buff placer
g_aiItemBool[48+ = sim mode
g_aiItemBool[64+ = allow the hero not to bring tp
g_aiItemBool[80+ = has entered LUX Mode

g_aiItemBool[96+ = item number initialized

g_aiItemBool[112+ = item requirement initialized (false = super-sim mode)

g_aiItemBool[128+ = signal to return to base on full stash

g_aiItemBool[144+ = a sub-recipe item is completed

g_aiItemBool[160+ = sim-mode has already entered Lux phase (buffer)
g_aiItemBool[176+ = sim-mode has already entered Lux phase (fix)

g_aiItemBool[192+ = g_ai_HasSecondBuild (mark of AI have second unit to build, i.e. Bear)

g_aiItemBool[208+ = return of last AIBuy_Core
g_aiItemBool[224+ = side-shop mode
g_aiItemBool[240+ = queue for side-shop mode
g_aiItemBool[256+ = side-shopping

g_aiItemBool[272+ = AI has all recipe items (if this is false, sideshopping cannot advance step)

g_aiItemBool[288+ = FORCEFIX - Disable sideshopping once bear is reached



---=============================================================================
"Usage of aiAbilities system"
- all data are saved in integer, rounded up if decimals.
- aiAbilities_Init -> initialize specific hero abilities data
- aiAbilities_InitSub -> save a single ability data. Syntax
	function aiAbilities_InitSub takes integer iAblCode, integer iCD1, integer iCD2, integer iCD3, integer iCD4, integer iCost1, integer iCost2, integer iCost3, integer iCost4, integer iRng1, integer iRng2, integer iRng3, integer iRng4, integer iAoE1, integer iAoE2, integer iAoE3, integer iAoE4 returns nothing
- Thus, to use the data is: LoadInteger(hash_aiAbilities,iAblCode,X)
  with X = iLevel +
		      	 0 for cooldown
			     4 for mana cost
			     8 for cast range
			     12 for AoE
- application: 	ga_rSkillCD[O5] = ulti
				ga_rSkillCD[16+O5] = spell1
				ga_rSkillCD[32+O5] = spell2
				ga_rSkillCD[48+O5] = spell3
