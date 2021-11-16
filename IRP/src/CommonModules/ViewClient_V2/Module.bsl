
#Region CACHE_BEFORE_CHANGE

Function GetSimpleParameters(Object, Form, TableName, Rows = Undefined)
	FormParameters   = GetFormParameters(Form);
	ServerParameters = GetServerParameters(Object);
	ServerParameters.TableName = TableName;
	ServerParameters.Rows      = Rows;
	Return GetParameters(ServerParameters, FormParameters);
EndFunction

Function GetFormParameters(Form)
	FormParameters   = ControllerClientServer_V2.GetFormParameters(Form);
	FormParameters.PropertyBeforeChange.Object.Names = GetObjectPropertyNamesBeforeChange();
	FormParameters.PropertyBeforeChange.Form.Names   = GetFormPropertyNamesBeforeChange();
	FormParameters.PropertyBeforeChange.List.Names   = GetListPropertyNamesBeforeChange();
	Return FormParameters;
EndFunction

Function GetServerParameters(Object)
	Return ControllerClientServer_V2.GetServerParameters(Object);
EndFunction

Function GetParameters(ServerParameters, FormParameters = Undefined)
	Return ControllerClientServer_V2.GetParameters(ServerParameters, FormParameters);
EndFunction

Procedure ExtractValueBeforeChange_Object(DataPath, FormParameters)
	FormParameters.PropertyBeforeChange.Object.DataPath = DataPath;
	ExtractValueBeforeChange(FormParameters, Undefined);
EndProcedure

Procedure ExtractValueBeforeChange_Form(DataPath, FormParameters)
	FormParameters.PropertyBeforeChange.Form.DataPath = DataPath;
	ExtractValueBeforeChange(FormParameters, Undefined);
EndProcedure

Procedure ExtractValueBeforeChange_List(DataPath, FormParameters, Rows)
	FormParameters.PropertyBeforeChange.List.DataPath = DataPath;
	ExtractValueBeforeChange(FormParameters, Rows);
EndProcedure

Procedure ExtractValueBeforeChange(FormParameters, Rows)

	If ValueIsFilled(FormParameters.PropertyBeforeChange.Object.DataPath) 
		Or ValueIsFilled(FormParameters.PropertyBeforeChange.Form.DataPath)
		Or ValueIsFilled(FormParameters.PropertyBeforeChange.List.DataPath) Then
		
		CacheBeforeChange = CommonFunctionsServer.DeserializeXMLUseXDTO(FormParameters.Form.CacheBeforeChange);
		
		If ValueIsFilled(FormParameters.PropertyBeforeChange.Object.DataPath) Then
			FormParameters.PropertyBeforeChange.Object.Value = 
				GetCacheBeforeChange(CacheBeforeChange.CacheObject, FormParameters.PropertyBeforeChange.Object.DataPath);
		EndIf;
		If ValueIsFilled(FormParameters.PropertyBeforeChange.Form.DataPath) Then
			FormParameters.PropertyBeforeChange.Form.Value = 
				GetCacheBeforeChange(CacheBeforeChange.CacheForm, FormParameters.PropertyBeforeChange.Form.DataPath);
		EndIf;
		If ValueIsFilled(FormParameters.PropertyBeforeChange.List.DataPath) Then
			If Rows = Undefined Then
				Raise "PropertyBeforeChange.List.DataPath is set but rows is Undefined";
			EndIf;
			FormParameters.PropertyBeforeChange.List.Value = 
				GetCacheBeforeChange(CacheBeforeChange.CacheList, FormParameters.PropertyBeforeChange.List.DataPath, Rows);
		EndIf;
	EndIf;
EndProcedure

