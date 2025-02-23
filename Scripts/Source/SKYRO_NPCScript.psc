Scriptname SKYRO_NPCScript extends activemagiceffect  

Import SKYROMisc
Import SKYROUtil

; Event OnPlayerLoadGame()
;     ModInit()
; EndEvent

; Event OnEffectStart(Actor akTarget, Actor akCaster)
;     ModInit()
; EndEvent

; Event OnMenuOpen(string menuName)
;     If (menuName == "BarterMenu")
;     Elseif (menuName == "GiftMenu")
;     Elseif (menuName == "Dialogue Menu")
;         ;Debug.MessageBox("NPC talking: \n" + GetCasterActor().GetDisplayName())
;     EndIf
; endEvent

; Event OnMenuClose(string menuName)
;     If (menuName == "BarterMenu")
;     Elseif (menuName == "GiftMenu")
;     Elseif (menuName == "Dialogue Menu")
;     EndIf
; endEvent

; Function ModInit()
;     RegisterForMenu("BarterMenu")
;     RegisterForMenu("GiftMenu")
;     RegisterForMenu("Dialogue Menu")
; EndFunction

Event OnActivate(ObjectReference akActionRef)
    ;Debug.MessageBox(GetCasterActor().GetDisplayName() + " activated!")
    GetMainScript().LastActivateActor = GetCasterActor()
EndEvent