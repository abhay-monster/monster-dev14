/*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description : Event trigger class to handle CRUD events. 
*/
public without sharing class EventTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** EventTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TaskTriggerHelper taskHelper;
    private EventTriggerHelper newHelper;

/*  
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : EventTriggerHandler handler = new EventTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public EventTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        taskHelper = TaskTriggerHelper.NewTriggerHelper();
        newHelper = EventTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to run the logic for after insert of event.
** @paramaters : an array of Event objects
** @returns : nothing
*/  

    public void OnBeforeUpdate(Event[] pEvent){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                newHelper.populatePhoneNumber(pEvent);                
        }               
        
    }/*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to run the logic for after insert of event.
** @paramaters : an array of Event objects
** @returns : nothing
*/  

    public void OnBeforeInsert(Event[] pEvent){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                newHelper.populatePhoneNumber(pEvent); 
                newHelper.ReassignEventOnAccount(pEvent);   
            	newHelper.checkIfAccountRecentlyConverted(pEvent); //added by Deepanshu - To throw an error message if the Account is not recently converted from a Lead
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description :  this method handles the 'After insert' event for the trigger; it's purpose is to run the logic for after insert of event.
** @paramaters : an array of Event objects
** @returns : nothing
*/  

    public void OnAfterInsert(Event[] pEvent){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
       
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            taskHelper.setLeadStatusToAccepted(pEvent);
            updateEventValidSalesActivityonAccount(pEvent, null);
//            newHelper.updateMaxActivityDateAndOwnerOfAccount(pEvent);  
            //newHelper.populatePhoneNumber(pEvent);                
        }              
       
    }
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 07/22/2014
** @description :  this method handles the 'After update' event for the trigger; it's purpose is to run the logic for after update of event.
** @paramaters : an array of Event objects
** @returns : nothing
*/  

    public void OnAfterUpdate(Event[] pEvent, map<Id,Event> poldEventMap){
       if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            taskHelper.setLeadStatusToAccepted(pEvent);
            updateEventValidSalesActivityonAccount(pEvent, poldEventMap);
            //newHelper.populatePhoneNumber(pEvent);                
        }               
       
    }
    
    public void onBeforeDelete(Event[] pEvent, map<Id,Event> poldEventMap){
        Profile_Permissions__c permissionToDeleteActivity = Profile_Permissions__c.getInstance(userinfo.getProfileId());
        
        if(permissionToDeleteActivity.Delete_Activities__c == false) {
            //AS 10.2.2017 per S-456700 - changed: use AddErrorinstead of throwing exception because it was generatign 'unhandled exception' emails to admins
            // throw new PermissionCheck.NoPermissionException(Label.Cannot_Delete_Activities);
            for (Event evt : pEvent) {
                evt.addError(Label.Cannot_Delete_Activities);
            }
        }

        /*if (PermissionCheck.hasPermission('Can_Delete_Activities')==false) {
            throw new PermissionCheck.NoPermissionException(Label.Cannot_Delete_Activities);
        }*/
    }
    
    public void updateEventValidSalesActivityonAccount(Event[] pEvent, map<Id,Event> poldEventMap) {
        System.debug('updateEventValidSalesActivityonAccount');
        Set<Id> activityAccount = new set<Id>();
        List<Account> lstAccountToUpdate = new List<Account>();
        // Update and Insert case
        if(pEvent != null) {
            for(Event e : pEvent) {
                // Apply trigger in Account tasks only
                Id accountId = getAccountId(e);
                if(accountId == null) {
                    continue;
                }
                // When activity is inserted with Valid_Sales_Activity__c to be true or
                // When activity is updated and Valid_Sales_Activity__c is set to true
                if((e.Valid_Sales_Activity__c && poldEventMap == null) ||
                   (e.Valid_Sales_Activity__c && poldEventMap != null &&
                   !poldEventMap.get(e.Id).Valid_Sales_Activity__c)) {
                    // Update the Account on activity
                    lstAccountToUpdate.add(new Account(Id = accountId ,
                                                     Covered_Date__c = e.LastModifiedDate.date() ,
                                                     MaxActivityDate__c = e.LastModifiedDate,
                                                     MaxActivityDateOwner__c = e.OwnerId,
                                                     Covered_Account__c = true ));
                }
                // When Activity's Valid_Sales_Activity__c is set to false , look for other activity on
                // that account and with Valid_Sales_Activity__c to be true and update account
                else if(!e.Valid_Sales_Activity__c && poldEventMap != null &&
                    poldEventMap.get(e.Id).Valid_Sales_Activity__c) {
                    activityAccount.add(accountId);
                }
            }
        }
        // delete case
        if(pEvent == null && poldEventMap != null) {
            for(Event e : poldEventMap.values()) {
                Id accountId = getAccountId(e);

                if(e.Valid_Sales_Activity__c && accountId != null) {
                    activityAccount.add(accountId);
                }
            }
        }

        Map<Id,Event> accountTaskMap = new Map<Id,Event>();
        for(Event e : [Select LastModifiedDate, OwnerId, AccountId, ReferenceAccount__c
                       From Event
                       WHERE Valid_Sales_Activity__c = true
                       AND (AccountId in :activityAccount OR ReferenceAccount__c in :activityAccount)
                       order by LastModifiedDate Desc
                       Limit 1]){
            Id accountId = getAccountId(e);
            if(accountId != null){
                accountTaskMap.put(accountId,e);
            }
        }

        // Find any Activity (Valid_Sales_Activity__c = true) on account and update it
        for(Id accountId : activityAccount) {
            if(accountTaskMap.containsKey(accountId)) {
                 lstAccountToUpdate.add(new Account(Id = accountId ,
                                        Covered_Date__c = accountTaskMap.get(accountId).LastModifiedDate.date() ,
                                        MaxActivityDate__c = accountTaskMap.get(accountId).LastModifiedDate,
                                        MaxActivityDateOwner__c = accountTaskMap.get(accountId).OwnerId,
                                        Covered_Account__c = true ));
            } else {
                lstAccountToUpdate.add(new Account(Id = accountId ,
                                        Covered_Date__c = null ,
                                        Covered_Account__c = false,
                                        MaxActivityDate__c = null,
                                        MaxActivityDateOwner__c = null ));
            }
        }
        System.debug('updateEventValidSalesActivityonAccount lstAccountToUpdate ' + lstAccountToUpdate);
        if(lstAccountToUpdate.size() > 0) {
            update lstAccountToUpdate;
        }

    }

    private Id getAccountId(Event pEvent){
        Id returnId;
        if(pEvent.AccountId != null){
            returnId = pEvent.AccountId;
        } else if (pEvent.ReferenceAccount__c != null){
            returnId = pEvent.ReferenceAccount__c;
        }
        return returnId;
    } 
}