#language: ru
@ExportScenarios
@IgnoreOnCIMainBuild
@tree

Функционал: export scenarios

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий.


# Pick up

Сценарий: check the product selection form with price information in Sales order
# sale order и sales invoice, Basic Partner terms, TRY, Ferron
	И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
	# temporarily
	Затем Если появилось окно диалога я нажимаю на кнопку 'OK'
	# temporarily
	И я проверяю отбор по виду номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Сlothes     |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title               | Unit  | In stock | Price  | Picked out |
			| Dress               | '*'   | '*'     | '*'    | '*'         |
			| Trousers            | '*'   | '*'     | '*'    | '*'         |
			| Shirt               | '*'   | '*'     | '*'    | '*'         |
	И я проверяю обновление отбора при выборе другого вида номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shoes       |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title      | Unit  | In stock | Price  | Picked out |
			| Boots      | '*'   | '*'      |'*'     | '*'         |
			| High shoes | '*'   | '*'      |'*'     | '*'         |
	И я проверяю сброс отборов
		И я нажимаю кнопку очистить у поля "Item type"
		И     таблица "ItemList" стала равной:
			| Title                | Unit  | In stock | Price  | Picked out |
			| Dress                | '*'   | '*'      |'*'     | '*'         |
			| Trousers             | '*'   | '*'      |'*'     | '*'         |
			| Shirt                | '*'   | '*'      |'*'     | '*'         |
			| Boots                | '*'   | '*'      |'*'     | '*'         |
			| High shoes           | '*'   | '*'      |'*'     | '*'         |
	И я проверяю отображение по товару item key в форме подбора
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И     таблица "ItemKeyList" стала равной:
			| Title     | Unit  | In stock | Price  | Picked out  |
			| S/Yellow  | '*'   | '*'      |'*'     | '*'         |
			| XS/Blue   | '*'   | '*'      |'*'     | '*'         |
			| M/White   | '*'   | '*'      |'*'     | '*'         |
			| L/Green   | '*'   | '*'      |'*'     | '*'         |
			| XL/Green  | '*'   | '*'      |'*'     | '*'         |
			| Dress/A-8 | '*'   | '*'      |'*'     | '*'         |
			| XXL/Red   | '*'   | '*'      |'*'     | '*'         |
			# | M/Brown   | '*'   | '*'      |'*'     | '*'         |
	И я проверяю добавление товара
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title    |
			| S/Yellow |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И     таблица "ItemTableValue" содержит строки:
			| 'Item'  | 'Quantity' | 'Item key' |
			| 'Dress' | '1,000'    | 'S/Yellow' |
	И я добавляю ещё одну строку и меняю по ней кол-во в таблице ItemTableValue
		Когда в таблице "ItemKeyList" я нажимаю на кнопку с именем 'ItemKeyListCommandBack'
		И в таблице "ItemList" я перехожу к строке:
			| 'Title'    |
			| 'Trousers' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'Title'     |
			| '38/Yellow' |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'     | 'Item key'  | 'Quantity' |
			| 'Trousers' | '38/Yellow' | '1,000'    |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '2,000'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И     таблица "ItemTableValue" стала равной:
			| 'Item'     | 'Quantity' | 'Item key'  |
			| 'Dress'    | '1,000'    | 'S/Yellow'  |
			| 'Trousers' | '2,000'    | '38/Yellow' |
	И я проверяю перенос подобранного товара в документ
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
		И Пауза 2
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550*'          |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800*'          |
	И я добавляю ещё одну строку в заказ через кнопку Add
		И я нажимаю на кнопку с именем "ItemListAdd"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shirt       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Item key"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
		И в таблице "List" я перехожу к строке:
			И в таблице "List" я перехожу к строке:
			| Item  | Item key |
			| Shirt | 36/Red   |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Q"
		И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
		И в таблице "ItemList" я завершаю редактирование строки
	* Checking the filling of the tabular part
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550,00'       |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800,00'       |
			| 'Shirt'    | '350,00' | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |
	И я добавляю ещё одну строку через форму подбора товара
		И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title   |
			| L/Green |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
		| 'Item'  | 'Item key' |
		| 'Dress' | 'L/Green' |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" я активизирую поле с именем "ItemTableValuePrice"
		И в таблице "ItemTableValue" в поле с именем 'ItemTableValuePrice' я ввожу текст '350,00'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
	И я проверяю табличную часть документа
		И     таблица "ItemList" стала равной:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550,00'       |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800,00'       |
			| 'Shirt'    | '350,00' | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |
			| 'Dress'    | '350,00' | 'L/Green'   | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |
	И я заполняю procurement method
		И в таблице "ItemList" я активизирую поле "Procurement method"
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице 'ItemList' я выделяю все строки
		И в таблице "ItemList" я нажимаю на кнопку 'Procurement'
		И я изменяю флаг 'Stock'
		И я нажимаю на кнопку 'OK'


