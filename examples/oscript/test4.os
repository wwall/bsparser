ПодключитьСценарий("..\src\ПарсерВстроенногоЯзыка\Ext\ObjectModule.bsl", "Парсер");
ПодключитьСценарий("..\plugins\ДетекторОшибочныхЗамыкающихКомментариев\src\ДетекторОшибочныхЗамыкающихКомментариев\Ext\ObjectModule.bsl", "ДетекторОшибочныхЗамыкающихКомментариев");
ПодключитьСценарий("..\plugins\ДетекторПропущенныхТочекСЗапятой\src\ДетекторПропущенныхТочекСЗапятой\Ext\ObjectModule.bsl", "ДетекторПропущенныхТочекСЗапятой");

Если АргументыКоманднойСтроки.Количество() <> 2 Тогда
	ВызватьИсключение "Укажите в качестве параметров список модулей bsl через ';' и имя файла отчета";
КонецЕсли;

Пути = СтрРазделить(АргументыКоманднойСтроки[0], ";");
Файлы = Новый Массив;
Для Каждого Путь Из Пути Цикл
	Файлы.Добавить(Новый Файл(Путь));
КонецЦикла;

Парсер = Новый Парсер;

Плагины = Новый Массив;
Плагины.Добавить(Новый ДетекторОшибочныхЗамыкающихКомментариев);
Плагины.Добавить(Новый ДетекторПропущенныхТочекСЗапятой);

ЧтениеТекста = Новый ЧтениеТекста;

Отчет = Новый Массив;

Для Каждого Файл Из Файлы Цикл
	Если Файл.ЭтоФайл() Тогда
		ЧтениеТекста.Открыть(Файл.ПолноеИмя, "UTF-8");
		Исходник = ЧтениеТекста.Прочитать();
		Попытка
			Парсер.Пуск(Исходник, Плагины);
			Для Каждого Ошибка Из Парсер.ТаблицаОшибок() Цикл
				Отчет.Добавить(Символы.ПС);
				Отчет.Добавить(Файл.ПолноеИмя);
				Отчет.Добавить(Символы.ПС);
				Отчет.Добавить(Ошибка.Текст);
				Отчет.Добавить(СтрШаблон(" [стр: %1; кол: %2]", Ошибка.НомерСтрокиНачала, Ошибка.НомерКолонкиНачала));
				Отчет.Добавить(Символы.ПС);
			КонецЦикла;
		Исключение
			Отчет.Добавить(Символы.ПС);
			Отчет.Добавить(Файл.ПолноеИмя);
			Отчет.Добавить(Символы.ПС);
			Отчет.Добавить("ОШИБКА:");
			Отчет.Добавить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			Отчет.Добавить(Символы.ПС);
		КонецПопытки;
		ЧтениеТекста.Закрыть();
	КонецЕсли;
КонецЦикла;

ЗаписьТекста = Новый ЗаписьТекста(АргументыКоманднойСтроки[1], "UTF-8",, Истина);
ЗаписьТекста.Записать(СтрСоединить(Отчет));
ЗаписьТекста.Закрыть();

Сообщить(СтрШаблон("Проверка закончена. Отчет о проверке находится в файле '%1'", АргументыКоманднойСтроки[1]));