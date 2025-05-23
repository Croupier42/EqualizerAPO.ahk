;Версия скрипта 1.2
;Создан https://web.telegram.org/#@Croupier42
;Для https://sourceforge.net/projects/equalizerapo/
;Основан на https://github.com/Brad331/APOpreamp.ahk
;Требуется https://www.autohotkey.com/ v1.1
;Зачем я это сделал? Потому что я ненавижу системную регулировку винды. Ну и для смены профилей APO по горячей клавише.
;блять научите как сделать нормально, а не то что ниже...

if !FileExist("ahk.tmp")																		;Если нет файла конфига, создать используя настройки по умолчанию
{																								;Сначала записать во временный файл,
	FileAppend, Include: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt`n, ahk.tmp											;Текущий профиль коррекции
	FileAppend, #Label: NOEMA`n, ahk.tmp																						;Название текущего профиля коррекции
	FileAppend, #Include1: D:\Programs\EqualizerAPO\NOEMA\NOEMA Filters.txt`n, ahk.tmp											;Профиль коррекции 1
	FileAppend, #Label1: NOEMA`n, ahk.tmp																						;Название профиля коррекции 1
	FileAppend, #Include2: D:\Programs\EqualizerAPO\Headphones\Zero_2\7Hz-Salnotes x Crinacle Zero_2 Filters.txt`n, ahk.tmp		;Профиль коррекции 2
	FileAppend, #Label2: Zero:2`n, ahk.tmp																						;Название профиля коррекции 2
	FileAppend, Preamp: -30`n, ahk.tmp																							;Текущее усиление
	FileAppend, #PreampMin: -60`n, ahk.tmp																						;Минимальное значение усиления
	FileAppend, #PreampMax: 10`n, ahk.tmp																						;Максимальное значение усиления
	FileAppend, #PreampStep: 5`n, ahk.tmp																						;Шаг изменения усиления
	FileAppend, #AGCVST: 1, ahk.tmp																								;Включать ли профиль с вст плагином HoRNet VU Meter MK4 при максимальном усилении
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
global Preamp := SubStr(line, 9)
FileReadLine, line, ahk.txt, 8
global PreampMin := SubStr(line, 13)
FileReadLine, line, ahk.txt, 9
global PreampMax := SubStr(line, 13)
FileReadLine, line, ahk.txt, 10
global PreampStep := SubStr(line, 14)
FileReadLine, line, ahk.txt, 11
global AGCVST := SubStr(line, 10)
if (AGCVST == 1)
{
	PreampMax = 0
}
global AGC := "#Include: agc.txt"																;Внутренняя переменная AGCVST
global PreampVisual :=																			;Внутренняя переменная для визуала

Gui +LastFound +AlwaysOnTop -Caption +ToolWindow												;Окно OSD. Как это уёбище сделать красивым?
Gui, Color, 000000																				;Цвет фона
Gui, Font, s24,																					;Размер шрифта
Gui, Margin, 4, 0																				;Отступы
Gui, Add, Text, vOSDText cFFFFFF, %Label% %PreampVisual%----------										;Текст, цвет текста
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
	GuiControl,, OSDText, %Label% %PreampVisual%												;Обновление значений
	Gui, Show, x100 y100 NoActivate																;Показать
	SetTimer, HideOSD, 1500																		;Таймер скрытия
	return
	HideOSD:																					;ХЗ че, но нужно для таймера
	Gui, Hide																					;Скрыть 
	return
}

$Volume_Mute::																					;При нажатии кнопки мьют,
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

$Volume_Down::																					;При нажатии кнопки уменьшения громкости,
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
		AGC = #Include: agc.txt																	;Отключить VSTAGC
		WriteCFG()																				;И записать в конфигурацию с помощью функции WriteCFG,
	}
	OSD()																						;Использовать функцию OSD для отображения значения усиления.
	return																						;Конец горячей клавиши.

$Volume_Up::																					;При нажатии кнопки увеличения громкости,
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
		if (AGCVST == 1)																		;Если в конфиге включен VSTAGC
		{
			AGC = Include: agc.txt																;Включить VSTAGC
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
	FileAppend, Preamp: %Preamp%`n, ahk.tmp
	FileAppend, #PreampMin: %PreampMin%`n, ahk.tmp
	FileAppend, #PreampMax: %PreampMax%`n, ahk.tmp
	FileAppend, #PreampStep: %PreampStep%`n, ahk.tmp
	FileAppend, #AGCVST: %AGCVST%`n, ahk.tmp
	if (AGCVST == 1)
	{
		FileAppend, %AGC%, ahk.tmp
	}
	FileCopy, ahk.tmp, ahk.txt, 1																;Затем перезаписать файл усиления временным файлом, для более плавного процесса регулировки громкости и уменьшения хлопков.
}
