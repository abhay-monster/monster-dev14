/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : Account trigger class to handle CRUD events.
*/
public without sharing class AccountTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** AccountTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    private TriggerHelperWithoutSharing helperwoutsharing;
    private AccountTriggerHelper accountHelper;
    private Profile CurrentUserProfile;
    public static Boolean ExecuteTriggers = true;
    public static Integer RunCount = 0;
    public static Boolean SKIP_BEFORE_UPDATE = false;
    public static Set<Id> onBeforeUpdateAccountIds = new Set<Id>(); //JFreese Appirio S-435483 4/10/17
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/10/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
public AccountTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;//

        // set current User profile

            // intantiate new trigger helper
            helperwoutsharing = TriggerHelperWithoutSharing.getInstance();
            helper = TriggerHelper.NewTriggerHelper();
            accountHelper = AccountTriggerHelper.NewTriggerHelper();


        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
            */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
public void OnBeforeInsert(Account[] pAccount, map<ID, Account> pAccountIdToNewAccountMap){
    system.debug('pAccount1'+pAccount);
    if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Account a : pAccount){
                System.debug('^^^ MAPP BeforeInsert Account ' + a);
            }
        }

            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                //T-416900
                //populate our helper variables for querying
                accountHelper.ResetQueries();
                accountHelper.AccountList = pAccount;
                accountHelper.updatePostingAddressFromLeadConvert(pAccount, pAccountIdToNewAccountMap);
                // T-414735 - Check permission for creating account directly without conversion
                accountHelper.validateCreateAccountPermission(pAccount);
                accountHelper.updateCreditLimtforAccounts(pAccount, null); //commented out for Justin's Demo
                accountHelper.UpdateParentThruDandBCompany1(pAccount);
                accountHelper.populateGlobalHQAccount1(pAccount);
                accountHelper.populateGlobalHQAndParentAccount(pAccount);
                accountHelper.populateAccountProgram(pAccount);
                accountHelper.CheckIsGlobalHQ(pAccount, false);
                accountHelper.AssignAccountsFromMAPP(pAccount);
                accountHelper.populateprimaryAgencyContact(pAccount,null);
                // Added by DinoBrinas
                // Story 1002, Task 1919
                accountHelper.populateAccountParent(pAccount);
                accountHelper.populateIsGlobalHQ(pAccount);
                //populatePaymentDetailField(pAccount, null);
                //T-429332
                nullifyDComapny(pAccount,null);
                populatePaymentFrequency(pAccount);
                if(UserInfo.getName() == 'Integration MAPP'){
                  //accountHelper.insertCustomerNumberforAccounts(pAccount);//AP
                  //accountHelper.populateEcommCustomerNumber(pAccount);//AP
                  accountHelper.updateAccountSizeForMapp(pAccount,null);
                //accountHelper.PopulateEcommPrimarySalesRep(pAccount);
                }

                //system.debug('adpAccount3' + pAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                           */
                for(Account a : pAccount){
                    system.debug('^^^ AccountTriggerHandler End of OnBeforeInsert - pAccount owner=' + a.ownerId);
                }
                if(UserInfo.getName() == 'Integration MAPP'){
                    for(Account a : pAccount){
                        System.debug('^^^ MAPP End of BeforeInsert Account ' + a);
                    }
                }
            }
            else{
                system.debug('^^^ AccountTriggerHandler Bypassed OnBeforeInsert ExecuteTriggers=' + ExecuteTriggers + ', IsTriggerContext=' + IsTriggerContext + ', IsVisualforcePageContext=' + IsVisualforcePageContext + ', IsWebServiceContext=' + IsWebServiceContext + ', IsExecuteAnonymousContext=' + IsExecuteAnonymousContext);
            }

        }
    /*
    private static void nullifyAccountFields(List<Account> lstAccount ,Map <Id,Account> oldAccountMAp ) {
        system.debug('**** Inside \n\n**** AccountTriggerHandler.nullifyAccountFields');

        //No need to requery this Jeff L.
        //lstAccount = [SELECT ID,shippingCity,shippingState ,shippingCountry ,dunsNumber  from account where  ID IN  :lstAccount] ;
        Set<Id> accSetId = new Set<Id>();
        Set<Id> cleanedAccountSet = new Set<Id>();
        Map<Id,DateTime> lastModifiedDetails = new Map<Id,DateTime>();
        List<account> accLstToUpdate = new List<Account>();


        for(AccountCleanInfo info : [Select AccountId ,LastStatusChangedDate From AccountCLeanInfo WHERE AccountId IN : lstAccount  ]){

            DateTime StartDate = Datetime.now().addSeconds(-20);

            if(info.LastStatusChangedDate >= StartDate ){

                system.debug('%%info.LastStatusChangedDate%%%' + info);
                lastModifiedDetails.put(info.AccountId,info.LastStatusChangedDate);
            }

        }


        for(Account acc: lstAccount){

            //if(accSetId.contains(acc.Id)){
            if(lastModifiedDetails.containsKey(acc.id)){

                acc.DunsNumber = oldAccountMap.get(acc.Id).DunsNumber;
                system.debug('###acc###' + acc);
                }else if (!lastModifiedDetails.containsKey(acc.id)   && ((acc.shippingCity != oldAccountMAp.get(acc.Id).shippingCity) ||
                    (acc.shippingState != oldAccountMAp.get(acc.Id).shippingState) ||
                    (acc.shippingCountry != oldAccountMAp.get(acc.Id).shippingCountry))){

                    acc.DunsNumber = null;
                    acc.DandbCompanyId = null;
                    acc.DBEmployeeSite__c = null ;
                    acc.DBEmployeeTotal__c = null;
                   }
            accLstToUpdate.add(acc);

        }

        if(accLstToUpdate.size()>0)
            DataBase.update(accLstToUpdate);

    }
*/


