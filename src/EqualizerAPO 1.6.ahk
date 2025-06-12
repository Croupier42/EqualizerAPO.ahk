#SingleInstance Force

;Переменные
global CFG := SubStr(A_ScriptName, 1, -3)"txt"
global TMP := SubStr(A_ScriptName, 1, -3)"tmp"
global LNK := SubStr(A_ScriptName, 1, -3)"lnk"
global DeviceLabel := "DeviceLabel: Out 1-2"
global DeviceLabel1 :=
global DeviceLabel2 :=
global DeviceLabelA := "DeviceLabelA: Out 1-2"
global DeviceLabelA1 :=
global DeviceLabelA2 :=
global DeviceLabelB := "DeviceLabelB: Динамики"
global DeviceLabelB1 :=
global DeviceLabelB2 :=
global IncludeLabel := "IncludeLabel: NOEMA"
global IncludeLabel1 :=
global IncludeLabel2 :=
global Include := "Include: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt"
global Include1 :=
global Include2 :=
global IncludeLabelA := "IncludeLabelA: NOEMA"
global IncludeLabelA1 :=
global IncludeLabelA2 :=
global IncludeA := "IncludeA: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt"
global IncludeA1 :=
global IncludeA2 :=
global IncludeLabelB := "IncludeLabelB: Chu 2"
global IncludeLabelB1 :=
global IncludeLabelB2 :=
global IncludeB := "IncludeB: D:\Programs\EqualizerAPO\Headphones\Chu 2\Moondrop Chu 2 Filters.txt"
global IncludeB1 :=
global IncludeB2 :=
global Preamp := "Preamp: -30 dB"
global Preamp1 :=
global Preamp2 :=
global Preamp3 :=
global PreampStep := "PreampStep: 5 dB"
global PreampStep1 :=
global PreampStep2 :=
global PreampStep3 :=
global VSTPlugin := "VSTPlugin: Library D:\Programs\VSTPlugins\LoudMax64.dll Thresh 1 Output 1 ""Fader Link"" 0 ""ISP Detection"" 1 ""Large GUI"" 1"
global MonitorScale := "MonitorScale: 2"
global MonitorScale1 :=
global MonitorScale2 :=
global Startup := "Startup: 1"
global Startup1 :=
global Startup2 :=

;Проверка на наличие Equalizer APO
if !FileExist("C:\Program Files\EqualizerAPO\Editor.exe")
{
	MsgBox,,, Для начала нужно установить Equalizer APO!, 3
	Run, https://sourceforge.net/projects/equalizerapo/
	exitapp
}

;Первоначальная настройка
if !FileExist(CFG)
{
	MsgBox, 4,, Добавить конфигурационный файл в Equalizer APO?, 3
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
				MsgBox,,, %EAPO% не найден!, 1
			}
		}
	MsgBox, 4,, Перейти на страницу проекта?, 3
		IfMsgBox Yes
		{
			Run, https://github.com/Croupier42/EqualizerAPO.ahk
		}
		WriteCFG()
}

;Считывание конфиг файла
FileRead, File, %CFG%													;Считывание конфиг файла
RegExMatch(File, "(DeviceLabel:) (.*)", DeviceLabel)
RegExMatch(File, "(DeviceLabelA:) (.*)", DeviceLabelA)
RegExMatch(File, "(DeviceLabelB:) (.*)", DeviceLabelB)
RegExMatch(File, "(IncludeLabel:) (.*)", IncludeLabel)
RegExMatch(File, "(Include:) (.*)", Include)
RegExMatch(File, "(IncludeLabelA:) (.*)", IncludeLabelA)
RegExMatch(File, "(IncludeA:) (.*)", IncludeA)
RegExMatch(File, "(IncludeLabelB:) (.*)", IncludeLabelB)
RegExMatch(File, "(IncludeB:) (.*)", IncludeB)
RegExMatch(File, "(Preamp:) (.*) (.*)", Preamp)							;Поиск и разделение переменной на Preamp1 "Preamp:", Preamp2 "-30", Preamp3 "dB"
RegExMatch(File, "(PreampStep:) (.*) (.*)", PreampStep)					;Поиск и разделение переменной на PreampStep1 "PreampStep:", PreampStep2 "5", PreampStep3 "dB"
RegExMatch(File, "(.*VSTPlugin:.*)", VSTPlugin)							;Поиск переменной VSTPlugin
RegExMatch(File, "(MonitorScale:) (.*)", MonitorScale)					;Поиск и разделение переменной на MonitorScale1 "MonitorScale:", MonitorScale2 "1"
RegExMatch(File, "(Startup:) (.*)", Startup)							;Поиск и разделение переменной на Startup1 "Startup:", Startup2 "0"