Сценарий: check the product selection form with price information in Sales invoice
# sale order и sales invoice, Basic Partner terms, TRY, Ferron
	И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
	# temporarily
	Затем Если появилось окно диалога я нажимаю на кнопку 'OK'
	# temporarily
	И я проверяю отбор по виду номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Сlothes     |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title               | Unit  | In stock | Price  | Picked out |
			| Dress               | '*'   | '*'     | '*'    | '*'         |
			| Trousers            | '*'   | '*'     | '*'    | '*'         |
			| Shirt               | '*'   | '*'     | '*'    | '*'         |
	И я проверяю обновление отбора при выборе другого вида номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shoes       |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title      | Unit  | In stock | Price  | Picked out |
			| Boots      | '*'   | '*'      |'*'     | '*'         |
			| High shoes | '*'   | '*'      |'*'     | '*'         |
	И я проверяю сброс отборов
		И я нажимаю кнопку очистить у поля "Item type"
		И     таблица "ItemList" стала равной:
			| Title                | Unit  | In stock | Price  | Picked out |
			| Dress                | '*'   | '*'      |'*'     | '*'         |
			| Trousers             | '*'   | '*'      |'*'     | '*'         |
			| Shirt                | '*'   | '*'      |'*'     | '*'         |
			| Boots                | '*'   | '*'      |'*'     | '*'         |
			| High shoes           | '*'   | '*'      |'*'     | '*'         |
	И я проверяю отображение по товару item key в форме подбора
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И     таблица "ItemKeyList" стала равной:
			| Title     | Unit  | In stock | Price  | Picked out  |
			| S/Yellow  | '*'   | '*'      |'*'     | '*'         |
			| XS/Blue   | '*'   | '*'      |'*'     | '*'         |
			| M/White   | '*'   | '*'      |'*'     | '*'         |
			| L/Green   | '*'   | '*'      |'*'     | '*'         |
			| XL/Green  | '*'   | '*'      |'*'     | '*'         |
			| Dress/A-8 | '*'   | '*'      |'*'     | '*'         |
			| XXL/Red   | '*'   | '*'      |'*'     | '*'         |
			# | M/Brown   | '*'   | '*'      |'*'     | '*'         |
	И я проверяю добавление товара
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title    |
			| S/Yellow |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И     таблица "ItemTableValue" содержит строки:
			| 'Item'  | 'Quantity' | 'Item key' |
			| 'Dress' | '1,000'    | 'S/Yellow' |
	И я добавляю ещё одну строку и меняю по ней кол-во в таблице ItemTableValue
		Когда в таблице "ItemKeyList" я нажимаю на кнопку с именем 'ItemKeyListCommandBack'
		И в таблице "ItemList" я перехожу к строке:
			| 'Title'    |
			| 'Trousers' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'Title'     |
			| '38/Yellow' |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'     | 'Item key'  | 'Quantity' |
			| 'Trousers' | '38/Yellow' | '1,000'    |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '2,000'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И     таблица "ItemTableValue" стала равной:
			| 'Item'     | 'Quantity' | 'Item key'  |
			| 'Dress'    | '1,000'    | 'S/Yellow'  |
			| 'Trousers' | '2,000'    | '38/Yellow' |
	И я проверяю перенос подобранного товара в документ
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
		И Пауза 2
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550*'          |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800*'          |
	И я добавляю ещё одну строку в заказ через кнопку Add
		И я нажимаю на кнопку с именем "ItemListAdd"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shirt       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Item key"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
		И в таблице "List" я перехожу к строке:
			И в таблице "List" я перехожу к строке:
			| Item  | Item key |
			| Shirt | 36/Red   |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Q"
		И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
		И в таблице "ItemList" я завершаю редактирование строки
	* Checking the filling of the tabular part
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550,00'       |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800,00'       |
			| 'Shirt'    | '350,00' | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |
	И я добавляю ещё одну строку через форму подбора товара
		И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title   |
			| L/Green |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
		| 'Item'  | 'Item key' |
		| 'Dress' | 'L/Green' |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" я активизирую поле с именем "ItemTableValuePrice"
		И в таблице "ItemTableValue" в поле с именем 'ItemTableValuePrice' я ввожу текст '350,00'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
	И я проверяю табличную часть документа
		И     таблица "ItemList" стала равной:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Total amount' |
			| 'Dress'    | '550,00' | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '550,00'       |
			| 'Trousers' | '400,00' | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '800,00'       |
			| 'Shirt'    | '350,00' | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |
			| 'Dress'    | '350,00' | 'L/Green'   | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '350,00'       |

Сценарий: check the product selection form with price information in Purchase invoice
	# purchase order и purchase invoice, Basic Partner terms, TRY, Ferron
	И я нажимаю на кнопку с именем "OpenPickupItems"
	# temporarily
	Затем Если появилось окно диалога я нажимаю на кнопку 'OK'
	# temporarily
	И я проверяю отбор по виду номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Сlothes     |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title               | Unit  | In stock | Price  | Picked out |
			| Dress               | '*'   | '*'     | '*'    | '*'         |
			| Trousers            | '*'   | '*'     | '*'    | '*'         |
			| Shirt               | '*'   | '*'     | '*'    | '*'         |
	И я проверяю обновление отбора при выборе другого вида номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shoes       |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title      | Unit  | In stock | Price  | Picked out |
			| Boots      | '*'   | '*'      |'*'     | '*'         |
			| High shoes | '*'   | '*'      |'*'     | '*'         |
	И я проверяю сброс отборов
		И я нажимаю кнопку очистить у поля "Item type"
		И     таблица "ItemList" стала равной:
			| Title                | Unit  | In stock | Price  | Picked out |
			| Dress                | '*'   | '*'      |'*'     | '*'         |
			| Trousers             | '*'   | '*'      |'*'     | '*'         |
			| Shirt                | '*'   | '*'      |'*'     | '*'         |
			| Boots                | '*'   | '*'      |'*'     | '*'         |
			| High shoes           | '*'   | '*'      |'*'     | '*'         |
	И я проверяю отображение по товару item key в форме подбора
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И     таблица "ItemKeyList" стала равной:
			| Title     | Unit  | In stock | Price  | Picked out  |
			| S/Yellow  | '*'   | '*'      |'*'     | '*'         |
			| XS/Blue   | '*'   | '*'      |'*'     | '*'         |
			| M/White   | '*'   | '*'      |'*'     | '*'         |
			| L/Green   | '*'   | '*'      |'*'     | '*'         |
			| XL/Green  | '*'   | '*'      |'*'     | '*'         |
			| Dress/A-8 | '*'   | '*'      |'*'     | '*'         |
			| XXL/Red   | '*'   | '*'      |'*'     | '*'         |
			# | M/Brown   | '*'   | '*'      |'*'     | '*'         |
	И я проверяю добавление товара
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title    |
			| S/Yellow |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И     таблица "ItemTableValue" содержит строки:
			| 'Item'  | 'Quantity' | 'Item key' |
			| 'Dress' | '1,000'    | 'S/Yellow' |
	И я добавляю ещё одну строку и меняю по ней кол-во в таблице ItemTableValue
		Когда в таблице "ItemKeyList" я нажимаю на кнопку с именем 'ItemKeyListCommandBack'
		И в таблице "ItemList" я перехожу к строке:
			| 'Title'    |
			| 'Trousers' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'Title'     |
			| '38/Yellow' |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'     | 'Item key'  | 'Quantity' |
			| 'Trousers' | '38/Yellow' | '1,000'    |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '2,000'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И     таблица "ItemTableValue" стала равной:
			| 'Item'     | 'Quantity' | 'Item key'  |
			| 'Dress'    | '1,000'    | 'S/Yellow'  |
			| 'Trousers' | '2,000'    | '38/Yellow' |
	И я проверяю перенос подобранного товара в документ
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
		И Пауза 2
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'      | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'           | '*'            |
			| 'Trousers' | '*'      | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs' | '*'           | '*'            |
	И я добавляю ещё одну строку в заказ через кнопку Add
		И я нажимаю на кнопку с именем "Add"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shirt       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Item key"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
		И в таблице "List" я перехожу к строке:
			И в таблице "List" я перехожу к строке:
			| Item  | Item key |
			| Shirt | 36/Red   |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Q"
		И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
		И в таблице "ItemList" я завершаю редактирование строки
	* Checking the filling of the tabular part
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit'| 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'      | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
			| 'Trousers' | '*'      | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
			| 'Shirt'    | '*'      | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
	И я добавляю ещё одну строку через форму подбора товара
		И я нажимаю на кнопку с именем "OpenPickupItems"
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title   |
			| L/Green |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
		| 'Item'  | 'Item key' |
		| 'Dress' | 'L/Green' |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" я активизирую поле с именем "ItemTableValuePrice"
		И в таблице "ItemTableValue" в поле с именем 'ItemTableValuePrice' я ввожу текст '350,00'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И я нажимаю на кнопку с именем 'FormCommandSaveAndClose'
	И я проверяю табличную часть документа
		И     таблица "ItemList" стала равной:
			| 'Item'     | 'Price'       | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'           | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Trousers' | '*'           | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Shirt'    | '*'           | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Dress'    | '350,00'      | 'L/Green'   | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |

