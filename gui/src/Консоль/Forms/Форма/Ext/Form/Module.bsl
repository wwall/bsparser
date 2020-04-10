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
	
	Результат.Очистить();
	ОчиститьСообщения();
	ВыполнитьНаСервере();

КонецПроцедуры

&НаСервере
Процедура ВыполнитьНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ФайлОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	ПутьКФайлуПарсера = ФайлОбработки.Путь + "ПарсерВстроенногоЯзыка.epf";
	
	Парсер = ВнешниеОбработки.Создать(ПутьКФайлуПарсера, Ложь);
	
	НовыйХэшПарсера = SHA1(Новый ДвоичныеДанные(ПутьКФайлуПарсера));	
	Если НовыйХэшПарсера <> ХэшПарсера Тогда
		ХэшИсходника = "";
	КонецЕсли;	
	ХэшПарсера = НовыйХэшПарсера;
	
	Текст = Исходник.ПолучитьТекст();
	
	Начало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если Вывод = "NULL" Тогда 
		
		Разобрать(Парсер, Текст);	
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
	ИначеЕсли Вывод = "АСД" Тогда 
		
		Модуль = Разобрать(Парсер, Текст);
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
		Если Модуль <> Неопределено Тогда 
			ЗаписьJSON = Новый ЗаписьJSON;
			ЗаписьJSON.SetString(Новый ПараметрыЗаписиJSON(, Chars.Tab));
			Если ПоказыватьКомментарии Тогда 
				Комментарии = Новый Соответствие;
				Для Каждого Элемент Из Модуль.Комментарии Цикл 
					Комментарии[Формат(Элемент.Ключ, "NZ=0; NG=")] = Элемент.Значение;				
				КонецЦикла;
				Модуль.Комментарии = Комментарии;			
			Иначе 
				Модуль.Удалить("Комментарии");			
			КонецЕсли;
			ЗаписатьJSON(ЗаписьJSON, Модуль, , "КонвертироватьЗначениеJSON", ЭтотОбъект);
			Результат.УстановитьТекст(ЗаписьJSON.Закрыть());		
		КонецЕсли;	
	
	ИначеЕсли Вывод = "Дерево" Тогда 
		
		Модуль = Разобрать(Парсер, Текст);
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
		Если Модуль <> Неопределено Тогда 
			ЗаполнитьДерево(Модуль);		
		КонецЕсли;	
	
	ИначеЕсли Вывод = "Плагины" Тогда 
		
		Модуль = Разобрать(Парсер, Текст);
		
		Если Модуль <> Неопределено Тогда 
			СписокПлагинов = Новый Массив;
			Для Каждого Строка Из Плагины.НайтиСтроки(Новый Структура("Выкл", Ложь)) Цикл 
				СписокПлагинов.Добавить(ВнешниеОбработки.Создать(Строка.Путь, Ложь));			
			КонецЦикла;
			Парсер.Подключить(СписокПлагинов);
			Парсер.Посетить(Модуль, Текст);
			ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
			МассивРезультатов = Новый Массив;
			Для Каждого Плагин Из СписокПлагинов Цикл 
				МассивРезультатов.Добавить(Плагин.Закрыть());			
			КонецЦикла;
			Результат.УстановитьТекст(СтрСоединить(МассивРезультатов));		
		КонецЕсли;	
		
	ИначеЕсли Вывод = "Бакенд" Тогда 
		
		Модуль = Разобрать(Парсер, Текст);
		
		Если Модуль <> Неопределено Тогда 
			Бакенд = ВнешниеОбработки.Создать(ПутьБакенда, Ложь);			
			Бакенд.Инициализировать(Парсер);
			ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
			Результат.УстановитьТекст(Бакенд.Посетить(Модуль));		
		КонецЕсли;	
		
	ИначеЕсли Вывод = "Токены" Тогда 
		
		Токены.Загрузить(Парсер.Токенизировать(Исходник.ПолучитьТекст()).Токены);	
		
		ПрошлоВМиллисекундах = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
		
	КонецЕсли;
	
	Если ЗамерВремени Тогда 
		Сообщить(СтрШаблон("%1 сек.", ПрошлоВМиллисекундах / 1000));	
	КонецЕсли;
	
	Ошибки.Загрузить(Парсер.Ошибки());

КонецПроцедуры

&НаСервере
Функция Разобрать(Парсер, Текст)
	
	НовыйХэшИсходника = SHA1(ПолучитьДвоичныеДанныеИзСтроки(Текст));
	
	Если ИспользоватьКэшАСД И НовыйХэшИсходника = ХэшИсходника Тогда
		
		Модуль = ПолучитьИзВременногоХранилища(АдресКэшаАСД);
		
		ОшибкиПарсера = Парсер.Ошибки();
		ОшибкиПарсера.Очистить();
		Для Каждого Строка Из ПолучитьИзВременногоХранилища(АдресКэшаОшибок) Цикл
			ЗаполнитьЗначенияСвойств(ОшибкиПарсера.Добавить(), Строка);
		КонецЦикла;
		
	Иначе
		
		Попытка 
			
			Парсер.СтрогийРежим = СтрогийРежим;
			Модуль = Парсер.Разобрать(Текст);		
			
			АдресКэшаАСД = ПоместитьВоВременноеХранилище(Модуль, УникальныйИдентификатор);;
			АдресКэшаОшибок = ПоместитьВоВременноеХранилище(Парсер.Ошибки(), УникальныйИдентификатор);
			ХэшИсходника = НовыйХэшИсходника;
			
		Исключение 
			
			Сообщить("ошибка синтаксиса!");		
			
		КонецПопытки;
		
	КонецЕсли; 
	
	Возврат Модуль;
	
КонецФункции

&НаСервере
Функция ЗаполнитьДерево(Модуль)
	ДеревоУзлов = Дерево.ПолучитьЭлементы();
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
	Если Узел.Свойство("Место", Место) И ТипЗнч(Место) = Тип("Структура") Тогда 
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
	Элементы.ПоказыватьКомментарии.Видимость = (ЭтотОбъект.Вывод = "АСД");
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
	СтрокаДерева = Дерево.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если СтрокаДерева.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(СтрокаДерева.Позиция, СтрокаДерева.Позиция + СтрокаДерева.Длина);
		ТекущийЭлемент = Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТокеныВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Строка = Токены.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + Строка.Длина);
		ТекущийЭлемент = Элементы.Исходник;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПлагиныПутьОткрытие(Item, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПоказатьФайл(Элементы.Плагины.ТекущиеДанные.Путь);
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
	Строка = Ошибки.НайтиПоИдентификатору(ВыбраннаяСтрока);
	Если Строка.НомерСтроки > 0 Тогда 
		Элементы.Исходник.УстановитьГраницыВыделения(Строка.Позиция, Строка.Позиция + 1);
		ТекущийЭлемент = Элементы.Исходник;	
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
	ПоказатьФайл(Элементы.Плагины.ТекущиеДанные.Путь);
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
