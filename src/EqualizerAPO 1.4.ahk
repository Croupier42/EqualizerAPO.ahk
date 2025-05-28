;Версия скрипта 1.4
;Создан https://web.telegram.org/#@Croupier42
;Для https://sourceforge.net/projects/equalizerapo/
;Основан на https://github.com/Brad331/APOpreamp.ahk
;Требуется https://www.autohotkey.com/ v1.1
;Зачем я это сделал? Потому что я ненавижу системную регулировку винды. Ну и для смены профилей APO/Устройства вывода звука по горячей клавише.
;Смена профилей, устройств пока не доделана.
;Планирую переделать запись в файл
;Бассбуст... Я решил что он нафиг не нужен.
;Описание кода... я чес сказать заебался, может быть и сделаю.

global CFG := "ahk.txt"													;Конфиг
if !FileExist(CFG)
{
	global Preamp := "Preamp: -30 dB"
	global AGC := "#Include: agc.txt"
	global PreampStep := "PreampStep: 5 dB"
	global MonitorScale := "MonitorScale: 2"
	WriteCFG()
	msgbox Configuration file was created`nInclude: %CFG% in Equalizer APO
}
if FileExist(CFG)
{
	FileRead, File, %CFG%
	RegExMatch(File, "(Preamp:) (.*) (.*)", Preamp)						;Поиск и разделение переменной на Preamp1 "Preamp:", Preamp2 "-30", Preamp3 "dB"
	RegExMatch(File, "(PreampStep:) (.*) (.*)", PreampStep)				;Поиск и разделение переменной на PreampStep1 "PreampStep:", PreampStep2 "5", PreampStep3 "dB"
	RegExMatch(File, "(.*Include.*)", AGC)								;Поиск переменной AGC
	RegExMatch(File, "(MonitorScale:) (.*)", MonitorScale)				;Поиск и разделение переменной на MonitorScale1 "MonitorScale:", MonitorScale2 "2"
}
else
{
	msgbox Pizdets...
	exitapp
}

SysGet, MonitorWorkArea, MonitorWorkArea, 1								;Win11 like OSD
MonitorWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
MonitorHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
global ControlW := (MonitorWidth // 9.89)								;384px+4px on white bg for 4k
global ControlH := (MonitorHeight // 22.04)								;94px+4px on white bg for 4k
global ControlWS := ControlW // MonitorScale2							; 194px
global ControlHS := ControlH // MonitorScale2							; 49px
global ControlX := (MonitorWidth // 2) - (ControlW // 2)
global ControlY := MonitorHeight - ControlH - (MonitorHeight // 17.7)	;122px for 4k
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 2C2C2C
Gui, Font, s14, Tahoma
Gui, Margin, 0, 0
Gui, Add, Text, vOSDText c4CC2FF w%ControlWS% h%ControlHS% Center
WinSet, Transparent, 191
global PreampVisual :=
global Preamp1 := Preamp1
global Preamp2 := Preamp2
global DeviceLabel := "Device"

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
	if (Preamp2 == 0)													;Визуальный бред
	{
		PreampVisual = %Preamp1% MAX
		if (SubStr(AGC, 1, 1) != "#")
		{
			PreampVisual = %Preamp1% AGC
		}
	}
	else
	{
		PreampVisual = %Preamp%
	}
	GuiControl, Text, OSDText, %DeviceLabel%`n%PreampVisual%
	Gui, Show, x%ControlX% y%ControlY% NoActivate
	SetTimer, HideOSD, 1500
	return
	HideOSD:
	Gui, Hide
	return
}

WriteCFG()																;Запись конфига
{
	FileDelete, %CFG%.tmp
	FileAppend, %Preamp%`n, %CFG%.tmp
	FileAppend, %AGC%`n, %CFG%.tmp
	FileAppend, %PreampStep%`n, %CFG%.tmp
	FileAppend, %MonitorScale%, %CFG%.tmp
	FileCopy, %CFG%.tmp, %CFG%, 1
}