Сценарий: check the product selection form with price information in Purchase order
	# purchase order и purchase invoice, Basic Partner terms, TRY, Ferron
	И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
	# temporarily
	Затем Если появилось окно диалога я нажимаю на кнопку 'OK'
	# temporarily
	И я проверяю отбор по виду номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Сlothes     |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title               | Unit  | In stock | Price  | Picked out |
			| Dress               | '*'   | '*'     | '*'    | '*'         |
			| Trousers            | '*'   | '*'     | '*'    | '*'         |
			| Shirt               | '*'   | '*'     | '*'    | '*'         |
	И я проверяю обновление отбора при выборе другого вида номенклатуры
		И я нажимаю кнопку выбора у поля "Item type"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shoes       |
		И в таблице "List" я выбираю текущую строку
		И     таблица "ItemList" стала равной:
			| Title      | Unit  | In stock | Price  | Picked out |
			| Boots      | '*'   | '*'      |'*'     | '*'         |
			| High shoes | '*'   | '*'      |'*'     | '*'         |
	И я проверяю сброс отборов
		И я нажимаю кнопку очистить у поля "Item type"
		И     таблица "ItemList" стала равной:
			| Title                | Unit  | In stock | Price  | Picked out |
			| Dress                | '*'   | '*'      |'*'     | '*'         |
			| Trousers             | '*'   | '*'      |'*'     | '*'         |
			| Shirt                | '*'   | '*'      |'*'     | '*'         |
			| Boots                | '*'   | '*'      |'*'     | '*'         |
			| High shoes           | '*'   | '*'      |'*'     | '*'         |
	И я проверяю отображение по товару item key в форме подбора
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И     таблица "ItemKeyList" стала равной:
			| Title     | Unit  | In stock | Price  | Picked out  |
			| S/Yellow  | '*'   | '*'      |'*'     | '*'         |
			| XS/Blue   | '*'   | '*'      |'*'     | '*'         |
			| M/White   | '*'   | '*'      |'*'     | '*'         |
			| L/Green   | '*'   | '*'      |'*'     | '*'         |
			| XL/Green  | '*'   | '*'      |'*'     | '*'         |
			| Dress/A-8 | '*'   | '*'      |'*'     | '*'         |
			| XXL/Red   | '*'   | '*'      |'*'     | '*'         |
	И я проверяю добавление товара
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title    |
			| S/Yellow |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И     таблица "ItemTableValue" содержит строки:
			| 'Item'  | 'Quantity' | 'Item key' |
			| 'Dress' | '1,000'    | 'S/Yellow' |
	И я добавляю ещё одну строку и меняю по ней кол-во в таблице ItemTableValue
		Когда в таблице "ItemKeyList" я нажимаю на кнопку с именем 'ItemKeyListCommandBack'
		И в таблице "ItemList" я перехожу к строке:
			| 'Title'    |
			| 'Trousers' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'Title'     |
			| '38/Yellow' |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'     | 'Item key'  | 'Quantity' |
			| 'Trousers' | '38/Yellow' | '1,000'    |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '2,000'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И     таблица "ItemTableValue" стала равной:
			| 'Item'     | 'Quantity' | 'Item key'  |
			| 'Dress'    | '1,000'    | 'S/Yellow'  |
			| 'Trousers' | '2,000'    | '38/Yellow' |
	И я проверяю перенос подобранного товара в документ
		И я нажимаю на кнопку с именем "FormCommandSaveAndClose"
		И Пауза 2
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'      | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'           | '*'            |
			| 'Trousers' | '*'      | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs' | '*'           | '*'            |
	И я добавляю ещё одну строку в заказ через кнопку Add
		И я нажимаю на кнопку с именем "Add"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Shirt       |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Item key"
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
		И в таблице "List" я перехожу к строке:
			И в таблице "List" я перехожу к строке:
			| Item  | Item key |
			| Shirt | 36/Red   |
		И в таблице "List" я выбираю текущую строку
		И в таблице "ItemList" я активизирую поле "Q"
		И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
		И в таблице "ItemList" я завершаю редактирование строки
	* Checking the filling of the tabular part
		И     таблица "ItemList" содержит строки:
			| 'Item'     | 'Price'  | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit'| 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'      | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
			| 'Trousers' | '*'      | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
			| 'Shirt'    | '*'      | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs' | '*'          | '*'            |
	И я добавляю ещё одну строку через форму подбора товара
		И я нажимаю на кнопку с именем "ItemListOpenPickupItems"
		И в таблице "ItemList" я перехожу к строке:
			| Title |
			| Dress |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| Title   |
			| L/Green |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
		| 'Item'  | 'Item key' |
		| 'Dress' | 'L/Green' |
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" я активизирую поле с именем "ItemTableValuePrice"
		И в таблице "ItemTableValue" в поле с именем 'ItemTableValuePrice' я ввожу текст '350,00'
		И в таблице "ItemTableValue" я завершаю редактирование строки
		И я нажимаю на кнопку с именем "FormCommandSaveAndClose"
	И я проверяю табличную часть документа
		И     таблица "ItemList" стала равной:
			| 'Item'     | 'Price'       | 'Item key'  | 'Store'    | 'Q'     | 'Offers amount' | 'Tax amount' | 'Unit' | 'Net amount' | 'Total amount' |
			| 'Dress'    | '*'           | 'S/Yellow'  | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Trousers' | '*'           | '38/Yellow' | 'Store 01' | '2,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Shirt'    | '*'           | '36/Red'    | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |
			| 'Dress'    | '350,00'      | 'L/Green'   | 'Store 01' | '1,000' | '*'             | '*'          | 'pcs'  | '*'          | '*'            |


