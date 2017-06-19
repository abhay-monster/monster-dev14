/**
* @description controller for custom merge functionality on account. 
* @author Cloudsherpas
* @date 01-06-2015
* @last modified 01-15-2015
*/

public with sharing class AccountMergeController{ 
  public boolean userCanMerge {get;set;}
  
  public boolean isValidAccount    {get;set;}
  public boolean withSourceAccount {get;set;}

  public Boolean loading {get;set;}

  public string searchText {get;set;}
  public string searchId {get;set;}
  
  public Account accnt {get;set;}

  public List<Account> selAccList {get;set;}

  public List<SelectableAccount> results {get;set;}

  public Id selectedAccountId {get;set;}
        
  string accId;
                                
  public AccountMergeController(){ 
    loading = true;
  }

    public PageReference constructPage(){
      
      loading = false;

      userCanMerge = false;
      accId = ApexPages.currentPage().getParameters().get('id');
      //verify user access to merge accounts by reference to a custom permission
      if(PermissionCheck.hasPermission('Can_Merge_Accounts')==true){
        userCanMerge = true;
        isValidAccount = true;
        withSourceAccount = false;
        accnt = new Account();
        
        if(!string.IsEmpty(accId)){
          try{
            //if account id is supplied, verify that the id is valid by retrieving the account record
            for(Account acc : [select Id, Name, OwnerId,AccountID__c,RegistrationNumber__c,AccountStatus__c,CustomerLapsedDate__c,MaxActivityDate__c, RecordType.IsPersonType, DomesticHQAccount__c, DomesticHQAccount__r.Name,
                          NewspaperStatus__c, DUNSNumber, CreatedDate, Score__c, GlobalUltimateDUNSNumber__c
                       from Account where Id = :accId]){
              accnt = acc;
            }
            if(accnt.Id != null){
              //if account is found, default the search text to the account's name
              withSourceAccount = true;
              /* Commented by Rohit B on 19/Nov/2015 on the ask of Mary Cullinan for issue I-191552.
              if(searchText == null){
                searchText = accnt.Name;
                //do auto-search based on account name
                search();
              }
              */
            }
            else{
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.CS_AccountMerge_Err_No_Matching_Account));
              isValidAccount = false;  
            }
          }
          catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.CS_AccountMerge_Err_Generic + ' ' + e.getMessage()));
            isValidAccount = false;
          }
        }
      }
      else{
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.CS_AccountMerge_Err_UserCannotMerge));
      }

      return null;
    }
  
  /**
  * @description method to perform the search on matching accounts based on search text (name) and account id 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public PageReference search()
  {
    results =  new List<SelectableAccount>();
    
    if (validateSearchCrit())
    {
      try
      {
        string soqlStr = 'select Id, AccountID__c, Name,RegistrationNumber__c, OwnerId,AccountStatus__c,CustomerLapsedDate__c,MaxActivityDate__c, ShippingCountry, DomesticHQAccount__c, DomesticHQAccount__r.Name, NewspaperStatus__c, DUNSNumber, CreatedDate, Score__c, GlobalUltimateDUNSNumber__c from Account where ';
        soqlStr += 'RecordType.isPersonType = '+accnt.RecordType.isPersonType+' AND (';

        
        String searchEscapedText; 
        String searchEscapedId;
        
        if(!string.isEmpty(searchText))
        {
          searchEscapedText = searchText.replace('*', '%');
          searchEscapedText = '%' + searchEscapedText + '%';
        }
            
        if(!string.isEmpty(searchId))
        {
          searchEscapedId = searchId.replace('*', '%');
          searchEscapedId = '%' + searchEscapedId + '%';
        }

        system.debug('&&searchEscapedId '+searchId);
        system.debug('&&searchEscapedId '+searchEscapedId);

            
        //build the query string based on searchText and searchId inputs
        
        if(!string.isEmpty(searchText))
          soqlStr += 'Name like:searchEscapedText ';
        
        if(!string.isEmpty(searchId))
        {
          if(!string.isEmpty(searchText))
            soqlStr += ' Or AccountID__c like:searchEscapedId ';
          else
            soqlStr += ' AccountID__c like:searchEscapedId ';
        }
        
        soqlStr += ') ';



        //if account is supplied, make sure that account is removed from the search results.
        if(withSourceAccount)
        {
          Id accId = accnt.Id;
          soqlStr += ' and Id != :accId ';
        }

        //return the top 50 most recently modified accounts 
        soqlStr += ' order by lastmodifieddate desc Limit 50';
        
        system.debug('&&1 ' + soqlStr);
        system.debug('&&2 ' + searchEscapedId);

        for(Account acc : Database.query(soqlStr))
            results.add(new SelectableAccount((Account)acc));

        system.debug('results ' +results);        
        if(results.size() == 50)
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.CS_AccountMerge_Warn_Results_Limit));
      }
      catch (Exception ex)
      {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.CS_AccountMerge_Err_Generic_Query + ' \n\n ' + ex.getMessage()));
      }
    } 
    return null;
  }
  
  /**
  * @description boolean method that verifies the search criteria entered by the user 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public boolean validateSearchCrit(){
    //either search text or id is required
    if(String.isEmpty(searchText) && String.isEmpty(searchId)){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CS_AccountMerge_Err_Name_Or_Id_Required));
      return false;    
    }
    //if search text is supplied, it should be at least 3 characters long  
    else if(!string.isEmpty(searchText) && searchText.length() < 3){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CS_AccountMerge_Err_Search_Value_Char));  
      return false;
    }
    //if search id is supplied, it should be at least 5 characters long  
    else if(!string.isEmpty(searchId) && searchId.length() < 5){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CS_AccountMerge_Err_SearchId_Value_Char));  
      return false;
    }
    return true;
  }
  
  /**
  * @description page reference method that navigates to step 2 of account merge (selection of the winning record) 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public PageReference navigateToMergePage() {
     //if account is supplied, only 1 account from the search result must be selected
         system.debug('%%1 ' + results);
         
         if(withSourceAccount && getSelectedAccounts().size() != 1){  
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.CS_AccountMerge_Err_One_Req_Account));
            return null;
         }
         //if no account is supplied, 2 accounts must be selected from the search results
         else if(!withSourceAccount && getSelectedAccounts().size() != 2){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.CS_AccountMerge_Err_Two_Req_Accounts));
            return null;
         }  
         else{
            PageReference pg = Page.AccountMergeSelection;
            return pg;
         }
    }
  
  /**
  * @description page reference method that calls the generic merge account helper. Logs any validation or run time exceptions. 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public PageReference performMerge(){
    final String CLASSNAME = '\n\n**** AccountMergeController.METHODNAME()';
       final string METHODNAME = CLASSNAME.replace('METHODNAME','performMerge');
       Logger.push(METHODNAME, Schema.Account.getSObjectType().getDescribe().getName());
    // Create a savepoint while AccountNumber is null
    Savepoint sp = Database.setSavepoint();
    try{
      AccountMergeHelper mergeHlp = new AccountMergeHelper();
      string res = '';


      for(Account acc : selAccList){
          if(acc.AccountStatus__c == 'Fraud'){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Accounts having Fraud Account Status cannot be included in merge'));
              return null;
          }

      }

      
      if(selAccList[0].Id == selectedAccountId){
        res = mergeHlp.mergeAccounts(selAccList[0].Id, selAccList[1].Id);
      }
      else{
        res = mergeHlp.mergeAccounts(selAccList[1].Id, selAccList[0].Id);
      }
      //verify if the returned message is 'success'. Otherwise, throw the exception or custom error message
      if(res == Label.CS_AccountMerge_Info_Success_Merge){
        return new PageReference('/' + selectedAccountId);
      }
      else{
        Logger.debugException(Label.CS_AccountMerge_Err_Generic_Merge + ' ' + res);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res));
      }
      
    }
    catch(exception e){
      // Rollback to the previous null value
      Database.rollback(sp);
      Logger.debugException(Label.CS_AccountMerge_Err_Generic_Merge + ' ' + e.getMessage());
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
    Logger.pop();
    return null;
  } 
  
  /**
  * @description page reference method that navigates to step 1 of account merge (accounts search) 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public PageReference navigateToSearch(){
    PageReference pg=  Page.AccountMerge;
        return pg;
  }
  
  /**
  * @description wrapper class to hold the two selected accounts 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public class selectionWrapper{
    
    public string fieldName   {get;set;}
    public string frAccFldVal  {get;set;}
    public string scAccFldVal  {get;set;}
    public boolean isSel    {get;set;}
    
    public selectionWrapper(boolean isSel, string fieldName, string frAccFldVal, string scAccFldVal){
      this.isSel      = isSel;
      this.fieldName     = fieldName;
      this.frAccFldVal   = frAccFldVal;
      this.scAccFldVal   = scAccFldVal;
    }
    
  }
  
  /**
  * @description returns the winning and losing account records. Built via wrapper to establish standard merge look and feel. 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
    public List<selectionWrapper> getSelList() {
      selectedAccountId = null;
      List<selectionWrapper> selList = new List<selectionWrapper>();
      selAccList = new List<Account>();
      
      if(withSourceAccount){
        selAccList.add(accnt);
        if(string.isEmpty(selectedAccountId)){
          selectedAccountId = accnt.Id;
        }  
      }
    
    selAccList.addAll(getSelectedAccounts());
    //winning record selection row
    selList.add(new selectionWrapper(true,  Label.CS_AccountMerge_Sel_Table_Select_Text, null, null));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_1, selAccList[0].CreatedDate.format(), selAccList[1].CreatedDate.format()));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_2, selAccList[0].DomesticHQAccount__r.Name, selAccList[1].DomesticHQAccount__r.Name));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_3, selAccList[0].NewspaperStatus__c, selAccList[1].NewspaperStatus__c));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_4, selAccList[0].DUNSNumber, selAccList[1].DUNSNumber));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_5, string.ValueOf(selAccList[0].Score__c), string.ValueOf(selAccList[1].Score__c)));
    selList.add(new selectionWrapper(false, Label.CS_AccountMerge_Sel_Table_Fld_6, selAccList[0].GlobalUltimateDUNSNumber__c, selAccList[1].GlobalUltimateDUNSNumber__c));
    selList.add(new selectionWrapper(false, Label.CS_Account_Merge_Sel_Table_Fld_7, selAccList[0].AccountStatus__c, selAccList[1].AccountStatus__c)); 
    selList.add(new selectionWrapper(false, Label.CS_Account_Merge_Sel_Table_Fld_8, selAccList[0].AccountID__c, selAccList[1].AccountID__c)); 
    selList.add(new selectionWrapper(false, Label.CS_Account_Merge_Sel_Table_Fld_9, string.ValueOf(selAccList[0].CustomerLapsedDate__c), string.ValueOf(selAccList[1].CustomerLapsedDate__c))); 
    selList.add(new selectionWrapper(false, Label.CS_Account_Merge_Sel_Table_Fld_10, string.ValueOf(selAccList[0].MaxActivityDate__c), string.ValueOf(selAccList[1].MaxActivityDate__c))); 
    selList.add(new selectionWrapper(false, Label.CS_Account_Merge_Sel_Table_Fld_11, string.ValueOf(selAccList[0].RegistrationNumber__c), string.ValueOf(selAccList[1].RegistrationNumber__c))); 
    
       return selList;
    } 

  /**
  * @description returns the account or accounts selected by the user from the search result. 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public List<Account> getSelectedAccounts() {
        List<Account> accounts = new List<Account>();
        if (getShowResults()) {
            for (SelectableAccount sa : results) {
                if (sa.isSelected) {
                    accounts.add(sa.record);
                }
            }
        }
        
        return accounts;
    }
  
  /**
  * @description boolean method that determines the size of the search result 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public boolean getShowResults() {
        return (results!=null && results.isempty()==false);
    }
  
  /**
  * @description wrapper class that holds the list of accounts from the search with an additional boolean attribute for selection. 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
  public class SelectableAccount {
        public Account record {get;set;}
        public Boolean isSelected {get;set;}
        
        public SelectableAccount (Account record) {
            this.record = record;
            this.isSelected = false;
        }
    }
    
  /**
  * @description page reference for the end user to return to the previous screen. 
  * @author Cloudsherpas
  * @date 01-06-2015
  * @last modified 01-15-2015
  */
    public PageReference cancel(){
      //if account id is supplied, return the user to the account's detail screen
      if(accId != null){
        return new PageReference('/' + accId);
      }
      //if no account id is supplied, return the user to the account tab.
      else{
        return new PageReference ('/001');
      }
    }  
}