#Region PrintForm

Function GetPrintForm(Ref, PrintFormName, AddInfo = Undefined) Export
	Return Undefined;
EndFunction

#EndRegion

#Region Posting

Function PostingGetDocumentDataTables(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	QueryArray = GetQueryTextsSecondaryTables(Parameters);
	Parameters.Insert("QueryParameters", GetAdditionalQueryParameters(Ref));
	PostingServer.ExecuteQuery(Ref, QueryArray, Parameters);
	Return New Structure();
EndFunction

Function PostingGetLockDataSource(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	DataMapWithLockFields = New Map();
	Return DataMapWithLockFields;
EndFunction

Procedure PostingCheckBeforeWrite(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	Tables = Parameters.DocumentDataTables;
	QueryArray = GetQueryTextsMasterTables();
	PostingServer.SetRegisters(Tables, Ref);
	PostingServer.FillPostingTables(Tables, Ref, QueryArray, Parameters);
EndProcedure

Function PostingGetPostingDataTables(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	PostingDataTables = New Map();
	PostingServer.SetPostingDataTables(PostingDataTables, Parameters);
	Return PostingDataTables;
EndFunction

Procedure PostingCheckAfterWrite(Ref, Cancel, PostingMode, Parameters, AddInfo = Undefined) Export
	CheckAfterWrite(Ref, Cancel, Parameters, AddInfo);
EndProcedure

#EndRegion

#Region Undoposting

Function UndopostingGetDocumentDataTables(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	Parameters.Insert("Unposting", True);
	Return PostingGetDocumentDataTables(Ref, Cancel, Undefined, Parameters, AddInfo);
EndFunction

Function UndopostingGetLockDataSource(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	DataMapWithLockFields = New Map();
	Return DataMapWithLockFields;
EndFunction

Procedure UndopostingCheckBeforeWrite(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	Return;
EndProcedure

Procedure UndopostingCheckAfterWrite(Ref, Cancel, Parameters, AddInfo = Undefined) Export
	Parameters.Insert("Unposting", True);
	CheckAfterWrite(Ref, Cancel, Parameters, AddInfo);
EndProcedure

#EndRegion

#Region CheckAfterWrite

Procedure CheckAfterWrite(Ref, Cancel, Parameters, AddInfo = Undefined)
	Return;
EndProcedure

#EndRegion

Function GetInformationAboutMovements(Ref) Export
	Str = New Structure();
	Str.Insert("QueryParameters", GetAdditionalQueryParameters(Ref));
	Str.Insert("QueryTextsMasterTables", GetQueryTextsMasterTables());
	Str.Insert("QueryTextsSecondaryTables", GetQueryTextsSecondaryTables());
	Return Str;
EndFunction

Function GetAdditionalQueryParameters(Ref)
	StrParams = New Structure();
	StrParams.Insert("Ref", Ref);
	Return StrParams;
EndFunction

Function GetQueryTextsSecondaryTables(Parameters = Undefined)
	QueryArray = New Array();
	QueryArray.Add(OffsetOfAdvancesAndAging(Parameters));
	Return QueryArray;
EndFunction

Function GetQueryTextsMasterTables()
	QueryArray = New Array();
	QueryArray.Add(T2010S_OffsetOfAdvances());
	QueryArray.Add(T2013S_OffsetOfAging());
	Return QueryArray;
EndFunction

#Region OffsetOfAdvances2

Function OffsetOfAdvancesAndAging(Parameters)
	If Parameters = Undefined Then
		Return VendorsAdvancesClosingQueryText();
	EndIf;
	If Parameters.Property("Unposting") And Parameters.Unposting Then
		Clear_SelfRecords(Parameters);
		Return VendorsAdvancesClosingQueryText();
	EndIf;
	
	Records_AdvancesKey = AccumulationRegisters.TM1020B_AdvancesKey.CreateRecordSet().UnloadColumns();
	Records_AdvancesKey.Columns.Delete(Records_AdvancesKey.Columns.PointInTime);
	
	Records_TransactionsKey = AccumulationRegisters.TM1030B_TransactionsKey.CreateRecordSet().UnloadColumns();
	Records_TransactionsKey.Columns.Delete(Records_TransactionsKey.Columns.PointInTime);
	
	Records_AgingsKey = AccumulationRegisters.TM1040T_AgingsKey.CreateRecordSet().UnloadColumns();
	Records_AgingsKey.Columns.Delete(Records_AgingsKey.Columns.PointInTime);
	
	// detail info by all offsets
	Records_OffsetInfo = InformationRegisters.T2010S_OffsetOfAdvances.CreateRecordSet().UnloadColumns();
	Records_OffsetInfo.Columns.Delete(Records_OffsetInfo.Columns.PointInTime);
	Records_OffsetInfo.Columns.Add("AdvancesRowKey"     , Metadata.DefinedTypes.typeRowID.Type);
	Records_OffsetInfo.Columns.Add("TransactionsRowKey" , Metadata.DefinedTypes.typeRowID.Type);
	
	// detail info by all aging
	Records_OffsetAging = InformationRegisters.T2013S_OffsetOfAging.CreateRecordSet().UnloadColumns();
	Records_OffsetAging.Columns.Delete(Records_OffsetAging.Columns.PointInTime);
	
	// Clear register records
	Clear_SelfRecords(Parameters);
	Write_TM1020B_AdvancesKey(Parameters, Records_AdvancesKey);
	Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey);
	
	// Create advances keys
	CreateAdvancesKeys(Parameters, Records_AdvancesKey);
	// Write advances keys to TM1020B_AdvancesKey, Receipt
	Write_TM1020B_AdvancesKey(Parameters, Records_AdvancesKey);
		
	// Create transactions keys
	CreateTransactionsKeys(Parameters, Records_TransactionsKey);
	// Write transactions keys to TM1030B_TransactionsKey
	Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey);

	
	// Offset advances to transactions - first iteration
	OffsetAdvancesToTransactions(Parameters, Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo, Records_AgingsKey);
	// Offset transactions to advances - firs iteration
	OffsetTransactionsToAdvances(Parameters, Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo, Records_AgingsKey);
	
	// after first iteration of 'offset advances to transactions' and 'offset transactions to advance'
	// Offset due as advance, TM1030B_TransactionsKey = Expense, TM1020B_AdvancesKey = Receipt
//	Query = New Query();
//	Query.Text = 
//	"SELECT
//	|	T2015S_TransactionsInfo.Recorder AS Document,
//	|	T2015S_TransactionsInfo.Company,
//	|	T2015S_TransactionsInfo.Branch,
//	|	T2015S_TransactionsInfo.Currency,
//	|	T2015S_TransactionsInfo.Date,
//	|	T2015S_TransactionsInfo.Partner,
//	|	T2015S_TransactionsInfo.LegalName,
//	|	T2015S_TransactionsInfo.Agreement,
//	|	T2015S_TransactionsInfo.Order,
//	|	T2015S_TransactionsInfo.TransactionBasis,
//	|	SUM(T2015S_TransactionsInfo.Amount) AS Amount
//	|INTO tmp_TransactionsInfo
//	|FROM
//	|	InformationRegister.T2015S_TransactionsInfo AS T2015S_TransactionsInfo
//	|WHERE
//	|	T2015S_TransactionsInfo.Date BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
//	|	AND T2015S_TransactionsInfo.Company = &Comapny
//	|	AND T2015S_TransactionsInfo.Branch = &Branch
//	|	AND T2015S_TransactionsInfo.IsVendorTransaction
//	|	AND T2015S_TransactionsInfo.DueAsAdvance
//	|GROUP BY
//	|	T2015S_TransactionsInfo.Branch,
//	|	T2015S_TransactionsInfo.Company,
//	|	T2015S_TransactionsInfo.Currency,
//	|	T2015S_TransactionsInfo.Date,
//	|	T2015S_TransactionsInfo.LegalName,
//	|	T2015S_TransactionsInfo.Agreement,
//	|	T2015S_TransactionsInfo.Order,
//	|	T2015S_TransactionsInfo.TransactionBasis,
//	|	T2015S_TransactionsInfo.Partner,
//	|	T2015S_TransactionsInfo.Recorder
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	MAX(TransactionsKeys.Ref) AS TransactionKey,
//	|	tmp_TransactionsInfo.Document,
//	|	tmp_TransactionsInfo.Company,
//	|	tmp_TransactionsInfo.Branch,
//	|	tmp_TransactionsInfo.Currency,
//	|	tmp_TransactionsInfo.Date,
//	|	tmp_TransactionsInfo.Partner,
//	|	tmp_TransactionsInfo.LegalName,
//	|	tmp_TransactionsInfo.Agreement,
//	|	tmp_TransactionsInfo.Order,
//	|	tmp_TransactionsInfo.TransactionBasis,
//	|	SUM(tmp_TransactionsInfo.Amount) AS Amount,
//	|	TRUE AS IsVendorTransaction
//	|FROM
//	|	tmp_TransactionsInfo AS tmp_TransactionsInfo
//	|		INNER JOIN Catalog.TransactionsKeys AS TransactionsKeys
//	|		ON NOT TransactionsKeys.DeletionMark
//	|		AND tmp_TransactionsInfo.Document = TransactionsKeys.Document
//	|		AND tmp_TransactionsInfo.Company = TransactionsKeys.Company
//	|		AND tmp_TransactionsInfo.Branch = TransactionsKeys.Branch
//	|		AND tmp_TransactionsInfo.Currency = TransactionsKeys.Currency
//	|		AND tmp_TransactionsInfo.Partner = TransactionsKeys.Partner
//	|		AND tmp_TransactionsInfo.LegalName = TransactionsKeys.LegalName
//	|		AND tmp_TransactionsInfo.Agreement = TransactionsKeys.Agreement
//	|		AND tmp_TransactionsInfo.Order = TransactionsKeys.Order
//	|		AND tmp_TransactionsInfo.TransactionBasis = TransactionsKeys.TransactionBasis
//	|		AND TransactionsKeys.IsVendorTransaction
//	|GROUP BY
//	|	tmp_TransactionsInfo.Branch,
//	|	tmp_TransactionsInfo.Company,
//	|	tmp_TransactionsInfo.Currency,
//	|	tmp_TransactionsInfo.Date,
//	|	tmp_TransactionsInfo.Document,
//	|	tmp_TransactionsInfo.LegalName,
//	|	tmp_TransactionsInfo.Agreement,
//	|	tmp_TransactionsInfo.Order,
//	|	tmp_TransactionsInfo.TransactionBasis,
//	|	tmp_TransactionsInfo.Partner";
//	Query.SetParameter("BeginOfPeriod", Parameters.Object.BeginOfPeriod);
//	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
//	Query.SetParameter("Company"      , Parameters.Object.Company);
//	Query.SetParameter("Branch"       , Parameters.Object.Branch);
//	
//	QueryResult = Query.Execute();
//	QuerySelection = QueryResult.Select();
//	
//	While QuerySelection.Next() Do
//		//WriteDueToAdvances();
//	EndDo;
	
	// Offset advances to transactions - second iteration
	//OffsetAdvancesToTransactions(Parameters, Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo);
	
	// Offset transactions to advances - second iteration
	//OffsetTransactionsToAdvances(Parameters, Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo);
	
	// Aging calculation
	Write_TM1040T_AgingsKey(Parameters, Records_AgingsKey);
	OffsetTransactionsToAging(Parameters, Records_OffsetAging);
		
	// Write OffsetInfo to R1020B_AdvancesToVendors and R1021B_VendorsTransactions and R5012B_VendorsAging
	Write_SelfRecords(Parameters, Records_OffsetInfo, Records_OffsetAging);
	
	
	WriteTablesToTempTables(Parameters, Records_OffsetInfo, Records_OffsetAging);
	Parameters.Object.RegisterRecords.TM1030B_TransactionsKey.Read();
	Parameters.Object.RegisterRecords.TM1020B_AdvancesKey.Read();
	Parameters.Object.RegisterRecords.TM1040T_AgingsKey.Read();
	
	Return VendorsAdvancesClosingQueryText();
EndFunction

Procedure WriteTablesToTempTables(Parameters, Records_OffsetInfo, Records_OffsetAging)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	Records_OffsetInfo.Period,
	|	Records_OffsetInfo.Document,
	|	Records_OffsetInfo.Company,
	|	Records_OffsetInfo.Branch,
	|	Records_OffsetInfo.Currency,
	|	Records_OffsetInfo.Partner,
	|	Records_OffsetInfo.LegalName,
	|	Records_OffsetInfo.TransactionDocument,
	|	Records_OffsetInfo.AdvancesDocument,
	|	Records_OffsetInfo.Agreement,
	|	Records_OffsetInfo.Key,
	|	Records_OffsetInfo.Amount,
	|	Records_OffsetInfo.DueAsAdvance
	|INTO tmpRecords_OffsetInfo
	|FROM
	|	&Records_OffsetInfo AS Records_OffsetInfo
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Records_OffsetAging.Period,
	|	Records_OffsetAging.Document,
	|	Records_OffsetAging.Company,
	|	Records_OffsetAging.Branch,
	|	Records_OffsetAging.Currency,
	|	Records_OffsetAging.Partner,
	|	Records_OffsetAging.Agreement,
	|	Records_OffsetAging.Invoice,
	|	Records_OffsetAging.PaymentDate,
	|	Records_OffsetAging.Amount
	|INTO tmpRecords_OffsetAging
	|FROM
	|	&Records_OffsetAging AS Records_OffsetAging
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpRecords_OffsetInfo.Period,
	|	tmpRecords_OffsetInfo.Document,
	|	tmpRecords_OffsetInfo.Company,
	|	tmpRecords_OffsetInfo.Branch,
	|	tmpRecords_OffsetInfo.Currency,
	|	tmpRecords_OffsetInfo.Partner,
	|	tmpRecords_OffsetInfo.LegalName,
	|	tmpRecords_OffsetInfo.TransactionDocument,
	|	tmpRecords_OffsetInfo.AdvancesDocument,
	|	tmpRecords_OffsetInfo.Agreement,
	|	tmpRecords_OffsetInfo.Key,
	|	tmpRecords_OffsetInfo.DueAsAdvance,
	|	SUM(tmpRecords_OffsetInfo.Amount) AS Amount
	|INTO Records_OffsetInfo
	|FROM
	|	tmpRecords_OffsetInfo AS tmpRecords_OffsetInfo
	|GROUP BY
	|	tmpRecords_OffsetInfo.Period,
	|	tmpRecords_OffsetInfo.Document,
	|	tmpRecords_OffsetInfo.Company,
	|	tmpRecords_OffsetInfo.Branch,
	|	tmpRecords_OffsetInfo.Currency,
	|	tmpRecords_OffsetInfo.Partner,
	|	tmpRecords_OffsetInfo.LegalName,
	|	tmpRecords_OffsetInfo.TransactionDocument,
	|	tmpRecords_OffsetInfo.AdvancesDocument,
	|	tmpRecords_OffsetInfo.Agreement,
	|	tmpRecords_OffsetInfo.Key,
	|	tmpRecords_OffsetInfo.DueAsAdvance
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpRecords_OffsetAging.Period,
	|	tmpRecords_OffsetAging.Document,
	|	tmpRecords_OffsetAging.Company,
	|	tmpRecords_OffsetAging.Branch,
	|	tmpRecords_OffsetAging.Currency,
	|	tmpRecords_OffsetAging.Partner,
	|	tmpRecords_OffsetAging.Agreement,
	|	tmpRecords_OffsetAging.Invoice,
	|	tmpRecords_OffsetAging.PaymentDate,
	|	SUM(tmpRecords_OffsetAging.Amount) AS Amount
	|INTO Records_OffsetAging
	|FROM
	|	tmpRecords_OffsetAging AS tmpRecords_OffsetAging
	|GROUP BY
	|	tmpRecords_OffsetAging.Period,
	|	tmpRecords_OffsetAging.Document,
	|	tmpRecords_OffsetAging.Company,
	|	tmpRecords_OffsetAging.Branch,
	|	tmpRecords_OffsetAging.Currency,
	|	tmpRecords_OffsetAging.Partner,
	|	tmpRecords_OffsetAging.Agreement,
	|	tmpRecords_OffsetAging.Invoice,
	|	tmpRecords_OffsetAging.PaymentDate";

	Query.SetParameter("Records_OffsetInfo"   , Records_OffsetInfo);
	Query.SetParameter("Records_OffsetAging"  , Records_OffsetAging);

	Query.Execute();
EndProcedure

Function T2010S_OffsetOfAdvances()
	Return 
	"SELECT
	|	*
	|INTO T2010S_OffsetOfAdvances
	|FROM
	|	Records_OffsetInfo
	|WHERE
	|	TRUE";
EndFunction

Function T2013S_OffsetOfAging()
	Return 
	"SELECT
	|	*
	|INTO T2013S_OffsetOfAging
	|FROM
	|	Records_OffsetAging
	|WHERE
	|	TRUE";
EndFunction

Procedure WriteDueToAdvances(Parameters, Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo)
//	Query = New Query();
//	Query.Text = 
//	"SELECT
//	|	TransactionsBalance.TransactionKey,
//	|	TransactionsBalance.AmountBalance AS TransactionAmount
//	|FROM
//	|	AccumulationRegister.TM1030B_TransactionsKey.Balance(ENDOFPERIOD(&EndOfPeriod, DAY),
//	|		TransactionKey.Company = &Company
//	|	AND TransactionKey.Branch = &Branch
//	|	AND TransactionKey.IsVendorTransaction) AS TransactionsBalance";
//	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
//	Query.SetParameter("Company"      , Parameters.Object.Company);
//	Query.SetParameter("Branch"       , Parameters.Object.Branch);
//	
//	QueryResult = Query.Execute();
//	QuerySelection = QueryResult.Select();
//
//	NeedWriteTransactions = False;
//	While QuerySelection.Next() Do
//		DistributeTransactionToAdvance(Parameters, QuerySelection.TransactionKey, QuerySelection.TransactionAmount,
//			Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo, NeedWriteTransactions);
//	EndDo;
//	// Write ofsetted advances to TM1020B_AdvancesKey, Expense
//	If NeedWriteTransactions Then
//		Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey);
//	EndIf;

EndProcedure

// transaction 01.01 => advance 02.01
Procedure OffsetAdvancesToTransactions(Parameters, Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo, Records_AgingsKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	AdvancesBalance.AdvanceKey,
	|	SUM(AdvancesBalance.AmountBalance) AS AdvanceAmount
	|FROM
	|	AccumulationRegister.TM1020B_AdvancesKey.Balance(ENDOFPERIOD(&EndOfPeriod, DAY), AdvanceKey.Company = &Company
	|	AND AdvanceKey.Branch = &Branch
	|	AND AdvanceKey.IsVendorAdvance) AS AdvancesBalance
	|GROUP BY
	|	AdvancesBalance.AdvanceKey
	|HAVING
	|	SUM(AdvancesBalance.AmountBalance) > 0";
	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company"      , Parameters.Object.Company);
	Query.SetParameter("Branch"       , Parameters.Object.Branch);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();

	NeedWriteAdvances = False;
	While QuerySelection.Next() Do
		DistributeAdvanceToTransaction(Parameters, QuerySelection.AdvanceKey, QuerySelection.AdvanceAmount,
			Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo, Records_AgingsKey, NeedWriteAdvances);
	EndDo;
	// Write ofsetted advances to TM1020B_AdvancesKey, Expense
	If NeedWriteAdvances Then
		Write_TM1020B_AdvancesKey(Parameters, Records_AdvancesKey);
	EndIf;
EndProcedure

// transaction 01.01 => advance 02.01
Procedure DistributeAdvanceToTransaction(Parameters, AdvanceKey, AdvanceAmount, 
	Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo, Records_AgingsKey, NeedWriteAdvances)
	
	Query = New Query();
	Query.Text = 
	"SELECT
	|	TransactionsBalance.TransactionKey,
	|	SUM(TransactionsBalance.AmountBalance) AS TransactionAmount
	|FROM
	|	AccumulationRegister.TM1030B_TransactionsKey.Balance(&AdvanceBoundary, TransactionKey.Company = &Company
	|	AND TransactionKey.Branch = &Branch
	|	AND TransactionKey.Currency = &Currency
	|	AND TransactionKey.Partner = &Partner
	|	AND TransactionKey.LegalName = &LegalName) AS TransactionsBalance
	|GROUP BY
	|	TransactionsBalance.TransactionKey
	|HAVING
	|	SUM(TransactionsBalance.AmountBalance) > 0";
	Query.SetParameter("AdvanceBoundary", 
	New Boundary(AdvanceKey.Document.PointInTime(),BoundaryType.Including));
	Query.SetParameter("Company"    , AdvanceKey.Company);
	Query.SetParameter("Branch"     , AdvanceKey.Branch);
	Query.SetParameter("Currency"   , AdvanceKey.Currency);
	Query.SetParameter("Partner"    , AdvanceKey.Partner);
	Query.SetParameter("LegalName"  , AdvanceKey.LegalName);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	NeedWriteoff = AdvanceAmount;
	NeedWriteTransactions = False;
	While QuerySelection.Next() Do
		If NeedWriteoff = 0 Then
			Break;
		EndIf;
		If ValueIsFilled(AdvanceKey.Order) Then // advance by order
			If QuerySelection.TransactionKey.Order <> AdvanceKey.Order Then
				Continue;
			EndIf;
		EndIf;
		CanWriteoff = Min(QuerySelection.TransactionAmount, AdvanceAmount);
		NeedWriteoff = NeedWriteoff - CanWriteoff;
		
		// Expense, Date = AdvanceKey.Date
		NewRow = Records_TransactionsKey.Add();
		NewRow.RecordType = AccumulationRecordType.Expense;
		NewRow.Period         = AdvanceKey.Date;
		NewRow.TransactionKey = QuerySelection.TransactionKey;
		NewRow.Amount         = CanWriteOff;
		NeedWriteTransactions = True;
		NeedWriteAdvances     = True;
		
		NewOffsetInfo = Records_OffsetInfo.Add();
		NewOffsetInfo.Period              = AdvanceKey.Date;
		NewOffsetInfo.Amount              = CanWriteoff;
		NewOffsetInfo.Document            = AdvanceKey.Document;
		NewOffsetInfo.Company             = AdvanceKey.Company;
		NewOffsetInfo.Branch              = AdvanceKey.Branch;
		NewOffsetInfo.Currency            = AdvanceKey.Currency;
		NewOffsetInfo.Partner             = AdvanceKey.Partner;
		NewOffsetInfo.LegalName           = AdvanceKey.LegalName;
		NewOffsetInfo.AdvancesDocument    = AdvanceKey.Document;
		NewOffsetInfo.TransactionDocument = QuerySelection.TransactionKey.Document;
		NewOffsetInfo.AdvancesRowKey      = FindRowKeyByAdvanceKey(AdvanceKey);
		NewOffsetInfo.TransactionsRowKey  = FindRowKeyByTransactionKey(QuerySelection.TransactionKey);
		NewOffsetInfo.Key = NewOffsetInfo.AdvancesRowKey;
		
		NewAgingsKey = Records_AgingsKey.Add();
		NewAgingsKey.Period         = AdvanceKey.Date;
		NewAgingsKey.TransactionKey = QuerySelection.TransactionKey;
		NewAgingsKey.Amount         = CanWriteoff;
	EndDo;
	
	// Write offseted transactions to TM1030B_TransactionsKey
	If NeedWriteTransactions Then
		Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey);
	EndIf;
EndProcedure

// advance 01.01 => transaction 02.01
Procedure OffsetTransactionsToAdvances(Parameters, Records_TransactionsKey, Records_AdvancesKey, Records_OffsetInfo, Records_AgingsKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	TransactionsBalance.TransactionKey,
	|	TransactionsBalance.AmountBalance AS TransactionAmount
	|FROM
	|	AccumulationRegister.TM1030B_TransactionsKey.Balance(ENDOFPERIOD(&EndOfPeriod, DAY),
	|		TransactionKey.Company = &Company
	|	AND TransactionKey.Branch = &Branch
	|	AND TransactionKey.IsVendorTransaction) AS TransactionsBalance";
	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company"      , Parameters.Object.Company);
	Query.SetParameter("Branch"       , Parameters.Object.Branch);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();

	NeedWriteTransactions = False;
	While QuerySelection.Next() Do
		DistributeTransactionToAdvance(Parameters, QuerySelection.TransactionKey, QuerySelection.TransactionAmount,
			Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo, Records_AgingsKey, NeedWriteTransactions);
	EndDo;
	// Write ofsetted advances to TM1020B_AdvancesKey, Expense
	If NeedWriteTransactions Then
		Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey);
	EndIf;
EndProcedure

// advance 01.01 => transaction 02.01
Procedure DistributeTransactionToAdvance(Parameters, TransactionKey, TransactionAmount, 
	Records_AdvancesKey, Records_TransactionsKey, Records_OffsetInfo, Records_AgingsKey, NeedWriteTransactions)
	
	Query = New Query();
	Query.Text = 
	"SELECT
	|	AdvancesBalance.AdvanceKey,
	|	SUM(AdvancesBalance.AmountBalance) AS AdvanceAmount
	|FROM
	|	AccumulationRegister.TM1020B_AdvancesKey.Balance(&TransactionBoundary, AdvanceKey.Company = &Company
	|	AND AdvanceKey.Branch = &Branch
	|	AND AdvanceKey.Currency = &Currency
	|	AND AdvanceKey.Partner = &Partner
	|	AND AdvanceKey.LegalName = &LegalName) AS AdvancesBalance
	|GROUP BY
	|	AdvancesBalance.AdvanceKey
	|HAVING
	|	SUM(AdvancesBalance.AmountBalance) > 0";
	Query.SetParameter("TransactionBoundary",
	New Boundary(TransactionKey.Document.PointInTime(), BoundaryType.Including));
	Query.SetParameter("Company"        , TransactionKey.Company);
	Query.SetParameter("Branch"         , TransactionKey.Branch);
	Query.SetParameter("Currency"       , TransactionKey.Currency);
	Query.SetParameter("Partner"        , TransactionKey.Partner);
	Query.SetParameter("LegalName"      , TransactionKey.LegalName);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	NeedWriteoff = TransactionAmount;
	NeedWriteAdvances = False;
	While QuerySelection.Next() Do
		If NeedWriteoff = 0 Then
			Break;
		EndIf;
		If ValueIsFilled(TransactionKey.Order) Then // transaction by order
			If QuerySelection.AdvanceKey.Order <> TransactionKey.Order Then
				Continue;
			EndIf;
		EndIf;
		CanWriteoff = Min(QuerySelection.AdvanceAmount, NeedWriteoff);
		NeedWriteoff = NeedWriteoff - CanWriteoff;
		
		// Expense, Date = TransactionKey.Date
		NewRow = Records_AdvancesKey.Add();
		NewRow.RecordType     = AccumulationRecordType.Expense;
		NewRow.Period         = TransactionKey.Date;
		NewRow.AdvanceKey     = QuerySelection.AdvanceKey;
		NewRow.Amount         = CanWriteOff;
		NeedWriteAdvances     = True;
		NeedWriteTransactions = True;
		
		NewOffsetInfo = Records_OffsetInfo.Add();
		NewOffsetInfo.Period              = TransactionKey.Date;
		NewOffsetInfo.Amount              = CanWriteoff;
		NewOffsetInfo.Document            = TransactionKey.Document;
		NewOffsetInfo.Company             = TransactionKey.Company;
		NewOffsetInfo.Branch              = TransactionKey.Branch;
		NewOffsetInfo.Currency            = TransactionKey.Currency;
		NewOffsetInfo.Partner             = TransactionKey.Partner;
		NewOffsetInfo.LegalName           = TransactionKey.LegalName;
		NewOffsetInfo.AdvancesDocument    = QuerySelection.AdvanceKey.Document;
		NewOffsetInfo.TransactionDocument = TransactionKey.Document;
		NewOffsetInfo.AdvancesRowKey      = FindRowKeyByAdvanceKey(QuerySelection.AdvanceKey);
		NewOffsetInfo.TransactionsRowKey  = FindRowKeyByTransactionKey(TransactionKey);
		NewOffsetInfo.Key = NewOffsetInfo.TransactionsRowKey;
		
		NewAgingsKey = Records_AgingsKey.Add();
		NewAgingsKey.Period         = TransactionKey.Date;
		NewAgingsKey.TransactionKey = TransactionKey;
		NewAgingsKey.Amount         = CanWriteoff;
	EndDo;
	
	// Write offseted advances to TM1020B_AdvancesKey
	If NeedWriteAdvances Then
		Write_TM1020B_AdvancesKey(Parameters, Records_AdvancesKey);
	EndIf;
EndProcedure

Procedure OffsetTransactionsToAging(Parameters, Records_OffsetAging)
	Query = New Query();
	Query.Text =
	"SELECT
	|	TM1040T_AgingsKey.AmountTurnover AS TransactionAmount,
	|	TM1040T_AgingsKey.TransactionKey
	|FROM
	|	AccumulationRegister.TM1040T_AgingsKey.Turnovers(BEGINOFPERIOD(&BeginOfPeriod, DAY), ENDOFPERIOD(&EndOfPeriod, DAY),,
	|		TransactionKey.Company = &Company
	|	AND TransactionKey.Branch = &Branch
	|	AND TransactionKey.IsVendorTransaction) AS TM1040T_AgingsKey";
	Query.SetParameter("BeginOfPeriod", Parameters.Object.BeginOfPeriod);
	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company"      , Parameters.Object.Company);
	Query.SetParameter("Branch"       , Parameters.Object.Branch);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	While QuerySelection.Next() Do
		DistributeTransactionToAging(Parameters, QuerySelection.TransactionKey, QuerySelection.TransactionAmount,
			Records_OffsetAging);
	EndDo;
EndProcedure

Procedure DistributeTransactionToAging(Parameters, TransactionKey, TransactionAmount, Records_OffsetAging)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	VendorsAging.PaymentDate,
	|	SUM(VendorsAging.AmountBalance) AS PaymentAmount
	|FROM
	|	AccumulationRegister.R5012B_VendorsAging.Balance(&TransactionBoundary, Company = &Company
	|	AND Branch = &Branch
	|	AND Currency = &Currency
	|	AND Agreement = &Agreement
	|	AND Partner = &Partner
	|	AND Invoice = &TransactionBasis) AS VendorsAging
	|GROUP BY
	|	VendorsAging.PaymentDate
	|HAVING
	|	SUM(VendorsAging.AmountBalance) > 0";
	Query.SetParameter("TransactionBoundary", 
	New Boundary(TransactionKey.Document.PointInTime(), BoundaryType.Including));
	Query.SetParameter("Company"          , TransactionKey.Company);
	Query.SetParameter("Branch"           , TransactionKey.Branch);
	Query.SetParameter("Currency"         , TransactionKey.Currency);
	Query.SetParameter("Agreement"        , TransactionKey.Agreement);
	Query.SetParameter("Partner"          , TransactionKey.Partner);
	Query.SetParameter("TransactionBasis" , TransactionKey.TransactionBasis);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	NeedWriteoff = TransactionAmount;
	While QuerySelection.Next() Do
		If NeedWriteoff = 0 Then
			Break;
		EndIf;
		CanWriteoff = Min(QuerySelection.PaymentAmount, NeedWriteoff);
		NeedWriteoff = NeedWriteoff - CanWriteoff;
		
		NewRow = Records_OffsetAging.Add();
		NewRow.Period      = TransactionKey.Date;
		NewRow.Document    = TransactionKey.Document;
		NewRow.Company     = TransactionKey.Company;
		NewRow.Branch      = TransactionKey.Branch;
		NewRow.Currency    = TransactionKey.Currency;
		NewRow.Agreement   = TransactionKey.Agreement;
		NewRow.Partner     = TransactionKey.Partner;
		NewRow.Invoice     = TransactionKey.TransactionBasis;
		NewRow.PaymentDate = QuerySelection.PaymentDate;
		NewRow.Amount      = CanWriteOff;
	EndDo;
EndProcedure

Procedure Write_TM1040T_AgingsKey(Parameters, Records_AgingsKey)
	RecordSet = AccumulationRegisters.TM1040T_AgingsKey.CreateRecordSet();
	RecordSet.DataExchange.Load = True;
	RecordSet.Filter.Recorder.Set(Parameters.Object.Ref);
	RecordSet.Load(Records_AgingsKey);
	RecordSet.SetActive(True);
	RecordSet.Write();
EndProcedure

Function FindRowKeyByAdvanceKey(AdvanceKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	MAX(T2014S_AdvancesInfo.Key) AS Key
	|FROM
	|	InformationRegister.T2014S_AdvancesInfo AS T2014S_AdvancesInfo
	|WHERE
	|	T2014S_AdvancesInfo.Company = &Company
	|	AND T2014S_AdvancesInfo.Branch = &Branch
	|	AND T2014S_AdvancesInfo.Currency = &Currency
	|	AND T2014S_AdvancesInfo.Date = &Date
	|	AND T2014S_AdvancesInfo.IsVendorAdvance
	|	AND T2014S_AdvancesInfo.LegalName = &LegalName
	|	AND T2014S_AdvancesInfo.Partner = &Partner
	|	AND T2014S_AdvancesInfo.Recorder = &Document
	|	AND CASE
	|		WHEN T2014S_AdvancesInfo.Order.ref IS NULL
	|			THEN VALUE(Document.PurchaseOrder.EmptyRef)
	|		ELSE T2014S_AdvancesInfo.Order
	|	END = &Order";
	Query.SetParameter("Company"   , AdvanceKey.Company);
	Query.SetParameter("Branch"    , AdvanceKey.Branch);
	Query.SetParameter("Currency"  , AdvanceKey.Currency);
	Query.SetParameter("Date"      , AdvanceKey.Date);
	Query.SetParameter("LegalName" , AdvanceKey.LegalName);
	Query.SetParameter("Partner"   , AdvanceKey.Partner);
	Query.SetParameter("Document"  , AdvanceKey.Document);
	Query.SetParameter("Order"     , ?(ValueIsFilled(AdvanceKey.Order)
		,AdvanceKey.Order, Documents.PurchaseOrder.EmptyRef()));
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return QuerySelection.Key;
	EndIf;
	Return "";
EndFunction

Function FindRowKeyByTransactionKey(TransactionKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	MAX(T2015S_TransactionsInfo.Key) AS Key
	|FROM
	|	InformationRegister.T2015S_TransactionsInfo AS T2015S_TransactionsInfo
	|WHERE
	|	T2015S_TransactionsInfo.Company = &Company
	|	AND T2015S_TransactionsInfo.Branch = &Branch
	|	AND T2015S_TransactionsInfo.Currency = &Currency
	|	AND T2015S_TransactionsInfo.Date = &Date
	|	AND T2015S_TransactionsInfo.IsVendorTransaction
	|	AND T2015S_TransactionsInfo.LegalName = &LegalName
	|	AND T2015S_TransactionsInfo.Partner = &Partner
	|	AND T2015S_TransactionsInfo.Agreement = &Agreement
	|	AND T2015S_TransactionsInfo.TransactionBasis = &TransactionBasis
	|	AND T2015S_TransactionsInfo.Recorder = &Document
	|	AND CASE
	|		WHEN T2015S_TransactionsInfo.Order.ref IS NULL
	|			THEN VALUE(Document.PurchaseOrder.EmptyRef)
	|		ELSE T2015S_TransactionsInfo.Order
	|	END = &Order";
	Query.SetParameter("Company"          , TransactionKey.Company);
	Query.SetParameter("Branch"           , TransactionKey.Branch);
	Query.SetParameter("Currency"         , TransactionKey.Currency);
	Query.SetParameter("Date"             , TransactionKey.Date);
	Query.SetParameter("LegalName"        , TransactionKey.LegalName);
	Query.SetParameter("Partner"          , TransactionKey.Partner);
	Query.SetParameter("Agreement"        , TransactionKey.Agreement);
	Query.SetParameter("TransactionBasis" , TransactionKey.TransactionBasis);
	Query.SetParameter("Document"         , TransactionKey.Document);
	Query.SetParameter("Order"            , ?(ValueIsFilled(TransactionKey.Order)
		,TransactionKey.Order, Documents.PurchaseOrder.EmptyRef()));
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	If QuerySelection.Next() Then
		Return QuerySelection.Key;
	EndIf;
	Return "";
Endfunction

Procedure CreateAdvancesKeys(Parameters, Records_AdvancesKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	T2014S_AdvancesInfo.Recorder AS Document,
	|	T2014S_AdvancesInfo.Company,
	|	T2014S_AdvancesInfo.Branch,
	|	T2014S_AdvancesInfo.Currency,
	|	T2014S_AdvancesInfo.Date,
	|	T2014S_AdvancesInfo.Partner,
	|	T2014S_AdvancesInfo.LegalName,
	|	T2014S_AdvancesInfo.Order,
	|	SUM(T2014S_AdvancesInfo.Amount) AS Amount
	|INTO tmp_AdvancesInfo
	|FROM
	|	InformationRegister.T2014S_AdvancesInfo AS T2014S_AdvancesInfo
	|WHERE
	|	T2014S_AdvancesInfo.Date BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
	|	AND T2014S_AdvancesInfo.Company = &Company
	|	AND T2014S_AdvancesInfo.Branch = &Branch
	|	AND T2014S_AdvancesInfo.IsVendorAdvance
	|GROUP BY
	|	T2014S_AdvancesInfo.Branch,
	|	T2014S_AdvancesInfo.Company,
	|	T2014S_AdvancesInfo.Currency,
	|	T2014S_AdvancesInfo.Date,
	|	T2014S_AdvancesInfo.LegalName,
	|	T2014S_AdvancesInfo.Order,
	|	T2014S_AdvancesInfo.Partner,
	|	T2014S_AdvancesInfo.Recorder
	|;
	|
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(AdvancesKeys.Ref) AS AdvanceKey,
	|	tmp_AdvancesInfo.Document,
	|	tmp_AdvancesInfo.Company,
	|	tmp_AdvancesInfo.Branch,
	|	tmp_AdvancesInfo.Currency,
	|	tmp_AdvancesInfo.Date,
	|	tmp_AdvancesInfo.Partner,
	|	tmp_AdvancesInfo.LegalName,
	|	tmp_AdvancesInfo.Order,
	|	SUM(tmp_AdvancesInfo.Amount) AS Amount,
	|	TRUE AS IsVendorAdvance
	|FROM
	|	tmp_AdvancesInfo AS tmp_AdvancesInfo
	|		LEFT JOIN Catalog.AdvancesKeys AS AdvancesKeys
	|		ON NOT AdvancesKeys.DeletionMark
	|		AND tmp_AdvancesInfo.Document = AdvancesKeys.Document
	|		AND tmp_AdvancesInfo.Company = AdvancesKeys.Company
	|		AND tmp_AdvancesInfo.Branch = AdvancesKeys.Branch
	|		AND tmp_AdvancesInfo.Currency = AdvancesKeys.Currency
	|		AND tmp_AdvancesInfo.Partner = AdvancesKeys.Partner
	|		AND tmp_AdvancesInfo.LegalName = AdvancesKeys.LegalName
	|		AND tmp_AdvancesInfo.Order = AdvancesKeys.Order
	|		AND AdvancesKeys.IsVendorAdvance
	|GROUP BY
	|	tmp_AdvancesInfo.Branch,
	|	tmp_AdvancesInfo.Company,
	|	tmp_AdvancesInfo.Currency,
	|	tmp_AdvancesInfo.Date,
	|	tmp_AdvancesInfo.Document,
	|	tmp_AdvancesInfo.LegalName,
	|	tmp_AdvancesInfo.Order,
	|	tmp_AdvancesInfo.Partner";
	Query.SetParameter("BeginOfPeriod", Parameters.Object.BeginOfPeriod);
	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company"      , Parameters.Object.Company);
	Query.SetParameter("Branch"       , Parameters.Object.Branch);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	While QuerySelection.Next() Do
		KeyRef = QuerySelection.AdvanceKey;
		If Not ValueIsFilled(KeyRef) Then // Create
			KeyObject = Catalogs.AdvancesKeys.CreateItem();
			FillPropertyValues(KeyObject, QuerySelection);
			KeyObject.Description = String(QuerySelection.Document);
			KeyObject.Write();
			KeyRef = KeyObject.Ref;
		ElsIf KeyRef.Date <> QuerySelection.Date Then // Update
			KeyObject = KeyRef.GetObject();
			KeyObject.Date = QuerySelection.Date;
			KeyObject.Description = String(QuerySelection.Document);
			KeyObject.Write();
		EndIf;
		
		NewRow = Records_AdvancesKey.Add();
		NewRow.RecordType = AccumulationRecordType.Receipt;
		NewRow.Period     = QuerySelection.Date;
		NewRow.AdvanceKey = KeyRef;
		NewRow.Amount     = QuerySelection.Amount;
	EndDo;
EndProcedure

Procedure Write_TM1020B_AdvancesKey(Parameters, Records_AdvancesKey)
	RecordSet = AccumulationRegisters.TM1020B_AdvancesKey.CreateRecordSet();
	RecordSet.DataExchange.Load = True;
	RecordSet.Filter.Recorder.Set(Parameters.Object.Ref);
	RecordSet.Load(Records_AdvancesKey);
	RecordSet.SetActive(True);
	RecordSet.Write();
EndProcedure

Procedure CreateTransactionsKeys(Parameters, Records_TransactionsKey)
	Query = New Query();
	Query.Text = 
	"SELECT
	|	T2015S_TransactionsInfo.Recorder AS Document,
	|	T2015S_TransactionsInfo.Company,
	|	T2015S_TransactionsInfo.Branch,
	|	T2015S_TransactionsInfo.Currency,
	|	T2015S_TransactionsInfo.Date,
	|	T2015S_TransactionsInfo.Partner,
	|	T2015S_TransactionsInfo.LegalName,
	|	T2015S_TransactionsInfo.Agreement,
	|	T2015S_TransactionsInfo.Order,
	|	T2015S_TransactionsInfo.TransactionBasis,
	|	SUM(T2015S_TransactionsInfo.Amount) AS Amount,
	|	MAX(T2015S_TransactionsInfo.IsDue) AS IsDue,
	|	MAX(T2015S_TransactionsInfo.IsPaid) AS IsPaid
	|INTO tmp_TransactionsInfo
	|FROM
	|	InformationRegister.T2015S_TransactionsInfo AS T2015S_TransactionsInfo
	|WHERE
	|	T2015S_TransactionsInfo.Date BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
	|	AND T2015S_TransactionsInfo.Company = &Company
	|	AND T2015S_TransactionsInfo.Branch = &Branch
	|	AND T2015S_TransactionsInfo.IsVendorTransaction
	|GROUP BY
	|	T2015S_TransactionsInfo.Branch,
	|	T2015S_TransactionsInfo.Company,
	|	T2015S_TransactionsInfo.Currency,
	|	T2015S_TransactionsInfo.Date,
	|	T2015S_TransactionsInfo.LegalName,
	|	T2015S_TransactionsInfo.Agreement,
	|	T2015S_TransactionsInfo.Order,
	|	T2015S_TransactionsInfo.TransactionBasis,
	|	T2015S_TransactionsInfo.Partner,
	|	T2015S_TransactionsInfo.Recorder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	MAX(TransactionsKeys.Ref) AS TransactionKey,
	|	tmp_TransactionsInfo.Document,
	|	tmp_TransactionsInfo.Company,
	|	tmp_TransactionsInfo.Branch,
	|	tmp_TransactionsInfo.Currency,
	|	tmp_TransactionsInfo.Date,
	|	tmp_TransactionsInfo.Partner,
	|	tmp_TransactionsInfo.LegalName,
	|	tmp_TransactionsInfo.Agreement,
	|	tmp_TransactionsInfo.Order,
	|	tmp_TransactionsInfo.TransactionBasis,
	|	SUM(tmp_TransactionsInfo.Amount) AS Amount,
	|	MAX(tmp_TransactionsInfo.IsDue) AS IsDue,
	|	MAX(tmp_TransactionsInfo.IsPaid) AS IsPaid,
	|	TRUE AS IsVendorTransaction
	|FROM
	|	tmp_TransactionsInfo AS tmp_TransactionsInfo
	|		LEFT JOIN Catalog.TransactionsKeys AS TransactionsKeys
	|		ON NOT TransactionsKeys.DeletionMark
	|		AND tmp_TransactionsInfo.Document = TransactionsKeys.Document
	|		AND tmp_TransactionsInfo.Company = TransactionsKeys.Company
	|		AND tmp_TransactionsInfo.Branch = TransactionsKeys.Branch
	|		AND tmp_TransactionsInfo.Currency = TransactionsKeys.Currency
	|		AND tmp_TransactionsInfo.Partner = TransactionsKeys.Partner
	|		AND tmp_TransactionsInfo.LegalName = TransactionsKeys.LegalName
	|		AND tmp_TransactionsInfo.Agreement = TransactionsKeys.Agreement
	|		AND tmp_TransactionsInfo.Order = TransactionsKeys.Order
	|		AND tmp_TransactionsInfo.TransactionBasis = TransactionsKeys.TransactionBasis
	|		AND TransactionsKeys.IsVendorTransaction
	|GROUP BY
	|	tmp_TransactionsInfo.Branch,
	|	tmp_TransactionsInfo.Company,
	|	tmp_TransactionsInfo.Currency,
	|	tmp_TransactionsInfo.Date,
	|	tmp_TransactionsInfo.Document,
	|	tmp_TransactionsInfo.LegalName,
	|	tmp_TransactionsInfo.Agreement,
	|	tmp_TransactionsInfo.Order,
	|	tmp_TransactionsInfo.TransactionBasis,
	|	tmp_TransactionsInfo.Partner";
	Query.SetParameter("BeginOfPeriod", Parameters.Object.BeginOfPeriod);
	Query.SetParameter("EndOfPeriod"  , Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company"      , Parameters.Object.Company);
	Query.SetParameter("Branch"       , Parameters.Object.Branch);
	
	QueryResult = Query.Execute();
	QuerySelection = QueryResult.Select();
	
	
	While QuerySelection.Next() Do
		KeyRef = QuerySelection.TransactionKey;
		If Not ValueIsFilled(KeyRef) Then // Create
			KeyObject = Catalogs.TransactionsKeys.CreateItem();
			FillPropertyValues(KeyObject, QuerySelection);
			KeyObject.Description = String(QuerySelection.Document);
			KeyObject.Write();
			KeyRef = KeyObject.Ref;
		ElsIf KeyRef.Date <> QuerySelection.Date Then // Update
			KeyObject = KeyRef.GetObject();
			KeyObject.Date = QuerySelection.Date;
			KeyObject.Description = String(QuerySelection.Document);
			KeyObject.Write();
		EndIf;
		
		NewRow = Records_TransactionsKey.Add();
		If QuerySelection.IsDue Then
			NewRow.RecordType = AccumulationRecordType.Receipt;
		ElsIf QuerySelection.IsPaid Then
			NewRow.RecordType = AccumulationRecordType.Expense;
		EndIf;
		
		NewRow.Period         = QuerySelection.Date;
		NewRow.TransactionKey = KeyRef;
		NewRow.Amount         = QuerySelection.Amount;
	EndDo;
EndProcedure

Procedure Write_TM1030B_TransactionsKey(Parameters, Records_TransactionsKey)
	RecordSet = AccumulationRegisters.TM1030B_TransactionsKey.CreateRecordSet();
	RecordSet.DataExchange.Load = True;
	RecordSet.Filter.Recorder.Set(Parameters.Object.Ref);
	RecordSet.Load(Records_TransactionsKey);
	RecordSet.SetActive(True);
	RecordSet.Write();
EndProcedure

Procedure Write_SelfRecords(Parameters, Records_OffsetInfo, Records_OffsetAging)
	// R5012B_VendorsAging
	Recorders = Records_OffsetAging.Copy();
	Recorders.GroupBy("Document");
	
	For Each Row In Recorders Do
		RecordSet_Aging = AccumulationRegisters.R5012B_VendorsAging.CreateRecordSet();
		RecordSet_Aging.Filter.Recorder.Set(Row.Document);
		TableAging =RecordSet_Aging.UnloadColumns();
		TableAging.Columns.Delete(TableAging.Columns.PointInTime);
		
		OffsetInfoByDocument = Records_OffsetAging.Copy(New Structure("Document", Row.Document));
		
		For Each RowOffset In OffsetInfoByDocument Do
			// Aging
			NewRow_Aging = TableAging.Add();
			FillPropertyValues(NewRow_Aging, RowOffset);
			NewRow_Aging.RecordType = AccumulationRecordType.Expense;
			NewRow_Aging.AgingClosing = Parameters.Object.Ref;
		EndDo;
		
		RecordSet_Aging.Load(TableAging);
		RecordSet_Aging.SetActive(True);
		RecordSet_Aging.Write();
	EndDo;
	
	// R1020B_AdvancesToVendors, R1021B_VendorsTransactions
	Recorders = Records_OffsetInfo.Copy();
	Recorders.GroupBy("Document");
	
	For Each Row In Recorders Do
		RecordSet_AdvancesToVendors = AccumulationRegisters.R1020B_AdvancesToVendors.CreateRecordSet();
		RecordSet_AdvancesToVendors.Filter.Recorder.Set(Row.Document);
		TableAdvances = RecordSet_AdvancesToVendors.UnloadColumns();
		TableAdvances.Columns.Delete(TableAdvances.Columns.PointInTime);
	
		RecordSet_VendorsTransactions = AccumulationRegisters.R1021B_VendorsTransactions.CreateRecordSet();
		RecordSet_VendorsTransactions.Filter.Recorder.Set(Row.Document);
		TableTransactions = RecordSet_VendorsTransactions.UnloadColumns();
		TableTransactions.Columns.Delete(TableTransactions.Columns.PointInTime);
		
		OffsetInfoByDocument = Records_OffsetInfo.Copy(New Structure("Document", Row.Document));
		
		AdvancesColumnKeyExists = False;
		For Each RowOffset In OffsetInfoByDocument Do
			If ValueIsFilled(RowOffset.AdvancesRowKey) Then
				TableAdvances.Columns.Add("Key", Metadata.DefinedTypes.typeRowID.Type);
				AdvancesColumnKeyExists = True;
				Break;
			EndIf;
		EndDo;
		
		TransactionsColumnKeyExists = False;
		For Each RowOffset In OffsetInfoByDocument Do
			If ValueIsFilled(RowOffset.TransactionsRowKey) Then
				TableTransactions.Columns.Add("Key", Metadata.DefinedTypes.typeRowID.Type);
				TransactionsColumnKeyExists = True;
				Break;
			EndIf;
		EndDo;
		
		OffsetInfoByDocument = Records_OffsetInfo.Copy(New Structure("Document", Row.Document));
	
		For Each RowOffset In OffsetInfoByDocument Do
			// Advances
			NewRow_Advances = TableAdvances.Add();
			FillPropertyValues(NewRow_Advances, RowOffset);
			NewRow_Advances.RecordType = AccumulationRecordType.Expense;
			NewRow_Advances.Basis = RowOffset.AdvancesDocument;
			NewRow_Advances.VendorsAdvancesClosing = Parameters.Object.Ref;
			If AdvancesColumnKeyExists Then
				NewRow_Advances.Key = RowOffset.AdvancesRowKey;
			EndIf;
			
			// Transactions
			NewRow_Transactions = TableTransactions.Add();
			FillPropertyValues(NewRow_Transactions, RowOffset);
			NewRow_Transactions.RecordType = AccumulationRecordType.Expense;
			NewRow_Transactions.Basis = RowOffset.TransactionDocument;
			NewRow_Transactions.VendorsAdvancesClosing = Parameters.Object.Ref;
			If TransactionsColumnKeyExists Then
				NewRow_Transactions.Key = RowOffset.TransactionsRowKey;
			EndIf;
		EndDo;
	
		// Currency calculation
		CurrenciesParameters = New Structure();

		PostingDataTables = New Map();

		PostingDataTables.Insert(RecordSet_AdvancesToVendors, New Structure("RecordSet", TableAdvances));
		PostingDataTables.Insert(RecordSet_VendorsTransactions, New Structure("RecordSet", TableTransactions));
		ArrayOfPostingInfo = New Array();
		For Each DataTable In PostingDataTables Do
			ArrayOfPostingInfo.Add(DataTable);
		EndDo;
		CurrenciesParameters.Insert("Object", Row.Document);
		CurrenciesParameters.Insert("ArrayOfPostingInfo", ArrayOfPostingInfo);
		CurrenciesServer.PreparePostingDataTables(CurrenciesParameters, Undefined);

		For Each ItemOfPostingInfo In ArrayOfPostingInfo Do
			// Advances
			If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1020B_AdvancesToVendors") Then
				RecordSet_AdvancesToVendors.Read();
				For Each RowPostingInfo In ItemOfPostingInfo.Value.RecordSet Do
					FillPropertyValues(RecordSet_AdvancesToVendors.Add(), RowPostingInfo);
				EndDo;
				RecordSet_AdvancesToVendors.SetActive(True);
				RecordSet_AdvancesToVendors.Write();
			EndIf;
			
			// Transactions
			If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1021B_VendorsTransactions") Then
				RecordSet_VendorsTransactions.Read();
				For Each RowPostingInfo In ItemOfPostingInfo.Value.RecordSet Do
					FillPropertyValues(RecordSet_VendorsTransactions.Add(), RowPostingInfo);
				EndDo;
				RecordSet_VendorsTransactions.SetActive(True);
				RecordSet_VendorsTransactions.Write();
			EndIf;
		EndDo;
	EndDo;
EndProcedure

Procedure Clear_SelfRecords(Parameters)
	Query = New Query();
	Query.Text =
	"SELECT
	|	R1020B_AdvancesToVendors.Recorder
	|FROM
	|	AccumulationRegister.R1020B_AdvancesToVendors AS R1020B_AdvancesToVendors
	|WHERE
	|	R1020B_AdvancesToVendors.VendorsAdvancesClosing = &Ref
	|GROUP BY
	|	R1020B_AdvancesToVendors.Recorder
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	R1021B_VendorsTransactions.Recorder
	|FROM
	|	AccumulationRegister.R1021B_VendorsTransactions AS R1021B_VendorsTransactions
	|WHERE
	|	R1021B_VendorsTransactions.VendorsAdvancesClosing = &Ref
	|GROUP BY
	|	R1021B_VendorsTransactions.Recorder
	|;
	|
	|///////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	R5012B_VendorsAging.Recorder
	|FROM
	|	AccumulationRegister.R5012B_VendorsAging AS R5012B_VendorsAging
	|WHERE
	|	R5012B_VendorsAging.AgingClosing = &Ref
	|GROUP BY
	|	R5012B_VendorsAging.Recorder";
	
	Ref = Parameters.Object.Ref;
	Query.SetParameter("Ref", Ref);
	QueryResults = Query.ExecuteBatch();

	For Each Row In QueryResults[0].Unload() Do
		RecordSet = AccumulationRegisters.R1020B_AdvancesToVendors.CreateRecordSet();
		RecordSet.Filter.Recorder.Set(Row.Recorder);
		RecordSet.Read();
		ArrayForDelete = New Array();
		For Each Record In RecordSet Do
			If Record.VendorsAdvancesClosing = Ref Then
				ArrayForDelete.Add(Record);
			EndIf;
		EndDo;
		For Each ItemForDelete In ArrayForDelete Do
			RecordSet.Delete(ItemForDelete);
		EndDo;
		RecordSet.Write();
	EndDo;

	For Each Row In QueryResults[1].Unload() Do
		RecordSet = AccumulationRegisters.R1021B_VendorsTransactions.CreateRecordSet();
		RecordSet.Filter.Recorder.Set(Row.Recorder);
		RecordSet.Read();
		ArrayForDelete = New Array();
		For Each Record In RecordSet Do
			If Record.VendorsAdvancesClosing = Ref Then
				ArrayForDelete.Add(Record);
			EndIf;
		EndDo;
		For Each ItemForDelete In ArrayForDelete Do
			RecordSet.Delete(ItemForDelete);
		EndDo;
		RecordSet.Write();
	EndDo;

	For Each Row In QueryResults[2].Unload() Do
		RecordSet = AccumulationRegisters.R5012B_VendorsAging.CreateRecordSet();
		RecordSet.Filter.Recorder.Set(Row.Recorder);
		RecordSet.Read();
		ArrayForDelete = New Array();
		For Each Record In RecordSet Do
			If Record.AgingClosing = Ref Then
				ArrayForDelete.Add(Record);
			EndIf;
		EndDo;
		For Each ItemForDelete In ArrayForDelete Do
			RecordSet.Delete(ItemForDelete);
		EndDo;
		RecordSet.Write();
	EndDo;
EndProcedure

#EndRegion


Function OffsetOfAdvances(Parameters)
	If Parameters = Undefined Then
		Return VendorsAdvancesClosingQueryText();
	EndIf;

	//ClearSelfRecords(Parameters.Object.Ref);

	If Parameters.Property("Unposting") And Parameters.Unposting Then
		Return VendorsAdvancesClosingQueryText();
	EndIf;

	OffsetOfAdvanceFull = InformationRegisters.T2010S_OffsetOfAdvances.CreateRecordSet().UnloadColumns();
	OffsetOfAdvanceFull.Columns.Delete(OffsetOfAdvanceFull.Columns.PointInTime);

	OffsetOfAgingFull = InformationRegisters.T2013S_OffsetOfAging.CreateRecordSet().UnloadColumns();
	OffsetOfAgingFull.Columns.Delete(OffsetOfAgingFull.Columns.PointInTime);
	
	// VendorsTransactions
	Query = New Query();
	Query.Text =
	"SELECT
	|	PartnerAdvances.Recorder AS Recorder,
	|	PartnerAdvances.Recorder.Date AS RecorderDate,
	|	FALSE AS IsVendorTransaction,
	|	TRUE AS IsVendorAdvanceOrPayment
	|INTO tmpPartnerAdvancesOrPayments
	|FROM
	|	InformationRegister.T2012S_PartnerAdvances AS PartnerAdvances
	|WHERE
	|	PartnerAdvances.Period BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
	|	AND PartnerAdvances.IsVendorAdvance
	|	AND PartnerAdvances.Company = &Company
	|	AND PartnerAdvances.Branch = &Branch
	|GROUP BY
	|	PartnerAdvances.Recorder,
	|	PartnerAdvances.Recorder.Date
	|
	|UNION ALL
	|
	|SELECT
	|	PartnerTransactions.Recorder,
	|	PartnerTransactions.Recorder.Date,
	|	FALSE,
	|	TRUE
	|FROM
	|	InformationRegister.T2011S_PartnerTransactions AS PartnerTransactions
	|WHERE
	|	PartnerTransactions.Period BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
	|	AND PartnerTransactions.IsPaymentToVendor
	|	AND PartnerTransactions.Company = &Company
	|	AND PartnerTransactions.Branch = &Branch
	|;
	|
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	PartnerTransactions.Recorder AS Recorder,
	|	PartnerTransactions.Recorder.Date AS RecorderDate,
	|	TRUE AS IsVendorTransaction,
	|	FALSE AS IsVendorAdvanceOrPayment
	|INTO tmp
	|FROM
	|	InformationRegister.T2011S_PartnerTransactions AS PartnerTransactions
	|WHERE
	|	PartnerTransactions.Period BETWEEN BEGINOFPERIOD(&BeginOfPeriod, DAY) AND ENDOFPERIOD(&EndOfPeriod, DAY)
	|	AND PartnerTransactions.IsVendorTransaction
	|	AND PartnerTransactions.Company = &Company
	|	AND PartnerTransactions.Branch = &Branch
	|
	|UNION ALL
	|
	|SELECT
	|	tmpPartnerAdvancesOrPayments.Recorder,
	|	tmpPartnerAdvancesOrPayments.RecorderDate,
	|	tmpPartnerAdvancesOrPayments.IsVendorTransaction,
	|	tmpPartnerAdvancesOrPayments.IsVendorAdvanceOrPayment
	|FROM
	|	tmpPartnerAdvancesOrPayments AS tmpPartnerAdvancesOrPayments
	|;
	|
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmp.Recorder,
	|	tmp.IsVendorTransaction,
	|	tmp.IsVendorAdvanceOrPayment
	|FROM
	|	tmp AS tmp
	|GROUP BY
	|	tmp.Recorder,
	|	tmp.IsVendorTransaction,
	|	tmp.IsVendorAdvanceOrPayment,
	|	tmp.RecorderDate
	|ORDER BY
	|	tmp.RecorderDate";
	Query.SetParameter("BeginOfPeriod", Parameters.Object.BeginOfPeriod);
	Query.SetParameter("EndOfPeriod", Parameters.Object.EndOfPeriod);
	Query.SetParameter("Company", Parameters.Object.Company);
	Query.SetParameter("Branch", Parameters.Object.Branch);

	QueryTable = Query.Execute().Unload();
	For Each Row In QueryTable Do
		Parameters.Insert("RecorderPointInTime", Row.Recorder.PointInTime());
		If Row.IsVendorTransaction Then
			Create_VendorsTransactions(Row.Recorder, Parameters);
			Create_VendorsAging(Row.Recorder, Parameters);
			OffsetOfPartnersServer.Vendors_OnTransaction(Parameters);

			UseKeyForAdvance = False;
			If OffsetOfPartnersServer.IsDebitCreditNote(Row.Recorder) Then
				UseKeyForAdvance = True;
			EndIf;

			Write_AdvancesAndTransactions(Row.Recorder, Parameters, OffsetOfAdvanceFull, UseKeyForAdvance);
			Write_PartnersAging(Row.Recorder, Parameters, OffsetOfAgingFull);
			Drop_Table(Parameters, "VendorsTransactions");
			Drop_Table(Parameters, "Aging");

			Drop_Table(Parameters, "OffsetOfAdvanceToVendors");
			Drop_Table(Parameters, "OffsetOfAging");
		EndIf;

		If Row.IsVendorAdvanceOrPayment Then
			Create_AdvancesToVendors(Row.Recorder, Parameters);
			Create_PaymentToVendors(Row.Recorder, Parameters);
			OffsetOfPartnersServer.Vendors_OnMoneyMovements(Parameters);

			UseKeyForAdvance = True;
			If OffsetOfPartnersServer.IsReturn(Row.Recorder) Then
				UseKeyForAdvance = False;
			EndIf;

			Write_AdvancesAndTransactions(Row.Recorder, Parameters, OffsetOfAdvanceFull, UseKeyForAdvance);
			Write_PartnersAging(Row.Recorder, Parameters, OffsetOfAgingFull);
			
			// Due as advance
			If CommonFunctionsClientServer.ObjectHasProperty(Row.Recorder, "DueAsAdvance")
				And Row.Recorder.DueAsAdvance Then
				OffsetOfPartnersServer.Vendors_DueAsAdvance(Parameters);
				Write_AdvancesAndTransactions_DueAsAdvance(Row.Recorder, Parameters, OffsetOfAdvanceFull);
				Drop_Table(Parameters, "Transactions");
				Drop_Table(Parameters, "TransactionsBalance");
				Drop_Table(Parameters, "DueAsAdvanceToVendors");
			EndIf;

			Drop_Table(Parameters, "VendorsTransactions");
			Drop_Table(Parameters, "AdvancesToVendors");

			Drop_Table(Parameters, "OffsetOfAdvanceToVendors");
			Drop_Table(Parameters, "OffsetOfAging");
		EndIf;
	EndDo;

	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	OffsetOfAdvanceFull.Period,
	|	OffsetOfAdvanceFull.Document,
	|	OffsetOfAdvanceFull.Company,
	|	OffsetOfAdvanceFull.Branch,
	|	OffsetOfAdvanceFull.Currency,
	|	OffsetOfAdvanceFull.Partner,
	|	OffsetOfAdvanceFull.LegalName,
	|	OffsetOfAdvanceFull.TransactionDocument,
	|	OffsetOfAdvanceFull.AdvancesDocument,
	|	OffsetOfAdvanceFull.Agreement,
	|	OffsetOfAdvanceFull.Key,
	|	OffsetOfAdvanceFull.Amount,
	|	OffsetOfAdvanceFull.DueAsAdvance
	|INTO tmpOffsetOfAdvances
	|FROM
	|	&OffsetOfAdvanceFull AS OffsetOfAdvanceFull
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	OffsetOfAgingFull.Period,
	|	OffsetOfAgingFull.Document,
	|	OffsetOfAgingFull.Company,
	|	OffsetOfAgingFull.Branch,
	|	OffsetOfAgingFull.Currency,
	|	OffsetOfAgingFull.Partner,
	|	OffsetOfAgingFull.Agreement,
	|	OffsetOfAgingFull.Invoice,
	|	OffsetOfAgingFull.PaymentDate,
	|	OffsetOfAgingFull.Amount
	|INTO tmpOffsetOfAging
	|FROM
	|	&OffsetOfAgingFull AS OffsetOfAgingFull
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpOffsetOfAdvances.Period,
	|	tmpOffsetOfAdvances.Document,
	|	tmpOffsetOfAdvances.Company,
	|	tmpOffsetOfAdvances.Branch,
	|	tmpOffsetOfAdvances.Currency,
	|	tmpOffsetOfAdvances.Partner,
	|	tmpOffsetOfAdvances.LegalName,
	|	tmpOffsetOfAdvances.TransactionDocument,
	|	tmpOffsetOfAdvances.AdvancesDocument,
	|	tmpOffsetOfAdvances.Agreement,
	|	tmpOffsetOfAdvances.Key,
	|	tmpOffsetOfAdvances.DueAsAdvance,
	|	SUM(tmpOffsetOfAdvances.Amount) AS Amount
	|INTO OffsetOfAdvances
	|FROM
	|	tmpOffsetOfAdvances AS tmpOffsetOfAdvances
	|GROUP BY
	|	tmpOffsetOfAdvances.Period,
	|	tmpOffsetOfAdvances.Document,
	|	tmpOffsetOfAdvances.Company,
	|	tmpOffsetOfAdvances.Branch,
	|	tmpOffsetOfAdvances.Currency,
	|	tmpOffsetOfAdvances.Partner,
	|	tmpOffsetOfAdvances.LegalName,
	|	tmpOffsetOfAdvances.TransactionDocument,
	|	tmpOffsetOfAdvances.AdvancesDocument,
	|	tmpOffsetOfAdvances.Agreement,
	|	tmpOffsetOfAdvances.Key,
	|	tmpOffsetOfAdvances.DueAsAdvance
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpOffsetOfAging.Period,
	|	tmpOffsetOfAging.Document,
	|	tmpOffsetOfAging.Company,
	|	tmpOffsetOfAging.Branch,
	|	tmpOffsetOfAging.Currency,
	|	tmpOffsetOfAging.Partner,
	|	tmpOffsetOfAging.Agreement,
	|	tmpOffsetOfAging.Invoice,
	|	tmpOffsetOfAging.PaymentDate,
	|	SUM(tmpOffsetOfAging.Amount) AS Amount
	|INTO OffsetOfAging
	|FROM
	|	tmpOffsetOfAging AS tmpOffsetOfAging
	|GROUP BY
	|	tmpOffsetOfAging.Period,
	|	tmpOffsetOfAging.Document,
	|	tmpOffsetOfAging.Company,
	|	tmpOffsetOfAging.Branch,
	|	tmpOffsetOfAging.Currency,
	|	tmpOffsetOfAging.Partner,
	|	tmpOffsetOfAging.Agreement,
	|	tmpOffsetOfAging.Invoice,
	|	tmpOffsetOfAging.PaymentDate";

	Query.SetParameter("OffsetOfAdvanceFull", OffsetOfAdvanceFull);
	Query.SetParameter("OffsetOfAgingFull", OffsetOfAgingFull);

	Query.Execute();

	Return VendorsAdvancesClosingQueryText();
EndFunction

Function VendorsAdvancesClosingQueryText()
	Return "SELECT *
		   |INTO OffsetOfAdvancesEmpty
		   |FROM
		   |	Document.VendorsAdvancesClosing AS OffsetOfAdvance
		   |WHERE
		   |	FALSE";
EndFunction


// VendorsTransactions
//	*Period
//	*Company
//	*Currency
//	*Partner
//	*LegalName
//	*TransactionDocument
//	*Agreement
//	*DocumentAmount
//	*Key
Procedure Create_VendorsTransactions(Recorder, Parameters)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	PartnerTransactions.Period,
	|	PartnerTransactions.Company,
	|	PartnerTransactions.Branch,
	|	PartnerTransactions.Currency,
	|	PartnerTransactions.Partner,
	|	PartnerTransactions.LegalName,
	|	PartnerTransactions.TransactionDocument,
	|	PartnerTransactions.Agreement,
	|	SUM(PartnerTransactions.Amount) AS DocumentAmount,
	|	CASE
	|		WHEN &IsDebitCreditNote
	|			THEN PartnerTransactions.Key
	|		ELSE """"
	|	END AS Key
	|INTO tmpVendorsTransactions
	|FROM
	|	InformationRegister.T2011S_PartnerTransactions AS PartnerTransactions
	|WHERE
	|	PartnerTransactions.Recorder = &Recorder
	|	AND PartnerTransactions.IsVendorTransaction
	|GROUP BY
	|	PartnerTransactions.Agreement,
	|	PartnerTransactions.Company,
	|	PartnerTransactions.Branch,
	|	PartnerTransactions.Currency,
	|	PartnerTransactions.LegalName,
	|	PartnerTransactions.Partner,
	|	PartnerTransactions.Period,
	|	PartnerTransactions.TransactionDocument,
	|	CASE
	|		WHEN &IsDebitCreditNote
	|			THEN PartnerTransactions.Key
	|		ELSE """"
	|	END
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	tmpVendorsTransactions.Period,
	|	tmpVendorsTransactions.Company,
	|	tmpVendorsTransactions.Branch,
	|	tmpVendorsTransactions.Currency,
	|	tmpVendorsTransactions.Partner,
	|	tmpVendorsTransactions.LegalName,
	|	tmpVendorsTransactions.Agreement,
	|	tmpVendorsTransactions.TransactionDocument,
	|	tmpVendorsTransactions.Key,
	|	R1021B_VendorsTransactionsBalance.AmountBalance AS DocumentAmount,
	|	FALSE AS IgnoreAdvances
	|	INTO VendorsTransactions
	|FROM
	|	AccumulationRegister.R1021B_VendorsTransactions.Balance(&Period, (Company, Branch, Currency, LegalName, Partner, Agreement,
	|		Basis) IN
	|		(SELECT
	|			tmp.Company,
	|			tmp.Branch,
	|			tmp.Currency,
	|			tmp.LegalName,
	|			tmp.Partner,
	|			tmp.Agreement,
	|			tmp.TransactionDocument
	|		FROM
	|			tmpVendorsTransactions AS tmp)
	|	AND CurrencyMovementType = VALUE(ChartOfCharacteristicTypes.CurrencyMovementType.SettlementCurrency)) AS
	|		R1021B_VendorsTransactionsBalance
	|		LEFT JOIN tmpVendorsTransactions AS tmpVendorsTransactions
	|		ON R1021B_VendorsTransactionsBalance.Company = tmpVendorsTransactions.Company
	|		AND R1021B_VendorsTransactionsBalance.Branch = tmpVendorsTransactions.Branch
	|		AND R1021B_VendorsTransactionsBalance.Currency = tmpVendorsTransactions.Currency
	|		AND R1021B_VendorsTransactionsBalance.Partner = tmpVendorsTransactions.Partner
	|		AND R1021B_VendorsTransactionsBalance.LegalName = tmpVendorsTransactions.LegalName
	|		AND R1021B_VendorsTransactionsBalance.Agreement = tmpVendorsTransactions.Agreement
	|		AND R1021B_VendorsTransactionsBalance.Basis = tmpVendorsTransactions.TransactionDocument
	|;
	|DROP tmpVendorsTransactions";
	Query.SetParameter("Period", New Boundary(Parameters.RecorderPointInTime, BoundaryType.Including));
	Query.SetParameter("Recorder", Recorder);
	Query.SetParameter("IsDebitCreditNote", OffsetOfPartnersServer.IsDebitCreditNote(Recorder));
	Query.Execute();
EndProcedure

// Aging
//  *Period
//  *Company
//  *Currency
//  *Partner
//  *Invoice
//  *PaymentDate
//  *Agreement
//  *Amount
Procedure Create_VendorsAging(Recorder, Parameters)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	R5012B_VendorsAging.Period,
	|	R5012B_VendorsAging.Company,
	|	R5012B_VendorsAging.Branch,
	|	R5012B_VendorsAging.Currency,
	|	R5012B_VendorsAging.Partner,
	|	R5012B_VendorsAging.Invoice,
	|	R5012B_VendorsAging.PaymentDate,
	|	R5012B_VendorsAging.Agreement,
	|	R5012B_VendorsAging.Amount
	|INTO Aging
	|FROM
	|	AccumulationRegister.R5012B_VendorsAging AS R5012B_VendorsAging
	|WHERE
	|	R5012B_VendorsAging.RecordType = VALUE(AccumulationRecordType.Receipt)
	|	AND R5012B_VendorsAging.Recorder = &Recorder";
	Query.SetParameter("Recorder", Recorder);
	Query.Execute();
EndProcedure

Procedure Create_PaymentToVendors(Recorder, Parameters)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	PartnerTransactions.Period,
	|	PartnerTransactions.Company,
	|	PartnerTransactions.Branch,
	|	PartnerTransactions.Currency,
	|	PartnerTransactions.Partner,
	|	PartnerTransactions.LegalName,
	|	PartnerTransactions.TransactionDocument,
	|	PartnerTransactions.Agreement,
	|	SUM(PartnerTransactions.Amount) AS Amount,
	|	FALSE AS IgnoreAdvances,
	|	PartnerTransactions.Key
	|INTO VendorsTransactions
	|FROM
	|	InformationRegister.T2011S_PartnerTransactions AS PartnerTransactions
	|WHERE
	|	PartnerTransactions.Recorder = &Recorder
	|	and PartnerTransactions.IsPaymentToVendor
	|GROUP BY
	|	PartnerTransactions.Agreement,
	|	PartnerTransactions.Company,
	|	PartnerTransactions.Branch,
	|	PartnerTransactions.Currency,
	|	PartnerTransactions.LegalName,
	|	PartnerTransactions.Partner,
	|	PartnerTransactions.Period,
	|	PartnerTransactions.TransactionDocument,
	|	PartnerTransactions.Key";
	Query.SetParameter("Recorder", Recorder);
	Query.Execute();
EndProcedure

// AdvancesToVendors
//  *Period
//  *Company
//  *Partner
//  *LegalName
//  *Currency
//  *DocumentAmount
//  *AdvancesDocument
//  *Key
Procedure Create_AdvancesToVendors(Recorder, Parameters)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	PartnerAdvances.Period,
	|	PartnerAdvances.Company,
	|	PartnerAdvances.Branch,
	|	PartnerAdvances.Currency,
	|	PartnerAdvances.Partner,
	|	PartnerAdvances.LegalName,
	|	PartnerAdvances.AdvancesDocument,
	|	PartnerAdvances.Amount AS DocumentAmount,
	|	PartnerAdvances.Key
	|INTO AdvancesToVendors
	|FROM
	|	InformationRegister.T2012S_PartnerAdvances AS PartnerAdvances
	|WHERE
	|	PartnerAdvances.Recorder = &Recorder";
	Query.SetParameter("Recorder", Recorder);
	Query.Execute();
EndProcedure

Procedure Drop_Table(Parameters, TableName)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text = "DROP " + TableName;
	Query.Execute();
EndProcedure

// DueAsAdvanceToVendors
//  *Period
//  *Company
//  *Partner
//  *LegalName
//  *Agreement
//  *Currency
//  *TransactionDocument
//  *AdvancesDocument
//  *Key
//  *Amount
Procedure Write_AdvancesAndTransactions_DueAsAdvance(Recorder, Parameters, OffsetOfAdvanceFull)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	DueAsAdvanceToVendors.Period,
	|	DueAsAdvanceToVendors.Company,
	|	DueAsAdvanceToVendors.Branch,
	|	DueAsAdvanceToVendors.Partner,
	|	DueAsAdvanceToVendors.LegalName,
	|	DueAsAdvanceToVendors.Agreement,
	|	DueAsAdvanceToVendors.Currency,
	|	DueAsAdvanceToVendors.TransactionDocument,
	|	DueAsAdvanceToVendors.AdvancesDocument,
	|	DueAsAdvanceToVendors.Key,
	|	DueAsAdvanceToVendors.Amount,
	|	&VendorsAdvancesClosing AS VendorsAdvancesClosing,
	|	&Document AS Document,
	|	&Document AS Recorder,
	|	TRUE AS DueAsAdvance
	|FROM
	|	DueAsAdvanceToVendors AS DueAsAdvanceToVendors";
	Query.SetParameter("VendorsAdvancesClosing", Parameters.Object.Ref);
	Query.SetParameter("Document", Recorder);

	QueryTable = Query.Execute().Unload();

	RecordSet_AdvancesToVendors = AccumulationRegisters.R1020B_AdvancesToVendors.CreateRecordSet();
	RecordSet_AdvancesToVendors.Filter.Recorder.Set(Recorder);
	TableAdvances = RecordSet_AdvancesToVendors.UnloadColumns();
	TableAdvances.Columns.Delete(TableAdvances.Columns.PointInTime);
	RecordSet_VendorsTransactions = AccumulationRegisters.R1021B_VendorsTransactions.CreateRecordSet();
	RecordSet_VendorsTransactions.Filter.Recorder.Set(Recorder);
	TableTransactions = RecordSet_VendorsTransactions.UnloadColumns();
	TableTransactions.Columns.Delete(TableTransactions.Columns.PointInTime);

	For Each Row In QueryTable Do

		FillPropertyValues(OffsetOfAdvanceFull.Add(), Row);

		NewRow_Advances = TableAdvances.Add();
		FillPropertyValues(NewRow_Advances, Row);
		NewRow_Advances.RecordType = AccumulationRecordType.Expense;
		NewRow_Advances.Basis = Row.AdvancesDocument;

		NewRow_Transactions = TableTransactions.Add();
		FillPropertyValues(NewRow_Transactions, Row);
		NewRow_Transactions.RecordType = AccumulationRecordType.Expense;
		NewRow_Transactions.Basis = Row.TransactionDocument;

	EndDo;
	
	// Currency calculation
	CurrenciesParameters = New Structure();

	PostingDataTables = New Map();

	PostingDataTables.Insert(RecordSet_AdvancesToVendors, New Structure("RecordSet", TableAdvances));
	PostingDataTables.Insert(RecordSet_VendorsTransactions, New Structure("RecordSet", TableTransactions));

	ArrayOfPostingInfo = New Array();
	For Each DataTable In PostingDataTables Do
		ArrayOfPostingInfo.Add(DataTable);
	EndDo;

	CurrenciesParameters.Insert("Object", Recorder);
	CurrenciesParameters.Insert("ArrayOfPostingInfo", ArrayOfPostingInfo);

	CurrenciesServer.PreparePostingDataTables(CurrenciesParameters, Undefined);

	For Each ItemOfPostingInfo In ArrayOfPostingInfo Do
		If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1020B_AdvancesToVendors") Then
			RecordSet_AdvancesToVendors.Read();
			For Each Row In ItemOfPostingInfo.Value.RecordSet Do
				FillPropertyValues(RecordSet_AdvancesToVendors.Add(), Row);
			EndDo;
			RecordSet_AdvancesToVendors.SetActive(True);
			RecordSet_AdvancesToVendors.Write();
		EndIf;

		If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1021B_VendorsTransactions") Then
			RecordSet_VendorsTransactions.Read();
			For Each Row In ItemOfPostingInfo.Value.RecordSet Do
				FillPropertyValues(RecordSet_VendorsTransactions.Add(), Row);
			EndDo;
			RecordSet_VendorsTransactions.SetActive(True);
			RecordSet_VendorsTransactions.Write();
		EndIf;
	EndDo;
EndProcedure

// OffsetOfAdvance
//  *Period
//  *Company
//  *Currency
//  *Partner
//  *LegalName
//  *TransactionDocument
//  *AdvancesDocument
//  *Agreement
//  *Amount
Procedure Write_AdvancesAndTransactions(Recorder, Parameters, OffsetOfAdvanceFull, UseKeyForAdvance = False)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	OffsetOfAdvance.Period,
	|	OffsetOfAdvance.Company,
	|	OffsetOfAdvance.Branch,
	|	OffsetOfAdvance.Currency,
	|	OffsetOfAdvance.Partner,
	|	OffsetOfAdvance.LegalName,
	|	OffsetOfAdvance.TransactionDocument,
	|	OffsetOfAdvance.AdvancesDocument,
	|	OffsetOfAdvance.Agreement,
	|	OffsetOfAdvance.Amount,
	|	OffsetOfAdvance.Key,
	|	&VendorsAdvancesClosing AS VendorsAdvancesClosing,
	|	&Document AS Document,
	|	&Document AS Recorder
	|FROM
	|	OffsetOfAdvanceToVendors AS OffsetOfAdvance";
	Query.SetParameter("VendorsAdvancesClosing", Parameters.Object.Ref);
	Query.SetParameter("Document", Recorder);

	QueryTable = Query.Execute().Unload();

	RecordSet_AdvancesToVendors = AccumulationRegisters.R1020B_AdvancesToVendors.CreateRecordSet();
	RecordSet_AdvancesToVendors.Filter.Recorder.Set(Recorder);
	TableAdvances = RecordSet_AdvancesToVendors.UnloadColumns();
	TableAdvances.Columns.Delete(TableAdvances.Columns.PointInTime);
	RecordSet_VendorsTransactions = AccumulationRegisters.R1021B_VendorsTransactions.CreateRecordSet();
	RecordSet_VendorsTransactions.Filter.Recorder.Set(Recorder);
	TableTransactions = RecordSet_VendorsTransactions.UnloadColumns();
	TableTransactions.Columns.Delete(TableTransactions.Columns.PointInTime);

	If UseKeyForAdvance Then
		TableAdvances.Columns.Add("Key", Metadata.DefinedTypes.typeRowID.Type);
	EndIf;

	For Each Row In QueryTable Do

		FillPropertyValues(OffsetOfAdvanceFull.Add(), Row);

		NewRow_Advances = TableAdvances.Add();
		FillPropertyValues(NewRow_Advances, Row);
		NewRow_Advances.RecordType = AccumulationRecordType.Expense;
		NewRow_Advances.Basis = Row.AdvancesDocument;

		NewRow_Transactions = TableTransactions.Add();
		FillPropertyValues(NewRow_Transactions, Row);
		NewRow_Transactions.RecordType = AccumulationRecordType.Expense;
		NewRow_Transactions.Basis = Row.TransactionDocument;

	EndDo;
	
	// Currency calculation
	CurrenciesParameters = New Structure();

	PostingDataTables = New Map();

	PostingDataTables.Insert(RecordSet_AdvancesToVendors, New Structure("RecordSet", TableAdvances));
	PostingDataTables.Insert(RecordSet_VendorsTransactions, New Structure("RecordSet", TableTransactions));

	ArrayOfPostingInfo = New Array();
	For Each DataTable In PostingDataTables Do
		ArrayOfPostingInfo.Add(DataTable);
	EndDo;

	CurrenciesParameters.Insert("Object", Recorder);
	CurrenciesParameters.Insert("ArrayOfPostingInfo", ArrayOfPostingInfo);

	CurrenciesServer.PreparePostingDataTables(CurrenciesParameters, Undefined);

	For Each ItemOfPostingInfo In ArrayOfPostingInfo Do
		If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1020B_AdvancesToVendors") Then
			RecordSet_AdvancesToVendors.Read();
			For Each Row In ItemOfPostingInfo.Value.RecordSet Do
				FillPropertyValues(RecordSet_AdvancesToVendors.Add(), Row);
			EndDo;
			RecordSet_AdvancesToVendors.SetActive(True);
			RecordSet_AdvancesToVendors.Write();
		EndIf;

		If TypeOf(ItemOfPostingInfo.Key) = Type("AccumulationRegisterRecordSet.R1021B_VendorsTransactions") Then
			RecordSet_VendorsTransactions.Read();
			For Each Row In ItemOfPostingInfo.Value.RecordSet Do
				FillPropertyValues(RecordSet_VendorsTransactions.Add(), Row);
			EndDo;
			RecordSet_VendorsTransactions.SetActive(True);
			RecordSet_VendorsTransactions.Write();
		EndIf;
	EndDo;
EndProcedure

// OffsetOfAging
//  *Period
//  *Company
//  *Currency
//  *Partner
//  *Invoice
//  *PaymentDate
//  *Agreement
//  *Amount
Procedure Write_PartnersAging(Recorder, Parameters, OffsetOfAgingFull)
	Query = New Query();
	Query.TempTablesManager = Parameters.TempTablesManager;
	Query.Text =
	"SELECT
	|	OffsetOfAging.Period,
	|	OffsetOfAging.Company,
	|	OffsetOfAging.Branch,
	|	OffsetOfAging.Currency,
	|	OffsetOfAging.Partner,
	|	OffsetOfAging.Invoice,
	|	OffsetOfAging.PaymentDate,
	|	OffsetOfAging.Agreement,
	|	OffsetOfAging.Amount,
	|	&AgingClosing AS AgingClosing,
	|	&Document AS Document,
	|	&Document AS Recorder
	|FROM
	|	OffsetOfAging AS OffsetOfAging";
	Query.SetParameter("AgingClosing", Parameters.Object.Ref);
	Query.SetParameter("Document", Recorder);

	QueryTable = Query.Execute().Unload();

	RecordSet_Aging = AccumulationRegisters.R5012B_VendorsAging.CreateRecordSet();
	RecordSet_Aging.Filter.Recorder.Set(Recorder);
	TableAging = RecordSet_Aging.UnloadColumns();
	TableAging.Columns.Delete(TableAging.Columns.PointInTime);

	For Each Row In QueryTable Do

		FillPropertyValues(OffsetOfAgingFull.Add(), Row);

		NewRow_Advances = TableAging.Add();
		FillPropertyValues(NewRow_Advances, Row);
		NewRow_Advances.RecordType = AccumulationRecordType.Expense;

	EndDo;

	RecordSet_Aging.Read();
	For Each Row In TableAging Do
		FillPropertyValues(RecordSet_Aging.Add(), Row);
	EndDo;
	RecordSet_Aging.SetActive(True);
	RecordSet_Aging.Write();
EndProcedure