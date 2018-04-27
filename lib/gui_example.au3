#include <GUIConstants.au3>

Opt("GUIOnEventMode", 1)
Opt("GUICoordMode", 1)

$guiL = 300
$guiH = 100

GUICreate("GranB", $guiL, $guiH, @DesktopWidth - $guiL-10, @DesktopHeight - $guiH-WinGetPos("[CLASS:Shell_TrayWnd]", "")[3]-4, $WS_SIZEBOX)
GUISetOnEvent($GUI_EVENT_CLOSE, "Exit_")	;register close event

$eOutput = GuiCtrlCreateEdit("", 0, 0, $guiL, $guiH , BitOR( $ES_WANTRETURN, $WS_VSCROLL, $WS_HSCROLL, $ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY))
GUICtrlSetResizing($eOutput, $GUI_DOCKTOP+$GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKLEFT)
GUICtrlSetFont($eOutput, "8", 400, 0, "Lucida Console")
GUICtrlSetBkColor($eOutput, 0xFFFFFF)

GUISetState(@SW_SHOW)

$newdata=0
$lastdata = Null

While 1
    Sleep(1000) ; Sleep to reduce CPU usage
	$lastdata = $newdata & @CRLF & $lastdata
	GUICtrlSetData($eOutput,$lastdata)
	$newdata=$newdata+1
WEnd

Func Exit_()
    Exit()
EndFunc   ;==>Event1