Function GetCacheBeforeChange(Cache, DataPath, Rows = Undefined)
	Segments = StrSplit(DataPath, ".");
	If Segments.Count() = 2 Then
		If Rows = Undefined Then
			Raise StrTemplate("Error read data from cache by data path [%1] rows is Udefined", DataPath);
		EndIf;
		TableName  = Segments[0];
		ColumnName = Segments[1];
		ArrayOfValuesBeforeChange = New Array();
		For Each Row In Rows Do
			For Each CacheRow In Cache[TableName] Do
				If Row.Key = CacheRow.Key Then
					NewRow = New Structure("Key", Row.Key);
					NewRow.Insert(ColumnName, CacheRow[ColumnName]);
					ArrayOfValuesBeforeChange.Add(NewRow);
					Break;
				EndIf;
			EndDo;
		EndDo;
		Result = New Structure();
		Result.Insert("DataPath"   , DataPath);
		Result.Insert("TableName"  , TableName);
		Result.Insert("ColumnName" , ColumnName);
		Result.Insert("ArrayOfValuesBeforeChange", ArrayOfValuesBeforeChange);
		Return Result;
	ElsIf Segments.Count() = 1 Then
		If Not Cache.Property(DataPath) Then
			Raise StrTemplate("Property by DataPath [%1] not found in CacheBeforeChange", DataPath);
		EndIf;
		// значение которое было в реквизите до того как он был изменен
		ValueBeforeChange = Cache[DataPath];
		Return New Structure("DataPath, ValueBeforeChange", DataPath, ValueBeforeChange);
	Else
		Raise StrTemplate("Wrong property data path [%1]", DataPath);
	EndIf;
EndFunction

// хранит значения реквизитов до изменения
Procedure UpdateCacheBeforeChange(Object, Form)
	// реквизиты Object которые нужно кэшировать
	CacheObject = New Structure(GetObjectPropertyNamesBeforeChange());
	FillPropertyValues(CacheObject, Object);
	
	// реквизиты Form которые нужно кэшировать
	CacheForm = New Structure(GetFormPropertyNamesBeforeChange());
	FillPropertyValues(CacheForm, Form);
	
	// реквизиты таблиц которые нужно кэшировать
	CacheList = New Structure();
	Tables    = New Structure();
	ListProperties = StrSplit(GetListPropertyNamesBeforeChange(), ",");
	For Each ListProperty In ListProperties Do
		Segments = StrSplit(ListProperty, ".");
		If Segments.Count() <> 2 Then
			Raise StrTemplate("Wrong list property [%1]", ListProperty);
		EndIf;
		TableName  = TrimAll(Segments[0]);
		ColumnName = TrimAll(Segments[1]);
		
		If Not CommonFunctionsClientServer.ObjectHasProperty(Object, TableName) Then
			Continue;
		EndIf;
		
		If Not Tables.Property(TableName) Then
			Tables.Insert(TableName, New Array());
		EndIf;
		If Tables[TableName].Find(ColumnName) = Undefined Then
			Tables[TableName].Add(ColumnName);
		EndIf;
	EndDo;
	
	For Each KeyValue In Tables Do
		TableName   = KeyValue.Key;
		ColumnNames = KeyValue.Value;
		
		CacheList.Insert(TableName, New Array());
		For Each Row In Object[TableName] Do
			NewRow = New Structure(StrConcat(ColumnNames, ","));
			NewRow.Insert("Key");
			FillPropertyValues(NewRow, Row);
			CacheList[TableName].Add(NewRow);
		EndDo;
	EndDo;
	
	CacheBeforeChange = New Structure();
	CacheBeforeChange.Insert("CacheObject", CacheObject);
	CacheBeforeChange.Insert("CacheForm"  , CacheForm);
	CacheBeforeChange.Insert("CacheList"  , CacheLIst);
	Form.CacheBeforeChange = CommonFunctionsServer.SerializeXMLUseXDTO(CacheBeforeChange);
EndProcedure

// возвращает список реквизитов объекта для которых нужно получить значение до изменения
Function GetObjectPropertyNamesBeforeChange()
	Return "Partner, Agreement, Sender, Receiver";
