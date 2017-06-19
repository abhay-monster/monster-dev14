/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description :   class that supports the 'UserTriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class UserTriggerHelper {
    final String CLASSNAME = '\n\n**** TriggerHelper.METHODNAME()';  
    
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/23/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the TriggerHelper class
*/
    public static UserTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserTriggerHelper newHelper = new UserTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private UserTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UserTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    }
    


/*
** @author : Cloud Sherpas, Inc.
** @date : 04/21/2014
** @description : Update the Sales Quota's fields(Division__c, Location__c, Status__c) with those of the related user's field.
** @paramaters : List of updated Users
** @returns : nothing
*/   
    public void UpdateSalesQuotas(List<User> pUpdatedUsers, map<ID, User> pUserIdToOldAccountMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateQuoteProposalOrganization');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Map<Id,User> UserMap = new Map<Id,User>();
        for(User usr : pUpdatedUsers){
            if((usr.Status__c != pUserIdToOldAccountMap.get(usr.Id).Status__c) ||
               (usr.Location__c != pUserIdToOldAccountMap.get(usr.Id).Location__c) ||
               (usr.Division__c != pUserIdToOldAccountMap.get(usr.Id).Division__c) ||
               (usr.PositionSalesGroup__c != pUserIdToOldAccountMap.get(usr.Id).PositionSalesGroup__c) ||
               (usr.PositionSalesChannel__c != pUserIdToOldAccountMap.get(usr.Id).PositionSalesChannel__c)||
               (usr.UserPositionRegion__c != pUserIdToOldAccountMap.get(usr.Id).UserPositionRegion__c) ||
               (usr.Organisation__c  != pUserIdToOldAccountMap.get(usr.Id).Organisation__c ) ||
               (usr.Extension!= pUserIdToOldAccountMap.get(usr.Id).Extension) ||
               (usr.Phone!= pUserIdToOldAccountMap.get(usr.Id).Phone) ||
               (usr.DefaultCurrencyIsoCode!= pUserIdToOldAccountMap.get(usr.Id).DefaultCurrencyIsoCode) ||
               (usr.ManagerId != pUserIdToOldAccountMap.get(usr.Id).ManagerId) ||
               (usr.Phone != pUserIdToOldAccountMap.get(usr.Id).Phone) ||
               (usr.Extension != pUserIdToOldAccountMap.get(usr.Id).Extension) ||
               (usr.Name != pUserIdToOldAccountMap.get(usr.Id).Name) ||
               (usr.Title != pUserIdToOldAccountMap.get(usr.Id).Title)
              ){
                UserMap.put(usr.Id, usr);
            }
        }
        
        List<Sales_Quotas__c> SQsToBeUpdated = new List<Sales_Quotas__c>();
        if(UserMap.size() > 0){
            for(Sales_Quotas__c sq : [Select Id, Division__c, Location__c, Status__c,  Name__c  FROM Sales_Quotas__c WHERE Name__c IN : UserMap.keySet()]){
                //sq.PositionSalesGroup__c = UserMap.get(sq.Name__c).PositionSalesGroup__c ;
                //sq.PositionSalesChannel__c = UserMap.get(sq.Name__c).PositionSalesChannel__c ;
                //sq.PositionRegion__c = UserMap.get(sq.Name__c).UserPositionRegion__c ;
                sq.Division__c = UserMap.get(sq.Name__c).Division__c ;
                sq.Location__c = UserMap.get(sq.Name__c).Location__c ;
                sq.Status__c = UserMap.get(sq.Name__c).Status__c ;
                sq.Organisation__c = UserMap.get(sq.Name__c).Organisation__c;
                sq.Ext__c = UserMap.get(sq.Name__c).Extension;
                sq.WorkPhone__c = UserMap.get(sq.Name__c).Phone;
                sq.CurrencyIsoCode = UserMap.get(sq.Name__c).DefaultCurrencyIsoCode;
                sq.WorkPhone__c = UserMap.get(sq.Name__c).Phone;
                sq.Ext__c = UserMap.get(sq.Name__c).Extension;
                sq.Name = UserMap.get(sq.Name__c).Name;
                sq.Position__c = UserMap.get(sq.Name__c).Title;
                SQsToBeUpdated.add(sq);
            }
            if(SQsToBeUpdated.size() >0){
                update SQsToBeUpdated;
            }
        }
        
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/20/2014
** @description : Adds user information to Monster Phone List for click-to-call 
** @paramaters : List of new Users
** @returns : nothing
*/     
    @future  
    public static void AddNewUserToMonsterPhoneList(set<Id> pList){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','AddNewUserToMonsterPhoneList');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        List<User> pUserList = [Select Id,Division__c,Division,Extension,FirstName,LastName,ProfileId,Title,Phone
                                 from User Where Id IN :pList ];
                                 
        map<Id,Profile> profileIdToProfileMap = new map<Id,Profile>([SELECT Id, Name FROM Profile]);
        
        list<MonsterPhoneList__c> monsterPhonelist = new list<MonsterPhoneList__c>();
        for(User oUser : pUserList){
            system.debug('Check *****' + String.IsBlank(oUser.Phone));
            if(!String.IsBlank(oUser.Phone)){
                MonsterPhoneList__c monsterPhone =  new MonsterPhoneList__c();
                if(!String.IsBlank(oUser.Division)){monsterPhone.Division__c = oUser.Division__c;}
                if(!String.IsBlank(oUser.Extension)){monsterPhone.Extension__c = oUser.Extension;}
                if(!String.IsBlank(oUser.FirstName)){monsterPhone.FirstName__c = oUser.FirstName;}
                if(!String.IsBlank(oUser.LastName)){monsterPhone.LastName__c = oUser.LastName;}
                if(!String.IsBlank(profileIdToProfileMap.get(oUser.ProfileId).Name)){monsterPhone.Profile__c = profileIdToProfileMap.get(oUser.ProfileId).Name;}
                if(!String.IsBlank(oUser.Title)){monsterPhone.Title__c = oUser.Title;}
                if(!String.IsBlank(oUser.FirstName) || !String.IsBlank(oUser.LastName)){monsterPhone.User_Name__c = oUser.FirstName + ' ' + oUser.LastName;}
                if(!String.IsBlank(oUser.Phone)){monsterPhone.UserPhone__c = oUser.Phone;}
                if(!String.IsBlank(oUser.Id)){monsterPhone.UserId__c = oUser.Id;}
            
                monsterPhonelist.add(monsterPhone);
            }
        }
        
        if(!monsterPhonelist.IsEmpty()){
            insert monsterPhonelist;
        }       
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/20/2014
** @description : Updates to deletes user information to Monster Phone List for click-to-call 
** @paramaters : List of Updated Users
** @returns : nothing
*/  
// not in use       
  /*  public void UpdateMonsterPhoneList(list<User> pUserList, map<Id,User> pUserIdToUserMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateMonsterPhoneList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        list<MonsterPhoneList__c> monsterPhoneToUpdatelist = new list<MonsterPhoneList__c>();
        list<MonsterPhoneList__c> monsterPhoneToDeletelist = new list<MonsterPhoneList__c>();
        set<Id> userIdSet = new set<Id>();
        
        // create a map of Profile ids to Profile map need to get the Profile name.
        map<Id,Profile> profileIdToProfileMap = new map<Id,Profile>([SELECT Id, Name FROM Profile]);
        
        // create a user id to Monster Phone List record map 
        list<MonsterPhoneList__c> monsterPhonelist = [SELECT Id, Division__c, Extension__c, FirstName__c, LastName__c, Profile__c, Title__c, User_Name__c, UserPhone__c, UserId__c FROM MonsterPhoneList__c WHERE UserId__c IN : pUserIdToUserMap.KeySet()];        
        map<Id, MonsterPhoneList__c> userIdToMonsterPhoneMap = new map<Id, MonsterPhoneList__c>();      
        for(MonsterPhoneList__c monsterPhone : monsterPhonelist){
            userIdToMonsterPhoneMap.put(monsterPhone.UserId__c, monsterPhone);
        }       
        
        for(User oUser : pUserList){
            if(!oUser.IsActive){
                if(userIdToMonsterPhoneMap.ContainsKey(oUser.Id)){
                    monsterPhoneToDeletelist.add(userIdToMonsterPhoneMap.get(oUser.Id));
                }
            }
            else{
                if(userIdToMonsterPhoneMap.ContainsKey(oUser.Id)){
                    if(!String.IsBlank(oUser.Division)){userIdToMonsterPhoneMap.get(oUser.Id).Division__c = oUser.Division;}
                    if(!String.IsBlank(oUser.Extension)){userIdToMonsterPhoneMap.get(oUser.Id).Extension__c = oUser.Extension;}                 
                    if(!String.IsBlank(oUser.FirstName)){userIdToMonsterPhoneMap.get(oUser.Id).FirstName__c = oUser.FirstName;}                 
                    if(!String.IsBlank(oUser.LastName)){userIdToMonsterPhoneMap.get(oUser.Id).LastName__c = oUser.LastName;}
                    if(!String.IsBlank(profileIdToProfileMap.get(oUser.ProfileId).Name)){userIdToMonsterPhoneMap.get(oUser.Id).Profile__c = profileIdToProfileMap.get(oUser.ProfileId).Name;}
                    if(!String.IsBlank(oUser.Title)){userIdToMonsterPhoneMap.get(oUser.Id).Title__c = oUser.Title;}
                    if(!String.IsBlank(oUser.FirstName) || !String.IsBlank(oUser.LastName)){userIdToMonsterPhoneMap.get(oUser.Id).User_Name__c = oUser.FirstName + ' ' + oUser.LastName;}
                    if(!String.IsBlank(oUser.Phone)){userIdToMonsterPhoneMap.get(oUser.Id).UserPhone__c = oUser.Phone;}
                    if(!String.IsBlank(oUser.Id)){userIdToMonsterPhoneMap.get(oUser.Id).UserId__c = oUser.Id;}
                    
                    monsterPhoneToUpdatelist.add(userIdToMonsterPhoneMap.get(oUser.Id));
                }else{
                    userIdSet.add(oUser.Id);                    
                }
            }
        }
        
         // delete Monster Phone List recored whe user is set to inactive 
        if(!monsterPhoneToDeletelist.IsEmpty()){
            delete monsterPhoneToDeletelist;
        }
        
        // update Monster Phone List record
        if(!monsterPhoneToUpdatelist.IsEmpty()){ 
            update monsterPhoneToUpdatelist;
        }   
        
        // call future method to add user to Monster Phone List
        if(!userIdSet.IsEmpty()){
            InsertMonsterPhoneList(userIdSet);
        }       
    }
    */
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/20/2014
** @description : Updates to deletes user information to Monster Phone List for click-to-call 
** @paramaters : List of Updated Users
** @returns : nothing
*/         
    public void ManageMonsterPhoneList(map<Id,User> pUserIdToUserMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ManageMonsterPhoneList');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ')); 
        
        //set<Id> userIdSet = pUserIdToUserMap.KeySet();      
        system.debug('Check ##' + pUserIdToUserMap.KeySet());
        if(!System.isBatch()) {
            UpdateMonsterPhoneList(pUserIdToUserMap.KeySet());
        }      
    }
    