/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Account objects
** @returns : nothing
*/
public void OnAfterInsert(Account[] pAccount, map<ID, Account> pAccountIdToNewAccountMap, map<ID, Account> pAccountIdToOldAccountMap){

    if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Account a : pAccount){
                System.debug('^^^ MAPP AfterInsert Account ' + a);
            }
        }

        if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            //populate our helper variables for querying
            accountHelper.ResetQueries();
            accountHelper.AccountList = pAccount;
            // Create Primary Sales and Service Rep on New Account Creation
            helper.CreatePrimaryAccountTeamMembers(pAccount);
            //accountHelper.UpdateAccountCurrencyBasedOnPostingCountry(pAccountIdToNewAccountMap);
            accountHelper.MarkDomesticAndGlobalAccount(pAccount, null);
            accountHelper.associatePersonAccountToRelatedCase(pAccount, pAccountIdToOldAccountMap);
            CSW_USPSModel.UpdateAccountAddress(pAccount, null);
            updateOrderFieldFromAccount(pAccount, null);
            //Jeff L commented this out 3/23/2016
            //updateLocalAgencyCustAndVATField(pAccountIdToOldAccountMap, pAccount);
            /*
                note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                       and call the methods from handler.
                       */
            accountHelper.AccountWithoutTerritory(pAccount);
            if(UserInfo.getName() == 'Integration MAPP'){
               // accountHelper.insertCustomerNumberforAccounts(pAccount);//AP
               accountHelper.populateEcommCustomerNumber(pAccount);//AP
               createCaseforAlphaAccounts(pAccount);

            }
            accountHelper.AssignPaymentDetails(pAccount); //set default PaymentDetails__c
            //system.debug('adpAccount3' + pAccount);

            accountHelper.SetParentLevelNeedsUpdating(pAccount, null);

            for(Account a : pAccount){
                system.debug('^^^ AccountTriggerHandler End of OnAfterInsert - pAccount owner=' + a.ownerId);
            }
        }
        else{
            system.debug('^^^ AccountTriggerHandler Bypassed OnAfterInsert ExecuteTriggers=' + ExecuteTriggers + ', IsTriggerContext=' + IsTriggerContext + ', IsVisualforcePageContext=' + IsVisualforcePageContext + ', IsWebServiceContext=' + IsWebServiceContext + ', IsExecuteAnonymousContext=' + IsExecuteAnonymousContext);
        }


    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014, last modified 12/23/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
