;Версия скрипта 1.3
;Создан https://web.telegram.org/#@Croupier42
;Для https://sourceforge.net/projects/equalizerapo/
;Основан на https://github.com/Brad331/APOpreamp.ahk
;Требуется https://www.autohotkey.com/ v1.1
;Зачем я это сделал? Потому что я ненавижу системную регулировку винды. Ну и для смены профилей APO по горячей клавише.
;блять научите как сделать нормально, а не то что ниже...

if !FileExist("ahk.tmp")																		;Если нет файла конфига, создать используя настройки по умолчанию
{																								;Сначала записать во временный файл,
	FileAppend, Include: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt`n, ahk.tmp											;1 Текущий профиль коррекции
	FileAppend, #Label: NOEMA`n, ahk.tmp																						;2 Название текущего профиля коррекции
	FileAppend, #Include1: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt`n, ahk.tmp											;3 Профиль коррекции 1
	FileAppend, #Label1: NOEMA`n, ahk.tmp																						;4 Название профиля коррекции 1
	FileAppend, #Include2: D:\Programs\EqualizerAPO\Headphones\Zero_2\7Hz-Salnotes x Crinacle Zero_2 Filters.txt`n, ahk.tmp		;5 Профиль коррекции 2
	FileAppend, #Label2: Zero:2`n, ahk.tmp																						;6 Название профиля коррекции 2
	FileAppend, #Filter: ON LSC Fc 105 Hz Gain 8 dB Q 0.71`n, ahk.tmp															;7 Басс буст
	FileAppend, Preamp: -30`n, ahk.tmp																							;8 Текущее усиление
	FileAppend, #PreampMin: -60`n, ahk.tmp																						;9 Минимальное значение усиления
	FileAppend, #PreampMax: 10`n, ahk.tmp																						;10 Максимальное значение усиления
	FileAppend, #PreampStep: 5`n, ahk.tmp																						;11 Шаг изменения усиления
	FileAppend, #Include: agc.txt, ahk.tmp																						;12 Профиль с вст плагином для автоматической регулировки усиления
	FileCopy, ahk.tmp, ahk.txt, 1																;Затем перезаписать файл усиления временным файлом, для более плавного процесса регулировки громкости и уменьшения хлопков.
	msgbox Configuration file was created`nInclude: ahk.txt in Equalizer APO
}

FileReadLine, line, ahk.txt, 1
global Include := SubStr(line, 10)
FileReadLine, line, ahk.txt, 2
global Label := SubStr(line, 9)
FileReadLine, line, ahk.txt, 3
global Include1 := SubStr(line, 12)
FileReadLine, line, ahk.txt, 4
global Label1 := SubStr(line, 10)
FileReadLine, line, ahk.txt, 5
global Include2 := SubStr(line, 12)
FileReadLine, line, ahk.txt, 6
global Label2 := SubStr(line, 10)
FileReadLine, line, ahk.txt, 7
global Bass := SubStr(line, 1)
FileReadLine, line, ahk.txt, 8
global Preamp := SubStr(line, 9)
FileReadLine, line, ahk.txt, 9
global PreampMin := SubStr(line, 13)
FileReadLine, line, ahk.txt, 10
global PreampMax := SubStr(line, 13)
FileReadLine, line, ahk.txt, 11
global PreampStep := SubStr(line, 14)
FileReadLine, line, ahk.txt, 12
global AGC := SubStr(line, 0)
if FileExist("agc.txt")																			;Включать ли профиль с вст плагином HoRNet VU Meter MK4 при максимальном усилении
{
	PreampMax = 0
}
global PreampVisual :=																			;Внутренняя переменная для визуала
global BassVisual :=																			;Внутренняя переменная для бассбуста

Gui +LastFound +AlwaysOnTop -Caption +ToolWindow												;Окно OSD. Как это уёбище сделать красивым?
Gui, Color, 000000																				;Цвет фона
Gui, Font, s24,																					;Размер шрифта
Gui, Margin, 4, 0																				;Отступы
Gui, Add, Text, vOSDText cFFFFFF, %BassVisual% %Label% %PreampVisual%-------------------										;Текст, цвет текста
WinSet, Transparent, 191																		;Прозрачность
OSD()																							;Функция OSD
{
	if (Preamp == PreampMax)																	;Визуальный бред
	{
		PreampVisual = MAX
		if (AGC == "Include: agc.txt") 
		{
			PreampVisual = AGC
		}
	}
	else
	{
		PreampVisual = %Preamp% dB
	}
	if (SubStr(Bass, 1, 1) == "#")
	{
		BassVisual =
	}
	else
	{
		BassVisual = BB
	}
	GuiControl,, OSDText, %BassVisual% %Label% %PreampVisual%												;Обновление значений
	Gui, Show, x100 y100 NoActivate																;Показать
	SetTimer, HideOSD, 1500																		;Таймер скрытия
	return
	HideOSD:																					;ХЗ че, но нужно для таймера
	Gui, Hide																					;Скрыть 
	return
}

$Media_Stop::																					;F10 При нажатии кнопки медиа стоп,
	if (SubStr(Bass, 1, 1) == "#")															;Если первый символ переменной равен переменной с #, (Спасибо AHK за говнокод ещё раз)
	{
		Bass := SubStr(Bass, 2)																	;Убрать # из переменной Bass
	}
	else
	{
		Bass = #%Bass%																	;Добавить # в переменную Bass
	}
	WriteCFG()
	OSD()
	return

$Volume_Mute::																					;F10 При нажатии кнопки мьют,
	if (Include == Include1)																	;Если текущий профиль - профиль А,
	{
		Include = %Include2%																	;То заменить его на профиль B.
		Label = %Label2%
	}
	else if (Include == Include2)																;Если текущий профиль - профиль B,
	{
		Include = %Include1%																	;То заменить его на профиль A.
		Label = %Label1%
	}
	else																						;Можно добавить сколько угодно профилей, если очень хочется. Только нужно не забыть добавить переменные и запись в файл конфига)
	{
		Include = %Include1%
		Label = %Label1%
	}
	WriteCFG()																					;Записать в конфигурацию с помощью функции WriteCFG,
	OSD()																						;Использовать функцию OSD для отображения текущего профиля.
	return																						;Конец горячей клавиши.

$Volume_Down::																					;F11 При нажатии кнопки уменьшения громкости,
	if (SystemVolume != 100)																	;Если системная громкость не максимальна,
	{
		SoundSet, 100																			;Установить системную громкость на максимум.
	}
	if (Preamp > PreampMin)																		;Если усиление больше минимального значения,
	{
		Preamp -= PreampStep																	;Уменьшить усиление,
		if (Preamp < PreampMin)																	;Если усиление меньше минимального значения,
		{
			Preamp = %PreampMin%																;Установить минимальное значение усиления.
		}
		AGC = #Include: agc.txt																	;Отключить AGC
		WriteCFG()																				;И записать в конфигурацию с помощью функции WriteCFG,
	}
	OSD()																						;Использовать функцию OSD для отображения значения усиления.
	return																						;Конец горячей клавиши.

$Volume_Up::																					;F12 При нажатии кнопки увеличения громкости,
	if (SystemVolume != 100)																	;Если системная громкость не максимальна,
	{
		SoundSet, 100																			;Установить системную громкость на максимум.
	}
	if (Preamp < PreampMax)																		;Если усиление меньше максимального значения,
	{
		Preamp += PreampStep																	;Увеличить усиление,
		if (Preamp > PreampMax)																	;Если усиление больше максимального значения,
		{
			Preamp = %PreampMax%																;Установить максимальное значение усиления.
		}
		WriteCFG()																				;И записать в конфигурацию с помощью функции WriteCFG,
	}
	else																						;Если усиление больше или равно максимальнму значению,
	{
		if FileExist("agc.txt")																	;Если в конфиге включен AGC
		{
			AGC = Include: agc.txt																;Включить AGC
			WriteCFG()																			;И записать в конфигурацию с помощью функции WriteCFG,
		}
	}
	OSD()																						;Использовать функцию OSD для отображения значения усиления.
	return																						;Конец горячей клавиши.

WriteCFG()																						;Функция WriteCFG отвечает за запись изменений в файл конфигурации.
{
	FileDelete, ahk.tmp																			;Удалить старый файл конфигурации, чтобы подготовить его к перезаписи,
	FileAppend, Include: %Include%`n, ahk.tmp													;Сначала записать во временный файл,
	FileAppend, #Label: %Label%`n, ahk.tmp
	FileAppend, #Include1: %Include1%`n, ahk.tmp
	FileAppend, #Label1: %Label1%`n, ahk.tmp
	FileAppend, #Include2: %Include2%`n, ahk.tmp
	FileAppend, #Label2: %Label2%`n, ahk.tmp
	FileAppend, %Bass%`n, ahk.tmp
	FileAppend, Preamp: %Preamp%`n, ahk.tmp
	FileAppend, #PreampMin: %PreampMin%`n, ahk.tmp
	FileAppend, #PreampMax: %PreampMax%`n, ahk.tmp
	FileAppend, #PreampStep: %PreampStep%`n, ahk.tmp
	FileAppend, %AGC%, ahk.tmp
	FileCopy, ahk.tmp, ahk.txt, 1																;Затем перезаписать файл усиления временным файлом, для более плавного процесса регулировки громкости и уменьшения хлопков.
}
