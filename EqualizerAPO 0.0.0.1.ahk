;Версия 0.0.0.1
;Создан croupier https://web.telegram.org/#@Croupier42
;Основан на базе https://github.com/Brad331/APOpreamp.ahk
;Если бы я мог измерить звуковое давление системы... я бы мог сделать значения громкости привязанными к реалу... правда оно было бы привязано только к одной системе...

global GainFile := "C:\Program Files\EqualizerAPO\config\ahk\Gain.txt"				;Изменяемый файл усиления, его нужно применить в EqualizerAPO.
global Gain := -30																	;Текущее усиление, а также значение при запуске скрипта
global GainMax := 10																;Максимальный уровень усиления, не рекомендую использовать выше 0 без индикатора громкости
global GainMin := -60																;Минимальный уровень усиления

global ProfileFile := "C:\Program Files\EqualizerAPO\config\ahk\Profile.txt"		;Изменяемый файл профиля, его нужно применить в EqualizerAPO.
global ProfileA := "C:\Program Files\EqualizerAPO\config\NOEMA\NOEMA Filters.txt"										;Расположение профиля А
global ProfileB := "C:\Program Files\EqualizerAPO\config\Headphones\Zero_2\7Hz-Salnotes x Crinacle Zero_2 Filters.txt"	;Расположение профиля А
global Profile := ProfileA															;Текущий профиль

WriteGain()																			;Применить значение усиления.
CoordMode, ToolTip																	;Установить для ToolTip режим CoordMode, чтобы она отображалась в абсолютной позиции на экране.

;																					;Добавление $ перед горячей клавишей позволяет избежать зацикливания, когда горячая клавиша отправляет себя.
$Volume_Up::																		;При нажатии кнопки увеличения громкости,
	SoundGet, SystemVolume															;Найти текущую системную громкость.
	if (SystemVolume = 100) {														;если системная громкость максимальна,
		if (Gain < GainMax) {
			Gain+=5																	;Увеличить усиление на (++ - 1дБ; +=5 - 5дБ),
			WriteGain()																;И записать в конфигурацию с помощью функции WriteGain,
		}
		ShowGain()																	;Использовать функцию ShowGain для отображения значения усиления в подсказке.
	}
	else {																			;Если системная громкость не максимальна,
		Send {Volume_Up}															;Увеличить системную громкость.
	}
	return																			;Конец горячей клавиши.

$Volume_Down::																		;При нажатии кнопки уменьшения громкости,
	if (Gain > GainMin) {
		Gain-=5																		;Уменьшить усиление на (++ - 1дБ; +=5 - 5дБ),
		WriteGain()																	;И записать в конфигурацию с помощью функции WriteGain,
		}
		ShowGain()																	;Использовать функцию ShowGain для отображения значения усиления в подсказке.
	return																			;Конец горячей клавиши.

WriteGain() {																		;Функция WriteGain отвечает за запись изменений в файл конфигурации.
	FileDelete, %GainFile%.tmp.txt													;Удалить старый файл конфигурации, чтобы подготовить его к перезаписи,
	FileAppend, Preamp: %Gain% dB, %GainFile%.tmp.txt								;Сначала записать во временный файл,
	FileCopy, %GainFile%.tmp.txt, %GainFile%, 1										;Затем перезаписать файл усиления временным файлом,
}																					;Для более плавного процесса регулировки громкости и уменьшения хлопков.

ShowGain() {
	ToolTip, Volume: %Gain% dB, 160, 90											;Показывать значение усиления во всплывающей подсказке в верхнем левом углу экрана.
	SetTimer, RemoveToolTip, -2000													;Таймер для всплывающей подсказки.
	return
	RemoveToolTip:																	;Автоматически скрыть подсказку.
	ToolTip
	return
}

$Volume_Mute::																		;При нажатии кнопки мьют,
	if (Profile == ProfileA) {														;Если текущий профиль - профиль А,
	Profile := ProfileB																;То заменить его на профиль B.
	}
	else {																			;Если текущий профиль - профиль B,
	Profile := ProfileA																;То заменить его на профиль A.
	}
	WriteProfile()																	;Записать в конфигурацию с помощью функции WriteProfile,
	ShowProfile()																	;Использовать функцию ShowProfile для отображения текущего профиля в подсказке.
	return																			;Конец горячей клавиши.

WriteProfile() {																	;Функция WriteProfile отвечает за запись изменений в файл конфигурации.
	FileDelete, %ProfileFile%.tmp.txt												;Удалить старый файл конфигурации, чтобы подготовить его к перезаписи,
	FileAppend, Include: %Profile%, %ProfileFile%.tmp.txt							;Сначала записать во временный файл,
	FileCopy, %ProfileFile%.tmp.txt, %ProfileFile%, 1								;Затем перезаписать файл профиля временным файлом,
}																					;Для более плавного процесса регулировки громкости и уменьшения хлопков.

ShowProfile() {
	ToolTip, Profile: %Profile%, 160, 90											;Показывать текущий профиль во всплывающей подсказке в верхнем левом углу экрана.
	SetTimer, RemoveToolTip, -2000													;Таймер для всплывающей подсказки.
	return
	ToolTip
	return
}
