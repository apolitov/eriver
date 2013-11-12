eriver
======
Проект использует статический генератор страниц [Wintersmith](http://wintersmith.io/). В среде разработки поддерживается перезагрузка страницы «на лету» (livereload).

### Установка зависимостей:
Для установки зависимостей используется `npm`:
```
cd ./wintersmith
npm install
```

### Предпросмотр

Для предпросмотра сайта (порт `1337`), без учета скомпилированных с помощью`compass watch` таблиц стилей (см. ниже):
```
wintersmith preview
```

Компиляция сайта (результат из папки ./wintersmith/build можно сразу размещать на сервере):
```
compass compile
wintersmith build
```

Отдельные интерпретаторы
======

Следующие интерпретаторы придется установить отдельно.

### CoffeeScript
Вместо vanilla JavaScript используется [CoffeeScript](http://coffeescript.org/). Компилятор CoffeeScript требуется установить отдельно, но дальше файлы `.coffee` Wintersmith будет компилировать самостоятельно.

### Compass (SASS)
В качестве препроцессора CSS используется фреймворк [Compass](http://compass-style.org/) для [SASS](http://sass-lang.com/). Так как Wintersmith не умеет работать с Сompass, для его настройки служит файл `./wintersmith/config.rb`. Таким образом, таблицы стилей `.scss` придется компилировать отдельно. Запуск отслеживания изменений и автоматической компиляции:
```
cd ./wintersmith
compass watch
```