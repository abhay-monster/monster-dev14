virtual public with sharing class OrderCloner {
    protected Map<String, Map<String, Schema.SObjectField>> sObjectAndFields;
    protected Id OrderId;
    protected Order__c ParentOrder;
    protected Order__c ClonedOrder;
    protected list<Order_Line_Item__c> ParentOrderLineItemlist;
    protected list<Line_Item_Attribute__c> ParentOrderLineAttributeItemlist;
    protected String ClonedOrderRecordTypeName;
    protected set<Id> OrderLineItemIdSet;
    protected String LineItemWhereClause;
    protected RecordType ClonedOrderRecordType;
    private Boolean changeStatus = false;
    public Boolean showBackButton {get; set;}
    protected Boolean RenderCloneInEditMode = false;
    public String ChangeTypeLabel {get; set;}
    
/**
* @description The Constructor
* @author Cloudsherpas
* @date 5-07-2014
*/         
    public OrderCloner(){
        
    }
/**
* @description The method to clone an order using the parent order's ID
* @author Cloudsherpas
* @date 5-07-2014
* @param Id of parent order
* @param String name of the cloned order
* @returns none
*/     
    @TestVisible protected void init(Id pOrderId, String pClonedOrderRecordType){
        ClonedOrderRecordTypeName = pClonedOrderRecordType;
        OrderId = pOrderId;
        getAllFields();
        getOrder();
        if(ParentOrder != null){
            LineItemWhereClause = ' Order__c = :OrderId';
            getLineItem();
        }
    }
    
/**
* @description The method to clone an order using selected Order Line Items' ID(s)
* @author Cloudsherpas
* @date 5-07-2014
* @param Id set of parent order's line item
* @param String name of the cloned order
* @returns none
*/     
    protected void init(Set<Id> pOrderLineItemIdSet, String pClonedOrderRecordType){
        changeStatus = true;
        ClonedOrderRecordTypeName = pClonedOrderRecordType;
        OrderLineItemIdSet = pOrderLineItemIdSet;
        getAllFields();
        LineItemWhereClause = ' Id IN :OrderLineItemIdSet';
        getLineItem();
        if(ParentOrderLineItemlist.size() > 0){
            OrderId = ParentOrderLineItemlist[0].Order__c;
            getOrder();
        }
    }
    
/**
* @description Gets all field detail of Order, Order Line Item, and Line Item Attribute
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/     
    private void getAllFields(){
        showBackButton = false;
        Utility util = new Utility();
        sObjectAndFields = util.getAllSObjectFieldsBySObjectName(new Set<String>{
            'Order_Line_Item__c',
            'Line_Item_Attribute__c',
            'Order__c'
        });
    }
    
/**
* @description Get Parent Order Record
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/         
    private void getOrder(){
        Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Order__c');
        
        String orderQuery = 'SELECT ';
        for(String sourceAPI : orderFields.keySet()){
            orderQuery += sourceAPI+',';
        }
        
        orderQuery = orderQuery.removeEnd(',');
        orderQuery += ' FROM Order__c WHERE Id = :OrderId';
        
        try{
            ParentOrder = Database.query(orderQuery);
            if(ParentOrder == null){
                addError('No parent order to process.');
            }
        }catch(Exception e){
            addError('Failed to get parent order. Error: '+e);
        }
    }
/**
* @description Get all Order line items
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/     
    private void getLineItem(){
        Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Order_Line_Item__c');
        
        String orderLineItemQuery = 'SELECT ';
        for(String sourceAPI : orderFields.keySet()){
            orderLineItemQuery += sourceAPI+',';
        }
        
        orderLineItemQuery += getLineItemAttributeQuery();
        orderLineItemQuery += ' FROM Order_Line_Item__c WHERE ' + LineItemWhereClause;
        
        try{
            ParentOrderLineItemlist = Database.query(orderLineItemQuery);
        }catch(Exception e){
            addError('Failed to get parent order line items. Error: '+e);
        }
    }
/**
* @description Assemble line item attribute query
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns none
*/     
    private String getLineItemAttributeQuery(){
        Map<String, Schema.SObjectField> orderFields = sObjectAndFields.get('Line_Item_Attribute__c');
        String orderLineItemQuery = '(SELECT ';
        for(String sourceAPI : orderFields.keySet()){
            orderLineItemQuery += sourceAPI+',';
        }
        
        orderLineItemQuery = orderLineItemQuery.removeEnd(',');
        orderLineItemQuery += ' FROM Line_Item_Attributes__r)';
        return orderLineItemQuery;
    }
/**
* @description Override method to handle every unique processes before cloning
* @author Cloudsherpas
* @date 5-08-2014
* @param none
* @returns none
*/     
    virtual protected void handleUniqueProcessBefore(){
        //override this to child classes to handle child class unique processes
    }
/**
* @description Override method to handle every unique processes after cloning
* @author Cloudsherpas
* @date 5-08-2014
* @param none
* @returns none
*/     
    virtual protected void handleUniqueProcessAfter(){
        //override this to child classes to handle child class unique processes
    }
/**
* @description helper to add error message in the page
* @author Cloudsherpas
* @date 4-30-2014
* @param String message that will be showd in the page
* @returns none
*/     
    protected void addError(String msg){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
        showBackButton = OrderId == null ? false : true;
    }
/**
* @description Action method of Back button that will redirect the user back to the parent order detail page
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns Page reference to the parent order's detail page
*/     
    public PageReference backToParentOrder(){
        return new PageReference('/'+OrderId);
    }
    String statusChange2;
    public PageReference saveOrder(String statusChange){
            statusChange2 = statusChange;
           return  cloneOrder();
            //return null;
    
    }
    
/**
* @description This method is the action method of the page element. In here the cloning will occur
* @author Cloudsherpas
* @date 4-30-2014
* @param none
* @returns Returns null when there's an error or there's no parent order. Returns the page reference of the clone order detail page
*/     
    public PageReference cloneOrder(){
        if(ParentOrder == null){
            addError('Cloning initialization failed.');
            return null;
        }
        try{
            //handleUniqueProcessBefore();
            system.debug('==ClonedOrderRecordTypeName=='+ClonedOrderRecordTypeName);
            ClonedOrderRecordType = [SELECT Id FROM RecordType WHERE Name = :ClonedOrderRecordTypeName AND SobjectType = 'Order__c'];
            ClonedOrder = ParentOrder.clone(false, true);
             system.debug('==ClonedOrder=='+ClonedOrder);
            ClonedOrder.RecordTypeId = ClonedOrderRecordType.Id;
            ClonedOrder.ParentOrder__c = ParentOrder.Id;
            ClonedOrder.Change_Type__c = statusChange2 ;
            if(statusChange2 == null){
                return null;
            }
            System.debug('Check ****************' + ChangeTypeLabel);
            if(changeStatus == true){
                clonedOrder.OrderStatus__c = 'Open';
            }
           
            handleUniqueProcessBefore();
            insert ClonedOrder;
            
            list<Order_Line_Item__c> ParentOrderLineItemClonedlist = new list<Order_Line_Item__c>();
                        
            Map<Id, Order_Line_Item__c> parentLineItemIdToClonedLI = new Map<Id, Order_Line_Item__c>();
            
            ParentOrderLineAttributeItemlist = new list<Line_Item_Attribute__c>();
            
            map<Id,list<Line_Item_Attribute__c>> oliIdToAttribute = new map<Id,list<Line_Item_Attribute__c>>();
            
            for(Order_Line_Item__c oli : ParentOrderLineItemlist){
                Order_Line_Item__c clonedOLI = oli.clone(false, true);
                clonedOLI.Order__c = ClonedOrder.Id;
                clonedOLI.BillingInArrears__c = true;
                clonedOLI.OriginalLineItem__c = oli.Id;
                parentLineItemIdToClonedLI.put(oli.Id, clonedOLI);
                
                if(oli.Line_Item_Attributes__r != null){
                    oliIdToAttribute.put(oli.Id, oli.Line_Item_Attributes__r);
                }
            }
            
            insert parentLineItemIdToClonedLI.values();
            
            list<Line_Item_Attribute__c> cloneAttributes = new list<Line_Item_Attribute__c>();
            
            for(Id parentOliId : oliIdToAttribute.keySet()){
                for(Line_Item_Attribute__c attr : oliIdToAttribute.get(parentOliId)){
                    Line_Item_Attribute__c clonedAttr = attr.clone(false, true);
                    if(parentLineItemIdToClonedLI.containsKey(parentOliId)){
                        clonedAttr.Order_Line_Item__c = parentLineItemIdToClonedLI.get(parentOliId).Id;                 
                        cloneAttributes.add(clonedAttr);
                    }
                }
            }
            
            insert cloneAttributes;
            
            handleUniqueProcessAfter();
            String redirectURL = '/'+ClonedOrder.Id;
            
            redirectURL += RenderCloneInEditMode ? '/e?retURL=/' + redirectURL : '';
            
            return new PageReference(redirectURL);
            
            }catch(DMLException dmlE){
            addError('Failed to create cloned order.');
            for(Integer i = 0; i < dmlE.getNumDml(); i++){
                addError('Error: ' + dmlE.getDmlMessage(i));
            }
            system.debug('\n\nOrder Cloning Error: '+dmlE+'\n'+dmlE.getStackTraceString()+'\n\n');
            return null;
        }catch(Exception e){
            addError('Failed to create cloned order. A problem has occurred & processing cannot complete successfully - please see system log for details.');
            system.debug('\n\nOrder Cloning Error: '+e+'\n'+e.getStackTraceString()+'\n\n');
            return null;
        }
    } 
}