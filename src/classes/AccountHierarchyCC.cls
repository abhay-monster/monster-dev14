/*
** @author : ???.
** @date : 03/04/2014
** @description : AccountHierarchyCC class to handle CRUD events.
**
*/

public without sharing class AccountHierarchyCC {

    public AccountHierarchyCC(ApexPages.StandardSetController controller) {
        AccountId = ApexPages.currentPage().getParameters().get('id');
    }


    final String CLASSNAME = '\n\n**** AccountHierarchyCC.METHODNAME()';
    
    public Account PageAccount{get;set;}
    public String AccountId{get;set;}
    public string activityReport {get;set;}
    public string contactReport {get;set;}
    public string opportunityReport {get;set;}
    public string quoteProposalReport {get;set;}
    public string orderReport {get;set;}
    public string caseReport {get;set;}
    private Id ultimateParent;
    private set<Id> accIdSet = new set<Id>();
    
    public AccountHierarchyCC(ApexPages.StandardController controller) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AccountHierarchyCC') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        PageAccount = (Account)controller.getRecord();        
        AccountId = PageAccount.Id;
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nAccount ID :: ' + AccountId + '\n\n');
        //ParentIdWithAccountList();
        Map<String, Standard_Reports__c> reports = Standard_Reports__c.getAll();
        activityReport = reports.get('Activity Report').Report_Id__c;
        contactReport = reports.get('Contact Report').Report_Id__c;
        opportunityReport = reports.get('Opportunity Report').Report_Id__c;
        quoteProposalReport = reports.get('Quote/Proposal Report').Report_Id__c;
        orderReport = reports.get('Order Report').Report_Id__c;
        caseReport = reports.get('Case Report').Report_Id__c;       
        
    }
    private map<Id, List<Account>> mapParentIdWithAccountList = new map<Id, List<Account>>();
    
    private void ParentIdWithAccountList (){
        /*for(Account acc : [SELECT Id, Name, ParentId, Last12MonthsSpend__c, CustomerNumber__c, AccountStatus__c, Primary_Xcode__c,
                                MasterHQ__c,AccountProgram__c,Level__c,DomesticHQAccount__c, Type, BillingCity, BillingState,
                                Industry, OwnerId, AccountID__c,X15DigitAccountId__c FROM Account
                                Where ParentId =:ultimateParent OR Parent.ParentId=: ultimateParent OR Parent.Parent.ParentId=: ultimateParent OR
                                    Parent.Parent.Parent.ParentId=: ultimateParent OR Parent.Parent.Parent.Parent.ParentId=: ultimateParent
                                Order By ParentId]){*/
        for(Account acc : [SELECT Id, Name, ParentId, Last12MonthsSpend__c, CustomerNumber__c, AccountStatus__c, Primary_Xcode__c,
                                MasterHQ__c,AccountProgram__c,Level__c,DomesticHQAccount__c, Type, BillingCity, BillingState,
                                Industry, OwnerId, AccountID__c,X15DigitAccountId__c FROM Account
                                Where Id IN : accIdSet
                                Order By ParentId]){
               if(!mapParentIdWithAccountList.isEmpty() && mapParentIdWithAccountList.containsKey(acc.ParentId)){
                   mapParentIdWithAccountList.get(acc.ParentId).add(acc);
               }
               else{
                   mapParentIdWithAccountList.put(acc.ParentId, new List<Account>{acc});
               }
        }
    }
    
    public AccountWrapper mAccountData;
    public AccountWrapper accountData {
        get{
            if(mAccountData == null){
                
                for(Account acc : [Select id, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId
                                    From Account Where Id =: AccountId]) {
                    
                    if(acc.Parent.Parent.Parent.Parent.ParentId!= NULL) {
                        ultimateParent = acc.Parent.Parent.Parent.Parent.ParentId;
                    }
                    else if(acc.Parent.Parent.Parent.ParentId!= NULL) {
                        ultimateParent = acc.Parent.Parent.Parent.ParentId;
                    } 
                    else if(acc.Parent.Parent.ParentId!= NULL) {
                        ultimateParent = acc.Parent.Parent.ParentId;
                    }
                    else if(acc.Parent.ParentId!= NULL) {
                        ultimateParent = acc.Parent.ParentId;
                    } 
                    else if(acc.ParentId!= NULL) {
                        ultimateParent = acc.ParentId;
                    }
                    else {
                        ultimateParent = acc.Id;
                    }
                                                                                                                                                                                                
                    if(acc.Parent.Parent.Parent.Parent.ParentId!= NULL) {
                        accIdSet.add(acc.Parent.Parent.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.Parent.Parent.ParentId!= NULL) {
                        accIdSet.add(acc.Parent.Parent.Parent.ParentId);
                    } 
                    if(acc.Parent.Parent.ParentId!= NULL) {
                        accIdSet.add(acc.Parent.Parent.ParentId);
                    }
                    if(acc.Parent.ParentId!= NULL) {
                        accIdSet.add(acc.Parent.ParentId);
                    } 
                    if(acc.ParentId!= NULL) {
                        accIdSet.add(acc.ParentId);
                    }
                    //if(acc.ParentId == NULL) {
                        accIdSet.add(acc.Id);
                    //}                   
                }
                
                ParentIdWithAccountList();
                
                Account acc = [SELECT Id, Name, ParentId, Last12MonthsSpend__c, CustomerNumber__c, AccountStatus__c, Primary_Xcode__c,
                                MasterHQ__c,AccountProgram__c,Level__c,DomesticHQAccount__c, Type, BillingCity, BillingState,
                                Industry, OwnerId, AccountID__c,X15DigitAccountId__c FROM Account WHERE Id =: ultimateParent ];
                mAccountData = new AccountWrapper(acc);
                set<Id> aIds = new set<Id>();

                if(mapParentIdWithAccountList.containsKey(acc.Id)){
                    for(Account a : mapParentIdWithAccountList.get(acc.Id)){
                    
                        aIds.add(a.id);
                        
                        if(mAccountData.accountWithChilds.ContainsKey(a.ParentId))
                            mAccountData.accountWithChilds.get(a.ParentId).add(new AccountWrapper(a));
                        else{
                            mAccountData.accountWithChilds.put(a.ParentId, new List<AccountWrapper>{new AccountWrapper(a)});
                             
                        }
                        //if(u.Management_Cadence_Level__c >0)
                            mAccountData.subordinateFlag = true;
                            
                    }
                    
                }
                
                mAccountData.size = aIds.size();
                if(mAccountData.accountWithChilds!= null){
                    
                    mAccountData.accountWithChilds = prepareData(mAccountData.accountWithChilds, aIds );
                    
                   
                }
            }
            return mAccountData;
        }
        set;
    }
    
    private Map<Id, List<AccountWrapper>> prepareData(Map<Id, List<AccountWrapper>> accountWithChilds, set<Id> aIds){
        set<Id> accIds = new set<Id>();
        boolean loopFlag = false;
        
            for(Id pid : accountWithChilds.keyset()){
            
                for(AccountWrapper aw : accountWithChilds.get(pid)){
                    if(mapParentIdWithAccountList.containsKey(aw.account.id)){
                        for(Account a : mapParentIdWithAccountList.get(aw.account.id)){
                            system.debug('***********uuuuuuuuuuuu**************'+a.name);  
                            if(aw.account.id == a.ParentId){
                                accIds.add(a.Id);
                                if(aw.accountWithChilds.ContainsKey(a.ParentId)){
                                    aw.accountWithChilds.get(a.ParentId).add(new AccountWrapper(a));
                                    if(!loopFlag)
                                        loopFlag =  mapParentIdWithAccountList.containsKey(a.Id);
                                }else{
                                    aw.accountWithChilds.put(a.ParentId, new List<AccountWrapper>{new AccountWrapper(a)});
                                    aw.subordinateFlag = true;
                                    if(!loopFlag)
                                        loopFlag =  mapParentIdWithAccountList.containsKey(a.Id);
                                } 
                                  //if(u.Management_Cadence_Level__c >0)
                                    //aw.subordinateFlag = true;  
                            }    
                        } aw.size = accIds.size();
                        if(loopFlag){
                           
                            aw.accountWithChilds = prepareData(aw.accountWithChilds, accIds);
                             
                        }
                    }
                }
            }
       
        
        return accountWithChilds;
    }
    
    private class AccountWrapper{
        public Account account{get;set;}
        public Map<Id, List<AccountWrapper>> accountWithChilds {get;set;}
        public boolean subordinateFlag{get;set;}
        public Integer size{get;set;}
        public AccountWrapper(Account account){
            this.account = account;
            this.subordinateFlag = false;
            accountWithChilds = new Map<Id, List<AccountWrapper>>();
            this.size = 0;
        }
    }
    
}