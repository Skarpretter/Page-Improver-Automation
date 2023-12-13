;----------------------------------------------------------------------------
/*
   _____          __        __________.__ 
  /  _  \  __ ___/  |_  ____\______   \  |	Espen Rabben Sakariassen
 /  /_\  \|  |  \   __\/  _ \|     ___/  |	Created: October 10 - 2020
/    |    \  |  /|  | (  <_> )    |   |  |	Last Modified: August 14 - 2022
\____|__  /____/ |__|  \____/|____|   |__|	Language: AutoHotkey_L 1.1.34.03
        \/ersion: 1.0.4 Beta
*/
;----------------------------------------------------------------------------
/*
		At first, I couldn't even look at you 
		But step by step i fixed you
		One part at a time
		I made you whole
		Made you perfect
		Made you a masterpiece
		Now you are finished
		Physically pure
		Mentally infallible
		Tomorrow i will name you
		AutoPI
*/
;----------------------------------------------------------------------------
/*
		PURPOSE:
			● Automate Page Improver.

		METHOD:
			● Automatic crop with a matching format in a table.
			● Automatic crop with manual settings.
			● Premade profiles in Page Improver.

		Features:
			● Easy to use GUI wtih presets.
			● Adding folders with Drag & Drop or dialog box.
			● Save and load information from JSON.
			● Hotkeys and macros with user controlled delays and triggering.
*/
;----------------------------------------------------------------------------
;	Compiled Executable Settings.
;----------------------------------------------------------------------------
;@Ahk2Exe-SetInternalName AutoPI
;@Ahk2Exe-SetProductName AutoPI
;@Ahk2Exe-SetDescription AutoPI (64 Bit)
;@Ahk2Exe-SetVersion 1.0.4.0
;@Ahk2Exe-SetCopyright Espen Sakariassen
;----------------------------------------------------------------------------
;	Password Protection
;----------------------------------------------------------------------------
;InputBox, Password, Password,, hide, 200,100
;if ErrorLevel
;ExitApp
;Else If Password !=[)191741 1353|-|357
;ExitApp
;----------------------------------------------------------------------------
;	*.dll Check
;----------------------------------------------------------------------------
if !FileExist(A_Scriptdir . "\Data\AutoPI.dll"){
		MsgBox, 262160, AutoPI - Error, Cant find:`n%A_ScriptDir%\Data\AutoPI.dll
		ExitApp
	}
;----------------------------------------------------------------------------
;	Program Settings
;----------------------------------------------------------------------------
;#warn
#NoEnv
#IfTimeout 1000
#MaxMem 1024
#MaxThreads 20
#SingleInstance Force
#Include Resources\GDI+\Gdip_All.ahk
#Include Resources\Button\Gen 3 Buttons.ahk
;#Include Resources\Wia\wia.ahk
Appname := "AutoPI"
Createdby := "Espen Sakariassen"
Version := "1.0.4.0 Beta"
Date := "08/14 - 2022"
If !pToken := Gdip_Startup(){
		MsgBox, 262160, %Appname% - Gdiplus Error, Gdiplus failed to start. Please ensure you have Gdiplus on your system.
		ExitApp
	}
SetWorkingDir, %A_ScriptDir%\Data
FileCreateDir, Presets\Single Pages
FileCreateDir, Presets\L & R on One Image
FileCreateDir, Presets\L & R on Two Images
FileEncoding, UTF-8
;SetBatchLines, 20ms
SetBatchLines, -1
SetControlDelay, -1
SetFormat, Float, 0.3
SetTitleMatchMode, 2
ListLines, Off
Coordmode, Mouse, Screen
Suspend, On
HDS_FULLDRAG := 0x0080
LVM_GETHEADER := 0x101F
MK_LBUTTON := 0x0001
MN_DBLCLK := 0x01F1
MN_GETHMENU := 0x01E1
MN_SELECTITEM := 0x01E5
SC_MINIMIZE := 0xF020
TCM_SETCURFOCUS := 0x1330
TCM_SETCURSEL := 0x130C
UDM_GETBUDDY := 0x046A
UDN_DELTAPOS := 0xFFFFFD2E
WM_HELP := 0x0053
WM_LBUTTONDBLCLK := 0x0203
WM_LBUTTONDOWN := 0x0201
WM_LBUTTONUP := 0x0202
WM_MOUSEMOVE := 0x0200
WM_NOTIFY := 0x004E
WM_COMMAND := 0x0111
WM_SETICON := 0x0080
WM_SYSCOMMAND := 0x0112
Global g_tabIndex := {}
#ctrls := 5
MC_Obj := Object()
SB_1 := 35, SB_2 := 458, SB_3 := 137, SB_4 := 35
;----------------------------------------------------------------------------
;	GUI 1 2 3 Colour and Font.
;----------------------------------------------------------------------------
Gui, 1:Color, White
;GUI, 2:Color, White
GUI, 3:Color, White
;GUI, 4:Color, White
;GUI, 5:Color, White
Gui, 1:Font, w400 cBlack s9 Q5, Segoe UI
;Gui, 2:Font, w400 cBlack Q5, Segoe UI
Gui, 3:Font, w400 cBlack s9 Q5, Segoe UI
;Gui, 4:Font, w400 Q5 s9 cBlack, Segoe UI
;Gui, 5:Font, w400 Q5 s9 cBlack, Segoe UI
;----------------------------------------------------------------------------
;	GUI 1 MENU
;----------------------------------------------------------------------------
Menu, Tray, NoStandard
Menu, Tray, Tip, %Appname% v%Version%
Menu, Tray, Icon, %A_Workingdir%\AutoPI.dll, 4, 1
Menu, Tray, Add, Restart, Restart_AutoPi
Menu, Tray, Add, Exit, Exit
Menu, AAAA, Add, &Load`tCtrl+L, Load_Settings
Menu, AAAA, Add, &Save`tCtrl+S, Save_Settings
Menu, AAAA, Add, &Save as`tCtrl+Shift+S, Save_as_Settings
Menu, AAAA, Add  ;- Separator line.
Menu, AAAA, Add, &Restart, Restart_AutoPi
Menu, AAAA, Add, &Exit, Exit
Menu, BBBB, Add, &Add row`tAlt+1, LV_Add_Row
Menu, BBBB, Add, &Add rows - multiple profiles`tAlt+2, LV_Add_Rows
Menu, BBBB, Add, &Add rows - one profile`tAlt+3, LV_Add_Rows_SingleProfile
Menu, BBBB, Add	;- Separator line.
Menu, BBBB, Add, &Insert`tF3, LV_Insertrow
Menu, MMMM, Add, &Crop`tShift+C, View_Raw
Menu, MMMM, Add, &Folder`tF2, LV_Modify_Folder
Menu, MMMM, Add, &Profile`tShift+F2, LV_Modify_Profile
Menu, BBBB, Add, &Modify, :MMMM
Menu, BBBB, Add	;- Separator line.
Menu, BBBB, Add, &Remove crop, LV_RemoveCrop
Menu, BBBB, Add, &Remove row`tDel, LV_RemoveSelected
Menu, BBBB, Add, &Delete all`tShift+Del, LV_Clear
Menu, NNNN, Add, &Left`tShift+L, View_RotateCounterClockwise
Menu, NNNN, Add, &Right`tShift+R, View_RotateClockwise
Menu, NNNN, Add, % "&90" . Chr(186) . " right", View_Rotate90right
Menu, NNNN, Add, % "&180" . Chr(186), View_Rotate180
Menu, NNNN, Add, % "&90" . Chr(186) . " left", View_Rotate90left
Menu, OOOO, Add, &Horizontal, View_Horizontal
Menu, OOOO, Add, &Vertical, View_Vertical
Menu, CCCC, Add, &Open raw`tShift+O, View_Raw
Menu, CCCC, Add, &Open output`tCtrl+Shift+O, View_OutPut
Menu, CCCC, Add	;- Separator line.
Menu, CCCC, Add, &Next`tPgDn, View_NextImage
Menu, CCCC, Add, &Previous`tPgUp, View_PreviousImage
Menu, CCCC, Add, &First`tHome, View_FirstImage
Menu, CCCC, Add, &Last`tEnd, View_LastImage
Menu, CCCC, Disable, &Next`tPgDn
Menu, CCCC, Disable, &Previous`tPgUp
Menu, CCCC, Disable, &First`tHome
Menu, CCCC, Disable, &Last`tEnd
Menu, CCCC, Add	;- Separator line.
Menu, CCCC, Add, &Rotate, :NNNN
Menu, CCCC, Add, &Mirror-reversal, :OOOO
Menu, CCCC, Disable, &Rotate
Menu, CCCC, Disable, &Mirror-reversal
Menu, CCCC, Add	;- Separator line.
Menu, CCCC, Add, &Grid`tShift+G, View_Grid, +Radio
Menu, CCCC, Disable, &Grid`tShift+G
Menu, CCCC, Add	;- Separator line.
Menu, CCCC, Add, &Close`tEsc, View_Close
Menu, CCCC, Disable, &Close`tEsc
Menu, GGGG, Add, Edges, SinglePages_NewDL_Settings
Menu, GGGG, Add, Sharpening 2, SinglePages_OldDL_Settings, +BarBreak
Menu, HHHH, Add, Automatic crop`t    Edges, AutoCrop_NewDL_Settings
Menu, HHHH, Add, Book`t    Edges, Book_NewDL_Settings
Menu, HHHH, Add, Periodical`t    Edges, Periodical_NewDL_Settings
Menu, HHHH, Add, Complete periodical`t    Edges, Complete_Periodical_NewDL_Settings
Menu, HHHH, Add, Sharpening 2, Complete_Periodical_Settings
Menu, HHHH, Insert, Sharpening 2, Sharpening 2, Periodical_Settings
Menu, HHHH, Insert, Sharpening 2, Sharpening 2, Book_Settings
Menu, HHHH, Insert, Sharpening 2, Sharpening 2, AutoCrop_OldDL_Settings, +BarBreak
Menu, IIII, Add, Edges, ScanVpage_Edges
Menu, IIII, Add, Sharpening 2, ScanVpage_Sharpening_2, +BarBreak
Menu, DDDD, Add, &Single pages, :GGGG
Menu, DDDD, Add, L && R on &one image, :HHHH
Menu, DDDD, Add, L && R on &two images, :IIII
Menu, JJJJ, Add, &Multiple profiles`tCtrl+1, Drop_Settings, +Radio
Menu, JJJJ, Add, &One profile`tCtrl+2, Drop_Settings, +Radio
Menu, EEEE, Add, List - drag && drop, :JJJJ
Menu, KKKK, Add, Checked, Checkboxes_C, +Radio
Menu, KKKK, Add, None, Checkboxes_N, +Radio
Menu, KKKK, Add, Percentage difference, Checkboxes_PD, +Radio
Menu, EEEE, Add, List - styles, :KKKK
Menu, EEEE, Add  ;- Separator line.
Menu, EEEE, Add, &Hotkeys`tF4, SuspendHK, +Radio
Menu, EEEE, Add, On &top`tF11, Always_On_Top, +Radio
Menu, LLLL, Add, &List, Open_List_JSON
Menu, LLLL, Add, &Settings, Open_Settings_JSON
Menu, LLLL, Add, &Table, Open_Table_JSON
Menu, EEEE, ADD, O&pen .json, :LLLL
Menu, EEEE, Add, Refresh`tF5, RefreshGui1, +Radio
Menu, EEEE, Add, &Restore, Default_Settings
Menu, EEEE, Add  ;- Separator line.
Menu, EEEE, Add, &Settings`tF12, Open_GUI_Settings
Menu, FFFF, Add, &Documentation`tF1, AutoPi_Document
Menu, FFFF, Add, &Training booklet, AutoPi_Training_Booklet
Menu, FFFF, Add  ;- Separator line.
Menu, FFFF, Add, &About, About_AutoPi
Menu, AutoPi_Menu, Add, &File, :AAAA
Menu, AutoPi_Menu, Add, &Edit, :BBBB
Menu, AutoPi_Menu, Add, &View, :CCCC
Menu, AutoPi_Menu, Add, Pr&esets, :DDDD
Menu, AutoPi_Menu, Add, &Settings, :EEEE
Menu, AutoPi_Menu, Add, &Help, :FFFF
Menu, MenuListView, Add, &Add row`tAlt+1, LV_Add_Row 
Menu, MenuListView, Add, &Add rows - multiple profiles`tAlt+2, LV_Add_Rows
Menu, MenuListView, Add, &Add rows - one profile`tAlt+3, LV_Add_Rows_SingleProfile
Menu, MenuListView, Add	;- Separator line.
Menu, MenuListView, Add, &Insert`tF3, LV_Insertrow
Menu, MenuListView, Add, &Modify, :MMMM
Menu, MenuListView, Add	;- Separator line.
Menu, MenuListView, Add, &Remove crop, LV_RemoveCrop
Menu, MenuListView, Add, &Remove row`tDel, LV_RemoveSelected
Menu, MenuListView, Add, &Delete all`tShift+Del, LV_Clear
Menu, MenuListView, Color, White
Menu, AutoPi_Menu, Color, White
Menu, GGGG, Color, White
Menu, HHHH, Color, White
Menu, IIII, Color, White
Gui, 1: Menu, AutoPi_Menu
;----------------------------------------------------------------------------
;	GUI 3 MENU
;----------------------------------------------------------------------------
Menu, MenuTableView, add, &Add row`tAlt+1, TableEntry
Menu, MenuTableView, add	;- Separator line.
Menu, MenuTableView, Add, &Remove`tDel, Delete_Selected_From_Tableview
Menu, MenuTableView, add, &Delete All`tShift+Del, Clear_From_Tableview
Menu, MenuTableView, Color, White
;----------------------------------------------------------------------------
;	GUI 1
;----------------------------------------------------------------------------
/*
Logical: Only the first 4094 characters of text are significant for sorting purposes. Any sequences of digits in the text are treated as true numbers rather than mere characters.
Integer: The limit is: -2147483648 to 2147483647 (32 bit integer).

ListView has no forced styles and defaults are:
0x10000 ; WS_TABSTOP
0x1 ; LVS_REPORT
0x8 ;  LVS_SHOWSELALWAYS
LV0x20 ; LVS_EX_FULLROWSELECT
LV0x10 ; LVS_EX_HEADERDRAGDROP

Selected extras at creation:
LV0x4 - LVS_EX_CHECKBOXES
-E0x200 - WS_EX_CLIENTEDGE
LV0x10000 - LVS_EX_SIMPLESELECT

Other options:
Count500000 -> allocate memory.
*/
/*
Gui, 1:Font, w600 s9 cwhite, Segoe UI
Gui, 1:Add, Progress, xm ym h24 w125 Hidden Disabled BackgroundFF4500 vStop2
Gui, 1:Add, Text, xp yp wp hp Hidden BackgroundTrans 0x201 vStop +Border gStop, Stop
Gui, 1:Add, Progress, xm ym h24 w125 Disabled Background009E60 vStart2
Gui, 1:Add, Text, xp yp wp hp BackgroundTrans 0x201 vStart +Border gStart, Start
Gui, 1:Font, w400 s9 cBlack, Segoe UI
*/
GUI, 1:+hwndGui1 -DPIScale
StartTheme := CustomButtons("Start"), GuiButtonType1.SetSessionDefaults(StartTheme.All, StartTheme.Default, StartTheme.Hover, StartTheme.Pressed)
StartButton := New HButton({Owner: Gui1, X: "m", Y: "m vStart", W: 125, H: 30, Text: "Start", Label: "Start"}, {BackgroundColor: "0xFFFFFFFF"})
StopTheme := CustomButtons("Stop"), GuiButtonType1.SetSessionDefaults(StopTheme.All, StopTheme.Default, StopTheme.Hover, StopTheme.Pressed)
StopButton := New HButton({Owner: Gui1, X: "m", Y: "m Hidden vStop", W: 125, H: 30, Text: "Stop", Label: "Stop"}, {BackgroundColor: "0xFFFFFFFF"})
Gui, 1:Add, Statusbar, 0x0100 hwndBar
SB_SetParts(SB_1, SB_2, SB_3, SB_4)
SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
Gui, 1:Add, ListView, xm ym w725 r10 AltSubmit ReadOnly Count500000 LV0x4 LV0x10000 -E0x200 HWNDListHWND vList gListview, Folder|Profile|Format|Images|Size|Timer
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", ListHWND, "WStr", "Explorer", "Ptr", 0)
ListHD := DllCall("SendMessage", "Ptr", ListHWND, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr")
Control, Style, -0x0080,, ahk_id %ListHD% ; 0x0080 is HDS_FULLDRAG
LV_ModifyCol(1,"360 Logical Left", A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . A_Space . "Folder"), LV_ModifyCol(2,"184 Logical Left","Profile")
LV_ModifyCol(3,"78 Logical Right", "Crop"), LV_ModifyCol(4,"50 Integer Right","Images"), LV_ModifyCol(5,"54 Logical Right", "Size"), LV_ModifyCol(6,"57 Logical Right", "Timer")
Folderrow := 1, ImageListID := IL_Create(1,0,0)
LV_SetImageList(ImageListID)
IL_Add(ImageListID, A_WorkingDir "\AutoPI.dll", 10)
Gui, 1:+Resize +MinSize744x120
;----------------------------------------------------------------------------
;	GUI 2 Hotkeys
;----------------------------------------------------------------------------
/*
GUI, 2:+hwndGui2
Gui, 2:Add, Tab3, x0 y5 w317 h357, Hotkeys
Gui, 2:Tab, 1
Gui, 2:Add, Groupbox, xm ym+23 w295 h44 ,
Gui, 2:Add, Checkbox, xm+10 ym+41 vOnTop_2 gAlways_On_Top_2, Always On Top
Gui, 2:Add, Button, xm+216 ym+36 +Default vSuspendHK gSuspendHK, Hotkeys On
Gui, 2:Add, Groupbox, xm ym+73 w295 h44, XnView Space Delay
Gui, 2:Add, Checkbox, xm+10 ys+92 vM_Space gHotkey_XnView, On/Off
Gui, 2:Add, Edit, +Number x+170 ys+89 w32 vSpace_X gSubmit_All, 250
Gui, 2:Add, Text, xm+228 ym+73, Milisecond
Gui, 2:Add, Groupbox, xm ym+123 w295 h44, Key Settings
Gui, 2:Add, Text, xm+225 ym+123, Macro Delay
Gui, 2:Add, Checkbox, xm+10 ys+142 vMacro_PageImprover gMacro_PageImprover_1, #1 On/Off
Gui, 2:Add, DropDownList, Disabled xm+240 ym+138 w30 vMacro_Delay_List gMacro_Delay_List, 1|2|3|4|5|6|7|8|9|0
Gui, 2:Add, Text, xm+100 ym+166,
Loop,% #ctrls 
	{
		IniRead, savedHK%A_Index%, Hotkeys.ini, Hotkeys, %A_Index%, %A_Space%
		If(A_Index = 4){
				If savedHK%A_Index%
					{
						Hotkey,% savedHK%A_Index%, Hotkey%A_Index%, T2
					}
			}Else{
				If savedHK%A_Index%
					{
						Hotkey,% savedHK%A_Index%, Hotkey%A_Index%, T1
					}
			}
		StringReplace, noMods, savedHK%A_Index%, ~
		StringReplace, noMods, noMods, #,,UseErrorLevel
		Gui, 2:Add, Hotkey, xs+135 y+15 vHK%A_Index% gHotkey, %noMods%
		Gui, 2:Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win
	}
Gui, 2:Add, Groupbox, xm ym+170 w295 h176, Keys
Gui, 2:Add, Text, xm+10 ym+197, #1 Apply/Save/Next. 
Gui, 2:Add, Text, xm+10 ym+225, #2
Gui, 2:Add, Text, xm+10 ym+253, #3
Gui, 2:Add, Text, xm+10 ym+281, #4 Pause AutoPI
Gui, 2:Add, Text, xm+10 ym+309, #5 Stop AutoPI
*/
;----------------------------------------------------------------------------
;	GUI 3 Settings
;----------------------------------------------------------------------------
GUI, 3:+hwndGui3 -MinimizeBox +Owner1
Gui, 3:Default
Gui, 3:Add, TreeView, xm-5 y+6 w177 h250 -HScroll +ReadOnly 0x200 HWNDTreeHWND vTreeView gTreeView,
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", TreeHWND, "WStr", "Explorer", "Ptr", 0)
ImageListID2 := IL_Create(16,0,0)
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 2) ; 1
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 3) ; 2
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 4) ; 3
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 5) ; 4
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 6) ; 5
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 7) ; 6
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 8) ; 7
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 9) ; 8
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 10) ; 9
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 11) ; 10
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 12) ; 11
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 13) ; 12
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 14) ; 13
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 15) ; 14
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 16) ; 15
IL_Add(ImageListID2, A_WorkingDir "\AutoPI.dll", 18) ; 16
TV_SetImageList(ImageListID2)
	P1 := TVAdd("Automatic crop",, "Icon3")
	P1C1 := TVAdd("Table", P1, "Icon15")
	P2 := TVAdd("Drive space",, "Icon4")
	P3 := TVAdd("Folder & profile",, "Icon1")
	P4 := TVAdd("Hotkeys",, "Icon6")
	P5 := TVAdd("Imageview",, "Icon9")
	P6 := TVAdd("List",, "Icon15")
	P7 := TVAdd("Mouse coordinates",, "Icon5")
    P8 := TVAdd("Page improver",, "Icon7")
	P8C1 := TVAdd("Identification", P8, "Icon13")
	P9 := TVAdd("Progress",, "Icon8")
	P10 := TVAdd("Script delay",, "Icon10")
    P10C1 := TVAdd("Main branch",P10, "Icon10")
    P10C2 := TVAdd("Restart branch",P10, "Icon10")
	P11 := TVAdd("Send mode",, "Icon11")
	;P9 := TVAdd("User interface",, "Icon14")
TV_Modify(P1, "Select")
GUI, 3:Add, Button, xs+430 ys+256 +Default w80 h23 hwndsetthwnd vSetting_OK gSetting_OK, &Ok
GUI, 3:Add, Button, xs+518 ys+256 w80 h23 gSetting_Cancel, &Cancel
Gui, 3:Add, Tab, x+0 w0 h0 vSettingsTab gSettingsTab, 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15
Gui, 3:Tab, 2 ; Table
Gui, 3:Add, ListView, xs+176 ys+0 w422 h250 AltSubmit Grid +ReadOnly -LV0x10 HWNDList2HWND vList2 gTableView, Format|Pages|Width|Height
ListHD := DllCall("SendMessage", "Ptr", List2HWND, "UInt", 0x101F, "Ptr", 0, "Ptr", 0, "UPtr")
Control, Style, -0x0080,, ahk_id %ListHD% ; 0x0080 is HDS_FULLDRAG
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", List2HWND, "WStr", "Explorer", "Ptr", 0)
LV_ModifyCol(1,"100 Center", "Format"), LV_ModifyCol(2,"80 Center","Pages"), LV_ModifyCol(3,"80 Center","Resize.W"), LV_ModifyCol(4,"80 Center","Resize.H")
Gui, 3:Tab, 3 ; Drive Space
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Drive space
Gui, 3:Add, Text, xs+200 ys+30, Free space.
GUI, 3:Add, Listbox, xs+330 ys+30 T8 H60 w86 vLB_DriveSpace gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+90, Empty recycle bin.
Gui, 3:Add, Button, xs+330 ys+85 w60 vRecyclebin hwndbuttonhwnd gRecyclebin, Delete
Gui, 3:Add, Text, xs+200 ys+120 hwndFreediskhwnd, Script threshold.
Gui, 3:Add, Edit, xs+330 ys+117 w60 +Number +Center vDisk_Space gSubmit_All,
Gui, 3:Add, Text, xs+395 ys+120, MB
Gui, 3:Tab, 4 ; Folder & Profile
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Folder && profile
Gui, 3:Add, Text, xs+200 ys+30, Browse for folder.
Gui, 3:Add, combobox, xs+330 ys+27 w200 HWNDFolderHWND vFolderpath gSubmit_All, D:\Dl_Files|D:\Dl_Files\Bok|D:\Dl_Files\Bok_NyeDL|D:\Dl_Files\Tidsskrift|D:\Dl_Files\Tidsskrift_Komplett|D:\Dl_Files\Tidsskrift_forsideuttrekk
Gui, 3:Add, Picture, xs+535 ys+21 h35 w35 Icon1, %A_Workingdir%\AutoPI.dll
Gui, 3:Add, Text, xs+200 ys+60, Crop warning.
Gui, 3:Add, Checkbox, xs+330 ys+60 +Left vCrop_Check g3Submit_All, % (Crop_Check ? "On" : "Off")
Gui, 3:Add, Text, xs+398 ys+60, Folder warning.
Gui, 3:Add, Checkbox, xs+524 ys+60 +Left vImageFolderCheck g3Submit_All, % (ImageFolderCheck ? "On" : "Off")
Gui, 3:Add, Text, xs+200 ys+90, Image extension.
GUI, 3:Add, Edit, xs+330 ys+87 +Center w140 vImageExtension gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+120, Image folder.
Gui, 3:Add, Edit, xs+330 ys+117 w140 +Center vImageFolder gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+180, Browse for profile.
Gui, 3:Add, ComboBox, xs+330 ys+177 w200 HWNDProfileHWND vProfilepath gSubmit_All, D:\Dl_Files\PI_Profiler
Gui, 3:Add, Picture, xs+535 ys+171 h35 w35 icon13, %A_Workingdir%\AutoPI.dll
Gui, 3:Add, Text, xs+200 ys+210, Profile extension.
GUI, 3:Add, Edit, xs+330 ys+207 +Center w49 vProfileExtension gSubmit_All,
Gui, 3:Tab, 5 ; Hotkeys
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Hotkeys
Gui, 3:Add, Text, xs+200 ys+30, #1 - Apply/save/next.
Gui, 3:Add, DropDownList, xs+330 ys+27 w30 vMacro_Delay_1 gMacro_Delay, 0|1|2|3|4|5|6|7|8|9
Gui, 3:Add, Hotkey, xs+365 ys+27 vHK1 gHotkey,
Gui, 3:Add, CheckBox, x+5 vCB1 gHotkey, Win
Gui, 3:Add, Text, xs+200 ys+60, #2 -
Gui, 3:Add, Hotkey, xs+365 ys+57 Disabled vHK2 gHotkey,
Gui, 3:Add, CheckBox, x+5 Disabled vCB2 gHotkey, Win
Gui, 3:Add, Text, xs+200 ys+90, #3 -
Gui, 3:Add, Hotkey, xs+365 ys+87 Disabled vHK3 gHotkey,
Gui, 3:Add, CheckBox, x+5 Disabled vCB3, Win
Gui, 3:Add, Text, xs+200 ys+120, #4 -
Gui, 3:Add, Hotkey, xs+365 ys+117 Disabled vHK4 gHotkey,
Gui, 3:Add, CheckBox, x+5 Disabled vCB4, Win
Gui, 3:Add, Text, xs+200 ys+150, #5 -
Gui, 3:Add, Hotkey, xs+365 ys+147 Disabled vHK5 gHotkey,
Gui, 3:Add, CheckBox, x+5 Disabled vCB5, Win
Gui, 3:Add, Text, xs+200 ys+180, Space delay.
Gui, 3:Add, Checkbox, xs+321 ys+180 +Right vSpace_Macro gHotkey_Space, % (Space_Macro ? "On" : "Off")
Gui, 3:Add, Edit, xs+365 ys+177 w50 +Number +center vSpace_Macro_Delay gSubmit_All,
Gui, 3:Add, Text, xs+416 ys+180, ms
Gui, 3:Add, Edit, xs+440 ys+177 w77 vSpace_Process gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+210, Toggle on/off.
Gui, 3:Add, Button, xs+365 ys+205 w50 vSuspendHK gSuspendHK, Off
Gui, 3:Tab, 6 ; ImageView
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, ImageView
Gui, 3:Add, Groupbox, xs+190 ys+18 w395 H63, Grid
Gui, 3:Add, Text, xs+200 ys+44, Colour.
GUI, 3:Add, DDL, xs+276 ys+41 w77 vMC_GridColour gSubmit_All, Black|Red|White
Gui, 3:Add, Text, xs+419 ys+44, Thickness.
Gui, 3:Add, Edit, xs+486 ys+41 w77 +ReadOnly +Center vMC_GridThickness gSubmit_All, 1.5
GUI, 3:Add, UpDown, xs+486 ys+41 -2,
Gui, 3:Add, Groupbox, xs+190 ys+82 w395 H93, Image
Gui, 3:Add, Text, xs+200 ys+108, Interpolation.
GUI, 3:Add, DDL, xs+276 ys+105 w128 AltSubmit vMC_Interpolation gSubmit_All, Default|LowQuality|HighQuality|Bilinear|Bicubic|NearestNeighbor|HighQualityBilinear|HighQualityBicubic
Gui, 3:Add, Text, xs+419 ys+108, Pixel Offset.
GUI, 3:Add, DDL, xs+486 ys+105 w88 AltSubmit vMC_PixelOffset gSubmit_All, Default|HighSpeed|HighQuality|None|Half
Gui, 3:Add, Text, xs+200 ys+138, Rotation increment.
GUI, 3:Add, Edit, xs+327 ys+135 w77 +ReadOnly +Center vMC_Angle gSubmit_All, 0.1
GUI, 3:Add, UpDown, xs+330 ys+135 -2,
Gui, 3:Add, Text, xs+419 ys+138, Smoothing.
GUI, 3:Add, DDL, xs+486 ys+135 w88 AltSubmit vMC_Smoothing gSubmit_All, Default|HighSpeed|HighQuality|None|AntiAlias
Gui, 3:Add, Groupbox, xs+190 ys+176 w395 H63, Selection
Gui, 3:Add, Text, xs+200 ys+202, Colour.
Gui, 3:Add, DDL, xs+276 ys+199 w77 vMC_SelectionColour gSubmit_All, Black|Silver|Gray|White|Maroon|Red|Purple|Fuchsia|Green|Lime|Olive|Yellow|Navy|Blue|Teal|Aqua
Gui, 3:Add, Text, xs+419 ys+202, Thickness.
Gui, 3:Add, Edit, xs+486 ys+199 w77 +ReadOnly +Center vMC_SelectionThickness gSubmit_All, 1.5
GUI, 3:Add, UpDown, xs+486 ys+199 -2,
Gui, 3:Tab, 7 ; List
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, List
Gui, 3:Add, Text, xs+200 ys+30, Autosize columns.
Gui, 3:Add, Checkbox, xs+330 ys+30 +Left vList_AutoHDR gList_HDR, % (List_AutoHDR ? "On" : "Off")
Gui, 3:Add, Text, xs+200 ys+60, Drag && drop.
GUI, 3:Add, DDL, xs+330 ys+57 w140 vDragDrop_DDL gDragDrop, Multiple profiles|One profile
Gui, 3:Add, Text, xs+200 ys+90, Doubleclick a row.
Gui, 3:Add, Edit, xs+330 ys+87 w210 vOpenwith gSubmit_All,
GUI, 3:Add, Button, xs+549 ys+86 w30 h25 vOpenWithButton gOpenWithButton, ...
Gui, 3:Add, Text, xs+200 ys+120, List styles.
GUI, 3:Add, DDL, xs+330 ys+117 w140 vCheckboxProperty gList_Update, Checked|None|Percentage difference
Gui, 3:Add, Text, xs+200 ys+150, Load on startup.
Gui, 3:Add, Checkbox, xs+330 ys+150 +Left vListLoad g3Submit_All, % (ListLoad ? "On" : "Off")
Gui, 3:Add, Text, xs+200 ys+180, Percentage difference.
Gui, 3:Add, Edit, xs+330 ys+177 w49 +ReadOnly +Center vPercentageDifference gSubmit_All,
GUI, 3:Add, UpDown, xs+330 ys+177 -2,
Gui, 3:Add, Text, xs+200 ys+210, Refresh list.
Gui, 3:Add, Checkbox, xs+330 ys+210 +Left vListRefresh gSubmit_All2, % (ListRefresh ? "On" : "Off")
Gui, 3:Tab, 8 ; Mouse Coordinates
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Mouse coordinates
Gui, 3:Add, Groupbox, xs+200 ys+30 w159 h173, Local navigator
Gui, 3:Add, Groupbox, xs+357 ys+30 w192 h173, Shoulder search
Gui, 3:Add, Text, xs+279 ys+60, Row.
Gui, 3:Add, Text, xs+400 ys+60, Left.
Gui, 3:Add, Text, xs+480 ys+60, Right.
Gui, 3:Add, Text, xs+224 ys+90, X-axis:
Gui, 3:Add, Text, xs+224 ys+120, Y-axis:
Gui, 3:Add, Edit, xs+274 ys+87 +Number +Center w60 vxMC_Local_Navigator gSubmit_All,
Gui, 3:Add, Edit, xs+274 ys+117 +Number +Center w60 vyMC_Local_Navigator gSubmit_All,
Gui, 3:Add, Edit, xs+381 ys+87 +Number +Center w60 vxMC_Left_Image gSubmit_All,
Gui, 3:Add, Edit, xs+381 ys+117 +Number +Center w60 vyMC_Left_Image gSubmit_All,
Gui, 3:Add, Edit, xs+464 ys+87 +Number +Center w60 vxMC_Right_Image gSubmit_All,
Gui, 3:Add, Edit, xs+464 ys+117 +Number +Center w60 vyMC_Right_Image gSubmit_All,
Gui, 3:Add, Button, xs+274 ys+147 w60 vMouse_GetPos1 gMouse_Get_Pos, &1
Gui, 3:Add, Button, xs+381 ys+147 w60 vMouse_GetPos2 gMouse_Get_Pos2, &2
Gui, 3:Add, Button, xs+464 ys+147 w60 vMouse_GetPos3 gMouse_Get_Pos3, &3
Gui, 3:Tab, 9 ; Page Improver
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Page Improver
Gui, 3:Add, Text, xs+200 ys+30, Effects.
Gui, 3:Add, DDL, xs+260 ys+27 w92 vEffects gSubmit_All, Bluring|Edges|Emboss|Sharpening 1|Sharpening 2
Gui, 3:Add, Text, xs+200 ys+60, Mode.
Gui, 3:Add, DDL, xs+260 ys+57 w135 +BackgroundF9CD63 vPi_Mode gSubmit_All, Single Pages|L & R on One Image|L & R on Two Images
Gui, 3:Add, Text, xs+200 ys+90, Output.
Gui, 3:Add, Combobox, xs+260 ys+87 w92 hwndOutput_FolderHWND vOutput_Folder gSubmit_All, digibok_
Gui, 3:Add, Text, xs+398 ys+90, Existing files.
Gui, 3:Add, DDL, xs+482 ys+87 w92 vOutput_Action gSubmit_All, Delete|Overwrite|Skip
Gui, 3:Add, Groupbox, xs+190 ys+124 w395 H100, Options
Gui, 3:Add, Text, xs+200 ys+150, Restart Page Improver.
Gui, 3:Add, Checkbox, xs+340 ys+150 +Left vConditional_Branch gPI_Restart, % (Conditional_Branch ? "On" : "Off")
Gui, 3:Add, Text, xs+200 ys+170, Initial restart.
Gui, 3:Add, Checkbox, xs+340 ys+170 +Left vInitial_Restart gPI_Restart, % (Initial_Restart ? "On" : "Off")
Gui, 3:Add, Text, xs+200 ys+190, Apply effect.
Gui, 3:Add, Checkbox, xs+340 ys+190 +Left vApply_Effect gPI_Restart, % (Apply_Effect ? "On" : "Off")
Gui, 3:Add, Text, xs+398 ys+150, Automatic crop.
Gui, 3:Add, Checkbox, xs+538 ys+150 +Left vAutoCrop gPI_Restart, % (AutoCrop ? "On" : "Off")
Gui, 3:Add, Text, xs+398 ys+170, Shoulder search.
Gui, 3:Add, Checkbox, xs+538 ys+170 +Left vShoulderSearch gPI_Restart, % (ShoulderSearch ? "On" : "Off")
Gui, 3:Tab, 10 ; Identification
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Identification
Gui, 3:Add, Text, xs+200 ys+30, Path.
Gui, 3:Add, Edit, xs+260 ys+27 w320 vcBranch_A1 gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+60, Process.
Gui, 3:Add, Edit, xs+260 ys+57 w320 vmBranch_A1 gSubmit_All,
Gui, 3:Add, Text, xs+200 ys+90, Title.
Gui, 3:Add, Edit, xs+260 ys+87 w320 vmBranch_A2 gSubmit_All,
Gui, 3:Tab, 11 ; Progress
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Progress
Gui, 3:Add, Groupbox, xs+190 ys+18 w395 h127, % A_Space . A_Space . A_Space
Gui, 3:Add, Radio, xs+200 ys+18 vImages_Timer gSelectTimer1, Count images
Gui, 3:Add, Text, xs+200 ys+44, Time limit
Gui, 3:Add, Checkbox, xs+253 ys+44 +Right vDeadline g3Submit_All, % (Deadline ? "On" : "Off")
Gui, 3:Add, Text, xs+312 ys+44, Multiplier. ; Timer multiplier.
GUI, 3:Add, DDL, xs+376 ys+41 w40 vTimelimit gSubmit_All, 1x|2x|3x|4x|5x
Gui, 3:Add, Text, xs+436 ys+44, Action.
GUI, 3:Add, DDL, xs+484 ys+41 w80 HWNDDeadlinetakenHWND vDeadlineActiontaken gSubmit_All, Continue|Stop
Gui, 3:Add, Groupbox, xs+200 ys+72 w375 h63, Delay (sec)
Gui, 3:Add, Text, xs+209 ys+98, Start.
Gui, 3:Add, Edit, xs+246 ys+95 w50 +ReadOnly +Center viCount_T1 gSubmit_All,
GUI, 3:Add, UpDown, xs+246 ys+95 -2,
Gui, 3:Add, Text, xs+337 ys+98, Interval.
Gui, 3:Add, Edit, xs+389 ys+95 w50 +ReadOnly +Center viCount_T2 gSubmit_All,
GUI, 3:Add, UpDown, xs+389 ys+95 -2,
Gui, 3:Add, Text, xs+480 ys+98, End.
Gui, 3:Add, Edit, xs+514 ys+95 w50 +ReadOnly +Center viCount_T3 gSubmit_All,
GUI, 3:Add, UpDown, xs+514 ys+95 -2,
Gui, 3:Add, Groupbox, xs+190 ys+148 w395 h93, % A_Space . A_Space . A_Space
Gui, 3:Add, Radio, xs+200 ys+148 vDuration_Timer gSelectTimer2, Count time
Gui, 3:Add, Text, xs+200 ys+174, Minimum execution time.
Gui, 3:Add, Edit, xs+370 ys+171 w80 +ReadOnly +Center vLimit gSubmit_All,
GUI, 3:Add, UpDown, xs+370 ys+171 -2,
Gui, 3:Add, Text, xs+460 ys+174, sec
Gui, 3:Add, Text, xs+200 ys+204, Page Improver crop speed.
Gui, 3:Add, Edit, xs+370 ys+201 w80 +ReadOnly +Center vMB_Second gSubmit_All,
GUI, 3:Add, UpDown, xs+370 ys+201 -2,
Gui, 3:Add, Text, xs+460 ys+204, MBps
Gui, 3:Tab, 12 ; Script Delay
Gui, 3:Tab, 13 ; Main Branch
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Main branch
Gui, 3:Add, Text, xs+200 ys+30, #1 After apply && preview.
Gui, 3:Add, Edit, xs+400 ys+27 w80 +Number +Center vmBranch_T1 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+27 -2,
Gui, 3:Add, Text, xs+485 ys+30, ms
Gui, 3:Add, Text, xs+200 ys+60, #2 After script startup routine.
Gui, 3:Add, Edit, xs+400 ys+57 w80 +Number +Center vmBranch_T2 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+57 -2,
Gui, 3:Add, Text, xs+485 ys+60, ms
Gui, 3:Add, Text, xs+200 ys+90, #3 Before a set of actions.
Gui, 3:Add, Edit, xs+400 ys+87 w80 +Number +Center vmBranch_T3 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+87 -2,
Gui, 3:Add, Text, xs+485 ys+90, ms
Gui, 3:Add, Text, xs+200 ys+120, #4 Between actions.
Gui, 3:Add, Edit, xs+400 ys+117 w80 +Number +Center vmBranch_T4 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+117 -2,
Gui, 3:Add, Text, xs+485 ys+120, ms
Gui, 3:Add, Text, xs+200 ys+150, #5 File overwrite warning.
Gui, 3:Add, Edit, xs+400 ys+147 w80 +Number +Center vmBranch_T5 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+147 -2,
Gui, 3:Add, Text, xs+485 ys+150, ms
Gui, 3:Add, Text, xs+200 ys+180, #6 WinWaitActive.
Gui, 3:Add, Edit, xs+400 ys+177 w80 +ReadOnly +Center vmBranch_T6 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+177 -2,
Gui, 3:Add, Text, xs+485 ys+180, sec
Gui, 3:Tab, 14 ; Restart Branch
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Restart branch
Gui, 3:Add, Text, xs+200 ys+30, #1 After starting Page Improver.
Gui, 3:Add, Edit, xs+400 ys+27 w80 +Number +Center vcBranch_T1 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+27 -2,
Gui, 3:Add, Text, xs+485 ys+30, ms
Gui, 3:Add, Text, xs+200 ys+60, #2 Before a set of actions.
Gui, 3:Add, Edit, xs+400 ys+57 w80 +Number +Center vcBranch_T2 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+57 -2,
Gui, 3:Add, Text, xs+485 ys+60, ms
Gui, 3:Add, Text, xs+200 ys+90, #3 Between actions.
Gui, 3:Add, Edit, xs+400 ys+87 w80 +Number +Center vcBranch_T3 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+87 -2,
Gui, 3:Add, Text, xs+485 ys+90, ms
Gui, 3:Add, Text, xs+200 ys+120, #4 WinWaitClose.
Gui, 3:Add, Edit, xs+400 ys+117 w80 +ReadOnly +Center vcBranch_T4 gSubmit_All,
GUI, 3:Add, UpDown, xs+400 ys+117 -2,
Gui, 3:Add, Text, xs+485 ys+120, sec
Gui, 3:Tab, 15 ; Send Mode
Gui, 3:Add, Groupbox, xs+176 ys-7 w423 h258, Send mode
Gui, 3:Add, Radio, xs+200 ys+30 vControl_Send gSelect, ControlSend
Gui, 3:Add, Radio, y+15 vSend_Event gSelect, SendEvent
Gui, 3:Add, Radio, y+15 vSend_Input gSelect, SendInput
Gui, 3:Add, Text, xs+330 ys+30, Key delay:
Gui, 3:Add, Edit, x+20 ys+27 w20 +number +Center vKeyDelayCS gSelect,
Gui, 3:Add, Text, x+20 ys+30, Press duration:
Gui, 3:Add, Edit, x+20 ys+27 w20 +number +Center vPressDurationCS gSelect,
Gui, 3:Add, Text, xs+330 ys+60, Key delay:
Gui, 3:Add, Edit, x+20 ys+57 w20 +number +Center vKeyDelay gSelect,
Gui, 3:Add, Text, x+20 ys+60, Press duration:
Gui, 3:Add, Edit, x+20 ys+57 w20 +number +Center vPressDuration gSelect,
;Gui, 3:Tab, 16 ; User Interface
Gui, 3:Tab, 1 ; Automatic Crop Settings
Gui, 3:Add, Tab2, xs+176 ys w422 h250 Hidden +0x0 +0x100 +0x8 +0x800000 vAutoCropTab hwndAutoCropTab,  Crop||Border|Shoulder
WinSet Top,, ahk_id %AutoCropTab%
Gui, 3:Tab, Crop
Gui, 3:Add, Groupbox, xs+190 ys+40 w400 h70, % A_Space . A_Space . A_Space
Gui, 3:Add, Groupbox, xs+190 ys+120 w400 h70, % A_Space . A_Space . A_Space
Gui, 3:Add, Radio, xs+200 ys+40 +Left vAC_Table gSelect_AC, % "Automatic"
Gui, 3:Add, Radio, xs+200 ys+120 +Left vAC_Manual gSelect_AC, % "Manual"
GUI, 3:Add, Edit, xs+200 ys+67 w340 ReadOnly vAC_TablePath gSubmit_All,
GUI, 3:Add, Button, xs+549 ys+66 w30 h25 vAC_TablePathButton gTablePathButton, ...
Gui, 3:Add, Text, xs+200 ys+150, Setting:
Gui, 3:Add, DDL, xs+255 ys+146 w90 vAC_Manual_sDDL gAC_Manual_DDL, Millimeter|Percent|Pixel
Gui, 3:Add, Text, xs+368 ys+150, W:
Gui, 3:Add, Edit, xs+390 ys+147 w60 +ReadOnly +Center vAC_WidthAdjust gAC_Submit,
GUI, 3:Add, UpDown, xs+390 ys+147 -2,
Gui, 3:Add, Text, xs+461 ys+150, H:
Gui, 3:Add, Edit, xs+482 ys+147 w60 +ReadOnly +Center vAC_HeightAdjust gAC_Submit,
GUI, 3:Add, UpDown, xs+482 ys+147 -2,
Gui, 3:Add, Text, xs+200 ys+210, PPI:
Gui, 3:Add, DDL, xs+255 ys+206 w60 vAC_PPI gSubmit_All, 300|400|500|600
Gui, 3:Tab, Border
Gui, 3:Add, Text, xs+200 ys+56, Border margins.
Gui, 3:Add, Checkbox, xs+300 ys+56 +Left vAC_Border g3Submit_All, % (AC_Border ? "On" : "Off")
Gui, 3:Add, Text, xs+350 ys+40, L:
Gui, 3:Add, Edit, xs+370 ys+37 w60 +ReadOnly +Center vAC_UpperLeftMargin gSubmit_All,
GUI, 3:Add, UpDown, xs+370 ys+37 -2,
Gui, 3:Add, Text, xs+441 ys+40, R:
Gui, 3:Add, Edit, xs+462 ys+37 w60 +ReadOnly +Center vAC_UpperRightMargin gSubmit_All,
GUI, 3:Add, UpDown, xs+462 ys+37 -2,
Gui, 3:Add, Text, xs+350 ys+70, L:
Gui, 3:Add, Edit, xs+370 ys+67 w60 +ReadOnly +Center vAC_LowerLeftMargin gSubmit_All,
GUI, 3:Add, UpDown, xs+370 ys+67 -2,
Gui, 3:Add, Text, xs+441 ys+70, R:
Gui, 3:Add, Edit, xs+462 ys+67 w60 +ReadOnly +Center vAC_LowerRightMargin gSubmit_All,
GUI, 3:Add, UpDown, xs+462 ys+67 -2,
Gui, 3:Tab, Shoulder
Gui, 3:Add, Text, xs+200 ys+56, Shoulder sweep.
Gui, 3:Add, Checkbox, xs+300 ys+56 +Left vAC_Sweep g3Submit_All, % (AC_Sweep ? "On" : "Off")
Gui, 3:Add, Text, xs+350 ys+40, L:
Gui, 3:Add, Edit, xs+370 ys+37 w60 +Number +Center vAC_UpperLeftSweep gSubmit_All,
Gui, 3:Add, Text, xs+441 ys+40, R:
Gui, 3:Add, Edit, xs+462 ys+37 w60 +Number +Center vAC_UpperRightSweep gSubmit_All,
Gui, 3:Add, Text, xs+350 ys+70, L:
Gui, 3:Add, Edit, xs+370 ys+67 w60 +Number +Center vAC_LowerLeftSweep gSubmit_All,
Gui, 3:Add, Text, xs+441 ys+70, R:
Gui, 3:Add, Edit, xs+462 ys+67 w60 +Number +Center vAC_LowerRightSweep gSubmit_All,
GuiControl 3:Show, AutoCropTab
GuiControl MoveDraw, SettingsTab
;----------------------------------------------------------------------------
;	GUI 4 "About"
;----------------------------------------------------------------------------
;GUI, 4:+hwndAbout
;Gui, 4:+AlwaysOnTop -MinimizeBox -Caption
;Gui, 4:Add, Picture, x-0 y-1 w306 h211, % "HBITMAP:*" . Create_AutoPi_Alpha_1_PNG()
;Gui, 4:Add, Text, xm+190 y+1, (Picture: First version)
;Gui, 4:Add, Text, xm+10 y+5, % "Version" Version
;Gui, 4:Add, Button, x-0 ys+270 w306 h25 g4GUIClose, Close
;----------------------------------------------------------------------------
;	GUI 5 "Splash"
;----------------------------------------------------------------------------
;GUI, 5:+hwndSplash
;Gui, 5:+AlwaysOnTop -SysMenu +Owner1
;GUI, 5:Add, Text,,"Processing..."
;Gui, 5:Add, Text, hwndCompletedHWND, % "Completed`n   "Time(Ending)
;----------------------------------------------------------------------------
;	ComObjects
;----------------------------------------------------------------------------
FilesystemObj := ComObjCreate("Scripting.FileSystemObject")
Shell := ComObjCreate("Shell.Application")
;Wia := ComObjCreate("WIA.ImageFile")
;----------------------------------------------------------------------------
;	GUI Show
;----------------------------------------------------------------------------
Gui, 1:Show, w822 h291, % Appname
Gui, 1:Default
;----------------------------------------------------------------------------
;	Startup settings
;----------------------------------------------------------------------------

; Global Variables:		Used inside functions. Load() Save()
; UpDown Variables:		Changes made to the GUI will cause their number to be wrong.
; Missing files:		Created by Load() function -> Fileobject() rw flag
;------------------------------------------------------------------------------------
;	UpDown.
Global UDM_GETBUDDY, UDN_DELTAPOS
;------------------------------------------------------------------------------------
;	AutoCrop
Global UpDown235_fIncrement, UpDown235_fPos, UpDown235_fRangeMin, UpDown235_fRangeMax ;	Manual Wdith Adjustment.
Global UpDown238_fIncrement, UpDown238_fPos, UpDown238_fRangeMin, UpDown238_fRangeMax ;	Manual Height Adjustment.
Global UpDown245_fIncrement, UpDown245_fPos, UpDown245_fRangeMin, UpDown245_fRangeMax ;	Modify Margins. Upper Left.
Global UpDown248_fIncrement, UpDown248_fPos, UpDown248_fRangeMin, UpDown248_fRangeMax ;	Modify Margins. Upper Right.
Global UpDown251_fIncrement, UpDown251_fPos, UpDown251_fRangeMin, UpDown251_fRangeMax ;	Modify Margins. Lower Left.
Global UpDown254_fIncrement, UpDown254_fPos, UpDown254_fRangeMin, UpDown254_fRangeMax ;	Modify Margins. Lower Right.
;------------------------------------------------------------------------------------
;	Imageview
Global UpDown63_fIncrement, UpDown63_fPos, UpDown63_fRangeMin, UpDown63_fRangeMax ; Grid Thickness
Global UpDown71_fIncrement, UpDown71_fPos, UpDown71_fRangeMin, UpDown71_fRangeMax ; Rotation Increment
Global UpDown79_fIncrement, UpDown79_fPos, UpDown79_fRangeMin, UpDown79_fRangeMax ; Selection Thickness
;------------------------------------------------------------------------------------
;	List
Global UpDown94_fIncrement, UpDown94_fPos, UpDown94_fRangeMin, UpDown94_fRangeMax ;	Percentage Difference
;------------------------------------------------------------------------------------
;	Progress
Global UpDown153_fIncrement, UpDown153_fPos, UpDown153_fRangeMin, UpDown153_fRangeMax ;	Delay (sec) - Start
Global UpDown156_fIncrement, UpDown156_fPos, UpDown156_fRangeMin, UpDown156_fRangeMax ;	Delay (sec) - Interval
Global UpDown159_fIncrement, UpDown159_fPos, UpDown159_fRangeMin, UpDown159_fRangeMax ;	Delay (sec) - End
Global UpDown164_fIncrement, UpDown164_fPos, UpDown164_fRangeMin, UpDown164_fRangeMax ;	Minimum Execution Time
Global UpDown168_fIncrement, UpDown168_fPos, UpDown168_fRangeMin, UpDown168_fRangeMax ;	Page Improver Crop Speed
;------------------------------------------------------------------------------------
;	Script Delay
Global UpDown173_fIncrement, UpDown173_fPos, UpDown173_fRangeMin, UpDown173_fRangeMax ;	Main Branch #1
Global UpDown177_fIncrement, UpDown177_fPos, UpDown177_fRangeMin, UpDown177_fRangeMax ;	Main Branch #2
Global UpDown181_fIncrement, UpDown181_fPos, UpDown181_fRangeMin, UpDown181_fRangeMax ;	Main Branch #3
Global UpDown185_fIncrement, UpDown185_fPos, UpDown185_fRangeMin, UpDown185_fRangeMax ;	Main Branch #4
Global UpDown189_fIncrement, UpDown189_fPos, UpDown189_fRangeMin, UpDown189_fRangeMax ;	Main Branch #5
Global UpDown193_fIncrement, UpDown193_fPos, UpDown193_fRangeMin, UpDown193_fRangeMax ;	Main Branch #6
Global UpDown198_fIncrement, UpDown198_fPos, UpDown198_fRangeMin, UpDown198_fRangeMax ;	Restart Branch #1
Global UpDown202_fIncrement, UpDown202_fPos, UpDown202_fRangeMin, UpDown202_fRangeMax ;	Restart Branch #2
Global UpDown206_fIncrement, UpDown206_fPos, UpDown206_fRangeMin, UpDown206_fRangeMax ;	Restart Branch #3
Global UpDown210_fIncrement, UpDown210_fPos, UpDown210_fRangeMin, UpDown210_fRangeMax ;	Restart Branch #4
;------------------------------------------------------------------------------------
;	Auto Crop
Global AC_Manual, AC_Manual_sDDL, AC_Table, AC_TablePath, AC_HeightAdjust, AC_WidthAdjust, AC_PPI, AC_OldWidth, AC_OldHeight, AC_Format, AC_Match, TableList, FormatList, List2, Input1, Input2, Input3, AC_Border, AC_Sweep
Global AC_LeftUpperBorder, AC_LeftLowerBorder, AC_RightUpperBorder, AC_RightLowerBorder, AC_UpperLeftMargin, AC_UpperRightMargin, AC_LowerLeftMargin, AC_LowerRightMargin
Global AC_WidthAdjust_Millimeter, AC_HeightAdjust_Millimeter, AC_WidthAdjust_Percent, AC_HeightAdjust_Percent, AC_WidthAdjust_Pixel, AC_HeightAdjust_Pixel
Global AC_UpperLeftSweep, AC_UpperRightSweep, AC_LowerLeftSweep, AC_LowerRightSweep
Global MC_Obj
;	Drive Space
Global Disk_Space
;	Edit
Global FilesystemObj, FocusedRowNumber, Shell, ImgObj
;	Folder & Profile
Global Crop_Check, Folder, FolderHWND, Folderlist, Folderpath, FolderVar, ImageExtension, ImageFolder, ImageFolderCheck, ProfileExtension, ProfileHWND, Profilepath, Profilevar
;	GUI
Global Gui1, Gui2, Gui3, Bar, SB_1, SB_2, SB_3, SB_4
;	Hotkeys
Global HK1, CB1, Hk2, CB2, HK3, CB3, HK4, CB4, HK5, CB5, savedHK1, savedHK2, savedHK3, savedHK4, savedHK5, Macro_Delay_1, Space_Macro, Space_Macro_Delay, Space_Process
;	Imageview
Global pToken, pBitmap, Gridcb, Image1, Image2, iPic, MC_Angle, MC_Interpolation, MC_Smoothing, MC_GridColour, MC_GridThickness, MC_PixelOffset, MC_SelectionThickness, MC_SelectionColour
;	List
Global CheckboxProperty, DragDrop_DDL, List_AutoHDR, ListLoad, ListRefresh, Openwith, PercentageDifference
;	ListView
Global Folderrow, List, Disablecontrol, ListHWND
;	Mouse Coordinates
Global xMC_Left_Image, yMC_Left_Image, xMC_Local_Navigator, yMC_Local_Navigator, xMC_Right_Image, yMC_Right_Image
;	Other Timers
Global Seconds, MaxDuration, Engage
;	Page Improver
Global Effects, Pi_Mode, Output_Folder, Output_FolderHWND, Output_Action, mBranch_A1, mBranch_A2, cBranch_A1, Conditional_Branch, Conditional_Path, ShoulderSearch, Apply_Effect, Initial_Restart, AutoCrop
;	PI Controls
Global AC_CalcWidth, AC_CalcHeight, AC_EffectsComboBox, AC_LeftWidth, AC_LeftHeight, AC_RightWidth, AC_RightHeight, AC_SysTabControl32
Global AC_LeftVcenter, AC_RightVcenter, AC_ImageHeight, AC_UpperMargins_L, AC_UpperMargins_R, AC_LowerMargins_L, AC_LowerMargins_R, AC_UpperSweep_L, AC_UpperSweep_R, AC_LowerSweep_L, AC_LowerSweep_R
;	Program Information
Global Appname, Version
;	Progress
Global Images_Timer, Deadline, Timelimit, DeadlineActiontaken, iCount_T1, iCount_T2, iCount_T3
Global Duration_Timer, Limit, MB_Second
;	Script delay.
Global mBranch_T1, mBranch_T2, mBranch_T3, mBranch_T4, mBranch_T5, mBranch_T6
Global cBranch_T1, cBranch_T2, cBranch_T3, cBranch_T4
;	Send Mode
Global Control_Send, KeyDelayCS, PressDurationCS, Send_Input, Send_Event, KeyDelay, PressDuration
if !Load("Settings.json", "r", A_FileEncoding){
		Error .= ErrorCheck("Settings.json")
		DefaultSettings("Restore")
	}
if !Load(AC_TablePath, "r", A_FileEncoding){
		Error .= ErrorCheck(AC_TablePath,1)
		If (AC_TablePath != (A_WorkingDir . "\Table.json")){
				if !Load("Table.json", "r", A_FileEncoding){
						Error .= ErrorCheck("Table.json")
						DefaultSettings("Table")
					}
		}Else{
				DefaultSettings("Table")
			}
	}
if !Load("List.json", "r", A_FileEncoding){
		Error .= ErrorCheck("List.json")
	}
If Error
	{
		MsgBox, 262208,	%Appname% - Info, % "Default settings are being used for:`n" Error
		Error := ""
	}
;----------------------------------------------------------------------------
;	ToolTip
;----------------------------------------------------------------------------
mBranch_A1_Modified := StrSplit(mBranch_A1, ".")
;	Automatic Crop
AC_Border_TT := ""
AC_UpperLeftMargin_TT := "Upper left margin."
AC_UpperRightMargin_TT := "Upper right margin."
AC_LowerLeftMargin_TT := "Lower left margin."
AC_LowerRightMargin_TT := "Lower right margin."
AC_Sweep_TT := ""
AC_UpperLeftSweep_TT := "Upper left sweep."
AC_UpperRightSweep_TT := "Upper right sweep."
AC_LowerLeftSweep_TT := "Lower left sweep."
AC_LowerRightSweep_TT := "Lower right sweep."
AC_Manual_TT := "Manual."
AC_Manual_sDDL_TT := "Setting."
AC_WidthAdjust_TT := "Width adjustment."
AC_HeightAdjust_TT := "Height adjustment."
AC_Table_TT := "Automatic."
AC_TablePathButton_TT := "Select file."
AC_TablePath_TT := "Path to table.json"
AC_PPI_TT := "Pixels per inch."
Input1_TT := "WidthxHeight"
Input2_TT := "WidthxHeight"
Input3_TT := "Total number of pages"
;	Drive Space
Disk_Space_TT := Chr(183)"Stops below this threshold.`n"Chr(183)"Free drive space is measured before`n crop begins and by folder drive letter."
LB_DriveSpace_TT := ""
Recyclebin_TT := "If none are selected, the recycle bin for all drives is emptied."
;	Folder & Profile
Crop_Check_TT := "A size comparison between the first and last image."
Folderpath_TT := "Initial starting point to browse for folder."
ImageExtension_TT := "Image extension."
ImageFolder_TT := "Image folder."
ImageFolderCheck_TT := "Display a warning when images are found outside " . ImageFolder . "."
;Profilepath_TT := "MRU in windows registry is used."
Profilepath_TT := "Initial starting point to browse for profile"
ProfileExtension_TT := "Profile extention."
;	Hotkeys
Macro_Delay_1_TT := "Delay."
HK1_TT := Chr(183)"Page improver.`nApply & preview "Chr(0x27A1)" Delay in seconds "Chr(0x27A1)" Save & open next."
HK2_TT := "Hotkey 2."
HK3_TT := "Hotkey 3."
HK4_TT := "Hotkey 4."
HK5_TT := "Hotkey 5."
CB1_TT := "Windows logo key."
CB2_TT := "Windows logo key."
CB3_TT := "Windows logo key."
CB4_TT := "Windows logo key."
CB5_TT := "Windows logo key."
Space_Macro_TT := "Space delay."
Space_Macro_Delay_TT := "Delay in milliseconds."
Space_Process_TT := "Executable program."
SuspendHK_TT := "Suspend hotkeys."
;	Imageview
MC_Angle_TT := "Rotation increment."
MC_Interpolation_TT := "Interpolation."
MC_PixelOffset_TT := "Pixel offset"
MC_Smoothing_TT := "Smoothing."
MC_GridColour_TT := "Grid colour."
MC_GridThickness_TT := "Grid thickness."
MC_SelectionThickness_TT := "Selection thickness."
MC_SelectionColour_TT := "Selection Colour."
;	List
CheckboxProperty_TT := "List styles."
DragDrop_DDL_TT := "Drag & drop settings."
List_AutoHDR_TT := "Autosize columns."
ListLoad_TT := "Load List.json on startup."
ListRefresh_TT := "Refresh list`n" . Chr(183) . " Deletes all rows with empty folders`n" . Chr(183) . " Updates checkbox properties"
Openwith_TT := "Alternatives:`n"Chr(183)"Raw - view raw images.`n"Chr(183)"Output - view cropped images.`n"Chr(183)"Blank field opens folder in file explorer.`n"Chr(183)"Full path to XnView.exe, opens folder in XnView."
OpenWithButton_TT := "Select program."
PercentageDifference_TT := "The percentage difference between folders."
;	Mouse Coordinates
xMC_Local_Navigator_TT := "X-Axis."
yMC_Local_Navigator_TT := "Y-Axis."
xMC_Left_Image_TT := "X-Axis."
yMC_Left_Image_TT := "Y-Axis."
xMC_Right_Image_TT := "X-Axis."
yMC_Right_Image_TT := "Y-Axis."
Mouse_GetPos1_TT := "Move the mouse arrow to the local navigator in`n" . mBranch_A2 . "`nand press Alt+1 to set coordinates.`n`nRequire:`n"Chr(183)"Settings needs to be the active window.`n`nAlso collects and updates:`n"Chr(183)"Path to " . mBranch_A1 . ".`n"Chr(183)"Process.`n"Chr(183)"Title."
Mouse_GetPos2_TT := "Move the mouse arrow to the left shoulder search area and`npress Alt+2 to set coordinates.`n`nRequire:`n"Chr(183)"Settings needs to be the active window."
Mouse_GetPos3_TT := "Move the mouse arrow to the right shoulder search area and`npress Alt+3 to set coordinates.`n`nRequire:`n"Chr(183)"Settings needs to be the active window."
;	Page Improver
PI_Mode_TT := "Operating mode for " . mBranch_A1_Modified[1] . " and the number`nof images the script searches for in output folder." ; `n`nL & R mode:`n"Chr(183)"Needs shoulder search to be effective.
Output_Folder_TT := "Subfolder with cropped images."
Output_Action_TT := "Existing files in output folder."
mBranch_A1_TT := "Determine whether " . mBranch_A1_Modified[1] . " is running."
mBranch_A2_TT := "Determine whether " . mBranch_A2 . "`nis the active window."
cBranch_A1_TT := "The file path to " . mBranch_A1
Conditional_Branch_TT := "Restarts a crashed or closed " . mBranch_A1_Modified[1] . ".`n`nPrerequisite for:`n"Chr(183)"Apply effect.`n"Chr(183)"Automatic crop.`n"Chr(183)"Initial restart."
Initial_Restart_TT := "Initial restart of " . mBranch_A1_Modified[1] . ".`n`nRequire:`n"Chr(183)"Restart " . mBranch_A1_Modified[1] . "."
Apply_Effect_TT := "Effect is applied after launching " . mBranch_A1_Modified[1] . ".`n`nRequire:`n"Chr(183)"Restart " . mBranch_A1_Modified[1] . "."
;AutoCrop_TT := "Row checkbox state determine whether or not to`nrestart " . mBranch_A1_Modified[1] . ".`n`nRequire:`n"Chr(183)"Restart " . mBranch_A1_Modified[1] . ".`n"Chr(183)"Initial Restart.`n"Chr(183)"Shoulder Search."
AutoCrop_TT := "Require:`n"Chr(183)"Restart " . mBranch_A1_Modified[1] . ".`n"Chr(183)"Initial restart.`n"Chr(183)"Shoulder search."
ShoulderSearch_TT := "Places shoulder in search zones.`n`nRequire:`n"Chr(183)"L & R mode."
;	Progress
Images_Timer_TT := "Count images."
DeadLine_TT := Chr(183)"ON`nUses timer column and multiplies it.`nContinues or stops when time limit is reached.`n`n"Chr(183)"OFF`nNot recommended if computer is unattended.`nRestricted to a maximum of two hours."
Timelimit_TT := "Timer multiplier."
DeadlineActiontaken_TT := Chr(183)"Continue`nStart the next row when time limit is reached.`nReq: Restart " . mBranch_A1_Modified[1] . ".`n`n"Chr(183)"Stop`nStops when limit is reached."
iCount_T1_TT := "The initial delay before counting images."
iCount_T2_TT := "The amplitude of the interval."
iCount_T3_TT := "The final delay when counting is complete."
Duration_Timer_TT := % "Count time.`n`n" . Chr(183) . "Adjust minimum execution time for small images`n" . A_Space . "and crop speed for large images.`n" . Chr(183) . Appname . " measures the avarage image size of each folder`n" . A_Space . " and uses the slowest timer."
Limit_TT := "Minimum execution time between`ncropped images in " . mBranch_A1_Modified[1]
MB_Second_TT := "Crop speed in MBps"
;	Main Branch
mBranch_T1_TT := "Script delay after apply & preview."
mBranch_T2_TT := "Script delay before commands are sent to " . mBranch_A1_Modified[1] . "."
mBranch_T3_TT := "Script delay before a set of actions." 
mBranch_T4_TT := "Script delay between actions."
mBranch_T5_TT := "Script delay for " . mBranch_A1_Modified[1] . " file overwrite warning."
mBranch_T6_TT := "Waits until the specified window is active."
;	Restart Branch
cBranch_T1_TT := "Script delay after starting " . mBranch_A1_Modified[1] . "."
cBranch_T2_TT := "Script delay before a set of actions."
cBranch_T3_TT := "Script delay between actions."
cBranch_T4_TT := "Waits until no matching windows can be found."
;	Send Mode
Control_Send_TT := "Sends directly to a window or control"
KeyDelayCS_TT := "Miliseconds"
PressDurationCS_TT := "Miliseconds"
Send_Event_TT := "Sends actual mouse clicks and keystrokes."
Send_Input_TT := "No delay and more reliable. Buffers any physical`nkeyboard or mouse activity during send."
KeyDelay_TT := "Miliseconds"
PressDuration_TT := "Miliseconds"
Gui, 1:Submit, NoHide
;Gui, 2:Submit, NoHide
Gui, 3:Submit, NoHide
;----------------------------------------------------------------------------
;	OnMessage
;----------------------------------------------------------------------------
;OnMessage(WM_HELP, "WM_HELP")
;OnMessage(WM_LBUTTONDOWN, "WM_LBUTTONDOWN")
OnMessage(WM_MOUSEMOVE, "WM_MOUSEMOVE")
OnMessage(WM_NOTIFY, "WM_NOTIFY")
Return

;----------------------------------------------------------------------------
;	Load and Save
;----------------------------------------------------------------------------

; Function:				AutoPIFiles
; Description:			Used by Menu Load, save and save as.

AutoPIFiles(Action){
	If (Action = "Load")
		{
			;M: Multi-select
			;1: File Must Exist
			;2: Path Must Exist
			FileSelectFile, Files, M3, %A_WorkingDir%, % Appname . " - Load", (*.json)
			If ErrorLevel
				{
					Return
				}
			Array := StrSplit(Files ,"`n",, -1)
			Loop % Array.Count()-1
				{
					Ext := FilesystemObj.GetExtensionName(Array[A_Index+1])
					if Ext in json
						{
							if !Load(Array[1] . "\" . Array[A_Index+1], "r", A_FileEncoding){
									Error .= "`n" Array[1] . "\" . Array[A_Index+1]
								}
						}
					Else
						{
							Error .= "`n" Array[1] . "\" . Array[A_Index+1]
						}
				}
			Gui, 1:Submit, NoHide
			;Gui, 2:Submit, NoHide
			Gui, 3:Submit, NoHide
			Return Error
		}
	; "w" flag empties file, "rw" does not.
	If (Action = "Save")
		{
			if !Save("List.json", "w", A_FileEncoding){
					Error .= ErrorCheck("List.json")
				}
			if !Save("Settings.json", "w", A_FileEncoding){
					Error .= ErrorCheck("Settings.json")
				}
			if !Save("Table.json", "w", A_FileEncoding){
					Error .= ErrorCheck("Table.json")
				}
			Return Error
		}
	If (Action = "Save as")
		{
			; S: Save dialog
			; 1: File Must Exist
			; 2: Path Must Exist
			; 16: Prompt to Overwrite File
			FileSelectFile, File, S19, %A_WorkingDir%, % Appname . " - Save as .json", (*.json)
			If ErrorLevel
				{
					Return
				}
			Ext := FilesystemObj.GetExtensionName(File)
			if Ext in json
				{
					if Save(File, "w", A_FileEncoding){
						Return
					}
				}
			Return "`n" File
		}
}

;----------------------------------------------------------------------------

; Function:				Load(File, Flag, Encoding)
; Description:			Reading .json files stored in A_WorkingDir and updates variables. Returns True or False.
;
; FileOpen				r-Read, w-write, a-append, rw-read/write, h-Filename is a file handle to wrap in an object.
;
; List:					Reads List.json and updates GUI 1 list view variable: list.
; Old Code:				LV_Add(Value*) / ListObjL._NewEnum()[k, v]
;
; Settings:				Reads Settings.json and updates variables in GUI 3.
; Default values:		Connected to DefaultSettings.
; UpDown Variables:		Adding new things to the GUI causes their numbers to be wrong. Startup_settings also needs to be updated.
;
; Table:				Reads Table.json and updates GUI 3 list view variable (List2).

Load(File, Flag, Encoding){
	Gui +OwnDialogs
	;msgbox % "File in load: " . File
	SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	If InStr(File, "List")
		{
			Listvar := FileOpen(File, Flag, Encoding)
			if !IsObject(Listvar)
				{
					;MsgBox, 262160, %Appname% - Error, Unable to read.`n%A_WorkingDir%\List.json
					Return False
				}
			ListObjL := Jxon_load(Listvar.Read())
			Listvar.Close()
			if ListObjL.Count()
				{
					if LV_GetCount()
						{
							MsgBox,	262435, %Appname% - Load, Load selected file and remove old rows?
							IfMsgBox Yes
								{
									LV_Delete()
									LV_Update("GetCount")
								}
							IfMsgBox Cancel
								{
									Return True
								}
						}
					SB_SetText("Reading List",2,1)
					GuiControl, -Redraw, List
					For Key, Value in ListObjL
						{
							If (ListObjL[(Key), "Status"] = "") or (ListObjL[(Key), "Folder"] = "") or (ListObjL[(Key), "Profile"] = "") or (ListObjL[(Key), "Images"] = "") or (ListObjL[(Key), "Size"] = "") or (ListObjL[(Key), "Timer"] = "") {
									Continue
								}Else{
									/*
									If (Instr((ListObjL[(Key), "Size"]), "GB")){
											SortSize := Floor(1000000*StrReplace((ListObjL[(Key), "Size"]), A_Space . "GB"))
										}
									If (Instr((ListObjL[(Key), "Size"]), "MB")){
											SortSize := (1000*StrReplace((ListObjL[(Key), "Size"]), A_Space . "MB"))
										}
									If (Instr((ListObjL[(Key), "Size"]), "KB")){
											SortSize := StrReplace((ListObjL[(Key), "Size"]), A_Space . "KB")
										}
									*/
									If (ListObjL[(Key), "Format"] != "")
										{
											If (ListObjL[(Key), "Width"] != "") && (ListObjL[(Key), "Height"]) && (ListObjL[(Key), "PPI"] != "") && (ListObjL[(Key), "L.TopBorder"] != "") && (ListObjL[(Key), "L.BottomBorder"] != "") && (ListObjL[(Key), "R.TopBorder"] != "") && (ListObjL[(Key), "R.BottomBorder"])
												{
													Cropinfo := Object()
													Cropinfo["Width"] := ListObjL[(Key), "Width"]
													Cropinfo["Height"] := ListObjL[(Key), "Height"]
													Cropinfo["PPI"] := ListObjL[(Key), "PPI"]
													Cropinfo["L.TopBorder"] := ListObjL[(Key), "L.TopBorder"]
													Cropinfo["L.BottomBorder"] := ListObjL[(Key), "L.BottomBorder"]
													Cropinfo["R.TopBorder"] := ListObjL[(Key), "R.TopBorder"]
													Cropinfo["R.BottomBorder"] := ListObjL[(Key), "R.BottomBorder"]
													MC_Obj[ListObjL[(Key), "Folder"]] := Cropinfo
											}Else{
													ListObjL[(Key), "Format"] := ""
												}
										}
									LV_Add(ListObjL[(Key), "Status"], ListObjL[(Key), "Folder"], ListObjL[(Key), "Profile"], ListObjL[(Key), "Format"], ListObjL[(Key), "Images"], ListObjL[(Key), "Size"], ListObjL[(Key), "Timer"])
								}
						}
					If LV_GetCount()
					GoSub, List_Update
					GuiControl, +Redraw, List
					If (Folderrow > 1){
							RowNumber := LV_GetNext(Folderrow-1)
							LV_Modify(RowNumber, "Focus Vis")
						}
					If (!xMC_Local_Navigator && !yMC_Local_Navigator) or (!xMC_Left_Image && !yMC_Left_Image) or (!xMC_Right_Image && !yMC_Right_Image)
						{
							SB_SetText("Please set new mouse coordinates in settings",2,1)
					}Else{
							SB_SetText("",2,1)
						}
					Return True
				}Else{
					; True: Prevent error with empty file.
					Return True
				}
		}
	If InStr(File, "Table")
		{
			Tablevar := FileOpen(File, Flag, Encoding)
			if !IsObject(Tablevar)
				{
					;MsgBox, 262160, %Appname% - Error, Unable to read.`n%A_WorkingDir%\Table.json
					Return False
				}
			TableObjL := Jxon_load(Tablevar.Read())
			Tablevar.Close()
			If TableObjL.Count()
				{	
					SB_SetText("Reading Table",2,1)
					Gui, 3:Default
					GuiControl, -Redraw, List2
					LV_Delete()
					For Key, Value in TableObjL
						{
							If (Key = "") or (TableObjL[(Key), "Pages"] = "") or (TableObjL[(Key), "Resize Width"] = "") or (TableObjL[(Key), "Resize Height"] = ""){
									Continue
								}Else{
									LV_Add(,Key, TableObjL[(Key), "Pages"], TableObjL[(Key), "Resize Width"], TableObjL[(Key), "Resize Height"])
								}
						}
					GuiControl, +Redraw, List2
					Gui, 1:Default
					SB_SetText("",2,1)
					Return True
			}Else{
					Return False
				}
		}
	If InStr(File, "Settings") or InStr(File, "Single Pages") or InStr(File, "L & R on One Image") or InStr(File, "L & R on Two Images")
		{
			Settingsvar := FileOpen(File, Flag, Encoding)
			if !IsObject(Settingsvar)
				{
					;MsgBox, 262160, %Appname% - Error, Unable to read.`n%A_WorkingDir%\Settings.json
					Return False
				}
			SettingsObjL := Jxon_load(Settingsvar.Read())
			Settingsvar.Close()
			if SettingsObjL.Count()
				{
					If InStr(File, "Settings"){
							SB_SetText("Reading Settings",2,1)
						}Else{
							SB_SetText("Reading Prefix",2,1)
						}
					DefaultValue := DefaultSettings("Create")
					;	Automatic Crop
					AC_Borderx := SettingsObjL["Automatic Crop", "Border Margins"]
					AC_UpperLeftMarginx := SettingsObjL["Automatic Crop", "UpperLeftMargin"]
					AC_UpperRightMarginx := SettingsObjL["Automatic Crop", "UpperRightMargin"]
					AC_LowerLeftMarginx := SettingsObjL["Automatic Crop", "LowerLeftMargin"]
					AC_LowerRightMarginx := SettingsObjL["Automatic Crop", "LowerRightMargin"]
					AC_Sweepx := SettingsObjL["Automatic Crop", "Shoulder Sweep"]
					AC_UpperLeftSweepx := SettingsObjL["Automatic Crop", "UpperLeftSweep"]
					AC_UpperRightSweepx := SettingsObjL["Automatic Crop", "UpperRightSweep"]
					AC_LowerLeftSweepx := SettingsObjL["Automatic Crop", "LowerLeftSweep"]
					AC_LowerRightSweepx := SettingsObjL["Automatic Crop", "LowerRightSweep"]
					AC_Tablex := SettingsObjL["Automatic Crop", "Table"]
					AC_TablePathx := SettingsObjL["Automatic Crop", "Table Path"]
					AC_PPIx := SettingsObjL["Automatic Crop", "PPI"]
					AC_Manualx := SettingsObjL["Automatic Crop", "Manual"]
					AC_Manual_sDDLx := SettingsObjL["Automatic Crop", "Manual Setting"]
					AC_WidthAdjust_Millimeterx := SettingsObjL["Automatic Crop", "Millimeter Width Adjustment"]
					AC_HeightAdjust_Millimeterx := SettingsObjL["Automatic Crop", "Millimeter Height Adjustment"]
					AC_WidthAdjust_Percentx := SettingsObjL["Automatic Crop", "Percent Width Adjustment"]
					AC_HeightAdjust_Percentx := SettingsObjL["Automatic Crop", "Percent Height Adjustment"]
					AC_WidthAdjust_Pixelx := SettingsObjL["Automatic Crop", "Pixel Width Adjustment"]
					AC_HeightAdjust_Pixelx := SettingsObjL["Automatic Crop", "Pixel Height Adjustment"]
					;	Drive Space
					Disk_Spacex := SettingsObjL["Drive Space", "Free"]
					;	Folder & Profile
					Crop_Checkx := SettingsObjL["User Interface", "Crop Warning"]
					Folderpathx := SettingsObjL["User Interface", "Folder Path"]
					ImageExtensionx := SettingsObjL["User Interface", "Image Extension"]
					ImageFolderx := SettingsObjL["User Interface", "Images Folder"]
					ImageFolderCheckx := SettingsObjL["User Interface", "Folder Warning"]
					Profilepathx := SettingsObjL["User Interface", "Profile Path"]
					ProfileExtensionx := SettingsObjL["User Interface", "Profile Extention"]
					;	Hotkeys
					savedHK1 := SettingsObjL["Hotkeys", "#1"]
					Macro_Delay_1x := SettingsObjL["Hotkeys", "#1 Macro Delay"]
					savedHK2 := SettingsObjL["Hotkeys", "#2"]
					savedHK3 := SettingsObjL["Hotkeys", "#3"]
					savedHK4 := SettingsObjL["Hotkeys", "#4"]
					savedHK5 := SettingsObjL["Hotkeys", "#5"]
					Space_Macrox := SettingsObjL["Hotkeys", "Space"]
					Space_Macro_Delayx := SettingsObjL["Hotkeys", "Space Delay"]
					Space_Processx := SettingsObjL["Hotkeys", "Space Process"]
					;	Imageview
					MC_GridColourx := SettingsObjL["Imageview", "Grid Colour"]
					MC_GridThicknessx := SettingsObjL["Imageview", "Grid Thickness"]
					MC_Interpolationx := SettingsObjL["Imageview", "Interpolation"]
					MC_PixelOffsetx := SettingsObjL["Imageview", "Pixel Offset"]
					MC_Anglex := SettingsObjL["Imageview", "Rotation Increment"]
					MC_Smoothingx := SettingsObjL["Imageview", "Smoothing"]
					MC_SelectionColourx := SettingsObjL["Imageview", "Selection Colour"]
					MC_SelectionThicknessx := SettingsObjL["Imageview", "Selection Thickness"]
					;	List
					DragDrop_DDLx := SettingsObjL["User Interface", "Drag & Drop"]
					CheckboxPropertyx := SettingsObjL["User Interface", "List Style"]
					List_AutoHDRx := SettingsObjL["User Interface", "Autosize Columns"]
					ListLoadx := SettingsObjL["User Interface", "Load On Startup"]
					Listrefreshx := SettingsObjL["User Interface", "Refresh List"]
					Openwithx := SettingsObjL["User Interface", "Open With Program"]
					PercentageDifferencex := SettingsObjL["User Interface", "Percentage Difference"]
					;	Mouse Coordinates
					xMC_Local_Navigatorx := SettingsObjL["Mouse Coordinates", "Local Navigator X"]
					yMC_Local_Navigatorx := SettingsObjL["Mouse Coordinates", "Local Navigator Y"]
					xMC_Left_Imagex := SettingsObjL["Mouse Coordinates", "Left Shoulder X"]
					yMC_Left_Imagex := SettingsObjL["Mouse Coordinates", "Left Shoulder Y"]
					xMC_Right_Imagex := SettingsObjL["Mouse Coordinates", "Right Shoulder X"]
					yMC_Right_Imagex := SettingsObjL["Mouse Coordinates", "Right Shoulder Y"]
					;	Page Improver
					Effectsx := SettingsObjL["Page Improver", "Effect"]
					Pi_Modex := SettingsObjL["Page Improver", "Operating Mode"]
					Output_Folderx := SettingsObjL["Page Improver", "Output Folder"]
					Output_Actionx := SettingsObjL["Page Improver", "Existing Files"]
					mBranch_A1x := SettingsObjL["Page Improver", "Process"]
					mBranch_A2x := SettingsObjL["Page Improver", "Title"]
					cBranch_A1x := SettingsObjL["Page Improver", "Path"]
					Conditional_Branchx := SettingsObjL["Page Improver", "Restart Page Improver"]
					Initial_Restartx := SettingsObjL["Page Improver", "Initial Restart"]
					Apply_Effectx := SettingsObjL["Page Improver", "Apply Effect"]
					ShoulderSearchx := SettingsObjL["Page Improver", "Shoulder Search"]
					AutoCropx := SettingsObjL["Page Improver", "Automatic Crop"]
					;	Progress
					Images_Timerx := SettingsObjL["Progress", "Use Images"]
					Deadlinex := SettingsObjL["Progress", "Time Limit"]
					Timelimitx := SettingsObjL["Progress", "Timer Column"]
					DeadlineActiontakenx := SettingsObjL["Progress", "Action Taken"]
					iCount_T1x := SettingsObjL["Progress", "Delay (sec) - Start"]
					iCount_T2x := SettingsObjL["Progress", "Delay (sec) - Interval"]
					iCount_T3x := SettingsObjL["Progress", "Delay (sec) - End"]
					Duration_Timerx := SettingsObjL["Progress", "Use Timer"]
					Limitx := SettingsObjL["Progress", "Minimum Execution Time"]
					MB_Secondx := SettingsObjL["Progress", "Page Improver Crop Speed"]
					;	Main Branch Delay
					mBranch_T1x := SettingsObjL["Main Branch Delay", "#1"]
					mBranch_T2x := SettingsObjL["Main Branch Delay", "#2"]
					mBranch_T3x := SettingsObjL["Main Branch Delay", "#3"]
					mBranch_T4x := SettingsObjL["Main Branch Delay", "#4"]
					mBranch_T5x := SettingsObjL["Main Branch Delay", "#5"]
					mBranch_T6x := SettingsObjL["Main Branch Delay", "#6"]
					;	Restart Branch
					cBranch_T1x := SettingsObjL["Restart Branch Delay", "#1"]
					cBranch_T2x := SettingsObjL["Restart Branch Delay", "#2"]
					cBranch_T3x := SettingsObjL["Restart Branch Delay", "#3"]
					cBranch_T4x := SettingsObjL["Restart Branch Delay", "#4"]
					;	Send Mode
					ControlSendx := SettingsObjL["Send Mode", "ControlSend"]
					KeyDelayCSx := SettingsObjL["Send Mode", "Control Key KeyDelay"]
					PressDurationCSx := SettingsObjL["Send Mode", "Control Press Duration"]
					SendEventx := SettingsObjL["Send Mode", "SendEvent"]
					SendInputx := SettingsObjL["Send Mode", "SendInput"]
					KeyDelayx := SettingsObjL["Send Mode", "Event Key Delay"]
					PressDurationx := SettingsObjL["Send Mode", "Event Press Duration"]
					;	Automatic Crop
					if AC_Borderx in 0,1
						{
							GuiControl,3:, AC_Border, %AC_Borderx%
						}Else{
							GuiControl,3:, AC_Border, % DefaultValue["AC_Border"]
						}
					UpDown245_fIncrement := DefaultValue["UpDown245_fIncrement"], UpDown245_fRangeMin := DefaultValue["UpDown245_fRangeMin"], UpDown245_fRangeMax := DefaultValue["UpDown245_fRangeMax"] ;	Margins. Upper Left.
					if AC_UpperLeftMarginx between -9999 and 9999
						{
							GuiControl,3:, AC_UpperLeftMargin, % Floor(AC_UpperLeftMarginx)
						}Else{
							GuiControl,3:, AC_UpperLeftMargin, % DefaultValue["AC_UpperLeftMargin"]
						}
					UpDown248_fIncrement := DefaultValue["UpDown248_fIncrement"], UpDown248_fRangeMin := DefaultValue["UpDown248_fRangeMin"], UpDown248_fRangeMax := DefaultValue["UpDown248_fRangeMax"] ;	Margins. Upper Right.
					if AC_UpperRightMarginx between -9999 and 9999
						{
							GuiControl,3:, AC_UpperRightMargin, % Floor(AC_UpperRightMarginx)
						}Else{
							GuiControl,3:, AC_UpperRightMargin, % DefaultValue["AC_UpperRightMargin"]
						}
					UpDown251_fIncrement := DefaultValue["UpDown251_fIncrement"], UpDown251_fRangeMin := DefaultValue["UpDown251_fRangeMin"], UpDown251_fRangeMax := DefaultValue["UpDown251_fRangeMax"] ;	Margins. Lower Left.
					if AC_LowerLeftMarginx between -9999 and 9999
						{
							GuiControl,3:, AC_LowerLeftMargin, % Floor(AC_LowerLeftMarginx)
						}Else{
							GuiControl,3:, AC_LowerLeftMargin, % DefaultValue["AC_LowerLeftMargin"]
						}
					UpDown254_fIncrement := DefaultValue["UpDown254_fIncrement"], UpDown254_fRangeMin := DefaultValue["UpDown254_fRangeMin"], UpDown254_fRangeMax := DefaultValue["UpDown254_fRangeMax"] ;	Margins. Lower Right.
					if AC_LowerRightMarginx between -9999 and 9999
						{
							GuiControl,3:, AC_LowerRightMargin, % Floor(AC_LowerRightMarginx)
						}Else{
							GuiControl,3:, AC_LowerRightMargin, % DefaultValue["AC_LowerRightMargin"]
						}
					if AC_Sweepx in 0,1
						{
							GuiControl,3:, AC_Sweep, %AC_Sweepx%
						}Else{
							GuiControl,3:, AC_Sweep, % DefaultValue["AC_Sweep"]
						}
					if AC_UpperLeftSweepx is Number
						{
							GuiControl,3:, AC_UpperLeftSweep, % Floor(AC_UpperLeftSweepx)
						}Else{
							GuiControl,3:, AC_UpperLeftSweep, % DefaultValue["AC_UpperLeftSweep"]
						}
					if AC_UpperRightSweepx is Number
						{
							GuiControl,3:, AC_UpperRightSweep, % Floor(AC_UpperRightSweepx)
						}Else{
							GuiControl,3:, AC_UpperRightSweep, % DefaultValue["AC_UpperRightSweep"]
						}
					if AC_LowerLeftSweepx is Number
						{
							GuiControl,3:, AC_LowerLeftSweep, % Floor(AC_LowerLeftSweepx)
						}Else{
							GuiControl,3:, AC_LowerLeftSweep, % DefaultValue["AC_LowerLeftSweep"]
						}
					if AC_LowerRightSweepx is Number
						{
							GuiControl,3:, AC_LowerRightSweep, % Floor(AC_LowerRightSweepx)
						}Else{
							GuiControl,3:, AC_LowerRightSweep, % DefaultValue["AC_LowerRightSweep"]
						}
				;   Manual AutoCrop Millimeter
					if AC_WidthAdjust_Millimeterx between -1000 and 1000
						{
							AC_WidthAdjust_Millimeter := % Floor(AC_WidthAdjust_Millimeterx)
						}Else{
							AC_WidthAdjust_Millimeter := % DefaultValue["AC_WidthAdjust_Millimeter"]
						}
					if AC_HeightAdjust_Millimeterx between -1000 and 1000
						{
							AC_HeightAdjust_Millimeter := % Floor(AC_HeightAdjust_Millimeterx)
						}Else{
							AC_HeightAdjust_Millimeter := % DefaultValue["AC_HeightAdjust_Millimeter"]
						}
				;   Manual AutoCrop Percent
					if AC_WidthAdjust_Percentx between -100.0 and 100.0
						{
							AC_WidthAdjust_Percent := % Round(AC_WidthAdjust_Percentx,1)
						}Else{
							AC_WidthAdjust_Percent := % DefaultValue["AC_WidthAdjust_Percent"]
						}
					if AC_HeightAdjust_Percentx between -100.0 and 100.0
						{
							AC_HeightAdjust_Percent := % Round(AC_HeightAdjust_Percentx,1)
						}Else{
							AC_HeightAdjust_Percent := % DefaultValue["AC_HeightAdjust_Percent"]
						}
				;   Manual AutoCrop Pixel
					if AC_WidthAdjust_Pixelx between -1000 and 1000
						{
							AC_WidthAdjust_Pixel := % Floor(AC_WidthAdjust_Pixelx)
						}Else{
							AC_WidthAdjust_Pixel := % DefaultValue["AC_WidthAdjust_Pixel"]
						}
					if AC_HeightAdjust_Pixelx between -1000 and 1000
						{
							AC_HeightAdjust_Pixel := % Floor(AC_HeightAdjust_Pixelx)
						}Else{
							AC_HeightAdjust_Pixel := % DefaultValue["AC_HeightAdjust_Pixel"]
						}
					if AC_Manual_sDDLx in Millimeter,Percent,Pixel
						{
							GuiControl,3:ChooseString, AC_Manual_sDDL, %AC_Manual_sDDLx%
						}Else{
							GuiControl,3:ChooseString, AC_Manual_sDDL, % DefaultValue["AC_Manual_sDDL"]
							AC_Manual_sDDLx := "Percent"
						}
					If (AC_Manual_sDDLx = "Millimeter"){
							UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Millimeter"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Millimeter"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Millimeter"] ;	Wdith Adjustment.
							GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Millimeter
							UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Millimeter"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Millimeter"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Millimeter"] ;	Height Adjustment.
							GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Millimeter
						}
					If (AC_Manual_sDDLx = "Percent"){
							UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Percent"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Percent"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Percent"] ;	Wdith Adjustment.
							GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Percent
							UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Percent"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Percent"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Percent"] ;	Height Adjustment.
							GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Percent
						}
					If (AC_Manual_sDDLx = "Pixel"){
							UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Pixel"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Pixel"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Pixel"] ;	Wdith Adjustment.
							GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Pixel
							UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Pixel"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Pixel"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Pixel"] ;	Height Adjustment.
							GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Pixel
						}
					if AC_PPIx in 300,400,500,600
						{
							GuiControl,3:ChooseString, AC_PPI, %AC_PPIx%
						}Else{
							GuiControl,3:ChooseString, AC_PPI, % DefaultValue["AC_PPI"]
						}
					if AC_Manualx in 0,1
						{
							GuiControl,3:, AC_Manual, %AC_Manualx%
						}Else{
							GuiControl,3:, AC_Manual, % DefaultValue["AC_Manual"]
						}
					if AC_Tablex in 0,1
						{
							GuiControl,3:, AC_Table, %AC_Tablex%
						}Else{
							GuiControl,3:, AC_Table, % DefaultValue["AC_Table"]
						}
					If AC_TablePathx
						{
							GuiControl,3:, AC_TablePath, %AC_TablePathx%
						}Else{
							GuiControl,3:, AC_TablePath, % DefaultValue["AC_TablePath"]
						}
					Gui, 3:Submit, NoHide
					If (AC_Manual = AC_Table){
							GuiControl,3:, AC_Manual, % DefaultValue["AC_Manual"]
							GuiControl,3:, AC_Table, % DefaultValue["AC_Table"]
							Gui, 3:Submit, NoHide
						}
					GoSub, Select_AC
					;	Drive Space
					if Disk_Spacex is Number
						{
							GuiControl,3:, Disk_Space, % Floor(Disk_Spacex)
						}Else{
							GuiControl,3:, Disk_Space, % DefaultValue["Disk_Space"]
						}
					;	Folder & Profile
					If (Folderpathx = ""){
							GuiControl,3:ChooseString, Folderpath, % DefaultValue["Folderpath"]
						}Else{
							ControlGet, FolderpathList, List,,, ahk_id %FolderHWND%
							if InStr(FolderpathList, Folderpathx, false, 1, 1){
									GuiControl,3:ChooseString, Folderpath, %Folderpathx%
								}Else{
									GuiControl,3:, Folderpath, %Folderpathx%
									GuiControl,3:ChooseString, Folderpath, %Folderpathx%
								}
						}
					if Crop_Checkx in 0,1
						{
							GuiControl,3:, Crop_Check, %Crop_Checkx%
						}Else{
							GuiControl,3:, Crop_Check, % DefaultValue["Crop_Check"]
						}
					if ImageFolderCheckx in 0,1
						{
							GuiControl,3:, ImageFolderCheck, %ImageFolderCheckx%
						}Else{
							GuiControl,3:, ImageFolderCheck, % DefaultValue["ImageFolderCheck"]
						}
					If (ImageExtensionx = ""){
							GuiControl,3:, ImageExtension, % DefaultValue["ImageExtension"]
						}Else{
							GuiControl,3:, ImageExtension, %ImageExtensionx%
						}
					if (ImageFolderx = ""){
							GuiControl,3:, ImageFolder, % DefaultValue["ImageFolder"]
						}Else{
							GuiControl,3:, ImageFolder, %ImageFolderx%
						}
					if (Profilepathx = ""){
							GuiControl,3:ChooseString, Profilepath, % DefaultValue["Profilepath"]
						}Else{
							ControlGet, ProfilepathList, List,,, ahk_id %ProfileHWND%
							if InStr(ProfilepathList, Profilepathx, false, 1, 1){
									GuiControl,3:ChooseString, Profilepath, %Profilepathx%
								}Else{
									GuiControl,3:, Profilepath, %Profilepathx%
									GuiControl,3:ChooseString, Profilepath, %Profilepathx%
								}
						}
					if (ProfileExtensionx = ""){
							GuiControl,3:, ProfileExtension, % DefaultValue["ProfileExtension"]
						}Else{
							GuiControl,3:, ProfileExtension, %ProfileExtensionx%
						}
					;	Hotkeys
					Loop, 5
						{
							If(A_Index = 4)
								{
									If savedHK%A_Index%
										{
											Hotkey,% savedHK%A_Index%, Hotkey%A_Index%, T2
										}
							}Else{
									If savedHK%A_Index%
										{
											Hotkey,% savedHK%A_Index%, Hotkey%A_Index%, T1
										}
								}
							If InStr(savedHK%A_Index%, "~"){
									GuiControl,3:, HK%A_Index%, % StrReplace(savedHK%A_Index%, "~",,, 1)
								}
							If InStr(savedHK%A_Index%, "#"){
									GuiControl,3:, HK%A_Index%, % StrReplace(savedHK%A_Index%, "#",, OutputVarCount, 1)
									GuiControl,3:, CB%A_Index%, % OutputVarCount
								}
						}
					if Macro_Delay_1x in 0,1,2,3,4,5,6,7,8,9
						{
							GuiControl,3:ChooseString, Macro_Delay_1, %Macro_Delay_1x%
						}Else{
							GuiControl,3:ChooseString, Macro_Delay_1, % DefaultValue["Macro_Delay_1"]
						}
					if Space_Macrox in 0,1
						{
							GuiControl,3:, Space_Macro, %Space_Macrox%
						}Else{
							GuiControl,3:, Space_Macro, % DefaultValue["Space_Macro"]
						}
					if Space_Macro_Delayx between 0 and 9999
						{
							GuiControl,3:, Space_Macro_Delay, % Floor(Space_Macro_Delayx)
						}Else{
							GuiControl,3:, Space_Macro_Delay, % DefaultValue["Space_Macro_Delay"]
						}
					If (Space_Processx = ""){
							GuiControl,3:, Space_Process, % DefaultValue["Space_Process"]
						}Else{
							GuiControl,3:, Space_Process, %Space_Processx%
						}
					;	Imageview
					if MC_GridColourx in Black,Red,White
						{
							GuiControl,3:ChooseString, MC_GridColour, %MC_GridColourx%
						}Else{
							GuiControl,3:ChooseString, MC_GridColour, % DefaultValue["Grid Colour"]
						}
					UpDown63_fIncrement := DefaultValue["UpDown63_fIncrement"], UpDown63_fRangeMin := DefaultValue["UpDown63_fRangeMin"], UpDown63_fRangeMax := DefaultValue["UpDown63_fRangeMax"] ;	Grid Thickness.
					if MC_GridThicknessx is Number
						{
							GuiControl,3:, MC_GridThickness, % Round(MC_GridThicknessx, 1)
						}Else{
							GuiControl,3:, MC_GridThickness, % DefaultValue["Grid Thickness"]
						}
					if MC_Interpolationx in Default,LowQuality,HighQuality,Bilinear,Bicubic,NearestNeighbor,HighQualityBilinear,HighQualityBicubic
						{
							GuiControl,3:ChooseString, MC_Interpolation, %MC_Interpolationx%
						}Else{
							GuiControl,3:ChooseString, MC_Interpolation, % DefaultValue["Interpolation"]
						}
					if MC_PixelOffsetx in Default,HighSpeed,HighQuality,None,Half
						{
							GuiControl,3:ChooseString, MC_PixelOffset, %MC_PixelOffsetx%
						}Else{
							GuiControl,3:ChooseString, MC_PixelOffset, % DefaultValue["Pixel Offset"]
						}
					UpDown71_fIncrement := DefaultValue["UpDown71_fIncrement"], UpDown71_fRangeMin := DefaultValue["UpDown71_fRangeMin"], UpDown71_fRangeMax := DefaultValue["UpDown71_fRangeMax"] ;	Rotation Increment.
					if MC_Anglex is Number
						{
							GuiControl,3:, MC_Angle, % Round(MC_Anglex, 1)
						}Else{
							GuiControl,3:, MC_Angle, % DefaultValue["Rotation Increment"]
						}
					if MC_Smoothingx in Default,HighSpeed,HighQuality,None,AntiAlias
						{
							GuiControl,3:ChooseString, MC_Smoothing, %MC_Smoothingx%
						}Else{
							GuiControl,3:ChooseString, MC_Smoothing, % DefaultValue["Smoothing"]
						}
					if MC_SelectionColourx in Black,Silver,Gray,White,Maroon,Red,Purple,Fuchsia,Green,Lime,Olive,Yellow,Navy,Blue,Teal,Aqua
						{
							GuiControl,3:ChooseString, MC_SelectionColour, %MC_SelectionColourx%
						}Else{
							GuiControl,3:ChooseString, MC_SelectionColour, % DefaultValue["Selection Colour"]
						}
					UpDown79_fIncrement := DefaultValue["UpDown79_fIncrement"], UpDown79_fRangeMin := DefaultValue["UpDown79_fRangeMin"], UpDown79_fRangeMax := DefaultValue["UpDown79_fRangeMax"] ;	Selection Thickness.
					if MC_SelectionThicknessx is Number
						{
							GuiControl,3:, MC_SelectionThickness, % Round(MC_SelectionThicknessx, 1)
						}Else{
							GuiControl,3:, MC_SelectionThickness, % DefaultValue["Selection Thickness"]
						}
					;	List
					if List_AutoHDRx in 0,1
						{
							GuiControl,3:, List_AutoHDR, %List_AutoHDRx%
						}Else{
							GuiControl,3:, List_AutoHDR, % DefaultValue["List_AutoHDR"]
						}
					if DragDrop_DDLx in Multiple profiles,One profile
						{
							GuiControl,3:ChooseString, DragDrop_DDL, %DragDrop_DDLx%
						}Else{
							GuiControl,3:ChooseString, DragDrop_DDL, % DefaultValue["DragDrop_DDL"]
						}
					If (Openwithx = ""){
							GuiControl,3:, Openwith, % DefaultValue["Openwith"]
						}Else{
							GuiControl,3:, Openwith, %Openwithx%
						}
					if CheckboxPropertyx in Checked,None,Percentage difference
						{
							GuiControl,3:ChooseString, CheckboxProperty, %CheckboxPropertyx%
						}Else{
							GuiControl,3:ChooseString, CheckboxProperty, % DefaultValue["CheckboxProperty"]
						}
					if ListLoadx in 0,1
						{
							GuiControl,3:, ListLoad, %ListLoadx%
						}Else{
							GuiControl,3:, ListLoad, % DefaultValue["ListLoad"]
						}
					UpDown94_fIncrement := DefaultValue["UpDown94_fIncrement"], UpDown94_fRangeMin := DefaultValue["UpDown94_fRangeMin"], UpDown94_fRangeMax := DefaultValue["UpDown94_fRangeMax"] ;	Percentage Difference
					if PercentageDifferencex between 0 and 1000
						{
							GuiControl,3:, PercentageDifference, % Floor(PercentageDifferencex)
						}Else{
							GuiControl,3:, PercentageDifference, % DefaultValue["PercentageDifference"]
						}
					if ListRefreshx in 0,1
						{
							GuiControl,3:, ListRefresh, %ListRefreshx%
						}Else{
							GuiControl,3:, ListRefresh, % DefaultValue["ListRefresh"]
						}
					;	Mouse Coordinates
					if xMC_Local_Navigatorx is Number
						{
							GuiControl,3:, xMC_Local_Navigator, % Floor(xMC_Local_Navigatorx)
						}Else{
							GuiControl,3:, xMC_Local_Navigator, % DefaultValue["xMC_Local_Navigator"]
						}
					if yMC_Local_Navigatorx is Number
						{
							GuiControl,3:, yMC_Local_Navigator, % Floor(yMC_Local_Navigatorx)
						}Else{
							GuiControl,3:, yMC_Local_Navigator, % DefaultValue["yMC_Local_Navigator"]
						}
					if xMC_Left_Imagex is Number
						{
							GuiControl,3:, xMC_Left_Image, % Floor(xMC_Left_Imagex)
						}Else{
							GuiControl,3:, xMC_Left_Image, % DefaultValue["xMC_Left_Image"]
						}
					if yMC_Left_Imagex is Number
						{
							GuiControl,3:, yMC_Left_Image, % Floor(yMC_Left_Imagex)
						}Else{
							GuiControl,3:, yMC_Left_Image, % DefaultValue["yMC_Left_Image"]
						}
					if xMC_Right_Imagex is Number
						{
							GuiControl,3:, xMC_Right_Image, % Floor(xMC_Right_Imagex)
						}Else{
							GuiControl,3:, xMC_Right_Image, % DefaultValue["xMC_Right_Image"]
						}
					if yMC_Right_Imagex is Number
						{
							GuiControl,3:, yMC_Right_Image, % Floor(yMC_Right_Imagex)
						}Else{
							GuiControl,3:, yMC_Right_Image, % DefaultValue["yMC_Right_Image"]
						}
					;	Page Improver
					if Effectsx in Bluring,Edges,Emboss,Sharpening 1,Sharpening 2
						{
							GuiControl,3:ChooseString, Effects, %Effectsx%
						}Else{
							GuiControl,3:ChooseString, Effects, % DefaultValue["Effects"]
						}
					if Pi_Modex in Single Pages,L & R on One Image,L & R on Two Images
						{
							GuiControl,3:ChooseString, Pi_Mode, %Pi_Modex%
						}Else{
							GuiControl,3:ChooseString, Pi_Mode, % DefaultValue["Pi_Mode"]
						}
					If (Output_Folderx = ""){
							GuiControl,3:ChooseString, Output_Folder, % DefaultValue["Output_Folder"]
						}Else{
								ControlGet, Output_Folder_List, List,,, ahk_id %Output_FolderHWND%
								if InStr(Output_Folder_List, Output_Folderx, false, 1, 1){
									GuiControl,3:ChooseString, Output_Folder, %Output_Folderx%
								}Else{
									GuiControl,3:, Output_Folder, %Output_Folderx%
									GuiControl,3:ChooseString, Output_Folder, %Output_Folderx%
								}
						}
					if Output_Actionx in Delete,Overwrite,Skip
						{
							GuiControl,3:ChooseString, Output_Action, %Output_Actionx%
						}Else{
							GuiControl,3:ChooseString, Output_Action, % DefaultValue["Output_Action"]
						}
					if Conditional_Branchx in 0,1
						{
							GuiControl,3:, Conditional_Branch, %Conditional_Branchx%
						}Else{
							GuiControl,3:, Conditional_Branch, % DefaultValue["Conditional_Branch"]
						}
					if Initial_Restartx in 0,1
						{
							GuiControl,3:, Initial_Restart, %Initial_Restartx%
						}Else{
							GuiControl,3:, Initial_Restart, % DefaultValue["Initial_Restart"]
						}
					if Apply_Effectx in 0,1
						{
							GuiControl,3:, Apply_Effect, %Apply_Effectx%
						}Else{
							GuiControl,3:, Apply_Effect, % DefaultValue["Apply_Effect"]
						}
					if AutoCropx in 0,1
						{
							GuiControl,3:, AutoCrop, %AutoCropx%
						}Else{
							GuiControl,3:, AutoCrop, % DefaultValue["AutoCrop"]
						}
					if ShoulderSearchx in 0,1
						{
							GuiControl,3:, ShoulderSearch, %ShoulderSearchx%
						}Else{
							GuiControl,3:, ShoulderSearch, % DefaultValue["ShoulderSearch"]
						}
					If (mBranch_A1x = ""){
							GuiControl,3:, mBranch_A1, % DefaultValue["mBranch_A1"]
						}Else{
							GuiControl,3:, mBranch_A1, %mBranch_A1x%
						}
					If (mBranch_A2x = ""){
							GuiControl,3:, mBranch_A2, % DefaultValue["mBranch_A2"]
						}Else{
							GuiControl,3:, mBranch_A2, %mBranch_A2x%
						}
					If (cBranch_A1x = ""){
							GuiControl,3:, cBranch_A1, % DefaultValue["cBranch_A1"]
						}Else{
							GuiControl,3:, cBranch_A1, %cBranch_A1x%
						}
					Gui, 3:Submit, NoHide
					GuiControl,3:, Crop_Check, % (Crop_Check = 1) ? "On" : "Off"
					GuiControl,3:, List_AutoHDR, % (List_AutoHDR = 1) ? "On" : "Off"
					GuiControl,3:, ListLoad, % (ListLoad = 1) ? "On" : "Off"
					GuiControl,3:, ListRefresh, % (ListRefresh = 1) ? "On" : "Off"
					GuiControl,3:, ImageFolderCheck, % (ImageFolderCheck = 1) ? "On" : "Off"
					GuiControl,3:, AC_Border, % (AC_Border = 1) ? "On" : "Off"
					GuiControl,3:, AC_Sweep, % (AC_Sweep = 1) ? "On" : "Off"
					GuiControl,3:, Space_Macro, % (Space_Macro = 1) ? "On" : "Off"
					GuiControl,3:, Conditional_Branch, % (Conditional_Branch = 1) ? "On" : "Off"
					GuiControl,3:, Initial_Restart, % (Initial_Restart = 1) ? "On" : "Off"
					GuiControl,3:, Apply_Effect, % (Apply_Effect = 1) ? "On" : "Off"
					GuiControl,3:, ShoulderSearch, % (ShoulderSearch = 1) ? "On" : "Off"
					GuiControl,3:, AutoCrop, % (AutoCrop = 1) ? "On" : "Off"
					If (Conditional_Branch = 0){
							GuiControl,3:, Apply_Effect, 0
							GuiControl,3:, Apply_Effect, Off
							GuiControl,3:, Initial_Restart, 0
							GuiControl,3:, Initial_Restart, Off
							GuiControl,3:, AutoCrop, 0
							GuiControl,3:, AutoCrop, Off
						}
					;	Progress
					if Images_Timerx in 0,1
						{
							GuiControl,3:, Images_Timer, %Images_Timerx%
						}Else{
							GuiControl,3:, Images_Timer, % DefaultValue["Images_Timer"]
						}
					if Duration_Timerx in 0,1
						{
							GuiControl,3:, Duration_Timer, %Duration_Timerx%
						}Else{
							GuiControl,3:, Duration_Timer, % DefaultValue["Duration_Timer"]
						}
					Gui, 3:Submit, NoHide
					If (Images_Timer = Duration_Timer){
							GuiControl,3:, Images_Timer, % DefaultValue["Images_Timer"]
							GuiControl,3:, Duration_Timer, % DefaultValue["Duration_Timer"]
							Gui, 3:Submit, NoHide
						}
					If (Images_Timer = 1){
							GoSub, SelectTimer1
						}Else{
							GoSub, SelectTimer2
						}
					if Deadlinex in 0,1
						{
							GuiControl,3:, Deadline, %Deadlinex%
						}Else{
							GuiControl,3:, Deadline, % DefaultValue["Deadline"]
						}
					Gui, 3:Submit, NoHide
					GuiControl,3:, Deadline, % (Deadline = 1) ? "On" : "Off"
					if Timelimitx in 1x,2x,3x,4x,5x
						{
							GuiControl,3:ChooseString, Timelimit, %Timelimitx%
						}Else{
							GuiControl,3:ChooseString, Timelimit, % DefaultValue["Timelimit"]
						}
					if DeadlineActiontakenx in Continue,Stop
						{
							GuiControl,3:ChooseString, DeadlineActiontaken, %DeadlineActiontakenx%
						}Else{
							GuiControl,3:ChooseString, DeadlineActiontaken, % DefaultValue["DeadlineActiontaken"]
						}
					UpDown153_fIncrement := DefaultValue["UpDown153_fIncrement"], UpDown153_fRangeMin := DefaultValue["UpDown153_fRangeMin"], UpDown153_fRangeMax := DefaultValue["UpDown153_fRangeMax"] ;	Delay (sec) - Start.
					if iCount_T1x between 1 and 900
						{
							GuiControl,3:, iCount_T1, % Floor(iCount_T1x)
						}Else{
							GuiControl,3:, iCount_T1, % DefaultValue["iCount_T1"]
						}
					UpDown156_fIncrement := DefaultValue["UpDown156_fIncrement"], UpDown156_fRangeMin := DefaultValue["UpDown156_fRangeMin"], UpDown156_fRangeMax := DefaultValue["UpDown156_fRangeMax"] ;	Delay (sec) - Interval.
					if iCount_T2x between 1.0 and 60.0
						{
							GuiControl,3:, iCount_T2, % Round(iCount_T2x,1)
						}Else{
							GuiControl,3:, iCount_T2, % DefaultValue["iCount_T2"]
						}
					UpDown159_fIncrement := DefaultValue["UpDown159_fIncrement"], UpDown159_fRangeMin := DefaultValue["UpDown159_fRangeMin"], UpDown159_fRangeMax := DefaultValue["UpDown159_fRangeMax"] ;	Delay (sec) - End.
					if iCount_T3x between 2.0 and 10.0
						{
							GuiControl,3:, iCount_T3, % Round(iCount_T3x,1)
						}Else{
							GuiControl,3:, iCount_T3, % DefaultValue["iCount_T3"]
						}
					UpDown164_fIncrement := DefaultValue["UpDown164_fIncrement"], UpDown164_fRangeMin := DefaultValue["UpDown164_fRangeMin"], UpDown164_fRangeMax := DefaultValue["UpDown164_fRangeMax"] ;	Minimum Execution Time.
					if Limitx between 1.0 and 10.0
						{
							GuiControl,3:, Limit, % Round(Limitx,1)
						}Else{
							GuiControl,3:, Limit, % DefaultValue["Limit"]
						}
					UpDown168_fIncrement := DefaultValue["UpDown168_fIncrement"], UpDown168_fRangeMin := DefaultValue["UpDown168_fRangeMin"], UpDown168_fRangeMax := DefaultValue["UpDown168_fRangeMax"] ;	Page Improver Crop Speed.
					if MB_Secondx between 1 and 10000
						{
							GuiControl,3:, MB_Second, % Floor(MB_Secondx)
						}Else{
							GuiControl,3:, MB_Second, % DefaultValue["MB_Second"]
						}
					;	Main Branch Delay
					UpDown173_fIncrement := DefaultValue["UpDown173_fIncrement"], UpDown173_fRangeMin := DefaultValue["UpDown173_fRangeMin"], UpDown173_fRangeMax := DefaultValue["UpDown173_fRangeMax"] ;	Main Branch #1
					if mBranch_T1x between 100 and 10000
						{
							GuiControl,3:, mBranch_T1, % Floor(mBranch_T1x)
						}Else{
							GuiControl,3:, mBranch_T1, % DefaultValue["mBranch_T1"]
						}
					UpDown177_fIncrement := DefaultValue["UpDown177_fIncrement"], UpDown177_fRangeMin := DefaultValue["UpDown177_fRangeMin"], UpDown177_fRangeMax := DefaultValue["UpDown177_fRangeMax"] ;	Main Branch #2
					if mBranch_T2x between 0 and 10000
						{
							GuiControl,3:, mBranch_T2, % Floor(mBranch_T2x)
						}Else{
							GuiControl,3:, mBranch_T2, % DefaultValue["mBranch_T2"]
						}
					UpDown181_fIncrement := DefaultValue["UpDown181_fIncrement"], UpDown181_fRangeMin := DefaultValue["UpDown181_fRangeMin"], UpDown181_fRangeMax := DefaultValue["UpDown181_fRangeMax"] ;	Main Branch #3
					if mBranch_T3x between 100 and 10000
						{
							GuiControl,3:, mBranch_T3, % Floor(mBranch_T3x)
						}Else{
							GuiControl,3:, mBranch_T3, % DefaultValue["mBranch_T3"]
						}
					UpDown185_fIncrement := DefaultValue["UpDown185_fIncrement"], UpDown185_fRangeMin := DefaultValue["UpDown185_fRangeMin"], UpDown185_fRangeMax := DefaultValue["UpDown185_fRangeMax"] ;	Main Branch #4
					if mBranch_T4x between 100 and 10000
						{
							GuiControl,3:, mBranch_T4, % Floor(mBranch_T4x)
						}Else{
							GuiControl,3:, mBranch_T4, % DefaultValue["mBranch_T4"]
						}
					UpDown189_fIncrement := DefaultValue["UpDown189_fIncrement"], UpDown189_fRangeMin := DefaultValue["UpDown189_fRangeMin"], UpDown189_fRangeMax := DefaultValue["UpDown189_fRangeMax"] ;	Main Branch #5
					if mBranch_T5x between 100 and 10000
						{
							GuiControl,3:, mBranch_T5, % Floor(mBranch_T5x)
						}Else{
							GuiControl,3:, mBranch_T5, % DefaultValue["mBranch_T5"]
						}
					UpDown193_fIncrement := DefaultValue["UpDown193_fIncrement"], UpDown193_fRangeMin := DefaultValue["UpDown193_fRangeMin"], UpDown193_fRangeMax := DefaultValue["UpDown193_fRangeMax"] ;	Main Branch #6
					if mBranch_T6x between 1.0 and 30.0
						{
							GuiControl,3:, mBranch_T6, % Round(mBranch_T6x,1)
						}Else{
							GuiControl,3:, mBranch_T6, % DefaultValue["mBranch_T6"]
						}
					;	Restart Branch Delay
					UpDown198_fIncrement := DefaultValue["UpDown198_fIncrement"], UpDown198_fRangeMin := DefaultValue["UpDown198_fRangeMin"], UpDown198_fRangeMax := DefaultValue["UpDown198_fRangeMax"] ;	Restart Branch #1
					if cBranch_T1x between 100 and 10000
						{
							GuiControl,3:, cBranch_T1, % Floor(cBranch_T1x)
						}Else{
							GuiControl,3:, cBranch_T1, % DefaultValue["cBranch_T1"]
						}
					UpDown202_fIncrement := DefaultValue["UpDown202_fIncrement"], UpDown202_fRangeMin := DefaultValue["UpDown202_fRangeMin"], UpDown202_fRangeMax := DefaultValue["UpDown202_fRangeMax"] ;	Restart Branch #2
					if cBranch_T2x between 100 and 10000
						{
							GuiControl,3:, cBranch_T2, % Floor(cBranch_T2x)
						}Else{
							GuiControl,3:, cBranch_T2, % DefaultValue["cBranch_T2"]
						}
					UpDown206_fIncrement := DefaultValue["UpDown206_fIncrement"], UpDown206_fRangeMin := DefaultValue["UpDown206_fRangeMin"], UpDown206_fRangeMax := DefaultValue["UpDown206_fRangeMax"] ;	Restart Branch #3
					if cBranch_T3x between 100 and 10000
						{
							GuiControl,3:, cBranch_T3, % Floor(cBranch_T3x)
						}Else{
							GuiControl,3:, cBranch_T3, % DefaultValue["cBranch_T3"]
						}
					UpDown210_fIncrement := DefaultValue["UpDown210_fIncrement"], UpDown210_fRangeMin := DefaultValue["UpDown210_fRangeMin"], UpDown210_fRangeMax := DefaultValue["UpDown210_fRangeMax"] ;	Restart Branch #4
					if cBranch_T4x between 1.0 and 30.0
						{
							GuiControl,3:, cBranch_T4, % Round(cBranch_T4x,1)
						}Else{
							GuiControl,3:, cBranch_T4, % DefaultValue["cBranch_T4"]
						}
					;	Send Mode
					if ControlSendx in 0,1
						{
							GuiControl,3:, Control_Send, %ControlSendx%
						}Else{
							GuiControl,3:, Control_Send, % DefaultValue["Control_Send"]
						}
					if SendEventx in 0,1
						{
							GuiControl,3:, Send_Event, %SendEventx%
						}Else{
							GuiControl,3:, Send_Event, % DefaultValue["Send_Event"]
						}
					if SendInputx in 0,1
						{
							GuiControl,3:, Send_Input, %SendInputx%
						}Else{
							GuiControl,3:, Send_Input, % DefaultValue["Send_Input"]
						}
					Gui,3:Submit,Nohide
					If ((Control_Send + Send_Event + Send_Input)>1){
							GuiControl,3:, Control_Send, % DefaultValue["Control_Send"]
							GuiControl,3:, Send_Event, % DefaultValue["Send_Event"]
							GuiControl,3:, Send_Input, % DefaultValue["Send_Input"]
							Gui,3:Submit,Nohide
					}
					if KeyDelayCSx between 0 and 1000
						{
							GuiControl,3:, KeyDelayCS, % Floor(KeyDelayCSx)
						}Else{
							GuiControl,3:, KeyDelayCS, % DefaultValue["KeyDelayCS"]
						}
					if PressDurationCSx between 0 and 1000
						{
							GuiControl,3:, PressDurationCS, % Floor(PressDurationCSx)
						}Else{
							GuiControl,3:, PressDurationCS, % DefaultValue["PressDurationCS"]
						}
					if KeyDelayx between 0 and 1000
						{
							GuiControl,3:, KeyDelay, % Floor(KeyDelayx)
						}Else{
							GuiControl,3:, KeyDelay, % DefaultValue["KeyDelay"]
						}
					if PressDurationx between 0 and 1000
						{
							GuiControl,3:, PressDuration, % Floor(PressDurationx)
						}Else{
							GuiControl,3:, PressDuration, % DefaultValue["PressDuration"]
						}
					GoSub, DragDrop
					If (!xMC_Local_Navigator && !yMC_Local_Navigator) or (!xMC_Left_Image && !yMC_Left_Image) or (!xMC_Right_Image && !yMC_Right_Image)
						{
							SB_SetText("Please set new mouse coordinates in settings",2,1)
					}Else{
							SB_SetText("",2,1)
						}
					Return True
				}Else{
					Return False
				}
		}
	Return False
}

;----------------------------------------------------------------------------

; Function:				Save(File, Flag, Encoding)
; Description:			Creates associative arrays and returns a prettified JSON string.
;
; List - Old Code:		Row := ["+Check", Folder, Profile, Images, Timer], ListObjS["Row "A_Index] := Row

Save(File, Flag, Encoding){
	Gui +OwnDialogs
	SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	If InStr(File, "List"){
			; GUI 1 List
			Listvar := FileOpen(File, Flag, Encoding)
			if !IsObject(Listvar){
					Return False
				}Else{
					Critical, On
					SB_SetText("Saving List",2,1)
					ListObjS := Object()
					Loop % LV_GetCount()
							{
								LV_GetText(Folder, A_Index, 1)
								LV_GetText(Profile, A_Index, 2)
								LV_GetText(Format, A_Index, 3)
								LV_GetText(Images, A_Index, 4)
								LV_GetText(Size, A_Index, 5)
								LV_GetText(Timer, A_Index, 6)
								If (Folder = "") or (Profile = "") or (Images = "") or (Size = "") or (Timer = ""){
										Break
									}
								Checked := LV_GetNext(A_Index-1, "checked")
								If (Checked = A_Index){
										Row := {Status: "+Check", Folder: Folder, Profile: Profile, Format: Format, "Width": MC_Obj[(Folder), "Width"], "Height": MC_Obj[(Folder), "Height"], "PPI": MC_Obj[(Folder), "PPI"], "L.TopBorder": MC_Obj[(Folder), "L.TopBorder"], "L.BottomBorder": MC_Obj[(Folder), "L.BottomBorder"], "R.TopBorder": MC_Obj[(Folder), "R.TopBorder"], "R.BottomBorder": MC_Obj[(Folder), "R.BottomBorder"], Images: Images, Size: Size, Timer: Timer}, ListObjS[A_Index] := Row
									}Else{
										Row := {Status: "-Check", Folder: Folder, Profile: Profile, Format: Format, "Width": MC_Obj[(Folder), "Width"], "Height": MC_Obj[(Folder), "Height"], "PPI": MC_Obj[(Folder), "PPI"], "L.TopBorder": MC_Obj[(Folder), "L.TopBorder"], "L.BottomBorder": MC_Obj[(Folder), "L.BottomBorder"], "R.TopBorder": MC_Obj[(Folder), "R.TopBorder"], "R.BottomBorder": MC_Obj[(Folder), "R.BottomBorder"], Images: Images, Size: Size, Timer: Timer}, ListObjS[A_Index] := Row
									}
							}
					Listvar.Write(Jxon_dump(ListObjS,4))
					Listvar.Close()
					SB_SetText("",2,1)
					Critical, Off
					Return True
				}
		}
	If InStr(File, "Table"){
			; GUI 3 Table
			Tablevar := FileOpen(File, Flag, Encoding)
			if IsObject(Tablevar){
					Critical, On
					SB_SetText("Saving Table",2,1)
					Gui, 3:Default
					Gui, Listview, List2
					TableObjs := Object()
					Loop % LV_GetCount()
						{
							LV_GetText(TFormat, A_Index, 1)
							LV_GetText(Pages, A_Index, 2)
							LV_GetText(Resize_W, A_Index, 3)
							LV_GetText(Resize_H, A_Index, 4)
							if (TFormat = "") or (Pages = "") or (Resize_W = "") or (Resize_H = ""){
									Continue
								}
							Row := {"Pages": Pages, "Resize Width": Resize_W, "Resize Height": Resize_H}, TableObjs[TFormat] := Row
						}
					Tablevar.Write(Jxon_dump(TableObjs,4))
					Tablevar.Close()
					Gui, 1:Default
					Gui, Listview, List
					SB_SetText("",2,1)
					Critical, Off
					Return True
				}Else{
					Return False
				}
		}
	If InStr(File, "Settings") or InStr(File, "Single Pages") or InStr(File, "L & R on One Image") or InStr(File, "L & R on Two Images"){
			; GUI 3 Settings
			Settingsvar := FileOpen(File, Flag, Encoding)
			if IsObject(Settingsvar){
					Gui, 3:Default
					Critical, On
					If InStr(File, "Settings"){
							SB_SetText("Saving Settings",2,1)
						}Else{
							SB_SetText("Saving Preset",2,1)
						}
					;	Automatic Crop
					Auto_Crop := Object()
					Auto_Crop["Border Margins"] := AC_Border
					Auto_Crop["UpperLeftMargin"] := AC_UpperLeftMargin
					Auto_Crop["UpperRightMargin"] := AC_UpperRightMargin
					Auto_Crop["LowerLeftMargin"] := AC_LowerLeftMargin
					Auto_Crop["LowerRightMargin"] := AC_LowerRightMargin
					Auto_Crop["Shoulder Sweep"] := AC_Sweep
					Auto_Crop["UpperLeftSweep"] := AC_UpperLeftSweep
					Auto_Crop["UpperRightSweep"] := AC_UpperRightSweep
					Auto_Crop["LowerLeftSweep"] := AC_LowerLeftSweep
					Auto_Crop["LowerRightSweep"] := AC_LowerRightSweep
					Auto_Crop["Manual"] := AC_Manual
					Auto_Crop["Manual Setting"] := AC_Manual_sDDL
					Auto_Crop["Table"] := AC_Table
					Auto_Crop["Table Path"] := AC_TablePath
					Auto_Crop["Millimeter Width Adjustment"] := AC_WidthAdjust_Millimeter
					Auto_Crop["Millimeter Height Adjustment"] := AC_HeightAdjust_Millimeter
					Auto_Crop["Percent Width Adjustment"] := AC_WidthAdjust_Percent
					Auto_Crop["Percent Height Adjustment"] := AC_HeightAdjust_Percent
					Auto_Crop["Pixel Width Adjustment"] := AC_WidthAdjust_Pixel
					Auto_Crop["Pixel Height Adjustment"] := AC_HeightAdjust_Pixel
					Auto_Crop["PPI"] := AC_PPI
					;	Drive Space
					Drive_Space := Object()
					Drive_Space["Free"] := Disk_Space
					;	Folder & Profile
					User_Interface := Object()
					User_Interface["Crop Warning"] := Crop_Check
					User_Interface["Folder Path"] := Folderpath
					User_Interface["Folder Warning"] := ImageFolderCheck
					User_Interface["Image Extension"] := ImageExtension
					User_Interface["Image Folder"] := ImageFolder
					User_Interface["Profile Extention"] := ProfileExtension
					User_Interface["Profile Path"] := Profilepath
					;	Hotkeys
					Hot_Keys := Object()
					Hot_Keys["#1"] := savedHK1
					Hot_Keys["#1 Macro Delay"] := Macro_Delay_1
					Hot_Keys["#2"] := savedHK2
					Hot_Keys["#3"] := savedHK3
					Hot_Keys["#4"] := savedHK4
					Hot_Keys["#5"] := savedHK5
					Hot_Keys["Space"] := Space_Macro
					Hot_Keys["Space Delay"] := Space_Macro_Delay
					Hot_Keys["Space Process"] := Space_Process
					;	Imageview
					Imageview := Object()
					GuiControlGet, OutputVar,, MC_GridColour, Text
					Imageview["Grid Colour"] := OutputVar
					Imageview["Grid Thickness"] := MC_GridThickness
					GuiControlGet, OutputVar,, MC_Interpolation, Text
					Imageview["Interpolation"] := OutputVar
					GuiControlGet, OutputVar,, MC_PixelOffset, Text
					Imageview["Pixel Offset"] := OutputVar
					Imageview["Rotation Increment"] := MC_Angle
					GuiControlGet, OutputVar,, MC_Smoothing, Text
					Imageview["Smoothing"] := OutputVar
					Imageview["Selection Colour"] := MC_SelectionColour
					Imageview["Selection Thickness"] := MC_SelectionThickness
					;	List
					User_Interface["Autosize Columns"] := List_AutoHDR
					User_Interface["Drag & Drop"] := DragDrop_DDL
					User_Interface["List Style"] := CheckboxProperty
					User_Interface["Load On Startup"] := ListLoad
					User_Interface["Open With Program"] := Openwith
					User_Interface["Percentage Difference"] := PercentageDifference
					User_Interface["Refresh List"] := Listrefresh
					;	Mouse Coordinates
					Mouse_Coordinates := Object()
					Mouse_Coordinates["Local Navigator X"] := xMC_Local_Navigator
					Mouse_Coordinates["Local Navigator Y"] := yMC_Local_Navigator
					Mouse_Coordinates["Left Shoulder X"] := xMC_Left_Image
					Mouse_Coordinates["Left Shoulder Y"] := yMC_Left_Image
					Mouse_Coordinates["Right Shoulder X"] := xMC_Right_Image
					Mouse_Coordinates["Right Shoulder Y"] := yMC_Right_Image
					;	Page Improver
					Page_Improver := Object()
					Page_Improver["Effect"] := Effects
					Page_Improver["Operating Mode"] := Pi_Mode
					Page_Improver["Output Folder"] := Output_Folder
					Page_Improver["Existing Files"] := Output_Action
					Page_Improver["Process"] := mBranch_A1
					Page_Improver["Title"] := mBranch_A2
					Page_Improver["Path"] := cBranch_A1
					Page_Improver["Restart Page Improver"] := Conditional_Branch
					Page_Improver["Initial Restart"] := Initial_Restart
					Page_Improver["Apply Effect"] := Apply_Effect
					Page_Improver["Shoulder Search"] := ShoulderSearch
					Page_Improver["Automatic Crop"] := AutoCrop
					; Progress
					Timer := Object()
					Timer["Use Images"] := Images_Timer
					Timer["Time Limit"] := Deadline
					Timer["Timer Column"] := Timelimit
					Timer["Action Taken"] := DeadlineActiontaken
					Timer["Delay (sec) - Start"] := iCount_T1
					Timer["Delay (sec) - Interval"] := iCount_T2
					Timer["Delay (sec) - End"] := iCount_T3
					Timer["Use Timer"] := Duration_Timer
					Timer["Minimum Execution Time"] := Limit
					Timer["Page Improver Crop Speed"] := MB_Second
					;	Main Branch Delay
					Main_Branch_Delay := Object()
					Main_Branch_Delay["#1"] := mBranch_T1
					Main_Branch_Delay["#2"] := mBranch_T2
					Main_Branch_Delay["#3"] := mBranch_T3
					Main_Branch_Delay["#4"] := mBranch_T4
					Main_Branch_Delay["#5"] := mBranch_T5
					Main_Branch_Delay["#6"] := mBranch_T6
					;	Restart Branch
					Restart_Branch_Delay := Object()
					Restart_Branch_Delay["#1"] := cBranch_T1
					Restart_Branch_Delay["#2"] := cBranch_T2
					Restart_Branch_Delay["#3"] := cBranch_T3
					Restart_Branch_Delay["#4"] := cBranch_T4
					; Send Mode
					Send_Mode := Object()
					Send_Mode["ControlSend"] := Control_Send
					Send_Mode["Control Key Delay"] := KeyDelayCS
					Send_Mode["Control Press Duration"] := PressDurationCS
					Send_Mode["SendInput"] := Send_Input
					Send_Mode["SendEvent"] := Send_Event
					Send_Mode["Event Key Delay"] := KeyDelay
					Send_Mode["Event Press Duration"] := PressDuration
					; Settingsobj
					SettingsObjS := Object()
					SettingsObjS["Main Branch Delay"] := Main_Branch_Delay
					SettingsObjS["Restart Branch Delay"] := Restart_Branch_Delay
					SettingsObjS["Drive Space"] := Drive_Space
					SettingsObjS["Hotkeys"] := Hot_Keys
					SettingsObjS["Imageview"] := Imageview
					SettingsObjS["Mouse Coordinates"] := Mouse_Coordinates
					SettingsObjS["Page Improver"] := Page_Improver
					SettingsObjS["Automatic Crop"] := Auto_Crop
					SettingsObjS["Progress"] := Timer
					SettingsObjS["Send Mode"] := Send_Mode
					SettingsObjS["User Interface"] := User_Interface
					Settingsvar.Write(Jxon_dump(SettingsObjS,4))
					Settingsvar.Close()
					Gui, 1:Default
					SB_SetText("",2,1)
					Critical, Off
					Return True
			}Else{
					Return False
				}
		}
	Return False
}

;----------------------------------------------------------------------------

; Function:				DefaultSettings
; Description:			The hard-coded default settings.

DefaultSettings(Action){
	if (Action = "Create"){
			Global DefaultValue := Object()
			;	Automatic Crop
			DefaultValue["AC_Border"] := 1
			DefaultValue["AC_UpperLeftMargin"] := -10
			DefaultValue["UpDown245_fIncrement"] := 1 ; Margins. Upper Left.
			DefaultValue["UpDown245_fRangeMin"] := -9999
			DefaultValue["UpDown245_fRangeMax"] := 9999
			DefaultValue["AC_UpperRightMargin"] := -10
			DefaultValue["UpDown248_fIncrement"] := 1 ; Margins. Upper Right.
			DefaultValue["UpDown248_fRangeMin"] := -9999
			DefaultValue["UpDown248_fRangeMax"] := 9999
			DefaultValue["AC_LowerLeftMargin"] := -10
			DefaultValue["UpDown251_fIncrement"] := 1 ; Margins. Lower Left.
			DefaultValue["UpDown251_fRangeMin"] := -9999
			DefaultValue["UpDown251_fRangeMax"] := 9999
			DefaultValue["AC_LowerRightMargin"] := -10
			DefaultValue["UpDown254_fIncrement"] := 1 ; Margins. Lower Right.
			DefaultValue["UpDown254_fRangeMin"] := -9999
			DefaultValue["UpDown254_fRangeMax"] := 9999
			DefaultValue["AC_Sweep"] := 1
			DefaultValue["AC_UpperLeftSweep"] := 200
			DefaultValue["AC_UpperRightSweep"] := 200
			DefaultValue["AC_LowerLeftSweep"] := 200
			DefaultValue["AC_LowerRightSweep"] := 200
			DefaultValue["AC_Table"] := 1
			DefaultValue["AC_TablePath"] := A_WorkingDir . "\Table.json"
			DefaultValue["AC_PPI"] := 400
			DefaultValue["AC_Manual"] := 0
			DefaultValue["AC_Manual_sDDL"] := "Percent"
			DefaultValue["UpDown235_fIncrement_Millimeter"] := 1 ; Manual Wdith Adjustment.
			DefaultValue["UpDown235_fRangeMin_Millimeter"] := -1000
			DefaultValue["UpDown235_fRangeMax_Millimeter"] := 1000
			DefaultValue["UpDown238_fIncrement_Millimeter"] := 1 ; Manual Height Adjustment.
			DefaultValue["UpDown238_fRangeMin_Millimeter"] := -1000
			DefaultValue["UpDown238_fRangeMax_Millimeter"] := 1000
			DefaultValue["UpDown235_fIncrement_Percent"] := 0.1
			DefaultValue["UpDown235_fRangeMin_Percent"] := -100.0
			DefaultValue["UpDown235_fRangeMax_Percent"] := 100.0
			DefaultValue["UpDown238_fIncrement_Percent"] := 0.1
			DefaultValue["UpDown238_fRangeMin_Percent"] := -100.0
			DefaultValue["UpDown238_fRangeMax_Percent"] := 100.0
			DefaultValue["UpDown235_fIncrement_Pixel"] := 1
			DefaultValue["UpDown235_fRangeMin_Pixel"] := -1000
			DefaultValue["UpDown235_fRangeMax_Pixel"] := 1000
			DefaultValue["UpDown238_fIncrement_Pixel"] := 1
			DefaultValue["UpDown238_fRangeMin_Pixel"] := -1000
			DefaultValue["UpDown238_fRangeMax_Pixel"] := 1000
			DefaultValue["AC_WidthAdjust_Millimeter"] := 10
			DefaultValue["AC_HeightAdjust_Millimeter"] := 10
			DefaultValue["AC_WidthAdjust_Percent"] := 6.5
			DefaultValue["AC_HeightAdjust_Percent"] := 3.5
			DefaultValue["AC_WidthAdjust_Pixel"] := 140
			DefaultValue["AC_HeightAdjust_Pixel"] := 110
			;	Disk Space
			DefaultValue["Disk_Space"] := "50000"
			;	Folder & Profile
			DefaultValue["Crop_Check"] := 1
			DefaultValue["Folderpath"] := "D:\Dl_Files\"
			DefaultValue["ImageExtension"] := "raw,tif,tiff,png,jpg,jpeg"
			DefaultValue["ImageFolderCheck"] := 1
			DefaultValue["Profilepath"] := "D:\Dl_Files\PI_Profiler"
			DefaultValue["ProfileExtension"] := "fyr"
			DefaultValue["ImageFolder"] := "pages_raw"
			;	Hotkeys
			DefaultValue["Space_Macro"] := 0
			DefaultValue["Space_Macro_Delay"] := 500
			DefaultValue["Space_Process"] := "xnview.exe"
			DefaultValue["Macro_Delay_1"] := 1
			DefaultValue["HK1"] := "~" ; ~ Prevents blocking of keyboard keys.
			DefaultValue["HK1 GUI"] := ""
			DefaultValue["HK2"] := "~"
			DefaultValue["HK2 GUI"] := ""
			DefaultValue["HK3"] := "~"
			DefaultValue["HK3 GUI"] := ""
			DefaultValue["HK4"] := "~"
			DefaultValue["HK4 GUI"] := ""
			DefaultValue["HK5"] := "~"
			DefaultValue["HK5 GUI"] := ""
			DefaultValue["CB1"] := 0 ; Hotkey prefix # = 1.
			DefaultValue["CB2"] := 0
			DefaultValue["CB3"] := 0
			DefaultValue["CB4"] := 0
			DefaultValue["CB5"] := 0
			;	Imageview
			DefaultValue["Grid Colour"] := "Black"
			DefaultValue["Grid Thickness"] := 1.5
			DefaultValue["UpDown63_fIncrement"] := 0.1 ; Grid Thickness
			DefaultValue["UpDown63_fRangeMin"] := 0.1
			DefaultValue["UpDown63_fRangeMax"] := 15.0
			DefaultValue["Interpolation"] := "HighQualityBicubic"
			DefaultValue["Pixel Offset"] := "Half"
			DefaultValue["Smoothing"] := "HighQuality"
			DefaultValue["Rotation Increment"] := 0.1
			DefaultValue["UpDown71_fIncrement"] := 0.1 ; Rotation Increment
			DefaultValue["UpDown71_fRangeMin"] := 0.1
			DefaultValue["UpDown71_fRangeMax"] := 180
			DefaultValue["Selection Colour"] := "Fuchsia"
			DefaultValue["Selection Thickness"] := 1.5
			DefaultValue["UpDown79_fIncrement"] := 0.1 ; Selection Thickness
			DefaultValue["UpDown79_fRangeMin"] := 0.1
			DefaultValue["UpDown79_fRangeMax"] := 15.0
			;	List
			DefaultValue["DragDrop_DDL"] := "One profile"
			DefaultValue["CheckboxProperty"] := "Percentage difference"
			DefaultValue["List_AutoHDR"] := 1
			DefaultValue["ListLoad"] := 1
			DefaultValue["ListRefresh"] := 1
			DefaultValue["Openwith"] := ""
			DefaultValue["PercentageDifference"] := 5
			DefaultValue["UpDown94_fIncrement"] := 1
			DefaultValue["UpDown94_fRangeMin"] := 0
			DefaultValue["UpDown94_fRangeMax"] := 1000
			;	Mouse Coordinates
			DefaultValue["xMC_Local_Navigator"] := 0
			DefaultValue["yMC_Local_Navigator"] := 0
			DefaultValue["xMC_Left_Image"] := 0
			DefaultValue["yMC_Left_Image"] := 0
			DefaultValue["xMC_Right_Image"] := 0
			DefaultValue["yMC_Right_Image"] := 0
			;	Page Improver
			DefaultValue["Effects"] := "Sharpening 2"
			DefaultValue["Pi_Mode"] := "L & R on One Image"
			DefaultValue["Output_Folder"] := "digibok_"
			DefaultValue["Output_Action"] := "Delete"
			DefaultValue["mBranch_A1"] := "PageImprover.exe"
			DefaultValue["mBranch_A2"] := "Fyr's image manipulation package"
			DefaultValue["cBranch_A1"] := "C:\Program Files\4Digitalbooks\Page Improver 64\PageImprover.exe"
			DefaultValue["Conditional_Branch"] := 1
			DefaultValue["Initial_Restart"] := 1
			DefaultValue["Apply_Effect"] := 1
			DefaultValue["AutoCrop"] := 0
			DefaultValue["ShoulderSearch"] := 1
			;	Progress
			DefaultValue["Images_Timer"] := 1
			DefaultValue["Deadline"] := 1
			DefaultValue["Timelimit"] := "2x"
			DefaultValue["DeadlineActiontaken"] := "Continue"
			DefaultValue["iCount_T1"] := 5 ; Delay (sec) - Start.
			DefaultValue["UpDown153_fIncrement"] := 1
			DefaultValue["UpDown153_fRangeMin"] := 1
			DefaultValue["UpDown153_fRangeMax"] := 900
			DefaultValue["iCount_T2"] := 2.0 ; Delay (sec) - Interval.
			DefaultValue["UpDown156_fIncrement"] := 0.1
			DefaultValue["UpDown156_fRangeMin"] := 1.0
			DefaultValue["UpDown156_fRangeMax"] := 60.0
			DefaultValue["iCount_T3"] := 3 ; Delay (sec) - End.
			DefaultValue["UpDown159_fIncrement"] := 1
			DefaultValue["UpDown159_fRangeMin"] := 2
			DefaultValue["UpDown159_fRangeMax"] := 10
			DefaultValue["Duration_Timer"] := 0
			DefaultValue["Limit"] := 2.5 ; Minimum Execution Time.
			DefaultValue["UpDown164_fIncrement"] := 0.1
			DefaultValue["UpDown164_fRangeMin"] := 1.0
			DefaultValue["UpDown164_fRangeMax"] := 10.0
			DefaultValue["MB_Second"] := 27 ; Page Improver Crop Speed.
			DefaultValue["UpDown168_fIncrement"] := 1
			DefaultValue["UpDown168_fRangeMin"] := 1
			DefaultValue["UpDown168_fRangeMax"] := 10000
			;	Main Branch Delay
			DefaultValue["mBranch_T1"] := 4000 ; Main Branch #1
			DefaultValue["UpDown173_fIncrement"] := 100
			DefaultValue["UpDown173_fRangeMin"] := 100
			DefaultValue["UpDown173_fRangeMax"] := 20000
			DefaultValue["mBranch_T2"] := 2000 ; Main Branch #2
			DefaultValue["UpDown177_fIncrement"] := 100
			DefaultValue["UpDown177_fRangeMin"] := 100
			DefaultValue["UpDown177_fRangeMax"] := 20000
			DefaultValue["mBranch_T3"] := 1000 ; Main Branch #3
			DefaultValue["UpDown181_fIncrement"] := 100
			DefaultValue["UpDown181_fRangeMin"] := 100
			DefaultValue["UpDown181_fRangeMax"] := 20000
			DefaultValue["mBranch_T4"] := 500 ; Main Branch #4
			DefaultValue["UpDown185_fIncrement"] := 100
			DefaultValue["UpDown185_fRangeMin"] := 100
			DefaultValue["UpDown185_fRangeMax"] := 20000
			DefaultValue["mBranch_T5"] := 3000 ; Main Branch #5
			DefaultValue["UpDown189_fIncrement"] := 100
			DefaultValue["UpDown189_fRangeMin"] := 100
			DefaultValue["UpDown189_fRangeMax"] := 20000
			DefaultValue["mBranch_T6"] := 5.0 ; Main Branch #6
			DefaultValue["UpDown193_fIncrement"] := 0.1
			DefaultValue["UpDown193_fRangeMin"] := 1.0
			DefaultValue["UpDown193_fRangeMax"] := 30.0
			;	Restart Branch
			DefaultValue["cBranch_T1"] := 5000 ; Restart Branch #1
			DefaultValue["UpDown198_fIncrement"] := 100
			DefaultValue["UpDown198_fRangeMin"] := 100
			DefaultValue["UpDown198_fRangeMax"] := 20000
			DefaultValue["cBranch_T2"] := 1000 ; Restart Branch #2
			DefaultValue["UpDown202_fIncrement"] := 100
			DefaultValue["UpDown202_fRangeMin"] := 100
			DefaultValue["UpDown202_fRangeMax"] := 20000
			DefaultValue["cBranch_T3"] := 500 ; Restart Branch #3
			DefaultValue["UpDown206_fIncrement"] := 100
			DefaultValue["UpDown206_fRangeMin"] := 100
			DefaultValue["UpDown206_fRangeMax"] := 20000
			DefaultValue["cBranch_T4"] := 5.0 ; Restart Branch #4
			DefaultValue["UpDown210_fIncrement"] := 0.1
			DefaultValue["UpDown210_fRangeMin"] := 1.0
			DefaultValue["UpDown210_fRangeMax"] := 30.0
			;	Send Mode
			DefaultValue["Control_Send"] := 0
			DefaultValue["KeyDelayCS"] := 0
			DefaultValue["PressDurationCS"] := 0
			DefaultValue["Send_Input"] := 1
			DefaultValue["Send_Event"] := 0
			DefaultValue["KeyDelay"] := 20
			DefaultValue["PressDuration"] := 20
			Return DefaultValue
		}
	if (Action = "Restore"){
			if !DefaultValue
				DefaultValue := DefaultSettings("Create")
			;	Automatic Crop
			GuiControl,3:, AC_Border, % DefaultValue["AC_Border"]
			GuiControl,3:, AC_Border, % (DefaultValue["AC_Border"] = 1) ? "On" : "Off"
			GuiControl,3:, AC_UpperLeftMargin, % DefaultValue["AC_UpperLeftMargin"]
			UpDown245_fIncrement := DefaultValue["UpDown245_fIncrement"], UpDown245_fRangeMin := DefaultValue["UpDown245_fRangeMin"], UpDown245_fRangeMax := DefaultValue["UpDown245_fRangeMax"] ;	Margins. Upper Left.
			GuiControl,3:, AC_UpperRightMargin, % DefaultValue["AC_UpperRightMargin"]
			UpDown248_fIncrement := DefaultValue["UpDown248_fIncrement"], UpDown248_fRangeMin := DefaultValue["UpDown248_fRangeMin"], UpDown248_fRangeMax := DefaultValue["UpDown248_fRangeMax"] ;	Margins. Upper Right.
			GuiControl,3:, AC_LowerLeftMargin, % DefaultValue["AC_LowerLeftMargin"]
			UpDown251_fIncrement := DefaultValue["UpDown251_fIncrement"], UpDown251_fRangeMin := DefaultValue["UpDown251_fRangeMin"], UpDown251_fRangeMax := DefaultValue["UpDown251_fRangeMax"] ;	Margins. Lower Left.
			GuiControl,3:, AC_LowerRightMargin, % DefaultValue["AC_LowerRightMargin"]
			UpDown254_fIncrement := DefaultValue["UpDown254_fIncrement"], UpDown254_fRangeMin := DefaultValue["UpDown254_fRangeMin"], UpDown254_fRangeMax := DefaultValue["UpDown254_fRangeMax"] ;	Margins. Lower Right.
			GuiControl,3:, AC_Sweep, % DefaultValue["AC_Sweep"]
			GuiControl,3:, AC_Sweep, % (DefaultValue["AC_Sweep"] = 1) ? "On" : "Off"
			GuiControl,3:, AC_UpperLeftSweep, % DefaultValue["AC_UpperLeftSweep"]
			GuiControl,3:, AC_UpperRightSweep, % DefaultValue["AC_UpperRightSweep"]
			GuiControl,3:, AC_LowerLeftSweep, % DefaultValue["AC_LowerLeftSweep"]
			GuiControl,3:, AC_LowerRightSweep, % DefaultValue["AC_LowerRightSweep"]
			GuiControl,3:, AC_Table, % DefaultValue["AC_Table"]
			GuiControl,3:, AC_TablePath, % DefaultValue["AC_TablePath"]
			GuiControl,3:ChooseString, AC_PPI, % DefaultValue["AC_PPI"]
			GuiControl,3:, AC_Manual, % DefaultValue["AC_Manual"]
			GuiControl,3:ChooseString, AC_Manual_sDDL, % DefaultValue["AC_Manual_sDDL"]
			GuiControl,3:Disable, AC_HeightAdjust
			GuiControl,3:Disable, AC_WidthAdjust
			GuiControl,3:, AC_WidthAdjust, % DefaultValue["AC_WidthAdjust_Percent"]
			UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Percent"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Percent"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Percent"] ;	Wdith Adjustment.
			GuiControl,3:, AC_HeightAdjust, % DefaultValue["AC_HeightAdjust_Percent"]
			UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Percent"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Percent"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Percent"] ;	Height Adjustment.
			AC_WidthAdjust_Millimeter := % DefaultValue["AC_WidthAdjust_Millimeter"]
			AC_HeightAdjust_Millimeter := % DefaultValue["AC_HeightAdjust_Millimeter"]
			AC_WidthAdjust_Percent := % DefaultValue["AC_WidthAdjust_Percent"]
			AC_HeightAdjust_Percent := % DefaultValue["AC_HeightAdjust_Percent"]
			AC_WidthAdjust_Pixel := % DefaultValue["AC_WidthAdjust_Pixel"]
			AC_HeightAdjust_Pixel := % DefaultValue["AC_HeightAdjust_Pixel"]
			;	Disk Space
			GuiControl,3:, Disk_Space, % DefaultValue["Disk_Space"]
			;	Folder & Profile
			GuiControl,3:, Crop_Check, % DefaultValue["Crop_Check"]
			GuiControl,3:, Crop_Check, % (DefaultValue["Crop_Check"] = 1) ? "On" : "Off"
			GuiControl,3:ChooseString, Folderpath, % DefaultValue["Folderpath"]
			GuiControl,3:, ImageFolder, % DefaultValue["ImageFolder"]
			GuiControl,3:, ImageExtension, % DefaultValue["ImageExtension"]
			GuiControl,3:, ImageFolderCheck, % DefaultValue["ImageFolderCheck"]
			GuiControl,3:, ImageFolderCheck, % (DefaultValue["ImageFolderCheck"] = 1) ? "On" : "Off"
			GuiControl,3:ChooseString, Profilepath, % DefaultValue["Profilepath"]
			GuiControl,3:, ProfileExtension, % DefaultValue["ProfileExtension"]
			;	Hotkeys
			GuiControl,3:, Space_Macro, % DefaultValue["Space_Macro"]
			GuiControl,3:, Space_Macro, % (DefaultValue["Space_Macro"] = 1) ? "On" : "Off"
			GuiControl,3:, Space_Macro_Delay, % DefaultValue["Space_Macro_Delay"]
			GuiControl,3:, Space_Process, % DefaultValue["Space_Process"]
			GuiControl,3:, Macro_Delay_1, % DefaultValue["Macro_Delay_1"]
			Hotkey, % DefaultValue["HK1"], Hotkey1, T1
			savedHK1 := % DefaultValue["HK1"]
			GuiControl,3:, HK1, % DefaultValue["HK1 GUI"]
			Hotkey, % DefaultValue["HK2"], Hotkey2, T1
			savedHK2 := % DefaultValue["HK2"]
			GuiControl,3:, HK2, % DefaultValue["HK2 GUI"]
			Hotkey, % DefaultValue["HK3"], Hotkey3, T1
			savedHK3 := % DefaultValue["HK3"]
			GuiControl,3:, HK3, % DefaultValue["HK3 GUI"]
			Hotkey, % DefaultValue["HK4"], Hotkey4, T2 ; Need 2 threads for pause.
			savedHK4 := % DefaultValue["HK4"]
			GuiControl,3:, HK4, % DefaultValue["HK4 GUI"]
			Hotkey, % DefaultValue["HK5"], Hotkey5, T1
			savedHK5 := % DefaultValue["HK5"]
			GuiControl,3:, HK5, % DefaultValue["HK5 GUI"]
			GuiControl,3:, CB1, % DefaultValue["CB1"]
			GuiControl,3:, CB2, % DefaultValue["CB2"]
			GuiControl,3:, CB3, % DefaultValue["CB3"]
			GuiControl,3:, CB4, % DefaultValue["CB4"]
			GuiControl,3:, CB5, % DefaultValue["CB5"]
			;	Imageview
			GuiControl,3:ChooseString, MC_GridColour, % DefaultValue["Grid Colour"]
			GuiControl,3:, MC_GridThickness, % DefaultValue["Grid Thickness"]
			UpDown63_fIncrement := DefaultValue["UpDown63_fIncrement"], UpDown63_fRangeMin := DefaultValue["UpDown63_fRangeMin"], UpDown63_fRangeMax := DefaultValue["UpDown63_fRangeMax"] ;	Grid Thickness.
			GuiControl,3:ChooseString, MC_Interpolation, % DefaultValue["Interpolation"]
			GuiControl,3:ChooseString, MC_PixelOffset, % DefaultValue["Pixel Offset"]
			GuiControl,3:ChooseString, MC_Smoothing, % DefaultValue["Smoothing"]
			GuiControl,3:, MC_Angle, % DefaultValue["Rotation Increment"]
			UpDown71_fIncrement := DefaultValue["UpDown71_fIncrement"], UpDown71_fRangeMin := DefaultValue["UpDown71_fRangeMin"], UpDown71_fRangeMax := DefaultValue["UpDown71_fRangeMax"] ;	Rotation Increment.
			GuiControl,3:ChooseString, MC_SelectionColour, % DefaultValue["Selection Colour"]
			GuiControl,3:, MC_SelectionThickness, % DefaultValue["Selection Thickness"]
			UpDown79_fIncrement := DefaultValue["UpDown79_fIncrement"], UpDown79_fRangeMin := DefaultValue["UpDown79_fRangeMin"], UpDown79_fRangeMax := DefaultValue["UpDown79_fRangeMax"] ;	Selection Thickness.
			;	List
			GuiControl,3:ChooseString, DragDrop_DDL, % DefaultValue["DragDrop_DDL"]
			GuiControl,3:ChooseString, CheckboxProperty, % DefaultValue["CheckboxProperty"]
			GuiControl,3:, List_AutoHDR, % DefaultValue["List_AutoHDR"]
			GuiControl,3:, List_AutoHDR, % (DefaultValue["List_AutoHDR"] = 1) ? "On" : "Off"
			GuiControl,3:, ListLoad, % DefaultValue["ListLoad"]
			GuiControl,3:, ListLoad, % (DefaultValue["ListLoad"] = 1) ? "On" : "Off"
			GuiControl,3:, ListRefresh, % DefaultValue["ListRefresh"]
			GuiControl,3:, ListRefresh, % (DefaultValue["ListRefresh"] = 1) ? "On" : "Off"
			GuiControl,3:, Openwith, % DefaultValue["Openwith"]
			GuiControl,3:, PercentageDifference, % DefaultValue["PercentageDifference"]
			UpDown94_fIncrement := DefaultValue["UpDown94_fIncrement"], UpDown94_fRangeMin := DefaultValue["UpDown94_fRangeMin"], UpDown94_fRangeMax := DefaultValue["UpDown94_fRangeMax"] ;	Percentage Difference
			;	Mouse Coordinates
			GuiControl,3:, xMC_Local_Navigator, % DefaultValue["xMC_Local_Navigator"]
			GuiControl,3:, yMC_Local_Navigator, % DefaultValue["yMC_Local_Navigator"]
			GuiControl,3:, xMC_Left_Image, % DefaultValue["xMC_Left_Image"]
			GuiControl,3:, yMC_Left_Image, % DefaultValue["yMC_Left_Image"]
			GuiControl,3:, xMC_Right_Image, % DefaultValue["xMC_Right_Image"]
			GuiControl,3:, yMC_Right_Image, % DefaultValue["yMC_Right_Image"]
			SB_SetText("Please set new mouse coordinates in settings",2,1)
			;	Page Improver
			GuiControl,3:ChooseString, Effects, % DefaultValue["Effects"]
			GuiControl,3:ChooseString, Pi_Mode, % DefaultValue["Pi_Mode"]
			GuiControl,3:ChooseString, Output_Folder, % DefaultValue["Output_Folder"]
			GuiControl,3:ChooseString, Output_Action, % DefaultValue["Output_Action"]
			GuiControl,3:, mBranch_A1, % DefaultValue["mBranch_A1"]
			GuiControl,3:, mBranch_A2, % DefaultValue["mBranch_A2"]
			GuiControl,3:, cBranch_A1, % DefaultValue["cBranch_A1"]
			GuiControl,3:, Conditional_Branch, % DefaultValue["Conditional_Branch"]
			GuiControl,3:, Conditional_Branch, % (DefaultValue["Conditional_Branch"] = 1) ? "On" : "Off"
			GuiControl,3:, Initial_Restart, % DefaultValue["Initial_Restart"]
			GuiControl,3:, Initial_Restart, % (DefaultValue["Initial_Restart"] = 1) ? "On" : "Off"
			GuiControl,3:, Apply_Effect, % DefaultValue["Apply_Effect"]
			GuiControl,3:, Apply_Effect, % (DefaultValue["Apply_Effect"] = 1) ? "On" : "Off"
			GuiControl,3:, AutoCrop, % DefaultValue["AutoCrop"]
			GuiControl,3:, AutoCrop, % (DefaultValue["AutoCrop"] = 1) ? "On" : "Off"
			GuiControl,3:, ShoulderSearch, % DefaultValue["ShoulderSearch"]
			GuiControl,3:, ShoulderSearch, % (DefaultValue["ShoulderSearch"] = 1) ? "On" : "Off"
			;	Progress
			GuiControl,3:, Images_Timer, % DefaultValue["Images_Timer"]
			GuiControl,3:Enable, Deadline
			GuiControl,3:Enable, Timelimit
			GuiControl,3:Enable, DeadlineActiontaken
			GuiControl,3:Enable, iCount_T1
			GuiControl,3:Enable, iCount_T2
			GuiControl,3:Enable, iCount_T3
			GuiControl,3:, Deadline, % DefaultValue["Deadline"]
			GuiControl,3:, Deadline, % (DefaultValue["Deadline"] = 1) ? "On" : "Off"
			GuiControl,3:ChooseString, Timelimit, % DefaultValue["Timelimit"]
			GuiControl,3:ChooseString, DeadlineActiontaken, % DefaultValue["DeadlineActiontaken"]
			GuiControl,3:, iCount_T1, % DefaultValue["iCount_T1"]
			UpDown153_fIncrement := DefaultValue["UpDown153_fIncrement"], UpDown153_fRangeMin := DefaultValue["UpDown153_fRangeMin"], UpDown153_fRangeMax := DefaultValue["UpDown153_fRangeMax"] ;	Delay (sec) - Start.
			GuiControl,3:, iCount_T2, % DefaultValue["iCount_T2"]
			UpDown156_fIncrement := DefaultValue["UpDown156_fIncrement"], UpDown156_fRangeMin := DefaultValue["UpDown156_fRangeMin"], UpDown156_fRangeMax := DefaultValue["UpDown156_fRangeMax"] ;	Delay (sec) - Interval.
			GuiControl,3:, iCount_T3, % DefaultValue["iCount_T3"]
			UpDown159_fIncrement := DefaultValue["UpDown159_fIncrement"], UpDown159_fRangeMin := DefaultValue["UpDown159_fRangeMin"], UpDown159_fRangeMax := DefaultValue["UpDown159_fRangeMax"] ;	Delay (sec) - End.
			GuiControl,3:, Duration_Timer, % DefaultValue["Duration_Timer"]
			GuiControl,3:, Limit, % DefaultValue["Limit"]
			UpDown164_fIncrement := DefaultValue["UpDown164_fIncrement"], UpDown164_fRangeMin := DefaultValue["UpDown164_fRangeMin"], UpDown164_fRangeMax := DefaultValue["UpDown164_fRangeMax"] ;	Minimum Execution Time.
			GuiControl,3:, MB_Second, % DefaultValue["MB_Second"]
			UpDown168_fIncrement := DefaultValue["UpDown168_fIncrement"], UpDown168_fRangeMin := DefaultValue["UpDown168_fRangeMin"], UpDown168_fRangeMax := DefaultValue["UpDown168_fRangeMax"] ;	Page Improver Crop Speed.
			GuiControl,3:Disable, Limit
			GuiControl,3:Disable, MB_Second
			;	Main Branch Delay
			GuiControl,3:, mBranch_T1, % DefaultValue["mBranch_T1"]
			UpDown173_fIncrement := DefaultValue["UpDown173_fIncrement"], UpDown173_fRangeMin := DefaultValue["UpDown173_fRangeMin"], UpDown173_fRangeMax := DefaultValue["UpDown173_fRangeMax"] ;	Main Branch #1
			GuiControl,3:, mBranch_T2, % DefaultValue["mBranch_T2"]
			UpDown177_fIncrement := DefaultValue["UpDown177_fIncrement"], UpDown177_fRangeMin := DefaultValue["UpDown177_fRangeMin"], UpDown177_fRangeMax := DefaultValue["UpDown177_fRangeMax"] ;	Main Branch #2
			GuiControl,3:, mBranch_T3, % DefaultValue["mBranch_T3"]
			UpDown181_fIncrement := DefaultValue["UpDown181_fIncrement"], UpDown181_fRangeMin := DefaultValue["UpDown181_fRangeMin"], UpDown181_fRangeMax := DefaultValue["UpDown181_fRangeMax"] ;	Main Branch #3
			GuiControl,3:, mBranch_T4, % DefaultValue["mBranch_T4"]
			UpDown185_fIncrement := DefaultValue["UpDown185_fIncrement"], UpDown185_fRangeMin := DefaultValue["UpDown185_fRangeMin"], UpDown185_fRangeMax := DefaultValue["UpDown185_fRangeMax"] ;	Main Branch #4
			GuiControl,3:, mBranch_T5, % DefaultValue["mBranch_T5"]
			UpDown189_fIncrement := DefaultValue["UpDown189_fIncrement"], UpDown189_fRangeMin := DefaultValue["UpDown189_fRangeMin"], UpDown189_fRangeMax := DefaultValue["UpDown189_fRangeMax"] ;	Main Branch #5
			GuiControl,3:, mBranch_T6, % DefaultValue["mBranch_T6"]
			UpDown193_fIncrement := DefaultValue["UpDown193_fIncrement"], UpDown193_fRangeMin := DefaultValue["UpDown193_fRangeMin"], UpDown193_fRangeMax := DefaultValue["UpDown193_fRangeMax"] ;	Main Branch #6
			;	Restart Branch
			GuiControl,3:, cBranch_T1, % DefaultValue["cBranch_T1"]
			UpDown198_fIncrement := DefaultValue["UpDown198_fIncrement"], UpDown198_fRangeMin := DefaultValue["UpDown198_fRangeMin"], UpDown198_fRangeMax := DefaultValue["UpDown198_fRangeMax"] ;	Restart Branch #1
			GuiControl,3:, cBranch_T2, % DefaultValue["cBranch_T2"]
			UpDown202_fIncrement := DefaultValue["UpDown202_fIncrement"], UpDown202_fRangeMin := DefaultValue["UpDown202_fRangeMin"], UpDown202_fRangeMax := DefaultValue["UpDown202_fRangeMax"] ;	Restart Branch #2
			GuiControl,3:, cBranch_T3, % DefaultValue["cBranch_T3"]
			UpDown206_fIncrement := DefaultValue["UpDown206_fIncrement"], UpDown206_fRangeMin := DefaultValue["UpDown206_fRangeMin"], UpDown206_fRangeMax := DefaultValue["UpDown206_fRangeMax"] ;	Restart Branch #3
			GuiControl,3:, cBranch_T4, % DefaultValue["cBranch_T4"]
			UpDown210_fIncrement := DefaultValue["UpDown210_fIncrement"], UpDown210_fRangeMin := DefaultValue["UpDown210_fRangeMin"], UpDown210_fRangeMax := DefaultValue["UpDown210_fRangeMax"] ;	Restart Branch #4
			;	Send Mode
			GuiControl,3:, Control_Send, % DefaultValue["Control_Send"]
			GuiControl,3:, KeyDelayCS, % DefaultValue["KeyDelayCS"]
			GuiControl,3:, PressDurationCS, % DefaultValue["PressDurationCS"]
			GuiControl,3:, Send_Input, % DefaultValue["Send_Input"]
			GuiControl,3:, Send_Event, % DefaultValue["Send_Event"]
			GuiControl,3:, KeyDelay, % DefaultValue["KeyDelay"]
			GuiControl,3:, PressDuration, % DefaultValue["PressDuration"]
			Return True
		}
	If (Action = "Table"){
			Gui, 3:Default
			Gui, Listview, List2
			LV_Add(,"100x150mm", 346, 4.0, 3.3)
			LV_Add(,"105x160mm", 482, 7.5, 8.1)
			LV_Add(,"105x185mm", 266, 6.1, 4.5)
			LV_Add(,"110x175mm", 128, 7.9, 3.6)
			LV_Add(,"110x180mm", 246, 7.9, 5.4)
			LV_Add(,"110x185mm", 258, 8.5, 3.5)
			LV_Add(,"115x160mm", 100, 7.9, 3.6)
			LV_Add(,"115x175mm", 294, 6.1, 5.5)
			LV_Add(,"115x185mm", 326, 6.4, 2.5)
			LV_Add(,"115x190mm", 258, 7.9, 4.0)
			LV_Add(,"115x210mm", 50, 3.9, 6.3)
			LV_Add(,"115x225mm", 118, 5.7, 5.0)
			LV_Add(,"120x175mm", 294, 6.1, 5.5)
			LV_Add(,"120x190mm", 134, 7.3, 6.1)
			LV_Add(,"120x195mm", 186, 6.2, 3.4)
			LV_Add(,"120x200mm", 226, 5.5, 4.0)
			LV_Add(,"120x210mm", 182, 7.3, 5.2)
			LV_Add(,"120x215mm", 262, 3.5, 7.1)
			LV_Add(,"120x215mm", 262, 3.5, 7.1)
			LV_Add(,"125x185mm", 126, 7.7, 6.6)
			LV_Add(,"125x190mm", 516, 4.1, 5.2) ; Donald pocket
			LV_Add(,"125x195mm", 332, 6.9, 2.9)
			LV_Add(,"125x205mm", 410, 7.5, 3.6)
			LV_Add(,"125x210mm", 110, 6.8, 5.2)
			LV_Add(,"125x215mm", 234, 5.5, 5.6)
			LV_Add(,"130x190mm", 314, 5.6, 3.9)
			LV_Add(,"130x205mm", 194, 5.6, 3.2)
			LV_Add(,"130x210mm", 434, 5.0, 3.8) ; From 8.2w 3.1h
			LV_Add(,"130x215mm", 186, 7.7, 6.0)
			LV_Add(,"130x220mm", 100, 5.9, 5.6)
			LV_Add(,"135x170mm", 306, 5.8, 3.8)
			LV_Add(,"135x190mm", 182, 4.3, 5.8)
			LV_Add(,"135x205mm", 258, 3.7, 2.8)
			LV_Add(,"135x210mm", 246, 8.0, 5.5)
			LV_Add(,"135x215mm", 122, 5.8, 4.5)
			LV_Add(,"140x175mm", 214, 3.7, 5.9)
			LV_Add(,"140x205mm", 306, 6.3, 3.4)
			LV_Add(,"140x210mm", 86, 5.0, 4.8)
			LV_Add(,"140x215mm", 170, 6.4, 5.4)
			LV_Add(,"145x205mm", 578, 7.9, 3.2)
			LV_Add(,"145x210mm", 146, 4.5, 2.5)
			LV_Add(,"145x215mm", 414, 4.5, 2.5) ; 4.8 3.9
			LV_Add(,"145x220mm", 198, 7.0, 5.4) ; From w4.5-h4.6
			LV_Add(,"145x225mm", 62, 4.7, 2.9)
			LV_Add(,"145x235mm", 214, 6.0, 6.3)
			LV_Add(,"150x210mm", 22, 4.5, 2.8)
			LV_Add(,"150x215mm", 182, 6.0, 3.3) ; From w5.3-h2.9
			LV_Add(,"150x220mm", 90, 6.5, 6.4)
			LV_Add(,"150x225mm", 296, 6.7, 3.1)
			LV_Add(,"150x230mm", 126, 6.7, 3.4)
			LV_Add(,"150x235mm", 438, 5.9, 5.2)
			LV_Add(,"155x220mm", 246, 5.0, 3.4)
			LV_Add(,"155x230mm", 50, 4.5, 3.0)
			LV_Add(,"155x235mm", 326, 6.7, 4.2)
			LV_Add(,"160x225mm", 102, 5.8, 4.7)
			LV_Add(,"160x240mm", 66, 4.9, 3.6)
			LV_Add(,"165x200mm", 38, 3.4, 3.0)
			LV_Add(,"165x220mm", 126, 3.5, 5.2)
			LV_Add(,"165x235mm", 142, 4.7, 3.0)
			LV_Add(,"165x240mm", 256, 4.3, 3.3)
			LV_Add(,"165x245mm", 214, 3.5, 3.7)
			LV_Add(,"165x250mm", 618, 4.5, 4.6)
			LV_Add(,"170x200mm", 66, 3.7, 2.5)
			LV_Add(,"170x205mm", 30, 5.1, 6.0)
			LV_Add(,"170x240mm", 384, 5.4, 4.3)
			LV_Add(,"170x245mm", 646, 5.2, 4.1) ; From w5.3-h4.4 | w6.1-h3.3 | 4.3w 3.0h
			LV_Add(,"170x250mm", 646, 5.2, 4.1) ; From w4.1-h5.4 | w5.6-h2.4
			LV_Add(,"170x255mm", 70, 4.8, 3.0)
			LV_Add(,"175x245mm", 122, 6.1, 3.3)
			LV_Add(,"175x250mm", 310, 6.0, 4.9)
			LV_Add(,"175x255mm", 68, 5.7, 2.5)
			LV_Add(,"180x190mm", 46, 2.5, 5.8)
			LV_Add(,"185x255mm", 146, 4.2, 2.8)
			LV_Add(,"185x260mm", 262, 4.2, 4.7)
			LV_Add(,"190x110mm", 38, 3.6, 6.6)
			LV_Add(,"190x230mm", 54, 3.3, 3.2)
			LV_Add(,"190x260mm", 442, 5.9, 2.4)
			LV_Add(,"190x275mm", 350, 3.8, 2.4)
			LV_Add(,"195x255mm", 226, 3.3, 5.2)
			LV_Add(,"200x135mm", 84, 2.3, 5.2)
			LV_Add(,"200x140mm", 74, 3.9, 8.8)
			LV_Add(,"200x210mm", 106, 3.2, 5.4)
			LV_Add(,"200x225mm", 142, 3.2, 3.1)
			LV_Add(,"200x230mm", 110, 4.8, 2.8)
			LV_Add(,"200x245mm", 122, 5.3, 4.0)
			LV_Add(,"205x260mm", 100, 2.8, 3.1)
			LV_Add(,"205x265mm", 156, 5.7, 3.4)
			LV_Add(,"205x270mm", 106, 2.9, 3.9)
			LV_Add(,"205x280mm", 216, 3.1, 2.0)
			LV_Add(,"205x300mm", 102, 3.6, 2.8)
			LV_Add(,"205x305mm", 150, 2.0, 2.5)
			LV_Add(,"210x160mm", 22, 3.2, 4.1)
			LV_Add(,"210x265mm", 126, 4.3, 2.4)
			LV_Add(,"210x270mm", 198, 3.0, 4.0)
			LV_Add(,"210x280mm", 126, 4.7, 3.6)
			LV_Add(,"210x285mm", 38, 3.1, 2.4)
			LV_Add(,"210x290mm", 270, 3.8, 3.9)
			LV_Add(,"210x300mm", 150, 4.3, 2.6)
			LV_Add(,"210x305mm", 90, 4.3, 4.5)
			LV_Add(,"215x300mm", 214, 3.6, 3.0) ; 5.4 2.7
			LV_Add(,"225x230mm", 166, 3.6, 4.2)
			LV_Add(,"230x165mm", 50, 3.0, 4.1)
			LV_Add(,"230x180mm", 30, 3.1, 6.4)
			LV_Add(,"230x270mm", 38, 3.1, 4.2)
			LV_Add(,"230x285mm", 214, 2.4, 3.6)
			LV_Add(,"235x310mm", 598, 3.6, 3.0)
			LV_Add(,"240x270mm", 318, 2.9, 5.1)
			LV_Add(,"255x215mm", 160, 4.4, 6.4)
			LV_Add(,"255x250mm", 320, 2.5, 3.3)
			LV_Add(,"260x210mm", 58, 2.8, 6.8)
			Gui, 1:Default
			Gui, Listview, List
			Return True
	}
}

;----------------------------------------------------------------------------

; Label:				Save_Settings
; Description:			GUI 1 Menu File->Save.

Save_Settings:
	Gui +OwnDialogs
	If Error := AutoPIFiles("Save")
		{
			MsgBox, 262160,	%Appname% - Error, % "Unable to save:`n" Error
			Error := ""
		}
	Return

;----------------------------------------------------------------------------

; Label:				Save_Settings
; Description:			GUI 1 Menu File->Save as.

Save_as_Settings:
	Gui +OwnDialogs
	If Error := AutoPIFiles("Save as")
		{
			MsgBox, 262160, %Appname% - Save as, % "Error Saving:`n" Error
			Error := ""
		}
	Return

;----------------------------------------------------------------------------

; Label:				Load_Settings
; Description:			GUI 1 Menu File->Load.

Load_Settings:
	Gui +OwnDialogs
	If Error := AutoPIFiles("Load")
		{
			MsgBox, 262160, %Appname% - Load, % "Error loading:`n" Error
			Error := ""
		}
	Return

;----------------------------------------------------------------------------

; Label:				Default_Settings
; Description:			GUI 1 menu option to restore default GUI 3 settings.

Default_Settings:
	Gui +OwnDialogs
	MsgBox, 262180, %Appname% - Settings, Restore default settings?
	IfMsgBox Yes
		{
			DefaultSettings("Restore")
			Gui, 1:Submit, NoHide
			Gui, 2:Submit, NoHide
			Gui, 3:Submit, NoHide
		}
	Return
;----------------------------------------------------------------------------

; Label:				Setting_OK
; Description:			Writes variables in GUI3 to settings.json and table.json after activating the Ok button.

Setting_OK:
	Gui +OwnDialogs
	if !Save("Settings.json", "w", A_FileEncoding){
			Error .= ErrorCheck("Settings.json")
		}
	if !Save("Table.json", "w", A_FileEncoding){
			Error .= ErrorCheck("Table.json")
		}
	If Error
		{
			MsgBox, 262160,	%Appname% - Error, % "Unable to save:`n" Error
			Error := ""
		}
	TableRead(0)
	GoSub, 3GUIClose
	TempSave := ""
	Return

;----------------------------------------------------------------------------

; Label:				Setting_Cancel
; Description:			Cancels any changes done to variables in GUI3 after activating the Cancel button.

Setting_Cancel:
	;	Automatic Crop Settings.
	GuiControl,3:, AC_Border, % TempSave["AC_Border"]
	GuiControl,3:, AC_Border, % (TempSave["AC_Border"] = 1) ? "On" : "Off"
	GuiControl,3:, AC_UpperLeftMargin, % TempSave["AC_UpperLeftMargin"]
	GuiControl,3:, AC_UpperRightMargin, % TempSave["AC_UpperRightMargin"]
	GuiControl,3:, AC_LowerLeftMargin, % TempSave["AC_LowerLeftMargin"]
	GuiControl,3:, AC_LowerRightMargin, % TempSave["AC_LowerRightMargin"]
	GuiControl,3:, AC_Sweep, % TempSave["AC_Sweep"]
	GuiControl,3:, AC_Sweep, % (TempSave["AC_Sweep"] = 1) ? "On" : "Off"
	GuiControl,3:, AC_UpperLeftSweep, % TempSave["AC_UpperLeftSweep"]
	GuiControl,3:, AC_UpperRightSweep, % TempSave["AC_UpperRightSweep"]
	GuiControl,3:, AC_LowerLeftSweep, % TempSave["AC_LowerLeftSweep"]
	GuiControl,3:, AC_LowerRightSweep, % TempSave["AC_LowerRightSweep"]
	GuiControl,3:, AC_Table, % TempSave["AC_Table"]
	GuiControl,3:, AC_TablePath, % TempSave["AC_TablePath"]
	GuiControl,3:ChooseString, AC_PPI, % TempSave["AC_PPI"]
	GuiControl,3:, AC_Manual, % TempSave["AC_Manual"]
	GuiControl,3:ChooseString, AC_Manual_sDDL, % TempSave["AC_Manual_sDDL"]
	GuiControl,3:, AC_HeightAdjust, % TempSave["AC_HeightAdjust"]
	GuiControl,3:, AC_WidthAdjust, % TempSave["AC_WidthAdjust"]
	AC_WidthAdjust_Millimeter := % TempSave["AC_WidthAdjust_Millimeter"]
	AC_HeightAdjust_Millimeter := % TempSave["AC_HeightAdjust_Millimeter"]
	AC_WidthAdjust_Percent := % TempSave["AC_WidthAdjust_Percent"]
	AC_HeightAdjust_Percent := % TempSave["AC_HeightAdjust_Percent"]
	AC_WidthAdjust_Pixel := % TempSave["AC_WidthAdjust_Pixel"]
	AC_HeightAdjust_Pixel := % TempSave["AC_HeightAdjust_Pixel"]
	;	UpDown Manual Wdith Adjustment.
	UpDown235_fIncrement := % TempSave["UpDown235_fIncrement"]
	UpDown235_fPos := % TempSave["UpDown235_fPos"]
	UpDown235_fRangeMin := % TempSave["UpDown235_fRangeMin"]
	UpDown235_fRangeMax := % TempSave["UpDown235_fRangeMax"]
	;	Updowen Manual Height Adjustment.
	UpDown238_fIncrement := % TempSave["UpDown238_fIncrement"]
	UpDown238_fPos := % TempSave["UpDown238_fPos"]
	UpDown238_fRangeMin := % TempSave["UpDown238_fRangeMin"]
	UpDown238_fRangeMax := % TempSave["UpDown238_fRangeMax"]
	GoSub, Select_AC
	UpdateTable(TableList)
	;	Disk Space.
	GuiControl,3:, Disk_Space, % TempSave["Disk_Space"]
	;	Folder & Profile
	GuiControl,3:, Crop_Check, % TempSave["Crop_Check"]
	GuiControl,3:, Crop_Check, % (TempSave["Crop_Check"] = 1) ? "On" : "Off"
	ControlGet, FolderpathList, List, , , % "ahk_id" FolderHWND
	if InStr(FolderpathList, TempSave["Folderpath"], false, 1, 1){
			GuiControl,3:ChooseString, Folderpath, % TempSave["Folderpath"]
		}Else{
			GuiControl,3:, Folderpath, % TempSave["Folderpath"]
			GuiControl,3:ChooseString, Folderpath, % TempSave["Folderpath"]
		}
	GuiControl,3:, ImageFolder, % TempSave["ImageFolder"]
	GuiControl,3:, ImageExtension, % TempSave["ImageExtension"]
	GuiControl,3:, ImageFolderCheck, % TempSave["ImageFolderCheck"]
	GuiControl,3:, ImageFolderCheck, % (TempSave["ImageFolderCheck"] = 1) ? "On" : "Off"
	ControlGet, ProfilepathList, List, , , % "ahk_id" ProfileHWND
	if InStr(ProfilepathList, TempSave["Profilepath"], false, 1, 1){
			GuiControl,3:ChooseString, Profilepath, % TempSave["Profilepath"]
		}Else{
			GuiControl,3:, Profilepath, % TempSave["Profilepath"]
			GuiControl,3:ChooseString, Profilepath, % TempSave["Profilepath"]
		}
	GuiControl,3:, ProfileExtension, % TempSave["ProfileExtension"]
	;	HotKeys
	;GuiControl,3:, HK1, % TempSave["savedHK1"]
	GuiControl,3:ChooseString, Macro_Delay_1, % TempSave["Macro_Delay_1"]
	;GuiControl,3:, HK2, % TempSave["savedHK2"]
	;GuiControl,3:, HK3, % TempSave["savedHK3"]
	;GuiControl,3:, HK4, % TempSave["savedHK4"]
	;GuiControl,3:, HK5, % TempSave["savedHK5"]
	GuiControl,3:, Space_Macro, % TempSave["Space_Macro"]
	GuiControl,3:, Space_Macro, % (TempSave["Space_Macro"] = 1) ? "On" : "Off"
	GuiControl,3:, Space_Macro_Delay, % TempSave["Space_Macro_Delay"]
	GuiControl,3:, Space_Process, % TempSave["Space_Process"]
	;	Imageview
	GuiControl,3:, MC_Angle, % TempSave["MC_Angle"]
	GuiControl,3:ChooseString, MC_Interpolation, % TempSave["MC_Interpolation"]
	GuiControl,3:ChooseString, MC_PixelOffset, % TempSave["MC_PixelOffset"]
	GuiControl,3:ChooseString, MC_Smoothing, % TempSave["MC_Smoothing"]
	GuiControl,3:ChooseString, MC_GridColour, % TempSave["MC_GridColour"]
	GuiControl,3:, MC_GridThickness, % TempSave["MC_GridThickness"]
	GuiControl,3:ChooseString, MC_SelectionColour, % TempSave["MC_SelectionColour"]
	GuiControl,3:, MC_SelectionThickness, % TempSave["MC_SelectionThickness"]
	;	List
	GuiControl,3:ChooseString, DragDrop_DDL, % TempSave["DragDrop_DDL"]
	Gosub, DragDrop
	GuiControl,3:ChooseString, CheckboxProperty, % TempSave["CheckboxProperty"]
	GuiControl,3:, List_AutoHDR, % TempSave["List_AutoHDR"]
	GuiControl,3:, List_AutoHDR, % (TempSave["List_AutoHDR"] = 1) ? "On" : "Off"
	GuiControl,3:, ListLoad, % TempSave["ListLoad"]
	GuiControl,3:, ListLoad, % (TempSave["ListLoad"] = 1) ? "On" : "Off"
	GuiControl,3:, ListRefresh, % TempSave["ListRefresh"]
	GuiControl,3:, ListRefresh, % (TempSave["ListRefresh"] = 1) ? "On" : "Off"
	GuiControl,3:, Openwith, % TempSave["Openwith"]
	GuiControl,3:, PercentageDifference, % TempSave["PercentageDifference"]
	;	Mouse Coordinates.
	GuiControl,3:, xMC_Local_Navigator, % TempSave["xMC_Local_Navigator"]
	GuiControl,3:, yMC_Local_Navigator, % TempSave["yMC_Local_Navigator"]
	GuiControl,3:, xMC_Left_Image, % TempSave["xMC_Left_Image"]
	GuiControl,3:, yMC_Left_Image, % TempSave["yMC_Left_Image"]
	GuiControl,3:, xMC_Right_Image, % TempSave["xMC_Right_Image"]
	GuiControl,3:, yMC_Right_Image, % TempSave["yMC_Right_Image"]
	;	Page Improver.
	GuiControl,3:ChooseString, Effects, % TempSave["Effects"]
	GuiControl,3:ChooseString, Pi_Mode, % TempSave["Pi_Mode"]
	ControlGet, Output_Folder_List, List, , , % "ahk_id" Output_FolderHWND
	if InStr(Output_Folder_List, TempSave["Output_Folder"], false, 1, 1){
			GuiControl,3:ChooseString, Output_Folder, % TempSave["Output_Folder"]
		}Else{
			GuiControl,3:, Output_Folder, % TempSave["Output_Folder"]
			GuiControl,3:ChooseString, Output_Folder, % TempSave["Output_Folder"]
		}
	GuiControl,3:ChooseString, Output_Action, % TempSave["Output_Action"]
	GuiControl,3:, mBranch_A1, % TempSave["mBranch_A1"]
	GuiControl,3:, mBranch_A2, % TempSave["mBranch_A2"]
	GuiControl,3:, cBranch_A1, % TempSave["cBranch_A1"]
	GuiControl,3:, Conditional_Branch, % TempSave["Conditional_Branch"]
	GuiControl,3:, Conditional_Branch, % (TempSave["Conditional_Branch"] = 1) ? "On" : "Off"
	GuiControl,3:, Initial_Restart, % TempSave["Initial_Restart"]
	GuiControl,3:, Initial_Restart, % (TempSave["Initial_Restart"] = 1) ? "On" : "Off"
	GuiControl,3:, Apply_Effect, % TempSave["Apply_Effect"]
	GuiControl,3:, Apply_Effect, % (TempSave["Apply_Effect"] = 1) ? "On" : "Off"
	GuiControl,3:, ShoulderSearch, % TempSave["ShoulderSearch"]
	GuiControl,3:, ShoulderSearch, % (TempSave["ShoulderSearch"] = 1) ? "On" : "Off"
	GuiControl,3:, AutoCrop, % TempSave["AutoCrop"]
	GuiControl,3:, AutoCrop, % (TempSave["AutoCrop"] = 1) ? "On" : "Off"
	;	Progress.
	If (TempSave["Images_Timer"] = TempSave["Duration_Timer"]){
			TempSave["Images_Timer"] := 1
			TempSave["Duration_Timer"] := 0
		}
	If (TempSave["Images_Timer"] = 1){
			GuiControl, 3:Enable, Deadline
			GuiControl, 3:Enable, Timelimit
			GuiControl, 3:Enable, DeadlineActiontaken
			GuiControl, 3:Enable, iCount_T1
			GuiControl, 3:Enable, iCount_T2
			GuiControl, 3:Enable, iCount_T3
		}Else{
			GuiControl, 3:Disable, Deadline
			GuiControl, 3:Disable, Timelimit
			GuiControl, 3:Disable, DeadlineActiontaken
			GuiControl, 3:Disable, iCount_T1
			GuiControl, 3:Disable, iCount_T2
			GuiControl, 3:Disable, iCount_T3
		}
	GuiControl,3:, Images_Timer, % TempSave["Images_Timer"]
	GuiControl,3:, Deadline, % TempSave["Deadline"]
	GuiControl,3:, Deadline, % (TempSave["Deadline"] = 1) ? "On" : "Off"
	GuiControl,3:ChooseString, Timelimit, % TempSave["Timelimit"]
	GuiControl,3:ChooseString, DeadlineActiontaken, % TempSave["DeadlineActiontaken"]
	GuiControl,3:, iCount_T1, % TempSave["iCount_T1"]
	GuiControl,3:, iCount_T2, % TempSave["iCount_T2"]
	GuiControl,3:, iCount_T3, % TempSave["iCount_T3"]
	GuiControl,3:, Duration_Timer, % TempSave["Duration_Timer"]
	GuiControl,3:, Limit, % TempSave["Limit"]
	GuiControl,3:, MB_Second, % TempSave["MB_Second"]
	If (TempSave["Duration_Timer"] = 1){
			GuiControl,3:Enable, Limit
			GuiControl,3:Enable, MB_Second
		}Else{
			GuiControl,3:Disable, Limit
			GuiControl,3:Disable, MB_Second
		}
	;	Main Branch Delay.
	GuiControl,3:, mBranch_T1, % TempSave["mBranch_T1"]
	GuiControl,3:, mBranch_T2, % TempSave["mBranch_T2"]
	GuiControl,3:, mBranch_T3, % TempSave["mBranch_T3"]
	GuiControl,3:, mBranch_T4, % TempSave["mBranch_T4"]
	GuiControl,3:, mBranch_T5, % TempSave["mBranch_T5"]
	GuiControl,3:, mBranch_T6, % TempSave["mBranch_T6"]
	;	Restart Branch.
	GuiControl,3:, cBranch_T1, % TempSave["cBranch_T1"]
	GuiControl,3:, cBranch_T2, % TempSave["cBranch_T2"]
	GuiControl,3:, cBranch_T3, % TempSave["cBranch_T3"]
	GuiControl,3:, cBranch_T4, % TempSave["cBranch_T4"]
	;	Send Mode.
	GuiControl,3:, Control_Send, % TempSave["Control_Send"]
	GuiControl,3:, KeyDelayCS, % TempSave["KeyDelayCS"]
	GuiControl,3:, PressDurationCS, % TempSave["PressDurationCS"]
	GuiControl,3:, Send_Event, % TempSave["Send_Event"]
	GuiControl,3:, KeyDelay, % TempSave["KeyDelay"]
	GuiControl,3:, PressDuration, % TempSave["PressDuration"]
	GuiControl,3:, Send_Input, % TempSave["Send_Input"]
	TempSave := ""
	Gui, 3:Submit, NoHide
	GoSub, 3GUIClose
	Return

;----------------------------------------------------------------------------

; Label:				TempSaveSettings
; Description:			Creates a copy of all the variables when opening GUI3 from the GUI1 menu.
;
; Notes:				Needs new code.

TempSaveSettings:
	TableRead(0,1)
	TempSave := Object()
	;	Automatic Crop.
	TempSave["AC_Border"] := AC_Border
	TempSave["AC_UpperLeftMargin"] := AC_UpperLeftMargin
	TempSave["AC_UpperRightMargin"] := AC_UpperRightMargin
	TempSave["AC_LowerLeftMargin"] := AC_LowerLeftMargin
	TempSave["AC_LowerRightMargin"] := AC_LowerRightMargin
	TempSave["AC_Sweep"] := AC_Sweep
	TempSave["AC_UpperLeftSweep"] := AC_UpperLeftSweep
	TempSave["AC_UpperRightSweep"] := AC_UpperRightSweep
	TempSave["AC_LowerLeftSweep"] := AC_LowerLeftSweep
	TempSave["AC_LowerRightSweep"] := AC_LowerRightSweep
	TempSave["AC_Table"] := AC_Table
	TempSave["AC_TablePath"] := AC_TablePath
	TempSave["AC_PPI"] := AC_PPI
	TempSave["AC_Manual"] := AC_Manual
	TempSave["AC_Manual_sDDL"] := AC_Manual_sDDL
	TempSave["AC_HeightAdjust"] := AC_HeightAdjust
	TempSave["AC_WidthAdjust"] := AC_WidthAdjust
	TempSave["AC_WidthAdjust_Millimeter"] := AC_WidthAdjust_Millimeter
	TempSave["AC_HeightAdjust_Millimeter"] := AC_HeightAdjust_Millimeter
	TempSave["AC_WidthAdjust_Percent"] := AC_WidthAdjust_Percent
	TempSave["AC_HeightAdjust_Percent"] := AC_HeightAdjust_Percent
	TempSave["AC_WidthAdjust_Pixel"] := AC_WidthAdjust_Pixel
	TempSave["AC_HeightAdjust_Pixel"] := AC_HeightAdjust_Pixel
	;	UpDown Manual Wdith Adjustment.
	TempSave["UpDown235_fIncrement"] := UpDown235_fIncrement
	TempSave["UpDown235_fPos"] := UpDown235_fPos
	TempSave["UpDown235_fRangeMin"] := UpDown235_fRangeMin
	TempSave["UpDown235_fRangeMax"] := UpDown235_fRangeMax
	;	UpDown Manual Height Adjustment.
	TempSave["UpDown238_fIncrement"] := UpDown238_fIncrement
	TempSave["UpDown238_fPos"] := UpDown238_fPos
	TempSave["UpDown238_fRangeMin"] := UpDown238_fRangeMin
	TempSave["UpDown238_fRangeMax"] := UpDown238_fRangeMax
	;	Disk Space.
	TempSave["Disk_Space"] := Disk_Space
	;	Folder & Profile
	TempSave["Crop_Check"] := Crop_Check
	TempSave["Folderpath"] := Folderpath
	TempSave["ImageFolder"] := ImageFolder
	TempSave["ImageExtension"] := ImageExtension
	TempSave["ImageFolderCheck"] := ImageFolderCheck
	TempSave["Profilepath"] := Profilepath
	TempSave["ProfileExtension"] := ProfileExtension
	;	HotKeys
	TempSave["savedHK1"] := HK1
	TempSave["Macro_Delay_1"] := Macro_Delay_1
	TempSave["savedHK2"] := HK2
	TempSave["savedHK3"] := HK3
	TempSave["savedHK4"] := HK4
	TempSave["savedHK5"] := HK5
	TempSave["Space_Macro"] := Space_Macro
	TempSave["Space_Macro_Delay"] := Space_Macro_Delay
	TempSave["Space_Process"] := Space_Process
	;	ImageView
	TempSave["MC_Angle"] := MC_Angle
	TempSave["MC_Interpolation"] := MC_Interpolation
	TempSave["MC_PixelOffset"] := MC_PixelOffset
	TempSave["MC_Smoothing"] := MC_Smoothing
	TempSave["MC_GridColour"] := MC_GridColour
	TempSave["MC_GridThickness"] := MC_GridThickness
	TempSave["MC_SelectionColour"] := MC_SelectionColour
	TempSave["MC_SelectionThickness"] := MC_SelectionThickness
	;	List
	TempSave["CheckboxProperty"] := CheckboxProperty
	TempSave["DragDrop_DDL"] := DragDrop_DDL
	TempSave["List_AutoHDR"] := List_AutoHDR
	TempSave["ListLoad"] := ListLoad
	TempSave["ListRefresh"] := ListRefresh
	TempSave["Openwith"] := Openwith
	TempSave["PercentageDifference"] := PercentageDifference
	;	Mouse Coordinates.
	TempSave["xMC_Local_Navigator"] := xMC_Local_Navigator
	TempSave["yMC_Local_Navigator"] := yMC_Local_Navigator
	TempSave["xMC_Left_Image"] := xMC_Left_Image
	TempSave["yMC_Left_Image"] := yMC_Left_Image
	TempSave["xMC_Right_Image"] := xMC_Right_Image
	TempSave["yMC_Right_Image"] := yMC_Right_Image
	;	Page Improver.
	TempSave["Effects"] := Effects
	TempSave["Pi_Mode"] := Pi_Mode
	TempSave["Output_Folder"] := Output_Folder
	TempSave["Output_Action"] := Output_Action
	TempSave["mBranch_A1"] := mBranch_A1
	TempSave["mBranch_A2"] := mBranch_A2
	TempSave["cBranch_A1"] := cBranch_A1
	TempSave["Conditional_Branch"] := Conditional_Branch
	TempSave["Initial_Restart"] := Initial_Restart
	TempSave["ShoulderSearch"] := ShoulderSearch
	TempSave["Apply_Effect"] := Apply_Effect
	TempSave["AutoCrop"] := AutoCrop
	;	Progress.
	TempSave["Images_Timer"] := Images_Timer
	TempSave["Deadline"] := Deadline
	TempSave["Timelimit"] := Timelimit
	TempSave["DeadlineActiontaken"] := DeadlineActiontaken
	TempSave["iCount_T1"] := iCount_T1
	TempSave["iCount_T2"] := iCount_T2
	TempSave["iCount_T3"] := iCount_T3
	TempSave["Duration_Timer"] := Duration_Timer
	TempSave["Limit"] := Limit
	TempSave["MB_Second"] := MB_Second
	;	Main Branch Delay.
	TempSave["mBranch_T1"] := mBranch_T1
	TempSave["mBranch_T2"] := mBranch_T2
	TempSave["mBranch_T3"] := mBranch_T3
	TempSave["mBranch_T4"] := mBranch_T4
	TempSave["mBranch_T5"] := mBranch_T5
	TempSave["mBranch_T6"] := mBranch_T6
	;	Restart Branch.
	TempSave["cBranch_T1"] := cBranch_T1
	TempSave["cBranch_T2"] := cBranch_T2
	TempSave["cBranch_T3"] := cBranch_T3
	TempSave["cBranch_T4"] := cBranch_T4
	;	Send Mode.
	TempSave["Control_Send"] := Control_Send
	TempSave["KeyDelayCS"] := KeyDelayCS
	TempSave["PressDurationCS"] := PressDurationCS
	TempSave["Send_Event"] := Send_Event
	TempSave["KeyDelay"] := KeyDelay
	TempSave["PressDuration"] := PressDuration
	TempSave["Send_Input"] := Send_Input
	Return

;----------------------------------------------------------------------------
;	Preset settings for Single Pages Edges
;----------------------------------------------------------------------------
SinglePages_NewDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(1,3)
	if Load(A_ScriptDir . "\Data\Presets\Single Pages\Single Pages - Edges.json", "r", A_FileEncoding){
			TrayTip,, Single Pages - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\Single Pages\Single Pages - Edges.json")
		}
	Return

;----------------------------------------------------------------------------
;	Preset settings for Single Pages Sharpening 2
;----------------------------------------------------------------------------
SinglePages_OldDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(1,4)
	if Load(A_ScriptDir . "\Data\Presets\Single Pages\Single Pages - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, Single Pages - Sharpening 2.json, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\Single Pages\Single Pages - Sharpening 2.json")
		}
	Return

;----------------------------------------------------------------------------
;	Preset settings for L & R on One Images - Edges
;----------------------------------------------------------------------------
AutoCrop_NewDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(2,1)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Automatic Crop - Edges.json", "r", A_FileEncoding){
			TrayTip,, Automatic Crop - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Automatic Crop - Edges.json")
		}
	Return

Book_NewDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(3,3)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Book - Edges.json", "r", A_FileEncoding){
			TrayTip,, Book - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Book - Edges.json")
		}
	Return

Periodical_NewDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(4,3)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Periodical - Edges.json", "r", A_FileEncoding){
			TrayTip,, Periodical - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Periodical - Edges.json")
		}

	Return

Complete_Periodical_NewDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(5,3)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Complete Periodical - Edges.json", "r", A_FileEncoding){
			TrayTip,, Complete Periodical - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Complete Periodical - Edges.json")
		}
	Return

;----------------------------------------------------------------------------
;	Preset settings for L & R on One Image - Sharpening 2
;----------------------------------------------------------------------------
AutoCrop_OldDL_Settings:
	Gui +OwnDialogs
	; ProfileSettings(2,2)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Automatic Crop - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, Automatic Crop - Sharpening 2, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Automatic Crop - Sharpening 2.json")
		}
	Return

Book_Settings:
	Gui +OwnDialogs
	; ProfileSettings(6,4)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Book - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, Book - Sharpening 2, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Book - Sharpening 2.json")
		}
	Return

Periodical_Settings:
	Gui +OwnDialogs
	; ProfileSettings(4,4)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Periodical - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, Periodical - Sharpening 2, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Periodical - Sharpening 2.json")
		}
	Return

Complete_Periodical_Settings:
	Gui +OwnDialogs
	; ProfileSettings(5,4)
	if Load(A_ScriptDir . "\Data\Presets\L & R on One Image\Complete Periodical - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, Complete Periodical - Sharpening 2, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on One Image\Complete Periodical - Sharpening 2.json")
		}
	Return

;----------------------------------------------------------------------------
;	Preset settings for L & R on Two Images
;----------------------------------------------------------------------------
ScanVpage_Edges:
	Gui +OwnDialogs
	; ProfileSettings(7,3)
	if Load(A_ScriptDir . "\Data\Presets\L & R on Two Images\L & R on Two Images - Edges.json", "r", A_FileEncoding){
			TrayTip,, L & R on Two Images - Edges, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on Two Images\L & R on Two Images - Edges.json")
		}
	Return

ScanVpage_Sharpening_2:
	Gui +OwnDialogs
	; ProfileSettings(7,4)
	if Load(A_ScriptDir . "\Data\Presets\L & R on Two Images\L & R on Two Images - Sharpening 2.json", "r", A_FileEncoding){
			TrayTip,, L & R on Two Images - Sharpening 2, 1, 0
		}Else{
			MsgBox, 262160,	%Appname% - Error, % "Unable to read:`n" ErrorCheck("Presets\L & R on Two Images\L & R on Two Images - Sharpening 2.json")
		}
	Return

;----------------------------------------------------------------------------
;	List View GUI1 and GUI3
;----------------------------------------------------------------------------

; Label:				Listview
; Description:			Events triggered through actions in Gui1 List View.
;
; Notes:				RMB opens menu. Double-click opens folder. Ctrl+A selects all items in listview.

/*
	If (A_GuiEvent == "I") && (CheckboxProperty = "Checked")
		{
			If (ErrorLevel == "C")
				{
					Critical, On
					RowNumber := 0
					Loop
						{
							RowNumber := LV_GetNext(RowNumber)
							if !RowNumber
							break
							LV_Modify(RowNumber, "+Check")
						}
					Critical, Off
				}
			if (ErrorLevel == "c")
				{
					Critical, On
					RowNumber := 0
					Loop
						{
							RowNumber := LV_GetNext(RowNumber)
							if !RowNumber
							break
							LV_Modify(RowNumber, "-Check")
						}
					Critical, Off
				}
			Return
		}
*/

Listview:
	Gui +OwnDialogs
	if(A_guievent = "F") or (A_GuiEvent = "I"){
			Return
		}
	If (A_GuiEvent = "ColClick"){
			;LV_Modify(0, "-Select")
			;RowNumber := LV_GetNext(Folderrow-1)
			;LV_Modify(RowNumber, "Focus Vis")
			/*
			If (A_EventInfo = 4)
				{
					If (LV_Sort = "Descending"){
							LV_Sort := "Ascending"
							LV_ModifyCol(6, "Sort")
					}Else{
							LV_Sort := "Descending"
							LV_ModifyCol(6, "SortDesc")
						}
				}
			*/
			LV_SortArrow(Listhwnd, A_EventInfo)
			If (ListRefresh = 1) && (CheckboxProperty = "Percentage difference"){
					LV_Update("Percentage difference", "1")
				}
			Return
		}
	if (A_GuiEvent = "DoubleClick"){
			LV_GetText(Folder, A_EventInfo, 1)
			If (Folder = "Error") or (Folder = "Folder"){
                    Return
                }
			if (openwith = ""){
					Run %Folder%,, UseErrorLevel
					if (ErrorLevel){
						MsgBox, 262160, %Appname% - Error, Unable to open:`n`n%Folder%
						Return
					}
				}
			If (Openwith = "Raw")
				{
					Gosub, View_Raw
					Return
				}
			If (Openwith = "Output")
				{
					Gosub, View_OutPut
					Return
				}
			If (Openwith != ""){
					Run %Openwith% %Folder%,, UseErrorLevel
					if (ErrorLevel){
						MsgBox, 262160, %Appname% - Error, Unable to open:`n`n%Folder%
						Return
					}
				}
		}
	if (A_GuiEvent = "Rightclick"){
			Menu, MenuListView, Show
			Return
		}
	if (A_GuiEvent = "K"){
			CtrlA := GetKeyState("Ctrl","P")
			if (CtrlA = 1){
					if (A_EventInfo = 65){
							LV_Modify(0, "Select")
							If (CheckboxProperty = "Checked"){
									LV_Modify(0, "+Check")
								}
						}
				}
		}
	return

;----------------------------------------------------------------------------

; Function:				LV_Modifylist
; Description:			Adds selected folder and profile into Gui1 ListView row.
;
; Old Code:
/*	
		Image := [], objFolder := Shell.BrowseForFolder(0, "AutoPI", 51, Folderpath)
		if IsObject(objFolder){
			For File, in objFolder.Items()
				{
					Ext := FilesystemObj.GetExtensionName(File)
					if Ext in % ImageExtension
						{
							FolderSizeMB += (File.Size/1048576)
							Image.Push(File.Name)
						}
				}
			}Else{
					Return 0
			}
*/
; Floor(FolderSizeMB*1000)

LV_Modifylist(Mode, Type, Option := 0, Event := 0){
	Gui +OwnDialogs
	SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	If (Mode = "Add") or (Mode = "DnD"){
			LV_Modify(LV_GetCount(), "+Focus")
		}
	FocusedRowNumber := LV_GetNext(0, "F")
	If (Type = "Folder")
		{
			FileSelectFolder, FolderVar, *%Folderpath%, 3
			If ErrorLevel
				{
					Return 0
				}
			Image := []
			loop, Files, %FolderVar%\*.*
					{
						If A_LoopFileExt in % ImageExtension
							{
								FolderSizeMB += (A_LoopFileSize/1048576)
								Image.Push(A_LoopFileFullPath)
							}
					}
			If Image.Count()
				{
					; RegExMatch(FolderVar, "i)" . ImageFolder . "$")
					if (ImageFolderCheck = 1) && (ImageFolder != FilesystemObj.GetFileName(FolderVar)){
							MsgBox, 262180, %Appname% - List, % "Selected folder is not " . ImageFolder . "`n`nContinue?"
							IfMsgBox no
								{
									Return 0
								}
						}
				}Else{
						MsgBox, 262160, %Appname% - Error, The folder has no images.
						Return 0
				}
			If (Crop_Check = 1) && (Image.Count() > 1)
				{
					FirstImage := WidthHeight(Image[Image.MinIndex()])
					LastImage := WidthHeight(Image[Image.MaxIndex()])
					If (FirstImage[1] != LastImage[1]) or (FirstImage[2] != LastImage[2])
					MsgBox, 262180, %Appname% - List, % "Folder contains images of varying sizes`n`nFirst Image: " . FirstImage[1] . "x" . FirstImage[2] . "`nLast Image: " . LastImage[1] . "x" . LastImage[2] . "`n`n" . FolderVar . "`n`nAdd Folder?"
					IfMsgBox no
						{
							Return 0
						}
				}
			FilesizeMB := (FolderSizeMB/Image.Count()), Sleepbase := ((FoldersizeMB/Image.Count())/MB_Second)
			Calculatedtime := ((Sleepbase <= Limit) ? (Limit*Image.Count()) : (Sleepbase*Image.Count()))
			FileSizeList := (FolderSizeMB > 1000) ? ((FolderSizeMB > 100000) ? (Floor(FolderSizeMB/1000) . " GB") : ((FolderSizeMB > 10000) ? (Round((FoldersizeMB/1000), 1) . " GB") : (Round((FoldersizeMB/1000), 2) . " GB"))) : ((FolderSizeMB < 1) ? (Floor(FolderSizeMB*1000) . " KB") : (Floor(FoldersizeMB) . " MB"))
			If (Mode = "Insert"){
					LV_Insert(FocusedRowNumber,, FolderVar,, Image.Count(), FileSizeList, Time(Calculatedtime))
					LV_Modify((FocusedRowNumber), "+Focus +Select")
					if (CheckboxProperty != "Checked"){
							LV_Modify((FocusedRowNumber+1), "-Select")
						}
					; MsgBox insert Row
				}
			If (Mode = "Modify"){
					LV_Modify(FocusedRowNumber,, FolderVar,,, Image.Count(), FileSizeList, Time(Calculatedtime))
					; MsgBox Modify Row
				}
			If (Mode = "Add")
				{
					if (Option = "Single Profile"){
						LV_Add(, FolderVar, ProfileVar,, Image.Count(), FileSizeList, Time(Calculatedtime))
						; MsgBox Add Row - Single Profile
					}Else{
						LV_Add(, FolderVar,,, Image.Count(), FileSizeList, Time(Calculatedtime))
						; MsgBox Add Row
					}
					if (CheckboxProperty != "Checked"){
							LV_Modify((FocusedRowNumber), "-Select")
						}
					LV_Modify((FocusedRowNumber+1), "+Focus +Select")
				}
			If LV_GetCount()
			GoSub, List_Update
			Return 1
		}
	If (Type = "Profile")
		{
			FileSelectFile, ProfileVar, S1, %Profilepath%\, Browse For Profile,(*.%ProfileExtension%)
			If ErrorLevel
				{
					If (Option = "Edit")
					Return 0
					LV_DeleteRows("Last Focus")
					Return 0
				}
			Loop
				{
					Ext := FilesystemObj.GetExtensionName(ProfileVar)
					if Ext in % ProfileExtension
						{
							LV_Modify(FocusedRowNumber, Folderrow,, ProfileVar)
							Return 1
						}
					Else
						{
							MsgBox, 262160, %Appname% - Error, Wrong file type.
							FileSelectFile, ProfileVar, S1, %Profilepath%, Browse For Profile,(*.%ProfileExtension%)
							If ErrorLevel
								{
									If (Option = "Edit")
									Return 0
									LV_DeleteRows("Last Focus")
									Return 0
								}
						}
				}
		}
	If (Type = "Multi")
		{
			Array := []
			If (Mode = "Add")
				{
					FileSelectFolder, FolderVar, *%Folderpath%, 3
					If ErrorLevel
						{
							Return 0
					}Else{
								if Check(FolderVar)
									{
										Array.Push(FolderVar)
									}
								Loop, Files, %FolderVar%\*.*, DR
									{
										Array.Push(A_LoopFileFullPath)
									}
						}
				}
			If (Mode = "DnD")
				{
					SB_SetText("Adding drag & drop",2,1)
					Loop, Parse, Event, `n
						{
							if Check(A_LoopField)
								{
									Array.Push(A_LoopField)
								}
							Loop, Files, %A_LoopField%\*.*, DR
								{
									Array.Push(A_LoopFileFullPath)
								}
						}
				}
			If Array.Count()
				{
					GuiControl, -Redraw, List
					Guictrls(0,0,0)
			}Else{
					Return 0
				}
			For Index, Value In Array
				{
					If (Output_Folder = FilesystemObj.GetFileName(Value)){
							Continue
						}
					Image := [], FolderSizeMB := ""
					loop, Files, %Value%\*.*
						{
							If A_LoopFileExt in % ImageExtension
								{
									FolderSizeMB += (A_LoopFileSize/1048576)
									Image.Push(A_LoopFileFullPath)
								}
						}
					If Image.Count()
						{
							if (ImageFolderCheck = 1) && (ImageFolder != FilesystemObj.GetFileName(Value)){
									MsgBox, 262179, %Appname% - Drag & Drop, % "Files were found in a non " . ImageFolder . " folder:`n`n" . Value . "`n`nAdd Folder?"
									IfMsgBox no
										{
											Continue
										}
									IfMsgBox Cancel
										{
											Break, 1
										}
								}
						}Else{
								Continue
						}
					If (Crop_Check = 1) && (Image.Count() > 1)
						{
							FirstImage := WidthHeight(Image[Image.MinIndex()])
							LastImage := WidthHeight(Image[Image.MaxIndex()])
							If (FirstImage[1] != LastImage[1]) or (FirstImage[2] != LastImage[2])
							MsgBox, 262180, %Appname% - List, % "Folder contains images of varying sizes`n`nFirst Image: " . FirstImage[1] . "x" . FirstImage[2] . "`nLast Image: " . LastImage[1] . "x" . LastImage[2] . "`n`n" . Value . "`n`nAdd Folder?"
							IfMsgBox no
								{
									Continue
								}
						}
					If (Image.Count()) && (Option != "")
						{
							FileSelectFile, ProfileVar, S1, %Profilepath%, Select profile for %Value%,(*.%ProfileExtension%)
							If ErrorLevel
								{
									Break, 1
								}
							Loop
								{
									Ext := FilesystemObj.GetExtensionName(ProfileVar)
									if Ext in % ProfileExtension
										{
											Break
										}
									Else
										{
											MsgBox, 262160, %Appname% - Error, Wrong file type.
											FileSelectFile, ProfileVar, S1, %Profilepath%, Select profile for %Value%,(*.%ProfileExtension%)
											If ErrorLevel
												{
													Break, 1
												}
										}
								}
							If (Option = "Single Profile"){
									Option := ""
							}
						}
					If Image.Count()
						{
							FilesizeMB := (FolderSizeMB/Image.Count()), Sleepbase := ((FoldersizeMB/Image.Count())/MB_Second)
							FileSizeList := (FolderSizeMB > 1000) ? ((FolderSizeMB > 100000) ? (Floor(FolderSizeMB/1000) . " GB") : ((FolderSizeMB > 10000) ? (Round((FoldersizeMB/1000), 1) . " GB") : (Round((FoldersizeMB/1000), 2) . " GB"))) : ((FolderSizeMB < 1) ? (Floor(FolderSizeMB*1000) . " KB") : (Floor(FoldersizeMB) . " MB"))
							Calculatedtime := ((Sleepbase <= Limit) ? (Limit*Image.Count()) : (Sleepbase*Image.Count()))
							If (CheckboxProperty = "Checked"){
										Lv_Add("+Check", Value, ProfileVar,, Image.Count(), FileSizeList, Time(Calculatedtime))
										Folderrow := LV_GetCount()+1, LV_Modify(FolderRow, "+Selected")
								}Else{
										Lv_Add(, Value, ProfileVar,, Image.Count(), FileSizeList, Time(Calculatedtime))
								}
						}
				}
			GuiControl, +Redraw, List
			SB_SetText("",2,1)
			Guictrls(1,1,0)
			If LV_GetCount()
			GoSub, List_Update
			Return 1
		}
}

;----------------------------------------------------------------------------

; Label:				LV_Add_Row
; Description:			Add a single folder and select a profile to GUI1 list view
;
; Trigger:				Add Row. GUI1 edit menu or left-click menu in list view.

LV_Add_Row:
	If LV_Modifylist("Add","Folder")
		LV_Modifylist("Add", "Profile")
	Return

;----------------------------------------------------------------------------

; Label:				LV_Add_Rows
; Description:			Add folders and select profiles to GUI1 list view. 
;
; Trigger:				Add Rows - Multiple profiles. GUI1 edit menu or left-click menu in list view.

/*
	Loop
		{
			If !LV_Modifylist("Add","Folder")
				Break
			If	!LV_Modifylist("Add", "Profile")
				Break
        }
*/

LV_Add_Rows:
	LV_Modifylist("Add", "Multi", "Multiple Profiles")
	Return

;----------------------------------------------------------------------------

; Label:				LV_Add_Rows_SingleProfile
; Description:			Add folders and select profile only once to GUI1 list view.
;
; Trigger:				Add Rows - One profile. GUI1 edit menu or left-click menu in list view.

/*
	If !LV_Modifylist("Add","Folder")
		Return
	if LV_Modifylist("Add", "Profile")
		{
			Loop
				{
					If !LV_Modifylist("Add", "Folder", "Single Profile")
						Break
				}
		}
*/

LV_Add_Rows_SingleProfile:
	LV_Modifylist("Add", "Multi", "Single Profile")
	Return

;----------------------------------------------------------------------------

; Label:				LV_Insertrow
; Description:			Inserts a new row above focused row in list view.
;
; Trigger:				Insert. GUI1 edit menu or left-click menu in list view.

LV_Insertrow:
	if (Folderrow > 1){
			If LV_Modifylist("Insert","Folder"){
				LV_Modifylist("Insert","Profile")
			}
		}
	Return

;----------------------------------------------------------------------------

; label:				LV_Modify_Folder
; Description:			Modifies the selected row in list view with a new folder.
;
; Trigger:				Modify. GUI1 edit menu or left-click menu in list view.

LV_Modify_Folder:
		if (Folderrow > 1){
			LV_ModifyList("Modify", "Folder", "Edit")
		}
	Return

;----------------------------------------------------------------------------

; label:				LV_Modify_Profile
; Description:			Modifies the selected row in list view with a new Profile.
;
; Trigger:				Modify. GUI1 edit menu or left-click menu in list view.

LV_Modify_Profile:
		if (Folderrow > 1){
			LV_ModifyList("Modify", "Profile", "Edit")
		}
	Return

;----------------------------------------------------------------------------

; Label:				LV_Clear
; Description:			Deletes everything from GUI1 List View and sets a new rowcount.
;
; Trigger:				Delete All. GUI1 edit menu or left-click menu in list view.

LV_Clear:
	Gui +OwnDialogs
	If (Folderrow != 1){
			MsgBox,	262180, %Appname% - List, Are you sure you want to clear the list?
			IfMsgBox Yes
				{
					LV_Delete()
					LV_Update("GetCount")
					if WinExist("ahk_id" Image1){
							GoSub, View_Close
						}
					If (List_AutoHDR = 1){
							LV_Update("AutoHDR")
						}
				}
		}
	return

;----------------------------------------------------------------------------

; Label:				LV_RemoveCrop
; Description:			Delete selected row(s) from crop object
;
; Trigger:				Remove crop. GUI1 edit menu or left-click menu in list view.

LV_RemoveCrop:
	FocusedRowNumber := LV_GetNext(0, "F")
	LV_GetText(Folder, FocusedRowNumber, 1)
	If (Folder != ""){
			LV_Modify(FocusedRowNumber, Folderrow,,,"")
			MC_Obj.Delete(Folder)
		}
	Return

;----------------------------------------------------------------------------

; Label:				LV_DeleteSelected
; Description:			Delete selected row(s) from GUI1 List View.
;
; Trigger:				Remove row. GUI1 edit menu or left-click menu in list view.

LV_RemoveSelected:
	If LV_DeleteRows("Selected")
		{
			if WinExist("ahk_id" Image1)
				GoSub, View_Close
		}
	return

;----------------------------------------------------------------------------
; Function:				LV_DeleteRows
; Description:			
; Last Entry:			Deletes the last row in List View and updates rowcount.
; Last Focus:			Deletes the last focused row in List View and updates rowcount.
; Selected:				Deletes selected rows in ListView and updates rowcount.

LV_DeleteRows(Action){
	If (Action = "Last Entry"){
			LV_Modify(Folderrow, "-Select +Focus")
			FocusedRowNumber := LV_GetNext(0, "F")
			LV_Delete(FocusedRowNumber)
			LV_Update("GetCount")
		}
	If (Action = "Last Focus"){
			LV_Delete(FocusedRowNumber)
			LV_Update("GetCount")
		}
	If (Action = "Selected"){
			Selected := Object(), RowNr := 0
			Loop
				{
					RowNr := LV_GetNext(RowNr)
					if (RowNr){
							Selected.InsertAt(A_Index, RowNr)
					}Else{
							 Break
						}
				}
			If (Selected.Count() = LV_GetCount()){
					LV_Delete()
					LV_Update("GetCount")
					If (List_AutoHDR = 1){
							LV_Update("AutoHDR")
						}
					return 1
				}
			Else if (Selected.Count() = 0){
						Return 0
				}Else{
						GuiControl, -Redraw, List
						For Key, Value in Selected
							{
								If (A_Index = 1){
									Lv_Delete(Value)
								}Else{
									LV_Delete(Value-A_Index+1)
								}
							}
						If (ListRefresh = 1){
							If (CheckboxProperty = "None")
									LV_Update("None", "1")
							If (CheckboxProperty = "Checked")
									LV_Update("Checked", "1")
							If (CheckboxProperty = "Percentage difference")
									LV_Update("Percentage difference", "1")
							}Else{
									LV_Update("GetCount")
								}
						GuiControl, +Redraw, List
						return 1
					}
		}
}

;----------------------------------------------------------------------------

; Label:				List_HDR
; Description:			Saves the contents of each control to associated variable (if any) and hides the window unless the NoHide option is present.

List_HDR:
	Gui, 3:Submit, Nohide
	GuiControl,3:, List_AutoHDR, % (List_AutoHDR = 1) ? "On" : "Off"
	If (ListRefresh = 1){
		If (CheckboxProperty = "None")
			LV_Update("None", "1")
		If (CheckboxProperty = "Checked")
			LV_Update("Checked", "1")
		If (CheckboxProperty = "Percentage difference")
			LV_Update("Percentage difference", "1")
	}Else{
			LV_Update("GetCount")
		}
	If (List_AutoHDR = 1){
			LV_Update("AutoHDR")
		}
	Return

;----------------------------------------------------------------------------

; Label:				List_Update
; Description:			Checkbox Property (DropDownList) in GUI 3 Settings.

List_Update:
	GUI, 3:Submit, NoHide
	If Disablecontrol
	Return
	If (CheckboxProperty = "None")
		{
			Menu, KKKK, Check, None
			Menu, KKKK, unCheck, Percentage difference
			Menu, KKKK, unCheck, Checked
			SendMessage, 0x1036, -0x08000000, 0x00000004, , % "ahk_id" . ListHWND ; 0x1036 is LVM_SETEXTENDEDLISTVIEWSTYLE | 0x08000000 is LVS_EX_AUTOCHECKSELECT | 0x00000004 is LVS_EX_CHECKBOXES
			GuiControl, 1:-LV0x4, List
			LV_Modify(0, "-Select")
		}
	If (CheckboxProperty = "Percentage difference")
		{
			Menu, KKKK, Check, Percentage difference
			Menu, KKKK, unCheck, None
			Menu, KKKK, unCheck, Checked
			GuiControl, 1:+LV0x4, List
			SendMessage, 0x1036, -0x08000000, 0x00000004, , % "ahk_id" . ListHWND ; 0x1036 is LVM_SETEXTENDEDLISTVIEWSTYLE | 0x08000000 is LVS_EX_AUTOCHECKSELECT | 0x00000004 is LVS_EX_CHECKBOXES
			LV_Modify(0, "-Select")
		}
	If (CheckboxProperty = "Checked")
		{
			Menu, KKKK, Check, Checked
			Menu, KKKK, unCheck, None
			Menu, KKKK, unCheck, Percentage difference
			GuiControl, 1:+LV0x4, List
			SendMessage, 0x1036, 0x08000000, 0x08000000, , % "ahk_id" . ListHWND ; 0x1036 is LVM_SETEXTENDEDLISTVIEWSTYLE | 0x08000000 is LVS_EX_AUTOCHECKSELECT
		}
	If (ListRefresh = 1){
			If (CheckboxProperty = "None")
				LV_Update("None", "1")
			If (CheckboxProperty = "Checked")
				LV_Update("Checked", "1")
			If (CheckboxProperty = "Percentage difference")
				LV_Update("Percentage difference", "1")
		}Else{
				LV_Update("GetCount")
		}
	If (List_AutoHDR = 1)
		{
			LV_Update("AutoHDR")
		}
	Return

;----------------------------------------------------------------------------

; Function:				LV_Update
; Description:			Events triggered through actions in Gui3 List View.

LV_Update(Action, RowCount := 0){
	;Critical
	Temp := A_DefaultGui, oIndex := 1
	If (Action = "GetCount"){
			GUI, 1:Default
			Folderrow := LV_GetCount()+1
			Gui, %Temp%:Default
			Return 1
		}
	If (Action = "None"){
			ControlGet, OutputVar, List, Col1,, % "ahk_id" ListHWND
			If Outputvar
				{
					GUI, 1:Default
					ComObjError(false)
					Critical, On
					Loop, Parse, OutputVar, `n
						{
							If !FilesystemObj.GetFolder(A_LoopField).Files.Count{
									LV_Delete(oIndex)
									Continue
								}
							Checked := LV_GetNext(oIndex-1, "Checked")
							If (Checked = oIndex){
									LV_Modify(oIndex, "-Check")
								}
							oIndex++
						}
					Critical, Off
					ComObjError(True)
					If (RowCount = "1"){
							LV_Update("GetCount")
						}
					Gui, %Temp%:Default
					Return True
				}Else{
					Return False
				}
			}
	if (Action = "Checked"){
			ControlGet, OutputVar, List, Col1,, % "ahk_id" ListHWND
			If Outputvar
				{
					GUI, 1:Default
					ComObjError(false)
					Critical, On
					Loop, Parse, OutputVar, `n
						{
							If !FilesystemObj.GetFolder(A_LoopField).Files.Count{
									LV_Delete(oIndex)
									Continue
								} 
							Checked := LV_GetNext(oIndex-1, "Checked")
							If (Checked = oIndex){
									LV_Modify(oIndex, "+Select")
								}
							Selected := LV_GetNext(oIndex-1)
							If (Selected = oIndex){
									LV_Modify(oIndex, "+Check")
								}
							oIndex++
						}
					Critical, Off
					ComObjError(True)
					If (RowCount = "1"){
							LV_Update("GetCount")
						}
					Gui, %Temp%:Default
					Return True
				}Else{
					Return False
				}
		}
	If (Action = "Percentage difference"){
			ControlGet, OutputVar, List, Col1,, % "ahk_id" ListHWND
			If Outputvar
				{
					GUI, 1:Default
					Array := []
					ComObjError(false)
					Critical, On
					Loop, Parse, OutputVar, `n
						{
							loop, Files, %A_LoopField%\*.*
							FolderSizeMB += (A_LoopFileSize/1048576)
							If (FolderSizeMB/FilesystemObj.GetFolder(A_LoopField).Files.Count = ""){
									LV_Delete(oIndex), FolderSizeMB := ""
									Continue
								}
							AverageFileSize := (FolderSizeMB/FilesystemObj.GetFolder(A_LoopField).Files.Count), FolderSizeMB := ""
							Array.InsertAt(oIndex, AverageFileSize), oIndex++
						}
					ComObjError(True)
					For index, Value in Array
						{
							if (Abs((Value-(Array[Index-1]))/((Value+(Array[Index-1]))/2)*100) >= PercentageDifference){
									LV_Modify(A_Index, "+Check")
								}Else{
									LV_Modify(A_Index, "-Check")
								}
						}
					Critical, Off
					If (RowCount = "1"){
							LV_Update("GetCount")
						}
					Gui, %Temp%:Default
					Return True
				}Else{
					Return False
				}
		}
	If (Action = "AutoHDR")
		{
			/*
				DecodeInteger("int4", &rect, 0) - Left
				DecodeInteger("int4", &rect, 4) - Top
				DecodeInteger("int4", &rect, 8) - Right
				DecodeInteger("int4", &rect, 12) - Bottom
				LVM_GETITEMRECT - Retrieves the bounding rectangle for all or part of an item in the current view
				LVIR_BOUNDS - Returns the bounding rectangle of the entire item, including the icon and label.
				ScrollWidth = SM_CXVSCROLL - Width of a vertical scroll bar, in pixels; and height of the arrow bitmap on a vertical scroll bar, in pixels.
				WS_VSCROLL = 0x200000
			*/
			GUI, 1:Default
			WinGet, OutputVar, MinMax, % "ahk_id" . Gui1
			If (Folderrow = 1){
					LV_ModifyCol(1,"360"), LV_ModifyCol(2,"184"), LV_ModifyCol(3,"78"), LV_ModifyCol(4,"50"), LV_ModifyCol(5,"54"), LV_ModifyCol(6,"57")
					;GuiControl,1:,List, w724 r10
					if OutputVar in 0
						{
							Gui, 1:Show, NA w822, % Appname
						}
					;msgbox % folderrow . " test 1"
					Gui, %Temp%:Default
					Return False
				}
			Loop % LV_GetCount("Column")-3{
					LV_ModifyCol(A_Index, "AutoHDR")
				}
			;msgbox % folderrow . " test 2"
			if OutputVar in 0
				{
					VarSetCapacity(rect, 16, 0)
					SendMessage, 0x1000+14, 0, &rect,, % "ahk_id" . ListHwnd
					ControlGet, LV_Style, Style,,, % "ahk_id" . ListHwnd
					If (LV_Style & 0x200000){
							SysGet, LV_cxvScroll, 2
							LV_Size := (DecodeInteger("int4", &rect, 8)-DecodeInteger("int4", &rect, 0)+LV_cxvScroll)
					}Else{
							LV_Size := (DecodeInteger("int4", &rect, 8)-DecodeInteger("int4", &rect, 0))
						}
					AutoPI_Size := ((22+LV_Size) > A_ScreenWidth ? A_ScreenWidth : (22+LV_Size))
					;msgbox % AutoPI_Size
					Gui, 1:Show, NA w%AutoPI_Size%, % Appname
				}
			Gui, %Temp%:Default
			Return True
		}
}

;----------------------------------------------------------------------------

; Function:				LV_SortArrow
; Description:			Display arrow in column headers
;
; h						ListView handle
; c						1 based Index of the column
; d						Optional direction to set the arrow. "asc" or "up". "desc" or "down".

LV_SortArrow(h, c, d=""){
	Static ptr, ptrSize, lvColumn, LVM_GETCOLUMN, LVM_SETCOLUMN
	if (!ptr){
			ptr := A_PtrSize ? ("ptr", ptrSize := A_PtrSize) : ("uint", ptrSize := 4)
			LVM_GETCOLUMN := A_IsUnicode ? (4191, LVM_SETCOLUMN := 4192) : (4121, LVM_SETCOLUMN := 4122)
			VarSetCapacity(lvColumn, ptrSize + 4), NumPut(1, lvColumn, "uint")
		}
	c -= 1 ; convert to 0 based index
	DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", c, ptr, &lvColumn)
	if ((fmt := NumGet(lvColumn, 4, "int")) & 1024){
				if (d && d = "asc" || d = "up")
					return
				NumPut(fmt & ~1024 | 512, lvColumn, 4, "int")
	}else if (fmt & 512) {
			if (d && d = "desc" || d = "down")
				return
			NumPut(fmt & ~512 | 1024, lvColumn, 4, "int")
	}else{
			Loop % DllCall("SendMessage", ptr, DllCall("SendMessage", ptr, h, "uint", 4127), "uint", 4608)
				if ((i := A_Index - 1) != c){
						DllCall("SendMessage", ptr, h, "uint", LVM_GETCOLUMN, "uint", i, ptr, &lvColumn)
						NumPut(NumGet(lvColumn, 4, "int") & ~1536, lvColumn, 4, "int")
						DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", i, ptr, &lvColumn)
					}
			NumPut(fmt | (d && d = "desc" || d = "down" ? 512 : 1024), lvColumn, 4, "int")
		}
	return DllCall("SendMessage", ptr, h, "uint", LVM_SETCOLUMN, "uint", c, ptr, &lvColumn)
}

;----------------------------------------------------------------------------

; Label:				GuiDropFiles
; Description:			Adding folders through Drag & Drop and selecting profiles.
/*
	GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y){
		for i, file in FileArray
	}
*/
GuiDropFiles:
	Gui +OwnDialogs
	If (Disablecontrol = 1) or (SelectedDnD = ""){
			Return
		}
	If (SelectedDnD = "&Multiple profiles`tCtrl+1"){
			LV_Modifylist("DnD", "Multi", "Multiple Profiles", A_GuiEvent)
		}
	If (SelectedDnD = "&One profile`tCtrl+2"){
			LV_Modifylist("DnD", "Multi", "Single Profile", A_GuiEvent)
		}
	Return

;----------------------------------------------------------------------------

; Function:				ImageViewer
; Description:			Image viewer. Draw rect with Lbutton and calculate crop settings.
;

; DllCall("gdiplus\GdipCreateCachedBitmap", "Ptr", pBitmap, "Ptr", G, "PtrP", cBitmap)
; DllCall( "gdiplus\GdipDrawCachedBitmap", "Ptr", G, "Ptr", cBitmap, "Int", 0, "Int", 0)

/*
	Gdip_CropImage(pBitmap, x, y, w, h)
		{
			pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
			Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
			Gdip_DeleteGraphics(G2)
			return pBitmap2
		}
*/

ImageViewer(Action, Byref ImgObj, Option := 0, Rotation := 0, RotationType1 := 0, RotationType2 := 0){
	If (Action = "Create")
		{
			Static Angle, iIndex, iMaxIndex, iWidth, iHeight, RWidth, RHeight, TWidth, THeight
			ImgObj := Object(), oIndex := 1, iIndex := 1, iMaxIndex := "", Angle := 0
			RowNumber := LV_GetNext(0, "F")
			LV_GetText(FolderVar, RowNumber, 1)
			If (Option = "Output")
			FolderVar := % FolderVar . "\" . Output_Folder
			Loop, Files, %FolderVar%\*.*, F
				{
					If A_LoopFileExt in % ImageExtension
						{
							ImgObj["ImagePath"oIndex] := A_LoopFilePath
							ImgObj["ImageName"oIndex] := A_LoopFileName
							ImgObj["FileSize"oIndex] := ((A_LoopFileSize/1048576) > 1000) ? (((A_LoopFileSize/1048576) > 100000) ? (Floor((A_LoopFileSize/1048576)/1000) . " GB") : (((A_LoopFileSize/1048576) > 10000) ? (Round(((A_LoopFileSize/1048576)/1000), 1) . " GB") : (Round(((A_LoopFileSize/1048576)/1000), 2) . " GB"))) : (((A_LoopFileSize/1048576) < 1) ? (Floor((A_LoopFileSize/1048576)*1000) . " KB") : (Floor((A_LoopFileSize/1048576)) . " MB"))
							oIndex++
						}
				}
			If !iMaxIndex := oIndex-1
			Return False
			SysGet, M_, MonitorWorkArea ; M_Left M_Right M_Top M_Bottom
			;WinGetPos,,,, tH, ahk_class Shell_TrayWnd
			ImgObj["ImagePath"] := FolderVar
			pBitmap := Gdip_CreateBitmapFromFile(ImgObj["ImagePath"iIndex])
			If !pBitmap
			Return False
			SB_SetText("", 1, 1), SB_SetText("", 2, 1), SB_SetText("", 3, 1), SB_SetText("", 4, 1), SB_1 := 600
			ImgObj["PPI"] := Gdip_GetImageHorizontalResolution(pBitmap) ; Gdip_GetImageVerticalResolution(pBitmap)
			iWidth := Gdip_GetImageWidth(pBitmap)
			iHeight := Gdip_GetImageHeight(pBitmap)
			ImgObj["Img_P"] := (M_Bottom-95)/iHeight
			ImgObj["Img_W"] := ((iWidth*ImgObj["Img_P"]) > M_Right) ? (M_Right-95) : (iWidth*ImgObj["Img_P"])
			ImgObj["Img_P"] := ((iWidth*ImgObj["Img_P"]) > M_Right) ? ImgObj["Img_W"]/iWidth : (M_Bottom-95)/iHeight ; Final Proportion
			ImgObj["Img_H"] := (iHeight*ImgObj["Img_P"])
			hdc := CreateCompatibleDC()
			hbm := CreateDIBSection(w := ImgObj["Img_W"], h := ImgObj["Img_H"], hdc, 32)  ; 32 bit colour
			obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
			Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"], ImgObj["Img_H"], 0, 0, iWidth, iHeight)
			Gui, Image1: +HwndImage1 +Parent1 -Caption +E0x80000 +ToolWindow -DPIScale ; Layered window = +E0x80000
			Gui, Image2: +HwndImage2 +ParentImage1 -Caption +E0x80000 +ToolWindow +OwnDialogs -DPIScale ; +AlwaysOnTop
			Gui, Image1: Add, Picture, % "x0 y0 w" . ImgObj["Img_W"] . " h" . ImgObj["Img_H"] . " viPic gView_gPicture_1",
			Gui, Image1: Show, Center
			Gui, 1:Show, % "xCenter y0 h" . (ImgObj["Img_H"]+43) . " w" . (ImgObj["Img_W"]+20), % Appname ; . " - " . ImgObj["ImagePath"iIndex]
			UpdateLayeredWindow(Image1, hdc, 10, 10, ImgObj["Img_W"], ImgObj["Img_H"])
			SB_SetText(A_Space . iIndex . "/" . iMaxIndex . "  |  " . ImgObj["ImageName"iIndex] . "  |  " . iWidth . "x" . iHeight . "  |  " . CalcSize(3, iWidth, IHeight, ImgObj["PPI"]) . "  |  " . ImgObj["FileSize"iIndex], 1, 1)
			SelectObject(hdc, obm), DeleteObject(hbm)
			DeleteDC(hdc), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
			;ImageViewer("Deskew", ImgObj)
			Return True
		}
	If (Action = "Deskew")
		{
			/*
			hOpencv := DllCall("LoadLibrary", "str", "C:\Users\Espen\Desktop\AutoPi\Resources\OpenCV\opencv-4.6.0-vc14_vc15\opencv\build\x64\vc15\bin\opencv_world460.dll", "ptr")
			hOpencvCom := DllCall("LoadLibrary", "str", "C:\Users\Espen\Desktop\AutoPi\Resources\OpenCV\autoit-opencv-com\autoit_opencv_com460.dll", "ptr")
			DllCall("autoit_opencv_com460.dll\DllInstall", "int", 1, "wstr", A_IsAdmin = 0 ? "user" : "", "cdecl")
			; Prep Image
			cv := ComObjCreate("OpenCV.cv")
			img := cv.imread(ImgObj["ImagePath"iIndex])
			img_grey := cv.cvtColor(img, CV_COLOR_BGR2GRAY := 6)
			img_blur = cv.GaussianBlur(img_grey, [9, 9], 0)
			cv.threshold(img_grey, 99, 255, (CV_THRESH_BINARY := 0))
			thresh := cv.extended.1
			contours := cv.findContours(thresh, CV_RETR_TREE := 3, CV_CHAIN_APPROX_SIMPLE := 2)
			arr := ComObjArray(VT_VARIANT:=12, 4)
			arr[0] := 0
			arr[1] := 0
			arr[2] := 255
			arr[3] := 0
			*/
			/*
			loop % contours.maxindex() + 1
				{
					data := contours[A_Index-1].data
					loop % contours[A_Index-1].dims*contours[A_Index-1].rows
						a .= numget(data+0, (A_Index-1)*4, "int") "-"
					a := SubStr(a, 1, -1) "`n"
				}
			msgbox % a
			*/
			/*
			cv.drawContours(img, contours, -1, arr, 3)
			cv.imshow(ImgObj["ImagePath"iIndex], img)
			;cv.imwrite("D:\Dl_Files\Bok\digibok_11111111111111\pages_raw\Test.jpg", img) 
			cv.waitKey()
			cv.destroyAllWindows()
			; unregister com
			DllCall("autoit_opencv_com460.dll\DllInstall", "int", 0, "wstr", A_IsAdmin = 0 ? "user" : "", "cdecl")
			DllCall("FreeLibrary", "ptr", hOpencv)
			DllCall("FreeLibrary", "ptr", hOpencvCom)
			*/
			/*
				# Calculate skew angle of an image
				def getSkewAngle(cvImage) -> float:
					# Prep image, copy, convert to gray scale, blur, and threshold
					newImage = cvImage.copy()
					gray = cv2.cvtColor(newImage, cv2.COLOR_BGR2GRAY)
					blur = cv2.GaussianBlur(gray, (9, 9), 0)
					thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]

					# Apply dilate to merge text into meaningful lines/paragraphs.
					# Use larger kernel on X axis to merge characters into single line, cancelling out any spaces.
					# But use smaller kernel on Y axis to separate between different blocks of text
					kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (30, 5))
					dilate = cv2.dilate(thresh, kernel, iterations=5)

					# Find all contours
					contours, hierarchy = cv2.findContours(dilate, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
					contours = sorted(contours, key = cv2.contourArea, reverse = True)

					# Find largest contour and surround in min area box
					largestContour = contours[0]
					minAreaRect = cv2.minAreaRect(largestContour)

					# Determine the angle. Convert it to the value that was originally used to obtain skewed image
					angle = minAreaRect[-1]
					if angle < -45:
						angle = 90 + angle
					return -1.0 * angle
			*/
		}
	If (Action = "Grid")
		{
			Thread, Priority, 1
			hdc := CreateCompatibleDC()
			hbm := CreateDIBSection(ImgObj["Img_W"], ImgObj["Img_H"], hdc, 32)
			obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc)
			Gdip_SetSmoothingMode(G, MC_Smoothing-1)
			pColour := (MC_GridColour = "Black") ? 0x77000000 : ((MC_GridColour = "Red") ? 0xffff0000 : 0xffffffff)
			pPen := Gdip_CreatePen(pColour, MC_GridThickness) ; Red = 0xffff0000 | Orange = 0xFFFAAA3C | Transparent Black : 0x77000000
			VarX := 0, VarY := 0
			Loop
				{ 
					Gdip_DrawLine(G, pPen, 0, VarX, ImgObj["Img_W"], VarX)
					VarX += 99.3
				}Until (VarX >= ImgObj["Img_h"])
			Loop
				{
					Gdip_DrawLine(G, pPen, VarY, 0, VarY, ImgObj["Img_H"])
					VarY += 99.3
				}Until (VarY >= ImgObj["Img_W"])
			Gdip_DeletePen(pPen)
			UpdateLayeredWindow(Image2, hdc, 0, 0, ImgObj["Img_W"], ImgObj["Img_H"])
			SelectObject(hdc, obm), DeleteObject(hbm)
			DeleteDC(hdc), Gdip_DeleteGraphics(G)
			Return True
		}
	If (Action = "Crop")
		{
			if (ImgObj["x1"] = ImgObj["x2"] or ImgObj["y1"] = ImgObj["y2"]){
					Return False
				}
			Imgx1 := ImgObj["x1"] - ImgObj["edgex1"] ; Corners relative to Parent
			Imgx2 := ImgObj["x2"] - ImgObj["edgex1"]
			Imgy1 := ImgObj["y1"] - ImgObj["edgey1"]
			Imgy2 := ImgObj["y2"] - ImgObj["edgey1"]
			Cropinfo := Object()
			; PageImprover rotation
			If (Pi_Mode = "L & R on One Image"){
					if (Angle = 0){
							x1 := Round(Imgx1/ImgObj["Img_P"]) ; Upscale
							x2 := Round(Imgx2/ImgObj["Img_P"])
							y1 := Round(Imgy1/ImgObj["Img_P"]) ; Top Border
							y2 := Round(Imgy2/ImgObj["Img_P"]) ; Lower Border
							Cropinfo["L.TopBorder"] := y1
							Cropinfo["L.BottomBorder"] := iHeight - y2
							Cropinfo["R.TopBorder"] := y1
							Cropinfo["R.BottomBorder"] := iHeight - y2
					}Else{
							Scale := (TWidth/ImgObj["Img_W"]) 
							x1 := Round(Imgx1*Scale) ; Upscale
							x2 := Round(Imgx2*Scale)
							y1 := Round(Imgy1*Scale) ; Top Border
							y2 := Round(Imgy2*Scale) ; Lower Border
							rPos := Round((x2*2)*Sin((Angle*(3.141592653589793/180))))
							Gdip_GetRotatedDimensions((iWidth*0.6), iHeight, Angle, PiWidth, PiHeight)
							Cropinfo["L.TopBorder"] := y1
							Cropinfo["L.BottomBorder"] := Round(PiHeight - y2)
							Cropinfo["R.TopBorder"] := Round(y1 - rPos)
							Cropinfo["R.BottomBorder"] := Round(PiHeight - y2 + rpos)
							; Fix Later
						}
					Cropinfo["Width"] := x2 - x1
					Cropinfo["Height"] := y2 - y1
					Cropinfo["PPI"] := ImgObj["PPI"]
					MC_Obj[ImgObj["ImagePath"]] := Cropinfo
					iFormat := CalcSize(3, Cropinfo["Width"], Cropinfo["Height"], ImgObj["PPI"])
					MsgBox, 262179, % Appname . " - " . ImgObj["ImagePath"], % "Format: " . iFormat . "  [ W: " . MC_Obj[(ImgObj["ImagePath"]), "Width"] . " | H: " . MC_Obj[(ImgObj["ImagePath"]), "Height"] . " | PPI: " . ImgObj["PPI"] " ]"
							. "`nU.border: L " . MC_Obj[(ImgObj["ImagePath"]), "L.TopBorder"] . "  |  R " . MC_Obj[(ImgObj["ImagePath"]), "R.TopBorder"]
							. "`nL.border: L " . MC_Obj[(ImgObj["ImagePath"]), "L.BottomBorder"] . "  |  R " . MC_Obj[(ImgObj["ImagePath"]), "R.BottomBorder"]
							. "`n`nSave?"
					IfMsgBox Yes
						{
							Gui, 1:Default
							FocusedRowNumber := LV_GetNext(0, "F")
							LV_Modify(FocusedRowNumber, Folderrow,,, iFormat)
							Gosub, View_Close
							Return True
						}
					IfMsgBox No
						{
							MC_Obj.Delete(ImgObj["ImagePath"])
							Return False
						}
					IfMsgBox Cancel
						{
							MC_Obj.Delete(ImgObj["ImagePath"])
							Gosub, View_Close
							Return False
						}
				}Else{
					MsgBox, 262209, % Appname . " - " . ImgObj["ImagePath"], Only avalible with L & R on One Image.
					IfMsgBox Cancel
						{
							MC_Obj.Delete(ImgObj["ImagePath"])
							Gosub, View_Close
							Return False
						}
					}
		}
	If (Action = "Next")
		{
			Thread, Priority, 1
			;WinGet, OutputVar, MinMax, % "ahk_id" . Gui1
			pBitmap := Gdip_CreateBitmapFromFile(ImgObj["ImagePath"iIndex]), Angle := 0
			If !pBitmap
			Return False
			ImgObj["PPI"] := Gdip_GetImageHorizontalResolution(pBitmap)
			iWidth := Gdip_GetImageWidth(pBitmap)
			iHeight := Gdip_GetImageHeight(pBitmap)
			SysGet, M_, MonitorWorkArea
			ImgObj["Img_P"] := (M_Bottom-95)/iHeight
			ImgObj["Img_W"] := ((iWidth*ImgObj["Img_P"]) > M_Right) ? (M_Right-95) : (iWidth*ImgObj["Img_P"])
			ImgObj["Img_P"] := ((iWidth*ImgObj["Img_P"]) > M_Right) ? ImgObj["Img_W"]/iWidth : (M_Bottom-95)/iHeight
			ImgObj["Img_H"] := (iHeight*ImgObj["Img_P"])
			hdc := CreateCompatibleDC()
			hbm := CreateDIBSection(w := ImgObj["Img_W"], h := ImgObj["Img_H"], hdc, 32)
			obm := SelectObject(hdc, hbm)
			G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
			Gdip_DrawImage(G, pBitmap,0,0, ImgObj["Img_W"], ImgObj["Img_H"], 0, 0, iWidth, iHeight)
			GuiControl Image1: Move, iPic, % "NA w" . ImgObj["Img_W"] . " h" . ImgObj["Img_H"]
			Gui, 1: Show, % "Restore xCenter y0 h" . (ImgObj["Img_H"]+43) . " w" . (ImgObj["Img_W"]+20), % Appname ; . " - " . ImgObj["ImagePath"iIndex]
			UpdateLayeredWindow(Image1, hdc, 10, 10, ImgObj["Img_W"], ImgObj["Img_H"])
			SB_SetText(A_Space . iIndex . "/" . iMaxIndex . "  |  " . ImgObj["ImageName"iIndex] . "  |  " . iWidth . "x" . IHeight . "  |  " . CalcSize(3, iWidth, IHeight, ImgObj["PPI"]) . "  |  " . ImgObj["FileSize"iIndex], 1, 1)
			SelectObject(hdc, obm), DeleteObject(hbm)
			DeleteDC(hdc), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
			If Gridcb
			ImageViewer("Grid", ImgObj)
			;ImageViewer("Deskew", ImgObj)
			Return True

			View_NextImage:
				If (iMaxIndex = 1)
				Return
				If(iIndex = iMaxIndex)
				iIndex := 1
				Else
				iIndex++
				ImageViewer("Next", ImgObj)
				Return

			View_PreviousImage:
				If (iMaxIndex = 1)
				Return
				If (iIndex = 1)
				iIndex := % iMaxIndex
				Else
				iIndex--
				ImageViewer("Next", ImgObj)
				Return

			View_FirstImage:
				If (iMaxIndex = 1)
				Return
				If (iIndex > 1){
						iIndex := 1
						ImageViewer("Next", ImgObj)
					}
				Return

			View_LastImage:
				If (iMaxIndex = 1)
				Return
				If (iIndex < iMaxIndex){
						iIndex := % iMaxIndex
						ImageViewer("Next", ImgObj)
					}
				Return
		}
	If (Action = "Rotate")
		{
			Thread, Priority, 1
			pBitmap := Gdip_CreateBitmapFromFile(ImgObj["ImagePath"iIndex])
			If !pBitmap
			Return False
			If (Rotation != ""){
					If (Option = 0){
							Angle := (Rotation = "Clockwise") ? (Angle += MC_Angle) : (Angle -= MC_Angle)
							if (Angle < 0){
									Angle := 359.9
								}
							If (Angle > 359.9){
									Angle := 0
								}
						}
					If (Option = 90){
							Angle := (Rotation = "Clockwise") ? (Angle >= 270) ? 0 : ((Angle >= 180 ? 270 : (Angle >= 90 ? 180 : 90 ))) : (Angle >= 270) ? 180 : ((Angle >= 180 ? 90 : (Angle >= 90 ? 0 : 270 )))
						}
					If (Option = 180){
							Angle := (Angle >= 180 ? 0 : 180)
						}
				}
			;iWidth := Gdip_GetImageWidth(pBitmap)
			;iHeight := Gdip_GetImageHeight(pBitmap)
			If (RotationType1 = "Center")
				{
					RDeg := Angle/180*3.14+aTan(ImgObj["Img_H"]/ImgObj["Img_W"])
					R:=(((ImgObj["Img_W"]//2)**2)+((ImgObj["Img_H"]//2)**2))**0.5
					TX := (R*cos(RDeg)-(ImgObj["Img_w"]/2))
					TY := (R*sin(RDeg)-(ImgObj["Img_H"]/2))
					hbm := CreateDIBSection(ImgObj["Img_W"], ImgObj["Img_H"])
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
					Gdip_TranslateWorldTransform(G, -TX, -TY), Gdip_RotateWorldTransform(G, Angle)
					Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"], ImgObj["Img_H"])
					Gdip_ResetWorldTransform(G)
					UpdateLayeredWindow(Image1, hdc, 10, 10, ImgObj["Img_W"], ImgObj["Img_H"])
					SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
					Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
					Return True
				}
			If (RotationType1 = "PageImprover")
				{
					Gdip_GetRotatedDimensions(ImgObj["Img_W"], ImgObj["Img_H"], Angle, RWidth, RHeight)
					Gdip_GetRotatedDimensions(iWidth, iHeight, Angle, TWidth, THeight)
					hbm := CreateDIBSection(RWidth, RHeight)
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
					ScaleW := ImgObj["Img_W"] > RWidth ? (ImgObj["Img_W"]/RWidth) : (RWidth/ImgObj["Img_W"])
					ScaleH := ImgObj["Img_H"] > RHeight ? (ImgObj["Img_H"]/RHeight) : (RHeight/ImgObj["Img_H"])
					If Angle Between 0 and 90
						{
							Gdip_GetRotatedTranslation(ImgObj["Img_W"]/ScaleH, ImgObj["Img_H"]/ScaleW, Angle, xTranslation, yTranslation)
						}
					Else If Angle Between 90 and 270
						{
							Gdip_GetRotatedTranslation(ImgObj["Img_W"]/ScaleW, ImgObj["Img_H"]/ScaleW, Angle, xTranslation, yTranslation)
						}
					Else If Angle Between 270 and 360
						{
							Gdip_GetRotatedTranslation(ImgObj["Img_W"]/ScaleW, ImgObj["Img_H"]/ScaleH, Angle, xTranslation, yTranslation)
						}
					Gdip_TranslateWorldTransform(G, xTranslation, yTranslation)
					Gdip_RotateWorldTransform(G, Angle)
					Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"]/ScaleW, ImgObj["Img_H"]/ScaleW,0,0, iWidth, iHeight)
					Gdip_ResetWorldTransform(G)
					UpdateLayeredWindow(Image1, hdc, 10, 10, Round(RWidth/ScaleW), Round(RHeight/ScaleW))
					SB_SetText(A_Space . iIndex . "/" . iMaxIndex . "  |  " . ImgObj["ImageName"iIndex] . "  |  " . TWidth . "x" . THeight . " - " . Round(Angle,1) . Chr(186) . "  |  " . CalcSize(3, iWidth, IHeight, ImgObj["PPI"]) . "  |  " . ImgObj["FileSize"iIndex], 1, 1)
					SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
					Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
					Return True
				}
			If (RotationType2 = "Horizontal") ; Mirror-reversal across a Horizontal axis.
				{
					Angle := 0
					hbm := CreateDIBSection(ImgObj["Img_W"], ImgObj["Img_H"])
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
					Gdip_ScaleWorldTransform(G, -1, 1), Gdip_TranslateWorldTransform(G, -ImgObj["Img_W"], 0)
					SB_SetText(A_Space . iIndex . "/" . iMaxIndex . "  |  " . ImgObj["ImageName"iIndex] . "  |  " . iWidth . "x" . IHeight . "  |  " . CalcSize(3, iWidth, IHeight, ImgObj["PPI"]) . "  |  " . ImgObj["FileSize"iIndex], 1, 1)
				}
			If (RotationType2 = "Vertical") ; Mirror-reversal across a vertical axis
				{
					Angle := 0
					hbm := CreateDIBSection(ImgObj["Img_W"], ImgObj["Img_H"])
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetPixelOffsetMode(G, MC_PixelOffset-1), Gdip_SetSmoothingMode(G, MC_Smoothing-1), Gdip_SetInterpolationMode(G, MC_Interpolation-1)
					Gdip_ScaleWorldTransform(G, 1, -1), Gdip_TranslateWorldTransform(G, 0, -ImgObj["Img_H"])
					SB_SetText(A_Space . iIndex . "/" . iMaxIndex . "  |  " . ImgObj["ImageName"iIndex] . "  |  " . iWidth . "x" . IHeight . "  |  " . CalcSize(3, iWidth, IHeight, ImgObj["PPI"]) . "  |  " . ImgObj["FileSize"iIndex], 1, 1)
				}
			Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"], ImgObj["Img_H"])
			Gdip_ResetWorldTransform(G)
			UpdateLayeredWindow(Image1, hdc, 10, 10, ImgObj["Img_W"], ImgObj["Img_H"])
			SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
			Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
			Return True
		}
	If (Action = "SelectRect"){
			Loop, 4
				{
					Gui, Temp%A_Index%: -Caption +ToolWindow +AlwaysOnTop -DPIScale
					Gui, Temp%A_Index%: Color, % MC_SelectionColour
				}
			Hotkey, *LButton, View_RectReturn, On ; Disable LButton.
			KeyWait, LButton, D ; Wait for user to press LButton.
			MouseGetPos, originx, originy ; Get initial coordinates.
			SetTimer, View_UpdateRect, 5 ; Set timer for updating the selection rectangle.
			KeyWait, LButton  ; Wait for user to release LButton.
			Hotkey, *LButton, Off  ; Re-enable LButton.
			SetTimer, View_UpdateRect, Off  ; Disable timer.
			Loop, 4 ; Destroy "selection rectangle" GUIs.
				{
					Gui, Temp%A_Index%: Destroy
				}
			return

			View_UpdateRect:
				ImgObj["R"] := MC_SelectionThickness ; Rectangle thickness
				MouseGetPos, x, y
				if (x = originx) && (y = originy){
						ImgObj["Stop"] := 1
						Return
					}
				ImgObj["Stop"] := 0
				ImgObj["y1"] := (y < originy) ? y : originy, ImgObj["y2"] := (y < originy) ? originy : y
				ImgObj["x1"] := (x < originx) ? x : originx, ImgObj["x2"] := (x < originx) ? originx : x
				ImgObj["x1"] := ImgObj["x1"] < ImgObj["edgex1"] ? ImgObj["edgex1"] : ImgObj["x1"]
				ImgObj["x2"] := ImgObj["x2"] > ImgObj["edgex2"] ? ImgObj["edgex2"] : ImgObj["x2"]
				ImgObj["y1"] := ImgObj["y1"] < ImgObj["edgey1"] ? ImgObj["edgey1"] : ImgObj["y1"]
				ImgObj["y2"] := ImgObj["y2"] > ImgObj["edgey2"] ? ImgObj["edgey2"] : ImgObj["y2"]
				Gui, Temp1:Show, % "NA X" . ImgObj["x1"] . " Y" . ImgObj["y1"] . " W" . ImgObj["x2"]-ImgObj["x1"] . " H" . ImgObj["R"]
				Gui, Temp2:Show, % "NA X" . ImgObj["x1"] . " Y" . ImgObj["y2"]-ImgObj["R"] . " W" . ImgObj["x2"]-ImgObj["x1"] . " H" . ImgObj["R"]
				Gui, Temp3:Show, % "NA X" . ImgObj["x1"] . " Y" . ImgObj["y1"] . " W" . ImgObj["R"] . " H" . ImgObj["y2"]-ImgObj["y1"]
				Gui, Temp4:Show, % "NA X" . ImgObj["x2"]-ImgObj["R"] . " Y" . ImgObj["y1"] . " W" . ImgObj["R"] . " H" . ImgObj["y2"]-ImgObj["y1"]
				Return

			View_RectReturn:
				return
		}
}

;----------------------------------------------------------------------------

; Label:				View_Raw
; Description:			Gui1 menu view->open raw. DisableControl = Block Drag&Drop. Guictrls2 = Show/Hide menu and controls. Saves position of Gui1

View_Raw:
	Gui, +OwnDialogs
	Disablecontrol := 1
	Guictrls2(0, 1)
	WinGetPos, xGui1, yGui1, wGui1, hGui1, % "ahk_id" . Gui1
	If (!ImageViewer("Create", ImgObj, "Raw")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_OutPut
; Description:			Gui1 menu view->open output.

View_OutPut:
	Gui, +OwnDialogs
	Disablecontrol := 1, DisableRect := 1
	Guictrls2(0, 1)
	WinGetPos, xGui1, yGui1, wGui1, hGui1, % "ahk_id" . Gui1
	If (!ImageViewer("Create", ImgObj, "Output")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Close
; Description:			Gui1 menu view->close. Destroy gui's and update menu/controls/vars. Moves AutoPI to the saved position.

View_Close:
	Gui, 1:Default
	SB_SetText("", 1, 1)
	Gdip_DisposeImage(pBitmap)
	;gdip_Shutdown(pToken)
	Guictrls2(1, 0)
	ImgObj := "", GridcB := "", Disablecontrol := 0, DisableRect := 0, SB_1 := 35
	GUI, Image1: Destroy
	GUI, Image2: Destroy
	If (List_AutoHDR = 1){
			WinMove, % "ahk_id" . Gui1,, xGui1, yGui1, wGui1, hGui1
			LV_Update("AutoHDR")
	}Else{
			WinMove, % "ahk_id" . Gui1,, xGui1, yGui1, wGui1, hGui1
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Grid
; Description:			Gui1 menu view->grid

View_Grid:
	Menu, CCCC, Togglecheck, &Grid`tShift+G
	if Gridcb
		{
			Gui, Image2:Hide
			Gridcb := 0
		}
	Else
		{
			Gui, Image2:Show
			ImageViewer("Grid", ImgObj)
			Gridcb := 1
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_gPicture_1
; Description:			Picture gLabel for Image1 GUI.

View_gPicture_1:
	Gui, +OwnDialogs
	If DisableRect
	Return
	ControlGetPos, xImg, yImg, wImg, hImg,, % "ahk_id" . Image1
	WinGetPos, xParent, yParent, wParent, hParent, % "ahk_id" . Gui1
	ImgObj["edgex1"] := xParent + xImg
	ImgObj["edgey1"] := yParent + yImg
	ImgObj["edgex2"] := ImgObj["edgex1"] + wImg
	ImgObj["edgey2"] := ImgObj["edgey1"] + hImg
	ImageViewer("SelectRect", ImgObj)
	if (ImgObj["Stop"] = 1)
	Return
	ImageViewer("Crop", ImgObj)
	Return

;----------------------------------------------------------------------------

; Label:				View_RotateClockwise
; Description:			Gui1 menu view->rotate - right

View_RotateClockwise:
	;ImageViewer("Rotate", ImgObj,, "Clockwise" , "0,0")
	If (!ImageViewer("Rotate", ImgObj,, "Clockwise" , "PageImprover")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_RotateCounterClockwise
; Description:			Gui1 menu view->rotate - left

View_RotateCounterClockwise:
	;ImageViewer("Rotate", ImgObj,, "CounterClockwise", "0,0")
	If (!ImageViewer("Rotate", ImgObj,, "CounterClockwise", "PageImprover")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Rotate90right
; Description:			Gui1 menu view->rotate - 90 right

View_Rotate90right:
	If (!ImageViewer("Rotate", ImgObj, 90, "Clockwise", "PageImprover")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Rotate90right
; Description:			Gui1 menu view->rotate - 90 left

View_Rotate90Left:
	If (!ImageViewer("Rotate", ImgObj, 90, "CounterClockwise", "PageImprover")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Rotate90right
; Description:			Gui1 menu view->rotate - 180

View_Rotate180:
	If (!ImageViewer("Rotate", ImgObj, 180, "Clockwise", "PageImprover")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Horizontal
; Description:			Gui1 menu view->flip->horizontal. (Flipped)

View_Horizontal:
	If (!ImageViewer("Rotate", ImgObj,,,,"Horizontal")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				View_Vertical
; Description:			Gui1 menu view->flip->vertical. (Flopped)

View_Vertical:
	If (!ImageViewer("Rotate", ImgObj,,,, "Vertical")){
			GoSub, View_Close
		}
	Return

;----------------------------------------------------------------------------

; Label:				TableView
; Description:			Events triggered through actions in Gui3 List View.
;
; Notes:				RMB opens menu. Alt+1 opens TableEntry. Delete key removes selected rows, Shift+Delete clears list.

TableView:
	Gui +OwnDialogs
	If (A_GuiEvent = "ColClick")
		{
			LV_SortArrow(List2hwnd, A_EventInfo)
		}
	if (A_GuiEvent = "Rightclick"){
			Menu, MenuTableView, Show
			Return
		}
	if (A_GuiEvent = "K"){
			CtrlA := GetKeyState("Ctrl","P")
			ShiftDel := GetKeyState("Shift","P")
			Alt1 := GetKeyState("Alt","P")
			If (Alt1 = 1){
					if (A_EventInfo = 49){
							GoSub TableEntry
							Return
						}
				}
			Else if (ShiftDel = 1){
					if (A_EventInfo = 0x2E){
							GoSub Clear_From_TableView
							Return
						}
				}
			Else if (A_EventInfo = 0x2E){
					LV_DeleteRows("Selected")
					Return
				}
			Else if (CtrlA = 1){
					if (A_EventInfo = 65){
							LV_Modify(0, "Select")
						}
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				Delete_Selected_From_Tableview
; Description:			Delete selected row(s) from GUI3 List View.
;
; Trigger:				Remove. left-click menu in GUI3 list view.

Delete_Selected_From_Tableview:
	Gui, 3:Default
	LV_DeleteRows("Selected")
	Gui, 1:Default
	Return

;----------------------------------------------------------------------------

; Label:				Clear_From_TableView
; Description:			Deletes everything from GUI3 List View and sets a new rowcount.
;
; Trigger:				Delete All. left-click menu in GUI3 list view.

Clear_From_TableView:
	Gui +OwnDialogs
	Gui, 3:Default
	TableRow := LV_GetCount()+1
	If (TableRow != 1){
			MsgBox,	262180, %Appname% - Table, Are you sure you want to clear the table?
			IfMsgBox Yes
				{
					LV_Delete()
					TableRow := LV_GetCount()+1
				}
		}
	Gui, 1:Default
	Return

;----------------------------------------------------------------------------
; GUI Related
;----------------------------------------------------------------------------

; Label:				AC_Submit
; Description:			Stores values for autocrop manual width and height variables; Millimeter, Percent and pixel.

AC_Submit:
	Gui, 3:Submit, NoHide
	If (AC_Manual_sDDL = "Millimeter"){
			AC_WidthAdjust_Millimeter := % AC_WidthAdjust
			AC_HeightAdjust_Millimeter := % AC_HeightAdjust
		}
	If (AC_Manual_sDDL = "Percent"){
			AC_WidthAdjust_Percent := % AC_WidthAdjust
			AC_HeightAdjust_Percent := % AC_HeightAdjust
		}
	If (AC_Manual_sDDL = "Pixel"){
			AC_WidthAdjust_Pixel := % AC_WidthAdjust
			AC_HeightAdjust_Pixel := % AC_HeightAdjust
		}
	Return

;----------------------------------------------------------------------------

; Label:				AC_Manual_DDL
; Description:			Settings for each choice in manual autocrop DropDownList.

AC_Manual_DDL:
	Gui, 3:Submit, NoHide
	if (AC_Manual_sDDL = "Millimeter"){
			;	UpDown Manual Wdith Adjustment.
			UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Millimeter"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Millimeter"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Millimeter"] ;	Wdith Adjustment.
			GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Millimeter
			;	UpDown Manual Height Adjustment.
			UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Millimeter"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Millimeter"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Millimeter"] ;	Height Adjustment.
			GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Millimeter
		}
	if(AC_Manual_sDDL = "Percent"){
			;	UpDown Manual Wdith Adjustment.
			UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Percent"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Percent"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Percent"] ;	Wdith Adjustment.
			GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Percent
			;	UpDown Manual Height Adjustment.
			UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Percent"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Percent"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Percent"] ;	Height Adjustment.
			GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Percent
		}
	If (AC_Manual_sDDL = "Pixel"){
			;	UpDown Manual Wdith Adjustment.
			UpDown235_fIncrement := DefaultValue["UpDown235_fIncrement_Pixel"], UpDown235_fRangeMin := DefaultValue["UpDown235_fRangeMin_Pixel"], UpDown235_fRangeMax := DefaultValue["UpDown235_fRangeMax_Pixel"] ;	Wdith Adjustment.
			GuiControl,3:, AC_WidthAdjust, % AC_WidthAdjust_Pixel
			;	UpDown Manual Height Adjustment.
			UpDown238_fIncrement := DefaultValue["UpDown238_fIncrement_Pixel"], UpDown238_fRangeMin := DefaultValue["UpDown238_fRangeMin_Pixel"], UpDown238_fRangeMax := DefaultValue["UpDown238_fRangeMax_Pixel"] ;	Height Adjustment.
			GuiControl,3:, AC_HeightAdjust, % AC_HeightAdjust_Pixel
		}
	Return

;----------------------------------------------------------------------------

; Label:				Always_On_Top
; Description:			GUI 1 always on top. Toggle on/off

Always_On_Top:
	WinSet, AlwaysOnTop, Toggle, A
	Menu, EEEE, Togglecheck, On &top`tF11
	return

;----------------------------------------------------------------------------

; Label:				Always_On_Top_2
; Description:			Gui 2 Always on top. Checkbox value: 0 or 1
/*
Always_On_Top_2:
	Gui, Submit, NoHide
		if(OnTop_2==1)
			Gui, +AlwaysOnTop
		else if(OnTop_2==0)
			Gui, -AlwaysOnTop
	return
*/

;----------------------------------------------------------------------------

; Label:				AutoPi_Document
; Description:			GUI 1 Menu item. Help->Documentation. Opens PDF.

AutoPi_Document:
	Gui +OwnDialogs
	if !FileExist("Documentation.pdf"){
			MsgBox, 262160, %Appname% - Error, Cant find:`n%A_WorkingDir%\Documentation.pdf
		}
	Else if FileExist("Documentation.pdf"){
			Run, Documentation.pdf,, UseErrorLevel
			if (ErrorLevel){
				MsgBox, 262160, %Appname% - Error, Could not open Documentation.pdf
				}
		}
	return

;----------------------------------------------------------------------------

; Label:				AutoPi_Training_Booklet
; Description:			GUI 1 Menu item. Help->Training Booklet. Opens PDF.

AutoPi_Training_Booklet:
	Gui +OwnDialogs
	if !FileExist("TrainingBooklet.pdf"){
			MsgBox, 262160, %Appname% - Error, Cant find:`n%A_WorkingDir%\TrainingBooklet.pdf
		}
	Else if FileExist("TrainingBooklet.pdf"){
			Run, TrainingBooklet.pdf,, UseErrorLevel
			if (ErrorLevel){
				MsgBox, 262160, %Appname% - Error, Could not open TrainingBooklet.pdf
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				About_AutoPi
; Description:			GUI 1 menu item. Help->About.

About_AutoPi:
	Gui +OwnDialogs
	MsgBox,262208,% Appname . A_Space . Version, % "Automation script for Page Improver.`n`nVersion: " Version "`nDate: " Date "`nBy: " Createdby
	Return

;----------------------------------------------------------------------------

; Class:				AutoPiLimit
; Description:			Countdown timer in statusbar. Used while counting images with Progress->Images->Time limit On.

class AutoPiLimit {
    __New(){
        this.interval := 1000
        this.count := (Seconds*MaxDuration)
        this.Timepiece := ObjBindMethod(this, "Tick")
    }
    Start(){
        Timepiece := this.Timepiece
        SetTimer % Timepiece, % this.interval
    }
    Stop(){
		if (this.Timepiece != ""){
				Timepiece := this.Timepiece, this.Timepiece := ""
				SetTimer % Timepiece, Delete
				SB_SetText("",2,1)
			}
    }
    Tick(){
		SB_SetText(DeadlineActiontaken . "s" . " in " . Time(--This.Count),2,1)
    }
}

;----------------------------------------------------------------------------

; Function:				CalcSize
; Description:			Different options for converting mm to pixels or vice versa. Calculate percentage decrease. etc

CalcSize(Option, Width, Height, PPI:=0){
	; 1 inch = 25.4mm
	If (Option = 1) ; Pixels = ( PPI / 25.4 ) * mm (FormatList. TableRead option 1)
		{
			wPX := Round((PPI/25.4)*Width)
			hPX := Round((PPI/25.4)*Height)
			Return wPX . hPX
		}
	If (Option = 2) ; mm = ( pixels * 25.4 ) / PPI
		{
			wMM := Floor((Width*25.4)/PPI)
			hMM := Floor((Height*25.4)/PPI)
			RoundedwMM := wMM+(5-Mod(wMM,5))
			RoundedhMM := hMM+(5-Mod(hMM,5))
			Return RoundedwMM . RoundedhMM
		}
	If (Option = 3) ; TableInput
		{
			wMM := Floor((Width*25.4)/PPI)
			hMM := Floor((Height*25.4)/PPI)
			RoundedwMM := wMM+(5-Mod(wMM,5))
			RoundedhMM := hMM+(5-Mod(hMM,5))
			Return RoundedwMM . "x" . RoundedhMM . "mm"
		}
	If (Option = 4) ; TableInput - Resize.W & Resize.H
		{
			rWH := (((Width-Height)/Width)*100)
			Return rWH
		}
	If (Option = 5) ; Pixels = ( PPI / 25.4 ) * mm (Manual Autocrop Millimeter)
		{
			wPX := Round((PPI/25.4)*Width)
			hPX := Round((PPI/25.4)*Height)
			Return wPX . "|" . hPX
		}
}

;----------------------------------------------------------------------------

; Function:				Check
; Description:			Checks if folder is empty

Check(Folder){
   Loop, Files, %Folder%\*.*, F
      return 1
   return 0
}

;----------------------------------------------------------------------------

; Label:				Checkboxes_N | Checkboxes_PD | Checkboxes_C
; Description:			Switch checkboxes. Activated by GUI 1 Menu. Settings / Checkboxes.

Checkboxes_C:
	GuiControl,3:ChooseString, CheckboxProperty, Checked
	Gosub, List_Update
	Return
Checkboxes_N:
	GuiControl,3:ChooseString, CheckboxProperty, None
	Gosub, List_Update
	Return
Checkboxes_PD:
	GuiControl,3:ChooseString, CheckboxProperty, Percentage difference
	Gosub, List_Update
	Return

;----------------------------------------------------------------------------

; Function:				CustomButtons
; Description:			Contains settings for gen 3 buttons created with GDI+.

CustomButtons(Button){
	If (Button = "Start")
		{
			StartButton := {}
			StartButton.Default := {}
			StartButton.Hover := {}
			StartButton.Pressed := {}
			;Default
			StartButton.Default.W := 200, StartButton.Default.H := 45, StartButton.Default.Text := "Start", StartButton.Default.Font := "Segoe UI", StartButton.Default.FontOptions := "Bold Center vCenter", StartButton.Default.FontSize := 11 
			StartButton.Default.TextBottomColor2 := 0x0002112F, StartButton.Default.TextTopColor1 := 0xFFFFFFFF, StartButton.Default.TextTopColor2 := 0xFFFFFFFF, StartButton.Default.TextOffsetX := 0, StartButton.Default.TextOffsetY := 0, StartButton.Default.TextOffsetW := 0, StartButton.Default.TextOffsetH := 0
			StartButton.Default.BackgroundColor := 0xFFFFFFFF, StartButton.Default.ButtonOuterBorderColor := 0xFF009E60
			StartButton.Default.ButtonCenterBorderColor := 0xFF009E60, StartButton.Default.ButtonInnerBorderColor1 := 0xFF009E60, StartButton.Default.ButtonInnerBorderColor2 := 0xFF009E60
			StartButton.Default.ButtonMainColor1 := 0xFF009E60, StartButton.Default.ButtonMainColor2 := 0xFF009E60
			StartButton.Default.ButtonAddGlossy := 1, StartButton.Default.GlossTopColor := 0x1111EB46, StartButton.Default.GlossTopAccentColor := "0533AD7D" , StartButton.Default.GlossBottomColor := "3311EB46"
			;Hover
			StartButton.Hover.W := 200, StartButton.Hover.H := 45, StartButton.Hover.Text := "Start", StartButton.Hover.Font := "Segoe UI", StartButton.Hover.FontOptions := "Bold Center vCenter", StartButton.Hover.FontSize := 11
			StartButton.Hover.TextBottomColor2 := 0x0002112F, StartButton.Hover.TextTopColor1 := 0xFFFFFFFF, StartButton.Hover.TextTopColor2 := 0xFFFFFFFF, StartButton.Hover.TextOffsetX := 0, StartButton.Hover.TextOffsetY := 0, StartButton.Hover.TextOffsetW := 0, StartButton.Hover.TextOffsetH := 0
			StartButton.Hover.BackgroundColor := 0xFFFFFFFF, StartButton.Hover.ButtonOuterBorderColor := 0xFF14A15E, StartButton.Hover.ButtonCenterBorderColor := 0xFF14A15E, StartButton.Hover.ButtonInnerBorderColor1 := 0xFF14A15E, StartButton.Hover.ButtonInnerBorderColor2 := 0xFF14A15E
			StartButton.Hover.ButtonMainColor1 := 0xFF14A15E, StartButton.Hover.ButtonMainColor2 := 0xFF14A15E
			StartButton.Hover.ButtonAddGlossy := 1, StartButton.Hover.GlossTopColor := 0x1111EB46, StartButton.Hover.GlossTopAccentColor := "05FFFFFF" , StartButton.Hover.GlossBottomColor := "3311EB46"
			;Pressed
			StartButton.Pressed.W := 200, StartButton.Pressed.H := 45, StartButton.Pressed.Text := "Start", StartButton.Pressed.Font := "Segoe UI", StartButton.Pressed.FontOptions := "Bold Center vCenter", StartButton.Pressed.FontSize := 11
			StartButton.Pressed.TextBottomColor2 := 0x0002112F, StartButton.Pressed.TextTopColor1 := 0xFFFFFFFF, StartButton.Pressed.TextTopColor2 := 0xFFFFFFFF, StartButton.Pressed.TextOffsetX := 0, StartButton.Pressed.TextOffsetY := 0, StartButton.Pressed.TextOffsetW := 0, StartButton.Pressed.TextOffsetH := -2
			StartButton.Pressed.BackgroundColor := 0xFFFFFFFF, StartButton.Pressed.ButtonOuterBorderColor := 0xFFFFFFFF, StartButton.Pressed.ButtonCenterBorderColor := 0xFF009E60, StartButton.Pressed.ButtonInnerBorderColor1 := 0xFF003E00, StartButton.Pressed.ButtonInnerBorderColor2 := 0xFF003E00
			StartButton.Pressed.ButtonMainColor1 := 0xFF009E60, StartButton.Pressed.ButtonMainColor2 := 0xFF009E60
			StartButton.Pressed.ButtonAddGlossy := 0
			return StartButton
		}
	If (Button = "Stop")
		{
			StopButton := {}
			StopButton.Default := {}
			StopButton.Hover := {}
			StopButton.Pressed := {}
			;	Default
			StopButton.Default.W := 125, StopButton.Default.H := 45, StopButton.Default.Text := "Stop" , StopButton.Default.Font := "Segoe UI" , StopButton.Default.FontOptions := "Bold Center vCenter", StopButton.Default.FontSize := 11
			StopButton.Default.TextBottomColor2 := 0x0002112F, StopButton.Default.TextTopColor1 := 0xFFFFFFFF , StopButton.Default.TextTopColor2 := 0xFFFFFFFF, StopButton.Default.TextOffsetX := 0, StopButton.Default.TextOffsetY := 0, StopButton.Default.TextOffsetW := 0, StopButton.Default.TextOffsetH := 0
			StopButton.Default.BackgroundColor := 0xFFFFFFFF, StopButton.Default.ButtonOuterBorderColor := 0xFFFF0000, StopButton.Default.ButtonCenterBorderColor := 0xFFFF0000, StopButton.Default.ButtonInnerBorderColor1 := 0xFFFF0000, StopButton.Default.ButtonInnerBorderColor2 := 0xFFFF0000
			StopButton.Default.ButtonMainColor1 := 0xFFFF0000, StopButton.Default.ButtonMainColor2 := 0xFFFF0000
			StopButton.Default.ButtonAddGlossy := 1, StopButton.Default.GlossTopColor := 0x11D90000, StopButton.Default.GlossTopAccentColor := "05ffffff" , StopButton.Default.GlossBottomColor := "33D90000"
			;	Hover
			StopButton.Hover.W := 125 , StopButton.Hover.H := 45, StopButton.Hover.Text := "Stop" , StopButton.Hover.Font := "Segoe UI" , StopButton.Hover.FontOptions := "Bold Center vCenter" , StopButton.Hover.FontSize := 11
			StopButton.Hover.TextBottomColor2 := 0x0002112F, StopButton.Hover.TextTopColor1 := 0xFFFFFFFF, StopButton.Hover.TextTopColor2 := 0xFFFFFFFF, StopButton.Hover.TextOffsetX := 0, StopButton.Hover.TextOffsetY := 0, StopButton.Hover.TextOffsetW := 0, StopButton.Hover.TextOffsetH := 0
			StopButton.Hover.BackgroundColor := 0xFFFFFFFF, StopButton.Hover.ButtonOuterBorderColor := 0xFFFF1E1E, StopButton.Hover.ButtonCenterBorderColor := 0xFFFF1E1E, StopButton.Hover.ButtonInnerBorderColor1 := 0xFFFF1E1E, StopButton.Hover.ButtonInnerBorderColor2 := 0xFFFF1E1E
			StopButton.Hover.ButtonMainColor1 := 0xFFFF1E1E, StopButton.Hover.ButtonMainColor2 := 0xFFFF1E1E
			StopButton.Hover.ButtonAddGlossy := 0
			;	Pressed
			StopButton.Pressed.W := 125 , StopButton.Pressed.H := 45 , StopButton.Pressed.Text := "Stop" , StopButton.Pressed.Font := "Segoe UI" , StopButton.Pressed.FontOptions := "Bold Center vCenter" , StopButton.Pressed.FontSize := 11
			StopButton.Pressed.TextBottomColor2 := 0x0002112F, StopButton.Pressed.TextTopColor1 := 0xFFFFFFFF, StopButton.Pressed.TextTopColor2 := 0xFFFFFFFF, StopButton.Pressed.TextOffsetX := 0, StopButton.Pressed.TextOffsetY := 0, StopButton.Pressed.TextOffsetW := 0, StopButton.Pressed.TextOffsetH := -2
			StopButton.Pressed.BackgroundColor := 0xFFFFFFFF, StopButton.Pressed.ButtonOuterBorderColor := 0xFFFFFFFF, StopButton.Pressed.ButtonCenterBorderColor := 0xFFFF0000, StopButton.Pressed.ButtonInnerBorderColor1 := 0xFFAB0000, StopButton.Pressed.ButtonInnerBorderColor2 := 0xFFAB0000
			StopButton.Pressed.ButtonMainColor1 := 0xFFFF0000, StopButton.Pressed.ButtonMainColor2 := 0xFFFF0000
			StopButton.Pressed.ButtonAddGlossy := 0
			Return StopButton
		}
}

;----------------------------------------------------------------------------

; Function:				DecodeInteger
; Description:			Decode integer in LV_Update("AutoHDR").

DecodeInteger(p_type, p_address, p_offset, p_hex=true){
	old_FormatInteger := A_FormatInteger
	if (p_hex){
			SetFormat, Integer, hex
	}else{
			SetFormat, Integer, decSetFormat, Integer, dec
		}
	sign := InStr(p_type, "u", false )^1
	StringRight, size, p_type, 1
	loop, %size%
		{
			value += (*((p_address+p_offset)+(A_Index-1))<<(8*(A_Index-1)))
		}
	if (sign and size <= 4 and *(p_address+p_offset+(size-1)) & 0x80){
			value := -((~value+1) & ((2**(8*size))-1))
		}
	SetFormat, Integer, %old_FormatInteger%
	return value
}

;----------------------------------------------------------------------------

; Label:				DragDrop
; Description:			Toggle On/Off Drag & Drop in GUI1 menu by User Interface\List\Drag & Drop

DragDrop:
	Gui, 3:Submit, NoHide
	if(DragDrop_DDL = "One profile"){
			Menu, JJJJ, Check, &One profile`tCtrl+2
			Menu, JJJJ, Uncheck, &Multiple profiles`tCtrl+1
			SelectedDnD := "&One profile`tCtrl+2"
		}
	if(DragDrop_DDL = "Multiple profiles"){
			Menu, JJJJ, Check, &Multiple profiles`tCtrl+1
			Menu, JJJJ, unCheck, &One profile`tCtrl+2
			SelectedDnD := "&Multiple profiles`tCtrl+1"
		}
	Return

;----------------------------------------------------------------------------

; Label:				Drop_Settings
; Description:			Toggle On/Off Drag & Drop in GUI1 menu->settings.

Drop_Settings:
	SelectedDnD := A_ThisMenuItem
	if (SelectedDnD = "&One profile`tCtrl+2"){
			Menu, JJJJ, Check, &One profile`tCtrl+2
			Menu, JJJJ, Uncheck, &Multiple profiles`tCtrl+1
			GuiControl,3:ChooseString, DragDrop_DDL, One profile
		}
	if (SelectedDnD = "&Multiple profiles`tCtrl+1"){
			Menu, JJJJ, Check, &Multiple profiles`tCtrl+1
			Menu, JJJJ, unCheck, &One profile`tCtrl+2
			GuiControl,3:ChooseString, DragDrop_DDL, Multiple profile
		}
	Gui, 3:Submit, NoHide
	Return

;----------------------------------------------------------------------------

; Function:				ErrorCheck
; Description:			Checks if file is missing or retrieves file attributes.

ErrorCheck(File, Option:=0){
	Local Error
	FileGetAttrib, Outputvar, % File
	If (Option = 0)
		{
			if Errorlevel
				{
					Error := "`n" A_WorkingDir . "\" . File .  " [ Missing ]"
				}Else{
					Error := "`n" A_WorkingDir . "\" . File . " [ " . Outputvar . " ]"
				}
		}
	If (Option = 1)
		{
			if Errorlevel
				{
					Error := "`n" File .  " [ Missing ]"
				}Else{
					Error := "`n" File . " [ " . Outputvar . " ]"
				}
		}
	Return Error
}

;----------------------------------------------------------------------------

; Label:				Exit
; Description:			GUI 1 menu item. File->Exit. Closes the program.

Exit:
	ExitApp
	return

;----------------------------------------------------------------------------

; Function:				GetComboBoxInfo
; Description:			Retrieves information about the specified combo box.
;
; Notes:				http://msdn.microsoft.com/en-us/library/bb775939(v=vs.85).aspx

GetComboBoxInfo(Combo){
   	Static SizeOfCBI := (4 * 10) + (A_PtrSize * 3)
   	Static OffNumEDIT := (4 * 10) + A_PtrSize
   	VarSetCapacity(CBI, SizeOfCBI, 0)
   	NumPut(SizeOfCBI, CBI, 0, "UInt")
   	If DllCall("User32.dll\GetComboBoxInfo", "Ptr", Combo, "Ptr", &CBI, "UInt"){
			Return NumGet(CBI, OffNumEDIT, "UPtr")
	   }
	Return False
}

;----------------------------------------------------------------------------

; Function:				GetDiskFreeSpaceEX
; Description:			Retrieves information about the amount of space that is available on a disk volume, which is the total amount of space, the total amount of free space, and the total amount of free space available to the user that is associated with the calling thread.
;
; Notes:				https://msdn.microsoft.com/en-us/library/aa364937(v=vs.85).aspx

GetDiskFreeSpaceEx(Drive){
		Static Drive_Space := Object()
		if !(DllCall("GetDiskFreeSpaceEx", "str", Drive, "uint64*", Free, "uint64*", Total, "uint64*", 0)){
				Throw Exception("GetDiskFreeSpaceEx failed: " A_LastError, -1)
			}
		Drive_Space.Free := StrFormatByteSizeEx(Free), Drive_Space.total := StrFormatByteSizeEx(Total)
		return Drive_Space
	}

;----------------------------------------------------------------------------

; Function:				Get_PI_Controls
; Description:			Retrieves Page Improver ClassNN.

Get_PI_Controls(Controls){
	Static bcx, bcy
	Local OutputVar
	If (Pi_Mode = "L & R on One Image")
		{
				If (Controls = 1) ; Tab Control.
					{
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								If (cw=528 && ch=272)
									{
										If InStr(A_LoopField, "WindowsForms10.SysTabControl32.app.0.1ca0192_")
											{
												AC_SysTabControl32 := A_LoopField
												bcx := cx
												bcy := cy
												Break
											}
									}
							}
					}
				If (Controls = 2) ; Effects ComboBox Control.
					{
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								If (cx=(bcx+158)) && (cy=(bcy+91)) && (cw=108) && (ch=21)
									{
										If InStr(A_LoopField, "WindowsForms10.COMBOBOX.app.0.1ca0192_")
											{
												AC_EffectsComboBox := A_LoopField
												Break
											}
									}
							}
					}
				If (Controls = 3) ; Crop Controls.
					{
						AC_CalcWidth := "", AC_CalcHeight := "", AC_LeftVcenter := "", AC_LeftWidth := "", AC_LeftHeight := "", AC_RightVcenter := "", AC_RightWidth := "", AC_RightHeight := ""
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								If (cx=(bcx+117)) && (cy=(bcy+92)) && (cw=32) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.BUTTON.app.0.1ca0192_")
											{
												AC_CalcWidth := A_LoopField
											}
									}
								If (cx=(bcx+117)) && (cy=(bcy+140)) && (cw=32) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.BUTTON.app.0.1ca0192_")
											{
												AC_CalcHeight := A_LoopField
											}
									}
								IF (cx=(bcx+77)) && (cy=(bcy+116)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LeftVcenter := A_LoopField
											}
									}
								If (cx=(bcx+77)) && (cy=(bcy+140)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LeftHeight := A_LoopField
											}
									}
								If (cx=(bcx+77)) && (cy=(bcy+92)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LeftWidth := A_LoopField
											}
									}
								IF (cx=(bcx+325)) && (cy=(bcy+116)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_RightVcenter := A_LoopField
											}
									}
								If (cx=(bcx+325)) && (cy=(bcy+140)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_RightHeight := A_LoopField
											}
									}
								If (cx=(bcx+325)) && (cy=(bcy+92)) && (cw=40) && (ch=20)
									{
										If InStr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_RightWidth := A_LoopField
											}
									}
								If (AC_CalcWidth != "") && (AC_CalcHeight != "") && (AC_LeftVcenter != "") && (AC_LeftWidth != "") && (AC_LeftHeight != "") && (AC_RightVcenter != "") && (AC_RightWidth != "") && (AC_RightHeight != ""){
										Break
									}
							}
					}
				If (Controls = 4) ; Image Height
					{
						AC_ImageHeight := ""
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								ControlGetText, OutputVar, %A_LoopField%, ahk_exe %mBranch_A1%
								If InStr(OutputVar, "Left & Right Base Images")
									{
										;AC_Staticbase := A_LoopField
										Scx := cx
										Scy := cy
									}
								if (cx=(Scx+12)) && (cy=(Scy+31)) && (cw=104) && (ch=16)
									{
										If InStr(A_LoopField, "WindowsForms10.STATIC.app.0.1ca0192_")
											{
												AC_SplitVar := StrSplit(OutputVar, "x", "., `t`n`r")
												AC_ImageHeight := AC_SplitVar[2]
												Break
											}
									}
							}
					}
				If (Controls = 5) ; Border Controls
					{
						AC_UpperMargins_L := "", AC_UpperMargins_R := "", AC_LowerMargins_L := "", AC_LowerMargins_R := ""
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								If (cx=(bcx+150)) && (cy=(bcy+82)) && (cw=31) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_UpperMargins_L := A_LoopField
											}
									}
								If (cx=(bcx+206)) && (cy=(bcy+82)) && (cw=31) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_UpperMargins_R := A_LoopField
											}
									}
								If (cx=(bcx+150)) && (cy=(bcy+104)) && (cw=31) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LowerMargins_L := A_LoopField
											}
									}
								If (cx=(bcx+206)) && (cy=(bcy+104)) && (cw=31) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LowerMargins_R := A_LoopField
											}
									}
								If (AC_UpperMargins_L != "") && (AC_UpperMargins_R != "") && (AC_LowerMargins_L != "") && (AC_LowerMargins_R != ""){
										Break
									}
							}
					}
				If (Controls = 6) ; Shoulder
					{
						AC_UpperSweep_L := "", AC_UpperSweep_R := "", AC_LowerSweep_L := "", AC_LowerSweep_R := ""
						WinGet, PI_Control_List, ControlList, ahk_exe %mBranch_A1%
						Loop, Parse, PI_Control_List, `n, `r
							{
								ControlGetPos, cx, cy, cw, ch, %A_LoopField%, ahk_exe %mBranch_A1%
								If (cx=(bcx+104)) && (cy=(bcy+167)) && (cw=44) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_UpperSweep_L := A_LoopField
											}
									}
								If (cx=(bcx+346)) && (cy=(bcy+167)) && (cw=44) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_UpperSweep_R := A_LoopField
											}
									}
								If (cx=(bcx+104)) && (cy=(bcy+211)) && (cw=44) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LowerSweep_L := A_LoopField
											}
									}
								If (cx=(bcx+346)) && (cy=(bcy+211)) && (cw=44) && (ch=20)
									{
										If Instr(A_LoopField, "WindowsForms10.EDIT.app.0.1ca0192_")
											{
												AC_LowerSweep_R := A_LoopField
											}
									}
								If (AC_UpperSweep_L != "") && (AC_UpperSweep_R != "") && (AC_LowerSweep_L != "") && (AC_LowerSweep_R != ""){
										Break
									}
							}
					}
				
		}
}

;----------------------------------------------------------------------------

; Label:				GuiClose
; Description:			Closing GUI 1 closes the program
;
; Notes:				Add GuiEscape: to also close AutoPI wtih the esc key.

GuiClose:
	ExitApp

;----------------------------------------------------------------------------

; Label:				2GuiEscape and 2GUIClose 
; Description:			Closing GUI 2 hides it and suspends hotkeys.

/*
2GuiEscape:
2GUIClose:
	Menu, CCCC, uncheck, &Open GUI
	GUIControl,2:, SuspendHK, Hotkeys Off
	Suspend, On
	Gui, 2:Hide
	Return
*/

;----------------------------------------------------------------------------

; Label:				3GUIClose
; Description:			Closing GUI 3 hides it. Enables GUI 1
;
; Notes:				Clicking X to close the GUI 3 window, doesn't revert changes to variables and lets the user run custom settings without saving them.

3GUIClose:
	Menu, EEEE, uncheck, &Settings`tF12
	Gui, 1:-Disabled
	Gui, 3:Hide
	Return

;----------------------------------------------------------------------------

; Function:				Guictrls
; Description:			Enable or Disable GUI controls.

Guictrls(Ctrlstatus, Start, Stop){
	Disablecontrol := (Ctrlstatus=1 ? 0 : 1)
	;GuiControl, % Start=1 ? "Show" : "Hide", Start2
	GuiControl, % Start=1 ? "Show" : "Hide", Start
	;Guicontrol, % Stop=1 ? "Show" : "Hide", Stop2
	GuiControl, % Stop=1 ? "Show" : "Hide", Stop
	Guicontrol, % Stop=1 ? "1:Disable" : "1:Enable", List
	GuiControl, % Ctrlstatus=1 ? "3:Enable" : "3:Disable", Images_Timer
	GuiControl, % Ctrlstatus=1 ? "3:Enable" : "3:Disable", Duration_Timer
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", &File
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", &Edit
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", &View
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", Pr&esets
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", &Settings
	Menu, AutoPi_Menu, % Ctrlstatus=1 ? "Enable" : "Disable", &Help
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Add row`tAlt+1
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Add rows - multiple profiles`tAlt+2
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Add rows - one profile`tAlt+3
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Insert`tF3
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Modify
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Remove crop
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Remove row`tDel
	Menu, MenuListView, % Ctrlstatus=1 ? "Enable" : "Disable", &Delete All`tShift+Del
}

;----------------------------------------------------------------------------

; Function:				Guictrls2
; Description:			Enable or Disable GUI controls related to ImageView.

Guictrls2(Ctrlstatus, View){
	Gui, 1:Color, % Ctrlstatus=1 ? "White" : "222222"
	GuiControl, % Ctrlstatus=1 ? "1:Show" : "1:Hide", Start
	;GuiControl, % Ctrlstatus=1 ? "1:Show" : "1:Hide", Start2
	GuiControl, % Ctrlstatus=1 ? "1:Show" : "1:Hide", List
	Menu, CCCC, % View=0 ? "Enable" : "Disable", &Open raw`tShift+O
	Menu, CCCC, % View=0 ? "Enable" : "Disable", &Open output`tCtrl+Shift+O
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Close`tEsc
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Next`tPgDn
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Previous`tPgUp
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &First`tHome
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Last`tEnd
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Rotate
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Mirror-reversal
	Menu, CCCC, % View=1 ? "Enable" : "Disable", &Grid`tShift+G
	Menu, CCCC, uncheck, &Grid`tShift+G
}

;----------------------------------------------------------------------------

; Label:				3GuiEscape
; Description:			Closing GUI 3 window with the ESC key, hides it and reverts changes to variables. Enables GUI 1.

3GuiEscape:
	Gosub, Setting_Cancel
	Menu, EEEE, uncheck, &Settings`tF12
	Gui, 1:-Disabled
	Gui, 3:Hide
	Return

;----------------------------------------------------------------------------

; Label:				GUISize
; Description:			Resize GUI 1. 
;
; Notes:				Settimer is used for lowering cpu usage. (Milliseconds)

GUISize:
	If (A_EventInfo = 1)
		Return
	wSize := A_GuiWidth-22	
	hSize := A_GuiHeight-77
	xSize := A_GuiWidth/2-62
	ySize := A_GuiHeight-59
	Guicontrol, MoveDraw, Start, % "x" . (xSize) . "y" . (ySize)
	Guicontrol, MoveDraw, Stop, % "x" . (xSize) . "y" . (ySize)
	;ControlMove,, (A_GuiWidth-ImgObj["Img_W"])/2,,,, % "ahk_id" . Image1
	SetTimer, ResizeGUI1, -15
	SetTimer, ResizeSB, -20
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey
; Description:			Adds or removes keyboard buttons associated with hotkeys 1-5.
;
; Notes:				HK = hotkey 1-5 var. savedhk contains saved buttons from Hotkeys.ini. CB 1-5 is the checkbox for win+key support.

Hotkey:
	If %A_GuiControl% in +,^,!,+^,+!,^!,+^!
		{
			return
		}
	num := SubStr(A_GuiControl,3)
	If (HK%num% != "") 
		{
			Gui, Submit, NoHide
		}
	If CB%num%
		{
			HK%num% := "#" HK%num%
		}
	If !RegExMatch(HK%num%,"[#!\^\+]")
		{
			HK%num% := "~" HK%num%
		}
	Loop,% #ctrls
		{
			If (HK%num% != "~") && (HK%num% = savedHK%A_Index%)
				{
					dup := A_Index
					Loop,6
						{
							GuiControl,% "Disable" b:=!b, HK%dup%
							Sleep,200
						}
					GuiControl,,HK%num%,% HK%num% := ""
					break
				}
		}
	If (savedHK%num% || HK%num%)
		{
			setHK(num, savedHK%num%, HK%num%)
		}
	return

;----------------------------------------------------------------------------

; Label:				Hotkey1
; Description:			Macro for hotkey 1. Page Improver: Apply and preview, delay and save and open next.

Hotkey1:
	if WinActive("ahk_exe" . mBranch_A1)
		{
			SendInput, {LAlt Down}
			sleep, 100
			SendInput, a
			sleep, 100
			SendInput, {LAlt Up}
			sleep, Macro_Delay_1*1000
			SendInput, {LAlt Down}
			sleep, 100
			SendInput, n
			sleep, 100
			SendInput, {Alt Up}
		}
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey2
; Description:			Blank.

Hotkey2:
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey3
; Description:			Blank.

Hotkey3:
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey4
; Description:			System uptime is used to measure time and hotkey 4 creates up to 3 additional timers for the paused time.
;
; Notes;				Needs new code. Not in use.

/*
	if (PauseVar = 1)
		{
			Engage := 0
			PauseVar++
			Timer_Stop := (A_TickCount - Timer_Start)
			SleeptimeLeft := (sTime - Timer_Stop)
			Extra_sTime_1 := (SleeptimeLeft+1000)
			TrayTip, Pause, On, 1,1
			Pause, On
			Return
		}
	If (PauseVar = 2)
		{
			Timer_Start2 := A_TickCount
			Pause, Off
			PauseVar++
			TrayTip, Pause, Off, 1,1
			Return
		}
	If (PauseVar = 3)
		{
			Engage := 0
			PauseVar++
			Timer_Stop := (A_TickCount - Timer_Start2)
			SleeptimeLeft := (Extra_sTime_1 - Timer_Stop)
			Extra_sTime_2 := (SleeptimeLeft+1000)
			TrayTip, Pause #2, On, 1, 1
			Pause, On
			Return
		}
	If (PauseVar = 4)
		{
			Timer_Start := A_TickCount
			Pause, Off
			PauseVar++
			TrayTip, Pause, Off, 1,1
			Return
		}
	If (PauseVar = 5)
		{
			Engage := 0
			PauseVar++
			Timer_Stop := (A_TickCount - Timer_Start2)
			SleeptimeLeft := (Extra_sTime_2 - Timer_Stop)
			Extra_sTime_3 := (SleeptimeLeft+1000)
			TrayTip, Pause #3, On, 1, 34
			Pause, On
			Return
		}
	If (PauseVar = 6)
		{
			Timer_Start := A_TickCount
			Pause, Off
			PauseVar++
			TrayTip, Pause #3, Off, 1, 34
			Return
		}
	If (PauseVar = 7)
		{
			Pausevar := 0
			TrayTip, Error, Aborted, 1,3
			GoSub, Stop
		}
*/
Hotkey4:
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey5
; Description:			Triggers the Stop Label. Not in use.

; GoSub, Stop

Hotkey5:
	Return

;----------------------------------------------------------------------------

; Label:				Hotkey_Space
; Description:			Checkbox located in GUI 3 Hotkeys - XnView Space Delay. Takes control over space button and triggers space based on a delay set in Space_Macro_Delay.
;
; Notes:				Getkeystate is slowed down by 10ms sleep to prevent high cpu usage.

Hotkey_Space:
	Gui, 3:Submit, Nohide
	if (A_GuiControl = "Space_Macro"){
			GuiControl,3:, Space_Macro, % (Space_Macro = 1) ? "On" : "Off"
		}
	#if (Space_Macro = 1) && (A_IsSuspended == 0) && WinActive("ahk_exe" . Space_Process)
		{
			While GetKeyState("Space", "P")
			Sleep, 10
			$Space::
			SendInput, {Space}
			Sleep, %Space_Macro_Delay%
			Return
		}
	#If
	Return

;----------------------------------------------------------------------------

; Function:				Jxon_Load
; Description:			Turning a JSON string into a Autohotkey object.

Jxon_Load(ByRef src, args*){
	static q := Chr(34)
	
	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := Object(tree, 1) ; ahk v1                    ; orig -> is_arr := { (tree): 1 }
	next := q "{[01234567890-tfn"
	pos := 0
	
	while ( (ch := SubStr(src, ++pos, 1)) != "" ) {
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true) {
			testArr := StrSplit(SubStr(src, 1, pos), "`n")
			ln := testArr.Length()
			
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}
		
		is_array := is_arr[obj := stack[1]] 
		
		if i := InStr("{[", ch) { ; start new object / map?
			val := (i = 1) ? Object() : Array()	; ahk v1
			
			is_array ? obj.Push(val) : obj[key] := val
			stack.InsertAt(1,val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q (is_key ? "}" : "{[]0123456789-tfn")
		} else if InStr("}]", ch) {
			stack.RemoveAt(1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		} else if InStr(",:", ch) {
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q "{[0123456789-tfn"
		} else { ; string | number | true | false | null
			if (ch == q) { ; string
				i := pos
				while i := InStr(src, q,, i+1) {
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					if (SubStr(val, 0) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  val := StrReplace(val,    "\/",  "/")
				val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1) {
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					xxxx := Abs("0x" . SubStr(val, i+2, 4)) ; \uXXXX - JSON unicode escape sequence
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}
				
				if is_key {
					key := val, next := ":"
					continue
				}
			} else { ; number | true | false | null
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
				
				static number := "number", integer := "integer", float := "float"
				if val is %number%
				{
					if val is %integer%
						val += 0
					if val is %float%
						val += 0
					else if (val == "true" || val == "false")
						val := %val% + 0
					else if (val == "null")
						val := ""
					else if is_key {					; else if (pos--, next := "#")
						pos--, next := "#"					; continue
						continue
					}
				}
				
				pos += i-1
			}
			
			is_array ? obj.Push(val) : obj[key] := val
			next := obj == tree ? "" : is_array ? ",]" : ",}"
		}
	}
	
	return tree[1]
}

;----------------------------------------------------------------------------

; Function:				Jxon_Dump
; Description:			Turning a Autohotkey object into a JSON string.

Jxon_Dump(obj, indent:="", lvl:=1){
	static q := Chr(34), chunkType := ""
	
	if IsObject(obj) {
		is_array := 0
		for k in obj
			is_array := k == A_Index
		until !is_array
		memType := is_array ? "Array" : "Map"
		
		if (memType ? (memType != "Object" And memType != "Map" And memType != "Array") : (ObjGetCapacity(obj) == ""))
			throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))
		
		static integer := "integer"
		if indent is integer ; %integer%
		{
			if (indent < 0)
				throw Exception("Indent parameter must be a postive integer.", -1, indent)
			spaces := indent, indent := ""
			If (A_AhkVersion < 2) {
				Loop %spaces% ; ===> changed
					indent .= " "
			} Else {
				Loop spaces ; ===> changed
					indent .= " "
			}
		}
		indt := ""
		lpCount := indent ? lvl : 0
		Loop %lpCount%
			indt .= indent

		lvl += 1, out := "" ; Make #Warn happy
		for k, v in obj {
			if IsObject(k) || (k == "")
				throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
			
			if !is_array ;// key ; ObjGetCapacity([k], 1)
				chunkType := "key", out .= (ObjGetCapacity([k]) ? Jxon_Dump(k) : q k q) (indent ? ": " : ":") ; token + padding
			Else
                chunkType := "value" ; need to check when calling Jxon_Dump() internally, if chunkType is a key or value
			
            out .= Jxon_Dump(v, indent, lvl) ; value
				.  ( indent ? ",`n" . indt : "," ) ; token + indent
		}

		if (out != "") {
			out := Trim(out, ",`n" . indent)
			if (indent != "")
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
		}
		
		return is_array ? "[" . out . "]" : "{" . out . "}"
	} else { ; Number
		copyObj := obj + 0
        If (copyObj = obj And chunkType != "key")
			return obj
		Else {
            obj := StrReplace(obj,"\","\\")
			obj := StrReplace(obj,"`t","\t")
			obj := StrReplace(obj,"`r","\r")
			obj := StrReplace(obj,"`n","\n")
			obj := StrReplace(obj,"`b","\b")
			obj := StrReplace(obj,"`f","\f")
			obj := StrReplace(obj,"/","\/")
			obj := StrReplace(obj,q,"\" q)
			return q obj q
		}
	}
}

;----------------------------------------------------------------------------

; Label:				Macro_Delay_List
; Description:			Label for the DropDownList in GUI 2 "key settings" groupbox. Updates var when delay is changed.

Macro_Delay:
	Gui, 3:Submit, NoHide
	return

;----------------------------------------------------------------------------

; Label:				Mouse_Get_Pos
; Description:			Local navigator mouse coordinates.
;
; Notes:				Finds: X Y coordinates. PageImprover process, path and title. Creates a tooltip with retrieved information for 5 seconds.

Mouse_Get_Pos:
	MouseGetPos, xpos, ypos, id, control
	WinGet PName, ProcessName, ahk_id %id%
	WinGet PPath, ProcessPath, ahk_id %id%
	WinGetTitle, title, ahk_id %id%
	;WinGetClass, class, ahk_id %id%
	ToolTip, Local Navigator`nX-axis: %xpos%`nY-axis: %ypos%`n`nScript Settings/Page Improver`nPath: %PPath%`nProcess: %PName%`nTitle: %Title% ;`nControl: %control%
	GuiControl,3:,xMC_Local_Navigator,%xpos%
	GuiControl,3:,yMC_Local_Navigator,%ypos%
	GuiControl,3:,mBranch_A1, % PName
	GuiControl,3:,mBranch_A2, % Title
	GuiControl,3:,cBranch_A1, % PPath
	SetTimer, RemoveToolTip, -5000
	StatusBarGetText, SBvar, 2, % "ahk_id" GUI1
	if instr(SBvar, "Please set new mouse coordinates in settings") or instr(SBvar, "Error: Mouse coordinates")
		{
			Gui, 1:Default
			SB_SetText("",2,1)
		}
	return

;----------------------------------------------------------------------------

; Label:				Mouse_Get_Pos2
; Description:			Mouse coordinates for the left page shoulder search.

Mouse_Get_Pos2:
	MouseGetPos, xpos, ypos, id, control
	GuiControl,3:,xMC_Left_Image,%xpos%
	GuiControl,3:,yMC_Left_Image,%ypos%
	ToolTip, Left Shoulder`nX-axis: %xpos%`nY-axis: %ypos%
	SetTimer, RemoveToolTip, -5000
	Return

;----------------------------------------------------------------------------

; Label:				Mouse_Get_Pos3
; Description:			Mouse coordinates for the right page shoulder search.

Mouse_Get_Pos3:
	MouseGetPos, xpos, ypos, id, control
	GuiControl,3:,xMC_Right_Image,%xpos%
	GuiControl,3:,yMC_Right_Image,%ypos%
	ToolTip, Right Shoulder`nX-axis: %xpos%`nY-axis: %ypos%
	SetTimer, RemoveToolTip, -5000
	Return

;----------------------------------------------------------------------------

; Label:				Open_Gui_Hotkeys
; Description:			GUI 1 menu item: Hotkeys->PageImprover/XnView. Opens GUI 2 based on the position of GUI 1 and activates hotkeys.

/*
Open_Gui_Hotkeys:
	if WinExist("ahk_id" Gui2){
			Gosub, 2GUIClose
			Return
		}
	GUIControl,2:, SuspendHK, Hotkeys On
	Suspend, Off
	WinGetPos, Hx, Hy, Width, Height, ahk_id %GUI1%
	Hx := Hx+(Width-324)/2
	Hy := Hy+(Height-400)/2
	Gui, 2:Show, w324 h370 x%Hx% y%Hy%, Page Improver/XnView
	Menu, CCCC, check, &Open GUI
	return
*/

;----------------------------------------------------------------------------

; Label:				Open_Gui_Settings
; Description:			GUI 1 menu item: Settings->Settings. Opens GUI 3 based on the position of GUI 1. Disables GUI 1.

Open_Gui_Settings:
	if WinExist("ahk_id" Gui3){
			Gosub, 3GUIClose
			Return
		}
	Gosub, TempSaveSettings
	Gui 1:+Disabled
	WinGetPos, Sx, Sy, Width, Height, ahk_id %GUI1%
	Sx := Sx+(Width-610)/2
	Sy := Sy+(Height-291)/2-17
	Gui, 3:Show, w610 h291 x%Sx% y%Sy%, Settings
	;Gui, 3:Show, w680 h392 Center x%SettingsPosition%, Settings
	Menu, EEEE, check, &Settings`tF12
	return

;----------------------------------------------------------------------------

; Label:				Open_List_JSON
; Description:			GUI 1 Menu Settings->Open.json->List.json.

Open_List_JSON:
	Gui +OwnDialogs
	if !FileExist("List.json"){
			MsgBox, 262160, %Appname% - Error, Cant find:`n%A_WorkingDir%\List.json
		}
	Else if FileExist("List.json"){
			Run, List.json,, UseErrorLevel
			if (ErrorLevel){
					MsgBox, 262160, %Appname% - Error, Unable to open List.json
				}
		}
	return

;----------------------------------------------------------------------------

; Label:				Open_Settings_JSON
; Description:			GUI 1 Menu Settings->Open.json->Settings.json.

Open_Settings_JSON:
	Gui +OwnDialogs
	if !FileExist("Settings.json"){
			MsgBox, 262160, %Appname% - Error, Cant find:`n%A_WorkingDir%\Settings.json
		}
	Else if FileExist("Settings.json"){
			Run, Settings.json,, UseErrorLevel
			if (ErrorLevel){
					MsgBox, 262160, %Appname% - Error, Unable to open Settings.json
				}
		}
	return

;----------------------------------------------------------------------------

; Label:				Open_Table_JSON
; Description:			GUI 1 Menu Settings->Open.json->Table.json.

Open_Table_JSON:
	Gui +OwnDialogs
	if !FileExist("Table.json"){
			MsgBox, 262160, %Appname% - Error, Cant find:`n%A_WorkingDir%\Table.json
		}
	Else if FileExist("Table.json"){
			Run, Table.json,, UseErrorLevel
			if (ErrorLevel){
					MsgBox, 262160, %Appname% - Error, Unable to open Table.json
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				OpenWithButton
; Description:			Select program to openwith.

OpenWithButton:
	Gui, 3:+OwnDialogs
	FileSelectFile, OutputVar, 3, \\, % Appname . " - Open with", (*.exe)
	If ErrorLevel
	Return
	Ext := FilesystemObj.GetExtensionName(OutputVar)
	if (Ext in "exe"){
			GuiControl,3:, Openwith, % OutPutVar
	}Else{
			MsgBox, 262160, %Appname% - Error, Wrong file type.
		}
	Return

;----------------------------------------------------------------------------

; Label:				PI_Restart
; Description:			Prevent the use of other script options that require "Restart Page Improver".
;
; Notes:				Previous ternary operator code resulted in a Bug.

PI_Restart:
	GUI, 3:Submit, NoHide
	IF (ShoulderSearch = 1){
			GuiControl,3:, ShoulderSearch, On
		}
	IF (ShoulderSearch = 0){
			GuiControl,3:, ShoulderSearch, Off
		}
	If (Conditional_Branch = 0){
			GuiControl,3:, Conditional_Branch, Off
			GuiControl,3:, Initial_Restart, 0
			GuiControl,3:, Initial_Restart, Off
			GuiControl,3:, Apply_Effect, 0
			GuiControl,3:, Apply_Effect, Off
			GuiControl,3:, AutoCrop, 0
			GuiControl,3:, AutoCrop, Off
		}
	If (Conditional_Branch = 1){
			GuiControl,3:, Conditional_Branch, On
			IF (Initial_Restart = 1){
					GuiControl,3:, Initial_Restart, On
					IF (AutoCrop = 1){
							GuiControl,3:, AutoCrop, On
						}
					IF (AutoCrop = 0){
							GuiControl,3:, AutoCrop, Off
						}
				}
			IF (Initial_Restart = 0){
					GuiControl,3:, Initial_Restart, Off
					GuiControl,3:, AutoCrop, 0
					GuiControl,3:, AutoCrop, Off
				}
			IF (Apply_Effect = 1){
					GuiControl,3:, Apply_Effect, On
				}
			IF (Apply_Effect = 0){
					GuiControl,3:, Apply_Effect, Off
				}
			IF (ShoulderSearch = 0){
					GuiControl,3:, AutoCrop, 0
					GuiControl,3:, AutoCrop, Off
				}
		}
	Gui, 3:Submit, NoHide
	Return

;----------------------------------------------------------------------------

; Label:				ProgressAnimation
; Description:			Started and stopped by settimer in AutoPI label. Stopped by settimer in Stop label.
;						SB_SetProgress creates a progressbar in statusbar section 3. Sets 1-99% in statusbar section 4.

ProgressAnimation:
   SB_SetProgress(++pp,3)
   if (pp=100){
      		SetTimer,ProgressAnimation,Off
			SB_SetProgress(0,3,"hide")
			SB_SetText("",4,1)
   		}Else{
			SB_SetText(pp " %",4,1)
		}
Return

;----------------------------------------------------------------------------

; Label:				Recyclebin
; Description:			Empties D:\ recycle bin.
;
; Notes:				Omitt drive letter to empty all drives.

Recyclebin:
	Gui +OwnDialogs
	Try 
		{	
			OutputVar := SubStr(LB_DriveSpace, 1, 3)
			FileRecycleEmpty, % OutputVar
			DriveGet, DriveList, List
			GuiControl,3:, LB_DriveSpace, |
			Loop, Parse, DriveList
				{
					; DriveGet, OutputVar, Type, % A_LoopField . ":\"
					; If Outputvar in Fixed ; Unknown,Removable,Network,Fixed,CDROM,RAMDisk
					If A_LoopField in C,D
						{
							GuiControl,3:, LB_DriveSpace, % A_LoopField . ":\  " . GetDiskFreeSpaceEx(A_LoopField . ":\").Free
						}
				}
			; MsgBox, 262208,	%Appname% - Info, % "Success! " . OutputVar . " has " . GetDiskFreeSpaceEx(OutputVar).Free . " of free space."
		}
	Catch e
		{
			If (e.message = 1){
					MsgBox, 262160, %Appname% - Error, Recycle bin is already empty.
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				RefreshGui1
; Description:			Gui1 menu settings->refresh

RefreshGui1:
	if WinExist("ahk_id" Image1){
		If (!ImageViewer("Next", ImgObj)){
				GoSub, View_Close
			}
		Return
	}
	GoSub, List_HDR
	Return

;----------------------------------------------------------------------------

; Label:				RemoveToolTip
; Description:			Closes tooltip.

RemoveToolTip:
	ToolTip
	return

;----------------------------------------------------------------------------

; Label:				ResizeGUI1
; Description:			Reposition listview, start and stop button when resizing GUI 1.

ResizeGUI1:
	Guicontrol, Move, List, w%wSize% h%hSize%
	/*
	Guicontrol, MoveDraw, Start2, % "x" . (xSize) . "y" . (ySize)
	Guicontrol, MoveDraw, Start, % "x" . (xSize) . "y" . (ySize)
	Guicontrol, MoveDraw, Stop2, % "x" . (xSize) . "y" . (ySize)
	Guicontrol, MoveDraw, Stop, % "x" . (xSize) . "y" . (ySize)
*/

	Return

;----------------------------------------------------------------------------

; Label:				ResizeSB
; Description:			Resize statusbar when resizing GUI 1.

ResizeSB:
	SB_SetParts(SB_1,wSize-200,SB_3, SB_4)
	Return

;----------------------------------------------------------------------------

; Label:				Restart_AutoPi
; Description:			GUI 1 menu item. File->Restart: Restarts AutoPI program.

Restart_AutoPi:
	Reload
	return

;----------------------------------------------------------------------------

; Function:				SB_CountRows
; Description:			Not in use. Counts rows in list view.

SB_CountRows(){
	Totalrows := LV_GetCount()
	If (Totalrows < 1){
			SB_SetText("",1,1)
			SB_SetText("",2,1)
		}
	If (Totalrows = 1){
			SB_SetText(Totalrows,1,1)
			SB_SetText("Row",2,1)
		}
	If (Totalrows > 1){
			SB_SetText(Totalrows,1,1)
			SB_SetText("Rows",2,1)
		}
}

;----------------------------------------------------------------------------

; Function:				SB_SetProgress
; Description:			Adds progressbar support in statusbar for AutoHotKey.
; Notes:				Old code - Colour doesn't work.
;
; Author: 				derRaphael. https://autohotkey.com/board/topic/34593-stdlib-sb-setprogress/
; License:				EUPL 1.0 - A free-software license.

SB_SetProgress(Value=0,Seg=1,Ops=""){
   ; Definition of Constants   
   Static SB_GETRECT      := 0x40a      ; (WM_USER:=0x400) + 10
        , SB_GETPARTS     := 0x406
        , SB_PROGRESS                   ; Container for all used hwndBar:Seg:hProgress
        , PBM_SETPOS      := 0x402      ; (WM_USER:=0x400) + 2
        , PBM_SETRANGE32  := 0x406
        , PBM_SETBARCOLOR := 0x409
        , PBM_SETBKCOLOR  := 0x2001
        , dwStyle         := 0x50000001 ; forced dwStyle WS_CHILD|WS_VISIBLE|PBS_SMOOTH

   ; Find the hWnd of the currentGui's StatusbarControl
   ;Gui,+LastFound
   ControlGet,hwndBar,hWnd,,, % "ahk_id" Bar

   if (!StrLen(hwndBar)) {
      rErrorLevel := "FAIL: No StatusBar Control"     ; Drop ErrorLevel on Error
   } else If (Seg<=0) {
      rErrorLevel := "FAIL: Wrong Segment Parameter"  ; Drop ErrorLevel on Error
   } else if (Seg>0) {
      ; Segment count
      SendMessage, SB_GETPARTS, 0, 0,, ahk_id %hwndBar%
      SB_Parts :=  ErrorLevel - 1
      If ((SB_Parts!=0) && (SB_Parts<Seg)) {
         rErrorLevel := "FAIL: Wrong Segment Count"  ; Drop ErrorLevel on Error
      } else {
         ; Get Segment Dimensions in any case, so that the progress control
         ; can be readjusted in position if neccessary
         if (SB_Parts) {
            VarSetCapacity(RECT,16,0)     ; RECT = 4*4 Bytes / 4 Byte <=> Int
            ; Segment Size :: 0-base Index => 1. Element -> #0
            SendMessage,SB_GETRECT,Seg-1,&RECT,,ahk_id %hwndBar%
            If ErrorLevel
               Loop,4
                  n%A_index% := NumGet(RECT,(a_index-1)*4,"Int")
            else
               rErrorLevel := "FAIL: Segmentdimensions" ; Drop ErrorLevel on Error
         } else { ; We dont have any parts, so use the entire statusbar for our progress
            n1 := n2 := 0
            ControlGetPos,,,n3,n4,,ahk_id %hwndBar%
         } ; if SB_Parts

         If (InStr(SB_Progress,":" Seg ":")) {

            hWndProg := (RegExMatch(SB_Progress, hwndBar "\:" seg "\:(?P<hWnd>([^,]+|.+))",p)) ? phWnd :

         } else {

            If (RegExMatch(Ops,"i)-smooth"))
               dwStyle ^= 0x1

            hWndProg := DllCall("CreateWindowEx","uint",0,"str","msctls_progress32"
               ,"uint",0,"uint", dwStyle
               ,"int",0,"int",0,"int",0,"int",0 ; segment-progress :: X/Y/W/H
               ,"uint",DllCall("GetAncestor","uInt",hwndBar,"uInt",1) ; gui hwnd
               ,"uint",0,"uint",0,"uint",0)

            SB_Progress .= (StrLen(SB_Progress) ? "," : "") hwndBar ":" Seg ":" hWndProg

         } ; If InStr Prog <-> Seg

         ; HTML Colors
         Black:=0x000000,Green:=0x008000,Silver:=0xC0C0C0,Lime:=0x00FF00,Gray:=0x808080
         Olive:=0x808000,White:=0xFFFFFF,Yellow:=0xFFFF00,Maroon:=0x800000,Navy:=0x000080
         Red:=0xFF0000,Blue:=0x0000FF,Fuchsia:=0xFF00FF,Aqua:=0x00FFFF

         If (RegExMatch(ops,"i)\bBackground(?P<C>[a-z0-9]+)\b",bg)) {
              if ((strlen(bgC)=6)&&(RegExMatch(bgC,"i)([0-9a-f]{6})")))
                  bgC := "0x" bgC
              else if !(RegExMatch(bgC,"i)^0x([0-9a-f]{1,6})"))
                  bgC := %bgC%
              if (bgC+0!="")
                  SendMessage, PBM_SETBKCOLOR, 0
                      , ((bgC&255)<<16)+(((bgC>>8)&255)<<8)+(bgC>>16) ; BGR
                      ,, ahk_id %hwndProg%
         } ; If RegEx BGC
         If (RegExMatch(ops,"i)\bc(?P<C>[a-z0-9]+)\b",fg)) {
              if ((strlen(fgC)=6)&&(RegExMatch(fgC,"i)([0-9a-f]{6})")))
                  fgC := "0x" fgC
              else if !(RegExMatch(fgC,"i)^0x([0-9a-f]{1,6})"))
                  fgC := %fgC%
              if (fgC+0!="")
                  SendMessage, PBM_SETBARCOLOR, 0
                      , ((fgC&255)<<16)+(((fgC>>8)&255)<<8)+(fgC>>16) ; BGR
                      ,, ahk_id %hwndProg%
         } ; If RegEx FGC

         If ((RegExMatch(ops,"i)(?P<In>[^ ])?range((?P<Lo>\-?\d+)\-(?P<Hi>\-?\d+))?",r))
              && (rIn!="-") && (rHi>rLo)) {    ; Set new LowRange and HighRange
              SendMessage,0x406,rLo,rHi,,ahk_id %hWndProg%
         } else if ((rIn="-") || (rLo>rHi)) {  ; restore defaults on remove or invalid values
              SendMessage,0x406,0,100,,ahk_id %hWndProg%
         } ; If RegEx Range
     
         If (RegExMatch(ops,"i)\bEnable\b"))
            Control, Enable,,, ahk_id %hWndProg%
         If (RegExMatch(ops,"i)\bDisable\b"))
            Control, Disable,,, ahk_id %hWndProg%
         If (RegExMatch(ops,"i)\bHide\b"))
            Control, Hide,,, ahk_id %hWndProg%
         If (RegExMatch(ops,"i)\bShow\b"))
            Control, Show,,, ahk_id %hWndProg%

         ControlGetPos,xb,yb,,,,ahk_id %hwndBar%
         ControlMove,,xb+n1,yb+n2,n3-n1,n4-n2,ahk_id %hwndProg%
         SendMessage,PBM_SETPOS,value,0,,ahk_id %hWndProg%

      } ; if Seg greater than count
   } ; if Seg greater zero

   If (regExMatch(rErrorLevel,"^FAIL")) {
      ErrorLevel := rErrorLevel
      Return -1
   } else
      Return hWndProg

}

;----------------------------------------------------------------------------

; Label:				Select
; Description:			Radiobuttons in GUI 3 Script->Send Mode.

Select:
	Gui, 3:Submit, Nohide
	GuiControl, % (Control_Send = 1) ? "3:Enabled" : "3:Disabled", PressDurationCS
	GuiControl, % (Control_Send = 1) ? "3:Enabled" : "3:Disabled", KeyDelayCS
	GuiControl, % (Send_Event = 1) ? "3:Enabled" : "3:Disabled", PressDuration
	GuiControl, % (Send_Event = 1) ? "3:Enabled" : "3:Disabled", KeyDelay
	If(Control_Send = 1){
			;SendMode Event
			SetKeyDelay, %KeyDelayCS%, %PressDurationCS%
		}
	Else if(Send_Input = 1){
			Sendmode Input
		}
	Else if(Send_Event = 1){
			SendMode Event
			SetKeyDelay, %KeyDelay%, %PressDuration%
		}
	Gui, 3:Submit, Nohide
	Return

;----------------------------------------------------------------------------

; Label:				Select_AC
; Description:			Both radiobuttons in Gui 3 Script->Automatic Crop->Settings->Crop

Select_AC:
	Gui, 3:Submit, Nohide
	GuiControl, % (AC_Manual = 1) ? "3:Enabled" : "3:Disabled", AC_HeightAdjust
	GuiControl, % (AC_Manual = 1) ? "3:Enabled" : "3:Disabled", AC_WidthAdjust
	GuiControl, % (AC_Manual = 1) ? "3:Enabled" : "3:Disabled", AC_Manual_sDDL
	GuiControl, % (AC_Table = 1) ? "3:Enabled" : "3:Disabled", AC_TablePath
	Gui, 3:Submit, Nohide
	Return

;----------------------------------------------------------------------------

; Label:				SelectTimer1
; Description:			Radiobutton in script->Progress->Images. Disables "Timer" controls and enables "Images" controls.

SelectTimer1:
	Gui, 3:Submit, Nohide
	if(Duration_Timer = 1 or Duration_Timer = ""){
			GuiControl, 3:, Duration_Timer, 0
		}
	if(Images_Timer = 1){
			GuiControl, 3:Enable, Deadline
			GuiControl, 3:Enable, Timelimit
			GuiControl, 3:Enable, DeadlineActiontaken
			GuiControl, 3:Enable, iCount_T1
			GuiControl, 3:Enable, iCount_T2
			GuiControl, 3:Enable, iCount_T3
			GuiControl, 3:Disable, Limit
			GuiControl, 3:Disable, MB_Second
		}
	Gui, 3:Submit, Nohide
	Return

;----------------------------------------------------------------------------

; Label:				SelectTimer2
; Description:			Radiobutton in script->Progress->Timer. Disables "Images" controls and enables "Timer" controls.

SelectTimer2:
	Gui, 3:Submit, Nohide
	if(Images_Timer = 1 or Images_Timer = ""){
			GuiControl, 3:, Images_Timer, 0
		}
	if(Duration_Timer = 1){
			GuiControl, 3:Disable, Deadline
			GuiControl, 3:Disable, Timelimit
			GuiControl, 3:Disable, DeadlineActiontaken
			GuiControl, 3:Disable, iCount_T1
			GuiControl, 3:Disable, iCount_T2
			GuiControl, 3:Disable, iCount_T3
			GuiControl, 3:Enable, Limit
			GuiControl, 3:Enable, MB_Second
		}
	Gui, 3:Submit, Nohide
	return

;----------------------------------------------------------------------------

; Function:				setHK
; Description:			Activates or disables hotkeys, saves hotkey to ini and creates a traytip.

setHK(num,INI,GUI){
	If INI
		{
			Hotkey, %INI%, Hotkey%num%, Off
		}
	If GUI
		{
			if (num = 4)
				{
					Hotkey, %GUI%, Hotkey%num%, On . T2
				}
			Else
				{
					Hotkey, %GUI%, Hotkey%num%, On . T1
				}
		}
	savedHK%num% := HK%num%
	TrayTip, Hotkey %num%,% !INI ? GUI " ON" : !GUI ? INI " OFF" : GUI " ON`n" INI " OFF"
}

;----------------------------------------------------------------------------

; Label:				SettingsTab
; Description:			Prevents viewing tab 12 in Gui 3 settings by showing the last tab instead. Updates free space listbox.

SettingsTab:
	Gui +OwnDialogs
	NextTab := SettingsTab
   	GuiControlGet, SettingsTab
   	If (SettingsTab = 12)
   		{
			GuiControl, 3:Choose, %A_GuiControl%, %NextTab%
   		}
	GuiControl % (SettingsTab = "1") ? "Show" : "Hide", AutoCropTab
	GuiControl MoveDraw, SettingsTab
	If (SettingsTab = 3)
		{
			GuiControl,3:, LB_DriveSpace, |
			DriveGet, DriveList, List
			Loop, Parse, DriveList
				{
					; DriveGet, OutputVar, Type, % A_LoopField . ":\"
					; If Outputvar in Fixed ; Unknown,Removable,Network,Fixed,CDROM,RAMDisk
					If A_LoopField in C,D
						{
							GuiControl,3:, LB_DriveSpace, % A_LoopField . ":\  " . GetDiskFreeSpaceEx(A_LoopField . ":\").Free
						}
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				SleepTimer
; Description:			Timer Used by AutoPI label.

SleepTimer(time,ByRef cancel){
	Engage := A_TickCount
	While !cancel && A_TickCount<(Engage+time)
	Sleep 10
	cancel=
	}

;----------------------------------------------------------------------------

; Function:				StrFormatByteSizeEx
; Description:			Converts a numeric value into a string that represents the number in bytes, kilobytes, megabytes, or gigabytes, depending on the size.
;
; Notes:				https://msdn.microsoft.com/en-us/library/bb892884(v=vs.85).aspx

StrFormatByteSizeEx(Int, Flags := 0x2){
		Size := VarSetCapacity(Buf, 0x0104, 0)
		if (DllCall("shlwapi.dll\StrFormatByteSizeEx", "int64", Int, "int", Flags, "str", Buf, "uint", Size) != 0){
			Throw Exception("StrFormatByteSizeEx failed", -1)
		}
		return Buf
	}

;----------------------------------------------------------------------------

; Label:				Submit_ALL
; Description:			Saves the contents of each control to associated variable (if any) and hides the window unless the NoHide option is present.

Submit_ALL:
	Gui, Submit, Nohide
	return

;----------------------------------------------------------------------------

; Label:				Submit_All2
; Description:			Saves the contents of each control to associated variable (if any) and hides the window unless the NoHide option is present.
;
; Notes:				Previously used to update changes to tooltip text.

Submit_All2:
	Gui, Submit, Nohide
	GuiControl,3:, ListRefresh, % (ListRefresh = 1) ? "On" : "Off"
		If (ListRefresh = 1){
				LV_Update(CheckboxProperty, "1")
			}
	;ShoulderSearch_TT := "Row checkbox state determine whether or not to place shoulder in search zones.`n`nRequire:`n"Chr(183)"L & R mode.`n`nRows are compared and checked if size difference is larger than`n" . PercentageDifference . " percent.")
	Return

;----------------------------------------------------------------------------

; Label:				SuspendHK
; Description:			Toggled by menu or Button in GUI 3 - activates or deactivates all hotkeys.

SuspendHK:
	Gui, 3:Submit, Nohide
	Suspend, toggle
	if (A_IsSuspended==1)
		{
			GUIControl,3:, SuspendHK, Off
			TrayTip, Hotkeys, Off
			Menu, EEEE, unCheck, &Hotkeys`tF4
		}
	if(A_IsSuspended==0)
		{
			GUIControl,3:, SuspendHK, On
			TrayTip, Hotkeys, On
			Menu, EEEE, Check, &Hotkeys`tF4
		}
	return

;----------------------------------------------------------------------------

; Label:				3Submit_ALL
; Description:			Ternary operator On/Off. Saves the contents of each control to associated variable (if any) and hides the window unless the NoHide option is present.

3Submit_ALL:
	Gui, 3:Submit, Nohide
	GuiControl,3:, ImageFolderCheck, % (ImageFolderCheck = 1) ? "On" : "Off"
	GuiControl,3:, Crop_Check, % (Crop_Check = 1) ? "On" : "Off"
	GuiControl,3:, ListLoad, % (ListLoad = 1) ? "On" : "Off"
	GuiControl,3:, AC_Border, % (AC_Border = 1) ? "On" : "Off"
	GuiControl,3:, AC_Sweep, % (AC_Sweep = 1) ? "On" : "Off"
	GuiControl,3:, Deadline, % (Deadline = 1) ? "On" : "Off"
	return

;----------------------------------------------------------------------------

; Label:				TableEntry
; Description:			Opens Table Inputbox, Adds new or replaces duplicate format.

;	AC_OldWidth := 2362
;	AC_OldHeight := 3307

TableEntry:
	Gui 3:+OwnDialogs
	WinGetPos, Tx, Ty, Width, Height, ahk_id %GUI3%
	Tx := Tx+(Width-234)/2-1
	Ty := Ty+(Height-224)/2
	NewTableRow := TableInputBox("New Table Entry",, Appname " - Table",, "Edit", 1, Gui3,, "x" . Tx . " " . "y" . Ty,,, "+AlwaysOnTop" )
	If (!ErrorLevel){
		Loop, Parse, NewTableRow, `n `r
			{
				If (A_LoopField = ""){
						MsgBox, 262160, %Appname% - Error, Incomplete entry.
						Return
					}
				C%A_Index% := StrSplit(A_LoopField, "x", " `t`n`rabcdeghijklmnopqrstuvwyz.,")
				If (A_Index < 3){
						If (C%A_Index%[1] = "" or C%A_Index%[2] = ""){
								MsgBox, 262160, %Appname% - Error, Incomplete entry.
								Return
							}
					}
			}
		Gui, 3:Default
		LV_Modify(0, "-Select")
		TableCheck := CalcSize(3, C1[1], C1[2], AC_PPI)
		Loop, % LV_GetCount()
			{
				LV_Modify(A_Index, "Focus Vis")
				LV_GetText(Duplicate, A_Index, 1)  ; Save value of current row
				If (Duplicate = TableCheck)
					{
						LV_GetText(DuplicateW, A_Index, 3), LV_GetText(DuplicateH, A_Index, 4)
						MsgBox, 262180, % Appname, % "Table already contains " . Duplicate . " format.`n`nOld: W:" . DuplicateW . " H:" . DuplicateH . "`nNew: W:" . Round(CalcSize(4, C1[1], C2[1]),1) . " H:" . Round(CalcSize(4, C1[2], C2[2]),1) . "`n`nUpdate ?"
						IfMsgBox Yes
							{
								LV_Modify(A_Index, "+Select +Focus", CalcSize(3, C1[1], C1[2], AC_PPI), C3[1], Round(CalcSize(4, C1[1], C2[1]),1), Round(CalcSize(4, C1[2], C2[2]),1))
								Gui,1:Default
								Return
							}
						IfMsgBox No
							{
								Gui,1:Default
								Return
							}
					}
			}
		LV_Add(, CalcSize(3, C1[1], C1[2], AC_PPI), C3[1], Round(CalcSize(4, C1[1], C2[1]),1), Round(CalcSize(4, C1[2], C2[2]),1))
		Gui,1:Default
	}
Return

;----------------------------------------------------------------------------

; Label:				TableInputBox
; Description:			Custom inputbox for GUI 3 list view. (Table)

TableInputBox(Headline := "", Content := "", Title := "", Default := "", Control := "", Options := "", Owner := "", Width := "", Pos := "", Icon := "", IconIndex := 1, WindowOptions := "", Timeout := ""){
    Static InputHWND, py, p1, p2, c, cy, ch, e, ey, eh, Footer, ww, ExitCode
    Gui, New, HWNDInputHWND LabelTableInput -0xA0000
    Gui, % (Owner) ? "+Owner" . Owner : ""
    Gui, Font
    Gui, Color, White
    Gui, Margin, 10, 12
    py := 10
    Width := (Width) ? Width : 230
    If (Headline != ""){
        Gui, Font, s10 c0x003399, Segoe UI
        Gui, Add, Text, vp1 x67 y12, %Headline%
        py := 40
    }
    Gui, Font, s9 cDefault, Segoe UI
    If (Content != ""){
        Gui, Add, Link, % "vp2 x10 y" . py . " w" . (Width - 20), %Content%
    }
    GuicontrolGet, c, Pos, % (Content != "") ? "p2" : "p1"
    py := (Headline != "" || Content !="") ? (cy + ch + 16) : 22
	Gui, Add, Text, xm+5 y+19, Calculated.
    Gui, Add, % (Control != "") ? Control : "TableEdit1", % "vInput1 x100 y" . py . " w" . (Width - 115) . "h21 " . Options, %Default%
    py := (Headline != "" || Content !="") ? (cy + ch + 46) : 22
	Gui, Add, Text, xm+5 y+10, Adjusted.
    Gui, Add, % (Control != "") ? Control : "TableEdit2", % "vInput2 x100 y" . py . " w" . (Width - 115) . "h21 " . Options, %Default%
	py := (Headline != "" || Content !="") ? (cy + ch + 76) : 22
	Gui, Add, Text, xm+5 y+10, Pages.
    Gui, Add, % (Control != "") ? Control : "TableEdit3", % "vInput3 Number x100 y" . py . " w" . (Width - 115) . "h21 " . Options, %Default%
    GuiControlGet, e, Pos, Input3
    py := ey + eh + 19
    Gui, Add, Text, HWNDFooter y%py% -Background +Border ; Footer
    Gui, Add, Button, % "gTableInputOK x" . (Width - 198) . " yp+12 w80 h23 Default", &OK
    Gui, Add, Button, % "gTableInputClose xp+86 yp w80 h23", &Cancel
    Gui, Show, % "w" . Width . " " . Pos, %Title%
    Gui, +SysMenu %WindowOptions%
    If (Icon != ""){
        hIcon := LoadPicture(Icon, "Icon" . IconIndex, ErrorLevel)
        SendMessage 0x0080, 0, hIcon,, ahk_id %InputHWND% ; 0x0080 is WM_SETICON
    }
    WinGetPos,,, ww,, ahk_id %InputHWND%
    Guicontrol, MoveDraw, %Footer%, % "x-1 " . " w" . ww . " h" . 48
    If (Timeout){
        SetTimer, TableInputTIMEOUT, % Round(Timeout) * 1000
    }
    If (Owner){
        WinSet, Disable,, ahk_id %Owner%
    }
    GuiControl, Focus, Input
    Gui, Font
    WinWaitClose, ahk_id %InputHWND%
    ErrorLevel := ExitCode
    Return Input1 . "`n" . Input2 . "`n" . Input3
    TableInputESCAPE:
    TableInputCLOSE:
    TableInputTIMEOUT:
    TableInputOK:
        SetTimer, TableInputTIMEOUT, Delete
        If (Owner){
            WinSet, Enable,, ahk_id %Owner%
        }
        Gui, %InputHWND%: Submit
        Gui, %InputHWND%: Destroy
        ExitCode := (A_ThisLabel == "TableInputOK") ? 0 : (A_ThisLabel == "TableInputTIMEOUT") ? 2 : 1
    Return
}

;----------------------------------------------------------------------------

TablePathButton:
	Gui, 3:+OwnDialogs
	FileSelectFile, OutputVar, 3, %A_WorkingDir%, % Appname . " - Select Table.json", (*.json)
	If ErrorLevel
	Return
	Ext := FilesystemObj.GetExtensionName(OutputVar)
	if (Ext in "json") && (InStr(OutPutVar, "Table", false, 1, 1))
		{
			If Load(OutputVar, "r", A_FileEncoding){
					GuiControl,3:, AC_TablePath, % OutPutVar
			}Else{
					Error .= ErrorCheck(OutputVar, 1)
			}
	}Else{ 
				Error .= ErrorCheck(OutputVar, 1)
		}
	If Error
		{
			MsgBox, 262160,	%Appname% - Error, % "Unable to load:`n" Error
			Error := ""
		}
	Return

;----------------------------------------------------------------------------

; Function:				TableSearch
; Description:			Searches through TableObj for a matching Format to the one in Page Improver.

TableSearch(Format,TableObj){
    Candidatus := {}, Element := {}
    for Index, Element in TableObj {
       		Element.Format := Index . "|" . TableObj[(Index),"Pages"] . "|" . TableObj[(Index),"Resize Width"] . "|" . TableObj[(Index),"Resize Height"]
        	Element.Difference := Abs(Format-Index)
        	if (Candidatus[Candidatus.Count()].Difference > Element.Difference || Candidatus.Count() == 0){
            		Candidatus.push(Element)
        		}
    	}
    return Candidatus[Candidatus.Count()].Format
}

;----------------------------------------------------------------------------

; Function:				TableRead
; Description:			Reads Table in GUI3 and creates an object.

TableRead(ObjMode, Option := 0){
	TableList := "", FormatList := "", TableLoop := ""
	TableList := Object()
	FormatList := Object()
	If (Option = 0){
			SB_SetText("",1,1), SB_SetText("Reading Table",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
		}
	Gui, 3:Default
	Gui, Listview, List2
	Loop % LV_GetCount()
		{
			LV_GetText(TFormat, A_Index, 1)
			LV_GetText(Pages, A_Index, 2)
			LV_GetText(Resize_W, A_Index, 3)
			LV_GetText(Resize_H, A_Index, 4)
			if (TFormat = "") or (Pages = "") or (Resize_W = "") or (Resize_H = ""){
					Continue
				}Else{
					If (ObjMode = 0){
							Row := {"Pages": Pages, "Resize Width": Resize_W, "Resize Height": Resize_H}, TableList[TFormat] := Row
						}
					If (ObjMode = 1){
							Format_mm := StrSplit(TFormat, "x", "., `t`n`rabcdeghijklmnopqrstuvwxyz")
							Row := {"Pages": Pages, "Resize Width": Resize_W, "Resize Height": Resize_H}, FormatList[Format_mm[1] . Format_mm[2]] := Row
						}
				}
		}
	Gui, 1:Default
	Gui, Listview, List
	SB_SetText("",2,1)
}

;----------------------------------------------------------------------------

; Function:				Time
; Description:			Formats seconds into HH:mm:ss

Time(NumberOfSeconds){
    time := 19990101
    time += NumberOfSeconds, seconds
    FormatTime, mmss, %time%, HH:mm:ss
    return mmss
}

;----------------------------------------------------------------------------

; Label:				TreeView
; Description:			Code prevents selecting tab 12 in GUI 3 TreeView.

TreeView:
	TabID := g_tabIndex[ TV_GetSelection() ]
	if (TabID = 12){
			Return
		}Else{
			GuiControl, 3:Choose, SettingsTab, |%TabID%
			GuiControl, 3:Focus, TreeView
		}
	Return

;----------------------------------------------------------------------------

; Function:				TVAdd
; Description:			Link GUI 3 treeview with GUI 3 tabs.

TVAdd(p*){
	id := TV_Add(p*)
	g_tabIndex[id] := g_tabIndex.Count()+1
	return id
}

;----------------------------------------------------------------------------

; Function:				UpdateTable
; Description:			Updates table in GUI3 settings.
;
; Notes:				Used when clicking cancel button in GUi 3 settings.

UpdateTable(TableObj){
	SB_SetText("",1,1), SB_SetText("Removing new table entries",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	Gui, 3:Default
	Gui, Listview, List2
	GuiControl, -Redraw, List2
	LV_Delete()
	For Index, Element in TableObj {
		If (TableObj[(Index), "Pages"] = "") or (TableObj[(Index), "Resize Width"] = "") or (TableObj[(Index), "Resize Height"] = ""){
				Continue
			}Else{
				LV_Add(,Index, TableObj[(Index), "Pages"], TableObj[(Index), "Resize Width"], TableObj[(Index), "Resize Height"])
			}
		}
	GuiControl, +Redraw, List2
	Gui, 1:Default
	Gui, Listview, List
	SB_SetText("",2,1)
}

;----------------------------------------------------------------------------

; Function:				WidthHeight
; Description:			Shell Object. Uses NameSpace to create a folder object and retrieve image width and height from file.

WidthHeight(FullPath){
   SplitPath, % FullPath, Name, Dir
   If (Folder := Shell.NameSpace(Dir)) && (Item := Folder.ParseName(Name)){
    	Width := Folder.GetDetailsOf(Item, 176)
    	Height := Folder.GetDetailsOf(Item, 178)
	}
   Return ((Width != "") && (Height != "")) ? Array(RegExReplace(Width, "\D"), RegExReplace(Height, "\D")) : False
}

;----------------------------------------------------------------------------

; Function:				WM_LBUTTONDOWN
; Description:			Placeholder - Not in use

WM_LBUTTONDOWN(){
	;GUI, 4:Hide
	GuiControlGet, fCtrl, Focus
 	GuiControlGet, hCtrl, HWND, %fCtrl%
	ToolTip % "hCtrl: " . hCtrl . " fCtrl: " . fCtrl
	}

;----------------------------------------------------------------------------

; Function:				WM_MOUSEMOVE
; Description:			Activates control tooltip in the GUI.

WM_MOUSEMOVE(){
	static CurrControl, PrevControl, _TT
	CurrControl := A_GuiControl
	If (CurrControl <> PrevControl)
		{
			SetTimer, DisplayToolTip, -300
			PrevControl := CurrControl
		}
	return
	
	DisplayToolTip:
	try
			ToolTip % %CurrControl%_TT
	catch
			ToolTip
	SetTimer, RemoveToolTip, -20000
	return
}

;----------------------------------------------------------------------------

; Function:				WM_NOTIFY
; Description:			UpDown controls with non-unitary increments. Used for updown controls in GUI 3.
;
; Notes:				The "-2" option is recommended when creating non-unitary UpDown controls, because
;						it prevents a glitch that may otherwise occur when the control is greatly solicited
;						(e.g. when using the mouse wheel to scroll the value).
;						It disables the control's UDS_SETBUDDYINT style flag.
; Author:				numEric http://numeric.nerim.net/AutoHotkey/Scripts/UpDown%20-%20Non-unitary%20increments.ahk
; License:				Free.

WM_NOTIFY(wParam, lParam, Msg, hWnd){
	NMUPDOWN_NMHDR_hwndFrom	:= NumGet(lParam + 0, 0, "UInt")
	NMUPDOWN_NMHDR_idFrom 	:= NumGet(lParam + 0, 8, "UInt")
	NMUPDOWN_NMHDR_code 	:= NumGet(lParam + 0, 16, "UInt")
	NMUPDOWN_iDelta 		:= NumGet(lParam + 0, 28, "Int")
	UpDown_fIncrement := UpDown%NMUPDOWN_NMHDR_idFrom%_fIncrement
	;Msgbox, %NMUPDOWN_NMHDR_idFrom%
	If (NMUPDOWN_NMHDR_code = UDN_DELTAPOS && UpDown_fIncrement != "")
		{
			
    		If (BuddyCtrl_hWnd := DllCall("User32\SendMessage", "UInt", NMUPDOWN_NMHDR_hWndFrom, "UInt", UDM_GETBUDDY, "UInt", 0, "UInt", 0))
      			{
         			UpDown_ID := NMUPDOWN_NMHDR_idFrom
					UpDown_fRangeMin := (UpDown%UpDown_ID%_fRangeMin != "") ? UpDown%UpDown_ID%_fRangeMin : 0
        			UpDown_fRangeMax := (UpDown%UpDown_ID%_fRangeMax != "") ? UpDown%UpDown_ID%_fRangeMax : UpDown_fRangeMin + Abs(UpDown_fIncrement) * 100
         			ControlGetText, BuddyCtrl_Text, , ahk_id %BuddyCtrl_hWnd%
         			BuddyCtrl_Text += NMUPDOWN_iDelta * UpDown_fIncrement
         			BuddyCtrl_Text := (BuddyCtrl_Text < UpDown_fRangeMin) ? UpDown_fRangeMin : (BuddyCtrl_Text > UpDown_fRangeMax) ? UpDown_fRangeMax: BuddyCtrl_Text
					If BuddyCtrl_Text is Float
					BuddyCtrl_Text := Round(BuddyCtrl_Text,1)
					ControlSetText, , %BuddyCtrl_Text%, ahk_id %BuddyCtrl_hWnd%
         			; Done; discard proposed change
         			Return True
      			}
     		 Else
      			{
         			; No buddy control
         			Return False
      			}
   		}
	Else
   		{
      		; Not UDN_DELTAPOS, or unit-incremented UpDown control
      		Return INTEGER
   		}
}

;----------------------------------------------------------------------------
;	Start AutoPI
;----------------------------------------------------------------------------

; Label:				Start
; Description:			Checks var's before running the script.

Start:
	Gui +OwnDialogs
	Guictrls(0,0,1)
	;Update_PI_Controls()
	ContinueScript := 0, ErrorClosed := 0
	StartError := 0, Stop := 0
	Error := "", ErrorFolder := ""
	Skip_Folder := "", Skipped := 0, Skip_Check := 0
	RetryProfile := 0, PreviousProfile := "" 
	LastComplete := "", LastRun := ""
	nFolder := "", B_Index := 0
	Multiplier := (Pi_Mode = "L & R on One Image") ? 2 : 1
	RowNumber := 0
	LV_GetText(Folder,1,1)
	If (Folder = "")
		{
			MsgBox, 262208, %Appname% - Info, List is empty.
			Guictrls(1,1,0)
			Return
		}
	if !Check(Folder)
		{
			MsgBox, 262160, %Appname% - Start, %Folder%`nis empty.
			Guictrls(1,1,0)
			Return
		}
	Else
		{
			DriveSpaceFree, Freespace, %Folder%
			If (Freespace < Disk_Space)
				{	
					MsgBox, 262160, %Appname% - Error, Free drive space is below %Disk_Space%
					Guictrls(1,1,0)
					Return
				}
		}
	if (CheckboxProperty != "Checked")
		{
			LV_Modify(0, "-Select")
		}
	SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	;	Main Branch
	if (!mBranch_T1)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#1."
		}
	if (!mBranch_T2)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#2."
		}
	if (!mBranch_T3)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#3."
		}
	if (!mBranch_T4)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#4."
		}
	if (!mBranch_T5)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#5."
		}
	if (!mBranch_T6)
		{
			StartError := 1
			Error .= "`nDelay/Main Branch/#6."
		}
	;	Restart Branch
	if (!cBranch_T1)
		{
			StartError := 1
			Error .= "`nDelay/Restart Branch/#1."
		}
	if (!cBranch_T2)
		{
			StartError := 1
			Error .= "`nDelay/Restart Branch/#2."
		}
	if (!cBranch_T3)
		{
			StartError := 1
			Error .= "`nDelay/Restart Branch/#3."
		}
	if (!cBranch_T4)
		{
			StartError := 1
			Error .= "`nDelay/Restart Branch/#4."
		}
	;	Drive Space
	if (!Disk_Space)
		{
			StartError := 1
			Error .= "`nDrive Space/Free Drive Space."
		}
	;	Mouse Coordinates
	if (!xMC_Local_Navigator)
		{
			StartError := 1
			Error .= "`nMouse coordinates/X-axis Local Navigator."
		}
	if (!yMC_Local_Navigator)
		{
			StartError := 1
			Error .= "`nMouse coordinates/Y-axis Local Navigator."
		}
	If(Pi_Mode = "L & R on One Image") or (Pi_Mode = "L & R on Two Images")
		{
			if (ShoulderSearch = 1)
				{
					if (!xMC_Left_Image)
						{
							StartError := 1
							Error .= "`nMouse coordinates/X-axis Left Shoulder."
						}
					if (!yMC_Left_Image)
						{
							StartError := 1
							Error .= "`nMouse coordinates/Y-axis Left Shoulder."
						}
					if (!xMC_Right_Image)
						{
							StartError := 1
							Error .= "`nMouse coordinates/X-axis Right Shoulder."
						}
					if (!yMC_Right_Image)
						{
							StartError := 1
							Error .= "`nMouse coordinates/Y-axis Right Shoulder."
						}
				}
		}
	;	Page Improver
	if (cBranch_A1 = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Path."
		}
	if (mBranch_A1 = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Process."
		}
	if (mBranch_A2 = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Title."
		}
	If (Pi_Mode = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Mode."
		}
	If (Output_Folder = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Output."
		}
	If (Output_Action = "")
		{
			StartError := 1
			Error .= "`nPage Improver/Existing Files."
		}
	If (!Conditional_Branch)
		{
			If (Initial_Restart = 1)
				{
					StartError := 1
					Error .= "`nPage Improver/Restart Branch Off - Initial Restart On."
				}
			If (Apply_Effect = 1)
				{
					StartError := 1
					Error .= "`nPage Improver/Restart Branch Off - Apply Effect On."
				}
			If (AutoCrop = 1)
				{
					StartError := 1
					Error .= "`nPage Improver/Restart Branch Off - AutoCrop On."
				}
		}
	;	Automatic Crop
	IF (AutoCrop = 1)
		{
			If (AC_Manual = "") or (AC_Table = "") or (AC_Manual = AC_Table)
				{
					StartError := 1
					Error .= "`nAutocrop/Settings/Choose Manual or Table."
				}
			if (AC_Table = 1)
				{
					TableRead(1)
					if (FormatList.Count() = "")
						{
							StartError := 1
							Error .= "`nAutoCrop/Table object is empty."		
						}
				}
			If (AC_Manual = 1)
				{
					if (AC_HeightAdjust = "")
						{
							StartError := 1
							Error .= "`nAutoCrop/Height Adjustment error."
						}
					if (AC_WidthAdjust = "")
						{
							Error .= "`nAutoCrop/Width Adjustment error."
						}
				}
			if (PI_Mode != "L & R on One Image")
				{
					StartError := 1
					Error .= "`nPage Improver/Automatic Crop is only compatible with L & R on One Image."
				}
			If (Initial_Restart = 0)
				{
					StartError := 1
					Error .= "`nPage Improver/Automatic Crop needs Initial Restart."
				}
			if (ShoulderSearch = 0)
				{
					StartError := 1
					Error .= "`nPage Improver/Automatic Crop needs Shoulder Search."
				}
		}
	;	Progress
	if(Duration_Timer = "") or (Images_Timer = "") or (Images_Timer = Duration_Timer)
		{
			StartError := 1
			Error .= "`nProgress/Choose Image or Timer."
		}
	if(Images_Timer = 1) && (Duration_Timer = 0)
		{
			if (DeadlineActiontaken = "Continue") && (Conditional_Branch = 0)
				{
					StartError := 1
					Error .= "`nImages/Restart Branch Off - Action taken: Continue."
				}
			if (!iCount_T1)
				{
					StartError := 1
					Error .= "`nImages/Delay (sec) - Start is empty."
				}
			if (!iCount_T2)
				{
					StartError := 1
					Error .= "`nImages/Delay (sec) - Interval is empty."
				}
			if (!iCount_T3)
				{
					StartError := 1
					Error .= "`nImages/Delay (sec) - End is empty."
				}
			if (!Output_Folder)
				{
					StartError := 1
					Error .= "`nPage Improver/Output Folder is empty."
				}
		}
	IF (Duration_Timer = 1) && (Images_Timer = 0)
		{
			If (!Limit)
				{
					StartError := 1
					Error .= "`nTimer/Minimum Execution Time."
				}
			If (!MB_Second)
				{
					StartError := 1
					Error .= "`nTimer/Page Improver Crop Speed."
				}
		}
	;	Send Mode
	if (Control_Send = "") or (Send_Input = "") or (Send_Event = "") ;(Send_Input = Send_Event) ; <>
		{
			StartError := 1
			Error .= "`nSend Mode/Choose Send mode."
		}
	If (Send_Event = 1) && (Send_Input = 0)
		{
			If (KeyDelay = "")
				{
					StartError := 1
					Error .= "`nSend Mode/Key Delay."
				}
			If (PressDuration = "")
				{
					StartError := 1
					Error .= "`nSend Mode/Press Duration."
				}
		}
	if (StartError = 1)
		{
			SB_SetText("Incomplete settings",2,1)
			MsgBox, 262160, %Appname% - Error, % "Incomplete settings:`n" Error
			Guictrls(1,1,0), Error := ""
			Return
		}
	If (Images_Timer = 1) && (Duration_Timer = 0)
		{
			If(Output_Action = "Overwrite")
				{
					MsgBox, 262180, %Appname%, If existing images in %Output_Folder% are equal to full,`nrows are ignored with current setting.`n`nContinue?
					ifmsgbox no
						{
							Guictrls(1,1,0)
							Return
						}
				}
			If (!Deadline)
				{
					MsgBox, 262436, %Appname%, Continue without a time limit?
					ifmsgbox no
						{
							Guictrls(1,1,0)
							Return
						}
				}
			If(Send_Input = 1) or (Send_Event = 1){
					Gosub, AutoPI
				}
			If (Control_Send = 1){
					Gosub, AutoPI2
				}
		}
	If (Images_Timer = 0) && (Duration_Timer = 1)
		{
			If(Send_Input = 1) or (Send_Event = 1){
					Gosub, AutoPI
				}
			If (Control_Send = 1){
					Gosub, AutoPI2
				}
		}
	Return

;----------------------------------------------------------------------------

; Label:				Stop
; Description:			Used by Stop button in GUI 1 and stops AutoPI.

Stop:
	Counter.Stop()
	Pause, Off
	Stop := 1, Engage := 0, Filecount := "", Pausevar := 0
	SetTimer,ProgressAnimation,Off
	SB_SetProgress(0,3,"hide")
	SB_SetText("",1,1), SB_SetText("",2,1), SB_SetText("",3,1), SB_SetText("",4,1)
	Guictrls(1,1,0)
	Return

;----------------------------------------------------------------------------
;	Main Script - WinActive
;----------------------------------------------------------------------------

; Label:				AutoPI
; Description:			Script that runs Page Improver.
;
; Test code:
/*
	; Test
	Gui +OwnDialogs
	AC_OldWidth := 2362
	AC_OldHeight := 3307
	AC_Format := CalcSize(2, AC_OldWidth, AC_OldHeight, AC_PPI)
	AC_Match := StrSplit(TableSearch(AC_Format, FormatList), "|")
	msgbox % "S: "AC_Match[1]"`nW: "AC_Match[3]"`nH: "AC_Match[4]
	msgbox % Floor(AC_OldWidth-(AC_OldWidth*(AC_Match[3]/100)))
	msgbox % Floor(AC_OldHeight-(AC_OldHeight*(AC_Match[4]/100)))
	If (AC_Manual_sDDL = "Millimeter"){
		AC_Temp := StrSplit(CalcSize(5, AC_WidthAdjust, AC_HeightAdjust, AC_PPI), "|")
		AC_NewWidth := (AC_OldWidth-(AC_Temp[1]))
		AC_NewHeight := (AC_OldHeight-(AC_Temp[2]))
		msgbox % AC_Temp[1]
	}
	If (AC_Manual_sDDL = "Percent"){
		AC_NewWidth := Floor(AC_OldWidth-(AC_OldWidth*(AC_WidthAdjust/100)))
		AC_NewHeight := Floor(AC_OldHeight-(AC_OldHeight*(AC_HeightAdjust/100)))
	}
	If (AC_Manual_sDDL = "Pixel"){
		AC_NewWidth := (AC_OldWidth-(AC_WidthAdjust))
		AC_NewHeight := (AC_OldHeight-(AC_HeightAdjust))
	}
	Guictrls(1,1,0)
	Return
*/

AutoPI:
	Gui +OwnDialogs
	GoSub, Select
	Beginning := A_TickCount
	; While stop < 1
	Loop,
		{
			B_Index++
			If (CheckboxProperty = "Checked"){
					RowNumber := LV_GetNext(RowNumber)
					if RowNumber
						{
							LV_GetText(Folder,RowNumber,1)
							LV_GetText(Profile,RowNumber,2)
							LV_GetText(Images,RowNumber,3)
							LV_GetText(Timer,RowNumber,5)
						}
					Else
						{
							Folder := ""
						}
				}
			Else
				{
					LV_GetText(Folder,B_Index,1)
					LV_GetText(Profile,B_Index,2)
					LV_GetText(Images,B_Index,3)
					LV_GetText(Timer,B_Index,5)
				}
			If (Folder != "")
					{
						Overwrite := 0
						Loop,
							{
								if (Stop = 1)
								Return
								if !Check(Folder)
									{
										If (CheckboxProperty = "Checked"){
												LV_Delete(RowNumber)
												LV_Update("GetCount")
												RowNumber := LV_GetNext(RowNumber)
												if RowNumber
													{
														LV_GetText(Folder,RowNumber,1)
														LV_GetText(Profile,RowNumber,2)
														LV_GetText(Images,RowNumber,3)
														LV_GetText(Timer,RowNumber,5)
													}
												Else
													{
														Folder := ""
														Break
													}
											}
										Else
											{
												LV_Delete(B_Index)
												LV_Update("GetCount")
												LV_GetText(Folder,B_Index,1)
												LV_GetText(Profile,B_Index,2)
												LV_GetText(Images,B_Index,3)
												LV_GetText(Timer,B_Index,5)
												If (Folder = "")
												Break
											}
									}
								Else
									{
										DriveSpaceFree, Freespace, %Folder%
										If (Freespace < Disk_Space)
											{
												SB_SetText("Error. Not enough free drive space",2,1) SB_SetText("",4,1)
												MsgBox, 262160, %Appname% - Error, Free drive space is below %Disk_Space%
												Guictrls(1,1,0)
												Return
											}
										Else
											{
												if (Stop = 1)
												Return
												ControlGet, Selected_Output_Folder, Choice, , , ahk_id %Output_FolderHWND%
												Cropfolder := (Folder . "\" . Selected_Output_Folder)
												ComObjError(False)
												Filecount := "", Filecount := FilesystemObj.GetFolder(Cropfolder).Files.Count
												ComObjError(True)
												if (Filecount)
														{
															If (Output_Action = "Delete")
																{
																	FileRemoveDir, %Cropfolder%, 1
																	if ErrorLevel
																		{
																			MsgBox, 262160,	%Appname% - Error, Unable to remove existing files:`n%Cropfolder%
																			Guictrls(1,1,0)
																			Return
																		}
																	Break
																}
															If (Output_Action = "Overwrite")
																{
																	If (Images_Timer = 1)
																		{
																			If (Filecount >= (Images*Multiplier))
																				{
																					If (CheckboxProperty = "Checked"){
																							B_Index++
																							Skipped++
																							Skip_Check := 1
																							Skip_Folder .= "`n"(Folder)
																							RowNumber := LV_GetNext(RowNumber)
																							if RowNumber
																								{
																									LV_GetText(Folder,RowNumber,1)
																									LV_GetText(Profile,RowNumber,2)
																									LV_GetText(Images,RowNumber,3)
																									LV_GetText(Timer,RowNumber,5)
																								}
																							Else
																								{
																									Folder := ""
																									Break
																								}
																						}
																					Else
																						{
																							B_Index++
																							Skipped++
																							Skip_Check := 1
																							Skip_Folder .= "`n"(Folder)
																							LV_GetText(Folder,B_Index,1)
																							LV_GetText(Profile,B_Index,2)
																							LV_GetText(Images,B_Index,3)
																							LV_GetText(Timer,B_Index,5)
																							If (Folder = "")
																							Break
																						}
																				}
																			Else
																				{
																					Overwrite := 1
																					Break			
																				}
																		}
																	Else
																		{
																			Overwrite := 1
																			Break
																		}
																}
															If (Output_Action = "Skip")
																{
																	If (CheckboxProperty = "Checked"){
																		B_Index++
																		Skipped++
																		Skip_Check := 1
																		Skip_Folder .= "`n"(Folder)
																		RowNumber := LV_GetNext(RowNumber)
																		if RowNumber
																			{
																				LV_GetText(Folder,RowNumber,1)
																				LV_GetText(Profile,RowNumber,2)
																				LV_GetText(Images,RowNumber,3)
																				LV_GetText(Timer,RowNumber,5)
																			}
																		Else
																			{
																				Folder := ""
																				Break
																			}
																	}
																Else
																	{
																		B_Index++
																		Skipped++
																		Skip_Check := 1
																		Skip_Folder .= "`n"(Folder)
																		LV_GetText(Folder,B_Index,1)
																		LV_GetText(Profile,B_Index,2)
																		LV_GetText(Images,B_Index,3)
																		LV_GetText(Timer,B_Index,5)
																		If (Folder = "")
																		Break
																	}
																}
														}
													Else
														{
															Break
														}
											}
									}
							}
						if (Stop = 1)
						Return
					}
			If(Folder = "")
					{
						Ending := ((A_TickCount - Beginning)/1000)
						If (Error != "") && (Skipped = 0)
							{
								If (Error = (B_Index-1))
									{
										SB_SetText("",1,1) SB_SetText("Error:  " Error . "  |  Time Elapsed  "Time(Ending),2,1)
									}
								Else
									{
										SB_SetText("`t"B_Index-1-Error,1,1) SB_SetText("Completed  |  Error:  " Error . "  |  Time Elapsed  "Time(Ending),2,1)
									}
								if FileExist("C:\Windows\media\Alarm03.wav"){
										SoundPlay, C:\Windows\media\Alarm03.wav
									}
								If (Error = 1)
									{
										MsgBox, 262144, %Appname%, Finished with %Error% error:`n%ErrorFolder%
									}
								Else
									{
										MsgBox, 262144, %Appname%, Finished with %Error% errors:`n%ErrorFolder%
									}
								Guictrls(1,1,0)
								return
							}
						If (Error != "") && (Skipped)
							{
								If (Error = (B_Index-1-Skipped))
									{
										SB_SetText("",1,1) SB_SetText("Error:  " Error . "  |  Skip:  " Skipped . "  |  Time Elapsed  "Time(Ending),2,1)
									}
								Else
									{
										SB_SetText("`t"B_Index-1-Error-Skipped,1,1) SB_SetText("Completed  |  Error:  " Error . "  |  Skip:  " Skipped . "  |  Time Elapsed  "Time(Ending),2,1)
									}
								if FileExist("C:\Windows\media\Alarm03.wav"){
										SoundPlay, C:\Windows\media\Alarm03.wav
									}
								If (Error = 1)
									{
										MsgBox, 262144, %Appname%, Finished with %Error% error:`n%ErrorFolder%`n`nIgnored: %Skipped%`n%Skip_Folder%
									}
								Else
									{
										MsgBox, 262144, %Appname%, Finished with %Error% errors:`n%ErrorFolder%`n`nIgnored: %Skipped%`n%Skip_Folder%
									}
								Guictrls(1,1,0)
								return
							}
						if (Skipped)
							{
									SB_SetText("`t"B_Index-1-Skipped,1,1) SB_SetText("Completed  |  Skip:  " Skipped . "  |  Time Elapsed   "Time(Ending),2,1)
									if FileExist("C:\Windows\media\Alarm03.wav"){
											SoundPlay, C:\Windows\media\Alarm03.wav
										}
									If (Skipped = 1)
										{
											MsgBox, 262144, %Appname%, Finished with %Skipped% ignored folder.`n%Skip_Folder%
										}
									Else
										{
											MsgBox, 262144, %Appname%, Finished with %Skipped% ignored folders.`n%Skip_Folder%
										}
									Guictrls(1,1,0)
									return	
							}
						SB_SetText("`t"B_Index-1,1,1) SB_SetText("Completed  |  Time Elapsed   "Time(Ending),2,1)
						if FileExist("C:\Windows\media\Alarm03.wav"){
								SoundPlay, C:\Windows\media\Alarm03.wav
							}
						;Gui, Splash:Show, NoActivate w81 h45, % "       "Appname
						;ControlSetText,, % "Completed`n   "Time(Ending), ahk_id %CompletedHWND%
						Guictrls(1,1,0)
						return
					}
				If (CheckboxProperty = "Checked")
					{
						LV_Modify(RowNumber, "+Focus Vis")
				}Else{
						LV_Modify(0, "-Select")
						LV_Modify(B_Index, "+Select +Focus Vis")
					}
				SB_SetText("`t#"B_Index,1,1)
				if(Profile = "")
					{
						SB_SetText("Error.",2,1)
						MsgBox, 262160, %Appname% - Error, Profile %B_Index% is empty.
						Guictrls(1,1,0)
						return
					}
				if(Images = "") && (Images_Timer = 1)
					{
						SB_SetText("Error.",2,1)
						MsgBox, 262160, %Appname% - Error, Images %B_Index% is empty.
						Guictrls(1,1,0)
						return
					}
				;	Continue if Timer = "" and image_timer=1?
				if(Timer = "")
					{
						SB_SetText("Error.",2,1)
						MsgBox, 262160, %Appname% - Error, Timer %B_Index% is empty.
						Guictrls(1,1,0)
						return
					}
				SB_SetText(Folder,2,1)
				SplitPath, Folder,,,,, OutDrive
				SB_SetText("Free space: " . GetDiskFreeSpaceEx(OutDrive . "\").Free,3,1)
				if (Stop = 1)
				Return
				if (B_Index != 1) && (LastComplete != "") && (Skip_Check = 1) && (CheckboxProperty = "Percentage difference")
					{
						Object := []
						LastRun := % (F:=strsplit(LastComplete,"`n"))[F.length()]
						Loop, 2
							{
								If(LastRun)
									{
										FolderValue := LastRun, LastRun := ""
									}
								Else
									{
										LV_GetText(FolderValue,B_Index-2+A_Index,1)
									}
								Loop Parse, FolderValue, `n
									{
										If (A_LoopField != "")
											{
												ComObjError(False)
												Filecount := FilesystemObj.GetFolder(FolderValue).Files.Count
												ComObjError(True)
												If (Filecount != "")
													{
														loop, %A_LoopField%\*.*
														FolderSizeMB += (A_LoopFileSize/1048576)
														FilesizeMB := (FolderSizeMB/Filecount)
														Object.InsertAt(A_Index, FilesizeMB)
														FolderSizeMB := "", FilesizeMB := "", FileCount := "", FolderValue := ""
													}
											}
									}
							}
						Count := Object.Count()
						If (Count = 2)
							{
								Valuediff := Abs((Object[1]-Object[2])/((Object[1]+Object[2])/2)*100)
								if (Valuediff >= PercentageDifference)
									{
										LV_Modify((B_Index),"+Check")
									}
								Else
									{
										LV_Modify((B_Index),"-Check")
									}
							}
						Object := "", Count := "", Skip_Check := 0
						if (Stop = 1)
						Return
					}
				If Winexist("ahk_exe" . mBranch_A1) && (Conditional_Branch = 1) && (Initial_Restart = 1) && (A_Index = 1)
					{
						Process, Close, %mBranch_A1%
						WinWaitClose, %mBranch_A2%,, %cBranch_T4%
						if ErrorLevel
							{
								SB_SetText("Error.",2,1), SB_SetText("",3,1)
								MsgBox, 262160, %Appname% - Error, WinWaitClose 1 Timed Out.`n`nTitle: %mBranch_A2%
								Guictrls(1,1,0)
								Return
							}
						SleepTimer(cBranch_T1,CancelNow)
						if (Stop = 1)
						Return
					}
				if Winexist("ahk_exe" . mBranch_A1) && (Conditional_Branch = 1) && (ContinueScript = 1)
					{
						Process, Close, %mBranch_A1%
						WinWaitClose, %mBranch_A2%,, %cBranch_T4%
						if ErrorLevel
							{
								SB_SetText("Error.",2,1), SB_SetText("",3,1)
								MsgBox, 262160, %Appname% - Error, WinWaitClose 2 Timed Out.`n`nTitle: %mBranch_A2%
								Guictrls(1,1,0)
								Return
							}
						SleepTimer(cBranch_T1,CancelNow)
						if (Stop = 1)
						Return
					}
/*
				if Winexist("ahk_exe" . mBranch_A1) && (AutoCrop = 1) && (ShoulderSearch = 1) && (Conditional_Branch = 1) && (ContinueScript = 0) && (ErrorClosed = 0) && (A_Index > 1)
					{
						FolderChecked := Lv_GetNext(B_Index -1, "Checked")
						If (B_Index = FolderChecked)
							{
								Process, Close, %mBranch_A1%
								WinWaitClose, %mBranch_A2%,,%cBranch_T4%
								if ErrorLevel
									{
										SB_SetText("Error.",2,1)
										MsgBox, 262160, %Appname% - Error, WinWaitClose 3 Timed Out.`n`nTitle: %mBranch_A2%
										Guictrls(1,1,0)
										Return
									}
								SleepTimer(cBranch_T1,CancelNow)
								if (Stop = 1)
								Return
							}
					}
*/
				Conditional_Path := 0, ContinueScript := 0, ErrorClosed := 0
				Start_Images := 0, Start_Timer := 0
				Extra_sTime_1 := 0, Extra_sTime_2 := 0, Extra_sTime_3 := 0, PauseVar := 0
				if Winexist("ahk_exe" . mBranch_A1)
					{
						WinActivate, ahk_exe %mBranch_A1%
						WinWaitActive, %mBranch_A2%,,%mBranch_T6%
						if ErrorLevel
							{
								SB_SetText("Error.",2,1), SB_SetText("",3,1)
								MsgBox, 262160, %Appname% - Error, WinWaitActive 1 Timed Out.`n`nTitle: %mBranch_A2%
								Guictrls(1,1,0)
								Return
							}
					}
				else
					{
						if (Conditional_Branch = 0)
							{
								SB_SetText("Error.",2,1), SB_SetText("",3,1)
								MsgBox, 262160, %Appname% - Error, %mBranch_A1% isn't running and restart Branch is disabled.
								Guictrls(1,1,0)
								Return
							}
						Else if !FileExist(cBranch_A1)
									{
										SB_SetText("Error.",2,1), SB_SetText("",3,1)
										MsgBox, 262160, %Appname% - Error, Can't find:`n%cBranch_A1%
										Guictrls(1,1,0)
										Return
									}
								Else if FileExist(cBranch_A1)
									{
										Run, %cBranch_A1%,, Max UseErrorLevel
										if (ErrorLevel){
												SB_SetText("Error.",2,1), SB_SetText("",3,1)
												MsgBox, 262160, %Appname% - Error, Could not open %cBranch_A1%
												Guictrls(1,1,0)
												Return
											}
										;WinActivate, ahk_exe %mBranch_A1%
										WinWaitActive, %mBranch_A2%,,%mBranch_T6%
										if (ErrorLevel){
												SB_SetText("Error.",2,1), SB_SetText("",3,1)
												MsgBox, 262160, %Appname% - Error, WinWaitActive 2 Timed Out.`n`nTitle: %mBranch_A2%
												Guictrls(1,1,0)
												Return
											}
										Conditional_Path := 1, AC_SysTabControl32 := "", AC_EffectsComboBox := ""
										SleepTimer(cBranch_T1,CancelNow)
										if (Stop = 1)
										Return
										if WinActive("ahk_exe" . mBranch_A1)
											{
												SendInput, {LAlt Down}
												SleepTimer(cBranch_T3,CancelNow)
												if (Stop = 1)
													{
														SendInput, {LAlt UP}
														Return
													}
												SendInput, o
												SleepTimer(cBranch_T3,CancelNow)
												if (Stop = 1)
													{
														SendInput, {LAlt UP}
														Return
													}
												If(Pi_Mode = "Single Pages")
													{
														SendInput, s
														If (AutoCrop = 0) && (Apply_Effect = 1)
															{
																SendRight := 8, SendTab1 := 13, SendTab2 := 2, SendLeft := 5
															}
													}
												If(Pi_Mode = "L & R on One Image")
													{
														SendInput, o
														If (AutoCrop = 0) && (Apply_Effect = 1)
															{
																SendRight := 8, SendTab1 := 12, SendTab2 := 3, SendLeft := 5
															}
													}
												If (Pi_Mode = "L & R on Two Images")
													{
														SendInput, t
														If (AutoCrop = 0) && (Apply_Effect = 1)
															{
																SendRight := 10, SendTab1 := 12, SendTab2 := 4, SendLeft := 5
															}
													}
												SleepTimer(cBranch_T3,CancelNow)
												SendInput, {LAlt Up}
												if (Stop = 1)
												Return
												SleepTimer(mBranch_T1,CancelNow)
												if (Stop = 1)
												Return
												SendInput, {Click left, %xMC_Local_Navigator%, %yMC_Local_Navigator%, 1}
												SleepTimer(cBranch_T2,CancelNow)
												if (Stop = 1)
												Return
											}
										If WinActive("ahk_exe" . mBranch_A1) && (AutoCrop = 1)
											{
												Get_PI_Controls(1)
												If(Pi_Mode = "L & R on One Image")
													{
														If (AC_SysTabControl32 = "")
															{
																SB_SetText("Error.",2,1), SB_SetText("",3,1)
																MsgBox, 262160, %Appname%, Error retrieving Tab Control from Page Improver.
																Guictrls(1,1,0)
																return
															}
														;   Select Effects Tab
														SendMessage, 0x1330, 8,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
														Sleep 0
														SendMessage, 0x130C, 8,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
														SleepTimer(cBranch_T3,CancelNow)
														Get_PI_Controls(2)
														If (AC_EffectsComboBox = "")
															{
																SB_SetText("Error.",2,1), SB_SetText("",3,1)
																MsgBox, 262160, %Appname%, Error retrieving ComboBox Control from Page Improver.
																Guictrls(1,1,0)
																return
															}
														If (Apply_Effect = 1)
															{
																Control, ChooseString, % Effects, % AC_EffectsComboBox, ahk_exe %mBranch_A1%
															}
														SleepTimer(cBranch_T3,CancelNow)
														;   Select Crop Tab
														SendMessage, 0x1330, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
														Sleep 0
														SendMessage, 0x130C, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
													}
												if (Stop = 1)
												Return
											}
										if WinActive("ahk_exe" . mBranch_A1) && (AutoCrop = 0) && (Apply_Effect = 1)
											{
												BlockInput, On
												SendInput, {DOWN}
												Loop % SendRight
													{
														Sleep 50
														SendInput, {RIGHT}
													}
												SleepTimer(cBranch_T3,CancelNow)
												Loop % SendTab1
													{
														Sleep 50
														SendInput, {TAB}
													}
												If (Effects = "Bluring"){
													SendInput, B
													SleepTimer(cBranch_T3,CancelNow)
												}
												If (Effects = "Edges"){
													SendInput, E
													SleepTimer(cBranch_T3,CancelNow)
													SendInput, E
												}
												If (Effects = "Emboss"){
													SendInput, E
													SleepTimer(cBranch_T3,CancelNow)
												}
												If (Effects = "Sharpening 1"){
													SendInput, S
													SleepTimer(cBranch_T3,CancelNow)
												}
												If (Effects = "Sharpening 2"){
													SendInput, S
													SleepTimer(cBranch_T3,CancelNow)
													SendInput, S
												}
												Loop % SendTab2
													{
														Sleep 50
														SendInput, {TAB}
													}
												Loop % SendLeft
													{
														Sleep 50
														SendInput, {LEFT}
													}
												BlockInput, Off
											}
									}
					}
			cTime := StrSplit(Timer, ":")
			Seconds := (cTime.1 * 3600) + (cTime.2 * 60 + cTime.3)
			sTime := Seconds * 1000
			ProgressTimer := (Seconds - 1) * 10
			BeforeFileCount := (iCount_T1*1000)
			Filecountinterval := (iCount_T2*1000)
			AfterFileCount := (iCount_T3*1000)
			StringTrimRight, MaxDuration, Timelimit, 1
			if (B_Index>1) && (RetryProfile = 0) && (Profile = PreviousProfile){
					ProfileStatus := 1
				}Else{
					ProfileStatus := 0
				}
			If (AutoCrop = 1){
					ProfileStatus := 0
				}
			PreviousProfile := % Profile
			RetryProfile := 0
			SleepTimer(mBranch_T2,CancelNow)
			if (Stop = 1)
			Return
			if WinActive("ahk_exe" . mBranch_A1)
				{
					SendInput, {Click left, %xMC_Local_Navigator%, %yMC_Local_Navigator%, 1}
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
					SendInput, {LAlt Down}
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
						{
							SendInput, {LAlt UP}
							Return
						}
					SendInput, f
					SleepTimer(mBranch_T4,CancelNow)
					SendInput, {LAlt UP}
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Conditional_Path = 0)
				{
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
					Send, %Folder%
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
					Return
					SendInput, {Enter}
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Conditional_Path = 1)
				{
					SleepTimer(cBranch_T2,CancelNow)
					if (Stop = 1)
					Return
					Send, %Folder%
					SleepTimer(cBranch_T3,CancelNow)
					if (Stop = 1)
					Return
					SendInput, {LAlt Down}
					SleepTimer(cBranch_T3,CancelNow)
					if (Stop = 1)
						{
							SendInput, {LAlt UP}
							Return
						}
					SendInput, r
					SleepTimer(cBranch_T3,CancelNow)
					SendInput, {LAlt UP}
					if (Stop = 1)
					Return
					SleepTimer(cBranch_T3,CancelNow)
					SendInput, {Enter}
					SleepTimer(cBranch_T2,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && ((Conditional_Path = 1) or (ProfileStatus = 0))
				{
					SendInput, {LAlt Down}
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
						{
							SendInput, {LAlt UP}
							Return
						}
					SendInput, l
					SleepTimer(mBranch_T4,CancelNow)
					SendInput, {LAlt UP}
					if (Stop = 1)
					Return
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
					Send, %Profile%
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
					Return
					SendInput, {ENTER}
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1)
				{
					SendInput, {Click Left, %xMC_Local_Navigator%, %yMC_Local_Navigator%, 2}
					SleepTimer(mBranch_T1,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && (ShoulderSearch = 1)
				{
					If(Pi_Mode = "L & R on One Image") or (Pi_Mode = "L & R on Two Images")
						{
							SendInput, {Click Right, %xMC_Left_Image%, %yMC_Left_Image%, 1}
							SleepTimer(cBranch_T2,CancelNow)
							if (Stop = 1)
							Return
						}
				}
			if WinActive("ahk_exe" . mBranch_A1) && (ShoulderSearch = 1)
				{
					If(Pi_Mode = "L & R on One Image") or (Pi_Mode = "L & R on Two Images")
						{
							SendInput, {Click Right, %xMC_Right_Image%, %yMC_Right_Image%, 1}
							SleepTimer(cBranch_T2,CancelNow)
							if (Stop = 1)
							Return
						}
				}
			if WinActive("ahk_exe" . mBranch_A1)
				{
					SendInput, {LAlt Down}
					SleepTimer(cBranch_T3,CancelNow)
					if (Stop = 1)
						{
							SendInput, {LAlt UP}
							Return
						}
					SendInput, a
					SleepTimer(cBranch_T3,CancelNow)
					SendInput, {LAlt UP}
					SleepTimer(mBranch_T1,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && (AutoCrop = 1)
				{
					If (Pi_Mode = "L & R on One Image")
						{
							Get_PI_Controls(3)
							If (AC_CalcWidth = "") or (AC_CalcHeight = "") or (AC_LeftVcenter = "") or (AC_LeftWidth = "") or (AC_LeftHeight = "") or (AC_RightVcenter = "") or (AC_RightWidth = "") or (AC_RightHeight = "")
								{
									SB_SetText("Error.",2,1), SB_SetText("",3,1)
									MsgBox, 262160, %Appname%, Error retrieving crop controls from Page Improver.
									Guictrls(1,1,0)
									return
								}
							SendMessage, 0x1330, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
							Sleep 0
							SendMessage, 0x130C, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
							SleepTimer(mBranch_T4,CancelNow)
							If (MC_Obj[Folder,"Width"] = "") or (MC_Obj[Folder,"Height"] = "")
								{
									SendMessage, 0x0201, 0x0001,, % AC_CalcWidth, ahk_exe %mBranch_A1% ; 0x0201 is WM_LBUTTONDOWN and 0x0001 is MK_LBUTTON
									SendMessage, 0x0202,,, % AC_CalcWidth, ahk_exe %mBranch_A1% ; 0x0202 is WM_LBUTTONUP
									SendMessage, 0x0201, 0x0001,, % AC_CalcHeight, ahk_exe %mBranch_A1% ; 0x0201 is WM_LBUTTONDOWN and 0x0001 is MK_LBUTTON
									SendMessage, 0x0202,,, % AC_CalcHeight, ahk_exe %mBranch_A1% ; 0x0202 is WM_LBUTTONUP
									SleepTimer(mBranch_T4,CancelNow)
									if (Stop = 1)
									Return
									ControlGetText, AC_OldWidth, % AC_LeftWidth, ahk_exe %mBranch_A1%
									ControlGetText, AC_OldHeight, % AC_LeftHeight, ahk_exe %mBranch_A1%
									ControlGetText, AC_VcenterLeft, % AC_LeftVcenter, ahk_exe %mBranch_A1%
									ControlGetText, AC_VcenterRight, % AC_RightVcenter, ahk_exe %mBranch_A1%
									if (AC_OldHeight = "") or (AC_OldHeight = "") or (AC_VcenterLeft = "") or (AC_VcenterRight ="")
										{
											SB_SetText("Error.",2,1), SB_SetText("",3,1)
											MsgBox, 262160, %Appname%, Error retrieving crop controls from Page Improver.
											Guictrls(1,1,0)
											return
										}
								}
							Else
								{
									AC_OldWidth := MC_Obj[Folder,"Width"]
									AC_OldHeight := MC_Obj[Folder,"Height"]
								}
							PPI := (MC_Obj[Folder,"PPI"] = "") ? AC_PPI : MC_Obj[Folder,"PPI"]
							If (AC_Manual = 1)
								{
									If (AC_Manual_sDDL = "Millimeter"){
											AC_Temp := StrSplit(CalcSize(5, AC_WidthAdjust, AC_HeightAdjust, PPI), "|")
											AC_NewWidth := (AC_OldWidth-(AC_Temp[1]))
											AC_NewHeight := (AC_OldHeight-(AC_Temp[2]))
										}
									If (AC_Manual_sDDL = "Percent"){
											AC_NewWidth := Floor(AC_OldWidth-(AC_OldWidth*(AC_WidthAdjust/100)))
											AC_NewHeight := Floor(AC_OldHeight-(AC_OldHeight*(AC_HeightAdjust/100)))
										}
									If (AC_Manual_sDDL = "Pixel"){
											AC_NewWidth := (AC_OldWidth-(AC_WidthAdjust))
											AC_NewHeight := (AC_OldHeight-(AC_HeightAdjust))
										}
								}
							If (AC_Table = 1)
								{
										;AC_Format := Floor(Sqrt((AC_OldHeight**2)+(AC_OldWidth**2)))
										AC_Format := CalcSize(2, AC_OldWidth, AC_OldHeight, PPI)
										AC_Match := StrSplit(TableSearch(AC_Format, FormatList), "|")
										AC_NewWidth := Floor(AC_OldWidth-(AC_OldWidth*(AC_Match[3]/100)))
										AC_NewHeight := Floor(AC_OldHeight-(AC_OldHeight*(AC_Match[4]/100)))
								}
							ControlSetText, % AC_LeftWidth, % AC_NewWidth, ahk_exe %mBranch_A1%
							ControlSetText, % AC_LeftHeight, % AC_NewHeight, ahk_exe %mBranch_A1%
							ControlSetText, % AC_RightWidth, % AC_NewWidth, ahk_exe %mBranch_A1%
							ControlSetText, % AC_RightHeight, % AC_NewHeight, ahk_exe %mBranch_A1%
							SleepTimer(mBranch_T4,CancelNow)
							if (Stop = 1)
							Return
						}
				}
			If Winactive("ahk_exe" . mBranch_A1) && (AutoCrop = 1) && (AC_Border = 1)
				{
					If (Pi_Mode = "L & R on One Image")
						{
							Get_PI_Controls(4)
							If (AC_ImageHeight = "")
								{
									SB_SetText("Error.",2,1), SB_SetText("",3,1)
									MsgBox, 262160, %Appname%, Error retrieving image controls from Page Improver.
									Guictrls(1,1,0)
									return
								}
							SendMessage, 0x1330, 1,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
							Sleep 0
							SendMessage, 0x130C, 1,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
							SleepTimer(mBranch_T4,CancelNow)
							if (Stop = 1)
							Return
							Get_PI_Controls(5)
							If (AC_UpperMargins_L = "") or (AC_UpperMargins_R = "") or (AC_LowerMargins_L = "") or (AC_LowerMargins_R = "")
								{
									SB_SetText("Error.",2,1), SB_SetText("",3,1)
									MsgBox, 262160, %Appname%, Error retrieving border controls from Page Improver.
									Guictrls(1,1,0)
									return
								}
							AC_LeftUpperBorder := (MC_Obj[Folder,"L.TopBorder"] = "") ? Floor(((AC_ImageHeight/2)-(AC_OldHeight/2))+(AC_VcenterLeft)+(AC_UpperLeftMargin)) : MC_Obj[Folder,"L.TopBorder"]+AC_LowerRightMargin
							AC_LeftLowerBorder := (MC_Obj[Folder,"L.BottomBorder"] = "") ? Floor(((AC_ImageHeight/2)-(AC_OldHeight/2))-(AC_VcenterLeft)+(AC_LowerLeftMargin)) : MC_Obj[Folder,"L.BottomBorder"]+AC_LowerLeftMargin
							AC_RightUpperBorder := (MC_Obj[Folder,"R.TopBorder"] = "") ? Floor(((AC_ImageHeight/2)-(AC_OldHeight/2))+(AC_VcenterRight)+(AC_UpperRightMargin)) : MC_Obj[Folder,"R.TopBorder"]+AC_UpperRightMargin
							AC_RightLowerBorder := (MC_Obj[Folder,"R.BottomBorder"] = "") ? Floor(((AC_ImageHeight/2)-(AC_OldHeight/2))-(AC_VcenterRight)+(AC_LowerRightMargin)) : MC_Obj[Folder,"R.BottomBorder"]+AC_LowerRightMargin
							;msgbox, AC_ImageHeight %AC_ImageHeight%
							;msgbox, AC_OldHeight %AC_OldHeight%
							;msgbox, AC_LeftVcenter %AC_LeftVcenter%
							;msgbox, AC_RightVcenter %AC_RightVcenter%
							;msgbox, AC_LeftUpperBorder %AC_LeftUpperBorder%
							;msgbox, AC_LeftLowerBorder %AC_LeftLowerBorder%
							;msgbox, AC_RightUpperBorder %AC_RightUpperBorder%
							;msgbox, AC_RightLowerBorder %AC_RightLowerBorder%
							ControlSetText, % AC_UpperMargins_L, % AC_LeftUpperBorder, ahk_exe %mBranch_A1%
							ControlSetText, % AC_UpperMargins_R, % AC_RightUpperBorder, ahk_exe %mBranch_A1%
							ControlSetText, % AC_LowerMargins_L, % AC_LeftLowerBorder, ahk_exe %mBranch_A1%
							ControlSetText, % AC_LowerMargins_R, % AC_RightLowerBorder, ahk_exe %mBranch_A1%
							SleepTimer(mBranch_T4,CancelNow)
							if (Stop = 1)
							Return
						}
				}
			If Winactive("ahk_exe" . mBranch_A1) && (AutoCrop = 1) && (AC_Sweep = 1)
				{
					If (Pi_Mode = "L & R on One Image")
						{
							SendMessage, 0x1330, 3,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
							Sleep 0
							SendMessage, 0x130C, 3,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
							Get_PI_Controls(6)
							If (AC_UpperSweep_L = "") or (AC_UpperSweep_R = "") or (AC_LowerSweep_L = "") or (AC_LowerSweep_R = "")
								{
									SB_SetText("Error.",2,1), SB_SetText("",3,1)
									MsgBox, 262160, %Appname%, Error retrieving shoulder controls from Page Improver.
									Guictrls(1,1,0)
									return
								}
							;MsgBox, AC_UpperSweep_L %AC_UpperSweep_L%
							;msgBox, AC_UpperSweep_R %AC_UpperSweep_R%
							;MsgBox, AC_LowerSweep_L %AC_LowerSweep_L%
							;MsgBox, AC_LowerSweep_R %AC_LowerSweep_R%
							ControlSetText, % AC_UpperSweep_L, % AC_UpperLeftSweep, ahk_exe %mBranch_A1%
							ControlSetText, % AC_UpperSweep_R, % AC_UpperRightSweep, ahk_exe %mBranch_A1%
							ControlSetText, % AC_LowerSweep_L, % AC_LowerLeftSweep, ahk_exe %mBranch_A1%
							ControlSetText, % AC_LowerSweep_R, % AC_LowerRightSweep, ahk_exe %mBranch_A1%
							SleepTimer(mBranch_T4,CancelNow)
							if (Stop = 1)
							Return
						}
				}
			If Winactive("ahk_exe" . mBranch_A1) && (AutoCrop = 1)
				{
							SendMessage, 0x1330, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
							Sleep 0
							SendMessage, 0x130C, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
							SleepTimer(mBranch_T4,CancelNow)
							if (Stop = 1)
							Return
				}
			if WinActive("ahk_exe" . mBranch_A1)
				{
					SendInput, {LAlt Down}
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
						{
							SendInput, {LAlt UP}
							Return
						}
					SendInput, H
					SleepTimer(mBranch_T4,CancelNow)
					SendInput, {LAlt UP}
					if (Stop = 1)
					Return
					SleepTimer(mBranch_T3,CancelNow)
					if (Stop = 1)
					Return
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Duration_Timer = 1)
				{
					If (Overwrite = 1)
						{
							SleepTimer(mBranch_T5,CancelNow)
							if (Stop = 1)
							Return
							if WinActive("ahk_exe" . mBranch_A1)
								{
									SendInput, a
									LastComplete .= "`n"(Folder)
									Start_Timer := 1
								}
						}
					Else
						{
							SendInput, {ENTER}
							LastComplete .= "`n"(Folder)
							Start_Timer := 1
						}
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Duration_Timer = 1) && (Start_Timer = 1)
				{
					SB_SetText("",3,1)
					pp := 0, PauseVar := 1
					SetTimer, ProgressAnimation, % ProgressTimer
					SB_SetProgress(0,3,"show")
					Timer_Start := A_TickCount
					SleepTimer(sTime,CancelNow)
					if (Stop = 1)
					Return
					/*
						SleepTimer(Extra_sTime_1,CancelNow)
						if (Stop = 1)
							{
								Return
							}
						SleepTimer(Extra_sTime_2,CancelNow)
						if (Stop = 1)
							{
								Return
							}
						SleepTimer(Extra_sTime_3,CancelNow)
						if (Stop = 1)
							{
								Return
							}
					*/
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Images_Timer = 1)
				{
					If (Overwrite = 1)
						{
							SleepTimer(mBranch_T5,CancelNow)
							if (Stop = 1)
							Return
							if WinActive("ahk_exe" . mBranch_A1)
								{
									SendInput, a
									LastComplete .= "`n"(Folder)
									Start_Images := 1
								}
						}
					Else
						{
							SendInput, {ENTER}
							LastComplete .= "`n"(Folder)
							Start_Images := 1
						}
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Images_Timer = 1) && (Start_Images = 1)
				{
					SB_SetText("",3,1)
					SleepTimer(BeforeFileCount,CancelNow)
					if (Stop = 1)
					Return
					Loop, Files, %Folder%\*.*, DR
					Folderlist .= (A_LoopFileFullPath)"`n"
					If InStr(Folderlist, Cropfolder, false, 1, 1)
						{
							Folderlist := "", pp := 0, FileCount := ""
							SB_SetProgress(0,3,"show")
							If (Deadline = 1)
								{
									Counter := new AutoPiLimit, Counter.Start()
									Timer_Start := A_TickCount
								}
							Loop,
								{
									ComObjError(false)
									Filecount := FilesystemObj.GetFolder(Cropfolder).Files.Count
									if (A_LastError = -2147352567)
										{
											Gosub, Stop
											MsgBox, 262160, %Appname%, Error while counting files.`n`n%Cropfolder%
											Return
										}
									pp := Floor((FileCount/(images*Multiplier))*100)
									SB_SetText(pp " %",4,1)
									SB_SetProgress(pp,3)
   									if (pp=100) 
										{
											SB_SetProgress(0,3,"hide")
											SB_SetText("",4,1)
											Filecount := "", Counter.Stop()
											SleepTimer(AfterFileCount,CancelNow)
											if (Stop = 1){
													Return
											}Else{
													Break
												}
   										}
									SleepTimer(Filecountinterval,CancelNow)
									if (Stop = 1)
									Return
									LoopDuration := (A_TickCount-Timer_Start), Filecount := ""
									if (LoopDuration >= (sTime*MaxDuration) && Deadline = 1 && DeadlineActiontaken = "Stop")
										{
											Gosub, Stop
											MsgBox, 262160, %Appname% - Time limit, Exceeded.
											Return
										}
									if (LoopDuration >= (sTime*MaxDuration) && Deadline = 1 && DeadlineActiontaken = "Continue")
										{
											Counter.Stop()
											ContinueScript := 1, Filecount := ""
											SB_SetProgress(0,3,"hide")
											SB_SetText("",4,1)
											Break
										}
									if (Deadline = 0) && (LoopDuration >= 7200000) ; 2 Hour time limit
										{
											Gosub, Stop
											MsgBox, 262160, %Appname% - Time limit, Two hours restriction reached.
											Return
										}
								}
						}
					Else
						{
							SB_SetText("",4,1), SB_SetText("Error",2,1)
							Folderlist := ""
							MsgBox, 262160, %Appname% - Error, Can't Find %CropFolder%
							Guictrls(1,1,0)
							Return
						}
					if (Stop = 1){
							Return
						}
				}
			if WinActive("ahk_exe" . mBranch_A1) && (Start_Timer <> Start_Images)
				{
					LV_GetText(Folder,(B_Index+1),1)
					If (Folder != "")
						{
							SendInput, {ENTER}
						}
				}
			Else
				{
					IF (Error > 1)
						{
							ErrorFolder .= "`n"(Folder)
							SB_SetText("Critical Error.",2,1), SB_SetText("",3,1)
							MsgBox, 262160, %Appname% - Error 3, Too many errors encountered.`n`nIncomplete:`n%ErrorFolder%
							Guictrls(1,1,0)
							Return
						}
					If (Error = "")
						{
							Error := 1
							SB_SetText("Error.",2,1), SB_SetText("",3,1)
							LV_GetText(nFolder,(B_Index+1),1)
							if (nFolder != "")
								{
									if (Conditional_Branch = 1)
										{
											MsgBox, 262166, %Appname% - Error 1 - %Folder%, %mBranch_A1% is not active.`n`nWarning: Automatically continues in 30s`nand attempts to shutdown %mBranch_A1%, 30
											;MsgBox, 262164, %Appname% - Error 1 - %mBranch_A1% is not active, %ErrorFolder%`nIncomplete!`n`nContinue?`n`nWarning: Automatically continues in 30s`nand attempts to shutdown %mBranch_A1%, 32
											IfMsgBox, Cancel
												{
													SB_SetText("Aborted.",2,1)
													Break
												}
											IfMsgBox, TryAgain
												{
													Error := ""
													B_Index--
													RetryProfile := 1
												}
											IfMsgBox, Continue
												{
													ErrorFolder .= "`n"(Folder)
													Process, Close, %mBranch_A1%
													WinWaitClose, %mBranch_A2%,,%cBranch_T4%
													if (ErrorLevel){
															SB_SetText("Error.",2,1)
															MsgBox, 262160, %Appname% - Error, WinWaitClose 4 Timed Out.`n`nTitle: %mBranch_A2%
															Guictrls(1,1,0)
															Return
														}
													ErrorClosed := 1, ContinueScript := 0
												}
											IfMsgBox, Timeout
												{
													ErrorFolder .= "`n"(Folder)
													Process, Close, %mBranch_A1%
													WinWaitClose, %mBranch_A2%,,%cBranch_T4%
													if (ErrorLevel){
															SB_SetText("Error.",2,1)
															MsgBox, 262160, %Appname% - Error, WinWaitClose 4 Timed Out.`n`nTitle: %mBranch_A2%
															Guictrls(1,1,0)
															Return
														}
													ErrorClosed := 1, ContinueScript := 0
												}
										}
									Else
										{
											MsgBox, 262166, %Appname% - Error 1 - %Folder%, %mBranch_A1% is not active.`n`nWarning: Automatically continues in 30s, 30
											;MsgBox, 262164, %Appname% - Error 1 - %mBranch_A1% is not active, %ErrorFolder%`nIncomplete!`n`nContinue?`n`nWarning: Automatically continues in 30s, 32
											IfMsgBox, Cancel
												{
													SB_SetText("Aborted.",2,1)
													Break
												}
											IfMsgBox, TryAgain
												{
													Error := ""
													B_Index--
													RetryProfile := 1
												}
											IfMsgBox, Continue
												{
													ErrorFolder .= "`n"(Folder)
												}
											IfMsgBox, Timeout
												{
													ErrorFolder .= "`n"(Folder)
												}
										}
								}Else{
									ErrorFolder .= "`n"(Folder)
								}
						}
					Else
						{
							Error++
							SB_SetText("Error.",2,1), SB_SetText("",3,1)
							LV_GetText(nFolder,(B_Index+1),1)
							if (nFolder != "")
								{
									if (Conditional_Branch = 1)
										{
											MsgBox, 262166, %Appname% - Error 2 - %Folder%, %mBranch_A1% is not active.`n`nWarning: Automatically continues in 30s`nand attempts to shutdown %mBranch_A1%, 30
											IfMsgBox Cancel
												{
													SB_SetText("Aborted.",2,1)
													Break
												}
											IfMsgBox TryAgain
												{
													Error--
													B_Index--
													RetryProfile := 1
												}
											IfMsgBox Continue
												{
													ErrorFolder .= "`n"(Folder)
													Process, Close, %mBranch_A1%
													WinWaitClose, %mBranch_A2%,,%cBranch_T4%
													if (ErrorLevel){
															SB_SetText("Error.",2,1)
															MsgBox, 262160, %Appname% - Error, WinWaitClose 5 Timed Out.`n`nTitle: %mBranch_A2%
															Guictrls(1,1,0)
															Return
														}
													ErrorClosed := 1, ContinueScript := 0
												}
											IfMsgBox Timeout
												{
													ErrorFolder .= "`n"(Folder)
													Process, Close, %mBranch_A1%
													WinWaitClose, %mBranch_A2%,,%cBranch_T4%
													if (ErrorLevel){
															SB_SetText("Error.",2,1)
															MsgBox, 262160, %Appname% - Error, WinWaitClose 5 Timed Out.`n`nTitle: %mBranch_A2%
															Guictrls(1,1,0)
															Return
														}
													ErrorClosed := 1, ContinueScript := 0
												}
										}
									Else
										{
											MsgBox, 262166, %Appname% - Error 2 - %Folder%, %mBranch_A1% is not active.`n`nWarning: Automatically continues in 30s, 30
											IfMsgBox Cancel
												{
													SB_SetText("Aborted.",2,1)
													Break
												}
											IfMsgBox TryAgain
												{
													Error--
													B_Index--
													RetryProfile := 1
												}
											IfMsgBox, Continue
												{
													ErrorFolder .= "`n"(Folder)
												}
											IfMsgBox, Timeout
												{
													ErrorFolder .= "`n"(Folder)
												}
										}
								}Else{
									ErrorFolder .= "`n"(Folder)
								}
						}
				}
		}
	Guictrls(1,1,0)
	return
;----------------------------------------------------------------------------
;	Secondary Script - WinExist. Finish later
;----------------------------------------------------------------------------
AutoPI2:

	;	Operating modes - Menu https://docs.microsoft.com/en-us/windows/win32/menurc/menus?redirectedfrom=MSDN
	;	WinGetClass, OutputVar, ahk_pid 6752
	;	SendMessage, 0x01E1, 0, 0,, ahk_class %OutputVar% ; 0x1E1 is MN_GETHMENU 
	;	testhWnd := ErrorLevel
	;	msgbox % testhwnd
	;	VarSetCapacity(GUITHREADINFO, A_PtrSize=8?72:48, 0)
	;	NumPut(A_PtrSize=8?72:48, GUITHREADINFO, 0, "UInt")
	;	vTID := DllCall("GetWindowThreadProcessId", Ptr,hWnd, UIntP,0, UInt)
	;	DllCall("GetGUIThreadInfo", UInt,vTID, Ptr,&GUITHREADINFO)
	;	hWnd2 := NumGet(GUITHREADINFO, A_PtrSize=8?32:20, "Ptr") ; hwndMenuOwner
	;	WinGetTitle, vWinTitle, % "ahk_id " hWnd2
	;	WinGetClass, vWinClass, % "ahk_id " hWnd2
	;	hMenu2 := DllCall("user32\GetMenu", Ptr,hWnd2, Ptr)
	;	MsgBox % hWnd2 "|" vWinTitle "|" vWinClass "|" hMenu2
	;	PostMessage, 0x0111, 10, 0,, ahk_exe %mBranch_A1% ; 0x0111 is VM_COMMAND - Opens hidden window in Page Improver
	;	SendMessage, 0x01E1,,,, ahk_class %OutputVar% ;	0x1E1 is MN_GETHMENU
	;	hMenu := ErrorLevel
	;	MsgBox % hMenu
	;	PostMessage, 0x01E5, 0, 0,, ahk_class %OutputVar% ; 0x1E5 is MN_SELECTITEM
	;	sleep 2000
	;	PostMessage, 0x01F1, 2, 0,, ahk_class %OutputVar% ; 0x1F1 is MN_DBLCLK
	;	PostMessage, 0x0112, 0xF020,,, ahk_exe %mBranch_A1%; 0x0112 is WM_SYSCOMMAND, 0xF020 is SC_MINIMIZE
	;	WinGet, OutputVar, List, ahk_exe %mBranch_A1% ; Run multiple Page Improver

	Gui +OwnDialogs
	Gosub, Select
	Guictrls(0,0,1)
	Stop := 0
	;B_Index++
	InputBox, Password, Password,, hide, 200,100
	if (ErrorLevel){
			Gosub, Stop
			Return
		}
	If (Password != "Ikke klar til bruk"){
			Gosub, Stop
			Return
		}
	LV_GetText(Folder,B_Index,1)
	LV_GetText(Profile,B_Index,2)
	If (Folder = "") or (Profile = ""){
			Gosub, Stop
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1){
			WinGet, OutputVar, MinMax, ahk_exe %mBranch_A1%
			if OutputVar in -1,0
			WinMaximize, ahk_exe %mBranch_A1%
		}Else{
			Gosub, Stop
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			ControlSend,, {Alt down}oo{Alt up}, %mBranch_A2%
			SleepTimer(mBranch_T1,CancelNow)
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1){
			;winminimize, ahk_exe Pageimprover.exe
			ControlClick, WindowsForms10.Window.8.app.0.1ca0192_r6_ad12, Single image Split & Crop,, Left, 1
		}
	If Winexist("ahk_exe" . mBranch_A1){
			Get_PI_Controls(1)
			If(Pi_Mode = "L & R on One Image")
				{
					If (AC_SysTabControl32 = "")
						{
							SB_SetText("Error.",2,1)
							MsgBox, 262160, %Appname%, Error retrieving Tab Control from Page Improver.
							Guictrls(1,1,0)
							return
						}
					;   Select Effects Tab
					SendMessage, 0x1330, 8,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
					Sleep 0
					SendMessage, 0x130C, 8,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
					SleepTimer(cBranch_T3,CancelNow)
					Get_PI_Controls(2)
					If (AC_EffectsComboBox = "")
						{
							SB_SetText("Error.",2,1)
							MsgBox, 262160, %Appname%, Error retrieving ComboBox control from Page Improver.
							Guictrls(1,1,0)
							return
						}
					If (Apply_Effect = 1)
						{
							Control, ChooseString, % Effects, % AC_EffectsComboBox, ahk_exe %mBranch_A1%
						}
					Else
						{
							Control, ChooseString, Sharpening 2, % AC_EffectsComboBox, ahk_exe %mBranch_A1%
						}
					SleepTimer(cBranch_T3,CancelNow)
					;   Select Crop Tab
					SendMessage, 0x1330, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
					Sleep 0
					SendMessage, 0x130C, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
				}
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			;	Select Files
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSend,, {Alt down}F{Alt up}, % mBranch_A2
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSetText, Edit1, %Folder%, Select Folder
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSend,, {Alt down}r{Alt up}, ahk_exe %mBranch_A1%
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSend,, {Enter}, ahk_exe %mBranch_A1%
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			;	Add profile
			ControlSend,, {Alt down}L{Alt up}, % mBranch_A2
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSetText, Edit1, %Profile%, Select profile to use
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
			ControlSend,, {Enter}, ahk_exe %mBranch_A1%
			SleepTimer(mBranch_T3,CancelNow)
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			;	Click Row - Windowsforms10.Window.8.app.0.1ca0192_r6_ad13
			X := 300 
			Y := 300
			ControlGet, hLV, Hwnd,, WindowsForms10.Window.8.app.0.1ca0192_r6_ad13, ahk_exe %mBranch_A1%
			PostMessage, 0x86, 0,,, ahk_id %hLV% ; WM_NCACTIVATE
			PostMessage, 0x201, 0, X&0xFFFF | Y<<16,, ahk_id %hLV% ; WM_LBUTTONDOWN
			PostMessage, 0x202, 0, X&0xFFFF | Y<<16,, ahk_id %hLV% ; WM_LBUTTONUP
			ControlSend, WindowsForms10.Window.8.app.0.1ca0192_r6_ad13, {Enter}, ahk_exe %mBranch_A1%
			SleepTimer(mBranch_T1,CancelNow)
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			;	Shoulder Search WindowsForms10.Window.8.app.0.1ca0192_r6_ad14
			ControlClick, x1120 y450, ahk_exe %mBranch_A1%,, Right, 1, pos
			SleepTimer(mBranch_T4,CancelNow)
			if (Stop = 1)
			Return
			ControlClick, x1330 y450, ahk_exe %mBranch_A1%,, Right, 1, pos
			SleepTimer(mBranch_T4,CancelNow)
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			; Apply & Preview
			ControlSend,, {Alt down}A{Alt up}, ahk_exe %mBranch_A1%
			SleepTimer(mBranch_T1,CancelNow)
			if (Stop = 1)
			Return
		}
	If Winexist("ahk_exe" . mBranch_A1)
		{
			Get_PI_Controls(3)
			If (Pi_Mode = "L & R on One Image")
				{
					If (AC_CalcWidth = "") or (AC_CalcHeight = "") or (AC_LeftWidth = "") or (AC_LeftHeight = "") or (AC_RightWidth = "") or (AC_RightHeight = "")
						{
							SB_SetText("Error.",2,1)
							MsgBox, 262160, %Appname%, Error retrieving crop controls from Page Improver.
							Guictrls(1,1,0)
							return
						}
					SendMessage, 0x1330, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x1330 is TCM_SETCURFOCUS
					Sleep 0
					SendMessage, 0x130C, 4,, % AC_SysTabControl32, ahk_exe %mBranch_A1% ; 0x130C is TCM_SETCURSEL
					SleepTimer(mBranch_T4,CancelNow)
					SendMessage, 0x0201, 0x0001,, % AC_CalcWidth, ahk_exe %mBranch_A1% ; 0x0201 is WM_LBUTTONDOWN and 0x0001 is MK_LBUTTON
					SendMessage, 0x0202,,, % AC_CalcWidth, ahk_exe %mBranch_A1% ; 0x0202 is WM_LBUTTONUP
					SendMessage, 0x0201, 0x0001,, % AC_CalcHeight, ahk_exe %mBranch_A1% ; 0x0201 is WM_LBUTTONDOWN and 0x0001 is MK_LBUTTON
					SendMessage, 0x0202,,, % AC_CalcHeight, ahk_exe %mBranch_A1% ; 0x0202 is WM_LBUTTONUP
					SleepTimer(mBranch_T4,CancelNow)
					if (Stop = 1)
					Return
					ControlGetText, AC_OldWidth, % AC_LeftWidth, ahk_exe %mBranch_A1%
					ControlGetText, AC_OldHeight, % AC_LeftHeight, ahk_exe %mBranch_A1%
					If (AC_Manual = 1)
						{
							AC_NewWidth := Floor(AC_OldWidth-(AC_OldWidth*(AC_WidthAdjust/100)))
							AC_NewHeight := Floor(AC_OldHeight-(AC_OldHeight*(AC_HeightAdjust/100)))
						}
					If (AC_Table = 1)
						{
							;AC_Format := Floor(Sqrt((AC_OldHeight**2)+(AC_OldWidth**2)))
							AC_Format := CalcSize(2, AC_OldWidth, AC_OldHeight, AC_PPI)
							AC_Match := StrSplit(TableSearch(AC_Format, FormatList), "|")
							AC_NewWidth := Floor(AC_OldWidth-(AC_OldWidth*(AC_Match[3]/100)))
							AC_NewHeight := Floor(AC_OldHeight-(AC_OldHeight*(AC_Match[4]/100)))
						}
					ControlSetText, % AC_LeftWidth, % AC_NewWidth, ahk_exe %mBranch_A1%
					ControlSetText, % AC_LeftHeight, % AC_NewHeight, ahk_exe %mBranch_A1%
					ControlSetText, % AC_RightWidth, % AC_NewWidth, ahk_exe %mBranch_A1%
					ControlSetText, % AC_RightHeight, % AC_NewHeight, ahk_exe %mBranch_A1%
				}
		}
	If Winexist("ahk_exe" . mBranch_A1){
			; Handle Files
			ControlSend, WindowsForms10.Window.8.app.0.1ca0192_r6_ad12, {Alt down}h{Alt up}, ahk_exe %mBranch_A1%
		}
	Gosub, Stop
	Return

;----------------------------------------------------------------------------
;	AutoPI History Bitmap.
;----------------------------------------------------------------------------
Create_AutoPi_Alpha_1_PNG(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 15544 << !!A_IsUnicode)
B64 := "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"
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}

Create_AutoPi_Alpha_2_PNG(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 18312 << !!A_IsUnicode)
B64 := "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"
B64 .= "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"
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}

Create_AutoPi_Alpha_3_PNG(NewHandle := False) {
Static hBitmap := 0
If (NewHandle)
   hBitmap := 0
If (hBitmap)
   Return hBitmap
VarSetCapacity(B64, 9972 << !!A_IsUnicode)
B64 := "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"
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &B64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)
   Return False
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Ptr", &Dec, "UPtr", DecLen)
DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", True, "PtrP", pStream)
hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", pToken, "Ptr", &SI, "Ptr", 0)
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  "Ptr", pStream, "PtrP", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
Return hBitmap
}

/*
;----------------------------------------------------------------------------
;	Old Presets
;----------------------------------------------------------------------------

; Function:				ProfileSettings
; Description:			Complete list of settings used by presets in GUI1 menu.

ProfileSettings(Option1, Option2){
	; Folder & Profile
	; Standard - Single Pages
	If (Option1 = 1){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\
			GuiControl,3:ChooseString, Pi_Mode, Single Pages
		}
	; Automatic Crop - L & R on One Image
	If (Option1 = 2){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\
			GuiControl,3:ChooseString, Pi_Mode, L & R on One Image
		}
	; Book New Camera - L & R on One Image
	if (Option1 = 3){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\Bok_NyeDL\
			GuiControl,3:ChooseString, Pi_Mode, L & R on One Image
		}
	; Periodical - L & R on One Image
	If (Option1 = 4){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\Tidsskrift\
			GuiControl,3:ChooseString, Pi_Mode, L & R on One Image
		}
	; Complete Periodical - L & R on One Image
	if (Option1 = 5){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\Tidsskrift_Komplett\
			GuiControl,3:ChooseString, Pi_Mode, L & R on One Image
		}
	; Book Old Camera - L & R on One Image
	if (Option1 = 6){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\Bok\
			GuiControl,3:ChooseString, Pi_Mode, L & R on One Image
		}
	; L & R on Two Images
	If (Option1 = 7){
			GuiControl,3:ChooseString, Folderpath, D:\Dl_Files\
			GuiControl,3:ChooseString, Pi_Mode, L & R on Two Images
		}
	; Automatic Crop New Camera
	If (Option2 = 1){
			GuiControl,3:, AC_Border, 1
			GuiControl,3:, AC_Border, On
			GuiControl,3:, AC_Sweep, 1
			GuiControl,3:, AC_Sweep, On
			GuiControl,3:, AutoCrop, 1
			GuiControl,3:, AutoCrop, On
			GuiControl,3:, Apply_Effect, 1
			GuiControl,3:, Apply_Effect, On
		}
	 ; Automatic Crop Old Camera
	If (Option2 = 2){
			GuiControl,3:, AC_Border, 1
			GuiControl,3:, AC_Border, On
			GuiControl,3:, AC_Sweep, 1
			GuiControl,3:, AC_Sweep, On
			GuiControl,3:, AutoCrop, 1
			GuiControl,3:, AutoCrop, On
			GuiControl,3:, Apply_Effect, 0
			GuiControl,3:, Apply_Effect, Off
		}
	; New Camera
	If (Option2 = 3){
			GuiControl,3:, AutoCrop, 0
			GuiControl,3:, AutoCrop, Off
			GuiControl,3:, Apply_Effect, 1
			GuiControl,3:, Apply_Effect, On
		}
	; Old Camera
	If (Option2 = 4){
			GuiControl,3:, AutoCrop, 0
			GuiControl,3:, AutoCrop, Off
			GuiControl,3:, Apply_Effect, 0
			GuiControl,3:, Apply_Effect, Off
		}
	GuiControl,3:, ImageFolderCheck, 1
	GuiControl,3:, ImageFolderCheck, On
	; GuiControl,3:, PercentageDifference, 10
	GuiControl,3:ChooseString, Profilepath, D:\Dl_Files\PI_Profiler\
	GuiControl,3:, ProfileExtension, .fyr
	; Main Branch Delay
	GuiControl,3:, mBranch_T2, 100
	GuiControl,3:, mBranch_T3, 1000
	GuiControl,3:, mBranch_T4, 500
	GuiControl,3:, mBranch_T5, 3000
	GuiControl,3:, mBranch_T6, 5.0
	; Restart Branch
	GuiControl,3:, mBranch_T1, 4000
	GuiControl,3:, cBranch_T1, 5000
	GuiControl,3:, cBranch_T2, 1000
	GuiControl,3:, cBranch_T3, 500
	GuiControl,3:, cBranch_T4, 5.0
	; Page Improver
	;GuiControl,3:ChooseString, Output_Folder, digibok_
	;GuiControl,3:ChooseString, Output_Action, Delete
	;GuiControl,3:, mBranch_A1, PageImprover.exe
	;GuiControl,3:, mBranch_A2, Fyr's image manipulation package
	;GuiControl,3:, cBranch_A1, C:\Program Files\4Digitalbooks\Page Improver 64\PageImprover.exe
	GuiControl,3:, Conditional_Branch, 1
	GuiControl,3:, Conditional_Branch, On
	GuiControl,3:, Initial_Restart, 1
	GuiControl,3:, Initial_Restart, On
	GuiControl,3:, ShoulderSearch, 1
	GuiControl,3:, ShoulderSearch, On
	; Images Timer
	GuiControl,3:, Images_Timer, 1
	GuiControl,3:, Deadline, 1
	GuiControl,3:, Deadline, On
	GuiControl,3:ChooseString, Timelimit, 2x
	GuiControl,3:ChooseString, DeadlineActiontaken, Continue
	GuiControl,3:, iCount_T1, 5
	GuiControl,3:, iCount_T2, 2.0
	GuiControl,3:, iCount_T3, 3.0
	GuiControl, 3:Enable, Deadline
	GuiControl, 3:Enable, Timelimit
	GuiControl, 3:Enable, DeadlineActiontaken
	GuiControl, 3:Enable, iCount_T1
	GuiControl, 3:Enable, iCount_T2
	GuiControl, 3:Enable, iCount_T3
	; Duration Timer
	GuiControl,3:, Duration_Timer, 0
	GuiControl,3:, Limit, 2.5
	GuiControl,3:, MB_Second, 27
	GuiControl,3:Disable, Limit
	GuiControl,3:Disable, MB_Second
	GUI, 3:Submit, NoHide
}
*/
;----------------------------------------------------------------------------
;	Stuff
;----------------------------------------------------------------------------
/*
SendMessage, 0x101F, 0, 0,, ahk_id %ListHWND% ; 0x101F is LVM_GETHEADER
ListHD := ErrorLevel
Control, Style, -0x0080,, ahk_id %ListHD% ; 0x0080 is HDS_FULLDRAG
*/
/*
Require Windows 1903+
uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
DllCall(SetPreferredAppMode, "int", 1) ; Dark
DllCall(FlushMenuThemes)
*/
/*
Dark Mode
DllCall("uxtheme\SetWindowTheme", "ptr", ctrl_hwnd, "str", "DarkMode_Explorer", "ptr", 0)
*/
/*
Load_Settings:
	Gui +OwnDialogs
	if !FileExist("Settings.json") and !Fileexist("List.json") and !FileExist("Table.json"){
			MsgBox, 262160, %Appname% - Load Error, Cant find:`n%A_WorkingDir%\Settings.json `n%A_WorkingDir%\List.json`n%A_WorkingDir%\Table.json
			return
		}
	LV_GetText(Folder, 1, 1)
	If (Folder = ""){
				if FileExist("List.json"){
						Load("List.json", "r", A_FileEncoding)
					}
				if FileExist("Settings.json"){
						Load("Settings.json", "r", A_FileEncoding)
					}
				if FileExist("Table.json"){
						Load("Table.json", "r", A_FileEncoding)
					}
            }Else{
				MsgBox,	262435, %Appname% - Load, Keep current rows?
				IfMsgBox Yes
						{
							if FileExist("List.json"){
									Load("List.json", "r", A_FileEncoding)
								}
							if FileExist("Settings.json"){
									Load("Settings.json", "r", A_FileEncoding)
								}
							if FileExist("Table.json"){
									Load("Table.json", "r", A_FileEncoding)
								}
						}
				IfMsgBox No
						{
							LV_Delete()
							LV_Update("GetCount")
							if FileExist("List.json"){
									Load("List.json", "r", A_FileEncoding)
								}
							if FileExist("Settings.json"){
									Load("Settings.json", "r", A_FileEncoding)
								}
							if FileExist("Table.json"){
									Load("Table.json", "r", A_FileEncoding)
								}
							}
				IfMsgBox Cancel
					{
						Return
					}
			}
	LV_Update("GetCount")
	If FileExist("Settings.json")
		{
			if FileExist("List.json")
				{
					if (!xMC_Local_Navigator) && (!yMC_Local_Navigator)
						{
							if FileExist("Table.json"){
									SB_SetText("Error: Mouse coordinates",2,1)
								}Else{
									SB_SetText("Loaded List and Settings. Error: Mouse coordinates",2,1)
								}
						}Else{
							if FileExist("Table.json"){
									SB_SetText("",2,1)
								}Else{
									SB_SetText("Loaded List and Settings",2,1)
								}
						}
				}Else{
					if (!xMC_Local_Navigator) && (!yMC_Local_Navigator){
							if FileExist("Table.json"){
									SB_SetText("Loaded Settings and Table. Error: Mouse coordinates",2,1)
								}Else{
									SB_SetText("Loaded Settings. Error: Mouse coordinates",2,1)
								}
						}Else{
							if FileExist("Table.json"){
									SB_SetText("Loaded Settings and Table sucessfully",2,1)
								}Else{
									SB_SetText("Loaded Settings sucessfully",2,1)
								}
						}
				}
		}Else{
			if FileExist("List.json") {
					if FileExist("Table.json"){
							if (!xMC_Local_Navigator) && (!yMC_Local_Navigator){
									SB_SetText("Loaded List and Table. Error: Mouse coordinates",2,1)
								}Else{
									SB_SetText("Loaded List and Table sucessfully.",2,1)
								}
						}Else{
							if (!xMC_Local_Navigator) && (!yMC_Local_Navigator){
									SB_SetText("Loaded List. Error: Mouse coordinates",2,1)
								}Else{
									SB_SetText("Loaded List.",2,1)
								}
						}
				}Else{
					if (!xMC_Local_Navigator) && (!yMC_Local_Navigator){
							SB_SetText("Loaded Table. Error: Mouse coordinates",2,1)
						}Else{
							SB_SetText("Loaded Table.",2,1)
						}
				}
		}
	Gui, 1:Submit, NoHide
	Gui, 2:Submit, NoHide
	Gui, 3:Submit, NoHide
	return
*/
/*
			iPics[iIndex] := LoadPicture(ImgObj["ImagePath"iIndex], "GDI+")
			GuiControl, Image:, iPicture, % "*w" . ImgObj["Img_W"] . " *h" . ImgObj["Img_H"] . " " . ImgObj["ImagePath"iIndex]
			Control, Hide,,, % "ahk_id" iPicture
			GuiControl, Image:, HBITMAP:%iPics%, % "*w" . ImgObj["Img_W"] . " *h" . ImgObj["Img_H"] . " HBITMAP:" . iPics[iIndex]
			Control, Show,,, % "ahk_id" iPicture
*/
/*
			;Wia := ComObjCreate("WIA.ImageFile") ; Old code - Remove
			;Wia.LoadFile(ImgObj["ImagePath"iIndex])
*/
/*
LV_Modifyrow:
	if (Folderrow > 1){
			LV_ModifyList("Modify", "Folder", "Edit")
			LV_ModifyList("Modify", "Profile", "Edit")
		}
	Return
*/
/*
					Gdip_GetRotatedDimensions(iWidth, iHeight, Angle, RWidth, RHeight)
					Gdip_GetRotatedTranslation(iWidth, iHeight, Angle, xTranslation, yTranslation)
					hbm := CreateDIBSection(ImgObj["Img_W"], ImgObj["Img_H"])
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetInterpolationMode(G, 0)
					Gdip_TranslateWorldTransform(G, xTranslation, yTranslation)
					Gdip_RotateWorldTransform(G, Angle)
					Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"], ImgObj["Img_H"])
					Gdip_ResetWorldTransform(G)
					UpdateLayeredWindow(Image1, hdc, 10, 10, ImgObj["Img_W"], ImgObj["Img_H"])
					SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
					Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
					Critical, Off
					Return True
*/
/*
Backup
					Gdip_GetRotatedDimensions(ImgObj["Img_W"], ImgObj["Img_H"], Angle, RWidth, RHeight)
					hbm := CreateDIBSection(RWidth, RHeight)
					hdc := CreateCompatibleDC()
					obm := SelectObject(hdc, hbm)
					G := Gdip_GraphicsFromHDC(hdc), Gdip_SetInterpolationMode(G, 0)
					ScaleW := ImgObj["Img_W"] > RWidth ? (ImgObj["Img_W"]/RWidth) : (RWidth/ImgObj["Img_W"])
					ScaleH := ImgObj["Img_H"] > RHeight ? (ImgObj["Img_H"]/RHeight) : (RHeight/ImgObj["Img_H"])
					If (Angle >= 0) {
							Gdip_GetRotatedTranslation(ImgObj["Img_W"]/ScaleH, ImgObj["Img_H"]/ScaleW, Angle, xTranslation, yTranslation)
					}Else{
							Gdip_GetRotatedTranslation(ImgObj["Img_W"]/ScaleW, ImgObj["Img_H"]/ScaleH, Angle, xTranslation, yTranslation)
						}
					Gdip_TranslateWorldTransform(G, xTranslation, yTranslation)
					Gdip_RotateWorldTransform(G, Angle)
					Gdip_DrawImage(G, pBitmap, 0, 0, ImgObj["Img_W"]/ScaleW, ImgObj["Img_H"]/ScaleW,0,0, iWidth, iHeight)
					Gdip_ResetWorldTransform(G)
					;NewWidth := (ImgObj["Img_W"]*cos(Angle)) + (ImgObj["Img_H"]*sin(Angle))
					;NewHeight := (ImgObj["Img_W"]*sin(Angle)) + (ImgObj["Img_H"]*cos(Angle))
					;msgbox % NewWidth "  " RWidth "  " NewHeight "  " RHeight
					UpdateLayeredWindow(Image1, hdc, 10, 10, RWidth/ScaleW, RHeight/ScaleW)
					SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
					Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
					Critical, Off
					Return True
*/
