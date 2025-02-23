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

Function ProcessGifts(Actor NPC, float TotalValue) Global
	;Make maps: 1. Given gifts 2. Npc favor
	int GivenGiftLog = JValue.readFromFile(GetMainScript().SRPath_GivenGiftsLog)
	string[] GiftEditID = JMap.allKeysPArray(GivenGiftLog)

	int NPCFavorMap = JValue.readFromFile(GetMainScript().SRPath_NPCFavorGift)
	string NPCFavorString = JMap.getStr(NPCFavorMap, NPC.GetDisplayName())
	string[] NPCFavorList = Split(NPCFavorString, "|")

	Debug.Trace(NPC.GetDisplayName() + "'s Favor string: " + NPCFavorString)

	Debug.Trace("Now making a map to store " + NPC.GetDisplayName() + "'s favor keywords of gifts!")

	int FavorGiftMap = JMap.object()
	int FavorIndex = NPCFavorList.Length
	int FavorValue
	while (FavorIndex)
		FavorIndex -= 1
		string CurFavor = NPCFavorList[FavorIndex]
		Debug.trace("Current string: " + CurFavor)

		If (Substring(CurFavor, 0, 1) != "-" && Substring(CurFavor, 0, 1) != "+") ;Check if this string is a keyword
			JMap.Setint(FavorGiftMap, CurFavor, FavorValue)
			debug.trace("Favor keyword added: " + CurFavor + ": " + FavorValue + " ! ")
		Else; this string is an int multiplier
			FavorValue = Substring(CurFavor, 1, GetLength(CurFavor) - 1) as int

			if (Substring(CurFavor, 0, 1) == "-")
				FavorValue = -FavorValue;negate
			Endif

			Debug.Trace("Favor value changed to: " + FavorValue)
		EndIf

	Endwhile
	;End of making map

	;Loop through all gifts, fore each type of gift, get npc's favors, and find if any of them in current 
	int GiftIndex = GiftEditID.Length
	int GiftFavorToAdd
	While (GiftIndex)
		GiftIndex -= 1
		;--------------------------------------Gifts loop---------------------------------------
		;Current gift
		Debug.Trace("Current gift: " + GiftEditID[GiftIndex])
		string CurGift = GiftEditID[GiftIndex]
		Form CurGiftForm = GetFormByEditorID(CurGift)
		Keyword[] GiftKeywords = CurGiftForm.GetKeywords()

		if (JMap.hasKey(FavorGiftMap, CurGift))
			;if this gift is in NPC's favor list
			int GiftFavor = JMap.getInt(FavorGiftMap, CurGift) * JMap.getInt(GivenGiftLog, CurGift);Favor mult * count
			GiftFavorToAdd += GiftFavor
		Else
			int keywordindex = GiftKeywords.Length
			While (keywordindex)
				keywordindex -= 1
				;-------------------------------Keywords loop---------------------------------------
				Debug.Trace("Searching for keyword in NPC's interest list: " + GiftKeywords[keywordindex].GetString())
				;Current keyword
				string CurKeyword = GiftKeywords[keywordindex].GetString()
				if (JMap.hasKey(FavorGiftMap, CurKeyword))
					;If this keyword is in NPC's favor list
					Debug.Trace(NPC.GetDisplayName() + " like " + CurKeyword + "!")
					int CurKeywordFavorValue = JMap.getInt(FavorGiftMap, CurKeyword) * JMap.getInt(GivenGiftLog, CurGift)
					GiftFavorToAdd += curkeywordfavorvalue
				Endif
			EndWhile
		Endif
	EndWhile

	;Set gift favor sv for NPC
	GiftFavorToAdd = (GiftFavorToAdd * (TotalValue / 100)) as int
	;return GiftFavorToAdd
	IncreaseGiftFavor(NPC, GiftFavorToAdd)
	; Debug.Trace("Gift favor added: " + GiftFavorToAdd + " ! ")

EndFunction

String Function PrintNPCAffinity(Actor NPC) Global
	String OutputString = NPC.GetDisplayName() + "'s Affinity:"
	OutputString += "\nQuest Favor: " + GetNPCFavor(NPC, GetMainScript().SRKey_QuestFavor)
	OutputString += "\nGift Favor: " + GetNPCFavor(NPC, GetMainScript().SRKey_GiftFavor)
	OutputString += "\nFaction Fame: " + GetNPCFactionFavor(NPC)
	return OutputString
EndFunction

float Function ClampF(float in, float Max, float Min) Global
	If (in > max)
		return Max
	EndIf

	If (in < Min)
		return Min
	EndIf
EndFunction

Function AmplifyPlayerSpeech(float Magnitude = 1.0) Global
	Perk BarterPerk = game.GetFormFromFile(0x002007, "SKYRO.esp") as Perk

	;selling
	BarterPerk.SetNthEntryValue(0,0,2 - Magnitude)
	;buying
	BarterPerk.SetNthEntryValue(1,0,Magnitude)
	game.GetPlayer().AddPerk(BarterPerk)

	;Debug.MessageBox(BarterPerk.GetName() + " * " + Magnitude + ": " + "\n" + BarterPerk.GetNthEntryValue(0, 0) + "\n" + BarterPerk.GetNthEntryValue(1, 0))
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
	Faction[] FactionList = NPC.GetFactions(0, 127)
	string FactionFameKey = GetMainScript().SRKey_FactionFame
	Int FactionIndex = FactionList.Length
	Int FactionFameSum

	while FactionIndex
		FactionIndex -= 1
		if(StorageUtil.HasIntValue(FactionList[FactionIndex], FactionFameKey))
			FactionFameSum += StorageUtil.GetIntValue(FactionList[FactionIndex], FactionFameKey)
		EndIf
	EndWhile

	Return FactionFameSum
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

int Function GetNPCTotalFavor(Actor NPC) Global

	int FavorPoint
	FavorPoint += GetNPCFavor(NPC, GetMainScript().SRKey_QuestFavor)
	FavorPoint += GetNPCFavor(NPC, GetMainScript().SRKey_GiftFavor)
	FavorPoint += GetNPCFactionFavor(NPC)

	Return FavorPoint
EndFunction