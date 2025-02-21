Scriptname SKYROUtil  Hidden 
import StringUtil

string ModName = "SKYRO.esp"
int MainQuestID = 0x000001
int GVSRDebugEnabled = 0x001001

string Property SRKey_FactionFame = "SRK_FactionFame" Auto
string Property SRKey_QuestFavor = "SRK_QuestFavor" Auto
string Property SRKey_GiftFavor = "SRK_GiftFavor" Auto

Form Function GetFormByEditorID(string refEditorID) Global native

int Function GetExternalInt(string modesp, int id)
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt()
endfunction

bool Function isDebugEnable()
	return (GetExternalInt(ModName, GVSRDebugEnabled) == 1)
EndFunction

Function ProcessAffinityUpdateString(String inputString)
	Debug.MessageBox("Processing String!!!")
	;This function is used to update Npc's QuestFavor stat and FactionAffinity stat towards Player
	string[] SplitedStrings = Split(inputString, "|")
	int StrNum = SplitedStrings.Length
	int iter = 0
	string outputstring = "Quest Objective Completed! NPC's SV has changed:"
	int FavorValue
	while iter < StrNum
		String CurString = SplitedStrings[iter]
		Form curForm = GetFormByEditorID(CurString)

		If (curForm) ;Check to see if current string is EditorID or int value
			Actor CurNPC = GetFormByEditorID(CurString + "REF") as Actor
			Faction CurFaction = GetFormByEditorID(CurString) as Faction

			If (CurNPC) 
				;------------------------look for npcs entry----------------------------
				IncreaseQuestFavor(CurNPC, FavorValue)
				outputstring = outputstring + "\n" + CurString + ": " + FavorValue + ", now is " + GetNPCFavor(CurNPC, SRKey_QuestFavor)
			elseif (CurFaction)
				;------------------------look for faction entry------------------------
				IncreaseFactionFame(CurFaction,  FavorValue)
				outputstring = outputstring + "\n" + CurString + ": " + FavorValue + ", now is " + StorageUtil.GetIntValue(curForm, SRKey_FactionFame)
			Elseif (isDebugEnable())
				Debug.Notification("This editorID is not what we look for: " + CurString)
				Debug.trace("This editorID is not what we look for: " + CurString)
			endif
		else
			;Update SVOffset
			FavorValue = Substring(CurString, 1, GetLength(CurString) - 1) as int
			if (FavorValue == 0 && isDebugEnable())
				Debug.Notification("Invalid editorID entry: " + CurString)
				Debug.trace("Invalid editorID entry: " + CurString + " | Source: " + inputString)
			Endif
			
			String FirstChar = substring(CurString, 0, 1)
			If (FirstChar == "-")
				FavorValue = -FavorValue
			EndIf
		EndIf
		iter += 1
	EndWhile
	If (isDebugEnable())
		debug.Trace(outputstring)
		debug.messagebox(outputstring)
	EndIf
EndFunction

;-----------Set and get value from StorageUtil--------------------

Function IncreaseFactionFame(Faction inFaction, int inValue)
	int CurVal = StorageUtil.GetIntValue(inFaction as Form, SRKey_FactionFame)
	StorageUtil.SetIntValue(inFaction as Form, SRKey_FactionFame, curVal + inValue)

	If (isDebugEnable())
		If (inFaction)
			Debug.notification("Fame of " + (inFaction as form).GetName() + " increased by " + inValue + ", now is: " + StorageUtil.GetIntValue(inFaction as Form, SRKey_FactionFame))
		else
			Debug.notification("Faction is not valid!")
		EndIf
	EndIf
EndFunction

Function IncreaseGiftFavor(Actor NPC, int inValue)
	int CurVal = StorageUtil.GetIntValue(NPC, SRKey_GiftFavor)
	StorageUtil.SetIntValue(NPC, SRKey_GiftFavor, curVal + inValue)
EndFunction

Function IncreaseQuestFavor(Actor NPC, int invalue)
	;This function will increase Npc's QuestFavor value for a permenant impact, also like stat for a tempory 'buff'.
	int curVal = GetNPCFavor(NPC, SRKey_QuestFavor)
	If (curVal < 20)
		StorageUtil.SetIntValue(NPC, SRKey_QuestFavor, curVal + inValue)
		; If (isDebugEnable())
		; 	Debug.notification(NPC.GetDisplayName() + "'s Quest Favor increased by " + invalue + "; Now is: " + ORomance.GetQuestFavorStat(NPC))
		; EndIf
	else
		If (isDebugEnable())
			Debug.notification(NPC.GetDisplayName() + "'s Quest Favor is already maxed!")
		Endif
	EndIf
Endfunction

int Function GetNPCFavor(Actor NPC, string inKey)
	return StorageUtil.GetIntValue(NPC, inKey)
EndFunction

int Function GetNPCFactionFavor(Actor NPC)
	Faction[] FactionList = NPC.GetFactions(0, 127)
	int FactionIndex = FactionList.Length
	int FactionFavorSum
	While (FactionIndex)
		FactionIndex -= 1
		FactionFavorSum += StorageUtil.GetIntValue(FactionList[FactionIndex], SRKey_FactionFame)
	EndWhile
	return FactionFavorSum
EndFunction