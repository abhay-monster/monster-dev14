/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description :   class that supports the OpportunityTriggerHelper class; it provides the methods called from those classes
*/
public with sharing class TaskTriggerHelper{
    final String CLASSNAME = '\n\n**** TaskTriggerHelper.METHODNAME()';
    final static ID TELEMARKETINGID = Schema.SObjectType.Task.RecordTypeInfosByName.get('Telemarketing').RecordTypeId;
    final static ID ACTION_PLAN = Schema.SObjectType.Task.RecordTypeInfosByName.get('Action Plan').RecordTypeId;
    final static ID ACTION_TRACKER = Schema.SObjectType.Task.RecordTypeInfosByName.get('Action Tracker').RecordTypeId;
    final static ID SALES = Schema.SObjectType.Task.RecordTypeInfosByName.get('Sales').RecordTypeId;
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

    /*
    ** @author : Cloud Sherpas Inc.
    ** @date : 06/11/2014
    ** @description : static method that instantiates a new instance of the class
    ** @paramaters : nothing
    ** @returns : a new instance of the CreditRequestTriggerHelper class
    */
    public static TaskTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        TaskTriggerHelper newHelper = new TaskTriggerHelper('');
        return newHelper;
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 06/11/2014
    ** @description : this method is the class constructor
    ** @paramaters : none
    ** @returns : nothing
    */
    private TaskTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','TaskTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 07/18/2014
** @Story : 0691
** @Element : E1726
** @description : Set the Lead Status to accepted.
** @param : list of Opportunity
** @returns : nothing
*/
    public void setLeadStatusToAccepted(list<SObject> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','setLeadStatusToAccepted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            Set<Id> oppoId = new Set<Id>();
            for(SObject t : pTaskList){
                if(t.get('WhatId') != null){
                    String checkId = String.Valueof(t.get('WhatId'));
                    if(t.get('Description') != null){
                        if(checkId.startsWith(Schema.SObjectType.Opportunity.getKeyPrefix())){
                            oppoId.add((Id)t.get('WhatId'));
                        }
                    }
                }
            }
            if(oppoId.size() > 0){
                List<Opportunity> oppoList = [SELECT Id, Account.isPersonAccount, Owner.UserRole.Name, LeadStatus__c FROM Opportunity WHERE Id in : oppoId];
                List<Opportunity> oppoToBeUpdated = new List<Opportunity>();
                for(Opportunity o : oppoList){
                    if(o.Account.isPersonAccount){
                        String RoleName = o.Owner.UserRole.Name;
                        if(RoleName != null && RoleName.toLowerCase().Contains('consumer sales rep')){
                            if(o.LeadStatus__c != 'Accepted'){
                                o.LeadStatus__c = 'Accepted';
                                oppoToBeUpdated.add(o);
                            }
                        }
                    }
                }
                if(oppoToBeUpdated.size() > 0){
                    update oppoToBeUpdated;
                }
            }
       /* }catch(DMLException dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'TaskTriggerHelper', 'setLeadStatusToAccepted', dmlex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.setLeadStatusToAccepted()', dmlex.getMessage());
        } */
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/29/2014
** @Story : 0948
** @Element : E1852
** @description :
**              1.) Max Activity Date field should be updated with the created date of the last created activity related to the account.
**              2.) Max Activity Date Owner lookup should be populated with the latest activity created.
** @param : list of Task
** @returns : nothing

    public void updateMaxActivityDateAndOwnerOfAccount(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateMaxActivityDateAndOwnerOfAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //try{
            /*Map<Id, Task> TaskAccountMap = new Map<Id, Task>();
            for(Task t : pTaskList){
                TaskAccountMap.put(t.AccountId, t);
            }
            List<Account> AccountToBeUpdated = new List<Account>();
            if(!TaskAccountMap.isEmpty()){
                for(Account acc: [SELECT Id, MaxActivityDate__c, MaxActivityDateOwner__c FROM Account WHERE Id IN: TaskAccountMap.keySet()] ){
                    if(TaskAccountMap.get(acc.Id).CreatedDate != null ){
                        acc.MaxActivityDate__c = TaskAccountMap.get(acc.Id).CreatedDate;
                    }
                    if(TaskAccountMap.get(acc.Id).ownerId != null ){
                        acc.MaxActivityDateOwner__c = TaskAccountMap.get(acc.Id).ownerId;
                    }
                    AccountToBeUpdated.add(acc);
                }
            }

            if(!AccountToBeUpdated.isEmpty()){
                update AccountToBeUpdated;
            }*/
           // TriggerHelperWithoutSharing.getInstance().updateMaxActivityDateAndOwnerOfAccount(pTaskList);
        /*}catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'updateMaxActivityDateAndOwnerOfAccount', ex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.updateMaxActivityDateAndOwnerOfAccount()', 'Failed to update the related Account. Please see system logs for details. \nError: '+ex.getMessage() );
        }
    }


        /*
** @author : Cloud Sherpas, Inc.
** @date : 08/13/2014
** @Story : 0576
** @Element : E1951
** @description : Populate the Phone by Contact.
** @param : list of Task
** @returns : nothing
*/
    public void populatePhoneNumber(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePhoneNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            List<Contact> con = new List<Contact>();
            List<Task> taskUpdate = new List<Task>();
            map<Id,Id> taskMap = new map<Id,Id>();
            set<Id> contactIds = new set<Id>();
            for(Task t : pTaskList){
                String checkId = String.Valueof(t.WhoId);
                if(checkId != null && checkId.startsWithIgnoreCase('003')){
                    //taskMap.put(t.Id, t.WhoId);
                    contactIds.add(t.WhoId);
                }
            }
            // Check and put query into map instead of loop
            //taskUpdate = [SELECT Id, ContactPhone__c, WhoId FROM Task WHERE Id In : taskMap.keySet()];
            map<Id,Contact> conMap = null;
            if(contactIds != null && contactIds.size() > 0){
                /*con = [SELECT Id, Phone, JobPosition__c, ContactType__c FROM Contact WHERE Id in : contactIds ];
                map<Id,Contact> conMap = new map<Id,Contact>();
                    for(Contact c : con){
                        conMap.put(c.Id, c);
                }*/
                conMap = new map<Id,Contact>([SELECT Id, Phone, JobPosition__c, ContactType__c FROM Contact WHERE Id in : contactIds ]);
                List<Task> taskToUpdate = new List<Task>();
                if(!conMap.isEmpty()){
                    for(Task tsk : pTaskList){
                        //if(tsk.ContactPhone__c != conMap.get(tsk.WhoId)){
                        if(conMap.get(tsk.WhoId) != null){
                            tsk.ContactPhone__c = conMap.get(tsk.WhoId).Phone;
                            tsk.ContactType__c = conMap.get(tsk.WhoId).ContactType__c;
                            tsk.ContactJobPosition__c = conMap.get(tsk.WhoId).JobPosition__c;
                            //taskToUpdate.add(tsk);
                        }
                    }
                }
            }
            //if(taskToUpdate.size() > 0){
            //    update taskToUpdate;
            //}

       /* }catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'TaskTriggerHelper', 'populatePhoneNumber', dmlex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.populatePhoneNumber()', dmlex.getMessage());
        } */
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/14/2014
** @Story : 0535
** @Element : E1984
** @description :
**              - For Tasks with a Record Type of "Telemarketing", we need to ensure that when the "Contact Name" field on Activity (Task) is populated with a Contact, that the "Related To" field is populated with the Contact's Account.
** @param : list of Task
** @returns : nothing
*/
    public void setRelatedToField(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateMaxActivityDateAndOwnerOfAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            set<Id> conIdset = new set<Id>();
            for(Task t : pTaskList){
                if(t.RecordTypeId == TELEMARKETINGID && t.WhoId != null){
                    String conId = t.WhoId;
                    if(conId.substring(0,3) == keyPrefix){
                        conIdset.add(t.WhoId);
                    }
                }
            }
            // Check and put query into map instead of loop
            if(conIdset.size() > 0) {
                Map<Id,Contact> contactsAccountMap = new map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE Id in : conIdset]);
                /*for(Contact con : [SELECT Id, AccountId FROM Contact WHERE ID IN:conIdset] ){
                    contactsAccountMap.put(con.Id, con);
                }*/
                if(!contactsAccountMap.isEmpty()){
                    for(Task t : pTaskList){
                        if(t.RecordTypeId == TELEMARKETINGID && t.WhoId != null){
                            String conId = t.WhoId;
                            if(conId.substring(0,3) == keyPrefix){
                                t.WhatId = contactsAccountMap.get(t.WhoId).AccountId;
                            }
                        }
                    }
                }
            }
       /* }catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'setRelatedToField', ex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.setRelatedToField()', 'Failed to populate Related To field. Please see system logs for details. \n Error: '+ex.getMessage() );
        } */
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/14/2014
** @Story : 0535
** @Element : E1985
** @description :
**              - For Tasks with a Record Type of "Telemarketing", we need to ensure that when the "Contact Name" field on Activity (Task) is populated with a Contact, that the "Related To" field is populated with the Contact's Account.
** @param : list of Task
** @returns : nothing
*/
    public void updateAccountsStatusToOutOfBusiness(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateAccountsStatusToOutOfBusiness');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            set<Id> AccountIdset = new set<Id>();
            for(Task t : pTaskList){
                if(t.RecordTypeId==TELEMARKETINGID ){
                    if(t.CallDisposition == 'Out of Business'){
                        AccountIdset.add(t.AccountId);
                    }
                }
            }
            List<Account> AccountListToBeUpdate = new List<Account>();
            if(!AccountIdset.isEmpty()){
                for(Account acc : [SELECT Id, AccountStatus__c FROM Account WHERE ID IN: AccountIdset] ){
                    acc.AccountStatus__c = 'Out of Business';
                    AccountListToBeUpdate.add(acc);
                }
            }
            if(!AccountListToBeUpdate.isEmpty()){
                update AccountListToBeUpdate;
            }
        /*}catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'updateAccountsStatusToOutOfBusiness', ex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.updateAccountsStatusToOutOfBusiness()', 'Failed to update the status of the related Account to \'Out of Business\'. Please see system logs for details. \nError: '+ex.getMessage()  );
        }*/
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 08/14/2014
** @Story : 0955
** @Element : E2073
** @description :
**              - For Tasks with "Telemarketing" record Types AND when there is an Account associated to the Task AND when the "Call Result" field is populated, set the Task owner ("Assigned To" field) to the "Primary Sales Rep" on the related Account.
** @param : list of Task
** @returns : nothing
*/
    public void ReassignTaskOnUpdate(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','ReassignTaskOnUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            map<Id,Account> TaskAccountIdMap = new map<Id,Account>();
            set<Id> AccountIdset = new set<Id>();
            for(Task t : pTaskList){
                if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                    system.debug('Taskt' + t);
                    system.debug('t.WhatId' + t.WhatId);
                    system.debug('t.CallDisposition' + t.CallDisposition);
                    system.debug('t.RecordTypeId' + t.RecordTypeId);
                }
                //if(t.RecordTypeId==TELEMARKETINGID  && t.WhatId!= null && t.CallDisposition != null ){
                if((t.RecordTypeId == TELEMARKETINGID || t.RecordTypeId == ACTION_PLAN || t.RecordTypeId == ACTION_TRACKER
                   || t.RecordTypeId == SALES ) && t.WhatId != null){
                     String ids = t.WhatId;
                    if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        system.debug('Stringid' + ids);
                    }
                     if(ids.substring(0,3) == keyPrefix){
                        AccountIdset.add(t.WhatId);
                        if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('AccountId' + AccountIdset);
                        }
                    }
                }
            }
            List<Account> AccountListToBeUpdate = new List<Account>();

            if(!AccountIdset.isEmpty()){
                /*for(Account acc : [SELECT Id, AccountStatus__c, OwnerId FROM Account WHERE ID IN: AccountIdset] ){
                    TaskAccountIdMap.put(acc.Id , acc.OwnerId);
                }*/

                TaskAccountIdMap = new map<Id, Account>([SELECT Id, AccountStatus__c, OwnerId FROM Account WHERE ID IN: AccountIdset]);
                if (pTaskList.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
                    system.debug('TaskAccountIdMap' + TaskAccountIdMap);
                }
                if(!TaskAccountIdMap.isEmpty()){
                    for(Task t : pTaskList){
                        if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                            system.debug('Taskt' + t);
                            system.debug('t.WhatId' + t.WhatId);
                            system.debug('t.CallDisposition' + t.CallDisposition);
                            system.debug('t.RecordTypeId' + t.RecordTypeId);
                        }
                        //if(t.RecordTypeId==TELEMARKETINGID && t.WhatId!= null && t.CallDisposition != null ){
                        if((t.RecordTypeId == TELEMARKETINGID || t.RecordTypeId == ACTION_PLAN || t.RecordTypeId == ACTION_TRACKER
                            || t.RecordTypeId == SALES ) && t.WhatId != null){
                            if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                                system.debug('TaskAccountIdMap.containsKey(t.WhatId)' + TaskAccountIdMap.containsKey(t.WhatId));
                                system.debug('TaskAccountIdMap.get(t.WhatId)' + TaskAccountIdMap.get(t.WhatId));
                            }
                            if(TaskAccountIdMap.containsKey(t.WhatId) && TaskAccountIdMap.get(t.WhatId) != null){
                                if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                                    system.debug('TaskAccountIdMap' + TaskAccountIdMap.get(t.WhatId).OwnerId );
                                }
                                t.OwnerId = TaskAccountIdMap.get(t.WhatId).OwnerId ;
                                if (pTaskList.size() <= cutoff || t.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                                    system.debug('t.OwnerId' + t.OwnerId);
                                }
                            }
                        }
                    }
                }
            }

        /*}catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'ReassignTaskOnUpdate', ex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.ReassignTaskOnUpdate()', 'Failed to reassign Task. Please see system logs for details. \nError: '+ex.getMessage()  );
        }*/
    }
    //---------------AS PER TONY'S REQUEST TO ADD THE FOLLOWING CODE ----------------
    public void updateContactDoNotCall(list<Task> pTaskList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateContactDoNotCall');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            Schema.DescribeSObjectResult r = Contact.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            set<Id> ContactIdset = new set<Id>();
            for(Task t : pTaskList){
                if(t.RecordTypeId== TELEMARKETINGID ){
                    if(t.CallDisposition == 'Do Not Call'){
                        String conId = t.WhoId;
                        if(conId.substring(0,3) == keyPrefix){
                            ContactIdset.add(t.WhoId);
                        }
                    }
                }
            }
            List<Contact> ContactListToBeUpdate = new List<Contact>();
            if(!ContactIdset.isEmpty()){
                for(Contact con : [SELECT Id, DoNotCall FROM Contact WHERE ID IN: ContactIdset] ){
                    con.DoNotCall = true;
                    ContactListToBeUpdate.add(con);
                }
            }
            if (pTaskList.size() <= cutoff){ //JFreese Appirio S-435483 4/11/17
                system.debug('^ContactListToBeUpdate : ' + ContactListToBeUpdate );
            }

            if(!ContactListToBeUpdate.isEmpty()){
                update ContactListToBeUpdate;
            }
        /*}catch(Exception ex){
            ExceptionLog.add(ex.getTypeName(), 'TaskTriggerHelper', 'updateContactDoNotCall', ex.getMessage());
            throw BaseApplicationException.NewException('TaskTriggerHelper.updateContactDoNotCall()', 'Failed to update the Do Not Call field of the related Contact. Please see system logs for details. \nError: '+ex.getMessage()  );
        } */
    }

    public void updateCaseFirstContactActualDateField(list<Task> pTaskList)
    {
        List<Id> tskWhatIdList = new List<Id>();
        Map<Id,Case> caseMap = null;
        Case tmpCase = null;
        List<Case> caseListToUpdate = new List<Case>();

        Schema.DescribeSObjectResult r = Case.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();

        for(Task tsk : pTaskList)
        {
            String ids = tsk.WhatId;
            if(tsk.WhatId != null){
                if(ids.substring(0,3) == keyPrefix)
                {
                    tskWhatIdList.add(tsk.WhatId);
                }
            }

        }
        if(tskWhatIdList.size() > 0)
        {
            caseMap = new Map<Id,Case>([select id,casenumber,subject,First_Contact_Actual_Date_Time__c from Case where Id IN: tskWhatIdList]);
            if(caseMap.size() > 0)
            {
                for(Case cs : caseMap.values())
                {
                    for(Task tsk : pTaskList)
                    {
                        //Jeff L added a null check - it was throwing a null pointer exception otherwise
                        if(tsk.ActivityType__c != null){
                            if((tsk.ActivityType__c).contains('Call') || (tsk.ActivityType__c).contains('Email'))
                            {
                                tmpCase = caseMap.get(tsk.WhatId);
                                if(tmpCase.First_Contact_Actual_Date_Time__c == null)
                                {
                                    tmpCase.First_Contact_Actual_Date_Time__c = datetime.now();
                                    caseListToUpdate.add(tmpCase);
                                }
                            }
                        }

                    }
                }
                if(caseListToUpdate.size() > 0)
                {
                    update caseListToUpdate;
                }
            }
        }

    }
     //To throw an error message if the Account is not recently converted from a Lead
    //I-219837 - Deepanshu Soni Appirio
    public void checkIfAccountRecentlyConverted (list<Task> pTaskList)
    {
        Set<Id> AccountIds = new Set<Id>();
        List<Account> accToCheck = new List<Account>();
        if(pTaskList != null)
		{
			for(Task t : pTaskList)
			{
			   if(t.AccountId != null)
			   {
				  AccountIds.add(t.AccountId) ;
			   }
            }
            accToCheck = [SELECT Id,ConvertedFromLead__c,CreatedDate from Account where Id IN :AccountIds];
            for(Account acc : accToCheck)
            {
                if((acc.ConvertedFromLead__c) && (acc.CreatedDate.addMinutes(3)<System.now()))
            	{
                	acc.addError('Only a Service Manager can make changes to the event once its complete');
            	}
            }
    	}
	}
}