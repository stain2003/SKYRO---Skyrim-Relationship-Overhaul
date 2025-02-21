Scriptname SKYROUtil  Hidden 
import StringUtil
import SKYROMisc


;------------UTIL FUNCTIONS-------------
Function ProcessAffinityUpdateString(String inputString, String QuestEDID = "") Global
	SKYRO main = GetMainScript()

	;This function is used to update Npc's QuestFavor stat and FactionAffinity stat towards Player
	string[] SplitedStrings = Split(inputString, "|")
	int StrNum = SplitedStrings.Length
	int iter = 0
	string outputstring = QuestEDID + " Completed! NPC's SV has changed:"
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
				outputstring = outputstring + "\n" + CurString + ": " + FavorValue + ", now is " + GetNPCFavor(CurNPC, Main.SRKey_QuestFavor)
			elseif (CurFaction)
				;------------------------look for faction entry------------------------
				IncreaseFactionFame(CurFaction,  FavorValue)
				outputstring = outputstring + "\n" + CurString + ": " + FavorValue + ", now is " + StorageUtil.GetIntValue(curForm, Main.SRKey_FactionFame)
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

;-----------GETTER & SETTER---------------
Function IncreaseFactionFame(Faction inFaction, int inValue) Global
	string SRKey_FactionFame = "SRK_FactionFame"
	string SRKey_QuestFavor = "SRK_QuestFavor"
	string SRKey_GiftFavor = "SRK_GiftFavor"

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

Function IncreaseGiftFavor(Actor NPC, int inValue) Global
	string SRKey_FactionFame = "SRK_FactionFame"
	string SRKey_QuestFavor = "SRK_QuestFavor"
	string SRKey_GiftFavor = "SRK_GiftFavor"

	int CurVal = StorageUtil.GetIntValue(NPC, SRKey_GiftFavor)
	StorageUtil.SetIntValue(NPC, SRKey_GiftFavor, curVal + inValue)
EndFunction

Function IncreaseQuestFavor(Actor NPC, int invalue) Global
	string SRKey_FactionFame = "SRK_FactionFame"
	string SRKey_QuestFavor = "SRK_QuestFavor"
	string SRKey_GiftFavor = "SRK_GiftFavor"

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

int Function GetNPCFavor(Actor NPC, string inKey) Global
	return StorageUtil.GetIntValue(NPC, inKey)
EndFunction

int Function GetNPCFactionFavor(Actor NPC) Global

	string SRKey_FactionFame = "SRK_FactionFame"
	string SRKey_QuestFavor = "SRK_QuestFavor"
	string SRKey_GiftFavor = "SRK_GiftFavor"

	Faction[] FactionList = NPC.GetFactions(0, 127)
	int FactionIndex = FactionList.Length
	int FactionFavorSum
	While (FactionIndex)
		FactionIndex -= 1
		FactionFavorSum += StorageUtil.GetIntValue(FactionList[FactionIndex], SRKey_FactionFame)
	EndWhile
	return FactionFavorSum
EndFunction

SKYRO Function GetMainScript() Global
	return Game.GetFormFromFile(0x000001, "SKYRO.esp") as SKYRO
EndFunction

int Function GetExternalInt(string modesp, int id) Global
	return (game.GetFormFromFile(id, modesp) as GlobalVariable).GetValueInt()
endfunction

bool Function isDebugEnable() Global
	return (GetExternalInt("SKYRO.esp", 0x001001) == 1)
EndFunction