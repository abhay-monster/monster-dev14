public without sharing class XCodeAccountTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** XCodeAccountTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;

/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : XCodeAccountTriggerHandler handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public XCodeAccountTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];

        // intantiate new trigger helper
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. XCodeAccountTriggerHandler)
        */
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'Before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public void OnbeforeInsert(XcodeAccount__c[] pNewXcodeAccount){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnbeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                PrimaryChild.updateXCodeAccountFieldsFromMAPP(pNewXcodeAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'Before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public void OnbeforeUpdate(XcodeAccount__c[] pNewXcodeAccount, map<Id, XcodeAccount__c> pOldXcodeAccountMap){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnbeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                PrimaryChild.updateXCodeAccountFieldsFromMAPP(pNewXcodeAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public void OnAfterInsert(XcodeAccount__c[] pNewXcodeAccount, map<Id, XcodeAccount__c> pNewXcodeAccountMap){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() =='Integration MAPP'){
            populateAccSiteEmployees(pNewXcodeAccount, pNewXcodeAccountMap);
        }

        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                PrimaryChild.SettingOfPrimaryXCodeImplemention(pNewXcodeAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public void OnAfterUpdate(XcodeAccount__c[] pNewXcodeAccount, map<Id, XcodeAccount__c> pOldXcodeAccountMap){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                PrimaryChild.SettingOfPrimaryXCodeImplemention(pNewXcodeAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old XcodeAccount objects, map of old XcodeAccount
**  @returns : nothing
*/
    public void OnAfterDelete(XcodeAccount__c[] pOldXcodeAccount, map<ID, XcodeAccount__c> pOldXcodeAccountMap){
        if (Personal_Settings__c.getInstance().trigger_account__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                AccountMergeHelper.DeletingOfPrimaryXCodeImplemention(pOldXcodeAccount);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }
		/*
    @Populating Account.Site_Number_of_Employees__c from XcodeAccount__c.Xcode_Employees__c starts
	@S-432850
	@Deepanshu Soni (Appirio)
	@28-Sep-2016
	*/
    public void populateAccSiteEmployees(XcodeAccount__c[] pNewXcodeAccount, map<Id, XcodeAccount__c> pNewXcodeAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populateAccSiteEmployees');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Account> accList = new List<Account>();
        Set<id> accIds = new set<Id>();
        String siteEmployees = '';
        for(XcodeAccount__c xacc : pNewXcodeAccount )  {
            if (xacc.Xcode_Employees__c != null){
                siteEmployees = xacc.Xcode_Employees__c ;
                system.debug('siteEmployees='+siteEmployees);
                if(accIds.isEmpty()){
                    Account acc = new Account(Id= xacc.Account__c, Site_Number_of_Employees__c= siteEmployees.deleteWhitespace());
                    accList.add(acc);
                    accIds.add(xacc.Account__c);
                }
                else if((!accIds.isEmpty()) && (!accIds.contains(xacc.Account__c))) {
                        Account acc = new Account(Id= xacc.Account__c, Site_Number_of_Employees__c=siteEmployees.deleteWhitespace());
                        accList.add(acc);
                        accIds.add(xacc.Account__c);
                }
            }
        }
        if(accList.size() > 0){
            update accList;
        }
    }
}