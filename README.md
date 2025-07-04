# EqualizerAPO.ahk
Скрипт для [Equalizer APO](https://sourceforge.net/projects/equalizerapo/)

Создан на [AutoHotkey v1.1.37.02](https://www.autohotkey.com/)

Спасибо за идею и иконку [Brad331](https://github.com/Brad331/APOpreamp.ahk/)

Спасибо за скрипт смены устройства вывода звука [Flipeador](https://www.autohotkey.com/boards/viewtopic.php?f=76&t=49980#p221777) 
1. Скачать .exe и расположить в удобном месте, например: 
    >C:\Program Files\EqualizerAPO\config\ahk\EqualizerAPO 1.5.exe
2. Запустить скрипт, при первом запуске:
* Будет проверено установлен ли Equalizer APO
   * В случае чего будет уведомление о неустановленном Equalizer APO и открыта ссылка на его загрузку
* Будет предложено добавить файл конфигурации в Equalizer APO
   * Добавляется строка "Include: (название файла конфигурации)" в файл
      >C:\Program Files\EqualizerAPO\config\config.txt
* Будет предложено перейти на страницу проекта (сюда)
* Создастся файл конфигурации с названием файла скрипта, но с расширением .txt
* Скрипт будет добавлен в автозагрузку
    * Создается ярлык скрипта в
      >%AppData%\Microsoft\Windows\Start Menu\Programs\Startup
3. Настроить под себя
* Нажать AltGr+Volume_Up (у меня Fn+AltGr+F12)
* Либо напрямую в файле конфигурации, после чего необходимо перезапустить скрипт для применения настроек
* Можно настроить:
  * Какие два устройства вывода звука переключать
  * Какие два профиля Equalizer APO переключать
  * Отображаемое название профилей Equalizer APO
  * Шаг регулировки громкости в дБ
  * Какой VST плагин использовать при привышении 0дБ
  * Масштабирование монитора
  * Автозагрузку скрипта при запуске системы
# Возможности:
* Автозагрузка скрипта при запуске системы
* Переключение между двух устройств по горячей клавише Volume_Mute (у меня Fn+F9)
* Переключение между двух профилей по горячей клавише Media_Stop (у меня Fn+F10)
* При нажатии мультимедиа кнопок громкости Volume_Down и Volume_Up (у меня Fn+F11 и Fn+F12):
   * Фиксируется системная громкость на 100%
   * Регулируется громкость через Equalizer APO
* Включение VST плагина при привышении 0дБ
   * Подразумевается плагин [лимитера](https://loudmax.blogspot.com/) или [авторегулировки громкости](https://www.hornetplugins.com/plugins/hornet-vu-meter-mk4/), ссылки приведены как пример
* Настройка конфинга по горячей клавише AltGr+Volume_Up (у меня Fn+AltGr+F12)
# Поддержать меня материально <3
По номеру карты Cбербанка: 5336 6903 0152 7182
