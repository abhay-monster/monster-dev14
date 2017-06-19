/*
** @author : Cloud Sherpas Inc.
** @date : 03/11/2014
** @description : AccountTeam Controller Class
*/
public without sharing class AccountTeamCC {
    
    final String CLASSNAME = '\n\n**** AccountTeamCC.METHODNAME()';
    list<Account_Team_Member__c> accountTeamMembersToUpsert;
    boolean error = false;
    
/******************* PROPERTIES ******************************/
     private boolean containSalesRep{get;set;}  
    public list<Account_Team_Member__c> CurrentCustomAccountTeamMember{
        get{
            if(CurrentCustomAccountTeamMember == null){
                String accountId = ApexPages.currentPage().getParameters().get('aid');
                CurrentCustomAccountTeamMember = [SELECT Id, AccountAccessLevel__c, AccountId__c, UserId__c, TeamMemberRole__c FROM Account_Team_Member__c WHERE AccountId__c = :accountId];
            }
            return CurrentCustomAccountTeamMember;
        }
        set;
    }
    public list<Account_Team_Member__c> CustomAccountTeamMemberList{
        get{
            if(CustomAccountTeamMemberList == null){
                CustomAccountTeamMemberList = new list<Account_Team_Member__c>();
            }
            return CustomAccountTeamMemberList;
        }
        set;
    }
    public Account TeamAccount{get;set;}
    public String TeamAccountId{get;set;}
    
/*********************** CONSTRUCTOR ********************************$$$  

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : constructor
** @paramaters : none
** @returns : nothing
*/  
    public AccountTeamCC(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AccountTeamCC') + ' - constructor';
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        containSalesRep = false;
        TeamAccountId = ApexPages.currentPage().getParameters().get('aid');
        TeamAccount = [Select Id, Name, AccountTeam__c, DateLastTeamed__c, DateLastUnTeamed__c From Account Where Id =:TeamAccountId];
        
        for(Integer i = 0; i < 5; i++){
            CustomAccountTeamMemberList.add(new Account_Team_Member__c(AccountId__c=TeamAccountId));            
        } 
              
    }
    
/********************************* PUBLIC METHODS *********************************$$$
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/14/2014
** @description : Deletes all Account Team Members except the Promary Sales rep and Updates 
**                Account Teamed Flag, Date Last Teamed and Date Last UnTeamed Account fields 
** @paramaters : none
** @returns : PageReference
*/  
    public PageReference DeleteAll(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnClick_Cancel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        // set Team Account Id property with the URL parameter
        TeamAccountId = ApexPages.currentPage().getParameters().get('aid');
        
        if(ApexPages.currentPage().getParameters().get('act') == 'removeall'){
                    
            DeleteAllAccountTeamMembers();          
            UpdateAccountTeamedFlagAndDates(false, null, System.Now());
            
            PageReference pgRef = new PageReference('/'+ TeamAccountId);
            pgRef.setRedirect(true);
            return pgRef;
        }
        else{
            return null;
        }   
    }   

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Cancel out of the Add new Account Team Member page and return to Account
** @paramaters : none
** @returns : PageReference
*/  
    public PageReference OnClick_Cancel(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnClick_Cancel');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        PageReference pgRef = new PageReference('/' + TeamAccountId);
        pgRef.setRedirect(true);
        return pgRef;

    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Save Account Team Members added to Account Team
** @paramaters : none
** @returns : PageReference
*/
    public PageReference OnClick_Save(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnClick_Save');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        PageReference pgRef;

            UpsertListOfAccountTeamMembersToUpsert();

            if(accountTeamMembersToUpsert == Null){return null;}    
            pgRef = new PageReference('/' + TeamAccountId);
            pgRef.setRedirect(true);
                


             return pgRef;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Save Account Team Members added to Account Team and returns to the Add Account Team Member page to 
**                with a clear grid.
** @paramaters : none
** @returns : PageReference
*/  
    public PageReference OnClick_SaveAndMore(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnClick_SaveAndMore');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UpsertListOfAccountTeamMembersToUpsert();
        if(accountTeamMembersToUpsert == Null){return null;} 
        PageReference pgRef = new PageReference('/apex/AccountTeam?aid=' + this.TeamAccountId);
        pgRef.setRedirect(true);
        return pgRef;
    }

/******************************* PRIVATE METHODS ***************************************$$$

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Returns a list of Custom Account Team Members to Upsert
** @paramaters : none
** @returns : List of Custom Account Team Member objects
*/  
    private list<Account_Team_Member__c> CreateListOfAccountTeamMembersToUpsert(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateListOfAccountTeamMembersToUpsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
         // create a list of Account_Team_Member__c to upsert
        list<Account_Team_Member__c> accountTeamMembersToUpsert = new list<Account_Team_Member__c>();
        
        // create a User Id to Account_Team_Member__c map and load with current Account_Team_Member__c;
        map<Id,Account_Team_Member__c> userIdToAccountTeamMemberMap = new map<Id,Account_Team_Member__c>();        
        if(!CurrentCustomAccountTeamMember.IsEmpty()){
            for(Account_Team_Member__c currentAccountTeamMember : CurrentCustomAccountTeamMember){
                userIdToAccountTeamMemberMap.put(currentAccountTeamMember.UserId__c, currentAccountTeamMember);
            }
        } 
             
        for(Account_Team_Member__c oAccountTeamMember : CustomAccountTeamMemberList){
            if(!String.IsBlank(oAccountTeamMember.UserId__c) && !String.IsBlank(oAccountTeamMember.TeamMemberRole__c)){
                        
                if(userIdToAccountTeamMemberMap.ContainsKey(oAccountTeamMember.UserId__c)){ 
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not add the same team member twice')); return null;
                    /*userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c).AccountId__c = oAccountTeamMember.AccountId__c;
                    userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c).AccountAccessLevel__c = oAccountTeamMember.AccountAccessLevel__c;
                    userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c).OpportunityAccessLevel__c = oAccountTeamMember.OpportunityAccessLevel__c;
                    userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c).CaseAccessLevel__c = oAccountTeamMember.CaseAccessLevel__c;
                    userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c).TeamMemberRole__c = oAccountTeamMember.TeamMemberRole__c; 
                    accountTeamMembersToUpsert.add(userIdToAccountTeamMemberMap.get(oAccountTeamMember.UserId__c)); */
                                    
                }else{
                    if(oAccountTeamMember.TeamMemberRole__c == 'Sales Rep'){
                        containSalesRep = true;
                    }
                    accountTeamMembersToUpsert.add(oAccountTeamMember);
                }
            }
        }
        
        return accountTeamMembersToUpsert;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/17/2014
** @description : Deletes all Account Team Members except the Primary Sales Rep
** @paramaters : none
** @returns : noting
*/  
    private void DeleteAllAccountTeamMembers(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','DeleteAllAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        list<Account_Team_Member__c> accountTeamMemberList = [SELECT Id, TeamMemberRole__c FROM Account_Team_Member__c WHERE AccountId__c = :TeamAccountId AND TeamMemberRole__c != 'Primary Sales Rep'];
        
        try{
            delete accountTeamMemberList;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Deletion of all Account Team Members failed');
        }       
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/17/2014
** @description : Updates the Account Team flag, Date Last Teamed, Date Last UnTeamed Account Fields
** @paramaters : none
** @returns : nothing
*/  
    private void UpdateAccountTeamedFlagAndDates(Boolean pTeamed, DateTime pDateLastTeamed, DateTime pDateLastUnTeamed){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateAccountTeamedFlagAndDates');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        //if(pTeamed != null){
        //    TeamAccount.AccountTeam__c = pTeamed;
        //}
        List<Account_Team_Member__c> ATMList =[SELECT Id FROM Account_Team_Member__c WHERE Id =: TeamAccountId AND TeamMemberRole__c = 'Sales Rep'];
        if(pDateLastTeamed != null  && ATMList.isEmpty() && containSalesRep == true){
            TeamAccount.DateLastTeamed__c = pDateLastTeamed;
            TeamAccount.AccountTeam__c = true;
        }
        system.debug('^ATMList: '+ATMList);
        
        if(pDateLastUnTeamed != null && ATMList.isEmpty()){
            TeamAccount.DateLastUnTeamed__c = pDateLastUnTeamed;
            TeamAccount.AccountTeam__c = false;
        }
        
        try{
            update TeamAccount;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Account Teamed Flag and Dates failed');
        }       
    }
     
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/11/2014
** @description : Upserts a List of Custom Account Team Members
** @paramaters : none
** @returns : nothing
*/  
    private void UpsertListOfAccountTeamMembersToUpsert(){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpsertListOfAccountTeamMembersToUpsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        accountTeamMembersToUpsert = CreateListOfAccountTeamMembersToUpsert();
        
        try{
            if(accountTeamMembersToUpsert !=null && !accountTeamMembersToUpsert.IsEmpty()){
                if(!TeamAccount.AccountTeam__c){
                    UpdateAccountTeamedFlagAndDates(true,System.now(),null);
                }
                upsert accountTeamMembersToUpsert;
                
            }
        }catch(BaseApplicationException beaex){
            throw beaex;
        }catch(DMLException dmlex){
            throw BaseApplicationException.NewException(METHODNAME, dmlex.getMessage(), 'Update to Account Teamed Flag and Dates failed');
        }
    } 
}