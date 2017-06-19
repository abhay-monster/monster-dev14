/*
  updated: 09/11
  update: 10/05 Option components to be looped through for cascading funcitonality to happen
  update: Snapshot of cascaded attributes needed 10/28
*/
public with sharing class CascadeAttributes {
    
    Id leadingProductId;
    Apttus_Config2__LineItem__c CurrentLineItem;
    List<Apttus_Config2__LineItem__c> bundleLineItems;
    Map<Id,Apttus_Config2__LineItem__c> LineItemByOptionId=new Map<Id,Apttus_Config2__LineItem__c>();
    Map<Id,Apttus_Config2__ProductAttributeValue__c> productAttributeValueList=new Map<Id,Apttus_Config2__ProductAttributeValue__c>();
     Apttus_Config2__ProductAttributeValue__c LeadProductAttributeRecord;
     list<Apttus_Config2__ProductAttributeValue__c> nonLeadOptionAttRecords;
     //set<Id> OptionIdsforBundle=new set<Id>();
     set<Id> optionCompIdforBundle=new set<Id>();
    //map<Id,set<string>> cascadableAttributesByProduct= new map<Id,set<string>>();
    boolean cascadeFlag;
    public CascadeAttributes(Apttus_Config2__ProductAttributeValue__c LeadAttRecord,Apttus_Config2__LineItem__c leadline, boolean flag)
    {
     //if(LeadRecord==null)
    cascadeFlag=flag; 
    // system.assertNotEquals(LeadRecord,null);
    if(!flag)
       return;
     CurrentLineItem=leadline;//leadlineItem
     LeadProductAttributeRecord=LeadAttRecord;
     nonLeadOptionAttRecords=new list<Apttus_Config2__ProductAttributeValue__c>();
     //apexpages.addMessage(new apexpages.message(apexpages.severity.info,''+LeadProductAttributeRecord));
    }
    
    
    
    /*public  void cascade(Id ConfigurationId,Decimal LineNumber,Id BundleId)
    {
     if(!cascadeFlag)
        return;                                         
     
     string linelist='';
     for(Apttus_Config2__LineItem__c lineItem: [Select ID, Apttus_Config2__LineStatus__c,
                                                    Apttus_Config2__BaseProductId__c,
                                                    Apttus_Config2__OptionId__c,
                                             Apttus_Config2__BasePrice__c,
                                             Apttus_Config2__PricingStatus__c,
                                             Apttus_Config2__ProductId__c,
                                             Apttus_Config2__AttributeValueId__c,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                                             Apttus_Config2__ConfigurationId__c,
                                             Apttus_Config2__AssetLineItemId__c,
                                             Apttus_Config2__EndDate__c,
                                             CurrencyIsoCode,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c
                                             FROM Apttus_Config2__LineItem__c
                                             WHERE Apttus_Config2__ConfigurationId__c=:configurationId AND 
                                            Apttus_Config2__LineNumber__c =:LineNumber 
                                            AND Apttus_Config2__LineType__c = 'Option'])
                                            {
                                                
                                                
                                             if(lineItem.Apttus_Config2__OptionId__c.equals(CurrentLineItem.Apttus_Config2__OptionId__c)){
                                                //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'Id compare'+LineItem.Apttus_Config2__OptionId__c+':'+LeadProductAttributeRecord.id));
                                                continue;//Do not update the lead record with its own value
                                             }
                                                
                                             OptionIdsforBundle.add(lineItem.Apttus_Config2__OptionId__c);   
                                            
                                             LineItemByOptionId.put(LineItem.Apttus_Config2__OptionId__c,lineItem);
                                             }
           map<Id,set<string>> AttributesByOptionId=getNonLeadingOptions(OptionIdsforBundle,BundleId); 
           Apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'attrbyOptoinId'+AttributesByOptionId));
           for(Id OptionId:LineItemByOptionId.keyset())
           {
            Apttus_Config2__LineItem__c lineitem=LineItemByOptionId.get(OptionId);
            Apttus_Config2__ProductAttributeValue__c relatedProductAttributeValue=getProductAttributeRecordInstance();
            relatedProductAttributeValue.Id=LineItem.Apttus_Config2__AttributeValueId__c;
            
           
            for(string AttributeAPI:AttributesByOptionId.get(OptionId))
            {
             apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'OptionId:'+OptionId+'-->'+AttributeAPI));
             //relatedProductAttributeValue.put(AttributeAPI,LeadProductAttributeRecord.get(AttributeAPI));
             
            }
            
            //Copy the fields from lead option to non lead options
            
            
            nonLeadOptionAttRecords.add(relatedProductAttributeValue);                                                               
           }
      update nonLeadOptionAttRecords;      
      system.debug('-->'+linelist);                             
                                            
                                            
    }*/
    
    
    
    public void cascadeAttributesFromLeadOption(Id BundleId)
    {
        integer bundleOptionsSize=bundleLineItems.size();
        System.debug('Inside cascadeAttributesFromLeadOption bundleOptionsSize:'+bundleOptionsSize);
        for(integer i=1; i<=bundleOptionsSize-1;i++)
        {
           Apttus_Config2__LineItem__c lineItem=bundleLineItems[i];
           optionCompIdforBundle.add(lineItem.Apttus_Config2__ProductOptionId__c); 
           LineItemByOptionId.put(LineItem.Apttus_Config2__ProductOptionId__c,lineItem);                                            
        }
        
        // This map contains option Id and realted wrapper  that contians attributes that  needs to be casacaded from lead option. 
        map<Id,bunldeOptionInfo> nonLeadingOptions=getBundleOptionInfo(optionCompIdforBundle,BundleId); 
        System.debug('Inside cascadeAttributesFromLeadOption nonLeadingOptions:'+nonLeadingOptions);
        for(Id ProdOptionCompId:LineItemByOptionId.keyset())
        {
            Apttus_Config2__LineItem__c lineitem=LineItemByOptionId.get(ProdOptionCompId);
            Apttus_Config2__ProductAttributeValue__c relatedProductAttributeValue=getProductAttributeRecordInstance();
            System.debug('Inside cascadeAttributesFromLeadOption ProdOptionCompId:'+ProdOptionCompId);
            System.debug('Inside cascadeAttributesFromLeadOption relatedProductAttributeValue:'+relatedProductAttributeValue);
            relatedProductAttributeValue.Id=LineItem.Apttus_Config2__AttributeValueId__c;
            //Apexpages.addMessage(new apexpages.Message(apexpages.severity.warning,'OptionId'+OptionId));
            system.assertNotEquals(ProdOptionCompId,null);
            system.assertNotEquals(nonLeadingOptions.get(ProdOptionCompId).cascadeAttributeAPIs,null);
            
            String snapshot='';
            for(string AttributeAPI: nonLeadingOptions.get(ProdOptionCompId).cascadeAttributeAPIs)
            {
              snapshot= snapshot+''+ AttributeAPI+'='+LeadProductAttributeRecord.get(AttributeAPI)+'##';
              system.debug('Cascading Debug:In the Loop'+snapshot);
             // if the attribute API is not specified in product option component, the an error occurs when the option config. icon is clicked on the bunle options page.
             // Include prevention logic for that error.
             
             relatedProductAttributeValue.put(AttributeAPI,LeadProductAttributeRecord.get(AttributeAPI));
             //Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,AttributeAPI+'-->'+relatedProductAttributeValue.get(AttributeAPI)));             
            }
            system.debug('Cascading Debug:Outside Loop'+snapshot);
            relatedProductAttributeValue.Cascaded_Attribute_value__c=snapshot;
            nonLeadOptionAttRecords.add(relatedProductAttributeValue);
            System.debug('Inside cascadeAttributesFromLeadOption nonLeadOptionAttRecords:'+nonLeadOptionAttRecords);
        }
        
        
        
        update nonLeadOptionAttRecords;
    }
    
    /*public  map<Id,set<string>> getNonLeadingOptions(Set<Id> productIds,Id BundleId)
    {
          //Map<Id,boolean> productIsLeadingMap = new  Map<Id,boolean>();
          map<Id,set<string>> cascadableAttributesByProduct= new map<Id,set<string>>();
          List<Apttus_Config2__ProductOptionComponent__c> productComponents= [Select ID,Apttus_Config2__ComponentProductId__c,
                                                                               Is_Leading_option__c,Copy_Fields_from_Lead__c
                                                                               FROM Apttus_Config2__ProductOptionComponent__c where
                                                                                Apttus_Config2__ComponentProductId__c IN: productIds and 
                                                                                Apttus_Config2__ParentProductId__c=:BundleId];
          for(Apttus_Config2__ProductOptionComponent__c currentComp:productComponents)
          {
              currentComp.Copy_Fields_from_Lead__c=(currentComp.Copy_Fields_from_Lead__c!=null)?currentComp.Copy_Fields_from_Lead__c:'';
              list<string> strlist=currentComp.Copy_Fields_from_Lead__c.split(',',0);
              set<string> strset=new set<string>(strlist);//(currentComp.Copy_Fields_from_Lead__c.split(',',0))
              cascadableAttributesByProduct.put(currentComp.Apttus_Config2__ComponentProductId__c,new set<string>(strset));
             
              
             set<string> tempstr=cascadableAttributesByProduct.get(currentComp.Apttus_Config2__ComponentProductId__c);
             //Apexpages.addMessage(new apexpages.message(apexpages.severity.info,'OptionId:'+currentComp.Apttus_Config2__ComponentProductId__c+'-->'+tempstr));
          }
          return cascadableAttributesByProduct;
        
    }   */
    
    class bunldeOptionInfo{
     Id optionId;
     boolean isLead;
     integer optionnumber;
     set<string> cascadeAttributeAPIs;
     
     public bunldeOptionInfo(Apttus_Config2__ProductOptionComponent__c prodOptionComp)
     {
      optionId=prodOptionComp.Apttus_Config2__ComponentProductId__c;
      isLead=prodOptionComp.Is_Leading_option__c;
      cascadeAttributeAPIs=getAttributeAPIs(prodOptionComp.Copy_Fields_from_Lead__c);
     }
     set<string> getAttributeAPIs(string FieldAPIstring)
     {
              if(string.isBlank(FieldAPIstring))
                 return new set<string>();
              
              list<string> strlist=FieldAPIstring.split(',',0);
              set<string> strset=new set<string>(strlist);//(currentComp.Copy_Fields_from_Lead__c.split(',',0))
            
              return strset;  
     }
     
    }
    
    class LineItemInfo{
     Integer OptionLineNumber;
     Apttus_Config2__LineItem__c lineItem;
     public LineItemInfo(Apttus_Config2__LineItem__c LI, Integer LNumber)
     {
      OptionLineNumber=LNumber;
      lineItem=LI;      
     }
    }
    
    public map<Id,bunldeOptionInfo> getBundleOptionInfo(Set<Id> ComponentIds,Id BundleId){
           map<Id,bunldeOptionInfo> BundleOptionInfoById= new map<Id,bunldeOptionInfo>();
           List<Apttus_Config2__ProductOptionComponent__c> productComponents= [Select ID,Apttus_Config2__ComponentProductId__c,
                                                                               Is_Leading_option__c,Copy_Fields_from_Lead__c
                                                                               FROM Apttus_Config2__ProductOptionComponent__c where
                                                                                Id IN: ComponentIds and 
                                                                                Apttus_Config2__ParentProductId__c=:BundleId];
          for(Apttus_Config2__ProductOptionComponent__c currentComp:productComponents)
          {
            BundleOptionInfoById.put(currentComp.Id,new bunldeOptionInfo(currentComp));
          }
          
          return BundleOptionInfoById;
    }
    
    public list<Apttus_Config2__LineItem__c> getLineItemsForBundle(Id ConfigurationId,Decimal LineNumber,Id BundleId){
     list<Apttus_Config2__LineItem__c> lineItems= [Select ID, Apttus_Config2__LineStatus__c,
                                                    Apttus_Config2__BaseProductId__c,
                                                    Apttus_Config2__OptionId__c,
                                             Apttus_Config2__BasePrice__c,
                                             Apttus_Config2__PricingStatus__c,
                                             Apttus_Config2__ProductId__c,
                                             Apttus_Config2__ProductOptionId__c,
                                             Apttus_Config2__AttributeValueId__c,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                                             Apttus_Config2__ConfigurationId__c,
                                             Apttus_Config2__AssetLineItemId__c,
                                             Apttus_Config2__EndDate__c,
                                             CurrencyIsoCode,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c,
                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c
                                             FROM Apttus_Config2__LineItem__c
                                             WHERE Apttus_Config2__ConfigurationId__c=:configurationId AND 
                                            Apttus_Config2__LineNumber__c =:LineNumber 
                                            AND Apttus_Config2__LineType__c = 'Option'];
                                            
     return lineItems;                                      
    
    }
    
    
    // The first option in the option group is always the lead option.
    public boolean validateLeadOption(Id ConfigurationId,Decimal LineNumber,Id BundleId)
    {
      System.debug('Inside the validateLeadOption function ');
        boolean validation=false;
         bundleLineItems=getLineItemsForBundle( ConfigurationId, LineNumber, BundleId);
         System.debug('Inside the validateLeadOption function  bundleLineItems'+bundleLineItems);
        //Error Prevention
        if(bundleLineItems.size()==0)
           return false;
         System.debug('Inside the validateLeadOption function  urrentLineItem.id'+currentLineItem.id);
         System.debug('Inside the validateLeadOption function  bundleLineItems[0].id'+bundleLineItems[0].id);
        // the first opiton in the list of options is always the lead option. This might change.
        if(bundleLineItems[0].id==CurrentLineItem.id)
          // validation=true; 
          cascadeAttributesFromLeadOption(BundleId);    
        
        return validation;
        //apexpages.addMessage(new apexpages.message(apexpages.severity.info,''+lineitems));
     //system.debug('validate lead options');
    }
 
 /*class CascadeAttributeInfo{
  public boolean isLeading=false;
  map<Id,List<string>> cascadableAttributesByProduct;
  string fieldlist;
  void doCascade()
  {
  
   return;
  }
 }*/
 
  Apttus_Config2__ProductAttributeValue__c getProductAttributeRecordInstance()
 {
  return new Apttus_Config2__ProductAttributeValue__c();
 }
     
    
}