Сценарий: check the product selection form in StockAdjustmentAsWriteOff/StockAdjustmentAsSurplus
	И я нажимаю на кнопку 'Pickup'
	* Проверка вывода остатков по Item
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock'  | 'Unit' | 'Picked out' |
		| 'Dress'                | '331'       | 'pcs'  | ''           |
		| 'Trousers'             | ''          | 'pcs'  | ''           |
		| 'Shirt'                | '7'         | 'pcs'  | ''           |
		| 'Boots'                | '4'         | 'pcs'  | ''           |
		| 'High shoes'           | ''          | 'pcs'  | ''           |
		| 'Bound Dress+Shirt'    | ''          | 'pcs'  | ''           |
		| 'Bound Dress+Trousers' | ''          | 'pcs'  | ''           |
		| 'Router'               | ''          | 'pcs'  | ''           |
	* Проверка вывода остатков по Item key
		И в таблице "ItemList" я перехожу к строке:
		| 'In stock' | 'Title' |
		| '331'      | 'Dress' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'   | 'Unit' |
			| '197'      | 'XS/Blue' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'    | 'Unit' |
			| '124'      | 'S/Yellow' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'  | 'Item key' | 'Quantity' | 'Unit' |
			| 'Dress' | 'S/Yellow' | '1,000'    | 'pcs'  |
		И в таблице "ItemTableValue" я активизирую поле "Quantity"
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '4,000'
		И я нажимаю на кнопку 'Transfer to document'
	* Проверка переноса остатков в документ
		И     таблица "ItemList" содержит строки:
		| 'Item'  | 'Quantity' | 'Item key' | 'Unit' |
		| 'Dress' | '1,000'    | 'XS/Blue'  | 'pcs'  |
		| 'Dress' | '4,000'    | 'S/Yellow' | 'pcs'  |
	* Проверка изменения остатков при перевыборе склада
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Store 06'    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю на кнопку 'Pickup'
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock' | 'Unit' | 'Picked out' |
		| 'Dress'                | '398'      | 'pcs'  | ''           |
		| 'Trousers'             | '405'      | 'pcs'  | ''           |

Сценарий: check the product selection form in PhysicalInventory
	И я нажимаю на кнопку 'Pickup'
	* Проверка вывода остатков по Item
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock' | 'Unit' | 'Picked out' |
		| 'Dress'                | '331'      | 'pcs'  | ''           |
		| 'Trousers'             | ''         | 'pcs'  | ''           |
		| 'Shirt'                | '7'        | 'pcs'  | ''           |
		| 'Boots'                | '4'        | 'pcs'  | ''           |
		| 'High shoes'           | ''         | 'pcs'  | ''           |
		| 'Bound Dress+Shirt'    | ''         | 'pcs'  | ''           |
		| 'Bound Dress+Trousers' | ''         | 'pcs'  | ''           |
		| 'Router'               | ''         | 'pcs'  | ''           |
	* Проверка вывода остатков по Item key
		И в таблице "ItemList" я перехожу к строке:
			| 'In stock' | 'Title' |
			| '331'      | 'Dress' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'   | 'Unit' |
			| '197'      | 'XS/Blue' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'    | 'Unit' |
			| '124'      | 'S/Yellow' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'  | 'Item key' | 'Quantity' | 'Unit' |
			| 'Dress' | 'S/Yellow' | '1,000'    | 'pcs'  |
		И в таблице "ItemTableValue" я активизирую поле "Quantity"
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '4,000'
		И я нажимаю на кнопку 'Transfer to document'
	* Проверка переноса остатков в документ PhysicalInventory
		И     таблица "ItemList" содержит строки:
			| 'Phys. count' | 'Item'  | 'Difference' | 'Item key' | 'Unit' |
			| '4,000'       | 'Dress' | '4,000'      | 'S/Yellow' | 'pcs'  |
			| '1,000'       | 'Dress' | '1,000'      | 'XS/Blue'  | 'pcs'  |
	* Проверка изменения остатков при перевыборе склада
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Store 06'    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю на кнопку 'Pickup'
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock' | 'Unit' | 'Picked out' |
		| 'Dress'                | '398'      | 'pcs'  | ''           |
		| 'Trousers'             | '405'      | 'pcs'  | ''           |

Сценарий: check the product selection form in InventoryTransferOrder/InventoryTransfer
	И я нажимаю на кнопку 'Pickup'
	* Проверка вывода остатков по Item
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock'  | 'Unit' | 'In stock receiver' | 'Picked out' |
		| 'Dress'                | '331'       | 'pcs'  | '398'               | ''           |
		| 'Trousers'             | ''          | 'pcs'  | '405'               | ''           |
		| 'Shirt'                | '7'         | 'pcs'  | ''                  | ''           |
		| 'Boots'                | '4'         | 'pcs'  | ''                  | ''           |
	* Проверка вывода остатков по Item key
		И в таблице "ItemList" я перехожу к строке:
			| 'In stock' | 'Title' |
			| '331'      | 'Dress' |
		И в таблице "ItemList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'   | 'Unit' |
			| '197'      | 'XS/Blue' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemKeyList" я перехожу к строке:
			| 'In stock' | 'Title'    | 'Unit' |
			| '124'      | 'S/Yellow' | 'pcs'  |
		И в таблице "ItemKeyList" я выбираю текущую строку
		И в таблице "ItemTableValue" я перехожу к строке:
			| 'Item'  | 'Item key' | 'Quantity' | 'Unit' |
			| 'Dress' | 'S/Yellow' | '1,000'    | 'pcs'  |
		И в таблице "ItemTableValue" я активизирую поле "Quantity"
		И в таблице "ItemTableValue" я выбираю текущую строку
		И в таблице "ItemTableValue" в поле 'Quantity' я ввожу текст '4,000'
		И я нажимаю на кнопку 'Transfer to document'
	* Проверка переноса остатков в документ PhysicalInventory
		И     таблица "ItemList" содержит строки:
			| 'Quantity'    | 'Item'  | 'Item key' | 'Unit' |
			| '4,000'       | 'Dress' | 'S/Yellow' | 'pcs'  |
			| '1,000'       | 'Dress' | 'XS/Blue'  | 'pcs'  |
	* Проверка изменения остатков при перевыборе склада
		И я нажимаю кнопку выбора у поля "Store sender"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Store 06'    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Store receiver"
		И в таблице "List" я перехожу к строке:
			| 'Description' |
			| 'Store 05'    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю на кнопку 'Pickup'
		И     таблица "ItemList" содержит строки:
		| 'Title'                | 'In stock' | 'Unit' | 'In stock receiver' | 'Picked out' |
		| 'Dress'                | '398'      | 'pcs'  | '331'               | ''           |
		| 'Trousers'             | '405'      | 'pcs'  | ''                  | ''           |








