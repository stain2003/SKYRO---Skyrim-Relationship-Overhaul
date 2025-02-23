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
        Utility.Wait(0.5)
        actor Target = GetMainScript().LastActivateActor
        If (Target)
            float Mag = FloatLeanearRemap(GetNPCTotalFavor(Target), -35, 35, 1.5, 0.5)
            Debug.MessageBox(GetNPCTotalFavor(Target) + ":" + Mag)
            Mag = ClampF(Mag, 1.5, 0.5)
            AmplifyPlayerSpeech(Mag)
        else
            Debug.messagebox("Not valid target")
        EndIf
    EndIf
endEvent

Event OnMenuClose(string menuName)
    If (menuName == "BarterMenu")
    Elseif (menuName == "GiftMenu")
    Elseif (menuName == "Dialogue Menu")
        ; Spell BarterSpell = game.GetFormFromFile(0x002004, "SKYRO.esp") as spell
        ; game.GetPlayer().RemoveSpell(BarterSpell)
    EndIf
endEvent

Function ModInit()
    RegisterForMenu("BarterMenu")
    RegisterForMenu("GiftMenu")
    RegisterForMenu("Dialogue Menu")
EndFunction