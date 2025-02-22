Scriptname SKYROMisc  Hidden 
;This script contains functions that calls SKSE or other miscellaneous mathematic API


Form Function GetFormByEditorID(string refEditorID) Global native

;Used for SKSE, save current NPC's inventory for comparation later
Function SKSEGetNPCInventory(Actor TargetNPC) Global native

;Print gifts given to NPC to "Data/SkyRomance/Log/GivenGiftsLog.json"
Function GetAddedItems(Actor TargetNPC) Global native

actor Function SKSEGetBarterNPC() Global native

;Remap input value leanerily by given input/output range
float Function IntLeanearRemap(int value, int input_min, int input_max, int output_min, int output_max) Global

    if(value > input_max)
        value = input_max
    ElseIf(value < input_min)
        value = input_min
    Endif
 
    float Out = value * ((output_max - output_min) / (input_max - input_min) as float)  + output_min
    return Out

EndFunction