# EndPick up

# SwitchBox/Item

# Сценарий: проверяю работу переключателя Box/Item
# 	И я меняю значение переключателя с именем 'InputType' на 'Item'
# 	И я нажимаю на кнопку с именем 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	Тогда таблица "List" не содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я перехожу к строке:
# 		| Description |
# 		| Trousers    |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item     | Item key  |
# 		| Trousers | 38/Yellow |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И я меняю значение переключателя с именем 'InputType' на 'Box'
# 	И я нажимаю на кнопку с именем 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	И я запоминаю количество строк таблицы "List" как "QS"
# 	Тогда переменная "QS" имеет значение 1
# 	Тогда таблица "List" содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item      | Item key           |
# 		| Paper box | 101/12150001908091 |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Q' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки

# Сценарий: проверяю работу переключателя Box/Item в складских документах
# 	И я меняю значение переключателя с именем 'InputType' на 'Item'
# 	И я нажимаю на кнопку 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	Тогда таблица "List" не содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я перехожу к строке:
# 		| Description |
# 		| Trousers    |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item     | Item key  |
# 		| Trousers | 38/Yellow |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Quantity' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И я меняю значение переключателя с именем 'InputType' на 'Box'
# 	И я нажимаю на кнопку 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	И я запоминаю количество строк таблицы "List" как "QS"
# 	Тогда переменная "QS" имеет значение 1
# 	Тогда таблица "List" содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item      | Item key           |
# 		| Paper box | 101/12150001908091 |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Quantity' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки

# Сценарий: проверяю работу переключателя Box/Item в PhysicalInventory
# 	И я меняю значение переключателя с именем 'InputType' на 'Item'
# 	И я нажимаю на кнопку 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	Тогда таблица "List" не содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я перехожу к строке:
# 		| Description |
# 		| Trousers    |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item     | Item key  |
# 		| Trousers | 38/Yellow |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Phys. count' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки
# 	И я меняю значение переключателя с именем 'InputType' на 'Box'
# 	И я нажимаю на кнопку 'Add'
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
# 	И я запоминаю количество строк таблицы "List" как "QS"
# 	Тогда переменная "QS" имеет значение 1
# 	Тогда таблица "List" содержит строки:
# 		| Description |
# 		| Paper box   |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item key"
# 	И в таблице "List" я перехожу к строке:
# 		| Item      | Item key           |
# 		| Paper box | 101/12150001908091 |
# 	И в таблице "List" я выбираю текущую строку
# 	И в таблице "ItemList" в поле 'Phys. count' я ввожу текст '1,000'
# 	И в таблице "ItemList" я завершаю редактирование строки



# EndSwitchBox/Item



# Filters

Сценарий: check the filter by Legal name
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Kalipso     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		Тогда таблица "List" стала равной:
			| Description     |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		И     элемент формы с именем "Partner" стал равен 'Kalipso'
		И     элемент формы с именем "LegalName" стал равен 'Company Kalipso'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Legal name' я ввожу текст 'Company Ferron BP'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Ferron BP |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "LegalName" стал равен 'Company Ferron BP''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Legal name (Ferron)
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		Тогда таблица "List" стала равной:
			| 'Description'              |
			| 'Company Ferron BP'        |
			| 'Second Company Ferron BP' |
		И я нажимаю на кнопку с именем 'FormChoose'
		И     элемент формы с именем "Partner" стал равен 'Ferron BP'
		И     элемент формы с именем "LegalName" стал равен 'Company Ferron BP'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Legal name' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "LegalName" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Legal name (Ferron) in Goods receipt and Shipment confirmation
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		Тогда таблица "List" стала равной:
			| 'Description'              |
			| 'Company Ferron BP'        |
			| 'Second Company Ferron BP' |
		И я нажимаю на кнопку с именем 'FormChoose'
		И     элемент формы с именем "Partner" стал равен 'Ferron BP'
		И     элемент формы с именем "LegalName" стал равен 'Company Ferron BP'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Legal name' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "LegalName" стал равен 'Company Kalipso''|
	И я проверяю автоматическое заполнение Legal name if the partner has only one
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			|  DFC     |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "LegalName" стал равен 'DFC'
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Company
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Kalipso     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Company  in the inventory transfer
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Store Sender"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Company  in the Shipment cinfirmation and Goods receipt
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Store"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
		И я закрыл все окна клиентского приложения

Сценарий: check the filter by Company (Ferron)
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения


Сценарий: check the filter by my own company
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by my own company in Cash expence/Cash revenue
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Account"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by my own company in Reconcilation statement
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Legal name"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by my own company in Cheque bond transaction
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Company' я ввожу текст 'Company Kalipso'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Currency"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Company Kalipso |
		И я нажимаю на кнопку с именем 'FormChoose'
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Company" стал равен 'Company Kalipso''|
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by my own company in Opening entry
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Company"
		Тогда таблица "List" стала равной:
			| 'Description'    |
			| 'Main Company'   |
			| 'Second Company' |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Company" стал равен 'Main Company'
	И я закрыл все окна клиентского приложения

Сценарий: check the filter by Partner term (by segments + expiration date)
	И я нажимаю на кнопку с именем 'FormCreate'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Kalipso     |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		И я нажимаю на кнопку с именем 'FormChoose'
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Partner term"
		Тогда таблица "List" стала равной:
			| 'Description'                   |
			| 'Basic Partner terms, TRY'         |
			| 'Basic Partner terms, without VAT' |
			| 'Personal Partner terms, $'        |
		И в таблице "List" я активизирую поле "Description"
		И в таблице "List" я перехожу к строке:
			| Description            |
			| Personal Partner terms, $ |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Agreement" стал равен 'Personal Partner terms, $'
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Partner term' я ввожу текст 'Sale autum, TRY'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Sale autum, TRY |
		И в таблице "List" я перехожу к строке:
			| Description            |
			| Personal Partner terms, $ |
		И в таблице "List" я выбираю текущую строку
		Когда Проверяю шаги на Исключение:
			|'И     элемент формы с именем "Agreement" стал равен 'Sale autum, TRY''|
	И я закрыл все окна клиентского приложения


