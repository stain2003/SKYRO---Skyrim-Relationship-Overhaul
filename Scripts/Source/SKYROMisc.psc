Scriptname SKYROMisc  Hidden 
;This script contains functions that calls SKSE or other miscellaneous mathematic API


Form Function GetFormByEditorID(string refEditorID) Global native

;Used for SKSE, save current NPC's inventory for comparation later
Function SKSEGetNPCInventory(Actor TargetNPC) Global native

;Print gifts given to NPC to "Data/SkyRomance/Log/GivenGiftsLog.json"
Function GetAddedItems(Actor TargetNPC) Global native

actor Function SKSEGetBarterNPC() Global native

;(Deprecated):Remap input value leanerily by given input/output range
float Function IntLeanearRemap(int value, int input_min, int input_max, int output_min, int output_max) Global

    if(value > input_max)
        value = input_max
    ElseIf(value < input_min)
        value = input_min
    Endif
 
    float Out = value * ((output_max - output_min) / (input_max - input_min) as float)  + output_min
    return Out

EndFunction

float Function FloatLeanearRemap(float value, float input_Start, float input_End, float output_Start, float output_End) Global

    if(value > input_End)
        value = input_End
    ElseIf(value < input_Start)
        value = input_Start
    Endif

    float Out = ((value - input_Start) * (output_End - output_Start)) / (input_End - input_Start) + output_Start

    If (Out < output_Start)
        Out = output_Start
    EndIf

    If (Out > output_End)
        Out = output_End
    EndIf
    
    return Out

EndFunction
