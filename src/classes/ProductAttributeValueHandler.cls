/*
   Venkata R Sabbella
   Apttus Inc.
   08/11
	//Updated issue Quanity__C cascading type casting issue - 17/11
*/

public with sharing class ProductAttributeValueHandler {
    
    public static map<String,Boolean> pavHandlerMap=new map<String,Boolean>{'BeforeInsert'=>false,
                                                                            'BeforeUpdate'=>false,
                                                                            'AfterUpdate'=>false   
                                                                            };
                                                                                
    public ProductAttributeValueHandler()
    {
     
    } 
    
    public void populatefields(list<Apttus_Config2__ProductAttributeValue__c> NewList)
    {
     for(Apttus_Config2__ProductAttributeValue__c pav:newList)
     {
      if(pav.Copy_Posting_Location__c){
        pav.Posting_Locations__c=pav.Country__c;
      } 
    }
    }
    
    public void updateFields(list<Apttus_Config2__ProductAttributeValue__c> pavList){
        /*
        Set<String> objIdSet = new Set<String>();
        Map<String,String> locationGroupMap = new Map<String,String>();
        Map<String,String> locationTierMap = new Map<String,String>();

        for(Integration_Attribute__c intAtt: [Select Id, Name,  (Select Name, Source_Value__c FROM Integration_Attribute_Values__r) FROM Integration_Attribute__c Where Source_Field__c = 'Posting_Location__c']){
            for(Integration_Attribute_Value__c value: intAtt.Integration_Attribute_Values__r){
               
                if(intAtt.Name == 'PostingLocationGroupId'){
                    locationGroupMap.put(value.Source_Value__c, value.Name);
                } else if(intAtt.Name == 'TierId'){
                    locationTierMap.put(value.Source_Value__c, value.Name); 
                }
            }
            //objIdSet.add(intAtt.Id);
        }
        
        */
        /*for(Integration_Attribute_Value__c att: [Select Name, Source_Value__c FROM Integration_Attribute_Value__c WHERE Integration_Attribute__c IN: objIdSet]){
            system.debug('******* att: '+att);
            locationTierMap.put(att.Source_Value__c, att.Name);
        }*/
        /*
       //system.debug('******* locationTierMap: '+locationTierMap);
        for(Apttus_Config2__ProductAttributeValue__c pav: pavList){

            pav.Tier_ID__c = locationTierMap.get(pav.Posting_Locations__c);
            pav.Posting_Location_Group_Id__c = locationGroupMap.get(pav.Posting_Locations__c);
        }
        */
    }
    
    
    /*
      Cascading requirement
    */
    public list<Apttus_Config2__ProductAttributeValue__c> copyFieldValuesFromLead(map<Id,Apttus_Config2__ProductAttributeValue__c> newMap)
    {
      
      list<Apttus_Config2__ProductAttributeValue__c> prodAttValueList = new list<Apttus_Config2__ProductAttributeValue__c>();
     //set<apttus_config2__productConfiguration__c> prodConfigIdSet;
     
     //if(string.isBlank(fieldAPIQueryString))
     //  return null;
     Id ConfigurationId; 
     decimal LineNumber;
     //system.assert(false,'before for');
     for(Apttus_Config2__ProductAttributeValue__c pav: newMap.values())
     {
      //system.assert(false,'in for'+pav.ConfigurationId__c);
      ConfigurationId=pav.ConfigurationId__c;
      LineNumber=pav.Line_Number__c;
      break;
     }
     //system.assert(false,'configId":'+ConfigurationId);
     
     map<Id,apttus_config2__lineItem__c> lineItemListForAttributes=new map<Id,apttus_config2__lineItem__c>([select id,name,Apttus_Config2__LineNumber__c,
                                                            Apttus_Config2__AttributeValueId__c,
                                                            Apttus_Config2__ConfigurationId__c,
                                                            Copy_Fields_From_Lead__c
                                                            from apttus_config2__lineItem__c 
                                                           where 
                                                            //Apttus_Config2__AttributeValueId__c IN:newMap.keyset()
                                                            //and 
                                                            Apttus_Config2__ConfigurationId__c=:ConfigurationId
                                                            and 
                                                           	Apttus_Config2__LineType__c='Option'
                                                            and 
                                                            Apttus_Config2__LineNumber__c=:LineNumber
                                                            //and Apttus_Config2__ProductOptionId__r.Is_Leading_option__c=false
                                                            ]);
                                                            
     string fieldAPIQueryString=getFieldAPI(lineItemListForAttributes.values());
     //map<Id,set<decimal>> lineNumberListByConfigId=new map<Id,set<decimal>>(); 
     //system.assert(lineItemListForAttributes.size()>0,'lineitems: '+lineItemListForAttributes.size());                                                   
     map<decimal,set<apttus_config2__lineItem__c>> lineItemlistByLineNumber=new  map<decimal,set<apttus_config2__lineItem__c>>();
     
     for(apttus_config2__lineItem__c lineItem:lineItemListForAttributes.values() )  
     {
       ConfigurationId=lineItem.Apttus_Config2__ConfigurationId__c;
      // construct the map lineNumberListByConfigId
       
       if(lineItemlistByLineNumber.containsKey(lineItem.Apttus_Config2__LineNumber__c))
          lineItemlistByLineNumber.get(lineItem.Apttus_Config2__LineNumber__c).add(lineItem);
       else
          lineItemlistByLineNumber.put(lineItem.Apttus_Config2__LineNumber__c,new set<apttus_config2__lineItem__c>{lineItem});
     }  
     
     
     /*List<apttus_config2__lineItem__c> lineItemListForCascading=[select id,name 
                                                                  from apttus_config2__lineItem__c 
                                                                  where                                                               
                                                                 Apttus_Config2__ConfigurationId__c =:ConfigurationId
                                                                 and Apttus_Config2__ProductOptionId__r.Is_Leading_option__c=true
                                                                 
                                                                 /*
                                                                  filter for lead lines
                                                                 
                                                            ];*/
                                                            
     //map<decimal,apttus_config2__lineItem__c> leadLineItemByLineNumber=new map<decimal,apttus_config2__lineItem__c>();    
     //query the lead lines                                              
     //for each lead in the configuration
     for(apttus_config2__lineItem__c LeadlineItem:database.query(getPavQueryString(fieldAPIQueryString,ConfigurationId)                                                                 
                                                                 ) ) 
     {
          //for each non lead item
        for(apttus_config2__lineItem__c NonLeadlineItem:lineItemlistByLineNumber.get(LeadlineItem.Apttus_Config2__LineNumber__c))
        {
         if(NonLeadlineItem.Apttus_Config2__LineNumber__c==null)
            continue;
         Apttus_Config2__ProductAttributeValue__c pav=newmap.get(NonLeadlineItem.Apttus_Config2__AttributeValueId__c);
         
         
         for(string attributeAPI:pav.Copy_Fields_From_Lead__c.split(',',0)){
         pav.put(AttributeAPI,LeadlineItem.get(AttributeAPI));
         prodAttValueList.add(pav);
         }
        }
     }  
     
     return prodAttValueList;                                                   
                                                            
     
    }
    // used in cascading requirement
    string getFieldAPI(list<Apttus_Config2__LineItem__c> LineItem)
    {
     set<string> pavFieldAPI=new set<string>();
     for(Apttus_Config2__LineItem__c Line: LineItem)
     {
      if(!string.isBlank(Line.Copy_Fields_From_Lead__c))      
        pavFieldAPI.addAll(Line.Copy_Fields_From_Lead__c.split(',',0));      
     }
     list<string> pavFieldAPIlist=new list<string>(pavFieldAPI);
     string str= string.join(pavFieldAPIlist,',');
     //str=(string.isBlank(str))?'':','+str;
     return ' '+str+' ';
    }
    // used in cascading requirment
    string getPavQueryString(string fieldstr,Id ConfigurationId)
    {
        string queryString='';
        fieldstr=(string.isBlank(fieldstr))?'':','+fieldstr;
        queryString=' select id,name,Apttus_Config2__LineNumber__c '+fieldstr+
        ' from apttus_config2__lineItem__c where '+
        ' Apttus_Config2__ConfigurationId__c =:ConfigurationId '+
        ' and Apttus_Config2__ProductOptionId__r.Is_Leading_option__c=true ';
        
        return queryString;
     
    } 
    
    
    // Mihir: Please use the string split Method here. so we donot run in to the issue
    public void RestoreTheCascadedValue(list<Apttus_Config2__ProductAttributeValue__c> PAVList)
    {
        //Updated issue Quanity__C cascading type casting issue - 17/11
        String objType='Apttus_Config2__ProductAttributeValue__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        //Updated issue Quanity__C cascading type casting issue - 17/11
        For(Apttus_Config2__ProductAttributeValue__c Otemp: PAVList)
        {
        	If(String.isnotblank(Otemp.Cascaded_Attribute_value__c ))
            {
                System.debug('Otemp id '+Otemp.id+' Otemp.Cascaded_Attribute_value__c'+Otemp.Cascaded_Attribute_value__c);
                string tempval = Otemp.Cascaded_Attribute_value__c;
                    System.debug('tempval'+tempval); 
                list<string> PAVAttrList = tempval.split('##');
                System.debug('PAVAttrList'+PAVAttrList);
                /*
                  PAVAttrList[0] Contains this value 'variable_quantity = 0';
                */
                    
                /*integer iCount  = PAVAttrList.size();
                integer i=0 ; 
                while (i < iCount)
                {
                    Otemp.put(PAVAttrList[i], PAVAttrList[i+1]);
                    i=i+2;
                }*/
                
                for(string snapshot:PAVAttrList)
                {
                  list<string> strlist=snapshot.split('=');
                   
                   // error scenario where PAVAttrList[0] Contains this value 'variable_quantity = ##';
                   if(strlist.size()<2)
                      continue;
                    System.debug('strlist[0]'+strlist[0]+'  strlist[1]'+strlist[1]);
                  If(strlist[1] != 'NULL')
                  {
                    string sFieldAPI = strlist[0].trim();  
                   Schema.DisplayType fielddataType = fieldMap.get(sFieldAPI).getDescribe().getType(); 
                      if(fielddataType == Schema.DisplayType.Integer) {
                        Otemp.put(sFieldAPI, Integer.valueof(strlist[1].trim()));
                      }
                      else if(fielddataType == Schema.DisplayType.DOUBLE) {
                      	 Otemp.put(sFieldAPI, DOUBLE.ValueOf(strlist[1].trim()));
                       }
                      else
                      {
                          Otemp.put(sFieldAPI, strlist[1].trim()); 
                      }
                  // Otemp.put(sFieldAPI, strlist[1].trim());
                  }
                 
                }
            }
        }
    }
}