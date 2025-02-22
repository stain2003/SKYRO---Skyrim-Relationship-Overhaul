Scriptname SKYRO_PlayerEffect extends activemagiceffect  

Import SKYROMisc
Import SKYROUtil

Event OnPlayerLoadGame()
    ModInit()
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
    ModInit()
EndEvent

Event OnMenuOpen(string menuName)
    If (menuName == "BarterMenu")
        Debug.MessageBox(PrintNPCAffinity(SKSEGetBarterNPC()))
    Elseif (menuName == "GiftMenu")
        Debug.MessageBox(SKSEGetBarterNPC().GetDisplayName())
    EndIf
endEvent

Function ModInit()
    RegisterForMenu("BarterMenu")
    RegisterForMenu("GiftMenu")
EndFunction