EndFunction

Function GetListPropertyNamesBeforeChange()
	Return "ItemList.Store, ItemList.DeliveryDate";
EndFunction

// возвращает список реквизитов формы для которых нужно получить значение до изменения
Function GetFormPropertyNamesBeforeChange()
	Return "Store, DeliveryDate";
EndFunction

#EndRegion

Function GetRowsByCurrentData(Form, TableName, CurrentData)
	Rows = New Array();
	If CurrentData = Undefined Then
		CurrentData = Form.Items[TableName].CurrentData;
	EndIf;
	If CurrentData <> Undefined Then
		Rows.Add(CurrentData);
	EndIf;
	Return Rows;
EndFunction

#Region ON_CHAIN_COMPLETE

Procedure OnChainComplete(Parameters) Export
	CommitChanges = False;
	
	// временно для SalesInvoice отдельно
	If Parameters.ObjectMetadataInfo.MetadataName = "SalesInvoice" Then
		__tmp_OnChainComplite(Parameters);
		Return;
	EndIf;
	
	// изменение склада (реквизит шапки) в шапке документа
	If Parameters.EventCaller = "StoreOnUserChange" Then
		If Parameters.ObjectMetadataInfo.MetadataName = "ShipmentConfirmation" Then
			If  NeedQueryStoreOnUserChange(Parameters) Then
				// Вопрос про изменение склада в табличной части
				NotifyParameters = New Structure("Parameters", Parameters);
				ShowQueryBox(New NotifyDescription("StoreOnUserChangeContinue", ThisObject, NotifyParameters), 
					R().QuestionToUser_005, QuestionDialogMode.YesNoCancel);
			Else
				CommitChanges = True;
			EndIf;
		EndIf;
	// изменение склада в табличной части ItemList
	ElsIf Parameters.EventCaller = "ItemListStoreOnUserChange" Then
		If Parameters.ObjectMetadataInfo.MetadataName = "ShipmentConfirmation" Then
			If NeedCommitChainChangesItemListStoreOnUserChange(Parameters) Then
				CommitChanges = True;
			EndIf;
		EndIf;
	Else
		CommitChanges = True;
	EndIf;
	
	If CommitChanges Then
		ControllerClientServer_V2.CommitChainChanges(Parameters);
		UpdateCacheBeforeChange(Parameters.Object, Parameters.Form);
	EndIf;		
EndProcedure

Function NeedQueryStoreOnUserChange(Parameters)
	If Parameters.Cache.Property("ItemList") Then
		For Each Row In Parameters.Cache.ItemList Do
			If Row.Property("Store") Then
				Return True;
			EndIf;
		EndDo;
	EndIf;
	Return False;
EndFunction

Procedure StoreOnUserChangeContinue(Answer, NotifyPrameters) Export
	If Answer = DialogReturnCode.Yes Then
		ControllerClientServer_V2.CommitChainChanges(NotifyPrameters.Parameters);
		UpdateCacheBeforeChange(NotifyPrameters.Parameters.Object,
								NotifyPrameters.Parameters.Form);
	EndIf;
EndProcedure

Function NeedCommitChainChangesItemListStoreOnUserChange(Parameters)
	If Parameters.Cache.Property("ItemList") Then
		For Each Row In Parameters.Cache.ItemList Do
			If Row.Property("Store") And Not ValueIsFilled(Row.Store) Then
				Return False;
			EndIf;
		EndDo;
	EndIf;
	Return True;
EndFunction