/*
** @author : Cloud Sherpas, Inc.
** @date : 05/22/2014
** @description : Future method to insert user information into the Monster Phone List for click-to-call when the User exists and call list record does not. 
** @paramaters : List of Updated Users
** @returns : nothing
*/  
    @future
    public static void UpdateMonsterPhoneList(set<Id> pUserIdSet) {
        
        list<MonsterPhoneList__c> monsterPhoneToInsertlist = new list<MonsterPhoneList__c>();
        list<MonsterPhoneList__c> monsterPhoneToUpdatelist = new list<MonsterPhoneList__c>();
        list<MonsterPhoneList__c> monsterPhoneToDeletelist = new list<MonsterPhoneList__c>();
        
        map<Id,Profile> profileIdToProfileMap = new map<Id,Profile>([SELECT Id, Name FROM Profile]);
        system.debug('Check' +  pUserIdSet);
        // create a user id to Monster Phone List record map 
        list<MonsterPhoneList__c> monsterPhonelist = [SELECT Id , Division__c, Extension__c, FirstName__c, LastName__c, Profile__c, Title__c, User_Name__c, UserPhone__c, UserId__c FROM MonsterPhoneList__c WHERE UserId__c IN : pUserIdSet];       
        map<Id, MonsterPhoneList__c> userIdToMonsterPhoneMap = new map<Id, MonsterPhoneList__c>();      
        system.debug('Check $$$' + monsterPhonelist);
        for(MonsterPhoneList__c monsterPhone : monsterPhonelist){
            userIdToMonsterPhoneMap.put(monsterPhone.UserId__c, monsterPhone);
        }       
        
        for(User oUser : [SELECT Id, Division__c, Division, Extension, FirstName,LastName, Title, Phone, ProfileId, IsActive FROM User WHERE Id IN : pUserIdSet]){
            if(!oUser.IsActive){
                if(userIdToMonsterPhoneMap.ContainsKey(oUser.Id)){
                    monsterPhoneToDeletelist.add(userIdToMonsterPhoneMap.get(oUser.Id));
                }
            }
            else{
                if(userIdToMonsterPhoneMap.ContainsKey(oUser.Id)){
                    if(!String.IsBlank(oUser.Division)){userIdToMonsterPhoneMap.get(oUser.Id).Division__c = oUser.Division;}
                    if(!String.IsBlank(oUser.Extension)){userIdToMonsterPhoneMap.get(oUser.Id).Extension__c = oUser.Extension;}                 
                    if(!String.IsBlank(oUser.FirstName)){userIdToMonsterPhoneMap.get(oUser.Id).FirstName__c = oUser.FirstName;}                 
                    if(!String.IsBlank(oUser.LastName)){userIdToMonsterPhoneMap.get(oUser.Id).LastName__c = oUser.LastName;}
                    if(!String.IsBlank(profileIdToProfileMap.get(oUser.ProfileId).Name)){userIdToMonsterPhoneMap.get(oUser.Id).Profile__c = profileIdToProfileMap.get(oUser.ProfileId).Name;}
                    if(!String.IsBlank(oUser.Title)){userIdToMonsterPhoneMap.get(oUser.Id).Title__c = oUser.Title;}
                    if(!String.IsBlank(oUser.FirstName) || !String.IsBlank(oUser.LastName)){userIdToMonsterPhoneMap.get(oUser.Id).User_Name__c = oUser.FirstName + ' ' + oUser.LastName;}
                    if(!String.IsBlank(oUser.Phone)){userIdToMonsterPhoneMap.get(oUser.Id).UserPhone__c = oUser.Phone;}
                    if(!String.IsBlank(oUser.Id)){userIdToMonsterPhoneMap.get(oUser.Id).UserId__c = oUser.Id;}
                    
                    monsterPhoneToUpdatelist.add(userIdToMonsterPhoneMap.get(oUser.Id));
                }else{
                    if(!String.IsBlank(oUser.Phone)){
                        MonsterPhoneList__c monsterPhone =  new MonsterPhoneList__c();
                        if(!String.IsBlank(oUser.Division)){monsterPhone.Division__c = oUser.Division__c;}
                        if(!String.IsBlank(oUser.Extension)){monsterPhone.Extension__c = oUser.Extension;}
                        if(!String.IsBlank(oUser.FirstName)){monsterPhone.FirstName__c = oUser.FirstName;}
                        if(!String.IsBlank(oUser.LastName)){monsterPhone.LastName__c = oUser.LastName;}
                        if(!String.IsBlank(profileIdToProfileMap.get(oUser.ProfileId).Name)){monsterPhone.Profile__c = profileIdToProfileMap.get(oUser.ProfileId).Name;}
                        if(!String.IsBlank(oUser.Title)){monsterPhone.Title__c = oUser.Title;}
                        if(!String.IsBlank(oUser.FirstName) || !String.IsBlank(oUser.LastName)){monsterPhone.User_Name__c = oUser.FirstName + ' ' + oUser.LastName;}
                        if(!String.IsBlank(oUser.Phone)){monsterPhone.UserPhone__c = oUser.Phone;}
                        if(!String.IsBlank(oUser.Id)){monsterPhone.UserId__c = oUser.Id;}
                
                        monsterPhoneToInsertlist.add(monsterPhone);
                    }                   
                }
            }
        }
        
         // delete Monster Phone List recored whe user is set to inactive 
        if(!monsterPhoneToDeletelist.IsEmpty()){
            delete monsterPhoneToDeletelist;
        }
        
        // update Monster Phone List record
        if(!monsterPhoneToUpdatelist.IsEmpty()){ 
            update monsterPhoneToUpdatelist;  
        } 
        
        // call future method to add user to Monster Phone List
        if(!monsterPhoneToInsertlist.IsEmpty()){
            insert monsterPhoneToInsertlist;
        }         
    }   

