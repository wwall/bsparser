﻿
// Проверка комментариев в окончаниях инструкций

Перем Узлы;
Перем Исходник;
Перем Результат;
Перем Комментарии;
Перем УровеньОбласти;
Перем СтекОбластей;

Процедура Инициализировать(Парсер) Экспорт
	Узлы = Парсер.Узлы();
	Исходник = Парсер.Исходник();
	Результат = Новый Массив;
	УровеньОбласти = 0;
	СтекОбластей = Новый Соответствие;
КонецПроцедуры

Функция Закрыть() Экспорт
	Возврат СтрСоединить(Результат, Символы.ПС);
КонецФункции

Функция Подписки() Экспорт
	Перем Подписки;
	Подписки = Новый Массив;
	Подписки.Добавить("ПосетитьМодуль");
	Подписки.Добавить("ПосетитьОбъявлениеМетода");
	Подписки.Добавить("ПосетитьИнструкциюПрепроцессора");
	Возврат Подписки;
КонецФункции

Процедура ПосетитьМодуль(Модуль) Экспорт
	Комментарии = Модуль.Комментарии;
КонецПроцедуры

Процедура ПосетитьОбъявлениеМетода(ОбъявлениеМетода) Экспорт
	Комментарий = Комментарии[ОбъявлениеМетода.Место.НомерПоследнейСтроки];
	Если Комментарий <> Неопределено И СокрП(Комментарий) <> СтрШаблон(" %1%2", ОбъявлениеМетода.Сигнатура.Имя, "()") Тогда
		Результат.Добавить(СтрШаблон("Метод `%1()` имеет неправильный замыкающий комментарий в строке %2", ОбъявлениеМетода.Сигнатура.Имя, ОбъявлениеМетода.Место.НомерПоследнейСтроки));
	КонецЕсли;
КонецПроцедуры

Процедура ПосетитьИнструкциюПрепроцессора(ИнструкцияПрепроцессора) Экспорт
	Если ИнструкцияПрепроцессора.Тип = Узлы.ИнструкцияПрепроцессораОбласть Тогда
		УровеньОбласти = УровеньОбласти + 1;
		СтекОбластей[УровеньОбласти] = ИнструкцияПрепроцессора.Имя;
	ИначеЕсли ИнструкцияПрепроцессора.Тип = Узлы.ИнструкцияПрепроцессораКонецОбласти Тогда
		Комментарий = Комментарии[ИнструкцияПрепроцессора.Место.НомерПервойСтроки];
		ИмяОбласти = СтекОбластей[УровеньОбласти];
		Если Комментарий <> Неопределено И СокрП(Комментарий) <> СтрШаблон(" %1", ИмяОбласти) Тогда
			Результат.Добавить(СтрШаблон("Область `%1` имеет неправильный замыкающий комментарий в строке %2:", ИмяОбласти, ИнструкцияПрепроцессора.Место.НомерПервойСтроки));
			Результат.Добавить(СтрШаблон("%1`%2%3`", Символы.Таб, Сред(Исходник, ИнструкцияПрепроцессора.Место.Позиция, ИнструкцияПрепроцессора.Место.Длина), Комментарий));
		КонецЕсли;
		УровеньОбласти = УровеньОбласти - 1;
	КонецЕсли;
КонецПроцедуры