// временная для SalesInvoice
Procedure __tmp_OnChainComplite(Parameters)
	If Parameters.ChangedData.Get("ItemList.Store") <> Undefined Then
		// вопрос при перезаполнении склада в табличной части ItemList
		//StrTemplate(R().QuestionToUser_009, String(NewStore))
	EndIf;
	ControllerClientServer_V2.CommitChainChanges(Parameters);
	UpdateCacheBeforeChange(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

Function AddOrCopyRow(Object, Form, TableName, Cancel, Clone, OriginRow)
	Cancel = True;
	NewRow = Object[TableName].Add();
	If Clone Then // Copy()
		OriginRows = GetRowsByCurrentData(Form, TableName, OriginRow);
		If Not OriginRows.Count() Then
			Raise "Not found origin row for clone";
		EndIf;
		NewRow.Key = String(New UUID());
		Rows = GetRowsByCurrentData(Form, TableName, NewRow);
		Parameters = GetSimpleParameters(Object, Form, TableName, Rows);
		
		// колонки которые не нужно копировать
		ArrayOfExcludeProperties = New Array();
		ArrayOfExcludeProperties.Add("Key");
		If Parameters.ObjectMetadataInfo.DependencyTables.Find("RowIDInfo") <> Undefined Then
			// эти колонки реквизиты формы
			ArrayOfExcludeProperties.Add("IsExternalLinked");
			ArrayOfExcludeProperties.Add("IsInternalLinked");
			ArrayOfExcludeProperties.Add("ExternalLinks");
			ArrayOfExcludeProperties.Add("InternalLinks");
		EndIf;
		
		FillPropertyValues(NewRow, OriginRows[0], ,StrConcat(ArrayOfExcludeProperties, ","));
		
	Else // Add()
		NewRow.Key = String(New UUID());
		Rows = GetRowsByCurrentData(Form, TableName, NewRow);
		Parameters = GetSimpleParameters(Object, Form, TableName, Rows);
		ControllerClientServer_V2.AddNewRow(TableName, Parameters);
	EndIf;
	Return NewRow;
EndFunction

Procedure DeleteRows(Object, Form, TableName)
	Parameters = GetSimpleParameters(Object, Form, TableName);
	ControllerClientServer_V2.DeleteRows(TableName, Parameters);
EndProcedure

#Region FORM

Procedure OnOpen(Object, Form, TableNames) Export
	UpdateCacheBeforeChange(Object, Form);
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TrimAll(TableName));
		ControllerClientServer_V2.FillPropertyFormByDefault(Form,  "Store", Parameters);
		ControllerClientServer_V2.FormOnOpen(Parameters);
	EndDo;
EndProcedure

Procedure OnOpenFormNotify(Parameters) Export
	Return;
EndProcedure

#EndRegion

#Region FORM_MODIFICATOR

Procedure FormModificator_CreateTaxesFormControls(Parameters) Export
	Parameters.Form.Taxes_CreateFormControls();
EndProcedure

#EndRegion

#Region _ITEM_LIST_

Procedure ItemListBeforeAddRow(Object, Form, Cancel, Clone, CurrentData = Undefined) Export
	NewRow = AddOrCopyRow(Object, Form, "ItemList", Cancel, Clone, CurrentData);
	Form.Items.ItemList.CurrentRow = NewRow.GetID();
	Form.Items.ItemList.ChangeRow();
EndProcedure

Procedure ItemListAfterDeleteRow(Object, Form) Export
	DeleteRows(Object, Form, "ItemList");
EndProcedure

#EndRegion

#Region _ITEM_LIST_COLUMNS

// ItemList.Item
Procedure ItemListItemOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListItemOnChange(Parameters);
EndProcedure

// ItemList.ItemKey
Procedure ItemListItemKeyOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListItemKeyOnChange(Parameters);
EndProcedure

Procedure OnSetItemListItemKey(Parameters) Export
	If Parameters.ObjectMetadataInfo.MetadataName = "SalesInvoice" Then
		SerialLotNumberClient.UpdateUseSerialLotNumber(Parameters.Object, Parameters.Form);
	EndIf;
EndProcedure

// ItemList.Unit
Procedure ItemListUnitOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListUnitOnChange(Parameters);
EndProcedure

// ItemList.TaxRate
Procedure ItemListTaxRateOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListTaxRateOnChange(Parameters);
EndProcedure

