/*
    * Class Name  :   AptsQuoteApprovalHelper
    * Developed By:   Bhanu Devaguptapu
    * Description :   Used to update Lookup field of approval managers on Proposal
                      Used to update checkbox field on Proposal up to which level approval is required
    * Version     :   V 1.0
    * Created Date:   5-Sep-2014
*/
public class AptsQuoteApprovalHelper{
    /* 
        ***************************************************************
        * @Param : List of Apttus_Proposal__Proposal__c
        * Return Type : NA
        * Called from "Apts_Quoteaprvl" trigger to update manager lookup fields on Proposal Object
        ***************************************************************     
     */ 
    public static void updateManager(List<Apttus_Proposal__Proposal__c> lst_ApttusProposal){
        // Query on User Object to get All active users and not having chatter profile
        Map<Id, User> map_AllUsers = new Map<Id, user>([Select Id, Discount_Threshold__c, ManagerId from user WHERE isActive=true AND Profile.Name !='Chatter External User' AND Profile.Name !='Chatter Free User' AND Profile.Name !='Chatter Moderator User']);
        Map<String, String> map_User2Manager = new Map<String, String>(); // Map User to Manager
        for(User usr : map_AllUsers.values()){
            map_User2Manager.put(usr.Id, usr.ManagerId);
        }
        // For every Proposal record we will call "clearRecord" & "updateTheshold" methods
        for(Apttus_Proposal__Proposal__c var : lst_ApttusProposal){
            //System.debug('------SS_--- '+ var.TotalDiscount__c);
            clearRecord(var); // Clear old Values
            //system.debug('var.APTS_Opportunity_Record_Type__c-->' + var.APTS_Opportunity_Record_Type__c);
             //I-168512 - added 2nd condition
         	 if(var.RecordType.Name !='GCS Locked'  && var.RecordType.Name !='GCS Proposal')
            {
                updateTheshold(var, map_User2Manager, map_AllUsers); // update new lookup field of manager & checkbox field
            }
            
            //If Quote is Product Conversion then populate First,Second and Third Line Manager
            if(var.APTS_Quote_Type__c == 'Product Conversion')
            {
                UpdateManagerForProductConversion(var, map_User2Manager, map_AllUsers);
            }
        }
    }
    /* 
        ***************************************************************
        * @Param : Object of Apttus_Proposal__Proposal__c
        * Return Type : NA
        * Private method to clear fields before insertinng or updating values
        ***************************************************************     
     */ 
    private static void clearRecord(Apttus_Proposal__Proposal__c Proposal){
        Proposal.Discount_Authority_Manager1__c = false;        
        Proposal.Discount_Authority_Manager2__c = false; 
        Proposal.Discount_Authority_Manager3__c = false;
        Proposal.Discount_Authority_Manager4__c = false;
        Proposal.Discount_Authority_Manager5__c = false;
        Proposal.Discount_Authority_Manager6__c = false;
        Proposal.Discount_Authority_Manager7__c = false;
        Proposal.Discount_Authority_Manager8__c = false;
        Proposal.Discount_Authority_Manager9__c = false;
        Proposal.Discount_Authority_Manager10__c = false;
        Proposal.Manager1__c = null;
        Proposal.Manager2__c = null;
        Proposal.Manager3__c = null;
        Proposal.Manager4__c = null;
        Proposal.Manager5__c = null;
        Proposal.Manager6__c = null;
        Proposal.Manager7__c = null;
        Proposal.Manager8__c = null;
        Proposal.Manager9__c = null;
        Proposal.Manager10__c = null;
    }
    /* 
        ***************************************************************
        * @Param : Object of Apttus_Proposal__Proposal__c, Map Of User to manager, Map of User
        * Return Type : NA
        * Update Values
        ***************************************************************     
     */ 
    private static void updateTheshold(Apttus_Proposal__Proposal__c Proposal , Map<String, String> map_User2Manger, Map<Id, User> map_Users){
        
        User currentManager;
        Integer MaxCount = 0;
        boolean isTotalDiscountExceedThreshhold = false;
        boolean canManagerApprove = false;
        //System.assert(map_Users.containsKey(Proposal.ownerId),'Map:'+map_Users + ','+Proposal.OwnerId);
        System.debug('Proposal.TotalDiscount__c '+ Proposal.TotalDiscount__c );
      //  System.debug('map_Users.get(Proposal.ownerId).Discount_Threshold__c '+ map_Users.get(Proposal.ownerId).Discount_Threshold__c );
       // System.debug('map_Users.containsKey(Proposal.ownerId) '+ map_Users.containsKey(Proposal.ownerId) );
        if(map_Users.containsKey(Proposal.ownerId) && map_Users.get(Proposal.ownerId).Discount_Threshold__c != null && Proposal.Total_Thresold_Discretionary_Discount__c > 0){
            System.debug('map_Users.get(Proposal.ownerId).Discount_Threshold__c '+ map_Users.get(Proposal.ownerId).Discount_Threshold__c );
            System.debug('Proposal.TotalDiscount__c '+ Proposal.TotalDiscount__c );
            if(map_Users.get(Proposal.ownerId).Discount_Threshold__c >= Proposal.Total_Thresold_Discretionary_Discount__c){
                MaxCount++;
                
            }
            else
            {
                isTotalDiscountExceedThreshhold = true;
            }
        }  
        
        // getting manger of user & verify Discount value
        if(map_User2Manger.containsKey(Proposal.OwnerId)){
            if(map_User2Manger.get(Proposal.OwnerId) != null && map_Users.containsKey(map_User2Manger.get(Proposal.OwnerId))){
                currentManager = map_Users.get(map_User2Manger.get(Proposal.OwnerId));
                if(currentManager != null && Proposal.Total_Thresold_Discretionary_Discount__c > 0 && currentManager.Discount_Threshold__c != null && Proposal.Total_Thresold_Discretionary_Discount__c <= currentManager.Discount_Threshold__c){
                    MaxCount++;
                    canManagerApprove = true;
                }
                System.debug('---- '+ currentManager );
            }   
        }
        boolean isAnyAuthorityManagerFound = false;
        
        system.debug('First ittration currentManager  :'+currentManager+'<> Proposal.Manager10__c :'+Proposal.Manager10__c+'<> Max count :'+isTotalDiscountExceedThreshhold+' isAnyAuthorityManagerFound<>'+isAnyAuthorityManagerFound);
        // iterrate over the loop untill we reach to last manager or current manager is not null
        while(currentManager != null && Proposal.Manager10__c == null && isTotalDiscountExceedThreshhold && !isAnyAuthorityManagerFound){
            system.debug('currentManager  :'+currentManager+'<> Proposal.Manager10__c :'+Proposal.Manager10__c+'<> Max count :'+isTotalDiscountExceedThreshhold+' isAnyAuthorityManagerFound<>'+isAnyAuthorityManagerFound);
           system.debug('santoshdebuggingapprovalsM1'+proposal.manager1__C);
            system.debug('santoshdebuggingapprovalsM2'+proposal.manager2__C);
             system.debug('santoshdebuggingapprovalsM3'+proposal.manager3__C);
              system.debug('santoshdebuggingapprovalsM4'+proposal.manager4__C);
               system.debug('santoshdebuggingapprovalsM4'+proposal.manager5__C);
                system.debug('santoshdebuggingapprovalsM6'+proposal.manager6__C);
                system.debug('santoshdebuggingapprovalsCurreM'+Currentmanager.id);
                
            if(Proposal.Manager1__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager1__c = true;
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
                    
              //      Proposal.Discount_Authority_Manager1__c = true;
                    isAnyAuthorityManagerFound = true;
                }
                 Proposal.Discount_Authority_Manager1__c = true;
                 Proposal.Manager1__c = currentManager.Id;
            }else if(Proposal.Manager2__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager2__c = true;   
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
               //     Proposal.Discount_Authority_Manager2__c = true;   
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager2__c = true;
                Proposal.Manager2__c = currentManager.Id;
            }else if(Proposal.Manager3__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager3__c = true;
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
              //     Proposal.Discount_Authority_Manager3__c = true;
                   isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager3__c = true;
                Proposal.Manager3__c = currentManager.Id;
            }else if(Proposal.Manager4__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager4__c = true;
                    isAnyAuthorityManagerFound = true;
                }*/
                 if(canManagerApprove)
                {
              //      Proposal.Discount_Authority_Manager4__c = true;
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager4__c = true;
                Proposal.Manager4__c = currentManager.Id;
            }else if(Proposal.Manager5__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager5__c = true;
                    isAnyAuthorityManagerFound = true;
                }*/
                 if(canManagerApprove)
                {
               //     Proposal.Discount_Authority_Manager5__c = true;
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager5__c = true;
                Proposal.Manager5__c = currentManager.Id;
            }else if(Proposal.Manager6__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager6__c = true;  
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
               //     Proposal.Discount_Authority_Manager6__c = true;  
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager6__c = true; 
                Proposal.Manager6__c = currentManager.Id;
            }else if(Proposal.Manager7__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager7__c = true;
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
               //     Proposal.Discount_Authority_Manager7__c = true;
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager7__c = true;
                Proposal.Manager7__c = currentManager.Id;
            }else if(Proposal.Manager8__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager8__c = true; 
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
                //    Proposal.Discount_Authority_Manager8__c = true; 
                    isAnyAuthorityManagerFound = true;
                }
                 Proposal.Discount_Authority_Manager8__c = true; 
                Proposal.Manager8__c = currentManager.Id;
            }else if(Proposal.Manager9__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager9__c= true;  
                    isAnyAuthorityManagerFound = true;
                }*/
                if(canManagerApprove)
                {
                  //  Proposal.Discount_Authority_Manager9__c= true;  
                    isAnyAuthorityManagerFound = true;
                }
                Proposal.Discount_Authority_Manager9__c= true;  
                Proposal.Manager9__c = currentManager.Id;
            }else if(Proposal.Manager10__c == null){
                /*if(MaxCount <= 1)
                {
                    Proposal.Discount_Authority_Manager10__c = true;   
                    isAnyAuthorityManagerFound= true;
                }*/
                if(canManagerApprove)
                {
                   // Proposal.Discount_Authority_Manager10__c= true;  
                    isAnyAuthorityManagerFound = true;
                }
                 Proposal.Discount_Authority_Manager10__c= true;  
                Proposal.Manager10__c = currentManager.Id;
            }
            // if TotalDiscount equals to Discount_Threshold then loop will execute once more else break;
            if(Proposal.Total_Thresold_Discretionary_Discount__c == currentManager.Discount_Threshold__c){
                MaxCount++;
            }else if(Proposal.Total_Thresold_Discretionary_Discount__c < currentManager.Discount_Threshold__c){
                MaxCount+=2;
            }
            // getting next manager of User
            if(currentManager.ManagerId != null && map_Users.containsKey(currentManager.ManagerId)){
                currentManager = map_Users.get(currentManager.ManagerId);
                if(currentManager.Discount_Threshold__c != null && Proposal.Total_Thresold_Discretionary_Discount__c <= currentManager.Discount_Threshold__c)
                {
                    canManagerApprove = true;
                }
            }else{
                currentManager = null;
            }
        }
        
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager1__c);
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager2__c);
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager3__c);
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager4__c);
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager5__c);
        system.debug('santoshdebuggingapprovalsauthority'+  Proposal.Discount_Authority_Manager6__c);
        
          if(Proposal.Manager1__c == null &&   map_Users.containsKey(map_User2Manger.get(Proposal.OwnerId)))
          {
              system.debug('Proposal.Manager1__c is null'+  Proposal.Manager1__c);
            Proposal.Manager1__c = map_Users.get(map_User2Manger.get(Proposal.OwnerId)).id;
         }
       
    }
    
    //This will be executed only in the case of Product Conversion
    private static void UpdateManagerForProductConversion(Apttus_Proposal__Proposal__c Proposal , Map<String, String> map_User2Manger, Map<Id, User> map_Users)
    {
        User currentManager;                
        // getting manger of user & verify Discount value
        if(map_User2Manger.containsKey(Proposal.OwnerId)){
            if(map_User2Manger.get(Proposal.OwnerId) != null && map_Users.containsKey(map_User2Manger.get(Proposal.OwnerId))){
                currentManager = map_Users.get(map_User2Manger.get(Proposal.OwnerId));              
            }   
        }
      
        Proposal.Manager1__c = null;
        Proposal.Manager2__c = null;
        Proposal.Manager3__c = null;
        // iterrate over the loop untill we reach to last manager or current manager is not null
        while(currentManager != null){
            if(Proposal.Manager1__c == null){                             
                Proposal.Manager1__c = currentManager.Id;
            }else if(Proposal.Manager2__c == null){               
                Proposal.Manager2__c = currentManager.Id;
            }else if(Proposal.Manager3__c == null){               
                Proposal.Manager3__c = currentManager.Id;
            }
            else
            {
                break;
            }
            // getting next manager of User
            if(currentManager.ManagerId != null && map_Users.containsKey(currentManager.ManagerId)){
                currentManager = map_Users.get(currentManager.ManagerId);                
            }else{
                currentManager = null;
            }
        }     
        
       
    }
}