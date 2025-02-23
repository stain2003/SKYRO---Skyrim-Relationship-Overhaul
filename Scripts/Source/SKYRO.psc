Scriptname SKYRO extends Quest  
import PapyrusUtil
import StringUtil
import SKYROUtil

string Property SR_ModName = "SKYRO.esp" auto

string Property SRPath_ObjectiveMap = "Data/SkyRomance/ObjectiveMap.json" auto
string Property SRPath_QuestMap = "Data/SkyRomance/QuestMap.json" auto
string Property SRPath_GivenGiftsLog = "Data/SkyRomance/Log/GivenGiftsLog.json" auto
string Property SRPath_NPCFavorGift = "Data/SkyRomance/NPCFavorGift.json" auto

;Quest Function Related
Quest RecentQuest
int RecentFailedQuest
int RecentCompletedQuest

Actor Property LastActivateActor auto

string property SRKey_FactionFame = "SRK_FactionFame" auto
string Property SRKey_QuestFavor = "SRK_QuestFavor" auto
string property SRKey_GiftFavor = "SRK_GiftFavor" auto


Event Oninit()
	InitEvents()
    InitDebugFunction()
EndEvent

event OnLoadGameGlobal()
	InitEvents()
    InitDebugFunction()
EndEvent

Event OnQuestObjectiveStateChangedGlobal(Quest akQuest, string displayText, int oldState, int newState, int objectiveIndex, alias[] ojbectiveAliases)
	;Dormant = 0;Displayed = 1;Completed = 2;CompletedDisplayed = 3;Failed = 4;FailedDisplayed = 5
	;debug.trace("Quest objective changed: " + objectiveIndex + "/" + displayText + "\n" + "newState: " + newState + " | oldState: " + oldState)

	RecentQuest = akQuest
	If RecentQuest.IsStopped()	;Send quest completed/failed event
		int QuestID = akQuest.GetFormID()
		If newstate == 2 || newstate == 3
			If (RecentCompletedQuest != QuestID)
				;Send quest completed event
				SendModEvent("SRQuestCompleted", akQuest.GetID(), akQuest.GetFormID() as float)
				RecentCompletedQuest = QuestID
			EndIf
		Else
			If (RecentFailedQuest != QuestID)
				;Send quest failed
				;RecentFailedQuest is used to check to prevent multiple call upon a quest failed!
				SendModEvent("SRQuestFailed", akQuest.GetID())
				RecentFailedQuest = QuestID
			EndIf
		endif
	else
		;Deprecated
	EndIf
	;Send objective completed event
	If (newState == 3 && oldState != 3)
		SendModEvent("SRQuestObjectiveUpdated", akQuest.GetID(), objectiveIndex)
	EndIf
	
	;debug.trace(akQuest.GetID() + displayText + " [" + objectiveIndex + "] " + " completed")
EndEvent

Event OnKeyDown(int KeyPress)

	if KeyPress == 34
		;Debug NPC's stat
		actor Target = game.GetCurrentCrosshairRef() as actor
		If (target)
			if  (target.IsInCombat() || OUtils.IsChild(target) || target.isdead() || !(target.GetRace().HasKeyword(Keyword.GetKeyword("ActorTypeNPC"))))
				return 
			endif
			IncreaseGiftFavor(Target, 10)
			IncreaseQuestFavor(Target, 10)
        else
		Endif
	EndIf

	If KeyPress == 35
        ;Debug.messagebox("Key Pressed!")
		Perk BarterPerk = game.GetFormFromFile(0x002007, "SKYRO.esp") as Perk
		If (game.GetPlayer().HasPerk(BarterPerk))
			game.GetPlayer().Removeperk(BarterPerk)
		else
			game.GetPlayer().AddPerk(BarterPerk)
		EndIf
        ;OnQuestCompletedEvent("0", "MS13", 0, game.getplayer() as form)
	Endif
EndEvent

;---------------------------------------------On Quest Update Event----------------------------------------------------------
Event OnQuestCompletedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	;_args: EditorID
	;_argc: FormID
	;Map validation
	int QuestMap = JValue.readFromFile(SRPath_QuestMap)
	if (QuestMap == 0)
		debug.Notification("Invalid QuestMap.Json!!!")
		return
	else
		;ReadString
		String RelationShipChangelist = JMap.getStr(QuestMap, _args)
		If (RelationShipChangelist != "")
			SKYROUtil.ProcessAffinityUpdateString(RelationShipChangelist, _args)
		Else
			Debug.Notification("Invalid or can't find Quest EditorID: " + _args + " !")
		Endif
	Endif
Endevent

Event OnQuestFailedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	Debug.Notification("Mod Event:\n" + _args + ": is failed")
	;TODO: same as QuestCompletedEvent
EndEvent

Event OnQuestObjectiveUpdatedEvent(String _eventName, String _args, Float _argc = 1.0, Form _sender)
	;_args: EditorID
	;_argc: Completed objective
	;Map validation
	int Index = _argc as int
	int ObjectiveMap = JValue.readFromFile(SRPath_ObjectiveMap)
	if (ObjectiveMap == 0)
		Debug.Notification("Can't find: " + SRPath_ObjectiveMap)
		return
	Endif

	;Reading objective update string
	String Objective = _args + "/" + Index
	String RelationShipChangelist = JMap.getStr(ObjectiveMap, Objective)
	If (RelationShipChangelist != "")
		SKYROUtil.ProcessAffinityUpdateString(RelationShipChangelist, _args + "/" + _argc as int)
	Else
		If (SKYROUtil.isDebugEnable())
			Debug.Notification("Invalid Quest objective EditorID! \nOr can't find objective in QuestMap.json:\n" + Objective)
		EndIf
	Endif
EndEvent

;----------------------------------------------------FUNCTIONS-----------------------------------------------------
Function InitEvents()
    DbSkseEvents.RegisterFormForGlobalEvent("OnQuestObjectiveStateChangedGlobal", self)
	;DbSkseEvents.RegisterFormForGlobalEvent("OnActivateGlobal", self)

	RegisterForModEvent("SRQuestCompleted", "OnQuestCompletedEvent")
	RegisterForModEvent("SRQuestFailed", "OnQuestFailedEvent")
	RegisterForModEvent("SRQuestObjectiveUpdated", "OnQuestObjectiveUpdatedEvent")
	; Spell BarterSpell = game.GetFormFromFile(0x002004, "SKYRO.esp") as spell
	; BarterSpell.SetNthEffectMagnitude(0, 0)
	; game.GetPlayer().AddSpell(BarterSpell)
EndFunction

Function InitDebugFunction()
    RegisterForKey(34)
	RegisterForKey(35)
EndFunction

Function WriteAddedItemsToJson(string[] itemkey, int[] count)
    SKYRO Main = SKYROUtil.GetMainScript()
	int fMap =  JMap.object()
	
	int len = itemkey.Length
	int i = 0
	string DebugString = "These items are given:"
	while i < len
		DebugString += "\n" + itemkey[i] + " x" + count[i]
		JMap.setInt(fMap, itemkey[i], count[i])
		i += 1
	Endwhile
	JValue.writeToFile(fMap, Main.SRPath_GivenGiftsLog)

	If (SKYROUtil.isDebugEnable())
		Debug.MessageBox(DebugString)
	EndIf
EndFunction