Сценарий: check the filter by customers in the sales documents
# должны отображаться только партнеры у которых проставлена галочка Customer
И я проверяю визуальный фильтр
	И я нажимаю кнопку выбора у поля "Partner"
	И я запоминаю количество строк таблицы "List" как "QS"
	Тогда переменная "QS" имеет значение 14
	Тогда таблица "List" содержит строки:
		| Description  |
		| Ferron BP    |
		| Kalipso      |
		| Manager B    |
		| Lomaniti     |
		| Anna Petrova |
		| Alians       |
		| MIO          |
		| Seven Brand  |
	И в таблице "List" я выбираю текущую строку
И я проверяю фильтр при вводе по строке
	И Пауза 2
	И в поле 'Partner' я ввожу текст 'Alexander Orlov'
	И Пауза 2
	И я нажимаю кнопку выбора у поля "Partner term"
	Тогда таблица "List" не содержит строки:
			| Description  |
			| Alexander Orlov |
	И в таблице "List" я выбираю текущую строку
	Когда Проверяю шаги на Исключение:
		|'И     элемент формы с именем "Partner" стал равен 'Alexander Orlov''|
И я закрыл все окна клиентского приложения

Сценарий: check the filter by vendors in the purchase documents
И я проверяю визуальный фильтр
	И я нажимаю кнопку выбора у поля "Partner"
	И я запоминаю количество строк таблицы "List" как "QS"
	Тогда переменная "QS" имеет значение 8
	Тогда таблица "List" содержит строки:
		| 'Description'      |
		| 'Ferron BP'        |
		| 'DFC'              |
		| 'Big foot'         |
		| 'Nicoletta' |
		| 'Veritas' |
		| 'Partner Kalipso'  |
	И в таблице "List" я выбираю текущую строку
И я проверяю фильтр при вводе по строке
	И Пауза 2
	И в поле 'Partner' я ввожу текст 'Kalipso'
	И Пауза 2
	И я нажимаю кнопку выбора у поля "Partner term"
	Тогда таблица "List" не содержит строки:
			| Description  |
			| Kalipso |
	И в таблице "List" я выбираю текущую строку
	Когда Проверяю шаги на Исключение:
		|'И     элемент формы с именем "Partner" стал равен 'Kalipso''|
И я закрыл все окна клиентского приложения

Сценарий: check the filter by customer partner terms in the sales documents
	# И Я устанавливаю ссылку 'https://bilist.atlassian.net/browse/IRP-349' с именем 'IRP-349'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP   |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Company Ferron BP |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Partner term"
		И таблица  "List" не содержит строки:
			| Description        |
			| Vendor Ferron, TRY |
			| Vendor Ferron, USD |
			| Vendor Ferron, EUR |
	И в таблице "List" я выбираю текущую строку
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Partner term' я ввожу текст 'Vendor Ferron, TRY'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Vendor Ferron, TRY |
		И в таблице "List" я выбираю текущую строку
		Когда Проверяю шаги на Исключение:
		|'И     элемент формы с именем "Agreement" стал равен 'Vendor Ferron, TRY''|
	И Я закрыл все окна клиентского приложения
	
Сценарий: check the filter by vendor partner terms in the purchase documents
	# И Я устанавливаю ссылку 'https://bilist.atlassian.net/browse/IRP-349' с именем 'IRP-349'
	И я проверяю визуальный фильтр
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP   |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Legal name"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Company Ferron BP |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Partner term"
		И таблица  "List" содержит строки:
			| Description        |
			| Vendor Ferron, TRY |
			| Vendor Ferron, USD |
			| Vendor Ferron, EUR |
		И я запоминаю количество строк таблицы "List" как "QS"
		Тогда переменная "QS" имеет значение 3
	И в таблице "List" я выбираю текущую строку
	И я проверяю фильтр при вводе по строке
		И Пауза 2
		И в поле 'Partner term' я ввожу текст 'Basic Partner terms, TRY'
		И Пауза 2
		И я нажимаю кнопку выбора у поля "Partner"
		Тогда таблица "List" не содержит строки:
			| Description  |
			| Basic Partner terms, TRY |
		И в таблице "List" я выбираю текущую строку
		Когда Проверяю шаги на Исключение:
		|'И     элемент формы с именем "Agreement" стал равен 'Basic Partner terms, TRY''|
	И Я закрыл все окна клиентского приложения

Сценарий: check Description
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю на гиперссылку "Description"
	И в поле 'Text' я ввожу текст 'Test description'
	И я нажимаю на кнопку 'OK'
	И     элемент формы с именем "Description" стал равен 'Test description'
	И я закрыл все окна клиентского приложения

# Сollapsible group

Сценарий: check the display of the header of the collapsible group in sales, purchase and return documents
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Partner" доступен для редактирования Тогда
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Ferron BP   |
		И в таблице "List" я выбираю текущую строку
		Если элемент "Legal name" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Legal name"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Company Ferron BP |
		И в таблице "List" я выбираю текущую строку
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
				| Description  |
				| Main Company |
		И в таблице "List" я выбираю текущую строку


Сценарий: check the display of the header of the collapsible group in expence/revenue documents
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" доступен для редактирования Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Main Company   |
		И в таблице "List" я выбираю текущую строку
		Если элемент "Accoun" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Account"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Bank account, TRY |
		И в таблице "List" я выбираю текущую строку


Сценарий: check the display of the header of the collapsible group in PhysicalCountByLocation
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 01   |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Responsible person"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Anna Petrova |
		И в таблице "List" я выбираю текущую строку

Сценарий: check the display of the header of the collapsible group in PhysicalInventory
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 01   |
		И в таблице "List" я выбираю текущую строку
	

Сценарий: check the display of the header of the collapsible group in OpeningEntry
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
				| Description  |
				| Main Company |
		И в таблице "List" я выбираю текущую строку


Сценарий: check the display of the header of the collapsible group in inventory transfer
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
				| Description  |
				| Main Company |
		И в таблице "List" я выбираю текущую строку
		Если элемент "Store sender" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Store sender"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 02    |
		И в таблице "List" я выбираю текущую строку
		Если элемент "Store receiver" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Store receiver"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 03    |
		И в таблице "List" я выбираю текущую строку