public void OnBeforeUpdate(Account[] pOldAccounts, Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap, map<ID, Account> pAccountIdToUpdatedAccountMap){
    for (Account acc : pUpdatedAccounts) {
        onBeforeUpdateAccountIds.add(acc.Id); //JFreese Appirio S-435483 4/10/17
    }

    String customerNum;
    for (Account acc : pUpdatedAccounts) {
        customerNum = acc.CustomerNumber__c;
        if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
            System.debug('----OnBeforeUpdate BEFORE ' + acc.Name + ' parent=' + acc.ParentId+', GlobalHQAccount__c='+acc.GlobalHQAccount__c);
        }
    }
    //if(UserInfo.getName() != 'Integration MAPP'){//I-247190
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
                return; // If triggers are off, then exit the method
            }
            final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            system.debug('>>1beforecount' + RunCount);
            if(AccountTriggerHandler.RunCount > 0 || SetSendToEmailFlag.byPassTrigger){
                if(UserInfo.getName() == 'Integration MAPP' && customerNum == null ){
                    system.debug('customernumber is null for ecomm, need to proceed');
                } //I-247190
                else{
                system.debug('^^^ AccountTriggerHandler Bypassing OnBeforeUpdate Runcount='+AccountTriggerHandler.RunCount);
                return;
                }
            }
        //}

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Account a : pUpdatedAccounts){
                System.debug('^^^ MAPP BeforeUpdate Account ' + a);
            }
        }

        if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext )){
            /*JFreese Appirio S-435483 4/6/17 If changing the account owner/TerritoryCode__c/TA_RunID__c
              (e.g. we are running the TA Queueable process), check to see if we are bypassing all custom validation rules*/
            Boolean bypassValidationRules = boolean.valueOf(accountHelper.batchSetting.get('Bypass_Validation_Rules__c'));
            system.debug('^^^Bypass validation rules when account owner/TerritoryCode__c/TA_RunID__c is changed = '+bypassValidationRules);
            if (bypassValidationRules){
                for(Account a : pUpdatedAccounts){
                    if(a.ownerId != pAccountIdToOldAccountMap.get(a.Id).ownerId ||
                       a.TerritoryCode__c != pAccountIdToOldAccountMap.get(a.Id).TerritoryCode__c ||
                       a.TA_RunID__c != pAccountIdToOldAccountMap.get(a.Id).TA_RunID__c)
                    {
                        a.Bypass_All_Validation_Rules__c = true;
                    }
                }
            }

            List<Account> UpdateGlobal = new List<Account>();
            List<Account> AccountOldList = new List<Account>();
            List<Account> AccountList = new List<Account>();
            System.debug('CHECK 1');
            //populate our helper variables for querying
            accountHelper.ResetQueries();
            accountHelper.AccountList = pUpdatedAccounts;
            accountHelper.OldAccountMap = pAccountIdToOldAccountMap;
            //accountHelper.updateHierarchyLock(pUpdatedAccounts, pAccountIdToOldAccountMap);
            System.debug('CHECK 2');

            accountHelper.UpdatePhoneNumberFormat(pUpdatedAccounts);
            accountHelper.UpdateAccountOwner(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.updateAccountTeamAndDateLastUnTeamed(pUpdatedAccounts, pAccountIdToUpdatedAccountMap);
            accountHelper.updateAccountTeamCheckbox(pUpdatedAccounts, pAccountIdToOldAccountMap);
            if(SetSendToEmailFlag.fromTerritory){
                system.debug('^^^ AccountTriggerHandler Exiting OnBeforeUpdate SetSendToEmailFlag.fromTerritory=' + SetSendToEmailFlag.fromTerritory);
                return;
            }
            for (Account acc : pUpdatedAccounts) {
                if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    System.debug('----OnBeforeUpdate MID ' + acc.Name + ' parent=' + acc.ParentId+', GlobalHQAccount__c='+acc.GlobalHQAccount__c);
                }
            }
            accountHelper.UpdateParentThruDandBCompany(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.updateHierarchyLock(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.updateAccountFields(pUpdatedAccounts, pAccountIdToUpdatedAccountMap,pAccountIdToOldAccountMap);
            accountHelper.PopulatePrimaryAgencyContact(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.updateCreditLimtforAccounts(pUpdatedAccounts, pAccountIdToOldAccountMap); //commented out for Justin's Demo
            accountHelper.updateDescendantsOftheUpdatedAccount(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.populateAccountProgram(pOldAccounts, pUpdatedAccounts);
            //accountHelper.updateAccountProgramInDescendants(pUpdatedAccounts, pAccountIdToOldAccountMap);//for populating Account Program Field from Parent to all the Hierarchical descendands
            accountHelper.CheckParentandGlobalHQAccountFields(pUpdatedAccounts, pAccountIdToOldAccountMap);
            accountHelper.updateAccountParent(pUpdatedAccounts);
            accountHelper.populateIsGlobalHQ(pUpdatedAccounts);

            //Sberron - I-248103 - 12/18/16
            //Moved as these were being called before parentId was updated
            //THESE ACCOUNTS ARE A BLOCK - KEEP TOGETHER
            for(Account acc: pUpdatedAccounts){
                if(acc.Parentid != null && acc.ParentId != pAccountIdToOldAccountMap.get(acc.Id).ParentId)
                UpdateGlobal.add(acc);

                if(acc.ParentId != pAccountIdToOldAccountMap.get(acc.Id).ParentId){
                    AccountList.add(acc);
                }
                if(acc.ParentId == null){
                    AccountOldList.add(acc);
                }
            }

            if(!AccountList.isEmpty()){
                accountHelper.populateGlobalHQAccount1(AccountList);
            }
            if(!UpdateGlobal.isEmpty()){
                accountHelper.CheckIsGlobalHQ(UpdateGlobal,true);
            }
            if(!AccountOldList.isEmpty()){
                accountHelper.uncheckIsGlobalHQCheckbox(AccountOldList, pAccountIdToOldAccountMap);
            }
            //END BLOCK

            //populateprimaryAgencyContact(pUpdatedAccounts,pAccountIdToOldAccountMap);

            populatePaymentDetailField(pUpdatedAccounts, pAccountIdToOldAccountMap);
            updatePostingAddressIsDifferent(pAccountIdToUpdatedAccountMap);
            nullifyDComapny(pUpdatedAccounts, pAccountIdToOldAccountMap);
            if(UserInfo.getName() == 'Integration MAPP'){
                accountHelper.updateAccountSizeForMapp(pUpdatedAccounts,pAccountIdToOldAccountMap);
            }
            System.debug('CHECK 3');
        }
        else{
            system.debug('^^^ AccountTriggerHandler Bypassed OnBeforeUpdate ExecuteTriggers=' + ExecuteTriggers + ', IsTriggerContext=' + IsTriggerContext + ', IsVisualforcePageContext=' + IsVisualforcePageContext + ', IsWebServiceContext=' + IsWebServiceContext + ', IsExecuteAnonymousContext=' + IsExecuteAnonymousContext);
        }
             //   updateOrderLineItemOwner(pUpdatedAccounts);
        for (Account acc : pUpdatedAccounts) {
            if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                System.debug('----OnBeforeUpdate AFTER ' + acc.Name + ', parent=' + acc.ParentId+', owner=' + acc.ownerId+', GlobalHQAccount__c='+acc.GlobalHQAccount__c);
            }
        }
}
/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/
public void OnAfterUpdate(Account[] pOldAccounts, Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap, map<ID, Account> pAccountIdToUpdatedAccountMap){
    String customerNum;
    //System.assert(false, 'Before Update getting called');
    System.debug('** In After Update **');
    for (Account acc : pUpdatedAccounts) {
        customerNum = acc.CustomerNumber__c;
        if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
            System.debug('----OnAfterUpdate BEFORE ' + acc.Name + ', parent=' + acc.ParentId+', GlobalHQAccount__c='+acc.GlobalHQAccount__c);
        }
    }

        if (Personal_Settings__c.getInstance().trigger_account__c==false){
                return; // If triggers are off, then exit the method
            }

            if(AccountTriggerHandler.RunCount > 0){
                if(UserInfo.getName() == 'Integration MAPP' && customerNum == null ){//I-247190
                     system.debug('customernumber is null for ecomm, need to proceed');
                }
                else{
                system.debug('^^^ AccountTriggerHandler Bypassing OnAfterUpdate Runcount='+AccountTriggerHandler.RunCount);
                return;
                }
            }
            RunCount++;
            if(SetSendToEmailFlag.byPassTrigger){
                 /*if(UserInfo.getName() == 'Integration MAPP' && customerNum == null ){
                     system.debug('customernumber is null for ecomm, need to proceed');
                }*/
                //else{
                system.debug('^^^ AccountTriggerHandler Bypassing OnAfterUpdate SetSendToEmailFlag.byPassTrigger='+SetSendToEmailFlag.byPassTrigger);
                return;
                //}
            }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('>>1aftercount' + RunCount);

        if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            //populate our helper variables for querying
            for (Account acc : pUpdatedAccounts) {
                if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    System.debug('----Acct parent BEFORE methods ' + acc.Name + ' parent=' + acc.ParentId);
                }
            }
            System.debug('AFTER CHECK 1');
            accountHelper.ResetQueries();
            for (Account acc : pUpdatedAccounts) {
                if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    System.debug('----Acct parent after ResetQueries ' + acc.Name + ' parent=' + acc.ParentId);
                }
            }
            accountHelper.AccountList = pUpdatedAccounts;
            accountHelper.OldAccountMap = pAccountIdToOldAccountMap;


            updateOrderLineItemOwner(pUpdatedAccounts, pAccountIdToOldAccountMap);
            for (Account acc : pUpdatedAccounts) {
                if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                    System.debug('----Acct parent after updateOrderLineItemOwner ' + acc.Name + ' parent=' + acc.ParentId);
                }
            }

            updateOrderLineItemXCode(pUpdatedAccounts, pAccountIdToOldAccountMap);
            updateOrderFieldFromAccount(pUpdatedAccounts, pAccountIdToOldAccountMap);

            //TKOM - S-445899 - commenting out entire method - emails sent by workflow instead
            //accountHelper.sendEmailWhenAccountStatusChange(pUpdatedAccounts, pAccountIdToUpdatedAccountMap, pAccountIdToOldAccountMap);

            updateAccountTeamMembers(pUpdatedAccounts,pAccountIdToOldAccountMap,pAccountIdToUpdatedAccountMap);
            //I-186498
            // GG ---------------- updateProposalOwner(pUpdatedAccounts, pAccountIdToOldAccountMap);
            /*
            JPL Commented out - this logic actually gets handled inside of ChangeProposalOwner
            set<Id> AccountThatHasOwnerChanged = new set<Id>();
            for(Account a : pUpdatedAccounts){
                if(a.OwnerId != pAccountIdToUpdatedAccountMap.get(a.Id).OwnerId){
                    AccountThatHasOwnerChanged.add(a.Id);
                }
            }
            updateProposalOwner2(AccountThatHasOwnerChanged);*/
            //AP I-167039

            //Appirio J Freese I-221832 moved whenPrimarySalesRepChanged from updateAccountTeamMembers()
            //to here so that it will process the children when the TA_RunID changes
            //JFreese Appirio S-435483 4/10/17 Pass the list of original Ids so we can see if any failed to update
            accountHelper.whenPrimarySalesRepChanged(pUpdatedAccounts, pAccountIdToOldAccountMap, onBeforeUpdateAccountIds);
           /* if(UserInfo.getName() != 'Integration MAPP'){
                accountHelper.updateCustumerNumberforAccounts(pUpdatedAccounts, pAccountIdToOldAccountMap);
            }*/
            CSW_USPSModel.UpdateAccountAddress(pUpdatedAccounts, pAccountIdToOldAccountMap);
            //nullifyAccountFields(pUpdatedAccounts,pAccountIdToOldAccountMap);

            accountHelper.SetParentLevelNeedsUpdating(pUpdatedAccounts, pAccountIdToOldAccountMap);
            /*if(!System.isFuture()){ JFreese 2/6/17 S-453964 No updates to hierarchical descendents per DMenard
                //to be skipped if the method is being called from a Future call
                accountHelper.updateAccountProgramInDescendants(pUpdatedAccounts, pAccountIdToOldAccountMap);//for populating Account Program Field from Parent to all the Hierarchical descendands - S-453964
            }*/
            System.debug('AFTER CHECK 2');
            for(Account acc : pUpdatedAccounts){
                if (pUpdatedAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/10/17
                   system.debug('----OnAfterUpdate AFTER ' + acc.name + ' parent=' + acc.ParentId + ', owner=' + acc.ownerId+', GlobalHQAccount__c='+acc.GlobalHQAccount__c);
                }
            }
        }
        else{
            system.debug('^^^ AccountTriggerHandler Bypassed OnAfterUpdate ExecuteTriggers=' + ExecuteTriggers + ', IsTriggerContext=' + IsTriggerContext + ', IsVisualforcePageContext=' + IsVisualforcePageContext + ', IsWebServiceContext=' + IsWebServiceContext + ', IsExecuteAnonymousContext=' + IsExecuteAnonymousContext);
        }
   }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, map of old Accounts