// ItemList.PriceType
Procedure ItemListPriceTypeOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListPriceTypeOnChange(Parameters);
EndProcedure

// ItemList.Price
Procedure ItemListPriceOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListPriceOnChange(Parameters);
EndProcedure

// ItemList.TaxAmount
Procedure ItemListTaxAmountOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListTaxAmountOnChange(Parameters);
EndProcedure

// ItemList.OffersAmount
Procedure ItemListOffersAmountOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListOffersAmountOnChange(Parameters);
EndProcedure

// ItemList.TotalAmount
Procedure ItemListTotalAmountOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListTotalAmountOnChange(Parameters);
EndProcedure

// ItemList.Store
Procedure ItemListStoreOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_List("ItemList.Store", FormParameters, Rows);
	FormParameters.EventCaller = "ItemListStoreOnUserChange";

	ServerParameters = GetServerParameters(Object);
	ServerParameters.Rows      = Rows;
	ServerParameters.TableName = "ItemList";
	
	Parameters = GetParameters(ServerParameters, FormParameters);
	ControllerClientServer_V2.ItemListStoreOnChange(Parameters);
EndProcedure

// ItemList.DeliveryDate
Procedure ItemListDeliveryDateOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_List("ItemList.DeliveryDate", FormParameters, Rows);
	FormParameters.EventCaller = "ItemListDeliveryDateOnUserChange";

	ServerParameters = GetServerParameters(Object);
	ServerParameters.Rows      = Rows;
	ServerParameters.TableName = "ItemList";
	
	Parameters = GetParameters(ServerParameters, FormParameters);
	ControllerClientServer_V2.ItemListDeliveryDateOnChange(Parameters);
EndProcedure

// ItemList.DontCalculateRow
Procedure ItemListDontCalculateRowOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListDontCalculateRowOnChange(Parameters);
EndProcedure	

// ItemList.Quantity
Procedure ItemListQuantityOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "ItemList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "ItemList", Rows);
	ControllerClientServer_V2.ItemListQuantityOnChange(Parameters);
EndProcedure

Procedure OnSetItemListQuantityNotify(Parameters) Export
	Return;
EndProcedure

Procedure OnSetItemListQuantityInBaseUnit(Parameters) Export
	If Parameters.ObjectMetadataInfo.MetadataName = "SalesInvoice" 
		Or Parameters.ObjectMetadataInfo.MetadataName = "ShipmentConfirmation" Then
		RowIDInfoClient.UpdateQuantity(Parameters.Object, Parameters.Form);
	EndIf;
	
	If Parameters.ObjectMetadataInfo.MetadataName = "SalesInvoice" Then
		SerialLotNumberClient.UpdateSerialLotNumbersTree(Parameters.Object, Parameters.Form);
		DocumentsClient.UpdateTradeDocumentsTree(Parameters.Object, Parameters.Form, 
			"ShipmentConfirmations", "ShipmentConfirmationsTree", "QuantityInShipmentConfirmation");
	EndIf;
EndProcedure

#EndRegion

#Region _PAYMENT_LIST_

Procedure PaymentListBeforeAddRow(Object, Form, Cancel, Clone, CurrentData = Undefined) Export
	NewRow = AddOrCopyRow(Object, Form, "PaymentList", Cancel, Clone, CurrentData);
	Form.Items.PaymentList.CurrentRow = NewRow.GetID();
	Form.Items.PaymentList.ChangeRow();
EndProcedure

Procedure PaymentListAfterDeleteRow(Object, Form) Export
	DeleteRows(Object, Form, "PaymentList");
EndProcedure

#EndRegion

#Region _PAYMENT_LIST_COLUMNS

Procedure PaymentListPartnerOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "PaymentList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "PaymentList", Rows);
	ControllerClientServer_V2.PaymentListPartnerOnChange(Parameters);
