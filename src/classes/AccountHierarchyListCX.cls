public with sharing class AccountHierarchyListCX {

    public AccountHierarchyListCX(ApexPages.StandardController controller) {

    }

  public Id SelectedId {get;set;}
  public Id oldSelectedId;
  public string level {get;set;}
  public Id acctId;
  public AccountHierarchyListCX(ApexPages.StandardSetController controller){

    level = 'All';
  }
 
  
  public ApexPages.StandardSetController AccountList {
        get {
                if(SelectedId == null) {
                    SelectedId = ApexPages.currentPage().getParameters().get('id');
                }
                
                if(oldSelectedId != SelectedId){
                    AccountList = null;
                }
                
                if(AccountList == null && SelectedId != null){
                oldSelectedId = SelectedId;
                String query = 'SELECT Id, Name, ParentId, Last12MonthsSpend__c, CustomerNumber__c, AccountStatus__c, Primary_Xcode__c, '+
                                    'MasterHQ__c,AccountProgram__c,Level__c,DomesticHQAccount__c, Type, BillingCity, BillingState, '+
                                    'Industry, OwnerId, AccountID__c,X15DigitAccountId__c FROM Account Where ParentId =: SelectedId  ';
                if(level == 'All' || level == null) {
                    query += ' Order by Name';
                    AccountList = new ApexPages.StandardSetController(Database.Query(query));
                }
                else {
                    query += ' AND Level__c =: level Order by Name';
                    
                    AccountList = new ApexPages.StandardSetController(Database.Query(query));
                } 
                
                AccountList.setPageSize(10);
                }
            return AccountList;
        }
        set;
    }
    
     public List<Account> getAccountPagination() {

       if( AccountList != null){
         return (List<Account>) AccountList.getRecords();
        }
        else
         return new List<Account>();

    }
    
    public Boolean getShowTable(){
        Account[] accs =  (List<Account>) AccountList.getRecords();
        system.debug('Account list: ' + accs.size());
        return accs.size() > 0;
    }
    
    public String getNoAccountMessage(){
        system.debug('Show Table result: ' + getShowTable());
        return !getShowTable() ? 'No child account.' : '';
    }

    public String getPageStatistics(){
        String output = '';
        if(getShowTable()){
            Integer size = getAccountPagination().size() != null ? getAccountPagination().size() : 0;
            Integer minPage = (AccountList.getPageNumber() * size) - (AccountList.getPageSize() - 1);
            Integer maxPage = (minPage - 1) + AccountList.getPageSize();
            output =  minPage + ' - ' + maxPage + ' of ' + AccountList.getResultSize();
        }
        return output;
    }
      
    public list<SelectOption> levelOptions {
        get {
            if (levelOptions==null) {
                levelOptions = new list<SelectOption>();
                 levelOptions.add(new SelectOption('All','All'));
                 for(Schema.PicklistEntry pEntry : Account.level__c.getDescribe().getPicklistValues()) {
                    if (pEntry.isActive() && pEntry.getValue()!='') {
                        levelOptions.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
                    }
                }
            }
            return levelOptions;
        }
        private set;
    }  
    
    public void next() {
       AccountList.next();
    }
    public void previous() {
        AccountList.previous();
    }
    
    public Boolean hasNext {
        get {
            if( AccountList != null){
            return AccountList.getHasNext();
            }
           else
              return false;
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            if( AccountList != null){
                return AccountList.getHasPrevious();
            }
            else
               return false;
        }
        set;
    }
    
}