**  @returns : nothing
*/
   /*public void OnBeforeDelete(Account[] pOldAccounts, map<ID, SObject> pAccountMapOld){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                           */
        /*    }

        }*/

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Account objects, map of old Accounts
**  @returns : nothing
*/  /*
    public void OnAfterDelete(Account[] pOldAccounts, map<ID, SObject> pAccountMapOld){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                           */
       /*     }

    }
    */
/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new Account object
**  @returns : nothing
*/       /*
    public void OnUndeleted(Account[] pUndeletedAccounts){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));


            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                           */
       /*     }

       }*/


 private static void nullifyDComapny(List<Account>newAccLst , Map <Id,Account> oldAccountMap){
           system.debug('**** Inside \n\n**** AccountTriggerHandler.nullifyDComapny');

           Boolean isInsert = false;

           if(oldAccountMap == null){
               IsInsert  = true;
           }

           for(Account acc : newAccLst){
                //Sly - Appirio (I-159841)   - handling removing duns information when clean status is not found
                /*if((!isInsert && acc.DunsNumber == null && oldAccountMap.get(acc.id).DunsNumber != null)
                    || (!isInsert && acc.cleanStatus=='NotFound' && oldAccountMap.get(acc.id).cleanStatus != 'NotFound' )){*/
                if(!isInsert && ( (acc.DunsNumber == null && oldAccountMap.get(acc.id).DunsNumber != null)
                            || (acc.cleanStatus=='NotFound' && oldAccountMap.get(acc.id).cleanStatus != 'NotFound')
                            || (acc.CustomerNumber__c == null && oldAccountMap.get(acc.id).CustomerNumber__c != null)
                            || acc.ShippingCity != oldAccountMap.get(acc.id).ShippingCity || acc.ShippingCountry != oldAccountMap.get(acc.id).ShippingCountry
                            || acc.ShippingState != oldAccountMap.get(acc.id).ShippingState || acc.ShippingPostalCode != oldAccountMap.get(acc.id).ShippingPostalCode
                            || acc.ShippingStreet != oldAccountMap.get(acc.id).ShippingStreet || acc.Name != oldAccountMap.get(acc.id).Name) ){
                     //Update Start By Vivek for I-182496
                    acc.DunsNumber = '';
                    acc.DandbCompany = null;
                    acc.AnnualRevenue = null;
                    acc.TickerSymbol ='';
                    //acc.Website = ''; //commented by Deepanshu for S-445833
                    acc.Industry = '';
                    acc.Ownership = '';
                    //acc.Phone = '';
                    acc.Fax = '';
                    acc.Site = '';
                    acc.Tradestyle = '';
                    acc.YearStarted = '';
                    acc.Sic = '';
                    acc.SicDesc = '';
                    acc.NaicsCode = '';
                    acc.NaicsDesc = '';
                    acc.Description = '';
                    acc.NumberOfEmployees = null;
                    acc.Industry_ID__c= '';
                    acc.Jigsaw= '';
                    //Update  End By Vivek for I-182496
                    acc.DandbCompanyId = null;
                    acc.DBEmployeeSite__c = null ;
                    acc.DBEmployeeTotal__c = null;

                }/* JHF 1/19/16 Commenting this logic block because it makes no sense; it is erasing the (required)
                    account phone number on the new account save.  In addition, the fix for I-182496 is incorrect
                    and needs to be correctly fixed when we reach the 3,000+ ranked issues.

                else if(IsInsert  && acc.DunsNumber == null){
                 //Update Start By Vivek for I-182496
                    acc.DandbCompany = null;
                    acc.AnnualRevenue = null;
                    acc.TickerSymbol ='';
                    acc.Website = '';
                    acc.Industry = '';
                    acc.Ownership = '';
                    acc.Phone = '';
                    acc.Fax = '';
                    acc.Site = '';
                    acc.Tradestyle = '';
                    acc.YearStarted = '';
                    acc.Sic = '';
                    acc.SicDesc = '';
                    acc.NaicsCode = '';
                    acc.NaicsDesc = '';
                    acc.Description = '';
                    acc.NumberOfEmployees = null;
                    acc.Industry_ID__c= '';
                    acc.Jigsaw= '';
                    //Update  End By Vivek for I-182496
                    acc.DandbCompanyId = null;
                    acc.DBEmployeeSite__c = null ;
                    acc.DBEmployeeTotal__c = null;

              }*/
          }

}