EndProcedure

Procedure PaymentListLegalNameOnChange(Object, Form, CurrentData = Undefined) Export
	Rows = GetRowsByCurrentData(Form, "PaymentList", CurrentData);
	Parameters = GetSimpleParameters(Object, Form, "PaymentList", Rows);
	ControllerClientServer_V2.PaymentListLegalNameOnChange(Parameters);
EndProcedure

#EndRegion

#Region ACCOUNT_SENDER

Procedure AccountSenerOnChange(Object, Form) Export
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_Object("Sender", FormParameters);
	ServerParameters = GetServerParameters(Object);
	Parameters = GetParameters(ServerParameters, FormParameters);
	ControllerClientServer_V2.AccountSenderOnChange(Parameters);
EndProcedure

Procedure OnSetAccountSenderNotify_IsUserChange(Parameters) Export
	CommonFunctionsClientServer.SetFormItemModifiedByUser(Parameters.Form, "Sender");
	SetSendCurrencyReadOnly(Parameters);
EndProcedure

Procedure OnSetAccountSenderNotify_IsProgrammChange(Parameters) Export
	SetSendCurrencyReadOnly(Parameters);
EndProcedure

Procedure SetSendCurrencyReadOnly(Parameters)
	AccountSenderCurrency = ServiceSystemServer.GetObjectAttribute(Parameters.Object.Sender, "Currency");
	Parameters.Form.Items.SendCurrency.ReadOnly = ValueIsFilled(AccountSenderCurrency);
EndProcedure

#EndRegion

#Region CURRENCY_SENDER

Procedure OnSetSendCurrencyNotify_IsProgrammChange(Parameters) Export
	Return;
EndProcedure

#EndRegion

#Region ACCOUNT_RECEIVER

Procedure AccountReceiverOnChange(Object, Form) Export
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_Object("Sender", FormParameters);
	ServerParameters = GetServerParameters(Object);
	Parameters = GetParameters(ServerParameters, FormParameters);
	ControllerClientServer_V2.AccountReceiverOnChange(Parameters);
EndProcedure

Procedure OnSetAccountReceiverNotify_IsUserChange(Parameters) Export
	CommonFunctionsClientServer.SetFormItemModifiedByUser(Parameters.Form, "Receiver");
	SetReceiveCurrencyReadOnly(Parameters);
EndProcedure

Procedure OnSetAccountReceiverNotify_IsProgrammChange(Parameters) Export
	SetReceiveCurrencyReadOnly(Parameters);
EndProcedure

Procedure SetReceiveCurrencyReadOnly(Parameters)
	AccountReceiverCurrency = ServiceSystemServer.GetObjectAttribute(Parameters.Object.Receiver, "Currency");
	Parameters.Form.Items.ReceiveCurrency.ReadOnly = ValueIsFilled(AccountReceiverCurrency);
EndProcedure

#EndRegion

#Region CURRENCY_RECEIVER

Procedure OnSetReceiveCurrencyNotify_IsProgrammChange(Parameters) Export
	Return;
EndProcedure

#EndRegion

#Region STORE

Procedure StoreOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		FormParameters = GetFormParameters(Form);
		FormParameters.EventCaller = "StoreOnUserChange";
		ExtractValueBeforeChange_Form("Store", FormParameters);
	
		ServerParameters = GetServerParameters(Object);
		ServerParameters.TableName = TableName;
	
		Parameters = GetParameters(ServerParameters, FormParameters);
	
		ControllerClientServer_V2.StoreOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetStoreNotify(Parameters) Export
	StoreArray = New Array();
	For Each Row In Parameters.Object.ItemList Do
		If ValueIsFilled(Row.Store) And StoreArray.Find(Row.Store) = Undefined Then
			StoreArray.Add(Row.Store);
		EndIf;
	EndDo;
	If StoreArray.Count() > 1 Then
		Parameters.Form.Items.Store.InputHint = StrConcat(StoreArray, "; ");
	EndIf;
