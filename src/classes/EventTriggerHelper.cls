public class EventTriggerHelper {
  final String CLASSNAME = '\n\n**** EventTriggerHelper.METHODNAME()';
    
    private String UserProfileName{get; private set;}
    
/*
** @author : Cloud Sherpas Inc.
** @date : 07/29/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the EventTriggerHelper class
*/
    public static EventTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        EventTriggerHelper newHelper = new EventTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/29/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private EventTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','EventTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
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
*/   
/*    public void updateMaxActivityDateAndOwnerOfAccount(list<Event> pEventList){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateMaxActivityDateAndOwnerOfAccount');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        /*Map<Id, Event> EventAccountMap = new Map<Id, Event>();
        for(Event e : pEventList){
            EventAccountMap.put(e.AccountId, e);
        }
        List<Account> AccountToBeUpdated = new List<Account>();
        for(Account acc: [SELECT Id, MaxActivityDate__c, MaxActivityDateOwner__c FROM Account WHERE Id IN: EventAccountMap.keySet()] ){
            if(EventAccountMap.get(acc.Id).CreatedDate != null ){
                acc.MaxActivityDate__c = EventAccountMap.get(acc.Id).CreatedDate;
            }
            if(EventAccountMap.get(acc.Id).ownerId != null ){
                acc.MaxActivityDateOwner__c = EventAccountMap.get(acc.Id).ownerId;
            }
            AccountToBeUpdated.add(acc);
        }
         
        if(!AccountToBeUpdated.isEmpty()){
            try{
                update AccountToBeUpdated;
            }catch(Exception ex){
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Error on updating account. Please see system logs for details.', ex);
            }
        }
        TriggerHelperWithoutSharing.getInstance().updateMaxActivityDateAndOwnerOfAccount(pEventList);
    }

        /*
** @author : Cloud Sherpas, Inc.
** @date : 08/13/2014
** @Story : 0576
** @Element : E1951
** @description : Populate the Phone by Contact.
** @param : list of Event
** @returns : nothing
*/   
    public void populatePhoneNumber(list<Event> pEventList){ 
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','populatePhoneNumber');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        try{
            List<Contact> con = new List<Contact>();
            List<Event> eventUpdate = new List<Event>();
            map<Id,Id> eventMap = new map<Id,Id>();
            set<Id> contactIds = new set<Id>();
            for(Event e : pEventList){
                String checkId = String.Valueof(e.WhoId);
                if(checkId != null && checkId.startsWithIgnoreCase('003')){
                    eventMap.put(e.Id, e.WhoId);
                    contactIds.add(e.WhoId);
                }
            }
            //eventUpdate = [SELECT Id, ContactPhone__c, WhoId FROM Event WHERE Id In : eventMap.keySet()];
            con = [SELECT Id, Phone, JobPosition__c, ContactType__c FROM Contact WHERE Id in : contactIds];
            map<Id,Contact> conMap = new map<Id,Contact>();
            for(Contact c : con){
                conMap.put(c.Id, c);
            }
            //List<Event> eventToUpdate = new List<Event>();
            if(con.size() > 0){
                for(Event evnt : pEventList){
                    //if(evnt.ContactPhone__c != conMap.get(evnt.WhoId)){
                    if(conMap.get(evnt.WhoId) != null){
                        evnt.ContactPhone__c = conMap.get(evnt.WhoId).Phone;
                        evnt.ContactType__c = conMap.get(evnt.WhoId).ContactType__c;
                        evnt.ContactJobPosition__c = conMap.get(evnt.WhoId).JobPosition__c;
                        //eventToUpdate.add(evnt);
                    }
                }
            }
            //if(eventToUpdate.size() > 0){
            //    update eventToUpdate;
            //}

        }catch(Exception dmlex){
            ExceptionLog.add(dmlex.getTypeName(), 'EventTriggerHelper', 'populatePhoneNumber', dmlex.getMessage());
            throw BaseApplicationException.NewException('EventTriggerHelper.populatePhoneNumber()', dmlex.getMessage());
        } 
    }




    public void ReassignEventOnAccount(list<Event> pEventList){

        ID ACTION_PLAN_EVENT = Schema.SObjectType.Event.RecordTypeInfosByName.get('Action Plan Event').RecordTypeId;
        ID SALES_EVENT = Schema.SObjectType.Event.RecordTypeInfosByName.get('Sales - Event').RecordTypeId;
                        
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        map<Id,Account> EventAccountIdMap = new map<Id,Account>();
        set<Id> AccountIdset = new set<Id>();
        for(Event e : pEventList){
           if((e.RecordTypeId == ACTION_PLAN_EVENT || e.RecordTypeId == SALES_EVENT) && e.WhatId != null){    
                 String ids = e.WhatId;                     
                 if(ids.substring(0,3) == keyPrefix){
                    AccountIdset.add(e.WhatId);                        
                }
            }
        }            
        if(!AccountIdset.isEmpty()){
        
            EventAccountIdMap = new map<Id, Account>([SELECT Id, AccountStatus__c, OwnerId FROM Account 
                                                     WHERE ID IN: AccountIdset]);
            if(!EventAccountIdMap.isEmpty()){
                for(Event e : pEventList){
                     if((e.RecordTypeId == ACTION_PLAN_EVENT || e.RecordTypeId == SALES_EVENT) && e.WhatId != null){ 
                        if(EventAccountIdMap.containsKey(e.WhatId) && EventAccountIdMap.get(e.WhatId) != null){
                           e.OwnerId = EventAccountIdMap.get(e.WhatId).OwnerId;                        
                        }
                    }
                }
            }
        }          
          
    }
	 //To throw an error message if the Account is not recently converted from a Lead
    //I-219837 - Deepanshu Soni Appirio
    public void checkIfAccountRecentlyConverted (list<Event> pEventList)
    {
        Set<Id> AccountIds = new Set<Id>();
        List<Account> accToCheck = new List<Account>();		
        if(pEventList != null) 
		{
			for(Event e : pEventList) 
			{
			   if(e.AccountId != null)
			   {
				  AccountIds.add(e.AccountId) ;
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