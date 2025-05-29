#SingleInstance Force
global CFG := SubStr(A_ScriptName, 1, -3)"txt"
global TMP := SubStr(A_ScriptName, 1, -3)"tmp"

if !FileExist("C:\Program Files\EqualizerAPO\Editor.exe")				;Установлен ли Equalizer APO?
{
	MsgBox Для начала нужно установить Equalizer APO!
	Run, https://sourceforge.net/projects/equalizerapo/
	exitapp
}

if !FileExist(CFG)														;Первый запуск
{
	MsgBox,4 ,, Создать конфигурационный файл?
		IfMsgBox Yes
		{
			global Preamp := "Preamp: -30 dB"
			global AGC := "#Include: agc.txt"
			global PreampStep := "PreampStep: 5 dB"
			global MonitorScale := "MonitorScale: 2"
			WriteCFG()
		}
		else
		{
			exitapp
		}
	MsgBox, 4,, Добавить конфигурационный файл в Equalizer APO?
		IfMsgBox Yes
		{
			EAPO := "C:\Program Files\EqualizerAPO\config\config.txt"
			if FileExist(EAPO)
			{
				ADDCFG := SubStr(A_ScriptFullPath, 1, -3)"txt"
				FileAppend, `nInclude: %ADDCFG%, %EAPO%
			}
			else
			{
				MsgBox %EAPO% не найден!
			}
		}
	MsgBox, 4,, Добавить скрипт в автозагрузку?
		IfMsgBox Yes
		{
			ADDLNK := SubStr(A_ScriptName, 1, -3)"lnk"
			FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%ADDLNK%, %A_WorkingDir%
		}
	Run, https://github.com/Croupier42/EqualizerAPO.ahk
}

FileRead, File, %CFG%													;Считывание конфиг файла
RegExMatch(File, "(Preamp:) (.*) (.*)", Preamp)							;Поиск и разделение переменной на Preamp1 "Preamp:", Preamp2 "-30", Preamp3 "dB"
RegExMatch(File, "(PreampStep:) (.*) (.*)", PreampStep)					;Поиск и разделение переменной на PreampStep1 "PreampStep:", PreampStep2 "5", PreampStep3 "dB"
RegExMatch(File, "(.*Include.*)", AGC)									;Поиск переменной AGC
RegExMatch(File, "(MonitorScale:) (.*)", MonitorScale)					;Поиск и разделение переменной на MonitorScale1 "MonitorScale:", MonitorScale2 "2"

SysGet, MonitorWorkArea, MonitorWorkArea, 1								;Win11 like OSD
MonitorWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
MonitorHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
ControlW := (MonitorWidth // 9.89)										;384px+4px on white bg for 4k
ControlH := (MonitorHeight // 22.04)									;94px+4px on white bg for 4k
ControlWS := ControlW // MonitorScale2									;194px
ControlHS := ControlH // MonitorScale2									;49px
global ControlY := MonitorHeight - ControlH - (MonitorHeight // 17.7)	;122px for 4k
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 2C2C2C
Gui, Font, s14, Tahoma
Gui, Margin, 0, 0
Gui, Add, Text, vOSDText c4CC2FF w%ControlWS% h%ControlHS% Center
WinSet, Transparent, 191

$Volume_Down::															;F11
	SoundGet, SystemVolume
	if (SystemVolume != 100)
	{
		SoundSet, 100
	}
	if (SubStr(AGC, 1, 1) != "#")
	{
		AGC = #%AGC%
		WriteCFG()
	}
	else
	{
		Preamp2 -= PreampStep2
		Preamp = %Preamp1% %Preamp2% %Preamp3%
		WriteCFG()
	}
	OSD()
	return

$Volume_Up::															;F12
	SoundGet, SystemVolume
	if (SystemVolume != 100)
	{
		SoundSet, 100
	}
	if (Preamp2 < 0)
	{
		Preamp2 += PreampStep2
		if (Preamp2 > 0)
		{
			Preamp2 = 0
		}
		Preamp = %Preamp1% %Preamp2% %Preamp3%
		WriteCFG()
	}
	else
	{
		if (SubStr(AGC, 1, 1) == "#")
		{
			AGC := SubStr(AGC, 2)
		}
		WriteCFG()
	}
	OSD()
	return

OSD()																	;Обновление OSD
{
	global Preamp2 := Preamp2
	global DeviceLabel := "В разработке :C"
	PreampVisual = Громкость: %Preamp2% дБ
	if (SubStr(AGC, 1, 1) != "#")
	{
		PreampVisual = Громкость: Макс.
	}
	GuiControl, Text, OSDText, %DeviceLabel%`n%PreampVisual%
	Gui, Show, xCenter y%ControlY% NoActivate
	SetTimer, HideOSD, 1500
	return
	HideOSD:
	Gui, Hide
	return
}

WriteCFG()																;Запись конфига
{
	FileDelete, %TMP%
	FileAppend, %Preamp%`n%AGC%`n%PreampStep%`n%MonitorScale%, %TMP%
	FileCopy, %TMP%, %CFG%, 1
}