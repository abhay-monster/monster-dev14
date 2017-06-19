/*
** @author : Cloud Sherpas Inc.
** @date : 3/26/2014
** @description : Task trigger class to handle CRUD events.
*/
public without sharing class TaskTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** TaskTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TaskTriggerHelper helper;
    private static Integer RunCount = 0;

/*
** @author : Cloud Sherpas Inc.
** @date : 03/26/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : TaskTriggerHandler handler = new TaskTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public TaskTriggerHandler(boolean isExecuting, integer pTriggerSize){

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

      // intantiate new trigger helper
        helper = TaskTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/26/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to run the logic for before insert of tasks.
** @paramaters : an array of Task objects
** @returns : nothing
*/

    public void OnBeforeInsert(Task[] pTask){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        final string TASKSUBJECT = 'Account Plan Update Due';
        final string HIGHPRIORITY = 'High';
        final string TASKTYPEACCOUNTSTRATEGY = 'Account Strategy';

        for(Task tsk : pTask){
            if(tsk.Subject == TASKSUBJECT  && tsk.Priority == HIGHPRIORITY ){
                tsk.Type = TASKTYPEACCOUNTSTRATEGY;
            }
        }

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                helper.populatePhoneNumber(pTask);
                // I-189243
                helper.ReassignTaskOnUpdate(pTask);
                //Id orderRecordTypeId = [Select Id,SobjectType,Name From RecordType WHERE Name ='Telemarketing' and SobjectType ='Task'  limit 1].Id;
                Id orderRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Telemarketing').getRecordTypeId();
                System.debug('==orderRecordTypeId=='+orderRecordTypeId);
                List<Task> TelemarketingTasks = new List<Task>();
                for(Task t : pTask){
                     if(t.RecordTypeId == orderRecordTypeId ){
                        TelemarketingTasks.add(t);
                     }
                }
                system.debug('TelemarketingTasks' + TelemarketingTasks);
                if(!TelemarketingTasks.isEmpty()){
                    helper.setRelatedToField(TelemarketingTasks);
                    helper.updateAccountsStatusToOutOfBusiness(TelemarketingTasks);
                    helper.updateContactDoNotCall(TelemarketingTasks);
                }
            }

       helper.updateCaseFirstContactActualDateField(pTask);
       helper.checkIfAccountRecentlyConverted(pTask); //added by Deepanshu - To throw an error message if the Account is not recently converted from a Lead
    }

    public void onBeforeUpdate(Task[] pTask, map<Id,Task> poldTaskMap){
         if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }

        // Restrict the update trigger

        RunCount++;

        if(RunCount > 1){
            return;
        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','onBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                helper.populatePhoneNumber(pTask);
                //Id orderRecordTypeId = [Select Id,SobjectType,Name From RecordType WHERE Name ='Telemarketing' and SobjectType ='Task'  limit 1].Id;
                Id orderRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Telemarketing').getRecordTypeId();
                System.debug('==orderRecordTypeId==2=='+orderRecordTypeId);
                List<Task> TelemarketingTasks = new List<Task>();
                for(Task t : pTask){
                     if(t.RecordTypeId == orderRecordTypeId ){
                        TelemarketingTasks.add(t);
                     }
                }
                if(!TelemarketingTasks.isEmpty()){
                    helper.setRelatedToField(TelemarketingTasks);
                    helper.updateAccountsStatusToOutOfBusiness(TelemarketingTasks);
                    helper.ReassignTaskOnUpdate(TelemarketingTasks);
                    helper.updateContactDoNotCall(TelemarketingTasks);
                }
            }
        helper.updateCaseFirstContactActualDateField(pTask);
    }
    public void OnAfterInsert(Task[] pTask){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        for(Task t: pTask){
            system.debug('\n\n\n\n\n -----------------\nt.Id: '+ t.Id);
        }

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.setLeadStatusToAccepted(pTask);
//                helper.updateMaxActivityDateAndOwnerOfAccount(pTask);
                //helper.populatePhoneNumber(pTask);
            }

        updateValidSalesActivityonAccount(pTask,null);
    }

    public void OnAfterUpdate(Task[] pTask, map<Id,Task> poldTaskMap){
        if (Personal_Settings__c.getInstance().Trigger_Activity__c ==false){
            return; // If triggers are off, then exit the method
        }

        updateValidSalesActivityonAccount(pTask,poldTaskMap);
        if(RunCount > 1){
            return;

        }

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.setLeadStatusToAccepted(pTask);
                //helper.populatePhoneNumber(pTask);
            }

    }

    public void onBeforeDelete(Task[] pTask, map<Id,Task> poldTaskMap){
        Profile_Permissions__c permissionToDeleteActivity = Profile_Permissions__c.getInstance(userinfo.getProfileId());
        if(permissionToDeleteActivity.Delete_Activities__c == false) {
            // throw new PermissionCheck.NoPermissionException(Label.Cannot_Delete_Activities);
            //AS 10.2.2017 per S-456700 - change: using AddError instead of throwing exception - it was generating 'Unhandled Exception' emails to admin
            for(Task t : pTask) {
                t.AddError(Label.Cannot_Delete_Activities);
            }
        }    
        /*if (PermissionCheck.hasPermission('Can_Delete_Activities')==false) {
            throw new PermissionCheck.NoPermissionException(Label.Cannot_Delete_Activities);
        }*/
    }

    public void onAfterDelete(Task[] pTask, map<Id,Task> poldTaskMap) {
        updateValidSalesActivityonAccount(null , poldTaskMap);
    }

    public void updateValidSalesActivityonAccount(Task[] pTask, map<Id,Task> poldTaskMap) {
        System.debug('updateValidSalesActivityonAccount');
        Set<Id> activityAccount = new set<Id>();
        List<Account> lstAccountToUpdate = new List<Account>();
        // Update and Insert case
        if(pTask != null) {
            for(Task t : pTask) {
                // Apply trigger in Account tasks only
                Id accountId = getAccountId(t);
                if(accountId == null) {
                    continue;
                }
                // When activity is inserted with Valid_Sales_Activity__c to be true or
                // When activity is updated and Valid_Sales_Activity__c is set to true
                if((t.Valid_Sales_Activity__c && poldTaskMap == null) ||
                   (t.Valid_Sales_Activity__c && poldTaskMap != null &&
                   !poldTaskMap.get(t.Id).Valid_Sales_Activity__c)) {
                    // Update the Account on activity
                    lstAccountToUpdate.add(new Account(Id = accountId ,
                                                     Covered_Date__c = t.LastModifiedDate.date() ,
                                                     MaxActivityDate__c = t.LastModifiedDate,
                                                     MaxActivityDateOwner__c = t.OwnerId,
                                                     Covered_Account__c = true ));
                }
                // When Activity's Valid_Sales_Activity__c is set to false , look for other activity on
                // that account and with Valid_Sales_Activity__c to be true and update account
                else if(!t.Valid_Sales_Activity__c && poldTaskMap != null &&
                    poldTaskMap.get(t.Id).Valid_Sales_Activity__c) {
                    activityAccount.add(accountId);
                }
            }
        }
        // delete case
        if(pTask == null && poldTaskMap != null) {
            for(Task t : poldTaskMap.values()) {
                Id accountId = getAccountId(t);

                if(t.Valid_Sales_Activity__c && accountId != null) {
                    activityAccount.add(accountId);
                }
            }
        }

        Map<Id,Task> accountTaskMap = new Map<Id,Task>();
        for(Task t : [Select LastModifiedDate, OwnerId, AccountId, ReferenceAccount__c
                       From Task
                       WHERE Valid_Sales_Activity__c = true
                       AND (AccountId in :activityAccount OR ReferenceAccount__c in :activityAccount)
                       order by LastModifiedDate Desc
                       Limit 1]){
            Id accountId = getAccountId(t);
            if(accountId != null){
                accountTaskMap.put(accountId,t);
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
        System.debug('updateValidSalesActivityonAccount lstAccountToUpdate ' + lstAccountToUpdate);
        if(lstAccountToUpdate.size() > 0) {
            // Shyam 4/28 : S-475629 - Start
            try{
                update lstAccountToUpdate;
            }
            catch (DMLException e){
                for(Account acc : lstAccountToUpdate){
                    acc.addError(e.getMessage());
                }
            }
            // Shyam 4/28 : S-475629 - End
        }

    }

    private Id getAccountId(Task pTask){
        Id returnId;
        if(pTask.AccountId != null){
            returnId = pTask.AccountId;
        } else if (pTask.ReferenceAccount__c != null){
            returnId = pTask.ReferenceAccount__c;
        }
        return returnId;
    }
}