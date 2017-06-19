public with sharing class LicenseIDTriggerHelper {

final String CLASSNAME = '\n\n**** LicenseIDTriggerHelper.METHODNAME()';
    private String UserProfileName{get; private set;}

/*
** @author : Cloud Sherpas Inc.
** @date : 04/09/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the LicenseIDTriggerHelper class
*/
    public static LicenseIDTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        LicenseIDTriggerHelper newHelper = new LicenseIDTriggerHelper(pUserProfileName);
        return newHelper;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private LicenseIDTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','LicenseIDTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 07/16/2014
** @story : 2258
** @element :
** @description :
** @paramaters :
** @returns : nothing
*/
    public void MatchOrderFromLIDMAPPOLI(list<LicenseID__c> pLicenseIds){
      final string METHODNAME = CLASSNAME.replace('METHODNAME','MatchOrderFromLIDMAPPOLI');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
      try{
        set<Id> MAPPOLIIdSet = new set<Id>();
      for(LicenseID__c lid : pLicenseIds){
        if(lid.MAPP_OrderLineItem__c != null){
            MAPPOLIIdSet.add(lid.MAPP_OrderLineItem__c);
        }
        }

        system.debug('==MAPPOLIIdSet=='+MAPPOLIIdSet);
        Map<String,Id> OrderAndMAPPOrderIdMap = new Map<String, Id>();
        if(!MAPPOLIIdSet.IsEmpty()){
          for(Order_Line_Item__c oli : [SELECT Id, MAPP_OrderLineItem__c FROM Order_Line_Item__c WHERE MAPP_OrderLineItem__c IN: MAPPOLIIdSet]){
            OrderAndMAPPOrderIdMap.put(oli.MAPP_OrderLineItem__c, oli.Id);
          }
        }
        system.debug('==OrderAndMAPPOrderIdMap=='+OrderAndMAPPOrderIdMap);
        system.debug('==pLicenseIds=='+pLicenseIds);
        if(!OrderAndMAPPOrderIdMap.IsEmpty()){
          for(LicenseID__c lid : pLicenseIds){
          if(lid.MAPP_OrderLineItem__c != null){
              if(OrderAndMAPPOrderIdMap.containsKey(lid.MAPP_OrderLineItem__c) && OrderAndMAPPOrderIdMap.get(lid.MAPP_OrderLineItem__c) != null){
                lid.OrderLineItem__c = OrderAndMAPPOrderIdMap.get(lid.MAPP_OrderLineItem__c);
              }
          }
          }
        }
      }catch(Exception e){
             ExceptionLog.add('Exception', 'OrderTriggerHelper', 'MatchOrderFromLIDMAPPOLI', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'.'+e ,e);
        }
    }


/*
** @author : Appirio (Jonathan F)
** @date : 03/28/16
** @description : Make changes to incoming LicenseID for Ecomm orders
** @returns : nothing
*/
    public void fixEcomm(list<LicenseID__c> pLicenseIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';

        try{
            set<Id> setIds = new set<Id>();
            for(LicenseID__c lid : pLicenseIds){
              setIds.add(lid.OrderLineItem__c);
            }

            //Map of direct fields: {'sourceField' => 'destField'} - if destField != sourceField, copy sourceField to destField
            map<String, String> directFields = new map<String, String>();

            String relatedObject = 'Xcode_lkp__r';
            //Map of related fields: {'sourceField' => 'destField'} - if destField != relatedObject.sourceField, copy relatedObject.sourceField to destField
            map<String, String> relatedFields = new map<String, String>{'Xcode__c' => 'Xcode__c'};

            map<Id, Order_Line_Item__c> mapSrc = new map<Id, Order_Line_Item__c>();
            String queryStr = 'SELECT Id, ';
            for(String field : directFields.keySet()){
                queryStr += field + ',';
            }
            for(String field : relatedFields.keySet()){
                queryStr += relatedObject + '.' + field + ',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ' FROM Order_Line_Item__c WHERE ID IN (';
            for(String id : setIds){
                queryStr += '\'' + id + '\',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ')';
            system.debug('queryStr = '+ queryStr);

            List<Order_Line_Item__c> OLIs = Database.query(queryStr);
            for(Order_Line_Item__c oli : OLIs){
                mapSrc.put(oli.Id,oli);
            }

            for(LicenseID__c dest : pLicenseIds){
                fixed = '';
                if (mapSrc != null && mapSrc.containskey(dest.OrderLineItem__c)){
                    //process the direct references
                    for(String sourceField : directFields.keySet()){
                        String destField = directFields.get(sourceField);
                        if (dest.get(destField) != mapSrc.get(dest.OrderLineItem__c).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.OrderLineItem__c).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }

                    //process the related object references
                    for(String sourceField : relatedFields.keySet()){
                        String destField = relatedFields.get(sourceField);
                        SObject relObject = mapSrc.get(dest.OrderLineItem__c).getSobject(relatedObject);
                        if (relObject != null && dest.get(destField) != mapSrc.get(dest.OrderLineItem__c).getSobject(relatedObject).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.OrderLineItem__c).getSobject(relatedObject).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }
                }
                if (fixed != ''){
                    system.debug('^^^ Updated MAPP LicenseID__c  (fixed ' + fixed + '): ' + dest);
                }
            }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'LicenseIDTriggerHelper', 'fixEcomm', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix key field(s) on LicenseID.' ,e);
        }
    }

/*
** @author : Appirio (Jonathan F)
** @date : 04/14/16
** @description : Make changes to the LicenseID's Order Line Item for Ecomm orders
** @returns : nothing
*/
    public void fixEcomm_OLI(List<LicenseID__c> pLicenseIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm_OLI');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';

        try{
            set<Id> setIds = new set<Id>();
            for(LicenseID__c lid : pLicenseIds){
              setIds.add(lid.OrderLineItem__c);
            }


          map<Id, Order_Line_Item__c> mapOLI = new map<Id, Order_Line_Item__c>();
          for(Order_Line_Item__c oli : [Select ID, LineType__c from Order_Line_Item__c Where ID IN :setIds]){
            mapOLI.put(oli.Id,oli);
          }

          List<Order_Line_Item__c> OLIsToUpdate = new List<Order_Line_Item__c>();
          for(LicenseID__c lid : pLicenseIds){
            if (mapOLI != null && mapOLI.containskey(lid.OrderLineItem__c)){
              Order_Line_Item__c oli = new Order_Line_Item__c();
              oli.Id = mapOLI.get(lid.OrderLineItem__c).Id;

              if(mapOLI.get(lid.OrderLineItem__c).LineType__c == null){
                oli.LineType__c = 'Ecomm';
                fixed += ' LineType__c';
              }
              else {
                system.debug('Did NOT update the OLI LineType__c as it has a value of ' + mapOLI.get(lid.OrderLineItem__c).LineType__c);
              }

              if (fixed != ''){
                  OLIsToUpdate.add(oli);
                  system.debug('^^^ Updated MAPP OLI for ' + lid.Id + ' (fixed' + fixed + '): ' + oli);
              }
            }
          }

          if (fixed != ''){
            OrderLineItemTriggerHandler.ExecuteTriggers = false;
            update OLIsToUpdate;
            OrderLineItemTriggerHandler.ExecuteTriggers = true;
          }



/*            map<Id, Account> mapOLI = new map<Id, Account>();
            String queryStr = 'SELECT Id, LineType__c ';
            queryStr += ' FROM Account WHERE ID IN : setIds';
            for(String id : setIds){
                queryStr += '\'' + id + '\',';
            }
            queryStr = queryStr.left(queryStr.length() - 1);
            queryStr += ')';
            system.debug('queryStr = '+ queryStr);

            List<Account> ContactAccounts = Database.query(queryStr);
            for(Account a : ContactAccounts){
                mapOLI.put(a.Id,a);
            }

            List<Account> AccountsToUpdate = new List<Account>();
            for(Contact c : pContact){
                fixed = '';
                conType = '';
                if (mapOLI != null && mapOLI.containskey(c.AccountId)){
                    Account a = new Account();
                    a.Id = mapOLI.get(c.AccountId).Id;
                    //J Freese Appirio 4/8/16 I-I-207995 disable this
                    //per Anu/Shoba, if user changes both primary and billing, resulting in 2 contacts,
                    //then makes a new order and checks “use account info for billing contact”, it will make
                    //a new combined contact(!), which we need to update account from
                    //if (c.InternetType__c.contains('Internet Billing') && c.InternetType__c.contains('Internet Primary')){
                    //    system.Debug('Not updating any account fields based on Contact ' + c.Id + ' as it is the initial combined contact where InternetType__c=' + c.InternetType__c);
                    //}
                    if(c.InternetType__c.contains('Internet Billing')){
                        conType = 'Billing';
                        for(String aField : billFields.keySet()){
                            String cField = billFields.get(aField);
                            if (c.get(cField) != mapOLI.get(c.AccountId).get(aField)){
                                a.put(aField, c.get(cField));
                                fixed += ' ' + aField;
                            }
                        }
                    }
                    else if(c.InternetType__c.contains('Internet Primary')){
                        conType = 'Primary';
                        for(String aField : primFields.keySet()){
                            String cField = primFields.get(aField);
                            if (c.get(cField) != mapOLI.get(c.AccountId).get(aField)){
                                a.put(aField, c.get(cField));
                                fixed += ' ' + aField;
                            }
                        }
                    }
                    else {
                        system.Debug('Not updating any account fields based on Contact ' + c.Id + ' as it is not a MAPP contact - InternetType__c=' + c.InternetType__c);
                    }

                    if (fixed != ''){
                        AccountsToUpdate.add(a);
                        system.debug('^^^ Updated MAPP Account based on ' + conType + ' Contact ' + c.Id + ' (fixed' + fixed + '): ' + a);
                    }
                }
            }
            AccountTriggerHandler.ExecuteTriggers = false;
            update AccountsToUpdate;
            AccountTriggerHandler.ExecuteTriggers = true;*/
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'LineItemAttributesTriggerHelper', 'fixEcomm_OLI', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix OLI field(s) for the LicenseID.' ,e);
        }
    }

/*
** @author : Adarsh
** @date : 05/03/16 //I-214657
** @description : Populate order xcode to license for ecomm orders
** @returns : nothing
*/
    public void Ecommxcode(List<LicenseID__c> pLicenseIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Ecommxcode');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<Id> setIds = new set<Id>();
            set<Id> setOLI = new Set<Id>();
            for(LicenseID__c lid : pLicenseIds){
              setIds.add(lid.OrderLineItem__c);
            }

        
          for(Order_Line_Item__c oli : [Select  Order__c from Order_Line_Item__c Where ID IN :setIds]){
            setOLI.add(oli.Order__c);
          }
        List<Order__c> ordList = [Select Xcode__c from Order__c where ID IN: setOLI];
        for(LicenseID__c lid1 : pLicenseIds){
              for(Order__c  ord: ordList){
                lid1.Xcode__c = ord.Xcode__c;
              }
            }
        }
            catch(Exception e){
                ExceptionLog.add('Exception', 'LicenseTriggerHelper', 'Ecommxcode', e.getMessage());
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate xcode for the LicenseID.' ,e);
            }
        
    }

/*
** @author : Adarsh
** @date : 07/11/16 //I-221991
** @description : Checking for existing LicenseID and if present inserting the existing License Id.
** @returns : nothing
*/
    public void CheckLicId(List<LicenseID__c> pLicenseIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CheckLicId');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> SetLicId = new set<String>();
           // set<String> LicenseName = new set<String>();
            for(LicenseID__c lid : pLicenseIds){
                SetLicId.add(lid.SiteLicenseID__c);
                //LicenseName.add(lid.Name);
               }
            List<LicenseID__c> LicList = [Select Id,Name from LicenseID__c Where SiteLicenseID__c IN :SetLicId];
            system.debug('LicList' + LicList);
            for(LicenseID__c lic : LicList){
                system.debug('lic' + lic);
                for(LicenseID__c lid1 : pLicenseIds){
                   system.debug('lid1' + lid1); 
                   system.debug('LicId' + lic.Id); 
                  LicenseID__c licord = new LicenseID__c();
                    licord.Id = lic.Id;
                   //lid1.Name = lic.Name;
                   system.debug('Licord.Id' + licord.Id);
                   }
            }
        }
            catch(Exception e){
                ExceptionLog.add('Exception', 'LicenseTriggerHelper', 'CheckLicId', e.getMessage());
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate LicenseID ' ,e);
            }
        
    }

/*
** @author : Adarsh
** @date : 08/14/16 //I-221617
** @description : Ensure Incomplete Orders inserted by MAPP process are not picked up by ICS
** @returns : nothing
*/
    public void SetIntegrationStatus(List<LicenseID__c> pLicenseIds){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetIntegrationStatus');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            set<String> OrderNumber = new set<String>();
            set<Id> OrderId = new Set<Id>();
            set<Id> OliId = new Set<Id>();
            String Organization;
            List<Order__c> UpdateordList = new List<Order__c>();
            for(LicenseID__c lid : pLicenseIds){
                OrderNumber.add(lid.Order__c);
                system.debug('OrderNumber' +OrderNumber);
            }
            
            List<Order__c> OrdList = [Select Id,ICS_OrderStatus__c,OrderStatus__c,IntegrationStatus__c,Organization__c from Order__C where Name IN:OrderNumber ];
            //List<Order__c> OrdList = [Select Id from Order__C where Name IN:OrderNumber ];
            for(Order__c  Ord : OrdList)
            {
                OrderId.add(Ord.Id);
                system.debug('OrderId' +OrderId);
                Organization = Ord.Organization__c;
            }
            List<Order_Line_Item__c> OliList = [Select ID from Order_Line_Item__c Where Order__c IN :OrderId];
            for(Order_Line_Item__c oli:OliList ){
                OliId .add(oli.Id);
                system.debug('OliId' +OliId);
            }
            Integer LicCount = [Select Count() from LicenseID__c Where OrderLineItem__c NOT IN :OliId AND Order__c IN:OrderNumber];
            system.debug('LicCount' + LicCount);
            if(LicCount == 0)
            {
                system.debug('debugIntegrationStatus');
                for (Order__c Neword: OrdList){
                    system.debug('ICSOrderStatus' + Neword.ICS_OrderStatus__c);
                    system.debug('OrderStatus previous' + Neword.OrderStatus__c);
                    if(Organization == 'Europe' && UserInfo.getName() == 'Integration MAPP'){//S-484487 AP 05/16
                        Neword.OrderStatus__c = 'Sent to Verification';
                        system.debug('New orderstatus EU' + Neword.OrderStatus__c);
                    }
                    else{
                        if(Neword.ICS_OrderStatus__c!= null){
                           Neword.OrderStatus__c = Neword.ICS_OrderStatus__c;//S-445901
                            //Neword.OrderStatus__c = 'Verified';
                            system.debug('OrderStatus after' + Neword.OrderStatus__c);
                        }
                    }
                    system.debug('New orderstatus EU2' + Neword.OrderStatus__c);
                    Neword.IntegrationStatus__c = 'Not Processed';
                    UpdateordList.add(Neword);
                    system.debug('NotProcessedUpdateordList' + UpdateordList);    
                }
                update UpdateordList;   
               
            }
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'LicenseTriggerHelper', 'SetIntegrationStatus', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to Set IntegrationStatus ' ,e);
        }   
    }
}