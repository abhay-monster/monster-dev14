/*
 updated: 08/30
*/

public with sharing class ruleProcessor {
    
    class AttributeException Extends Exception
    {
      
    }
    map<string,Pavtempalte> pavTemplateMap=new map<string,Pavtempalte>();
    list<Id> AVGMIds=new list<Id>();
    /*
       AttributeValueMap:
       Key: AVGM Id;
       Value: AttributeValue custom type
       
       AttributeValue:
       Contains Attribute_Value_Group_Member__c information
       
       Re_Eval_Map: Contains attributes that needs to re evaluated 
       Eg: if the AVGM contains a record that hold product attribute value object fieldsAPI in attributeValues, it needs to re-evaluated after each pard Execution
           AVGM:
           if the posting_location__c = country__c for product attribute value reocrds
    */
    map<Id,attributeValue> AttributeValueMap=new map<Id,attributeValue>();
    map<Id,attributeValue> Re_Eval_Map=new map<Id,attributeValue>();
    
    public apttus_proposal__proposal__c proposalRecord;
    map<string,string> mapinputvalues=new map<string,string>();
    apttus_config2__ProductAttributeValue__c prodAttValue;
    
    
    /*
       Variables holding the rules information
    */
    map<Id,List<Id>> AttributeValueGroupIdByPardId;
    map<Id,list<Attribute_Value_Group_Member__c>> AttributeMemberByGroupId;
    
    /*
      Constructor: 
       The below member variables belong to productRulesWrapper
       map<Id,list<Id>> attValGrpByPardId;
       map<Id,list<Attribute_Value_Group_Member__c>> groupMembersByGroupId;
    */
    
    //List<string> PardRuleIds=new list<string>{'From Add to cart:'};
    /*
      for debugging purposes. To track the order of pard rules executed for each product.
    */
   
        ///Change 26/10 - added one more parameter 
    public ruleProcessor(productRuleHelper.productRuleInfo productRulesWrapper, Apttus_Proposal__proposal__c proposal, Apttus_Config2__ProductAttributeValue__c AttribValue) 
    {
        //Code 
        AttributeValueGroupIdByPardId = productRulesWrapper.attValGrpByPardId;
        AttributeMemberByGroupId      = productRulesWrapper.groupMembersByGroupId;
		System.debug('MS TEST AttributeMemberByGroupId'+AttributeMemberByGroupId); 
        Apexpages.addMessage(new apexpages.message(apexpages.severity.info,'--> pard rules by product '+AttributeValueGroupIdByPardId.size()));
       
        /* required when parsing attribute members*/
        proposalRecord=proposal;
        System.debug('MS TEST AttribValue'+AttribValue);
        ///Change 26/10 
        If(AttribValue != null)
        {
            
            prodAttValue  = AttribValue;
            }
        /*
         Prepare the cache of attribute values for this product
        */
        for(List<Attribute_Value_Group_Member__c> avgmlist:AttributeMemberByGroupId.values())
        {
          for(Attribute_Value_Group_Member__c avgm: avgmlist)
          {
           AttributeValueMap.put(avgm.Id,new attributeValue(avgm));
          }
        }
        System.debug('MS TEST AttributeValueMap'+AttributeValueMap);
        /*
          parse the rules
        */
        
        //AttributeValueMap=parseAttributeValueMap(AttributeValueMap,proposalRecord);
         
    }
    
    
    
    /*
     Method being called from GoToPricingCustomController.
    */
    
    Public  apttus_config2__ProductAttributeValue__c processRules(list<string> fieldAPINames,string productname)
    {
        //ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,'-->In process lines'+fieldAPINames));
        //ApexPages.addMessage(new apexpages.Message(apexpages.severity.error,'-->In process lines'+productname+':')); 
        for(string fieldName: fieldAPINames)
        {
         pavTemplateMap.put(fieldName,new Pavtempalte(fieldName,'Select One'));
        }
        pavTemplateMap.put('Product_Name__c',new Pavtempalte('Product_Name__c',productname));
        mapinputvalues.put('Product_Name__c',productname);
        
        pavTemplateMap.put('Geography__c',new Pavtempalte('Geography__c','National'));
        mapinputvalues.put('Geography__c','National');
       // System.debug('MS TEST AttribValue 1 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        prodAttValue=getFieldvaluesFromTemplate(); 
        System.debug('AttributeValueMap'+AttributeValueMap);
        //System.debug('MS TEST AttribValue 2 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        AttributeValueMap=parseAttributeValueMap(AttributeValueMap,proposalRecord);      
        //System.debug('MS TEST AttribValue 3 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        ExecuteRules();     
        //System.debug('MS TEST AttribValue 4 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        prodAttValue=getFieldvaluesFromTemplate(); 
        //System.debug('MS TEST AttribValue 5 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        //prodAttValue.Attribute_Debugger__c=''+string.join(PardRuleIds,',');
        
        return prodAttValue;
    }
    
    /*
      productAttribute Value Template
    */
    public class Pavtempalte
    {
     string fieldAPIName;
     string fieldValue;
     public Pavtempalte(string fieldAPI, string fieldValue)
     {
      this.fieldAPIName=fieldAPI;
      this.fieldValue=fieldValue;
     }
    }
    public class attributeValue
    {
        string attributeName;
        string attributeValues;
        string attributeType;
        Id Id;
        public attributeValue(Attribute_Value_Group_Member__c avgm)//
        {
         attributeName=(string.isBlank(avgm.Attribute_Value_Name__c))?'':avgm.Attribute_Value_Name__c;
         attributeValues=(string.isBlank(avgm.Attribute_Record_Value__c))?'':avgm.Attribute_Record_Value__c;
         
         attributeType=(string.isBlank(avgm.Attribute_Value_Type__c))?'':avgm.Attribute_Value_Type__c;
         Id=avgm.id;
        }
        
        public attributeValue(attributeValue av)
        {
         this.attributeName=av.attributeName;
         this.attributeValues=av.attributeValues;
         this.attributeType=av.attributeType;
         this.Id=av.id;
        }
     
    }
    
    
    /*
      Execute the rules and return the product attribute value reocrd.
    
    */
    
    public void executeRules()
    {
        //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'Before processing :Pard Rules: size:'+AttributeValueGroupIdByPardId.keyset().size()));
        integer counter=0;
        // loop through pardIds
         System.debug('MS TEST AttribValue 6 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        for(Id pardId:AttributeValueGroupIdByPardId.keyset())
        {
          counter+=1;
          //PardRuleIds.add(pardId);
         //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'prodAttvalue:'+prodAttValue));
         if(Re_Eval_Map.keyset().size()>0){
            prodAttValue=getFieldvaluesFromTemplate();
            reEvaluatedynamicProductAttributes(prodAttValue,counter);
           
         }
         List<Id> AttributeValueGroupIdList=AttributeValueGroupIdByPardId.get(pardId);
            System.debug('MS TEST AttributeValueGroupIdList'+AttributeValueGroupIdList);
         /*
           1st Element contains controlling group Id
           2nd Element contains dependent group Id
         */
         Id ControllingGroupId=AttributeValueGroupIdList[0];
         Id DependentGroupId= AttributeValueGroupIdList[1];
         
         
         
         /*
          get the AVGMs for the groupId 
         */
         /*
            Approach:
            1. create a map with attributeName and attribute values
            2. Group the multiple entries with the same API name in to a single key
            3. Loop through the input values verifying if the value matches.
         */
         //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'Executing rules :Pard Id '+''+pardId+' Controlling group: '+ControllingGroupId));
         //System.debug('MS TEST AttribValue 7 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
         Boolean controllingGroupResult=processControllingGroup(ControllingGroupId);
        // System.debug('MS TEST AttribValue 8 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'Result:'+counter+':'+controllingGroupResult));
         //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'mapinputvalues:'+mapinputvalues))
         
          
           if(controllingGroupResult)
            processDependentGroup(DependentGroupId,counter);  
           // System.debug('MS TEST AttribValue 9 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
          }
         //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'-->after processing all the pard rules'));
          storeNewInputsToPavTemplate();
         // System.debug('MS TEST AttribValue 10 :'+prodAttValue.id + ' Quanity value'+prodAttValue.Variable_Quanity__c);
        }
        
     
     boolean processControllingGroup(Id ControllingAVGID)
     {
         boolean processFlag=true;
         map<string,set<string>> attributeValuesbyAttributeName=groupAttributeMembersByName(AttributeMemberByGroupId.get(ControllingAVGID));
         
         /*
          Compare the input values with attribute values from rules
         
         */
         //Apexpages.addMessage(new apexpages.Message(apexpages.severity.Error,'Controlling group:::: Conf. APIs'+attributeValuesbyAttributeName.keyset()+'Conf. Values'+attributeValuesbyAttributeName.values()));  
         
         for(string configuredAttributeName: attributeValuesbyAttributeName.keyset()){
         
         set<string> configuredAttributesValuesSet=attributeValuesbyAttributeName.get(configuredAttributeName);
         
         /*
          the configured attribute name must exist in input map.
         */
         //if(!mapinputValues.containskey(configuredAttributeName))
           // Throw new AttributeException('Configured Attribute Field does not exist in attribute groups for given product. Id:'+ControllingAVGID);
         
         string inputValue=mapinputValues.get(configuredAttributeName);
         //apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'inputvalue:'+inputValue+':'+configuredAttributesValuesSet+'Result:'+configuredAttributesValuesSet.contains(inputValue))); 
         if(!configuredAttributesValuesSet.contains(inputValue))
            return false;
         
         
         
           }
         return processFlag; 
     }
     
     void processDependentGroup(Id DependentGroupId,integer i)
     {
       System.debug('DependentGroupId'+DependentGroupId);  
         System.debug('AttributeMemberByGroupId.get(DependentGroupId)'+AttributeMemberByGroupId.get(DependentGroupId));  
         System.debug('AttributeMemberByGroupId.get(DependentGroupId)'+groupAttributeMembersByName(AttributeMemberByGroupId.get(DependentGroupId)));
      map<string,set<string>> attributeValuesbyAttributeName=groupAttributeMembersByName(AttributeMemberByGroupId.get(DependentGroupId));
      for(string configuredAttName:attributeValuesbyAttributeName.keyset())
      {
       set<string> configuredattValues=attributeValuesbyAttributeName.get(configuredAttName);
       string DefaultValue=new list<string>(configuredattValues)[0];
       mapinputvalues.put(configuredAttName,DefaultValue);
       //apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'Defaulting Value:Att name:'+configuredAttName+'Value'+DefaultValue));
     
       } 
       //apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'Defaulting Snapshot:Counter:'+i+':'+attributeValuesbyAttributeName));
      
     }
     
     void storeNewInputsToPavTemplate()
     {
      for(string fieldAPI: pavTemplateMap.keyset())
      {
        string processedFieldValue= mapinputvalues.get(fieldAPI);
        pavTempalte pavTemplateItem= pavTemplateMap.get(fieldAPI);
        pavTemplateItem.fieldValue=processedFieldValue;
        pavTemplateMap.put(fieldAPI,pavTemplateItem);
      }
     }
     
     
    
    /*
       loop through template and return productattribute values
    */
    Apttus_config2__ProductAttributeValue__c getFieldvaluesFromTemplate()
    {
        //Code changes 26/10 
         apttus_config2__ProductAttributeValue__c prodAttvalue1;
        If(prodAttValue == null)
        {
    	  prodAttvalue1 =new apttus_config2__ProductAttributeValue__c();
        }
        else
        {
           prodAttvalue1 =  prodAttValue;
        }
        for(string fieldAPIName:pavTemplateMap.keyset())
        { 

         PavTempalte pavTemp= pavTemplateMap.get(fieldAPIName);
         if(fieldAPIName.equalsIgnoreCase('Quantity__c')){
             //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'quantity value:'+pavTemp.fieldValue));
             //pavTemp.fieldValue='0';
             
             Integer i=integer.valueOf(pavTemp.fieldValue=(pavTemp.fieldValue==null || pavTemp.fieldValue=='Select One')?'0':pavTemp.fieldValue);  
             prodAttvalue1.put(pavTemp.fieldAPIName,i);
             Continue;
        }
            
         prodAttvalue1.put(pavTemp.fieldAPIName,pavTemp.fieldValue);
        }
        
        return  prodAttvalue1;
    }
    
    
    map<string,set<string>> groupAttributeMembersByName(list<Attribute_Value_Group_Member__c> avgMemberlist)
    {
      map<string,set<string>> attributeValuesbyAttributeNameMap=new map<string,set<string>>();
      for(Attribute_Value_Group_Member__c avgMem:avgMemberlist)
         {
          attributeValue AV=AttributeValueMap.get(avgMem.Id);
           if(attributeValuesbyAttributeNameMap.containsKey(AV.attributeName))
           {
            /*
              New enhancement: comma seperated attribute values into groupmembers
              update the logic here below.
              
            */
            string attributeValues=AV.attributeValues;
            set<string> attributeValuesSet=new set<string>(attributeValues.split(',',0));
            attributeValuesSet.addALL(attributeValuesbyAttributeNameMap.get(AV.attributeName));
            /*
             above statement add the set returned by map to the existing set.
            */
            attributeValuesbyAttributeNameMap.put(AV.attributeName,attributeValuesSet);
            
           }
           else
           {
               System.debug(' AttributeValueMap AV'+AttributeValueMap);
               System.debug(' attributeValuesbyAttributeNameMap AV'+AV);
            attributeValuesbyAttributeNameMap.put(AV.attributeName,new set<string>(AV.attributeValues.split(',',0)));
           }
          
         }
      return attributeValuesbyAttributeNameMap;
      
    }
    
    
    
    
    /*
    
      parse the attribute rules by querying for proposal attributes.
    
    */
    
    
    map<Id,attributeValue> parseAttributeValueMap(map<Id,attributeValue> attvalueByAvgIdmap,Apttus_Proposal__Proposal__c prodProposal)
    {
     for(Id avgmId:attvalueByAvgIdmap.keyset() )
     {
      attributeValue att=attvalueByAvgIdmap.get(avgmId);
      System.debug('attributeValue att'+att);
            
            if(att.attributeType == 'Product'){
            AttributeValueMap.put(att.Id, att);
            
            /*
             re evaluation logic for product attribute value logic
             posting location=country
            */
            if(att.attributeValues.endsWith('__c'))
            Re_Eval_Map.put(att.id,new attributeValue(att));
            //Re_Eval_Map.put(att.id,att);
            }
            
            
            
            if(att.attributeType == 'Proposal'){
             
                if(att.attributeValues.endsWith('__c') || att.attributeValues.endsWith('__r.Name')){
                    if(att.attributeValues.endsWith('__c')){
                        if(prodProposal.get(att.attributeValues) != null){
                            att.attributeValues = String.valueOf(prodProposal.get(att.attributeValues));
                            system.debug('att.AttributeValueMap 1  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                            AttributeValueMap.put(att.Id,att);
                        }
                    }else if(att.attributeValues.endsWith('__r.Name')){
                             String rvar = att.attributeValues;
                             String obj = rvar.SubString(0,rvar.indexof('.'));
                             String field = rvar.SubString(rvar.indexof('.') + 1,rvar.Length());
                             system.debug('obj :'+obj+' field  :'+ field +'(String)prodProposal.getSObject(obj).get(field)  :'+(String)prodProposal.getSObject(obj).get(field) );
                             if((String)prodProposal.getSObject(obj).get(field) != null){
                                 String sValue = (String)prodProposal.getSObject(obj).get(field);
                                 att.attributeValues = sValue;
                                 system.debug('att.AttributeValueMap 2  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                                 AttributeValueMap.put(att.Id,att);
                             }
                             
                          }
                } else if(!att.attributeValues.endsWith('__c') && !att.attributeValues.endsWith('__r.Name') && (att.attributeName.endsWith('__c') || att.attributeName.endsWithIgnoreCase('__r.Name'))){
                          //controller proposal.
                          //hascontrollerproposalheader = true;
                          if(att.attributeName.endsWith('__c')){
                             //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,':'+att.attributeName+': att Id:'+ att.Id//+':'+prodProposal.get(att.attributeName)));
                              system.debug('controlling proposal __c'+String.valueOf(prodProposal.get(att.attributeName)).trim());
                              system.debug(' con value :'+att.attributeValues);
                              
                                if(prodProposal.get(att.attributeName) != null && String.valueOf(prodProposal.get(att.attributeName)).trim()!=null){
                                 AttributeValueMap.put(att.Id,att);
                                 string svalue=String.valueOf(prodProposal.get(att.attributeName)).trim();
                                 
                                 /*
                                  map proposal input values needs to be included.
                                 
                                 */
                                 //mapproposalInputValues.put(att.attributeName,sValue);
                                 system.debug('att.AttributeValueMap 3  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                                   mapinputvalues.put(att.attributeName,sValue);
                                }
                                else{
                                Throw new AttributeException('Attribute'+att.attributeName+'not found on proposal');
                                }
                              
                          } else {
                              system.debug(' in here __r');
                              system.debug('att.attributeName  :'+ att.attributeName);
                              //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,':'+att.attributeName
                                                                         //+':'+prodProposal.get(att.attributeName)
                              //                                           ));
                             
                              if(att.attributeName.endsWithIgnoreCase('__r.Name')){
                              String rvar = att.attributeName;
                              String obj = rvar.SubString(0,rvar.indexof('.'));
                              String field = rvar.SubString(rvar.indexof('.') + 1,rvar.Length());
                              system.debug('obj :'+obj+' field  :'+ field +'(String)prodProposal.getSObject(obj).get(field)  :'+(String)prodProposal.getSObject(obj).get(field));
                             
                              system.debug(' con value :'+att.attributeValues);
                              if((String)prodProposal.getSObject(obj).get(field) != null){
                                 String sValue = (String)prodProposal.getSObject(obj).get(field);
                                 //att.attributeValues = sValue;
                                 system.debug('att.AttributeValueMap 4  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                                 AttributeValueMap.put(att.Id,att);
                                // mapproposalInputValues.put(att.attributeName,sValue);
                                mapinputvalues.put(att.attributeName,sValue);
                             }
                             else
                             Throw new AttributeException('Price List values not found for pard');
                              
                                //AttributeValueMap.put(att.Id,att);
                              system.debug('att.attributeName  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                             }
                          }
                          
                          
                }
            
            }
            //queryProposal = ' Pricing_Channel_Account__c ';
     }
     return AttributeValueMap;
    }
    
    void reEvaluatedynamicProductAttributes(apttus_config2__ProductAttributeValue__c PAV, integer i)
    {
     for(Id avgmId:Re_Eval_Map.keyset() )
     {
      attributeValue re_eval_att=Re_Eval_Map.get(avgmId);
      attributeValue att=attributeValueMap.get(avgmId);
      //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'re eval method:'+i+':Field:'+re_eval_att.attributeValues+'Value:'+PAV.get(re_eval_att.attributeValues)));
     
      att.attributeValues=string.valueOf(PAV.get(re_eval_att.attributeValues));
      
      AttributeValueMap.put(att.Id, att);
     }
     //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,'Exit: Reeval Method'+i));
      
    }
    
}

/*
  Tested Scenarios:
   
  AND Conditions works- Tested
  
  OR Condition works  - Tested
  
  Sequential:
  1. If product: country__c=canada
     Then Refresh interval=30         pard 09759
     
  2. If Refresh interval=30
     Then has auto refresh=Yes.       pard 09760
     
  
     
  

*/

/*
  Context:
  
  Debug the error:Invalid field Select One for Apttus_Config2__ProductAttributeValue__c
  Fixed. But the select one is being reatained for scenario posting location=country.
  Need to fix it.
  04/53 7/19.
  
  Commented debug lines in processDependentGroup method. 
  Commented debug lines in execute rules.
  
  Product used for testing:
  Monster standard Job Ad Veteran
  Used pard rules with sequences 7 , 8 and 9 for testing for verifying posting location = country
  
*/