Сценарий: check the display of the header of the collapsible group in Shipment confirmation, Goods receipt, Bundling/Unbundling
	И я нажимаю на кнопку с именем 'FormCreate'
	Если элемент "Company" присутствует на форме Тогда
	И я нажимаю кнопку выбора у поля "Company"
	И в таблице "List" я перехожу к строке:
		| Description  |
		| Main Company |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю кнопку выбора у поля с именем "Store"
	И в таблице "List" я перехожу к строке:
		| Description |
		| Store 03    |
	И в таблице "List" я выбираю текущую строку

Сценарий: check the display of the header of the collapsible group in bank payments documents
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Account"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Bank account, USD |
		И в таблице "List" я выбираю текущую строку

Сценарий: check the display of the header of the collapsible group in cash receipt document
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля с именем "Currency"
		И в таблице "List" я перехожу к строке:
			| Code | Description     |
			| USD  | American dollar |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Cash account"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Cash desk №2 |
		И в таблице "List" я выбираю текущую строку
		И из выпадающего списка "Transaction type" я выбираю точное значение 'Payment from customer'

Сценарий: check the display of the header of the collapsible group in cash payment document
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля с именем "Currency"
		И в таблице "List" я перехожу к строке:
			| Code | Description     |
			| USD  | American dollar |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Cash account"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Cash desk №2 |
		И в таблице "List" я выбираю текущую строку
		И из выпадающего списка "Transaction type" я выбираю точное значение 'Payment to the vendor'




Сценарий: check the display of the header of the collapsible group in invoice match
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И из выпадающего списка "Operation type" я выбираю точное значение 'With customer'
		И я активизирую поле "Partner ar transactions basis document"
		И в таблице "" я перехожу к строке:
			| 'Column1'            |
			| Sales invoice |
		И в таблице "" я выбираю текущую строку
		И в таблице "List" я перехожу к строке:
			| Number |
			| 1    |
		И в таблице "List" я выбираю текущую строку

Сценарий: check the display of the header of the collapsible group in planned incoming/outgoing documents
	И я нажимаю на кнопку с именем 'FormCreate'
	* Filling in the details of the document
		Если элемент "Company" присутствует на форме Тогда
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Account"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Cash desk №2 |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля с именем "Currency"
		И в таблице "List" я перехожу к строке:
			| Code | Description  |
			| TRY  | Turkish lira |
		И в таблице "List" я выбираю текущую строку

Сценарий: create a test partner with one vendor partner term and one customer partner term
	И я создаю Partner Kalipso
		И я открываю навигационную ссылку 'e1cib/list/Catalog.Partners'
		И я нажимаю на кнопку с именем 'FormCreate'
		И в поле 'ENG' я ввожу текст 'Partner Kalipso'
		И я нажимаю кнопку выбора у поля "Main partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Kalipso   |
		И в таблице "List" я выбираю текущую строку
		И я устанавливаю флаг 'Customer'
		И я устанавливаю флаг 'Vendor'
		И я нажимаю на кнопку 'Save'
	И я добавляю соглашение с клиентом
		И В текущем окне я нажимаю кнопку командного интерфейса 'Partner terms'
		И я нажимаю на кнопку с именем 'FormCreate'
		И в поле 'ENG' я ввожу текст 'Partner Kalipso Customer'
		И я меняю значение переключателя 'Type' на 'Customer'
		И в поле 'Number' я ввожу текст '#1001'
		И в поле 'Date' я ввожу текст '28.08.2019'
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Multi currency movement type"
		И в таблице "List" я перехожу к строке:
			| 'Currency' | 'Type'      |
			| 'TRY'      | 'Partner term' |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Price type"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Basic Price Types |
		И в таблице "List" я выбираю текущую строку
		И в поле 'Start using' я ввожу текст '28.08.2019'
		И я устанавливаю флаг 'Price include tax'
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 02    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю на кнопку 'Save and close'
		И я жду закрытия окна 'Partner term (create) *' в течение 20 секунд
	И я добавляю соглашение с поставщиком
		И В текущем окне я нажимаю кнопку командного интерфейса 'Partner terms'
		И я нажимаю на кнопку с именем 'FormCreate'
		И в поле 'ENG' я ввожу текст 'Partner Kalipso Vendor'
		И я меняю значение переключателя 'Type' на 'Vendor'
		И в поле 'Number' я ввожу текст '#1001'
		И в поле 'Date' я ввожу текст '28.08.2019'
		И я нажимаю кнопку выбора у поля "Company"
		И в таблице "List" я перехожу к строке:
			| Description  |
			| Main Company |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Multi currency movement type"
		И в таблице "List" я перехожу к строке:
			| 'Currency' | 'Type'      |
			| 'TRY'      | 'Partner term' |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю кнопку выбора у поля "Price type"
		И в таблице "List" я перехожу к строке:
			| Description       |
			| Vendor price, TRY |
		И в таблице "List" я выбираю текущую строку
		И в поле 'Start using' я ввожу текст '28.08.2019'
		И я устанавливаю флаг 'Price include tax'
		И я нажимаю кнопку выбора у поля "Store"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Store 02    |
		И в таблице "List" я выбираю текущую строку
		И я нажимаю на кнопку 'Save and close'
		И я жду закрытия окна 'Partner term (create) *' в течение 20 секунд
	И Я закрыл все окна клиентского приложения

Сценарий: check the autocompletion of the partner term (by vendor) in the documents of purchase/returns 
	# И Я устанавливаю ссылку 'https://bilist.atlassian.net/browse/IRP-495' с именем 'IRP-495'
	И я проверяю автозаполнение соглашения, контрагента, компании
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Partner Kalipso   |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Partner" стал равен 'Partner Kalipso'
		И     элемент формы с именем "LegalName" стал равен 'Company Kalipso'
		И     элемент формы с именем "Agreement" стал равен 'Partner Kalipso Vendor'
		И     элемент формы с именем "Company" стал равен 'Main Company'


Сценарий: check the autocompletion of the partner term (by customer) in the documents of sales/returns 
	# И Я устанавливаю ссылку 'https://bilist.atlassian.net/browse/IRP-495' с именем 'IRP-495'
	И я проверяю автозаполнение соглашения, контрагента, компании
		И я нажимаю кнопку выбора у поля "Partner"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Partner Kalipso   |
		И в таблице "List" я выбираю текущую строку
		И     элемент формы с именем "Partner" стал равен 'Partner Kalipso'
		И     элемент формы с именем "LegalName" стал равен 'Company Kalipso'
		И     элемент формы с именем "Agreement" стал равен 'Partner Kalipso Customer'
		И     элемент формы с именем "Company" стал равен 'Main Company'

