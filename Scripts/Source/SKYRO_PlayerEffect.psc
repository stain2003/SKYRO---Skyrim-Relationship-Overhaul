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
    Elseif (menuName == "GiftMenu")

    Elseif (menuName == "Dialogue Menu")
        ; actor Target = game.GetCurrentCrosshairRef() as actor
        ; If (Target)
        ;     ;Debug.MessageBox(PrintNPCAffinity(NPC))
        ;     AmplifyPlayerSpeech(GetNPCTotalFavor(Target))
        ; else
        ;     Debug.messagebox("Not valid target under crosshair")
        ; EndIf
        Utility.Wait(0.5)
        actor Target = GetMainScript().LastActivateActor
        If (Target)
            ;Debug.MessageBox(PrintNPCAffinity(NPC))
            AmplifyPlayerSpeech(GetNPCTotalFavor(Target))
        else
            Debug.messagebox("Not valid target under crosshair")
        EndIf
    EndIf
endEvent

Event OnMenuClose(string menuName)
    If (menuName == "BarterMenu")
    Elseif (menuName == "GiftMenu")
    Elseif (menuName == "Dialogue Menu")
        Spell BarterSpell = game.GetFormFromFile(0x002004, "SKYRO.esp") as spell
        game.GetPlayer().RemoveSpell(BarterSpell)
    EndIf
endEvent

Function ModInit()
    RegisterForMenu("BarterMenu")
    RegisterForMenu("GiftMenu")
    RegisterForMenu("Dialogue Menu")
EndFunction