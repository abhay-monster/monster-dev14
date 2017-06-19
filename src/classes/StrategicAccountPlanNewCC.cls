/*
** @author : Cloud Sherpas Inc.
** @date : 03/24/2014
** @description : StrategicAccountPlanCC Page Controller Class
*/
public with sharing class StrategicAccountPlanNewCC {
    
    final String CLASSNAME = '\n\n**** StrategicAccountPlanCC.METHODNAME()';
    
    public Strategic_Account_Plan__c PageAccount{get;set;}
    
    public Strategic_Account_Plan__c sapLIst{get;set;}
    public Strategic_Account_Plan__c AccountList{get;set;}
    public String accId{get;set;}
    public list<Strategic_Account_Plan_Key_Contact__c> ContactList{get;set;}
    public list<CompetitiveLandscape__c> CompetitiveLandscapeList{get;set;}
    public list<ProposedSolution__c> ProposedSolutionList {get; set;}
    private list<Task> TaskList{get;set;}
    public String SapId{get;set;}
    public String tempString{get;set;}
    public list<Task> MonsterAnalysisTaskList{
        get{
            if(MonsterAnalysisTaskList == NULL){
                MonsterAnalysisTaskList = new list<Task>();
            }
            return MonsterAnalysisTaskList;
        }
        set;
    }
    public list<Task> ClientAnalysisTaskList{
        get{
            if(ClientAnalysisTaskList == NULL){
                ClientAnalysisTaskList = new list<Task>();
            }
            return ClientAnalysisTaskList;
        }
        set;
    }
    public String PrimarySalesManager{get;set;}
    public ProposedSolution__c ProposedProductTotal {get; set;}
    public Map<String, String> ContactLabels {get; private set;}
    public Map<String, String> StrategicLabels {get; private set;}
    public Map<String, String> CompetitiveLandscapeLabels {get; private set;}
    public Map<String, String> TaskLabels {get; private set;}
    public Map<String, String> ProposedSolutionLabels {get; private set;}
    public Map<String, String> AccountLabels {get; private set;}
    public Map<String,String> StrategicAccountPlanLabels {get; private set;}
    
    //getter of the current page plus the render as pdf url param set to true
    //for new tab pdf rendering of the page
    public String NewTabAsPDF {
        get{
            String param = '?';
            for(String pName : ApexPages.currentPage().getParameters().keySet()){
                param += pName + '=' + ApexPages.currentPage().getParameters().get(pName) + '&';
            }
            return '/apex/StrategicAccountPlanPDF' + param;
        }
    }
    
    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/24/2014
** @description : constructor
** @paramaters : none
** @returns : nothing
*/
    public StrategicAccountPlanNewCC(ApexPages.StandardController controller){
        PageAccount = (Strategic_Account_Plan__c)controller.getRecord();        
        SapId = PageAccount.Id;

        SetModelLists(SapId);
        SetAnalysisTaskLists();
        GetSobjectLabelsForPDFRendering();

    }
    private void SetModelLists(String pASapId){    
        final string METHODNAME = CLASSNAME.replace('METHODNAME','StrategicAccountPlanNewCC') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        sapList = new Strategic_Account_Plan__c();
        sapList = [SELECT Goal__c, Strategy__c, Name, Account_Name__c, Account_Name__r.AccountStatus__c,
                         Account_Name__r.GlobalHQAccount__c, Account_Name__r.Region__c, BillingAgency__c,
                         Account_Name__r.PrimaryAgencyContact__c, Account_Name__r.NumberofLocations__c,
                         Account_Name__r.NumberofEmployeesTotal__c, Trial_Candidate__c, At_Risk_Account__c,
                         Additional_Account_Commentary__c, Long_Term_Strategy__c, Short_Term_Strategy__c,
                         Account_Name__r.OwnerId, Account_Name__r.PrimarySalesManager__c,
                         Account_Name__r.PrimaryServiceRep__c, Account_Name__r.NAP__c, Account_Name__r.MasterHQ__c,
                         Centralized_Buying__c, Client_Turnover_Rate__c, Number_of_Hires__c, Key_Initiative__c,
                         Penetration_Level__c, Level_Justification__c,
                         Total_Account_Opportunity__c, International_Online_Budget__c, Domestic_Online_Budget__c,
                         Newspaper_Value__c, Account_Name__r.TotalSpend1YearPrior__c, Account_Name__r.TotalSpend2yearPrior__c,
                         Account_Name__r.Last12MonthsSpend__c, Account_Name__r.Hierarchy12MonthSpend__c,
                         Monster_Business_Objective__c, Monster_Strengths__c, Monster_Weaknesses__c,
                         ApplyScreens__c,InterestCapture__c,SourceAttribution__c,SourceAttributionTag__c,
                         ApplyTimeHours__c,ApplyTimeMinutes__c,JobPostingTemplate__c,
                         Client_Business_Objective__c, Value__c, Opportunity_Area__c,MeasurementofSuccess__c,VendorEvaluationKeyMetrics__c,
                         JobPostingMethod__c,ApplyMethod__c,ApplyMethodLocation__c,ATS_Vendor__c,CustomApplyRedirect__c,Opportunity_WWK__c, Objectives_WWK__c, Recruiter_Habits_WWK__c, Technology_WWK__c,
                         Cost_of_Not_Purchasing_WWK__c, Opportunity_TBD__c, Objectives_TBD__c, Recruiter_Habits_TBD__c,
                         Technology_TBD__c, Cost_of_Not_Purchasing_TBD__c,Additional_Budget_Available__c,Additional_Budget_Source__c,
                          Account_Name__r.Parent_Account_Number__c,Agency_Billed__c ,Recordtype.Name ,of_Crawled_Jobs__c,All_Jobs_URL__c,Career_Center_URL__c,Date_Received__c,Estimated_Budget__c,
                          Sales_Channel__c,Tracking_Enabled__c,Tracking_Enabled_Detail__c,Website__c,Plan_Type__c,Global_HQ_Account__c,Account_Status__c,Parent_Account_ID__c,Region__c,Primary_Agency_Contact__c,
                          Number_of_Locations__c,Number_of_Employees_Total__c, Account_Activity__c, Account_Classification__c, Injestion_Type__c
                    FROM Strategic_Account_Plan__c WHERE ID =: pASapId];
        accId = sapList.Account_Name__c;
        AccountList = [SELECT Id,
                                (SELECT ActivityDate,Description,Id,Owner.Name,Status,Subject, AnalysisType__c FROM Tasks),
                                (SELECT Competitor__c, ContractValue__c,ExpDate__c,Hire__c,Id,Name,RelationshipStanding__c,TotalJobs__c FROM Competitors__r), 
                                (SELECT Business_Objective__c,Contact_Type__c,Coverage__c,Email__c,Id,Job_Position__c,Motivation__c,Name,Potential_Objection__c,Phone_Number__c,Key_Contact_Role__c,Status_as_Key_Contact__c FROM Strategic_Account_Plan_Key_Contacts__r),
                                (SELECT ProductDivision__c, ProductGroup__c, ProposedValue__c, ProblemAddressed__c FROM Proposed_Solutions__r)
                            FROM Strategic_Account_Plan__c 
                            WHERE Id = :pASapId];

        ContactList = AccountList.Strategic_Account_Plan_Key_Contacts__r;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCONTACT LIST :: ' + ContactList + '\n\n');
        CompetitiveLandscapeList = AccountList.Competitors__r;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCOMPETITIVE LANDSCAPE LIST :: ' + CompetitiveLandscapeList + '\n\n');
        ProposedSolutionList = AccountList.Proposed_Solutions__r;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nPROPOSED SOLUTION LIST :: ' + ProposedSolutionList + '\n\n');
        TaskList = AccountList.Tasks;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nTASK LIST :: ' + TaskList + '\n\n');

        //adding of Proposed Product Total
        if(ProposedSolutionList != null && ProposedSolutionList.size() > 0){
            system.debug('Compute Proposed Product Total');
            ProposedProductTotal = new ProposedSolution__c();
            ProposedProductTotal.ProductDivision__c = 'Proposed Product Total';
            ProposedProductTotal.ProposedValue__c = 0;
            for(ProposedSolution__c ps : ProposedSolutionList){
                if(ps.ProposedValue__c != null){
                    ProposedProductTotal.ProposedValue__c += ps.ProposedValue__c;
                }
            }
            if(ApexPages.currentPage().getUrl().indexOf('StrategicAccountPlanPDF') == -1){
                ProposedSolutionList.add(ProposedProductTotal);
            }
            system.debug('ProposedProductTotal.ProposedValue__c: ' + ProposedProductTotal.ProposedValue__c);
        }
    }

    private void GetSobjectLabelsForPDFRendering(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','StrategicAccountModel') + ' - getSobjectLabelsForPDFRendering';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Map<String, Map<String, String>> allFieldsBySObject = Utility.newInstance().getSObjectsFieldsLabels(new Set<String>{
            'Account', 'Contact', 'Task', 'CompetitiveLandscape__c', 'ProposedSolution__c', 'Strategic_Account_Plan__c'
        });
        ContactLabels = allFieldsBySObject.get('Contact');
        CompetitiveLandscapeLabels = allFieldsBySObject.get('CompetitiveLandscape__c');
        ProposedSolutionLabels = allFieldsBySObject.get('ProposedSolution__c');
        TaskLabels = allFieldsBySObject.get('Task');
        AccountLabels = allFieldsBySObject.get('Account');
        StrategicAccountPlanLabels = allFieldsBySObject.get('Strategic_Account_Plan__c');
        //system.assert(false , StrategicAccountPlanLabels.keyset());
        for(String fieldAPIName2 : StrategicAccountPlanLabels .keySet()){
        
                system.debug('Check #####' + fieldAPIName2 );
        
        }
        
        system.debug('\n\nRemoving of (WWK) and (TBD) from field labels');
        for(String fieldAPIName : AccountLabels.keySet()){
            if(AccountLabels.get(fieldAPIName).indexOf('(WWK)') != -1){
                String newLabel = AccountLabels.remove(fieldAPIName).remove('(WWK)');
                AccountLabels.put(fieldAPIName, newLabel);
            }
            if(AccountLabels.get(fieldAPIName).indexOf('(TBD)') != -1){
                String newLabel = AccountLabels.remove(fieldAPIName).remove('(TBD)');
                AccountLabels.put(fieldAPIName, newLabel);
            }
        }
        //hardcoded labels
        AccountLabels.put('primarysalesrep', 'Primary Sales Rep');
        AccountLabels.put('sfid', 'Account ID');
        AccountLabels.put('ATSVendor__c','ATS Vendor');
        AccountLabels.put('PrimaryAgencyContact__c','Primary Agency Contact');
        AccountLabels.put('Region__c','Region');
        AccountLabels.put('AdditionalBudgetSource__c','Additional Budget Source');

        TaskLabels.put('owner', TaskLabels.get('ownerid').removeend('ID'));
        TaskLabels.put('activitydate', TaskLabels.get('activitydate').removeEnd('Only'));
    }

    private void SetAnalysisTaskLists(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetAnalysisTaskLists');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(!TaskList.isEmpty()){
            for(Task oTask : TaskList){
                if(oTask.AnalysisType__c == 'Monster Analysis'){
                    MonsterAnalysisTaskList.add(oTask);
                }
                if(oTask.AnalysisType__c == 'Client Analysis'){
                    ClientAnalysisTaskList.add(oTask);
                }
            }
            
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nMONSTER TASK LIST :: ' + MonsterAnalysisTaskList + '\n\n');
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCLIENT TASK LIST :: ' + ClientAnalysisTaskList + '\n\n');
            
        }
    }
    public class AccountStrategyRow {
        public string productName {get; private set;}
        public string accountName {get; private set;}
        public Id accountId {get; private set;}
        public Id productId {get; private set;}
        //public date endDate {get; private set;}
        //public decimal quantity {get; private set;}
        //public decimal netPrice {get; private set;}               
        public list<AccountStrategyRow> asRow {get; private set;}
        
        public AccountStrategyRow(string accountName, Id accountId) {
            this.accountName = accountName;
            this.accountId = accountId;
            this.asRow = new list<AccountStrategyRow>();
        }
        
        public AccountStrategyRow(string accountName, string productName, Id accountId, Id productId ) {
            this.accountName = accountName;
            this.productName = productName;
            this.accountId = accountId;
            this.productId = productId;
            this.asRow = new list<AccountStrategyRow>();
        }       
        
        public AccountStrategyRow(string productName, string accountName, id productId, id accountId, date endDate, decimal quantity, decimal netPrice) {
            this.productName = productName;
            this.productId = productId;
            this.accountName = accountName;
            this.accountId = accountId;
            this.endDate = endDate;
            this.quantity = quantity;
            this.netPrice = netPrice;
            this.asRow = new list<AccountStrategyRow>();
            
        }
        public double quantity {
          get {
            if (quantity == null  || quantity == 0) {
              quantity = 0;
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  quantity += sub.quantity == null ? 0 : sub.quantity;
                }
              }
            }
            return quantity;
          }
          private set;
        }
        public double netPrice {
          get {
            if (netPrice == null  || netPrice == 0) {
              netPrice = 0;
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  netPrice += sub.netPrice == null ? 0 : sub.netPrice;
                }
              }
            }
            return netPrice;
          }
          private set;
        }
        public date endDate {
          get {
            date previousDate;
            if (endDate == null) {
              if ( asRow.IsEmpty() == false) {
                for (AccountStrategyRow sub : asRow) {
                  if(previousDate==NULL || previousDate< sub.endDate) {
                      endDate = sub.endDate;
                      previousDate = sub.endDate;
                  }
                }
              }
            }
            return endDate;
          }
          private set;
        }                               
    }
    
    public list<AccountStrategyRow> mAccountStrategyRow;
    public list<AccountStrategyRow> asRowData {
        get {
            mAccountStrategyRow = new list<AccountStrategyRow>();
            AccountStrategyRow detailRows;
            AccountStrategyRow totalRow;
            AccountStrategyRow productGrouping = null;
            AccountStrategyRow oliGrouping = null;
            Id previousProductId = null;
            Id previousOLIId = null;
            datetime previousEndDate = null;
            list<Order_Line_Item__c> oliList = [SELECT NetUnitPrice__c, Quantity__c, EndDate__c,    Product__c, Product__r.Name, Order__c, Order__r.OrderStatus__c, Order__r.Account__c, Order__r.Account__r.Name  
                                                FROM Order_Line_Item__c
                                                WHERE Order__r.Account__c =:accId 
                                                AND Order__r.OrderStatus__c In  ('Open - Ecomm','Open','Sent To Verification','Verified','Invoiced','Finance Hold')
                                                order by Order__r.Account__r.Name, Product__c ];
            
            //system.assertequals(oliList[0] , null);
            if(!oliList.isEmpty()) {                                    
                detailRows = new AccountStrategyRow(oliList[0].Order__r.Account__r.Name, oliList[0].Order__r.Account__c);
                totalRow = new AccountStrategyRow(oliList[0].Order__r.Account__r.Name, oliList[0].Order__r.Account__c);
            }                                 
            for(Order_Line_Item__c oli : oliList) {
                if(productGrouping==null || previousProductId!= oli.Product__c) {
                    productGrouping = new AccountStrategyRow(oli.Order__r.Account__r.Name, oli.Product__r.Name, oli.Order__r.Account__c, oli.Product__c);                                        
                    detailRows.asRow.add(productGrouping );
                }
                
                if( previousOLIId!=oli.Id) {
                    oliGrouping = new AccountStrategyRow(oli.Product__r.Name, oli.Order__r.Account__r.Name, oli.Product__c, oli.Order__r.Account__c,  oli.EndDate__c, oli.quantity__c, oli.NetUnitPrice__c);
                    productGrouping.asRow.add(oliGrouping );
                    
                }
                
                previousOLIId = oli.Id;
                previousProductId = oli.Product__c;
                if(oli.quantity__c!=NULL) {
                    totalRow.quantity += oli.quantity__c; 
                }
                if(oli.NetUnitPrice__c!=NULL) {
                    totalRow.netPrice += oli.NetUnitPrice__c; 
                }                
            }
            if(detailRows!=NULL){
                mAccountStrategyRow.add(detailRows);    
            }
            mAccountStrategyRow.add(totalRow);                        
            return mAccountStrategyRow;                                 
        }
        set;
    } 
}