/*
** @author : Cloud Sherpas, Inc.
** @date : 05/22/2014
** @description : Future method to insert user information into the Monster Phone List for click-to-call when the User exists and call list record does not. 
** @paramaters : List of Updated Users
** @returns : nothing
*/  
// Not in use
/*    @future
    public static void InsertMonsterPhoneList(set<Id> pUserIdSet) {
        
        list<MonsterPhoneList__c> monsterPhoneToInsertlist = new list<MonsterPhoneList__c>();
        
        map<Id,Profile> profileIdToProfileMap = new map<Id,Profile>([SELECT Id, Name FROM Profile]);
        
        // create a user id to Monster Phone List record map 
        list<MonsterPhoneList__c> monsterPhonelist = [SELECT Id, Division__c, Extension__c, FirstName__c, LastName__c, Profile__c, Title__c, User_Name__c, UserPhone__c, UserId__c FROM MonsterPhoneList__c WHERE UserId__c IN : pUserIdSet];       
        map<Id, MonsterPhoneList__c> userIdToMonsterPhoneMap = new map<Id, MonsterPhoneList__c>();      
        for(MonsterPhoneList__c monsterPhone : monsterPhonelist){
            userIdToMonsterPhoneMap.put(monsterPhone.UserId__c, monsterPhone);
        }       
        
        for(User oUser : [SELECT Id, Division__c, Division, Extension, FirstName,LastName, Title, Phone, ProfileId FROM User WHERE Id IN : pUserIdSet]){
            if(!userIdToMonsterPhoneMap.ContainsKey(oUser.Id)){
                if(!String.IsBlank(oUser.Phone)){
                    MonsterPhoneList__c monsterPhone =  new MonsterPhoneList__c();
                    if(!String.IsBlank(oUser.Division)){monsterPhone.Division__c = oUser.Division__c;}
                    if(!String.IsBlank(oUser.Extension)){monsterPhone.Extension__c = oUser.Extension;}
                    if(!String.IsBlank(oUser.FirstName)){monsterPhone.FirstName__c = oUser.FirstName;}
                    if(!String.IsBlank(oUser.LastName)){monsterPhone.LastName__c = oUser.LastName;}
                    if(!String.IsBlank(profileIdToProfileMap.get(oUser.ProfileId).Name)){monsterPhone.Profile__c = profileIdToProfileMap.get(oUser.ProfileId).Name;}
                    if(!String.IsBlank(oUser.Title)){monsterPhone.Title__c = oUser.Title;}
                    if(!String.IsBlank(oUser.FirstName) || !String.IsBlank(oUser.LastName)){monsterPhone.User_Name__c = oUser.FirstName + ' ' + oUser.LastName;}
                    if(!String.IsBlank(oUser.Phone)){monsterPhone.UserPhone__c = oUser.Phone;}
                    if(!String.IsBlank(oUser.Id)){monsterPhone.UserId__c = oUser.Id;}
                
                    monsterPhoneToInsertlist.add(monsterPhone);
                }
            }
        }
        
        if(!monsterPhoneToInsertlist.IsEmpty()){
            insert monsterPhoneToInsertlist;
        }
    } */
}