Сценарий: create test item with one item key
	И я открываю навигационную ссылку 'e1cib/list/Catalog.Items'
	И я нажимаю на кнопку с именем 'FormCreate'
	И в поле 'ENG' я ввожу текст 'Scarf'
	И я нажимаю кнопку выбора у поля "Item type"
	И в таблице "List" я перехожу к строке:
		| Description |
		| Сlothes     |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю кнопку выбора у поля "Unit"
	И в таблице "List" я перехожу к строке:
		| Description |
		| pcs         |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю на кнопку 'Save'
	И В текущем окне я нажимаю кнопку командного интерфейса 'Item keys'
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю кнопку выбора у поля "Size"
	И в таблице "List" я перехожу к строке:
		| Additional attribute | Description |
		| Size          | XS          |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю кнопку выбора у поля "Color"
	И в таблице "List" я перехожу к строке:
		| Additional attribute | Description |
		| Color         | Red         |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю на кнопку 'Save and close'
	И В текущем окне я нажимаю кнопку командного интерфейса 'Main'
	И я нажимаю на кнопку 'Save and close'



Сценарий: check item key autofilling in sales/returns documents for an item that has only one item key
	И в таблице товаров я выбираю Item Scarf
		И в таблице "ItemList" я нажимаю на кнопку с именем 'ItemListAdd'
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Scarf       |
		И в таблице "List" я выбираю текущую строку
	И я проверяю заполнение item key
		И     таблица "ItemList" содержит строки:
			| Item  |Item key | Unit |
			| Scarf |XS/Red   | pcs  |
	И Я закрыл все окна клиентского приложения


Сценарий: check item key autofilling in purchase/returns/goods receipt/shipment confirmation documents for an item that has only one item key
	И в таблице товаров я выбираю Item Scarf
		И я нажимаю на кнопку 'Add'
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Scarf       |
		И в таблице "List" я выбираю текущую строку
	И я проверяю заполнение item key
		И     таблица "ItemList" содержит строки:
			| Item  |Item key | Unit |
			| Scarf |XS/Red   | pcs  |
	И Я закрыл все окна клиентского приложения

Сценарий: check item key autofilling in bundling/transfer documents for an item that has only one item key
	И я перехожу к закладке "Item list"
	И в таблице товаров я выбираю Item Scarf
		И я нажимаю на кнопку 'Add'
		И в таблице "ItemList" я нажимаю кнопку выбора у реквизита "Item"
		И в таблице "List" я перехожу к строке:
			| Description |
			| Scarf       |
		И в таблице "List" я выбираю текущую строку
	И я проверяю заполнение item key
		И     таблица "ItemList" содержит строки:
			| Item  |Item key | Unit |
			| Scarf |XS/Red   | pcs  |
	И Я закрыл все окна клиентского приложения

Сценарий: check the barcode search in the sales documents + price and tax filling in
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю кнопку выбора у поля "Partner"
	И в таблице "List" я перехожу к строке:
		| Description |
		| Partner Kalipso     |
	И в таблице "List" я выбираю текущую строку
	И в таблице "ItemList" я нажимаю на кнопку 'SearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283705'
	И я нажимаю на кнопку 'OK'
	И я проверяю добавление товара и заполнение цены в табличной части
		И     таблица "ItemList" содержит строки:
			| 'Item'  | 'Price'  | 'Item key' |'Q'     | 'Unit' | 'Total amount' |
			|'Dress TR' |'700,00' | 'XS/Blue TR'  |'1,000' | 'adet'  | '700,00'       |
	И Я закрыл все окна клиентского приложения

Сценарий: check the barcode search on the return documents
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю кнопку выбора у поля "Partner"
	И в таблице "List" я перехожу к строке:
		| Description |
		| Partner Kalipso     |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю на кнопку 'SearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283705'
	И я нажимаю на кнопку 'OK'
	И я проверяю добавление товара
		И     таблица "ItemList" содержит строки:
			| 'Item'  | 'Item key' |'Q'     | 'Unit' |
			|'Dress TR' | 'XS/Blue TR' |'1,000' | 'adet'  |
	И Я закрыл все окна клиентского приложения


Сценарий: check the barcode search in the purchase/purchase returns
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю кнопку выбора у поля "Partner"
	И в таблице "List" я перехожу к строке:
		| Description |
		| Partner Kalipso     |
	И в таблице "List" я выбираю текущую строку
	И я нажимаю на кнопку с именем 'ItemListSearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283713'
	И я нажимаю на кнопку 'OK'
	И я проверяю добавление товара и заполнение цены в табличной части
		И     таблица "ItemList" содержит строки:
			| 'Item'  |'Item key' |'Q'     | 'Unit' |
			|'Dress TR' |'S/Yellow TR'  |'1,000' | 'adet'  |
	И Я закрыл все окна клиентского приложения

Сценарий: check the barcode search in storage operations documents	
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю на кнопку 'SearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283713'
	И я нажимаю на кнопку 'OK'
	И я проверяю добавление товара и заполнение цены в табличной части
		И     таблица "ItemList" содержит строки:
			| 'Item'    |'Item key'     | 'Unit' |
			|'Dress TR' |'S/Yellow TR'  | 'adet'  |
	И Я закрыл все окна клиентского приложения


Сценарий: check the barcode search in the product bundling documents
	И я нажимаю на кнопку с именем 'FormCreate'
	И я перехожу к закладке "Item list"
	И в таблице "ItemList" я нажимаю на кнопку 'SearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283713'
	И я нажимаю на кнопку 'OK'
	И я проверяю добавление товара и заполнение цены в табличной части
		И     таблица "ItemList" содержит строки:
			| 'Item'  |'Item key' |'Quantity'     | 'Unit' |
			|'Dress TR' |'S/Yellow TR'  |'1,000' | 'adet'  |
	И Я закрыл все окна клиентского приложения

Сценарий: check the barcode search in the PhysicalInventory documents
	И я нажимаю на кнопку с именем 'FormCreate'
	И я нажимаю на кнопку 'SearchByBarcode'
	И в поле 'InputFld' я ввожу текст '2202283713'
	И я нажимаю на кнопку 'OK'
	И я проверяю Adding items to табличной части
		И     таблица "ItemList" содержит строки:
			| 'Item'    |'Item key'     | 'Unit' |
			|'Dress TR' |'S/Yellow TR'  | 'adet'  |
	И Я закрыл все окна клиентского приложения