/*
**  @author : ???
**  @date : ???
**  @description :  Update the Order line item with newly set Primary Xcode on the account....
**  @paramaters : array of new Account object
**  @returns : nothing

        updated 01/09/2017 -ASuch for S-456559
*/

   public void updateOrderLineItemXCode(List<Account> listAccounts, map<Id,Account> oldMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderLineItemXCode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order_Line_Item__c> listItems = new List<Order_Line_Item__c>();
        List<Account> accounts = new List<Account>();
        map<string,List<XcodeAccount__c>> mapXcode = new map<string,List<XcodeAccount__c>>();
        map<string, string> mapPrimXCode = new map<string,string>(); //S-456559 account-PrimaryXcode
        if (listAccounts.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
            system.debug('#####checkList##' + listAccounts + oldMap );
        }
        for(Account acc : listAccounts) {
            if (listAccounts.size() <= cutoff || acc.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                system.debug('@@@@@@@@@@@@acc@@@@' +acc);
                system.debug('******acc.Primary_Xcode__c******'+acc.Primary_Xcode__c);
            }
            if(acc.Primary_Xcode__c != null
              && acc.Primary_Xcode__c != oldMap.get(acc.Id).Primary_Xcode__c){
              accounts.add(acc);
              mapPrimXCode.put(acc.Id,acc.Primary_Xcode__c); //S-456559 note the new primary xcode
            }
        }

        if(accounts.isEmpty()) return;

        for(XcodeAccount__c xAcc : [Select Id,Account__c,Xcode__c,Xcode_Name__c from
                                    XcodeAccount__c Where Account__c IN :accounts]){
            //S-456559 new condition - process only for the Primary Xcodes
            if(xAcc.Xcode_Name__c == mapPrimXcode.get(xAcc.Account__c)) {
                if(!mapXcode.containsKey(xAcc.Account__c)) {
                    mapXcode.put(xAcc.Account__c,new List<XcodeAccount__c>());
                }
                mapXcode.get(xAcc.Account__c).add(xAcc);
            }
        }
        if(mapXcode.isEmpty()) return;

        //S-456559 modified query, commenting out limit for OLI, adding limit for Order on status
        for(Order__c order : [Select Account__c,
                                ( Select Xcode_lkp__c,Order__c,Xcode__c From Order_Line_Items__r
                                  //Where Xcode_lkp__c = null OR Xcode__c = null
                                  )
                                  From Order__c
                                  Where OrderStatus__c='Open' AND Account__c IN :mapXcode.keySet()]) {
                   //system.debug('***** size value: ' + mapXcode.get(order.Account__c).size() );
                   if(order.Order_Line_Items__r != null &&
                      mapXcode.containsKey(order.Account__c)
                      && mapXcode.get(order.Account__c).size() == 1){
                       //system.debug('**** inside IF ...');
                       XcodeAccount__c xAcc = mapXcode.get(order.Account__c)[0];
                       for(Order_Line_Item__c orderItem : order.Order_Line_Items__r) {
                         //system.debug('**** inside FOR OLI, adding to listItems...');
                         orderItem.Xcode_lkp__c = xAcc.Id;
                         orderItem.Xcode__c = xAcc.Xcode_Name__c;
                         listItems.add(orderItem);
                       }
                   }
        }
        //system.debug('*** listItems.size = ' + listItems.size());

        if(listItems.size()>0) {
            update listItems;
        }

   }

