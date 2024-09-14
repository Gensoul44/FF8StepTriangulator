; Script written by Gensoul
; Version 1.1  9/14/2024
; Feel free to alter and share this script freely.

#include ImagePut.ahk
#singleinstance force

;
 ; Load footstep info from INI file
;

iniFile := FileOpen("FF8StepTriangulator.ini", 0)
initxt := iniFile.Read()
iniFile.Close
StepName := Array()
StepL := Array()
StepR := Array()
SanityCheck := 0
Loc := InStr(initxt, "[Footsteps]") +13
If (Loc = 13)
	Loc := 1
While !(SubStr(initxt,Loc,1) = "[") & (Loc < StrLen(initxt))
{
	If (SanityCheck++ > 100) || (Trim(SubStr(initxt, Loc, InStr(initxt, "`r`n", 0, Loc)-Loc)) = "") 
		Break
	StepName.Push SubStr(initxt, Loc, InStr(initxt, "`r`n", 0, Loc)-Loc)
	Loc := Instr(initxt,"`r`n",0,Loc) +2
	If (Loc = 2)
		Break
	StepL.Push SubStr(initxt, Loc, InStr(initxt, "`r`n", 0, Loc)-Loc)
	Loc := Instr(initxt,"`r`n",0,Loc) +2
	If (Loc = 2)
		Break
	StepR.Push SubStr(initxt, Loc, InStr(initxt, "`r`n", 0, Loc)-Loc)
	Loc := Instr(initxt,"`r`n",0,Loc) +2
	If (Loc = 2)
		Break
}
initxt := ""

;
 ; Start GUI
;

myGui := Constructor()
myGui.Show()

Constructor()
{	
	;
	 ; Create GUI
	;
	myGui := Gui()
	myGui.Title := "FF8 Step Triangulator v1.1"
	myGui.OnEvent('Close', (*) => ExitApp())

	myGui.Add("Text", "w60", "Field Name:")
	Field := myGui.Add("Edit", "ys w80",)
	myGui.Add("Text", "ys w60", "Step Sound:")
        Steps := myGui.Add("DropDownList", "ys w170 Choose1", StepName)

	myGui.Add("Text", "xm Section", "Triangle Numbers: (separated by commas or spaces)")
	Triangles := myGui.Add("Edit", "r6 w400")
	myGui.Add("Text", "xm w100 Section", "Output:")
	Global TriAdd := myGui.Add("Checkbox", "ys x+80 Checked", "Automatically add ctrl-clicked triangles")
	Output := myGui.Add("Edit", "r12 w400 xm")

	myBtn := MyGui.Add("Button", "Default r2 w400", "Copy to clipboard")
	myBtn.OnEvent("Click", MyBtn_Click) 

	Triangles.OnEvent("Change", Triangles_Change)
	Field.OnEvent("Change", Triangles_Change)
	Steps.OnEvent("Change", Triangles_Change)

	MyBtn_Click(btn, info)
	{
		A_Clipboard := Output.Value
	}

	;
	 ; Create Output - Runs on every input change
	;
	Triangles_Change(ctl, info)
	{
		Itxt := StrReplace(Trim(Triangles.Value), ",", " ") . " "
		Itxt := StrReplace(Itxt, "`n", " ")
		While Instr(Itxt,"  ")
			Itxt := StrReplace(Itxt,"  ", " ")
		Otxt := ""
		SanityCheck:= 0
		Loc := 1
		While Loc <= StrLen(Itxt)
		{
			If (SanityCheck++ > 1000)
				Break
			numtxt := SubStr(Itxt,Loc,Instr(Itxt," ",0,Loc)-Loc)
			Otxt .= "[" . Field.Value . "_" . numtxt . "_2]`r`n"
                        Otxt .= "shuffle = [ " . StepL[Steps.Value] . " ]`r`n`r`n"
			Otxt .= "[" . Field.Value . "_" . numtxt . "_3]`r`n"
                        Otxt .= "shuffle = [ " . StepR[Steps.Value] . " ]`r`n`r`n"
			Loc := Instr(Itxt," ",0,Loc) +1
		}
		Output.Value := StrReplace(Otxt, "__", "_")
	}
	Return myGui
}

;
 ; Triangle locator
;	
^LButton::
{
	if !WinExist("Deling")  ;Ensure Deling is running and set as default working window 
		Return
	StartTime := A_TickCount
	;
	 ; Locate various locations and sizes of Deling window areas
	;
	WinActivate
	CoordMode "Mouse", "Screen"
	MouseGetPos &MouseX, &MouseY
	WinGetClientPos &WinX, &WinY	
	ControlGetPos &x1, &y1, &x2, &y2, "Qt5152QWindowOwnDCIcon1"
	ControlClick "x" . x1+60 .  " y" . y1+y2+200
	x1 += WinX
	y1 += WinY
	if MouseX-x1 < 1 || MouseY-y1 < 1 || MouseX-x1 > x2 || MouseY-y1 > y2 
	{
		MsgBox "Error: Is mouse outside of walkmesh area?"
		Return
	}

	;
	 ; Click in Triangle Selection area and locate last triangle number
	;
	A_Clipboard := ""
	Sendinput "{End}^c"
	LastTriangle := 0
	Clipwait 1
	txt := SubStr(A_Clipboard,9)
	If txt != ""
		LastTriangle := Integer(txt)
	if !LastTriangle
	{
		MsgBox "Error: Can't select last triangle.`nMake sure Walkmesh tab is selected and triangle list is in view."
		Return
	}

	;colors := ""

        Range := 10
	;ColorsToFind := ["0xFF130B00", "0xFF1C1000", "0xFF703F00", "0xFF754200", "0xFF784400", "0xFF7F4800", "0xFF8E5000", "0xFFAA6000"]
	ColorsToFind := [0xFF130B00, 0xFF1C1000, 0xFF703F00, 0xFF754200, 0xFF784400, 0xFF7F4800, 0xFF8E5000, 0xFFAA6000, 0xFFFF900000, 0xFFC67000]
	Found := false

	;
	 ; Loop through triangles checking pixel colors around mouse area after each triangle switch
	;
	Loop LastTriangle
	{
		pic := ImagePutBuffer([MouseX-Range, MouseY-Range, Range*2, Range*2])
		Loop ColorsToFind.Length
			If pic.PixelSearch(ColorsToFind[A_Index])
			{ 
				Found := true
				ColorFound := ColorsToFind[A_Index]
				Break
			}
		if (Found = true)
			Break
		Sendinput "{Up}"
		sleep 1
	}
	if (Found = true)
	{
		A_Clipboard := ""
		Sendinput "^c"
		Clipwait 1
		Triangle := Integer(SubStr(A_Clipboard,9))
		A_Clipboard := Triangle
		Ttxt := "Found triangle " . Triangle . " after " . Round((A_TickCount - StartTime)/1000,1) . " seconds.`nColor: " . Format("0x{1:X}",ColorFound)
		If TriAdd.Value
		{
			ControlSendText " " . Triangle, "Edit2", "FF8 Step Triangulator"
			Ttxt .= "`nTriangle number added to Triangle Box and saved to clipboard."
		}
		else
			Ttxt .= "`nTriangle number saved to clipboard."
	} 
	Else
		Ttxt := " Not found after " . Round((A_TickCount - StartTime)/1000,1) . " seconds." 
	Tooltip Ttxt
	SetTimer () => ToolTip(), -3000
}
