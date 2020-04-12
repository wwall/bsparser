﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отмена, СтандартнаяОбработка)
	
	Если СтрНайти(СтрокаСоединенияИнформационнойБазы (), "File=") = 0 Тогда 
		Сообщить("Только для файловых баз");	
	КонецЕсли;
	
	Вывод = "Дерево";

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Cancel)
	
	УстановитьВидимостьЭлементов(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура КомандаВыполнить(Command)
	
	ЭтотОбъект.Результат.Очистить();
	ОчиститьСообщения();
	ВыполнитьНаСервере();

КонецПроцедуры

&НаСервере
Процедура ВыполнитьНаСервере()
	
	ОбработкаОбъект = ЭтотОбъект.РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	ПутьКФайлуПарсера = ФайлОбработки.Путь + "ПарсерВстроенногоЯзыка.epf";
	
	Парсер = ВнешниеОбработки.Создать(ПутьКФайлуПарсера, Ложь);
	
	НовыйХэшПарсера = SHA1(Новый ДвоичныеДанные(ПутьКФайлуПарсера));	
	Если НовыйХэшПарсера <> ЭтотОбъект.ХэшПарсера Тогда
		ХэшИсходника = "";
	КонецЕсли;	
	ХэшПарсера = НовыйХэшПарсера;
	
	ТекстМодуля = ЭтотОбъект.Исходник.ПолучитьТекст();
	
	Начало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если ЭтотОбъект.Вывод = "NULL" Тогда 
		
		Разобрать(Парсер, ТекстМодуля);	
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
	ИначеЕсли ЭтотОбъект.Вывод = "АСД" Тогда 
		
		Модуль = Разобрать(Парсер, ТекстМодуля);
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
		Если Модуль <> Неопределено Тогда 
			ЗаписьJSON = Новый ЗаписьJSON;
			ЗаписьJSON.SetString(Новый ПараметрыЗаписиJSON(, Chars.Tab));
			КопияМодуля = Новый Структура(Модуль);
			КопияМодуля.Удалить("Комментарии");
			ЗаписатьJSON(ЗаписьJSON, КопияМодуля, , "КонвертироватьЗначениеJSON", ЭтотОбъект);
			ЭтотОбъект.Результат.УстановитьТекст(ЗаписьJSON.Закрыть());		
		КонецЕсли;	
	
	ИначеЕсли ЭтотОбъект.Вывод = "Дерево" Тогда 
		
		Модуль = Разобрать(Парсер, ТекстМодуля);
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
		Если Модуль <> Неопределено Тогда 
			ЗаполнитьДерево(Модуль);		
		КонецЕсли;	
	
	ИначеЕсли ЭтотОбъект.Вывод = "Плагины" Тогда 
		
		Модуль = Разобрать(Парсер, ТекстМодуля);
		
		Если Модуль <> Неопределено Тогда 
			СписокПлагинов = Новый Массив;
			Для Каждого Строка Из ЭтотОбъект.Плагины.НайтиСтроки(Новый Структура("Выкл", Ложь)) Цикл 
				СписокПлагинов.Добавить(ВнешниеОбработки.Создать(Строка.Путь, Ложь));			
			КонецЦикла;
			Парсер.Подключить(СписокПлагинов);
			Парсер.Посетить(Модуль);
			ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
			МассивРезультатов = Новый Массив;
			Для Каждого Плагин Из СписокПлагинов Цикл 
				МассивРезультатов.Добавить(Плагин.Закрыть());			
			КонецЦикла;
			ЭтотОбъект.Результат.УстановитьТекст(СтрСоединить(МассивРезультатов));		
		КонецЕсли;	
		
	ИначеЕсли ЭтотОбъект.Вывод = "Бакенд" Тогда 
		
		Модуль = Разобрать(Парсер, ТекстМодуля);
		
		Если Модуль <> Неопределено Тогда 
			Бакенд = ВнешниеОбработки.Создать(ЭтотОбъект.ПутьБакенда, Ложь);			
			Текст = Бакенд.Посетить(Парсер, Модуль);
			ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
			ЭтотОбъект.Результат.УстановитьТекст(Текст);		
		КонецЕсли;	
		
	ИначеЕсли ЭтотОбъект.Вывод = "Токены" Тогда 
		
		ЭтотОбъект.Токены.Загрузить(Парсер.Токенизировать(ЭтотОбъект.Исходник.ПолучитьТекст()).Токены);	
		
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
	КонецЕсли;
	
	Если ЭтотОбъект.ЗамерВремени Тогда 
		Сообщить(СтрШаблон("%1 сек.", ПрошлоВМиллисекундах / 1000));	
	КонецЕсли;
	
	ЭтотОбъект.Ошибки.Загрузить(Парсер.Ошибки());
	ЭтотОбъект.КоличествоОшибок = ЭтотОбъект.Ошибки.Количество();
	
КонецПроцедуры

&НаСервере
Функция Разобрать(Парсер, ТекстМодуля)
	
	НовыйХэшИсходника = SHA1(ПолучитьДвоичныеДанныеИзСтроки(ТекстМодуля));
	
	Если ЭтотОбъект.ИспользоватьКэшАСД И НовыйХэшИсходника = ЭтотОбъект.ХэшИсходника Тогда
		
		Модуль = ПолучитьИзВременногоХранилища(ЭтотОбъект.АдресКэшаАСД);
		
		ОшибкиПарсера = Парсер.Ошибки();
		ОшибкиПарсера.Очистить();
		Для Каждого Строка Из ПолучитьИзВременногоХранилища(ЭтотОбъект.АдресКэшаОшибок) Цикл
			Если Строка.Источник = "ПарсерВстроенногоЯзыка" Тогда
				ЗаполнитьЗначенияСвойств(ОшибкиПарсера.Добавить(), Строка);
			КонецЕсли;
		КонецЦикла;
		
		Парсер.УстановитьИсходник(ТекстМодуля);
		
	Иначе
		
		Попытка 
			
			Парсер.СтрогийРежим = ЭтотОбъект.СтрогийРежим;
			Модуль = Парсер.Разобрать(ТекстМодуля);
			
			Модуль = Новый ФиксированнаяСтруктура(Модуль);
			
			АдресКэшаАСД = ПоместитьВоВременноеХранилище(Модуль, ЭтотОбъект.УникальныйИдентификатор);;
			АдресКэшаОшибок = ПоместитьВоВременноеХранилище(Парсер.Ошибки(), ЭтотОбъект.УникальныйИдентификатор);
			ХэшИсходника = НовыйХэшИсходника;
			
		Исключение 
			
			Сообщить("ошибка синтаксиса!");		
			
		КонецПопытки;
		
	КонецЕсли; 
	
	Возврат Модуль;
	
КонецФункции

&НаСервере
Функция ЗаполнитьДерево(Модуль)
	ДеревоУзлов = ЭтотОбъект.Дерево.ПолучитьЭлементы();
	ДеревоУзлов.Очистить();
	СтрокаДерева = ДеревоУзлов.Добавить();
	СтрокаДерева.Имя = "Модуль";
	СтрокаДерева.Тип = Модуль.Тип;
	СтрокаДерева.Значение = "<...>";
	ЗаполнитьУзел(СтрокаДерева, Модуль);
КонецФункции

&НаСервере
Функция ЗаполнитьУзел(СтрокаДерева, Узел)
	Перем Место;
	Если ТипЗнч(Узел) = Тип("Структура") И Узел.Свойство("Место", Место) И ТипЗнч(Место) = Тип("Структура") Тогда
		СтрокаДерева.НомерСтроки = Место.НомерПервойСтроки;
		СтрокаДерева.Позиция = Место.Позиция;
		СтрокаДерева.Длина = Место.Длина;
	КонецЕсли;
	ЭлементыДерева = СтрокаДерева.ПолучитьЭлементы();
	Для Каждого Элемент Из Узел Цикл 
		Если Элемент.Ключ = "Место"
		Или Элемент.Ключ = "Тип" Тогда 
			Продолжить;		
		КонецЕсли;
		Если ТипЗнч(Элемент.Значение) = Тип("Массив") Тогда 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			СтрокаДерева.Тип = СтрШаблон("Массив (%1)", Элемент.Значение.Количество());
			СтрокаДерева.Значение = "<...>";
			ЭлементыСтроки = СтрокаДерева.ПолучитьЭлементы();
			Индекс = 0;
			Для Каждого Элемент Из Элемент.Значение Цикл 
				СтрокаДерева = ЭлементыСтроки.Добавить();
				СтрокаДерева.Имя = СтрШаблон("[%1]", Индекс);
				Индекс = Индекс + 1;
				Если Элемент = Неопределено Тогда 
					СтрокаДерева.Значение = "Неопределено";				
				ИначеЕсли ТипЗнч(Элемент) = Тип("Строка") Тогда
					СтрокаДерева.Тип = "Строка";
					СтрокаДерева.Значение = Элемент;	
				Иначе 
					Элемент.Свойство("Тип", СтрокаДерева.Тип);
					СтрокаДерева.Значение = "<...>";
					ЗаполнитьУзел(СтрокаДерева, Элемент);				
				КонецЕсли;			
			КонецЦикла;		
		ИначеЕсли ТипЗнч(Элемент.Значение) = Тип("Структура") Тогда 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			Если Не Элемент.Значение.Свойство("Тип", СтрокаДерева.Тип) Тогда
				СтрокаДерева.Тип = "Структура";
			КонецЕсли;
			СтрокаДерева.Значение = "<...>";
			ЗаполнитьУзел(СтрокаДерева, Элемент.Значение);
		Иначе 
			СтрокаДерева = ЭлементыДерева.Добавить();
			СтрокаДерева.Имя = Элемент.Ключ;
			СтрокаДерева.Значение = Элемент.Значение;
			СтрокаДерева.Тип = ТипЗнч(Элемент.Значение);		
		КонецЕсли;	
	КонецЦикла;
КонецФункции

&НаСервере
Функция КонвертироватьЗначениеJSON(Свойство, Значение, Другое, Отмена) Экспорт
	Если Значение = Null Тогда 
		Возврат Неопределено;	
	КонецЕсли;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьВидимостьЭлементов(ЭтотОбъект)
	
	Элементы = ЭтотОбъект.Элементы;
	
	Элементы.СтраницаПлагины.Видимость = (ЭтотОбъект.Вывод = "Плагины");
	Элементы.СтраницаРезультатДерево.Видимость = (ЭтотОбъект.Вывод = "Дерево");
	Элементы.СтраницаРезультатТекст.Видимость = (
		ЭтотОбъект.Вывод = "Плагины"
		Или ЭтотОбъект.Вывод = "АСД"
		Или ЭтотОбъект.Вывод = "Бакенд"
	);
	Элементы.ПутьБакенда.Видимость = (ЭтотОбъект.Вывод = "Бакенд"); 
	Элементы.СтраницаРезультатТокены.Видимость = (ЭтотОбъект.Вывод = "Токены");	

КонецПроцедуры

&НаКлиенте
Процедура ВыводПриИзменении(Item)
	
	Если ЭтотОбъект.Вывод = "Дерево" Тогда
		ЭтотОбъект.Результат.Очистить();
	КонецЕсли;
	
	УстановитьВидимостьЭлементов(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура ПлагиныПутьНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьПуть(Элемент, ЭтотОбъект, РежимДиалогаВыбораФайла.Открытие, "(*.epf)|*.epf");

КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПуть(Элемент, Форма, РежимДиалога = Неопределено, Фильтр = Неопределено) Экспорт
	
	Если РежимДиалога = Неопределено Тогда 
		РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога;	
	КонецЕсли;
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалога);
	ДиалогВыбораФайла.МножественныйВыбор = Ложь;
	ДиалогВыбораФайла.Фильтр = Фильтр;
	Если РежимДиалога = РежимДиалогаВыбораФайла.ВыборКаталога Тогда 
		ДиалогВыбораФайла.Каталог = Элемент.ТекстРедактирования;	
	Иначе 
		ДиалогВыбораФайла.ПолноеИмяФайла = Элемент.ТекстРедактирования;	
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура("Элемент, Форма", Элемент, Форма);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборФайла", ЭтотОбъект, ДополнительныеПараметры);
	
	ДиалогВыбораФайла.Show(ОписаниеОповещения);

КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборФайла(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено Тогда 
		ИнтерактивноУстановитьЗначениеЭлементаФормы(
			Результат[0], 
			ДополнительныеПараметры.Элемент, 
			ДополнительныеПараметры.Форма
		);	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ИнтерактивноУстановитьЗначениеЭлементаФормы(Значение, Элемент, Форма) Экспорт
	
	ВладелецФормы = Форма.ВладелецФормы;
	ЗакрыватьПриВыборе = Форма.ЗакрыватьПриВыборе;
	
	Форма.ВладелецФормы = Элемент;
	Форма.ЗакрыватьПриВыборе = Ложь;
	
	Форма.ОповеститьОВыборе(Значение);
	
	Если Форма.ВладелецФормы = Элемент Тогда 
		Форма.ВладелецФормы = ВладелецФормы;	
	КонецЕсли;
	
	Если Форма.ЗакрыватьПриВыборе = Ложь Тогда 
		Форма.ЗакрыватьПриВыборе = ЗакрыватьПриВыборе;	
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ДеревоВыбор(Item, ВыбраннаяСтрока, Field, СтандартнаяОбработка)
	СтрокаДерева = ЭтотОбъект.Дерево.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если СтрокаДерева.НомерСтроки > 0 Тогда 
		ЭтотОбъект.Элементы.Исходник.УстановитьГраницыВыделения(СтрокаДерева.Позиция, СтрокаДерева.Позиция + СтрокаДерева.Длина);
		ТекущийЭлемент = ЭтотОбъект.Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТокеныВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Строка = ЭтотОбъект.Токены.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		ЭтотОбъект.Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + Строка.Длина);
		ТекущийЭлемент = ЭтотОбъект.Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПлагиныПутьОткрытие(Item, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьФайл(ЭтотОбъект.Элементы.Плагины.ТекущиеДанные.Путь);
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьФайл(ПолноеИмя) Экспорт
	Если ПолноеИмя <> Неопределено Тогда 
		BeginRunningApplication(
			Новый ОписаниеОповещения("ОбработатьПоказатьФайл", ЭтотОбъект, ПолноеИмя), 
			"explorer.exe /select, " + ПолноеИмя
		);	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьПоказатьФайл(ReturnCode, ПолноеИмя) Экспорт
 // silently continue
КонецПроцедуры

&НаКлиенте
Процедура ОшибкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Строка = ЭтотОбъект.Ошибки.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		ЭтотОбъект.Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + 1);
		ТекущийЭлемент = ЭтотОбъект.Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПутьБакендаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьПуть(Элемент, ЭтотОбъект, РежимДиалогаВыбораФайла.Открытие, "(*.epf)|*.epf");
	
КонецПроцедуры

&НаКлиенте
Процедура ПутьБакендаОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьФайл(ЭтотОбъект.Элементы.Плагины.ТекущиеДанные.Путь);
КонецПроцедуры

&НаСервереБезКонтекста
Функция SHA1(ДвоичныеДанные) Экспорт
	Перем SHA1;
			
	ХешированиеДанных = Новый ХешированиеДанных (ХешФункция .SHA1);
	ХешированиеДанных.Добавить("blob " + Format(ДвоичныеДанные.Size(), "NZ=0; NG=") + Char(0));
	ХешированиеДанных.Добавить(ДвоичныеДанные);
	
	SHA1 = ПолучитьHexСтрокуИзДвоичныхДанных(ХешированиеДанных.ХешСумма);
	
	Возврат SHA1;

КонецФункции

&НаКлиенте
Процедура СтрогийРежимПриИзменении(Элемент)
	
	ХэшИсходника = Неопределено; // Сброс кэша
	
КонецПроцедуры
