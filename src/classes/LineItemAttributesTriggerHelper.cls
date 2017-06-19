/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description :   class that supports the '*TriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class LineItemAttributesTriggerHelper
{

    final String CLASSNAME = '\n\n**** LineItemAttributesTriggerHelper.METHODNAME()';

    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}
    private Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;

/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the LineItemAttributesTriggerHelper class
*/
    /*public static LineItemAttributesTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        LineItemAttributesTriggerHelper newHelper = new LineItemAttributesTriggerHelper(pUserProfileName);
        return newHelper;
    }*/

/*
** @author : Cloud Sherpas Inc.
** @date : 06/18/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the LineItemAttributesTriggerHelper class
*/
    public static LineItemAttributesTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        LineItemAttributesTriggerHelper newHelper = new LineItemAttributesTriggerHelper('');
        return newHelper;
    }

    /*
    ** @author : Cloud Sherpas, Inc.
    ** @date : 06/18/2014
    ** @description : this method is the class constructor
    ** @paramaters : none
    ** @returns : nothing
    */
    private LineItemAttributesTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','LineItemAttributesTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }


    /*
    @author : CloudSherpas
    @description :  Will call the updateRequest method
    @date : 06/10/2014
    @param : creditRequest
    @return : nothing
    */
    public void afterCreate(List<Line_Item_Attribute__c> lineItemAttribute){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','afterCreate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        updateOrderLineItem(lineItemAttribute);

        /*I-159896 JFreese Appirio 9/30/16 - Set this up and now not needed, retain in case wanted in the future
        if(UserInfo.getName() == 'Integration MAPP'){
            processChildCases(lineItemAttribute);
        }*/
    }

    /**
    * @description Gets all field detail of Opportunity
    * @author Cloudsherpas
    * @date 06/18/2014
    * @param none
    * @returns none
    */
    private void updateOrderLineItem(List<Line_Item_Attribute__c> lineItemAttribute){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateOrderLineItem');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        map<Id, Order_Line_Item__c> orderLineMap = new map<Id, Order_Line_Item__c>();

        set<Id> OrderLineSet = new set<Id>();

        for(Line_Item_Attribute__c line : lineItemAttribute){
            OrderLineSet.add(line.Order_Line_Item__c);
        }
        map<Id,Order_Line_Item__c> oli = new map<Id,Order_Line_Item__c>([SELECT Id,PostingLocation__c FROM Order_Line_Item__c WHERE id in : OrderLineSet]);
        for(Line_Item_Attribute__c lineItemAtt : lineItemAttribute){
            if(oli.containsKey(lineItemAtt.Order_Line_Item__c)){
                Order_Line_Item__c orderLineItemToUpdate = oli.get(lineItemAtt.Order_Line_Item__c);
                orderLineItemToUpdate.PostingLocation__c = lineItemAtt.Posting_Locations__c;
                system.debug('line item attr posting location ' + lineItemAtt.Country__c);
                system.debug('oli posting location ' + orderLineItemToUpdate.PostingLocation__c);
                 if(!orderLineMap.containsKey(orderLineItemToUpdate.Id)){
                    orderLineMap.put(orderLineItemToUpdate.Id, orderLineItemToUpdate);
                }
            }
        }
        try{
            if(orderLineMap.size() > 0){
                update orderLineMap.values();
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Failed to update. Please see system log for details.', e);
            ExceptionLog.add('', 'LineItemAttributesTriggerHelper', 'updateOrderLineItem', e.getMessage());

        }
    }


/*
** @author : Appirio (Jonathan F)
** @date : 04/03/16
** @description : Make changes to incoming Order Line Item Attribute records for Ecomm orders
** @returns : nothing
*/
    public void fixEcomm(List<Line_Item_Attribute__c> lineItemAttribute){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','fixEcomm');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        String fixed = '';
		String setordIds; //S-461406 Adarsh 1/18/17
        try{
            set<Id> setIds = new set<Id>();
            for(Line_Item_Attribute__c lia : lineItemAttribute){
              setIds.add(lia.Order_Line_Item__c);
            }

            //Map of direct fields: {'sourceField' => 'destField'} - if destField != sourceField, copy sourceField to destField
            map<String, String> directFields = new map<String, String>();

            String relatedObject = 'order__r';
            //Map of related fields: {'sourceField' => 'destField'} - if destField != relatedObject.sourceField, copy relatedObject.sourceField to destField
            map<String, String> relatedFields = new map<String, String>{'Quote_Selling_Country__c' => 'Country__c'};

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
                setordIds = oli.Order__c; //S-461406 Adarsh 1/18/17
            }

            for(Line_Item_Attribute__c dest : lineItemAttribute){
                fixed = '';
                if (mapSrc != null && mapSrc.containskey(dest.Order_Line_Item__c)){
                    //process the direct references
                    for(String sourceField : directFields.keySet()){
                        String destField = directFields.get(sourceField);
                        if (dest.get(destField) != mapSrc.get(dest.Order_Line_Item__c).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Order_Line_Item__c).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }

                    //process the related object references
                    for(String sourceField : relatedFields.keySet()){
                        String destField = relatedFields.get(sourceField);
                        SObject relObject = mapSrc.get(dest.Order_Line_Item__c).getSobject(relatedObject);
                        if (relObject != null && dest.get(destField) != mapSrc.get(dest.Order_Line_Item__c).getSobject(relatedObject).get(sourceField)){
                            dest.put(destField, mapSrc.get(dest.Order_Line_Item__c).getSobject(relatedObject).get(sourceField));
                            fixed += ' ' + destField;
                        }
                    }
                }
                if (fixed != ''){
                    system.debug('^^^ Updated MAPP Line_Item_Attribute__c  (fixed ' + fixed + '): ' + dest);
                }
            }
            //S-461406 Adarsh 1/18/17
            List<Order__c> OrderToBeUpdated = new List<Order__c>();
			Order__c ord = new Order__c();
            ord.Id = setordIds;
            ord.MAPP_Insert_Complete__c = true;
			OrderToBeUpdated.add(ord);
			update OrderToBeUpdated;
        }
        catch(Exception e){
            ExceptionLog.add('Exception', 'LineItemAttributesTriggerHelper', 'fixEcomm', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to fix key field(s) on Line_Item_Attribute__c.' ,e);
        }
    }

/*
** @author : Appirio (Jonathan F)
** @date : 09/22/16
** @description : Create a child case if appropriate for the Ecomm Order Line Item
** @returns : nothing
*/
/*    public void processChildCases(List<Line_Item_Attribute__c> lineItemAttribute){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','processChildCases');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        /*The following code was copied and modified from OrderTriggerHelper.processCases(),
          where the child case section is disabled for the Integration MAPP user*//*

        Map<String, Map<String, Id>> OrderAndCaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Order__c', 'Case'});
        Id caseProductImplementationRecordTypeId = OrderAndCaseRecordTypes.get('Case').get('Product Implementation');
        Map<Id,Case> ordertoCaseMap = new Map<Id,Case>();
        List<Case> childCaseToInsert = new List<Case>();
        Set<Id> newOrder = new Set<Id>();
        List<Line_Item_Attribute__c> lias = new List<Line_Item_Attribute__c>();

        for(Line_Item_Attribute__c lia : [
            SELECT Id, Name, Order_Line_Item__c, Order_Line_Item__r.LineType__c, Order_Line_Item__r.prod_code__c,
                   Order_Line_Item__r.Order__c, Order_Line_Item__r.Order__r.Account__c,
                   Order_Line_Item__r.Product_Name_for_Case__c, Order_Line_Item__r.Quantity2__c,
                   Order_Line_Item__r.Order__r.Name
                FROM Line_Item_Attribute__c WHERE Id IN :lineItemAttribute]){

            lias.add(lia);
            newOrder.add(lia.Order_Line_Item__r.Order__c);
        }

        for(Case c : [Select Order__c,Id,AccountId from Case Where Order__c IN :newOrder]){
            ordertoCaseMap.put(c.Order__c,c);
        }

        system.debug('childcases run1');
        for(Line_Item_Attribute__c lia : lias){
            system.debug('lia.Order_Line_Item__r.LineType__c ' + lia.Order_Line_Item__r.LineType__c);
            system.debug('lia.Order_Line_Item__r.prod_code__c '+lia.Order_Line_Item__r.prod_code__c);
            if(lia.Order_Line_Item__r.LineType__c != null &&
               lia.Order_Line_Item__r.LineType__c.equalsIgnoreCase ('Product/Service') &&
               lia.Order_Line_Item__r.prod_code__c.equalsIgnoreCase('QUOTE BUNDLE')){
                /*This will "probably" never happen because MAPP does not send bundle headers, but
                  leave it in just in case...*//*
                continue;
            }
            else{
                system.debug('childcases run2');
                Case newCase = new Case();
                newCase.SystemGenerated__c = True;
                newCase.Order__c = lia.Order_Line_Item__r.Order__c;


                Case parentCase = ordertoCaseMap.get(lia.Order_Line_Item__r.Order__c);
                if(parentCase != null){
                    newCase.ParentId = parentCase.Id;
                }

                newCase.OrderLineItem__c = lia.Order_Line_Item__c;
                newCase.RecordTypeId = caseProductImplementationRecordTypeId;
                newCase.AccountId = lia.Order_Line_Item__r.Order__r.Account__c;
                /*String account = '';
                if(firstOli.Order__r.Account__c != null){
                    account = firstOli.Order__r.Account__c;
                }*//*
                system.debug('lia.Order_Line_Item__r.Product_Name_for_Case__c = ' + lia.Order_Line_Item__r.Product_Name_for_Case__c);
                newCase.Subject = lia.Order_Line_Item__r.Product_Name_for_Case__c + ' - ' + 'Qty: ' + lia.Order_Line_Item__r.Quantity2__c + ' - ' + lia.Order_Line_Item__r.Order__r.Name;
                system.debug('newCase.Subject = '+newCase.Subject);
                newCase.Sub_Type__c = 'Line Item Fulfillment';
               // newCase.setOptions(dmlOpts);
                childCaseToInsert.add(newCase);
                system.debug('childCaseToInsert~~~ '+childCaseToInsert);
            }
        }

        if(!childCaseToInsert.isEmpty()){
            insert childCaseToInsert;
            system.debug('childCaseToInsert~~~AFTER '+childCaseToInsert);
            system.debug('Inserting a new Implementation record [child] !!!');
            //avoidRecurssion = false;
        }
    }
*/

 /*
** @author : Adarsh
** @date : 04/24/2016
** @story :
** @Issue : I-198905/I-211033
** @description : Populate RefreshInterval with default 0 whenever Hasautorefresh is 0 for salesforce Monster Standard Job Slot product on LineItemAttribute
** @paramaters : list of Orders
** @returns : nothing
*/
   /* public void PopulateRefreshInterval(List<Line_Item_Attribute__c> lineItemsAtt){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','PopulateRefreshInterval');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
         String Hasautorefresh;
		 String Orderlineitemid;
		 String Prodcode;
         List<Line_Item_Attribute__c> updrefresh = new List<Line_Item_Attribute__c>();
         try{
			system.debug('lia' + lineItemsAtt);
            for(Line_Item_Attribute__c lia : lineItemsAtt){
                Hasautorefresh = lia.Has_Auto_Refresh__c;
                system.debug('Hasautorefresh' + Hasautorefresh);
				Orderlineitemid = lia.Order_Line_Item__c;
                system.debug('Orderlineitemid' + Orderlineitemid);
            }
            List<Order_Line_Item__c> orderLinelist = [select Id, prod_code__c from Order_Line_Item__c  where Id =: Orderlineitemid];
			system.debug('orderLinelist' + orderLinelist);
             for(Order_Line_Item__c oli: orderLinelist){
                Prodcode = oli.prod_code__c;
                 system.debug('Prodcode' + Prodcode);
			}
			if (Prodcode == 'M11690X12M' && Hasautorefresh == 'No' ){
				for(Line_Item_Attribute__c updatelia  : lineItemsAtt){
					updatelia.Refresh_Interval__c = '0';
                    //updrefresh.add(updatelia);
                    system.debug('inside');
                    system.debug('updatelia.Refresh_Interval__c' + updatelia.Refresh_Interval__c );
                    system.debug('updatelia' + updatelia );
				}
                //update updrefresh;
			}

        }
         catch(Exception e){
            system.debug('errored');
            ExceptionLog.add('Exception', 'LineItemAttributesTriggerHelper', 'PopulateRefreshInterval', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to populate RefreshInterval for Monster Standard Job Slot.' ,e);
        }
	}*/


}