//Jeff L moved to trigger handler code
/*
private static void populateprimaryAgencyContact(List<Account>newAccLst ,Map<Id,Account> oldAccountMap){

Boolean isInsert = true;
Set<Id> accIdSet = new Set<Id>();
Set<Id> partnerIdSet = new Set<Id>();
Map<Id,Id> accToContactIdMap = new Map<Id,Id>();
Map<Id,Id> accIdToPartnerIdMap = new Map<Id,Id>();
List<Account> lstToBeUpdated = new List<Account>();

if(oldAccountMap != null)
    isInsert = false;

    for(account acc : newAccLst){
        if(isInsert && acc.PrimaryRelatedAgency__c != null){

            accIdSet.add(acc.PrimaryRelatedAgency__c);
        }else if(!isInsert && acc.PrimaryRelatedAgency__c != oldAccountMap.get(acc.id).PrimaryRelatedAgency__c){

            accIdSet.add(acc.PrimaryRelatedAgency__c);
        }
    }

    if(accIdSet.size()>0){
        for(RelatedPartner__c partner : [Select Id,Partner__c,Account__c From RelatedPartner__c Where Id IN : accIdSet]){

            partnerIdSet.add(partner.Partner__c);
            accIdToPartnerIdMap.put(partner.Account__c , partner.Partner__c);
        }
    }

    if(partnerIdSet.size()>0){
        for(Contact con : [Select Id,AccountId From Contact Where AccountId IN : partnerIdSet AND PrimarySalesContact__c = true]){

            accToContactIdMap.put(con.AccountId,con.id);
        }
    }

    for(account acc : newAccLst){
    Id partnerId;
    Id conId;
        if(accIdToPartnerIdMap.containsKey(acc.PrimaryRelatedAgency__c))
            partnerId = accIdToPartnerIdMap.get(acc.PrimaryRelatedAgency__c);

        if(accToContactIdMap.containsKey(partnerId))
            conId = accToContactIdMap.get(partnerId);

        if(conId !=  null){

            acc.Primary_Agency_Contact__c = conId;
            lstToBeUpdated.add(acc);

        }
    }

    update lstToBeUpdated;

}*/

    //Updated as per I-182108
    // Commented as per  S-448035
    // Uncommented as per S-474800 by Shyam
    public void updateOrderLineItemOwner(List<Account> plistAccounts, Map<Id,Account> pAccountIdToOldAccountMap){
       final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderLineItemOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Order_Line_Item__c> listItems = new List<Order_Line_Item__c>();
        Set<String> orderStatus = new Set<String>{'Verified' , 'Resubmitted' , 'Negated' , 'Paid in Full' , 'Invoiced' , 'Closed'};

        set<Id> AccountThatHasOwnerChanged = new set<Id>();
        for(Account a : plistAccounts){
            if(a.OwnerId != pAccountIdToOldAccountMap.get(a.Id).OwnerId){
                AccountThatHasOwnerChanged.add(a.Id);
            }
        }

        System.debug('IN updateOrderLineItemOwner====');
        for(Order__c order : [Select Account__r.OwnerId, Account__c,
                                (Select Owner_on_Start_Date__c From Order_Line_Items__r
                                 Where  StartDate__c >=TODAY AND ArchivalStatus__c != 'Archived' )
                              From Order__c
                              Where OrderStatus__c IN :orderStatus And Account__c IN :AccountThatHasOwnerChanged
                                    ]) {
            if (plistAccounts.size() <= cutoff || order.Account__c == debugId){ //JFreese Appirio S-435483 4/10/17
                System.debug('IN updateOrderLineItemOwner 1st loop===='+order);
            }
            for(Order_Line_Item__c orderItem : order.Order_Line_Items__r) {
                if(orderItem.Owner_on_Start_Date__c != order.Account__r.OwnerId){
                    orderItem.Owner_on_Start_Date__c = order.Account__r.OwnerId;
                    listItems.add(orderItem);
                    if (plistAccounts.size() <= cutoff || order.Account__c == debugId){ //JFreese Appirio S-435483 4/10/17
                        System.debug('IN updateOrderLineItemOwner 2nd loop===='+orderItem);
                    }
                }
            }
        }
        System.debug('Out updateOrderLineItemOwner ===='+listItems);
        if(listItems.size()>0) {
            update listItems;
        }
    }

    /* Jeff L Commented out and moved into AccountTriggerHelper.ChangeProposalOwner
    @future
    public static void updateProposalOwner2(Set<Id> AccountThatHasOwnerChanged){
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','updateProposalOwner');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Apttus_Proposal__Proposal__c> listItems = new List<Apttus_Proposal__Proposal__c>();

        Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
        for(Apttus_Proposal__Proposal__c prop : [Select Id,QuoteStatus__c,ownerId,Apttus_Proposal__Account__r.OwnerId, Apttus_Proposal__Account__c
                                                 From Apttus_Proposal__Proposal__c
                                                 Where QuoteStatus__c NOT IN :proposalStatus And Apttus_Proposal__Account__c IN :AccountThatHasOwnerChanged
                                                 ]) {
               if(prop.ownerId != prop.Apttus_Proposal__Account__r.OwnerId){
                    prop.ownerId=prop.Apttus_Proposal__Account__r.OwnerId;
                    listItems.add(prop);
               }


        }
        if(listItems.size() > 0){
                Database.SaveResult[] srList = Database.update(listItems, false);
            }

    }*/




 //Updated as per I-186498
  /*  public void updateProposalOwner(List<Account> plistAccounts, Map<Id,Account> pAccountIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateProposalOwner');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Apttus_Proposal__Proposal__c> listItems = new List<Apttus_Proposal__Proposal__c>();
        set<Id> AccountThatHasOwnerChanged = new set<Id>();
        for(Account a : plistAccounts){
            if(a.OwnerId != pAccountIdToOldAccountMap.get(a.Id).OwnerId){
                AccountThatHasOwnerChanged.add(a.Id);
            }
        }


        Set<String> proposalStatus = new Set<String>{'Inactive' , 'Expired' , 'Closed' };
        for(Apttus_Proposal__Proposal__c prop : [Select Id,QuoteStatus__c,ownerId,Apttus_Proposal__Account__r.OwnerId, Apttus_Proposal__Account__c
                                                 From Apttus_Proposal__Proposal__c
                                                 Where QuoteStatus__c NOT IN :proposalStatus And Apttus_Proposal__Account__c IN :AccountThatHasOwnerChanged
                                                 ]) {
               if(prop.ownerId != prop.Apttus_Proposal__Account__r.OwnerId){
                    prop.ownerId=prop.Apttus_Proposal__Account__r.OwnerId;
                    listItems.add(prop);
               }


        }
        if(listItems.size() > 0){
                Database.SaveResult[] srList = Database.update(listItems, false);
            }

    }
*/

    private void createCaseforAlphaAccounts(List<Account> accounts){

        List<String> listOfRegistration = new List<String>();
        Map<Id,String> newAccountWithRegistration = new Map<Id, String>();
        Map<String , Boolean> registrationToProcess = new Map<String , Boolean>();
        //Map<Id, String> oldAccountsWithRegistration = new Map<Id, String>();
        List<Case> caseToCreate = new List<Case>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Request re Credit Limit').getRecordTypeId();
        // get all the Registration number for which need to check the Accounts
        for(Account account : accounts){
            if(!string.isBlank(account.RegistrationNumber__c) && !account.RegistrationNumber__c.isAlpha()){
                newAccountWithRegistration.put(account.Id , account.RegistrationNumber__c);

            }

        }

        System.debug('newAccountWithRegistration >>' + newAccountWithRegistration);

        for(Account acc : [Select Id , RegistrationNumber__c , CreditStatus__c From Account
                           Where RegistrationNumber__c IN : newAccountWithRegistration.Values()]){
            if(acc.CreditStatus__c != null && acc.CreditStatus__c != 'OK' &&
                !newAccountWithRegistration.containsKey(acc.Id)){

                if(!registrationToProcess.containsKey(acc.RegistrationNumber__c)){
                    registrationToProcess.put(acc.RegistrationNumber__c , true);
                }
            }
        }

        for(String str : newAccountWithRegistration.values()){
            if(!registrationToProcess.containsKey(str)){
                registrationToProcess.put(str , false);
            }
        }

        System.debug('registrationToProcess >>' + registrationToProcess);


        for(Id ids : newAccountWithRegistration.keySet()){

            String str = newAccountWithRegistration.get(ids);
            if(registrationToProcess.get(str) == true){
             Case cse = new Case();
             cse.SystemGenerated__c = True;
             cse.recordTypeId = caseRecordTypeId;
             cse.AccountId = ids;
             cse.Description = 'Please review the credit on this newly created account';
             cse.Subject = 'Autogenerated Case for a credit check on a new account';
             cse.Category__c = 'Support';
             caseToCreate.add(cse);

            }

        }

        if(caseToCreate.size() > 0)
            insert caseToCreate;
    }


    // Method to populate payment detail on Account
    private static void populatePaymentDetailField (List<Account> accList,Map<Id,Account> accOldMap){
        system.debug('**** Inside \n\n**** AccountTriggerHandler.populatePaymentDetailField');

        Boolean isInsert = true;
        if(accOldMap != null) {
            isInsert = false;
        }

        set<string> payTerm = new set<string>();
        set<string> payFrequency = new set<string>();
        set<string> payMethod = new set<string>();
        set<string> orgSet = new set<string>();
        List<Account> accToUpdate = new List<Account>();
        string key = null;

        for(Account acc : accList){

            if(isInsert && acc.Payment_Method__c == null && acc.Payment_Frequency__c == null
                                             && acc.Payment_Term__c == null ){
                acc.PaymentDetails__c = null;
            }

            if(acc.Payment_Method__c != null && acc.Payment_Frequency__c != null
                                             && acc.Payment_Term__c != null ){
                payMethod.add(acc.Payment_Method__c);
                payFrequency.add(acc.Payment_Frequency__c);
                payTerm.add(acc.Payment_Term__c);
                accToUpdate.add(acc);
                orgSet.add(acc.Organization__c);
            }

            if(!isInsert && (acc.Payment_Frequency__c != accOldMap.get(acc.Id).Payment_Frequency__c ||
                                  acc.Payment_Term__c != accOldMap.get(acc.Id).Payment_Term__c ||
                                  acc.Payment_Method__c !=  accOldMap.get(acc.Id).Payment_Method__c)){
                acc.PaymentDetails__c = null;
            }

        }

        if(accToUpdate.isEmpty())  return;

        map<string,string> paymentDetailMap = new map<string,string>();
        for(Payment_Details__c pDetail : [SELECT Id,PaymentFrequency__c,PaymentMethod__c,PaymentTerm__c,Organization__c,Non_Standard_Payment__c
                                                FROM Payment_Details__c WHERE (PaymentFrequency__c IN :payFrequency
                                                OR PaymentMethod__c IN :payMethod
                                                OR PaymentTerm__c IN :payTerm OR Organization__c In :orgSet)
                                                AND Active__c = true]){
            key = pDetail.Organization__c + pDetail.PaymentMethod__c + pDetail.PaymentTerm__c + pDetail.PaymentFrequency__c;
            paymentDetailMap.put(key , pDetail.ID);

        }

        for(Account accountRecord : accToUpdate){
            string paymentDetail = null;
            boolean isValid = false;
            key = accountRecord.Organization__c+accountRecord.Payment_Method__c+accountRecord.Payment_Term__c + accountRecord.Payment_Frequency__c;
            if(isInsert) {
                isValid = true;
            }else if(!isInsert && (accountRecord.Payment_Frequency__c != accOldMap.get(accountRecord.Id).Payment_Frequency__c ||
                                  accountRecord.Payment_Term__c != accOldMap.get(accountRecord.Id).Payment_Term__c ||
                                  accountRecord.Payment_Method__c !=  accOldMap.get(accountRecord.Id).Payment_Method__c)){
                accountRecord.PaymentDetails__c = null;
                isValid = true;

            }
            if(isValid && paymentDetailMap.containsKey(key)) {
                paymentDetail = paymentDetailMap.get(key);
                if(paymentDetail != null){
                    accountRecord.PaymentDetails__c = paymentDetail;
                }
                else {
                    accountRecord.addError('No matching Payment Details could be found, please contact your administrator.');
                }
            }
        }

    } // End of method

    // Use this method to update any Order__c Fields from Account.

    private void updateOrderFieldFromAccount(list<Account> newAccountList, Map<Id, Account> oldAccountMap){
       final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderFieldFromAccount');
       system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       // Code by appirio, added in March 16
       //Basic
       Map<Id, Account> mapAcc = new map <Id, Account> ();
       Set<String> orderStatus = new Set<String>{'Open' , 'Pending Processing' , 'Rejected','Sent To Verification'};//I-263281 AP 03/07
       List<Order__c> listOrders = new List<Order__c>();

       for(Account acc: newAccountList) {
            if(oldAccountMap != null && (acc.VATNumber__c != oldAccountMap.get(acc.id).VATNumber__c ) ){
                mapAcc.put(acc.Id, acc);
            }
       }

       system.debug('check ######## mapAcc' + mapAcc);
       if(!mapAcc.keySet().isEmpty()){
           for(Order__c ord : [Select id, Account__c, VAT_Number__c,Agency__c,Agency_VAT__c From Order__c Where Account__c IN :mapAcc.keySet() AND OrderStatus__c IN :orderStatus ]){
                ord.VAT_Number__c = mapAcc.get(ord.Account__c).VATNumber__c;

                listOrders.add(ord);
            }
            for(Order__c ordagency : [Select Agency_VAT__c,Agency__c, Id From Order__c Where Agency__c IN :mapAcc.keySet() AND OrderStatus__c IN :orderStatus]){
                ordagency.Agency_VAT__c = mapAcc.get(ordagency.Agency__c).VATNumber__c;
                listOrders.add(ordagency);
                system.debug('check ######## order' + listOrders);
            }
       }
       system.debug('check ######## order' + listOrders);
       if(listOrders.size() > 0 ){
            OrderTriggerHandler.executeUpdateTrigger = false;
            update listOrders;
            OrderTriggerHandler.executeUpdateTrigger = true;
       }
   }

    private void updatePostingAddressIsDifferent(Map<Id,Account> accountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updatePostingAddressIsDifferent');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List < AccountCleanInfo > cleanInfo = [Select Id, AccountId, IsDifferentCity, IsDifferentCountry, IsDifferentState, IsDifferentStreet, CleanedByUser, LastMatchedDate, LastStatusChangedDate
            from AccountCleanInfo where AccountId IN: accountMap.keyset()];

        system.debug('CleanInfo!! ' + cleanInfo);
        for (AccountCleanInfo aci: cleanInfo) {

            Account currAcc = accountMap.get(aci.AccountId);
            system.debug('curr Acc ' + currAcc);
            if(currAcc != null){
                // if any address field is different from the data.com address after clean, set a flag on the account object
                if (aci.isDifferentCity || aci.isDifferentCountry || aci.isDifferentState ||
                  aci.isDifferentStreet) {
                  system.debug('inside different if statement ');
                  currAcc.Posting_Address_IsDifferent__c = true;
                }
                else {
                  system.debug('inside of else statement');
                  currAcc.Posting_Address_IsDifferent__c = false;
                }
              }
        }
    }

    private void populatePaymentFrequency(list<Account> newAccountList){

        for(Account acc : newAccountList){
            if(acc.Organization__c == 'North America'){
                acc.Payment_Frequency__c = 'Single Payment' ;

            }
            else if(acc.Organization__c == 'Europe'){
                acc.Payment_Frequency__c = 'Single Invoice' ;
            }
            else if(acc.Organization__c == 'Asia Pacific'){
                acc.Payment_Frequency__c = 'Invoice' ;
            }

        }

    }

