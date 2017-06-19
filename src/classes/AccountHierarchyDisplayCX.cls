public with sharing class AccountHierarchyDisplayCX {
    private final Integer MAX_INIT_LEVEL = 5;
    
    private map<Integer, Id> RawHierarchyMap;
    private Id CurrentAccountId;
    private set<Id> AccountIdInEditModeSet;
    private Account[] ChildAccountList;
    private SelectOption[] CuntryOptionList;
    
    public String Level {get; set;}
    public AccountHierarchyLookupFilter__c FilterRecord {get; set;}
    public Id Program {get; set;}
    public Id GlobalHQAccount {get; set;}
    public String GlobalUltimateDUNS {get; set;}
    public String CountryFilter {get; set;}//for task E1848
    
    public Boolean RenderEditButton {get; set;}
    
    public HierarchyWrap[] HierarchyAccountList {get; set;}
    public Account CurrentAccount {get; set;}
    
    public string activityReport {get;set;}
    public string contactReport {get;set;}
    public string opportunityReport {get;set;}
    public string quoteProposalReport {get;set;}
    public string orderReport {get;set;}
    public string caseReport {get;set;}
    public string ShowInAccountId {get;set;}
    
    private ApexPages.StandardSetController Paginator;

    
    public String[] trial {get; set;}
    
    public AccountHierarchyDisplayCX(ApexPages.Standardcontroller sc){
        trial = new String[]{};
        
        FilterRecord = new AccountHierarchyLookupFilter__c();
        CurrentAccountId = sc.getId();
        
        Map<String, Standard_Reports__c> reports = Standard_Reports__c.getAll();
        activityReport = reports.get('Activity Report').Report_Id__c;
        contactReport = reports.get('Contact Report').Report_Id__c;
        opportunityReport = reports.get('Opportunity Report').Report_Id__c;
        quoteProposalReport = reports.get('Quote/Proposal Report').Report_Id__c;
        orderReport = reports.get('Order Report').Report_Id__c;
        caseReport = reports.get('Case Report').Report_Id__c; 
        
        RawHierarchyMap = new map<Integer, Id>();
        RawHierarchyMap.put(1, sc.getId());
        ExtractRawIds(CurrentAccountId);
        
        HierarchyAccountList = new HierarchyWrap[]{};
        AccountIdInEditModeSet = new set<Id>();
        ExtractAccounts();
        
        //determining if edit button will be rendered
        Map<String, Schema.SObjectField> fieldsToCheck = Utility.newInstance().getAllSObjectFieldsBySObjectName(new set<String>{'Account'}).get('Account');
        Boolean isEditableLevel = fieldsToCheck.get('level__c').getDescribe().isUpdateable();
        Boolean isEditableDomesticHQ = fieldsToCheck.get('domestichqaccount__c').getDescribe().isUpdateable();
        Boolean isEditableProgram = fieldsToCheck.get('accountprogram__c').getDescribe().isUpdateable();
        RenderEditButton = isEditableLevel || isEditableDomesticHQ || isEditableProgram;
        
        createChildRecords();
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/24/2014
** @story : 0947
** @element : E1848
** @description : Getter for SelectOption list used for country filter in the page 
** @paramaters : nothing
** @returns : nothing
*/   
    public SelectOption[] getCountryFilterOptions(){
        if(CuntryOptionList == null){
            map<String, SelectOption> options = new map<String, SelectOption>();
            
            if(ChildAccountList != null && ChildAccountList.size() > 0){
                for(Account a : ChildAccountList){
                    if(a.ShippingCountry != null && !options.containsKey(a.ShippingCountry)){
                        options.put(a.ShippingCountry, new SelectOption(a.ShippingCountry, a.ShippingCountry));
                    }
                }
            }
            // Modified by Vikas Menon 24 Nov 2016 Refer to S-445918 to sort selectoption list
            List<SelectOption> sortedOptions = new List<SelectOption>();
            if(!options.isEmpty()) {
                sortedOptions = sortSelectOptions(options.values());
            }
            CuntryOptionList = new SelectOption[]{new SelectOption('', '- None Selected -')};
            CuntryOptionList.addAll(sortedOptions);
        }
        return CuntryOptionList;
    }
    
    // Method to Sort SelectOption list
    // Created by Vikas Menon 24 Nov 2016 Refer to S-445918
    public List<SelectOption> sortSelectOptions(List<SelectOption> sortingList) {
         
        for (Integer i =0; i < sortingList.size(); i++) {
             for (Integer j = i; j > 0; j--) {
                if (sortingList[j-1].getLabel() > sortingList[j].getLabel()){
                  SelectOption temp = sortingList[j];
                  sortingList[j] = sortingList[j-1];
                  sortingList[j-1] = temp;
                }
             }
        }
        return sortingList;
    }
    
    public Account[] getChildAccounts(){
        return Paginator.getRecords();
    }
    
    public PageReference nextChildren(){
        Paginator.next();
        return null;
    }
    
    public PageReference prevChildren(){
        Paginator.previous();
        return null;
    }
    
    public Boolean getHasNext(){
        return Paginator != null ? Paginator.getHasNext() : false;
    }
    
    public Boolean getHasPrev(){
        return Paginator != null ? Paginator.getHasPrevious() : false;
    }
    
    public Boolean getNoNext(){
        return !getHasNext();
    }
    
    public Boolean getNoPrev(){
        return !getHasPrev();
    }
    
    public Boolean getHasChildren(){
        return Paginator.getResultSize() > 0;
    }
    
    public Boolean getHasNoChildren(){
        return !getHasChildren();
    }
    
    public String getPageInfo(){
        Integer size = Paginator.getResultSize();
        Integer current = parseInt(getChildAccounts().size());
        Integer max = (Paginator.getPageSize() *  Paginator.getPageNumber()) - (Paginator.getPageSize() - current);
        Integer min = size == 0 ? 0 : (max - current) + 1;
        return min + '-' + max + ' of ' + size;
    }
    
    public list<SelectOption> levelOptions {
        get {
            if (levelOptions==null) {
                levelOptions = new list<SelectOption>();
                 levelOptions.add(new SelectOption('All','All'));
                 for(Schema.PicklistEntry pEntry : Account.Level__c.getDescribe().getPicklistValues()) {
                    if (pEntry.isActive() && pEntry.getValue()!='') {
                        levelOptions.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
                    }
                }
            }
            return levelOptions;
        }
        private set;
    }
    /*
     * @author  Cloud Sherpas, Inc.
     * @date    12.5.2014
     * @story   1003
     * @description method to populate the child records and apply filter values on the page 
     * Revision(s) Andre 12.4.2014 - added method comments and filters for Account Id, Domestic HQ, and Parent Id for the page
    */ 
    public void createChildRecords(){
        try{
            Program = FilterRecord.AccountProgram__c;
            GlobalHQAccount = FilterRecord.GlobalHQAccount__c;
            Id rec;
            Id recDom;
            Id recPid;
            if(FilterRecord.GlobalHQAccount__c != null){
                rec = FilterRecord.GlobalHQAccount__c;
            }
            
            if(FilterRecord.Domestic_HQ_Id__c != null){
                recDom = FilterRecord.Domestic_HQ_Id__c;
            }
            if(FilterRecord.Parent_Id__c != null){
                recPid = FilterRecord.Parent_Id__c;
            }
            String accId = rec;
            String domId = recDom;//.DomesticHQAccountID__c;
            String parId = recPid;//.ParentId;
            String filterLevel = (Level == 'All' || Level == null) ? '' : ' Level__c = \''+Level+'\' AND ';
            String filterProgram = (Program == null) ? '' : ' AccountProgram__c = :Program AND ';
            String filterAccount = (accId == null) ? '' : ' Id = :accId AND ';
            String filterDomHQ = (domId == null) ? '' : ' DomesticHQAccount__c = :domId AND ';
            String filterPid = (parId == null) ? '' : ' ParentId = :parId AND ';
            //String filterGlobalHQAccount = (GlobalHQAccount == null) ? '' : ' (GlobalHQAccount__c = :GlobalHQAccount OR (Id = :GlobalHQAccount AND IsGlobalHQ__c = true)) AND';
            String filterGlobalUltimateDUNS = (GlobalUltimateDUNS == '' || GlobalUltimateDUNS == null) ? '' : ' GlobalUltimateDUNSNumber__c LIKE \'%'+GlobalUltimateDUNS+'%\' AND ';
            String filterCountry = CountryFilter == null || CountryFilter == '' ? '' : ' ShippingCountry = :CountryFilter AND '; //for task E1848
            
            String filterText = filterLevel + filterProgram + filterAccount + filterDomHQ + filterPid + filterGlobalUltimateDUNS + filterCountry;
            
            String queryFields = 'GlobalHQAccount__c, ParentId, Last12MonthsSpend__c, CustomerNumber__c, AccountStatus__c, Primary_Xcode__c, MasterHQ__c,';
            queryFields += 'DomesticHQDisplay__c, GlobalHQDisplay__c, IsGlobalHQ__c, IsDomesticHQ__c, AccountProgram__c, Level__c, DomesticHQAccount__c, Account_Type__c, BillingCity, BillingState, Industry, OwnerId, AccountID__c, ShippingCity, ShippingState, ShippingCountry ';
            String query = 'SELECT Id, Name, '+queryFields+' FROM Account WHERE '+filterText+' ParentId = :CurrentAccountId ORDER BY CreatedDate DESC';
            
            
            
            ChildAccountList = Database.query(query);
            system.debug('\n\nFILTER QUERY: ' + query + '\n' + domId + '\n');
            /*for(Account acc : ChildAccountList){
                if(acc.IsGlobalHQ__c){
                    acc.GlobalHQAccount__c = acc.Id;
                }
                if(acc.IsDomesticHQ__c){
                    acc.DomesticHQAccount__c = acc.Id;
                }
            }*/
            Paginator = new ApexPages.StandardSetController(ChildAccountList);
            Paginator.setPageSize(10);
        }catch(Exception e){
            system.debug('\n\nError filtering account hierarchy page.');
            system.debug('Error: ' + e);
            system.debug('Trace: ' + e.getStackTraceString() + '\n\n');
        }
    }
    
    
    public PageReference showInTree(){
        system.debug('\n\nShowInAccountId: ' + ShowInAccountId + '\n\n');
        system.debug('\n\nShowInAccountId URL: ' + ApexPages.currentPage().getParameters().get('ShowInAccountId') + '\n\n');
        if(ShowInAccountId != null){
            return new PageReference('/apex/AccountHierarchyDisplay?id=' + ShowInAccountId);
        }
        return null;
    }
    
    private Integer parseInt(Object num){
        return num == null ? 0 : Integer.valueOf(num);
    }
    
    private void ExtractAccounts(){
        map<Id, Account> hierarchyAccounts = new map<Id, Account>([
            SELECT Id, Name, X15DigitAccountId__c, Last12MonthsSpend__c, Hierarchy12MonthSpend__c, AccountID__c, AccountStatus__c, CustomerNumber__c, Primary_Xcode__c, 
            AccountProgram__c, Level__c, DomesticHQAccount__c, GlobalHQAccount__c, Account_Type__c, Industry, ShippingCity, ShippingCountry, ShippingState, OwnerId,
            IsGlobalHQ__c, IsDomesticHQ__c //for Task E1851
            FROM Account  WHERE Id IN :RawHierarchyMap.values()
        ]);
        Integer position = 0;
        for(Integer i = RawHierarchyMap.size(); i >= 1; i--){
            Account acc = hierarchyAccounts.get(RawHierarchyMap.get(i));
            if(acc != null){
                HierarchyWrap wrap = new HierarchyWrap();
                wrap.Acc = acc;
                if(acc.IsGlobalHQ__c){
                    wrap.Acc.GlobalHQAccount__c = acc.Id;
                }
                if(acc.IsDomesticHQ__c){
                    wrap.Acc.DomesticHQAccount__c = acc.Id;
                }
                if(AccountIdInEditModeSet.contains(acc.Id)){
                    wrap.IsEdit = true;
                }
                Integer padding = (position * 12);
                if(i == RawHierarchyMap.size()){
                    wrap.Position = '';
                    wrap.HideBracket = 'display: none;';
                }else{
                    wrap.Position = 'padding-left: ' + padding + 'px;';
                }
                
                if(CurrentAccountId == acc.Id){
                    CurrentAccount = acc;
                    wrap.EnableShowInTree = false;
                }
                HierarchyAccountList.add(wrap);
            }
            position++;
        }
    }
    
    private void ExtractRawIds(Id pCurrentRecordId){
        String parentField = ' ';
        for(Integer i = 0; i < MAX_INIT_LEVEL; i++){
            String pq = '';
            for(Integer j = 0; j <= i; j++){
                pq += 'Parent.';
            }
            pq += 'ParentId, ';
            parentField += pq;
        }
        
        String ancestorQuery = 'SELECT ' + parentField + ' Id FROM Account WHERE Id = :pCurrentRecordId';
        
        try{
            Account currentAccount = Database.query(ancestorQuery);
            if(currentAccount != null){
                GetRawIds(currentAccount);
            }
        }catch(Exception e){
            trial.add('Current Account Error: ' + e);
            trial.add('Current Account Trace: ' + e.getStackTraceString());
        }
    }
    
    private void GetRawIds(Account pCurrentAccount){
        if(pCurrentAccount.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.ParentId);
        }
        if(pCurrentAccount.Parent.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.Parent.ParentId);
        }
        if(pCurrentAccount.Parent.Parent.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.Parent.Parent.ParentId);
        }
        if(pCurrentAccount.Parent.Parent.Parent.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.Parent.Parent.Parent.ParentId);
        }
        if(pCurrentAccount.Parent.Parent.Parent.Parent.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.Parent.Parent.Parent.Parent.ParentId);
        }
        if(pCurrentAccount.Parent.Parent.Parent.Parent.Parent.ParentId != null){
            RawHierarchyMap.put(RawHierarchyMap.size() + 1, pCurrentAccount.Parent.Parent.Parent.Parent.Parent.ParentId);
        }
        
        Id LastId = RawHierarchyMap.get(RawHierarchyMap.size());
        if(LastId != null && LastId != pCurrentAccount.Id && LastId != pCurrentAccount.ParentId){
            ExtractRawIds(LastId); //extract remaining ancestor
        }
    }
    
    public class HierarchyWrap{
        public Account Acc {get; set;}
        public Boolean IsEdit {get; set;}
        public Boolean IsView {get{return !IsEdit;}}
        public Boolean EnableShowInTree {get; set;}
        public String Position {get; set;}
        public String HideBracket {get; set;}
        public HierarchyWrap(){
            IsEdit = false;
            EnableShowInTree = true;
        }
    } 
}