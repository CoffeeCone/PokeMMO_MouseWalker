#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Author:         CoffeeCone
 Website:        http://coffeecone.com/mousewalker

 Name: PokeMMO MouseWalker
 Version: 1.1
 Description:
	Allows character movement by holing down the middle mouse button and moving
	the mouse to the desired location.

#ce ----------------------------------------------------------------------------

#Region
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=MouseWalker is a tool for PokeMMO that implements mouse-based walking using the middle mouse button.
#AutoIt3Wrapper_Res_Description=CoffeeCone.com
#AutoIt3Wrapper_Res_Fileversion=1.1
#AutoIt3Wrapper_Res_LegalCopyright=CoffeeCone.com
#EndRegion
#NoTrayIcon

#include <Misc.au3>
#include <WinHttp.au3>

; Check if configuration file is present.
; If not, show error.
If Not FileExists("mousewalker.ini") Then
	MsgBox(16, "Error", "Could not find 'mousewalker.ini'. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
EndIf

; Declare arrays and variable which will be used later.
Dim $keymap[4]
Dim $keyup[4]
Dim $settings[7]
Dim $client

; Read configuration file for settings.
$ini = IniReadSection("mousewalker.ini", "Settings")

; Check if configuration file is a valid INI.
; If invalid, show error.
If @error Then
	MsgBox(48, "Error", "Invalid 'mousewalker.ini' file. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
Else

	; Assign each of the defined keys to their respective array nodes.
    For $i = 1 To $ini[0][0]
		Switch ($ini[$i][0])
			Case "VERSION"
				$settings[0] = $ini[$i][1]
			Case "CHECK_UPDATES"
				$settings[1] = $ini[$i][1]
			Case "LAUNCHER_MODE"
				$settings[2] = $ini[$i][1]
			Case "CONFIRM_MESSAGE"
				$settings[3] = $ini[$i][1]
			Case "MINIMUM_MEMORY"
				$settings[4] = $ini[$i][1]
			Case "MAXIMUM_MEMORY"
				$settings[5] = $ini[$i][1]
			Case "OFFSET"
				$settings[6] = $ini[$i][1]
		EndSwitch
    Next

EndIf

; Check INI version against program version.
$oldver = FileGetVersion(@AutoItExe,"Fileversion")
If $settings[0] <> $oldver Then
	MsgBox(48, "Error", "Mismatched 'mousewalker.ini' file version. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
EndIf

; Check if updates are allowed.
If $settings[1] = "true" Then

	; Get latest version.
	$ver = HttpGet("http://s.coffeecone.com/mousewalker/latestversion.txt")

	; Check if compiled and if there's no error with retriving version.
	; If an error occurs, skip checking and continue on.
	; If no errors occur, ask the user if they want to download the latest version or not.
	If (@Compiled) AND (Not @error) Then
		If $oldver <> $ver Then

			; If the user decides to download the new version, the program will exit.
			If MsgBox(68, "MouseWalker - New Version Available", "You currently have version '" & $oldver & "'. However, there is a newer version '" & $ver & "' available." & @CRLF & @CRLF & "Would you like to download the update?") = 6 Then
				ShellExecute("http://coffeecone.com/mousewalker")
				Exit
			EndIf

		EndIf
	EndIf

EndIf

; Read configuration file for key mapping.
$ini = IniReadSection("mousewalker.ini", "Mapping")

; Check if configuration file is a valid INI.
; If invalid, show error.
If @error Then
	MsgBox(48, "Error", "Invalid 'mousewalker.ini' file. Please make sure you have downloaded this from http://coffeecone.com/mousewalker to ensure the integrity of the package.")
	Exit
Else

	; Assign each of the defined keys to their respective array nodes.
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

; Fill up key release array nodes.
$keyup[0] = "{" & $keymap[0] & " up}"
$keyup[1] = "{" & $keymap[1] & " up}"
$keyup[2] = "{" & $keymap[2] & " up}"
$keyup[3] = "{" & $keymap[3] & " up}"

; Fill up key press array nodes.
$keymap[0] = "{" & $keymap[0] & " down}"
$keymap[1] = "{" & $keymap[1] & " down}"
$keymap[2] = "{" & $keymap[2] & " down}"
$keymap[3] = "{" & $keymap[3] & " down}"

; Check if launcher mode is enabled.
If $settings[2] = "true" Then

	; Check if in the same directory as PokeMMO.
	If Not FileExists("PokeMMO.exe") Then
		MsgBox(16, "Error", "Could not find 'PokeMMO.exe'. Please make sure you have downloaded this from http://pokemmo.eu to ensure the integrity of the package.")
		Exit
	EndIf

	$client = Run("javaw.exe -Xms" & $settings[4] & "M -Xmx" & $settings[5] & "M -ea -cp ./lib/*;pokemmo.exe com.pokeemu.client.Client", @ScriptDir)
	If $client = 0 Then
		MsgBox(16, "Error", "Could not find your Java installation. Please make sure you have installed Java correctly.")
		Exit
	EndIf

	WinWait("[CLASS:LWJGL; TITLE:PokeMMO]")
	WinActivate("[CLASS:LWJGL; TITLE:PokeMMO]")
EndIf

; Wait for PokeMMO window to be present.
If (WinWait("[CLASS:LWJGL; TITLE:PokeMMO]","",5) = 0) Then

	; If not detected within 5 seconds, program will exit.
	MsgBox(48, "Error", "PokeMMO doesn't seem to be running. Please make sure it's running first.")
	Exit

Else

	; Check if confirmation message is enabled.
	If ($settings[3] = "true") AND ($settings[2] = "false") Then

		; If detected, message is shown to confirm.
		; The message will auto-close after 10 seconds.
		MsgBox(64, "Success!", "MouseWalker is now active and will automatically close after you exit PokeMMO.", 10)

	EndIf

EndIf

; Open user32.dll to hook to mouse button detection.
$dll = DllOpen("user32.dll")

; Main loop for detecting mouse button clicks.
While 1

	; If PokeMMO window doesn't exist anymore (a.k.a. closed), exit the program too.
	If Not WinExists("[CLASS:LWJGL; TITLE:PokeMMO]") Then
		ExitLoop
	EndIf

	; Pause for 250 milliseconds to give the processor some timee to breathe.
	Sleep(250)

	; Check if PokeMMO is the active window.
	; This is done so that the key binding will not work outside the game and will not interfere with other programs.
	If WinActive("[CLASS:LWJGL; TITLE:PokeMMO]") Then

		; I'm not gonna explain what's going on below because it's all just logic.

		$mouse = MouseGetPos()

		$window = WinGetClientSize("[CLASS:LWJGL; TITLE:PokeMMO]")
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

			If (($window[0] > $mouse[0]) AND (($window[0] - $mouse[0]) < Int($settings[6]))) OR (($mouse[0] > $window[0]) AND (($mouse[0] - $window[0]) < Int($settings[6]))) Then
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

; Release user32.dll.
DllClose($dll)

Exit