/*
**  @author : Appirio
**  @date : 10/12/2015
**  @description :  This method handles a lot of logic around account team member updates. Jeff L broke it out of the main
**  Trigger handler code
**  @paramaters : array of new Account object, map of new Accounts, map of old Accounts
**  @returns : nothing
*/

    private void updateAccountTeamMembers(Account[] pUpdatedAccounts, map<ID, Account> pAccountIdToOldAccountMap, map<ID, Account> pAccountIdToUpdatedAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

         map<string, list<Account>> primaryTeamMemberTypeToListOfAccountsMap = new map<string, list<Account>>();
            // create an Account Id Set
            set<Id> accountIdSet = new set<Id>();
            //set<Id> updateContactOrganizationAccountIdSet = new set<Id>();
            set<Id> updateOwnerAccountIdSet = new set<Id>();
            Boolean equalSalesRep = false;
            Integer count = 0;
            for(Account oAccount: pUpdatedAccounts){
                // if Account ownership has changed, add the Account to the Primary Sales Rep list
                if(pAccountIdToUpdatedAccountMap.get(oAccount.Id).OwnerId != pAccountIdToOldAccountMap.get(oAccount.Id).OwnerId){

                    if(!primaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimarySalesRep'))
                        primaryTeamMemberTypeToListOfAccountsMap.put('PrimarySalesRep' , new list<Account>());

                    primaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep').add(oAccount);
                    accountIdSet.add(oAccount.Id);

                    /*if(primaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimarySalesRep')){
                        accountIdSet.add(oAccount.Id);
                        primaryTeamMemberTypeToListOfAccountsMap.get('PrimarySalesRep').add(oAccount);
                        }else{
                            accountIdSet.add(oAccount.Id);
                            list<Account> newAccountList = new list<Account>();
                            newAccountList.add(oAccount);
                            primaryTeamMemberTypeToListOfAccountsMap.put('PrimarySalesRep', newAccountList);
                        }*/
                    }

                // if Account Primary Service Rep has changed, add the Account to the Primary Service Rep list
                if(pAccountIdToUpdatedAccountMap.get(oAccount.Id).PrimaryServiceRep__c != pAccountIdToOldAccountMap.get(oAccount.Id).PrimaryServiceRep__c){

                    if(!primaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimaryServiceRep'))
                        primaryTeamMemberTypeToListOfAccountsMap.put('PrimaryServiceRep' , new list<Account>());

                    primaryTeamMemberTypeToListOfAccountsMap.get('PrimaryServiceRep').add(oAccount);
                    accountIdSet.add(oAccount.Id);
                    /*if(primaryTeamMemberTypeToListOfAccountsMap.containsKey('PrimaryServiceRep')){
                        accountIdSet.add(oAccount.Id);
                        primaryTeamMemberTypeToListOfAccountsMap.get('PrimaryServiceRep').add(oAccount);
                        }else{
                            accountIdSet.add(oAccount.Id);
                            list<Account> newAccountList = new list<Account>();
                            newAccountList.add(oAccount);
                            primaryTeamMemberTypeToListOfAccountsMap.put('PrimaryServiceRep', newAccountList);
                        }*/
                    }
                }
                // update the Primary Account Team Members
                if(!accountIdSet.isEmpty()){
                    SetSendToEmailFlag.runAfterUpdate = true;
                    if(SetSendToEmailFlag.fromTerritory){
                        helperwoutsharing.UpdatePrimaryAccountTeamMembers2(accountIdSet, primaryTeamMemberTypeToListOfAccountsMap);
                        accountHelper.ReplaceAccountTeamMember(accountIdSet);
                        } else {
                        helperwoutsharing.UpdatePrimaryAccountTeamMembers2(accountIdSet, primaryTeamMemberTypeToListOfAccountsMap);
                    }
                }

                if(!accountIdSet.isEmpty()){
                    accountHelper.DeleteAccountTemaMemberOfFraudUsers(pUpdatedAccounts, pAccountIdToOldAccountMap);
                    //Appirio J Freese I-221832 move whenPrimarySalesRepChanged to the afterUpdate method
                    //so it will process the children when the TA_RunID changes
                    //accountHelper.whenPrimarySalesRepChanged(pUpdatedAccounts, pAccountIdToOldAccountMap);
                    } else {
                        accountHelper.MarkDomesticAndGlobalAccount(pUpdatedAccounts, pAccountIdToOldAccountMap);
                    }
    }

}