/*
Updated Date: 08/31/2015
updated  for debug: 09/10 Venkata Sabbella 
updated: Comment Unused methods 09/13
Updated: Issue on  GoToPricing - 17/11
*/


public with sharing class GoToPricingCustomController {
    
    Class RuleException Extends Exception{ 
        
        
    }
    private ID tempID;
    private ID configID;
    private Map<ID,Apttus_Config2__LineItem__c> liIDliSOMap = new Map<ID,Apttus_Config2__LineItem__c>();
    private ID quoteID;
    private ID accountID;
    private List<Apttus_Config2__AccountLocation__c> accLocSOList = new List<Apttus_Config2__AccountLocation__c>();
    private string prodCatalogPage = null;
    private string cartPage = null;
    private string location = null;
    private List<Apttus_Config2__LineItem__c> updateLISOList = new List<Apttus_Config2__LineItem__c>();
    private List<Decimal> newLineItemIDList = new List<Decimal>();  
    
    private List<Id> OptionIds=new list<Id>();
    private Apttus_Proposal__Proposal__c proposal;
    //private map<Id,list<Id>> OptionListIdByBundleId=new  map<Id,list<Id>>();
    map<Id,List<string>> optionFieldsByProductId;
    Map<id,id> LineItemToPAVIdMAP = new MAP<id,id>();           ///Change 26/10
    
    map<Decimal,Id> BundleLineItemsIdsByLineNumber=new map<Decimal,Id>();
    map<Decimal,List<Id>> OptionLineItemsIdsByLineNumber=new map<Decimal,List<Id>>();
    map<Id,Apttus_Config2__LineItem__c> lineItemById=new  map<Id,Apttus_Config2__LineItem__c>();
    
    /*
create a map bundle and list option product ids
*/
    
    public List<Apttus_Config2__LineItem__c> liSOList {get; private set;}
    public Decimal numNoLocationLines{get; private set;}
    //map<Id,productRuleHelper.productRuleInfo> ruleHeapByProductId=productRuleHelper.QueryPardRulesByOptions(new List<Id>{'01tq0000000dpUB','01tq0000000dpUA'},'01tq0000000dpRf');
    map<Id,productRuleHelper.productRuleInfo> ruleHeapByProductId;
    // =productRuleHelper.QueryPardRulesByOptions(new List<Id>{'01tq0000000dpUA'},'01tq0000000dpRf');
    
    
    public GoToPricingCustomController() { 
        /*
The custom button in the shopping cart page will have configRequestID and the id parameters.
id - The Cart ID (Product Configuration Object), configRequestId - Temp object (System created)
The 2 fields will be used to reroute control to the shopping cart page.
*/
        try{
            System.debug('Constructor:Start');
            tempID = ApexPages.currentPage().getParameters().get('configRequestId'); 
            configID = ApexPages.currentPage().getParameters().get('id');
            System.debug('Constructor:Start'+configID);
            numNoLocationLines = 0;
            getProductConfigFields();
            getProductCatalogPage();
            
            //System.assert(configID==null,'configId is null');
            //System.assert(tempID==null,'Tempid is null');
            //System.assert(quoteID==null,'QuoteId is null'); 
            //I-160245  - addded Pricing_Channel__c in query
            proposal=[select id,name,Apttus_QPConfig__PriceListId__c,Apttus_QPConfig__PriceListId__r.name,
                      Selling_Country__c,Pricing_Channel_Account__c,Pricing_Channel__c
                      from Apttus_Proposal__Proposal__c
                      where id=:quoteID];
            getLineItems();
            
            System.debug('Constructor:BundleLineItemsIdsByLineNumber map size'+BundleLineItemsIdsByLineNumber.size());
            
            
            list<Id> optionProductsId=new list<Id>();
            set<Id> optionGroupIdset=new set<Id>();
            Id BundleProductId;
            for(Decimal i:BundleLineItemsIdsByLineNumber.keyset())
            {
                Id BundleLineItemId= BundleLineItemsIdsByLineNumber.get(i);
                List<Id> OptionLineItemIdList=OptionLineItemsIdsByLineNumber.get(i);
                SYstem.debug('OptionLineItemIdList'+OptionLineItemIdList);
                //I-160245 - When user try to click add more product multilpe time and come back issue occurs
                
                If(OptionLineItemIdList != null )
                {
                    for(Id oLineItemId:OptionLineItemIdList){
                        optionProductsId.add(lineItemById.get(oLineItemId).Apttus_Config2__OptionId__c);
                        optionGroupIdset.add(lineItemById.get(oLineItemId).Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c);
                        
                    }
                    
                    BundleProductId=lineItemById.get(BundleLineItemId).Apttus_Config2__ProductId__c;
                    
                    // maxing out the view state. Rather do this in the loop and implement remoting. Commenting 0813
                    //ruleHeapByProductId=productRuleHelper.QueryPardRulesByOptions(optionProductsId,optionGroupIdset); 
                    
                    optionFieldsByProductId=getFieldsByProductId(optionProductsId);
                    
                    break;
                }
            }
            System.debug('Constructor:End');
            
        }
        catch(Exception Ex)
        {
            System.debug('Error:1. Please check default options for product: '+Ex.getMessage()+ Ex.getLineNumber());
            
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'Error while fetching the proudct default attributes: '+Ex.getMessage()+': Line:' +Ex.getLineNumber()));  
            Throw new RuleException('Error:1. Please check default options for product: '+Ex.getMessage()+ Ex.getLineNumber());    
        }
        
    }
    private void getProductConfigFields() {
        List<Apttus_Config2__ProductConfiguration__c> prodConfigSOList = [select id, Apttus_QPConfig__Proposald__c,Apttus_Config2__AccountId__c  from Apttus_Config2__ProductConfiguration__c where id = :configID limit 1];
        if(prodConfigSOList != null && !prodConfigSOList.isEmpty()) {
            quoteID = prodConfigSOList[0].Apttus_QPConfig__Proposald__c;
            accountID = prodConfigSOList[0].Apttus_Config2__AccountId__c;
        }
    }
    private void getProductCatalogPage() {
        Apttus_Config2__ConfigSystemProperties__c configSysProperties = Apttus_Config2__ConfigSystemProperties__c.getInstance('System Properties');
        if(configSysProperties != null) {
            prodCatalogPage = configSysProperties.Apttus_Config2__DefaultProductsPage__c;
            cartPage = configSysProperties.Apttus_Config2__ViewCartPage__c;
        }
    }
    
    public PageReference doCancel() {
        PageReference pageRef = null;
        if(prodCatalogPage != null) {
            pageRef = new PageReference('/apex/'+ prodCatalogPage+'?id=' + configID + '&configRequestId=' + tempID);
            pageRef.setRedirect(true);
        }
        return pageRef; 
    }
    
    public PageReference doGoToPricing() {
        
        
        
        PageReference pageRef =  new PageReference('/apex/Apttus_Config2__Pricing?id=' + configID + '&configRequestId=' + tempID);
        //update updateLISOList;
        
        /* List<String> errorMessageList;
if(errorMessageList != null && errorMessageList.size() > 0) {
for(String errorMessage : errorMessageList) {
ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,errorMessage);
ApexPages.AddMessage(msg);
}
pageRef = null;
}
else {
if(newLineItemIDList != null && !newLineItemIDList.isEmpty()) {
pageRef = new PageReference('/apex/Apttus_Config2__Pricing?id=' + configID + '&configRequestId=' + tempID);
}
else {
pageRef = new PageReference('/apex/' + cartPage + '?id=' + configID + '&configRequestId=' + tempID);
}
pageRef.setRedirect(true);
}*/
        
        
        return pageRef;
    }
    
    /*private List<String> validateConstraints() {
List<String> errorMessageList = new List<String>();
Decimal numErrors = 0;
List<Integer> primaryLines = new List<Integer>();
Apttus_CPQApi.CPQWebService.associateConstraintRules(configID,primaryLines);
Apttus_CPQApi.CPQWebService.applyConstraintRules(configID, true);

Apttus_CPQApi.CPQ.ConstraintResultDO constRuleResultDO = Apttus_CPQApi.CPQWebService.getConstraintRuleResult(configID);
List<Apttus_CPQApi.CPQ.AppliedActionDO> appliedActionDOList = constRuleResultDO.ConstraintRuleActions;
for(Apttus_CPQApi.CPQ.AppliedActionDO appliedActDO:appliedActionDOList) {
if(appliedActDO.MessageType.equals('Error') && appliedActDO.IsPending) {
numErrors++;
errorMessageList.add(appliedActDO.Message);
}
}
return errorMessageList;
}*/
    
    
    
    
    public PageReference processLines()
    {
        // return null;
        PageReference pref;
        try{
            pref=doGoToPricing();
            
            //System.debug('');
            System.debug('ProcessLines: Start');  
            List<Apttus_Config2__ProductAttributeValue__c> prodAttValList=new List<Apttus_Config2__ProductAttributeValue__c>();
            List<Apttus_config2__lineItem__c> lineItemList=new List<Apttus_config2__lineItem__c>();
            System.debug('LineItemToPAVIdMAP  :'+LineItemToPAVIdMAP);
           
            //Issue on  GoToPricing - 17/11
            If(optionFieldsByProductId == NULL)
            {
                return pref;
            }
            
            MAP<id,Apttus_Config2__ProductAttributeValue__c>   PAVMAP  = getAllPAVMAP(optionFieldsByProductId , LineItemToPAVIdMAP.values());		///Change 26/10
            for(Decimal d:OptionLineItemsIdsByLineNumber.keyset())
            {
                List<Id> optionLineItemIds=OptionLineItemsIdsByLineNumber.get(d);
                for(Id oLineItemId:optionLineItemIds)
                {
                    System.debug('ProcessLines: For Loop:LineItem id: '+oLineItemId);  
                    
                    Apttus_config2__lineItem__c oLineItem= lineItemById.get(oLineItemId);
                    lineItemList.add(oLineItem);
                    
                    //adding the heap query here to get rid of the view state limit.
                    ruleHeapByProductId=productRuleHelper.QueryPardRulesByOptions(new list<Id>{oLineItem.Apttus_Config2__OptionId__c},new set<Id>{oLineItem.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c}); 
                    //,);
                    
                    productRuleHelper.productRuleInfo prodRuleInstance=ruleHeapByProductId.get(oLineItem.Apttus_Config2__OptionId__c);
                    System.debug('PAVMAP.get(LineItemToPAVIdMAP.get(oLineItem.id))'+PAVMAP.get(LineItemToPAVIdMAP.get(oLineItem.id))); 
                    ruleProcessor ruleProcessInstance=new ruleProcessor(prodRuleInstance,proposal , PAVMAP.get(LineItemToPAVIdMAP.get(oLineItem.id))); ///Change 26/10
                    system.debug('ProcessLines:productFields'+oLineItem.Apttus_Config2__OptionId__c);
                    system.debug('ProcessLines:productFields'+optionFieldsByProductId.ContainsKey(oLineItem.Apttus_Config2__OptionId__c));
                    
                    list<string> productFields=optionFieldsByProductId.get(oLineItem.Apttus_Config2__OptionId__c);
                    Apttus_Config2__ProductAttributeValue__c prodAttVal= ruleProcessInstance.processRules(productFields,oLineItem.Apttus_Config2__OptionId__r.name);
                    prodAttVal.Apttus_Config2__LineItemId__c=oLineItem.id;
                    prodAttVal.Defaulted_Attributes__c='';
                    for(string fieldAPI:productFields){
                        prodAttVal.Defaulted_Attributes__c+=fieldAPI+'=>'+prodAttVal.get(fieldAPI)+',\r\n';
                    }
                    Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'-->'+prodAttVal.Defaulted_Attributes__c));
                    prodAttValList.add(prodAttVal);
                    
                    //get rid of the heap
                    ruleHeapByProductId=null;
                    prodRuleInstance=null;
                    ruleProcessInstance=null;
                    System.debug('ProcessLines: For Loop End:LineItem id: '+oLineItemId);  
                    
                }
                Id BundleLineItemid=BundleLineItemsIdsByLineNumber.get(d);
                Apttus_config2__lineItem__c blineItem=lineItemById.get(BundleLineItemid);
                lineItemList.add(blineItem);
                break;
            }
            upsert prodAttValList;
            
            for(Apttus_Config2__ProductAttributeValue__c p:prodAttValList)
            {
                Apttus_config2__lineItem__c oLineItem= lineItemById.get(p.Apttus_Config2__LineItemId__c);
                oLineItem.Apttus_Config2__AttributeValueId__c=p.id;
            }
            
            for(Apttus_config2__lineItem__c li:lineItemList)
            {
                li.Attributes_Defaulted__c=true;
                
                
                
                
            }
            update lineItemList;
            //return pref;  
        }
        catch(Exception Ex)
        {
            
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'Error while defaulting the attributes: '+ex.getMessage()+' '+ex.getLineNumber()+ex.getStackTraceString()));      
            return null;
        }
        System.debug('ProcessLines: End '); 
        
        return pref;
        // apexpages.addMessage(new apexpages.Message(apexpages.severity.warning,'RuleHeapByproductId '+ruleHeapByProductId.keyset()));
    }
    
    
    
    
    
    
    
    public list<Apttus_config2__lineItem__c> getLineItems()
    {
        List<Apttus_config2__lineItem__c> lineItemList=[select id,name,
                                                        Apttus_Config2__AttributeValueId__c,Apttus_Config2__OptionId__c,
                                                        Apttus_Config2__PrimaryLineNumber__c,
                                                        Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,
                                                        Apttus_Config2__LineNumber__c,
                                                        Apttus_Config2__OptionId__r.name,
                                                        Apttus_Config2__ProductId__c,
                                                        Apttus_Config2__LineType__c,
                                                        Attributes_Defaulted__c
                                                        from Apttus_config2__lineItem__c                                                     
                                                        where Apttus_Config2__ConfigurationId__c=:configID
                                                        //and Apttus_Config2__LineType__c='Option'
                                                        and Attributes_Defaulted__c=false
                                                        order by Apttus_Config2__LineNumber__c
                                                       ];
        for(Apttus_config2__lineItem__c lineItem: lineItemList) 
        {
            if(lineItem.Apttus_Config2__LineType__c=='Product/Service'){
                
                BundleLineItemsIdsByLineNumber.put(lineItem.Apttus_Config2__LineNumber__c,lineItem.id);
                
            }
            else if(lineItem.Apttus_Config2__LineType__c=='Option')
            {
                if(OptionLineItemsIdsByLineNumber.containsKey(lineItem.Apttus_Config2__LineNumber__c))
                    OptionLineItemsIdsByLineNumber.get(lineItem.Apttus_Config2__LineNumber__c).add(lineitem.id);
                else
                    OptionLineItemsIdsByLineNumber.put(lineItem.Apttus_Config2__LineNumber__c,new list<Id>{lineItem.id});
                
            }
            lineItemById.put(LineItem.Id,LineItem);
            LineItemToPAVIdMAP.put(LineItem.Id,LineItem.Apttus_Config2__AttributeValueId__c);   //Changes 26/10
        }                                          
        //Apexpages.addMessage(new apexpages.message(apexpages.severity.info,'OptionListIdByBundleId:'+OptionListIdByBundleId+':/r/n Line items'+liIDliSOMap));
        
        return lineItemList;
    }  
    
    
    // Happy path to default the attributes. Remove after testing
    /*public Apttus_Config2__ProductAttributeValue__c getProductAttributeValue()
{
Apttus_Config2__ProductAttributeValue__c prodAttVal2=new Apttus_Config2__ProductAttributeValue__c();

//prodAttVal2.put(fieldlist[0],'National');
//prodAttVal2.put(fieldlist[1],'India');
prodAttVal2.put('Geography__c','National');
prodAttVal2.put('Country__c','Canada');
prodAttVal2.put('Search_Method__c','Classic');
prodAttVal2.put('License_Type__c','Master');
prodAttVal2.put('Duration__c','2 Weeks');
prodAttVal2.put('View_Count_Resume__c','500');
prodAttVal2.put('Boards__c','Monster');
prodAttVal2.put('Search_Geography__c','National');
prodAttVal2.put('Program_Name__c','n/a');
prodAttVal2.put('Consultants__c','N/A');
prodAttVal2.put('Location__c','N/A');
prodAttVal2.put('Zip_Code__c','');
return prodAttVal2;
}*/
    
    
    // retrieve the list of productattribute value record fields by productId
    Public static map<Id,List<string>> getFieldsByProductId(list<Id> productIds)
    {
        map<Id,List<string>> productAttributeListByProductId;
        try {
            list<Apttus_Config2__ProductAttribute__c> AttFields = [SELECT Apttus_Config2__Field__c,
                                                                   Apttus_Config2__Sequence__c,
                                                                   Apttus_Config2__AttributeGroupId__c
                                                                   FROM Apttus_Config2__ProductAttribute__c 
                                                                   WHERE Apttus_Config2__AttributeGroupId__c IN 
                                                                   (SELECT Apttus_Config2__AttributeGroupId__c 
                                                                    FROM Apttus_Config2__ProductAttributeGroupMember__c 
                                                                    WHERE Apttus_Config2__ProductId__r.Id IN: productIds) 
                                                                   ORDER BY Apttus_Config2__Sequence__c];
            
            map<Id,list<Apttus_Config2__ProductAttribute__c>> prodAttByGroupid=new map<Id,list<Apttus_Config2__ProductAttribute__c>>();
            

            for(Apttus_Config2__ProductAttribute__c prodAttribute: AttFields)   
            {
                if(prodAttByGroupid.containsKey(prodAttribute.Apttus_Config2__AttributeGroupId__c))
                    prodAttByGroupid.get(prodAttribute.Apttus_Config2__AttributeGroupId__c).add(prodAttribute);
                else
                    prodAttByGroupid.put(prodAttribute.Apttus_Config2__AttributeGroupId__c,new list<Apttus_Config2__ProductAttribute__c>{prodAttribute});


                  
            } 
            
            // Put an error message if the multiple group members are found   
            
            List<product2> productList=[select id,name,
                                        (select id,name,Apttus_Config2__AttributeGroupId__c
                                         from Apttus_Config2__AttributeGroups__r)
                                        from product2 where Id IN:productIds];
            
            //map<Id,Id> AttGroupIdByProductId= new map<Id,Id>();
            productAttributeListByProductId=new map<Id,List<string>>();
            
            for(product2 p: productList)
            {
                Apttus_Config2__ProductAttributeGroupMember__c groupMember=(Apttus_Config2__ProductAttributeGroupMember__c)p.getSObjects('Apttus_Config2__AttributeGroups__r')[0];
                //AttGroupIdByProductId.put(p.Id,groupMember.Apttus_Config2__AttributeGroupId__c);
                list<string> prodAttFieldsList=getAttributeFieldList(prodAttByGroupid.get(groupMember.Apttus_Config2__AttributeGroupId__c));
                productAttributeListByProductId.put(p.id,prodAttFieldsList);
            }                                                                                             
        }
        Catch(Exception e){
            system.debug('EXCEPTION!!! ' + e.getMessage() + ' ' + e.getLineNumber());
        }
        return productAttributeListByProductId;
    }
    
    
    /*

utility method to convert the list<productattributevalue> to list<fields> by taking the field__c field.
*/
    
    public static list<string> getAttributeFieldList(list<Apttus_Config2__ProductAttribute__c> AttFieldList)
    {
        list<string> queryFieldList=new List<string>();
        for(Apttus_Config2__ProductAttribute__c prodAttField:AttFieldList)
        {
            queryFieldList.add(prodAttField.Apttus_Config2__Field__c);
        }
        
        return queryFieldList;
    }    
    
    ///Change 26/10 - added new function
    public MAP<id,Apttus_Config2__ProductAttributeValue__c> getAllPAVMAP(map<Id,List<string>> productAttributeListByProductId , List<id> PAVlineSet)                
    {
            System.debug('PAVlineSet' + PAVlineSet);
        set<string> AttributeAPISet = new set<string>();            	
        for(id tempid  : productAttributeListByProductId.keySet())
        {
            List<string> templist = productAttributeListByProductId.get(tempid) ;
            If(templist != null)
            {
                for(string s : templist)
                {
                    AttributeAPISet.add(s);
                }
            }
        }
            System.debug('AttributeAPISet' + AttributeAPISet);
        list<string> tempstringlist = new list<string>();
        tempstringlist.addAll(AttributeAPISet);
        string squery = 'select id,' +string.join(tempstringlist, ',')+ ' from Apttus_Config2__ProductAttributeValue__c where id = :PAVlineSet';
        MAP<id,Apttus_Config2__ProductAttributeValue__c> PAVMAP = new MAP<id,Apttus_Config2__ProductAttributeValue__c>();
         System.debug('squery' + squery);
        List<Apttus_Config2__ProductAttributeValue__c> tempPAVlist  = database.query(squery);
        
        For(Apttus_Config2__ProductAttributeValue__c oTemp : tempPAVlist)
        {
            PAVMAP.put(oTemp.id , oTemp);
        }
        System.debug('PAVMAP' + PAVMAP);
            
        return PAVMAP;
    }
    
    
    
}