;Автозагрузка
if (Startup2 = 1)
{
	if !FileExist(A_Startup "\" LNK)
	{
		FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%LNK%, %A_WorkingDir%
		msgbox,,, Скрипт добавлен в автозагрузку, 1
	}
}
else
{
	if FileExist(A_Startup "\" LNK)
	{
		FileDelete, %A_Startup%\%LNK%
		msgbox,,, Скрипт удален из автозагрузки, 1
	}
}

;Win11 like OSD
SysGet, MonitorWorkArea, MonitorWorkArea, 1
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

;Смена устройства вывода звука, взято отсюда https://www.autohotkey.com/boards/viewtopic.php?f=76&t=49980#p221777
Devices := {}
IMMDeviceEnumerator := ComObjCreate("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
DllCall(NumGet(NumGet(IMMDeviceEnumerator+0)+3*A_PtrSize), "UPtr", IMMDeviceEnumerator, "UInt", 0, "UInt", 0x1, "UPtrP", IMMDeviceCollection, "UInt")
ObjRelease(IMMDeviceEnumerator)
DllCall(NumGet(NumGet(IMMDeviceCollection+0)+3*A_PtrSize), "UPtr", IMMDeviceCollection, "UIntP", Count, "UInt")
Loop % (Count)
{
	DllCall(NumGet(NumGet(IMMDeviceCollection+0)+4*A_PtrSize), "UPtr", IMMDeviceCollection, "UInt", A_Index-1, "UPtrP", IMMDevice, "UInt")
	DllCall(NumGet(NumGet(IMMDevice+0)+5*A_PtrSize), "UPtr", IMMDevice, "UPtrP", pBuffer, "UInt")
	DeviceID := StrGet(pBuffer, "UTF-16"), DllCall("Ole32.dll\CoTaskMemFree", "UPtr", pBuffer)
	DllCall(NumGet(NumGet(IMMDevice+0)+4*A_PtrSize), "UPtr", IMMDevice, "UInt", 0x0, "UPtrP", IPropertyStore, "UInt")
	ObjRelease(IMMDevice)
	VarSetCapacity(PROPVARIANT, A_PtrSize == 4 ? 16 : 24)
	VarSetCapacity(PROPERTYKEY, 20)
	DllCall("Ole32.dll\CLSIDFromString", "Str", "{A45C254E-DF1C-4EFD-8020-67D146A850E0}", "UPtr", &PROPERTYKEY)
	NumPut(14, &PROPERTYKEY + 16, "UInt")
	DllCall(NumGet(NumGet(IPropertyStore+0)+5*A_PtrSize), "UPtr", IPropertyStore, "UPtr", &PROPERTYKEY, "UPtr", &PROPVARIANT, "UInt")
	DeviceName := StrGet(NumGet(&PROPVARIANT + 8), "UTF-16")
	DllCall("Ole32.dll\CoTaskMemFree", "UPtr", NumGet(&PROPVARIANT + 8))
	ObjRelease(IPropertyStore)
	ObjRawSet(Devices, DeviceName, DeviceID)
}
ObjRelease(IMMDeviceCollection)
Return

;Fn+F9
$Media_Stop::
	if (DeviceLabel2 == DeviceLabelA2)
	{
		DeviceLabel2 = %DeviceLabelB2%
		DeviceLabel = %DeviceLabel1% %DeviceLabel2%
		SetDefaultEndpoint( GetDeviceID(Devices, DeviceLabel2) )
	}
	else 
	{
		DeviceLabel2 = %DeviceLabelA2%
		DeviceLabel = %DeviceLabel1% %DeviceLabel2%
		SetDefaultEndpoint( GetDeviceID(Devices, DeviceLabel2) )
	}
	WriteCFG()
	OSD()
	return

;Fn+F10
$Volume_Mute::
	if (Include2 == IncludeA2)
	{
		Include2 = %IncludeB2%
		IncludeLabel2 = %IncludeLabelB2%
		Include = %Include1% %Include2%
		IncludeLabel = %IncludeLabel1% %IncludeLabel2%
	}
	else
	{
		Include2 = %IncludeA2%
		IncludeLabel2 = %IncludeLabelA2%
		Include = %Include1% %Include2%
		IncludeLabel = %IncludeLabel1% %IncludeLabel2%
	}
	WriteCFG()
	OSD()
	return

;Fn+F11
$Volume_Down::
	SysVol()
	Preamp2 -= PreampStep2
	Preamp = %Preamp1% %Preamp2% %Preamp3%
	VSTPlugin()
	WriteCFG()
	OSD()
	return

;Fn+F12
$Volume_Up::
	SysVol()
	Preamp2 += PreampStep2
	Preamp = %Preamp1% %Preamp2% %Preamp3%
	VSTPlugin()
	WriteCFG()
	OSD()
	return

;Fn+AltGr+F12
$<^>!Volume_Up::
Setup()
return

;Настройка конфига
Setup()
{
	MsgBox,4 ,, Открыть mmsys.cpl?, 2
	IfMsgBox Yes
	{
		Run, mmsys.cpl
	}
	InputBox, Answer,, Название устройства вывода звука A`n(Его можно найти в mmsys.cpl),,,,,,,, %DeviceLabelA2%
	DeviceLabelA = %DeviceLabelA1% %Answer%
	DeviceLabel = %DeviceLabel1% %Answer%
	InputBox, Answer,, Название устройства вывода звука B`n(Его можно найти в mmsys.cpl),,,,,,,, %DeviceLabelB2%
	DeviceLabelB = %DeviceLabelB1% %Answer%
	InputBox, Answer,, Имя профиля A`n(Будет отображаться в OSD),,,,,,,, %IncludeLabelA2%
	IncludeLabelA = %IncludeLabelA1% %Answer%
	IncludeLabel = %IncludeLabel1% %Answer%
	InputBox, Answer,, Путь к файлу профиля A`n(Без кавычек),,,,,,,, %IncludeA2%
	IncludeA = %IncludeA1% %Answer%
	Include = %Include1% %Answer%
	InputBox, Answer,, Имя профиля B`n(Будет отображаться в OSD),,,,,,,, %IncludeLabelB2%
	IncludeLabelB = %IncludeLabelB1% %Answer%
	InputBox, Answer,, Путь к файлу профиля B`n(Без кавычек),,,,,,,, %IncludeB2%
	IncludeB = %IncludeB1% %Answer%
	InputBox, Answer,, Шаг регулировки громкости в дБ,,,,,,,, %PreampStep2%
	PreampStep = %PreampStep1% %Answer% %PreampStep3%
	InputBox, Answer,, VST плагин лимитера или авторегулировки громкости`n(Можно скопировать уже настроенный из Equalizer APO),,,,,,,, %VSTPlugin%
	VSTPlugin = %Answer%
	InputBox, Answer,, Масштабирование экрана:`n1 - 100`% `;` 1.25 - 125`% `;` 1.5 - 150`% и т.д,,,,,,,, %MonitorScale2%
	MonitorScale = %MonitorScale1% %Answer%
	InputBox, Answer,, Автозагрузка:`n0 - Выключить`n1 - Включить,,,,,,,, %Startup2%
	Startup = %Startup1% %Answer%
	WriteCFG()
	reload
}

;Смена устройства вывода звука
SetDefaultEndpoint(DeviceID)
{
	IPolicyConfig := ComObjCreate("{870af99c-171d-4f9e-af0d-e63df40c2bc9}", "{F8679F50-850A-41CF-9C72-430F290290C8}")
	DllCall(NumGet(NumGet(IPolicyConfig+0)+13*A_PtrSize), "UPtr", IPolicyConfig, "UPtr", &DeviceID, "UInt", 0, "UInt")
	ObjRelease(IPolicyConfig)
}
GetDeviceID(Devices, Name)
{
	For DeviceName, DeviceID in Devices
		If (InStr(DeviceName, Name))
			Return DeviceID
}

;Фиксирование системной громкости на 100%
SysVol()
{
	SoundGet, SystemVolume
	if (SystemVolume != 100)
	{
		SoundSet, 100
	}
}

;Переключение VST плагина
VSTPlugin()
{
	if (Preamp2 <= 0)
	{
		if (SubStr(VSTPlugin, 1, 1) != "#")
		{
			VSTPlugin = #%VSTPlugin%
		}
	}
	else
	{
		if (SubStr(VSTPlugin, 1, 1) == "#")
		{
			VSTPlugin := SubStr(VSTPlugin, 2)
		}
	}
}

;Обновление OSD
OSD()
{
	PreampVisual = Громкость: %Preamp2% дБ
	GuiControl, Text, OSDText, %DeviceLabel2% | %IncludeLabel2%`n%PreampVisual%
	Gui, Show, xCenter y%ControlY% NoActivate
	SetTimer, HideOSD, 1500
	return
	HideOSD:
	Gui, Hide
	return
}

;Запись конфига
WriteCFG()
{
	FileDelete, %TMP%
	FileAppend, %DeviceLabel%`n%DeviceLabelA%`n%DeviceLabelB%`n%IncludeLabel%`n%Include%`n%IncludeLabelA%`n%IncludeA%`n%IncludeLabelB%`n%IncludeB%`n%Preamp%`n%PreampStep%`n%VSTPlugin%`n%MonitorScale%`n%Startup%, %TMP%
	FileCopy, %TMP%, %CFG%, 1
}
