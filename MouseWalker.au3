#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         CoffeeCone
 Website:        http://coffeecone.com/mousewalker

 Name: PokeMMO MouseWalker
 Version: 1.0
 Description:
	Allows character movement by holing down the middle mouse button and moving
	the mouse to the desired location.

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#Region
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=MouseWalker is a tool for PokeMMO that implements mouse-based walking using the middle mouse button.
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=CoffeeCone.com
#EndRegion

#include <Misc.au3>

If Not FileExists("PokeMMO.exe") Then
	MsgBox(16, "Error", "Could not find 'PokeMMO.exe'. Please make sure you have downloaded this from http://pokemmo.eu to ensure the integrity of the package.")
	Exit
EndIf
If Not FileExists("mousewalker.ini") Then
	MsgBox(16, "Error", "Could not find 'mousewalker.ini'. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
EndIf
$ini = IniReadSection("mousewalker.ini", "Mapping")

Dim $keymap[4]
Dim $keyup[4]

If @error Then
	MsgBox(48, "Error", "Invalid 'mousewalker.ini' file. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
Else
    For $i = 1 To $ini[0][0]
		Switch ($ini[$i][0])
			Case "KEY_UP"
				$keymap[0] = $ini[$i][1]
			Case "KEY_DOWN"
				$keymap[1] = $ini[$i][1]
			Case "KEY_LEFT"
				$keymap[2] = $ini[$i][1]
			Case "KEY_RIGHT"
				$keymap[3] = $ini[$i][1]
		EndSwitch
    Next
EndIf

$keyup[0] = "{" & $keymap[0] & " up}"
$keyup[1] = "{" & $keymap[1] & " up}"
$keyup[2] = "{" & $keymap[2] & " up}"
$keyup[3] = "{" & $keymap[3] & " up}"

$keymap[0] = "{" & $keymap[0] & " down}"
$keymap[1] = "{" & $keymap[1] & " down}"
$keymap[2] = "{" & $keymap[2] & " down}"
$keymap[3] = "{" & $keymap[3] & " down}"

If (WinWait("[CLASS:LWJGL]","",5) = 0) Then
	MsgBox(48, "Error", "PokeMMO doesn't seem to be running. Please make sure it's running first.")
	Exit
EndIf

$dll = DllOpen("user32.dll")

While 1
	If Not WinExists("[CLASS:LWJGL]") Then
		ExitLoop
	EndIf

	Sleep(250)

	If WinActive("[CLASS:LWJGL]") Then
		$mouse = MouseGetPos()

		$window = WinGetClientSize("[CLASS:LWJGL]")
		$window[0] = $window[0]/2
		$window[1] = $window[1]/2

		If _IsPressed("04", $dll) Then
			Send($keyup[0])
			Send($keyup[1])
			Send($keyup[2])
			Send($keyup[3])

			If $window[0] > $mouse[0] Then
				Send($keymap[2])
			Else
				Send($keymap[3])
			EndIf

			If (($window[0] > $mouse[0]) AND (($window[0] - $mouse[0]) < 100)) OR (($mouse[0] > $window[0]) AND (($mouse[0] - $window[0]) < 100)) Then
				If $window[1] > $mouse[1] Then
					Send($keymap[0])
				Else
					Send($keymap[1])
				EndIf
			EndIf
		Else
			Send($keyup[0])
			Send($keyup[1])
			Send($keyup[2])
			Send($keyup[3])
		EndIf
	EndIf

WEnd

DllClose($dll)
Exit