EndProcedure

#EndRegion

#Region DELIVERY_DATE

Procedure DeliveryDateOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		FormParameters = GetFormParameters(Form);
		FormParameters.EventCaller = "DeliveryDateOnUserChange";
		ExtractValueBeforeChange_Form("DeliveryDate", FormParameters);
	
		ServerParameters = GetServerParameters(Object);
		ServerParameters.TableName = TableName;
	
		Parameters = GetParameters(ServerParameters, FormParameters);
	
		ControllerClientServer_V2.DeliveryDateOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetDeliveryDateNotify(Parameters) Export
	DeliveryDateArray = New Array();
	For Each Row In Parameters.Object.ItemList Do
		If ValueIsFilled(Row.DeliveryDate) And DeliveryDateArray.Find(Row.DeliveryDate) = Undefined Then
			DeliveryDateArray.Add(Row.DeliveryDate);
		EndIf;
	EndDo;
	If DeliveryDateArray.Count() > 1 Then
		DeliveryDateFormattedArray = New Array();
		For Each Row In DeliveryDateArray Do
			DeliveryDateFormattedArray.Add(Format(Row, "DF=dd.MM.yy;"));
		EndDo;
		Parameters.Form.Items.DeliveryDate.Tooltip = StrConcat(DeliveryDateFormattedArray, "; ");
	EndIf;
EndProcedure

#EndRegion

#Region _DATE

Procedure DateOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TrimAll(TableName));
		ControllerClientServer_V2.DateOnChange(Parameters);
	EndDo;
EndProcedure

#EndRegion

#Region COMPANY

Procedure CompanyOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TrimAll(TableName));
		ControllerClientServer_V2.CompanyOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetCompanyNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region ACCOUNT

Procedure AccountOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TrimAll(TableName));
		ControllerClientServer_V2.AccountOnChange(Parameters);
	EndDo;
EndProcedure
	
Procedure OnSetAccountNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region CURRENCY

Procedure CurrencyOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TrimAll(TableName));
		ControllerClientServer_V2.CurrencyOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetCurrencyNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region PARTNER

Procedure PartnerOnChange(Object, Form, TableNames) Export
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_Object("Partner", FormParameters);
	
	For Each TableName In StrSplit(TableNames, ",") Do
		ServerParameters = GetServerParameters(Object);
		ServerParameters.TableName = TableName;
		Parameters = GetParameters(ServerParameters, FormParameters);
		ControllerClientServer_V2.PartnerOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetPartnerNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region LEGAL_NAME

Procedure LegalNameOnChange(Object, Form, TableNames) Export
	For Each TableName In StrSplit(TableNames, ",") Do
		Parameters = GetSimpleParameters(Object, Form, TableName);
		ControllerClientServer_V2.LegalNameOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetLegalNameNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region AGREEMENT

Procedure AgreementOnChange(Object, Form, TableNames) Export
	FormParameters = GetFormParameters(Form);
	ExtractValueBeforeChange_Object("Agreement", FormParameters);
	
	For Each TableName In StrSplit(TableNames, ",") Do
		ServerParameters = GetServerParameters(Object);
		ServerParameters.TableName = TableName;
		Parameters = GetParameters(ServerParameters, FormParameters);
		ControllerClientServer_V2.AgreementOnChange(Parameters);
	EndDo;
EndProcedure

Procedure OnSetAgreementNotify(Parameters) Export
	DocumentsClientServer.ChangeTitleGroupTitle(Parameters.Object, Parameters.Form);
EndProcedure

#EndRegion

#Region PRICE_INCLUDE_TAX

Procedure PriceIncludeTaxOnChange(Object, Form) Export
	Parameters = GetSimpleParameters(Object, Form, "ItemList");
	ControllerClientServer_V2.PriceIncludeTaxOnChange(Parameters);
EndProcedure

#EndRegion

