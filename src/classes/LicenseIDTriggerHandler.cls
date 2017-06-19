public with sharing class LicenseIDTriggerHandler extends BaseTriggerHandler{
  final String CLASSNAME = '\n\n**** LicenseIDTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    public static Boolean ExecuteTriggers = true;
    LicenseIDTriggerHelper helper;
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public LicenseIDTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId() LIMIT 1];

        // intantiate new trigger helper
        helper = LicenseIDTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Order_Line_Item__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(LicenseID__c[] pLicenseIds){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(LicenseID__c lid : pLicenseIds){
                System.debug('^^^ MAPP Insert LicenseID__c ' + lid);
            }
            helper.fixEcomm(pLicenseIds);
            helper.Ecommxcode(pLicenseIds);
            //helper.CheckLicId(pLicenseIds);
        }
        helper.CheckLicId(pLicenseIds);

        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                //setting of QuoteCreated__c flag when an Apptus_proposal is created
                //Commented on June 2014 as per confirmation, we are not updating Parent OLIs
                //helper.SubtractQuantityAndNetPriceToParentLineItem(pNewOrderLineItemMap);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                helper.MatchOrderFromLIDMAPPOLI(pLicenseIds);

         }
    }

/*
** @author : Appirio (Jonathan F)
** @date : 04/14/16
*/

    public void OnAfterInsert(LicenseID__c[] pLicenseIds , map<Id, LicenseID__c> pLicenseIdToNewLicenseIDMap){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(LicenseID__c lid : pLicenseIds){
                System.debug('^^^ MAPP After Insert LicenseID__c ' + lid);
            }
            helper.SetIntegrationStatus(pLicenseIds);//I-221617
            //helper.fixEcomm_OLI(pLicenseIds); // Set parent OLI lineType to Ecomm so it will get included in order.netTotalAmount__c
            //commented out for I-218373
        }   
    }
}