;Создан croupier https://web.telegram.org/#@Croupier42
;Основан на базе https://github.com/Brad331/APOpreamp.ahk
;Версия скрипта 1.0
;Требуется AutoHotkey 1.1
;Зачем я это сделал? Потому что я ненавижу системную регулировку винды. Ну и для смены профилей APO по горячей клавише.
;Если бы я мог измерить звуковое давление системы... я бы мог сделать значения громкости привязанными к реалу... правда оно было бы привязано только к одной системе...
;блять научите как сделать нормально, а не то что ниже...
;Переменные-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !FileExist("ahk.tmp")															;Если нет файла конфига, создать используя настройки по умолчанию
{
	FileAppend, Include: `n, ahk.tmp												;Сначала записать во временный файл,
	FileAppend, #Label: `n, ahk.tmp
	FileAppend, #IncludeA: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt`n, ahk.tmp
	FileAppend, #LabelA: NOEMA`n, ahk.tmp
	FileAppend, #IncludeB: D:\Programs\EqualizerAPO\Headphones\Zero_2\7Hz-Salnotes x Crinacle Zero_2 Filters.txt`n, ahk.tmp
	FileAppend, #LabelB: Zero:2`n, ahk.tmp
	FileAppend, Preamp: -60`n, ahk.tmp
	FileAppend, #PreampRatio: 6`n, ahk.tmp
	FileAppend, #PreampMin: -60`n, ahk.tmp
	FileAppend, #PreampMax: 6, ahk.tmp
	FileCopy, ahk.tmp, ahk.txt, 1													;Затем перезаписать файл усиления временным файлом, для более плавного процесса регулировки громкости и уменьшения хлопков.
	msgbox Configuration file was created`nInclude: ahk.txt in Equalizer APO
}

;Считывание данных с файла конфига--------------------------------------------------------------------------------------------------------------------------------------------------------------
FileReadLine, line, ahk.txt, 1
global Include := SubStr(line, 10)
FileReadLine, line, ahk.txt, 2
global Label := SubStr(line, 9)
FileReadLine, line, ahk.txt, 3
global IncludeA := SubStr(line, 12)
FileReadLine, line, ahk.txt, 4
global LabelA := SubStr(line, 10)
FileReadLine, line, ahk.txt, 5
global IncludeB := SubStr(line, 12)
FileReadLine, line, ahk.txt, 6
global LabelB := SubStr(line, 10)
FileReadLine, line, ahk.txt, 7
global Preamp := SubStr(line, 9)
FileReadLine, line, ahk.txt, 8
global PreampRatio := SubStr(line, 15)
FileReadLine, line, ahk.txt, 9
global PreampMin := SubStr(line, 13)
FileReadLine, line, ahk.txt, 10
global PreampMax := SubStr(line, 13)

;OSD. Как это уёбище сделать красивым?----------------------------------------------------------------------------------------------------------------------------------------------------------
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow									;Окно OSD
Gui, Color, 000000																	;Цвет фона
Gui, Font, s24,																		;Размер шрифта
Gui, Margin, 4, 0																	;Отступы
Gui, Add, Text, vOSDText cFFFFFF,-----------------------							;Текст, цвет текста
WinSet, Transparent, 191															;Прозрачность
return
OSD()																				;функция OSD
{
	GuiControl,, OSDText, %Label% %Preamp% dB										;Обновление значений
	Gui, Show, x100 y100 NoActivate													;Показать
	SetTimer, HideOSD, 1500															;Таймер скрытия
	return
	HideOSD:																		;ХЗ че, но нужно для таймера
	Gui, Hide																		;Скрыть 
	return
}

;Регулировка громкости--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Volume_Up::																		;При нажатии кнопки увеличения громкости,
	if (SystemVolume != 100)														;Если системная громкость не максимальна,
	{
		SoundSet, 100																;Установить системную громкость на максимум.
	}
	if (Preamp < PreampMax)
	{																				;Если усиление меньше максимального значения,
		Preamp+=PreampRatio															;Увеличить усиление,
		if (Preamp > PreampMax)
			{
			Preamp=%PreampMax%
			}
		WriteCFG()																	;И записать в конфигурацию с помощью функции WriteCFG,
	}
	OSD()																			;Использовать функцию OSD для отображения значения усиления.
return																				;Конец горячей клавиши.

$Volume_Down::																		;При нажатии кнопки уменьшения громкости,
	if (SystemVolume != 100)														;Если системная громкость не максимальна,
	{
		SoundSet, 100																;Установить системную громкость на максимум.
	}
	if (Preamp > PreampMin)															;Если усиление больше минимального значения,
	{
		Preamp-=PreampRatio															;Уменьшить усиление,
		if (Preamp < PreampMin)
			{
			Preamp=%PreampMin%
			}
		WriteCFG()																	;И записать в конфигурацию с помощью функции WriteCFG,
	}
	OSD()																			;Использовать функцию OSD для отображения значения усиления.
return																				;Конец горячей клавиши.

;смена конфига----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$Volume_Mute::																		;При нажатии кнопки мьют,
	if (Include == IncludeA)														;Если текущий профиль - профиль А,
	{
		Include=%IncludeB%															;То заменить его на профиль B.
		Label=%LabelB%
	}
	else if (Include == IncludeB)													;Если текущий профиль - профиль B,
	{
		Include=%IncludeA%															;То заменить его на профиль A.
		Label=%LabelA%
	}
	else
	{
	Include=%IncludeA%
	Label=%LabelA%
	}
	WriteCFG()																		;Записать в конфигурацию с помощью функции WriteCFG,
	OSD()																			;Использовать функцию OSD для отображения текущего профиля.
	return																			;Конец горячей клавиши.

;запись в файл конфигурации---------------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteCFG()																			;Функция WriteCFG отвечает за запись изменений в файл конфигурации.
{
	FileDelete, ahk.tmp																;Удалить старый файл конфигурации, чтобы подготовить его к перезаписи,
	FileAppend, Include: %Include%`n, ahk.tmp										;Сначала записать во временный файл,
	FileAppend, #Label: %Label%`n, ahk.tmp
	FileAppend, #IncludeA: %IncludeA%`n, ahk.tmp
	FileAppend, #LabelA: %LabelA%`n, ahk.tmp
	FileAppend, #IncludeB: %IncludeB%`n, ahk.tmp
	FileAppend, #LabelB: %LabelB%`n, ahk.tmp
	FileAppend, Preamp: %Preamp%`n, ahk.tmp
	FileAppend, #PreampRatio: %PreampRatio%`n, ahk.tmp
	FileAppend, #PreampMin: %PreampMin%`n, ahk.tmp
	FileAppend, #PreampMax: %PreampMax%, ahk.tmp
	FileCopy, ahk.tmp, ahk.txt, 1													;Затем перезаписать файл усиления временным файлом, для более плавного процесса регулировки громкости и уменьшения хлопков.
}
