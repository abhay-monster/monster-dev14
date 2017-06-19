/*
  Updated: Venkata R Sabbella, Cascading attributes.

  for supporting the option groups within the constraint rules
  Created 08/10/2015.
*/


public with sharing class BundleOptionAttributeExt2 {
     
    


    

/* on every change of Attribute field value this method is called.
 save the current Attribute selection into mapinputvalues and replace the Attributes with maporiginalatt (which contains all the values)
 call populatefields will will run the Atribute condition on the current values.
*/
class AttributeException Extends Exception{
 
}
//debug variables

public string sysflow{
 get{
     if(sysflow==null)
       sysflow='';
       return sysflow;
      
 }
 set{
     sysflow=value;
 }
}

public string debugString{
 get{if(debugString==null)
        debugstring=''+system.now();
     
    return debugString;}
 set{debugString=Value;}
}

public string pardPath{
get{
    if(pardPath==null)
      pardpath=''+system.now();
      
      return pardPath;
 }
set{pardpath=value;}
}

Map<String,String> mapinputvalues = new Map<String,String>();
list<string> pardRuleIds=new list<string>{'From: Page:'};


    public PageReference Attchange() {
      //return null;
    //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Attribute Id'+pavObject.id));
       Sysflow+='Attchange-->';
       system.debug(' in Attchange input :'+ inputlabel +' '+inputvalue);
       system.debug('\nResume_Upgrade'+Resume_Upgrade);
       if(!Mid_Contract || !Product_Extension || !Product_Conversion){

        // for current input values selected <field>, <value>
              apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Name:'+mapinputvalues.get('Country__c')));
                    
              //set<String> setinputfields = new set<String>();
              //set<String> setinputfieldsapi = new set<String>();
               AttClassTemplateItem t1=pavTemplateMap.get('Product_Name__c');
               t1.templItemInput=product.name;
               pavTemplateMap.put('Product_Name__c',t1);
               t1=pavTemplateMap.get('Geography__c');
               t1.templItemInput='National';
               pavTemplateMap.put('Geography__c',t1);
              
		       mapinputvalues.put('Product_Name__c',product.name);	      
		      mapinputvalues.put('Geography__c','National');
		      
		      
              if(hascontrollerproposalheader){
                    //mapinputvalues.put('Quoteheader__c','TRUE');
                    //setinputfieldsapi.add('Quoteheader__c');
                    for(string attnamekey:mapproposalInputValues.keyset())
                    {
                     mapinputvalues.put(attnamekey,mapproposalInputValues.get(attnamekey));
                     //setinputfieldsapi.add(attnamekey);
                    }
                    
                }
                
              //for(AttClassTemplateItem t: AttClassTemplateItemList)
                for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem t=pavTemplateMap.get(fieldAPIName);
                	
                	
                    mapinputvalues.put(t.labelValueApi,t.templItemInput);// save the current selection values(needs logic to save other than picklist)
                    system.debug('t.labelValueApi  : '+t.labelValueApi+'  t.templItemInput:'+ t.templItemInput);
                    //if(t.templItemInput != 'None' && t.templItemInput != null){
                        //setinputfields.add(t.labelValue); // the current field labels that have been modified
                        //setinputfieldsapi.add(t.labelValueApi);// the current field labels api that have been modified
                        //t.templItemInput = 'None';
                    //}
                    system.debug('maporiginalatt:'+maporiginalatt.get(t.labelValueApi));
                    //logic to set the values to original map values
                    t.attrbOption.clear();
                    if(!Resume_Upgrade)
                        t.attrbOption.add(new selectOption('None','None'));
                    if(maporiginalatt.get(t.labelValueApi)!=null){
                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Name:'+t.labelValueApi+':'+maporiginalatt.get(t.labelValueApi)));
                        for(String key : maporiginalatt.get(t.labelValueApi).split(',')){
                            t.attrbOption.add(new selectOption(key,key));
                        }
                    }   
                    system.debug('t.labelValueApi'+t.labelValueApi+'\n maporiginalatt.get(t.labelValueApi) :'+maporiginalatt.get(t.labelValueApi));
                    system.debug('after t.attrbOption'+t.attrbOption);
                    //if(t.labelValueApi=='Country__c')
                    //{
                     //pavObject.Country__c=t.templItemInput;
                    //}
                }//for
                // add mapinputvalues.put('Quoteheader__c','TRUE') if there is any Quote header controller 
                //reEvaluateAttributes();
                system.debug('hascontrollerproposalheader :'+hascontrollerproposalheader);                     
                system.debug('map original values :'+maporiginalatt);
                system.debug('mapinputvalues:'+mapinputvalues); 
                //system.debug('setinputfieldsapi  :'+setinputfieldsapi);
            
                populatefields(mapinputvalues);
       }// end if locked
       else{ // should allow from resume updgrade midcontract.
           //LockProductAttributes();
           updateProductAttributeValue();
       }
       //cascadeAttributesOnLeadConfiguration();
                return null;
        }
        
  public void cascadeAttributesOnLeadConfiguration()
  {
   CascadeAttributes cascadeAtt=new CascadeAttributes(pavObject1,lineItem,true); 
   //cascadeAtt.cascade('a1eq0000000Mw8fAAC',1);
   //cascadeAtt.cascade(lineItem.Apttus_Config2__ConfigurationId__c,lineItem.Apttus_Config2__LineNumber__c,ProdId);  
     boolean flag=cascadeAtt.validateLeadOption(lineItem.Apttus_Config2__ConfigurationId__c,lineItem.Apttus_Config2__LineNumber__c,ProdId);
     //system.assert(!flag);
     
  }       
    
 // method to dymamicaly populate the picklist values on the controlling and dependent selection.
 
  public PageReference populatefields(Map<String,String> mapinputvalues){
       apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'populate fields:'+mapinputvalues));
             
    
     try{
     	     for(String PARDid :pardControllingmap.keyset() ){
                boolean result=processControllingGroup(PARDid,mapinputvalues);
                //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'populate fields:'+pardControllingmap.keyset()+result));
             
                if(true)//result
                {
                 mapinputvalues=processDependentGroup(PARDid,mapinputvalues);
                 reEvaluateAttributes(mapinputvalues);
                }
             }
         }
         catch(Exception e){
             //debugString+=''e.getMessage()+''+ex.getLineNumber();
             //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'controlling and dependent attribute didnot load correctly please contact your Admin'+e.getLineNumber()));
             System.debug('Error Attribute field Exception controlling and dependent fields :'+ e);
             
         }
 
LockProductAttributes();
updateProductAttributeValue();
return null;
}// end populatefields

/*public void resetDependentValues(string PardId)
{
 //system.debug('attributeId-->'+pardDependentMap.get(PardId));
 //return;
 list<string> AttributeValueIdList = pardDependentMap.get(PardId);
 Attribute_Value__c attributevalue=productAttributeValueMap.get(AttributeValueIdList[0]);
 system.debug('attribute value:'+attributevalue);
 string attributeAPIName=attributevalue.Attributes_Name__c;
 for(AttClassTemplateItem t: AttClassTemplateItemList){
  if(t.labelValueApi==attributeAPIName)
  {
   system.debug('reset values for :'+attributeAPIName);
   if(maporiginalatt.get(t.labelValueApi)!=null){
                        for(String key : maporiginalatt.get(t.labelValueApi).split(',')){
                            t.attrbOption.add(new selectOption(key,key));
                        }
                    }
  }
 }
 return ;
}*/

/*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : method to includ attribute values.
** @paramaters : 
** @returns : 
*/
 map<string,set<string>> getConfiguredValues(List<Id> avgmIds)
{
	       
	       map<string,set<string>> configuredValuesByAPI=new map<string,set<string>>();
           for(Id avgmId:avgmIds)
             {
              attributeValue av=productAttributeValueMap1.get(avgmId);
              //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'getConfigredValues:'+av));
	
              if(configuredValuesByAPI.containsKey(av.attributeName)){
                 set<string> configuredValuesset=new set<string>(av.attributeValues.split(',',0));
                 set<string> existingset=configuredValuesByAPI.get(av.attributeName);
                 configuredValuesset.addALL(existingset);
                 configuredValuesByAPI.put(av.attributeName,configuredValuesset);
                 
              }
              else{
              	 configuredValuesByAPI.put(av.attributeName,new set<string>(av.attributeValues.split(',',0)));
                }
              }
          
          return configuredValuesByAPI;    
          
          // updated method
       
}

boolean processControllingGroup(Id PARDid, map<string,string> mapinputvalues){
	         boolean result=true;
             list<Id> avgmIdlist=pardControllingmap.get(PARDid);
             map<string,set<string>> configuredValuesByAPI=getConfiguredValues(avgmIdlist); 
             for(string APIName: configuredValuesByAPI.keyset())
             {
              string inputValue=mapinputvalues.get(APIName);
              set<string> configuredValues=configuredValuesByAPI.get(APIName);
              if(!configuredValues.contains(inputValue))
              {
               return false;
              }
              
             }
              
         return result;      
	
 
}

map<string,string> processDependentGroup(id PARDid,map<string,string> mapinputvalues)
{   
	if(PARDAction.get(PARDid) != null){
                             if(PARDAction.get(PARDid) == 'Include'){
                             //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Inclusion Rule'+pardRulesById.get(PARDid).name));
                                mapinputvalues=includeDependents(PARDid,mapinputvalues);
                         } else if(PARDAction.get(PARDid) == 'Exclude'){
                                   excludeDependents(PARDid);
                              } else if(PARDAction.get(PARDid) == 'Hide'){
                                       hideDependents(PARDid);
                                  } else if(PARDAction.get(PARDid) == 'Lock'){
                                            lockDependents(PARDid);
                                      }
                         }
      return mapinputvalues;                    
 
}

public map<string,string> includeDependents(String PARDid, map<string,string> mapinputvalueUpdates){
	         //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'includedependents'));
	         list<Id> avgmIdlist=pardDependentMap.get(PARDid);
	         if(avgmIdlist.size()==0)
	            return mapinputvalueUpdates;
	         Product_Attribute_Rule_Definitions__c pardrule= pardRulesById.get(PARDid); 
             map<string,set<string>> configuredValuesByAPI=getConfiguredValues(avgmIdlist);
             
              apexpages.addMessage(new apexpages.message(apexpages.severity.info,'conf values'+avgmIdlist));
             for(string fieldAPI:configuredValuesByAPI.keyset())
             {
              list<string> configuredValues=new list<string>(configuredValuesByAPI.get(fieldAPI));
              //if(configuredValues.size()==0)
              //   configuredValues[0]='None';
              string defaultValue=configuredValues[0];
              AttClassTemplateItem pavTemplate=pavTemplateMap.get(fieldAPI);              
              pavTemplate.attrbOption.clear();
              //pavTemplate.attrbOption.add(new selectOption('None','None'));
              if(configuredValues.size()>0){
                 pavTemplate.optList=configuredValues;
                 pavTemplate.getAttrbOption();
              }
              pavTemplate.templItemInput = defaultValue;//defaultValue
              pavTemplate.hidden=pardrule.hide__c;
              mapinputvalueUpdates.put(pavTemplate.labelValueApi, pavTemplate.templItemInput);
              apexpages.addMessage(new apexpages.message(apexpages.severity.info,PARDid+' includedependents'+'Field API:'+fieldAPI+'::'+'labelValueApi'+pavTemplate.labelValueApi+'::'+pavTemplateMap.get(pavTemplate.labelValueApi).templItemInput));
              }
	         
	         
	         /*
	         AttClassTemplateItem.clear();
	         for(AttClassTemplateItem pavTemplate1:pavTemplateMap.values())
	         {
	          AttClassTemplateItemList.add(pavTemplate1);
	         }*/
	return mapinputvalueUpdates;
}


/*public map<string,string> includeDependents(String PARDid, map<string,string> mapinputvalueUpdates){
    sysflow+='include dependents-->';
    List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
    for(String eachAvid : pardDependentMap.get(PARDid)){
        if(productAttributeValueMap.get(eachAvid) != null)
           listAV.add(productAttributeValueMap.get(eachAvid));
    }
     //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'listAV'+listAV));
    system.debug('to be execute dependent list :'+listAV);
    Product_Attribute_Rule_Definitions__c pardrule= pardRulesById.get(PARDid);   
    
    if(pardrule==null)
    Throw new AttributeException('No Pard Exists');
                
    
    
    
    
    for(AttClassTemplateItem opt: AttClassTemplateItemList){
        Integer count = 0;
        String lockvalue;
        set<String> inputs = new Set<String>();
        for(Attribute_Value__c eachAv : listAV){
           if(eachAv.Attributes_Name__c == opt.labelValueApi && count == 0){
           //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'include rule'));
              opt.attrbOption.clear();
              opt.attrbOption.add(new selectOption('None','None'));
              count++;
              lockvalue = eachAv.Attribute_Values__c;
              opt.attrbOption.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
              inputs.add(eachAv.Attribute_Values__c);
              opt.hidden=pardrule.hide__c;
              
              //mapinputvalueUpdates.put(opt.labelValueApi,lockvalue);
              
           }else if(eachAv.Attributes_Name__c == opt.labelValueApi && count != 0){
                     count++;
                     //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Include Rule Encountered+count'+count));
                     opt.attrbOption.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
                     inputs.add(eachAv.Attribute_Values__c);
                }
          }
          if(count == 1){
             opt.templItemInput = lockvalue;
          }
          system.debug('opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption+' count  :'+ count);
          mapinputvalueUpdates.put(opt.labelValueApi, opt.templItemInput);                       
       }
       
       return mapinputvalueUpdates;
    
}*/

/*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : method to exclude attribute values.
** @paramaters : 
** @returns : 
*/

public void excludeDependents(String PARDid){/*
    
    List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
    for(String eachAvid : pardDependentMap.get(PARDid)){
        if(productAttributeValueMap.get(eachAvid) != null)
           listAV.add(productAttributeValueMap.get(eachAvid));
    }
    system.debug('to be execute dependent list :'+listAV);
    for(AttClassTemplateItem opt: AttClassTemplateItemList){
        system.debug('Before'+'  opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption);
        set<String> inputs = new Set<String>();
        for(Attribute_Value__c eachAv : listAV){
           if(eachAv.Attributes_Name__c == opt.labelValueApi){
              for(integer i=0;i< opt.attrbOption.Size();i++){
                  if(opt.attrbOption[i].getValue() == eachAv.Attribute_Values__c)
                     opt.attrbOption.remove(i);
              }
           }
           
          }
          system.debug('After'+'  opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption);
                                 
       }
       */
}

/*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : method to Hide attribute values.
** @paramaters : 
** @returns : 
*/
public void hideDependents(String PARDid){
    
}


/*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : method to lock attribute values.
** @paramaters : 
** @returns : 
*/
public void lockDependents(String PARDid){
    //debugString+='Lock Dependents';
    /*List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
    for(String eachAvid : pardDependentMap.get(PARDid)){
        if(productAttributeValueMap.get(eachAvid) != null)
           listAV.add(productAttributeValueMap.get(eachAvid));
    }
    for(AttClassTemplateItem opt: AttClassTemplateItemList){
        Integer count = 0;
        String lockvalue;
        set<String> inputs = new Set<String>();
        for(Attribute_Value__c eachAv : listAV){
           if(eachAv.Attributes_Name__c == opt.labelValueApi ){
              debugString+='@lock'+eachAv.Attributes_Name__c ;
              opt.attrbOption.clear();              
              opt.attrbOption.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
              inputs.add(eachAv.Attribute_Values__c);
              opt.explicitLock=true;
                            
           }
        }
    }   */ 
}


/*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : creates the Attributes into groups.
** @paramaters : 
** @returns : 
*/

public Map<String,List<Attribute_Value__c>> creatgroups(List<Attribute_Value__c> controllinglistAV){
    Map<String,List<Attribute_Value__c>> attgroups = new Map<String,List<Attribute_Value__c>>();
    if(controllinglistAV != null){
        for(Attribute_Value__c eachattval: controllinglistAV){
            if(attgroups.get(eachattval.Attributes_Name__c) == null){
                List<Attribute_Value__c> temp = new List<Attribute_Value__c>();
                temp.add(eachattval);
                attgroups.put(eachattval.Attributes_Name__c,temp);
            }else{
                List<Attribute_Value__c> temp = attgroups.get(eachattval.Attributes_Name__c);
                temp.add(eachattval);
                attgroups.put(eachattval.Attributes_Name__c,temp);
            }
            
        }
    }
  return attgroups;
}

/*
** @author : Cloud Sherpas Inc.
** @date : 10/1/2014
** @description : lock the fields if the there is only one Attribute value selection 
                                   else if Quote type = Resume Upgrade then only enable attribute selection for Contract_Duration__c, Geography__c, Resume_License_Type__c and View_Count_Resume__c
                                   else if Quote type = Product Extension then only enable attribute selection for Contract_Duration__c,
                                   else if line item status = 'Incremented' or 'Amended' or 'Renewed' lock the Attribute 
                                   else open for editing.
** @paramaters : 
** @returns : 
*/


public void LockProductAttributes(){
    //system.debug(' linestatuslock :'+linestatuslock);
    //(AttClassTemplateItem opt: AttClassTemplateItemList){
    	for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem opt=pavTemplateMap.get(fieldAPIName);
        system.debug(' size opt.labelValueApi  :'+opt.labelValueApi+' = size :'+opt.attrbOption.size()+' <>option values'+opt.attrbOption);
        if(!Resume_Upgrade && !Product_Extension && !Mid_Contract && !Product_Conversion){
            opt.lockfield = false;
        }
        if(opt.attrbOption.size() == 2 && !Resume_Upgrade){
            opt.lockfield = true;
            system.debug('opt.attrbOption size:'+opt.attrbOption[opt.attrbOption.size()-1].getValue()+'\n opt.templItemInput :'+opt.templItemInput);
            if(opt.attrbOption[opt.attrbOption.size()-1].getValue() != null && opt.templItemInput != opt.attrbOption[opt.attrbOption.size()-1].getValue() && (opt.templItemInput == null || opt.templItemInput == 'Select One')){
                opt.templItemInput = opt.attrbOption[opt.attrbOption.size()-1].getValue();
            }
        } 
        
        if(Resume_Upgrade && (opt.labelValueApi =='Contract_Duration__c' || opt.labelValueApi =='Geography__c' || opt.labelValueApi == 'Resume_License_Type__c' || opt.labelValueApi == 'View_Count_Resume__c')){
                opt.lockfield = false;
        }else if(Resume_Upgrade){
                opt.lockfield = true;
        }
        
        if(Product_Extension && opt.labelValueApi =='Contract_Duration__c'){
                opt.lockfield = false;
        }else if(Product_Extension){
                opt.lockfield = true;
        }
        
        if(Mid_Contract){
                opt.lockfield = true;
        }
        
        if(Product_Conversion){
                opt.lockfield = true;
        }
        
        /*else if(linestatuslock){
                opt.lockfield = true;
            }else{
                opt.lockfield = false;
            }*/
    }
}
 
 /*
** @author : Cloud Sherpas Inc.
** @date : 09/23/2014
** @description : if the Quote type is Mid contract the the contract duration should be limited to =< Remaining Duration(Original Quote Contract End Date(latest end date) ? Current Date)
                    this superseeds any controlling dependent logic.
** @paramaters : 
** @returns : 
*/
public void  midContractDuration(){
    Date currentDate = Date.Today();
    String contractDurationstr = '';
    Integer counter = 1; 
    system.debug('in mid contract : contract end date:'+contrectEndDate+'  today Date'+currentDate);
    if(contrectEndDate != null && currentDate < contrectEndDate){
        currentDate = currentDate.addDays(7);
        if(currentDate < contrectEndDate) contractDurationstr = '1 Week';
        currentDate = currentDate.addDays(7);
        if(currentDate < contrectEndDate) contractDurationstr+= ',2 Weeks';
        currentDate = currentDate.addDays(14);
        if(currentDate < contrectEndDate) contractDurationstr+= ',1 Month';
        currentDate = currentDate.addMonths(1);
        while(currentDate < contrectEndDate){
            counter++;
            contractDurationstr+=','+counter+' Months';
            currentDate = currentDate.addMonths(1);
            
        }

    }
        system.debug('contractDurationstr '+contractDurationstr);
       // for(AttClassTemplateItem atClass: AttClassTemplateItemList){
        for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);	
            if(atClass.labelValueApi  == 'Contract_Duration__c'){
                atClass.attrbOption.clear();
                atClass.attrbOption.add(new selectOption('None','None'));
                for(String key : contractDurationstr.split(',')){
                    atClass.attrbOption.add(new selectOption(key,key));
                }
                
            }
        }
}

public Apttus_Config2__ProductAttributeValue__c getProdAttSO()
{
 Apttus_Config2__ProductAttributeValue__c prodAttributeVal=new Apttus_Config2__ProductAttributeValue__c();
 for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);	
            System.debug('atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
            
            if(atClass.labelValuetype =='DATE'){// the attribute type is Date
                pavObject.put(atClass.labelValueApi, atClass.inputdate);
            }else if(atClass.labelValuetype =='DOUBLE'){// the attribute type is Double
                      pavObject.put(atClass.labelValueApi, atClass.inputItemDOUBLE);
            }else{// the attribute type is picklist or String
               pavObject.put(atClass.labelValueApi, atClass.templItemInput); 
            }
                
            
        }//for
        return prodAttributeVal;
}

// update the Attribute sellection to the line item.
public PageReference updateProductAttributeValue(){
	return null;
    /*
        Apttus_Config2__ProductAttributeValue__c pavObject = new Apttus_Config2__ProductAttributeValue__c(ID = pavObjectID);
       // date dateVar = null;
       if(Product_Extension){
            pavObject.put('APTS_Updated_From_Attributes_Page__c',true);
       }

        pavObject.put('Apttus_Config2__LineItemId__c',lineItemId);
        //for(AttClassTemplateItem atClass: AttClassTemplateItemList){
        for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);	
            System.debug('atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
            
            if(atClass.labelValuetype =='DATE'){// the attribute type is Date
                pavObject.put(atClass.labelValueApi, atClass.inputdate);
            }else if(atClass.labelValuetype =='DOUBLE'){// the attribute type is Double
                      pavObject.put(atClass.labelValueApi, atClass.inputItemDOUBLE);
            }else{// the attribute type is picklist or String
               pavObject.put(atClass.labelValueApi, atClass.templItemInput); 
            }
                
            
        }//for
        /*
           Attribute Debugger.
        */
        //pavObject.put('Attribute_Debugger__c',string.join(pardRuleIds,','));
    /*   
    System.debug('pavObject : '+pavObject);
        if(pavObjectID == null || pavObjectID ==''){
           insert pavObject;
           Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c (id = lineItemId,Apttus_Config2__AttributeValueId__c = pavObject.Id );
           update lineItem;
           
          }
        else 
        update pavObject;
        System.debug('pavObject updated.');
        // for passing pavObject as a parameters to cascading constructor.
        pavObject1=pavObject;
       
        return null;
    */
    } // End updateproductAttributevalue


  //dynamic picing code when Calculate price button on click.
  // this method will call the pricing web service and result is recived set the lineitem status to pendingstatus.
public PageReference pricingcalls(){ 
    system.debug('starting pricing code <> actionpollar :'+ actionpollar);
    system.debug('configSO :'+configid+' <>prodLineItems :'+lineItemId);
       /* if(configid != null && lineItemId != null){
        //result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
        system.debug('is the result pending'+result.IsPricePending);
        //actionpollar = true;
         if(!result.IsPricePending){
            Apttus_Config2__LineItem__c lineitemprice = [ select Id,Apttus_Config2__BasePrice__c, Apttus_Config2__PricingStatus__c from Apttus_Config2__LineItem__c where Id =:lineItemId];
             if(lineitemprice.Apttus_Config2__BasePrice__c != null)
             price =  lineitemprice.Apttus_Config2__BasePrice__c.setScale(2);
            system.debug(' price :'+ price);
            if(lineitemprice.Apttus_Config2__PricingStatus__c != 'Pending'){
                lineitemprice.Apttus_Config2__PricingStatus__c = 'Pending';
                update lineitemprice;
                actionpollar = false;
            }
         }else{
             actionpollar = true;
         } 
        //system.debug('pricing product line item :'+picelist); Apttus_Config2__PricingStatus__c
     }*/

    return null;
}

 /*
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : action pollar method for the pricing which recussively check if the pricing web service got completed.
                  get the base price for that line item and set the line item status to pending.
** @paramaters : 
** @returns : 
*/

public PageReference updatepricingcalls(){
    /*(configid != null && lineItemId != null){
    System.debug('in actionpollar still calculating price:'+result.IsPricePending+'  <>action pollar is :'+actionpollar);
    result = Apttus_CpqApi.CPQWebService.updatePriceForCart(request);
    System.debug('after call:'+result.IsPricePending);
    if(!result.IsPricePending && actionpollar){
            Apttus_Config2__LineItem__c lineitemprice = [ select Id,Apttus_Config2__BasePrice__c, Apttus_Config2__PricingStatus__c from Apttus_Config2__LineItem__c where Id =:lineItemId];
             if(lineitemprice.Apttus_Config2__BasePrice__c != null)
             price =  lineitemprice.Apttus_Config2__BasePrice__c.setScale(2);
            system.debug(' price :'+ price);
            if(lineitemprice.Apttus_Config2__PricingStatus__c != 'Pending'){
                lineitemprice.Apttus_Config2__PricingStatus__c = 'Pending';
                update lineitemprice;
                
            }
            actionpollar = false;
         }
    }else{
        actionpollar = false;
    }*/
         return null;
}

    
/*public static String currency(String i) {
    String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
    return s.substring(0,s.length()-1);
}*/
 
public Product2 Product; 
    
public String pavObjectID;       
public String inputlabel;
public String inputvalue;
public String ProdId;

public String optionGroupId;
public String ProposalId;
public String lineItemId;
public String configRequestId;
public String configid;
public String AssetLineItemId;
public Date contrectEndDate;
public Apttus_Config2__ProductAttribute__c[] AttFields;    
public String[] field = new List<String>();
public String[] fieldname = new List<String>();
public String[] datatype = new List<String>();
public Map<String,String> fieldmap = new Map<String,String>();

public map<string,AttClassTemplateItem> pavTemplateMap=new map<string,AttClassTemplateItem>();
//public List<AttClassTemplateItem> AttClassTemplateItemList  = new List<AttClassTemplateItem>();
public Map<String,String> maporiginalatt =new Map<String,String>();
//public Apttus_CPQApi.CPQ.UpdatePriceRequestDO request = new Apttus_CPQApi.CPQ.UpdatePriceRequestDO();
//public Apttus_CpqApi.CPQ.UpdatePriceResponseDO result;
public Boolean actionpollar{get; set;}
public String pricecurrency {get; set;} // to show the currency Type eg USD..
public Decimal price {get; set;} // Shows the Price from LineItem.Baseprice round it 2 decimal places.
public Integer Qty {get; set;}// Qty on each product.
public Boolean Resume_Upgrade {get; set;}
public Boolean Mid_Contract {get; set;}
public Boolean Product_Extension {get; set;}
public Boolean Product_Conversion {get; set;}
public Boolean hascontrollerproposalheader{get; set;}
//new model maps
public Map<String,List<String>> pardControllingMap = new Map<String,List<String>>();
//public Map<String,List<String>> controllingMap = new Map<String,List<String>>();
public Map<String,List<String>> pardDependentMap = new Map<String,List<String>>();


//public Map<String,Attribute_value__c> productAttributeValueMap = new Map<String,Attribute_Value__c>();
// Attribute Value Cache....
public Map<String,attributeValue> productAttributeValueMap1 = new Map<String,attributeValue>();


public Map<Id,String> PARDAction = new Map<Id,String>();//map to maintain Action type of PARD records.
public map<Id,Product_Attribute_Rule_Definitions__c> pardRulesById=new map<Id,Product_Attribute_Rule_Definitions__c>();
public map<string,string> mapproposalInputValues=new map<string,string>();
Apttus_Config2__ProductAttributeValue__c pavObject;
//for passing as a parameter to cascading attribute constructor.
Apttus_Config2__ProductAttributeValue__c pavObject1;
//map<Id,Attribute_Value__c> AttributeById_reevalMap=new map<Id,Attribute_Value__c>();

//code refactor
map<Id,attributeValue> AttributeById_reevalMap1=new map<Id,attributeValue>();

map<Integer,Id> PardSequenceMap=new map<Integer,Id>();
Apttus_Config2__LineItem__c lineItem;


    public List<AttClassTemplateItem> getAttClassTemplateItemList(){  
       for(string fieldAPIName : pavTemplateMap.keyset()){
          // AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);
          // atClass.attrbOption.add(new selectoption('test','test'));
          //atClass.templItemInput='None';
       }
        return pavTemplateMap.values();
        //for(string fieldAPIName : pavTemplateMap.keyset())
                	//AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);	
    }   

  //this is the constructor
  Public BundleOptionAttributeExt2(ApexPages.StandardController controller){ 
       // get parameter values
     //ctrl = new Apttus_Config2.ProductAttributeDetailController2(controller);
     //debugString='';
      try{
     lineItemId = System.currentPageReference().getParameters().get('id');
     configRequestId =  System.currentPageReference().getParameters().get('configRequestId');
     lineItem = [select ID, Apttus_Config2__LineStatus__c,
                                                    Apttus_Config2__BaseProductId__c,
                                                    Apttus_Config2__OptionId__c,
                                                    // option group Id
                                                    Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c,
                                                    Apttus_Config2__BasePrice__c,
                                                    Apttus_Config2__PricingStatus__c,
                                                    Apttus_Config2__ProductId__c,
                                                    Apttus_Config2__AttributeValueId__c,
                                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                                                    Apttus_Config2__ConfigurationId__c,
                                                    Apttus_Config2__LineNumber__c,
                                                    Apttus_Config2__AssetLineItemId__c,
                                                    Apttus_Config2__EndDate__c,
                                                    CurrencyIsoCode,
                                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.APTS_Quote_Type__c,
                                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c
                                                from Apttus_Config2__LineItem__c
                                                where ID =:lineItemId]; 
      
      pavObjectID = lineItem.Apttus_Config2__AttributeValueId__c; 
      ProdId =lineItem.Apttus_Config2__ProductId__c;
      optionGroupId=lineItem.Apttus_Config2__ProductOptionId__r.Apttus_Config2__ProductOptionGroupId__c;
      Id OptionId= lineItem.Apttus_Config2__OptionId__c;
      Product=[select id,name from product2 where Id=:OptionId];
      ProposalId = lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c;
      configid = lineItem.Apttus_Config2__ConfigurationId__c;
      AssetLineItemId = LineItem.Apttus_Config2__AssetLineItemId__c;
           // get the Line item Base Price to price variable so it can be shown on the Attribute page Onload.
           //this varible is updated in Price call method through calculate button on Attribute page.
      if(lineItem.Apttus_Config2__BasePrice__c != null){
          price = lineItem.Apttus_Config2__BasePrice__c.setScale(2);
      }
      //request.CartId = configid; // set configration id for pricing.
      pricecurrency = lineItem.CurrencyIsoCode;
      contrectEndDate = lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c;
      String fieldlist;
      actionpollar = false;
      //linestatuslock = false;
      Resume_Upgrade = false;
      Mid_Contract = false;
      Product_Extension = false;
      Product_Conversion = false;
      hascontrollerproposalheader = false;
      Apttus_Proposal__Proposal__c prodProposal;
      // donot allow editing of attributes if the Line item status = Incremented or Amended or Renewed
      pavObject=[select id,name,country__c from Apttus_Config2__ProductAttributeValue__c where id=:pavObjectID];
      
      
        
      
        
        // Get the attribute list for the product.
        AttFields = [SELECT Apttus_Config2__Field__c,
                            Apttus_Config2__Sequence__c 
                                FROM Apttus_Config2__ProductAttribute__c 
                                WHERE Apttus_Config2__AttributeGroupId__c IN 
                                            (SELECT Apttus_Config2__AttributeGroupId__c 
                                                    FROM Apttus_Config2__ProductAttributeGroupMember__c 
                                                    WHERE Apttus_Config2__ProductId__r.Id =:OptionId) ORDER BY Apttus_Config2__Sequence__c];
       
        Map<Id,Controlling_Attribute_workflow_Object__c> productlock;
        //Map<Id,Controlling_Attribute_workflow_Object__c> proposaldriver;
        //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Attributes Size'+AttFields.size()));
       if(AttFields.size() >0){ 
          
          try{
         // AttFields.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__Field__c=''+product.name,
         //                                                         Apttus_Config2__Sequence__c=AttFields.size()+1)); 
          // for rules based on product name to be fired.                                                       
              
        //get attributes and its metadata from product Attribute value object for the Attributes listed in ProductAttributeGroupMember of the Product.
              Schema.SObjectType t = Schema.getGlobalDescribe().get('Apttus_Config2__ProductAttributeValue__c');  
              Schema.DescribeSObjectResult r = t.getDescribe();   
              for(Integer j=0; j<AttFields.size();j++){
                 field.add(AttFields[j].Apttus_Config2__Field__c);
                 //field.add(String.valueof(AttFields[j].Apttus_Config2__Field__c));
                 system.debug('field name field[j]:'+field[j]);
                 Schema.DescribeFieldResult f = r.fields.getMap().get(field[j]).getDescribe();
                 fieldname.add(f.getLabel());// get field names
                 system.debug(' field type: '+ f.getType());
                 //set datatype for field
                  if(f.getType() == Schema.DisplayType.PICKLIST) {
                     datatype.add('PICKLIST');  
                  }else if(f.getType() == Schema.DisplayType.DATE){
                          datatype.add('DATE');
                        }else if(f.getType() == Schema.DisplayType.DOUBLE){
                            datatype.add('DOUBLE');
                        }else if(f.getType() == Schema.DisplayType.STRING){
                           datatype.add('STRING'); 
                        }
                      
                 system.debug('field[j] :'+field[j]+' fieldname:'+fieldname[j]+' type :'+datatype[j]);
        
                 List<String> lstPickvals = new List<String>();
                 String orgpicklistval;
                 if(datatype[j] == 'PICKLIST'){
                   for (Schema.PicklistEntry a : F.getPicklistValues()) { //for all values in the picklist list
                      lstPickvals.add(a.getValue());//add the value  to our final list
                      system.debug('fieldname[j]'+fieldname[j]+'a.getValue():'+a.getValue());
                      system.debug('before orgpicklistval'+orgpicklistval);
                      if(string.isBlank(orgpicklistval)){orgpicklistval = a.getValue();}else{ orgpicklistval+=','+a.getValue();}
                      //system.debug('orgpicklistval'+orgpicklistval);
                    }//for
                system.debug('orgpicklistval'+orgpicklistval);
                }//if
               
               AttClassTemplateItem pavTemplate=new AttClassTemplateItem(fieldname[j],field[j],datatype[j],lstPickvals);
               //AttClassTemplateItemList.add(pavTemplate);
               //adds value to the picklist
               maporiginalatt.put(field[j],orgpicklistval);
               // add values to field map <Apiname, fieldname>
               fieldmap.put(fieldname[j],field[j]);
               pavTemplateMap.put(field[j],pavTemplate);
               mapinputValues.put(field[j],null);
               
               system.debug('fieldmap :'+fieldmap);
               
               if(string.isBlank(fieldlist)){fieldlist = field[j];}else{ fieldlist+=','+field[j];}  
             }
             //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Template list'+AttClassTemplateItemList.size()));
      
         }catch(Exception e) { 
                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'product attribute fields issue'+e.getlineNumber()));
                             System.debug(LoggingLevel.ERROR, 'cannot access DescribeFieldResult'); 
                          } 
    
    
     if(!Mid_Contract || !Product_Extension || !Product_Conversion){ // if the Line Itme is Locked i:e status =Incremented or Amended or Renewed then dont do the controling dependent attribute 
        
        List<Product_Attribute_Rule_Definitions__c> prodPardList = new List<Product_Attribute_Rule_Definitions__c>();
        List<Attribute_Value__c> attValues = new  List<Attribute_Value__c>();
        Set<Id> avgIdSet = new Set<Id>();
         // get all controlling and dependents records from PARD object for selected product.
               
        

       
       prodPardList=[SELECT Id,Name,
                                  bundle_product__r.name,Primary_Product__r.name,
                                  Controlling_Attribute_Value_Group__c,
                                  Dependent_Attribute_Value_Group__c ,
                                  Hide__c,
                                  Primary_Product__c,
                                  Action__c,
                                  sequence__c,
                                  Leading_Produc_Option__c,Leading_Product_Option_Group__c,
                                  active__c
                                  FROM Product_Attribute_Rule_Definitions__c 
                                  Where active__c=true and
                                  ((Primary_Product__c =:OptionId  and Product_Option_Group__c=null) 
                                    or
                                   (Primary_Product__c =:OptionId and Product_Option_Group__c=: optionGroupId)
                                  )
                                  order by Primary_Product__c,Product_Option_Group__c nulls first,sequence__c];                                               
        Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Rules Size'+prodPardList.size()));                        
        
        for(Product_Attribute_Rule_Definitions__c pd: prodPardList){
            avgIdSet.add(pd.Controlling_Attribute_Value_Group__c);
            PARDAction.put(pd.Id,pd.Action__c);
            avgIdSet.add(pd.Dependent_Attribute_Value_Group__c);
            pardRulesById.put(pd.id,Pd);
           // PardSequenceMap.put(pd,);
        }
        
        //attValues = AttributeUtilityClass.getAttribueValueList(avgIdSet);
        String queryProposal;
        
        
        
        queryProposal=' id,name,Apttus_QPConfig__PriceListId__c,Apttus_QPConfig__PriceListId__r.name, '+
                          ' Selling_Country__c,Pricing_Channel_Account__c ';
        prodProposal = getProposal(queryProposal);
        
       
        
        
        Map<String,List<String>> attrbToValGroupMap = new Map<String,List<String>>();
        
        Set<Id> contAvgs = new Set<Id>();
        Set<Id> depAvgs = new Set<Id>();
        Set<Id> allAvgs = new Set<Id>();
        //Set<ID> allAttributes = new Set<Id>();

        for(Product_Attribute_Rule_Definitions__c pard: prodPardList){
            if(pard.Controlling_Attribute_Value_Group__c != null){
                contAvgs.add(pard.Controlling_Attribute_Value_Group__c);
                depAvgs.add(pard.Dependent_Attribute_Value_Group__c);
                //pardAvgContMap.put(pard.Id, pard.Controlling_Attribute_Value_Group__c);
                //pardAvgDepMap.put(pard.Id, pard.Dependent_Attribute_Value_Group__c);
            }
            
        }
        
        allAvgs.addAll(contAvgs);
        allAvgs.addAll(depAvgs);
        
        //constructing a map of attribute group to attribute value
        //map < attributegroup=> attributevalue list >
        for(Attribute_Value_Group_Member__c gp: [SELECT Attribute_Value__c, Attribute_Value_Group__c,Attribute_Value_Name__c,
                                                        Attribute_Record_Value__c,Attribute_Value_Type__c,
                                                        Attribute_Value_Name_Manual__c, Attribute_Record_Value_Manual__c, Attribute_Value_Type_Manual__c                                                        
                                                 From Attribute_Value_Group_Member__c 
                                                 Where Attribute_Value_Group__c 
                                                 IN:allAvgs]){
            //allAttributes.add(gp.Attribute_Value__c);
            productAttributeValueMap1.put(gp.Id,new attributeValue(gp));
            if(attrbToValGroupMap.containsKey(gp.Attribute_Value_Group__c)){
                attrbToValGroupMap.get(gp.Attribute_Value_Group__c).add(gp.Id);
            } else {
                attrbToValGroupMap.put(gp.Attribute_Value_Group__c, new List<String>{gp.Id});
            }
        }
       // parseAttributeValues(prodProposal);
       //map<Pard => controlling attribute values Ids>
       // map<Pard=> Dependenet attribute values ids >
       for(Product_Attribute_Rule_Definitions__c pard: prodPardList){
            pardControllingMap.put(pard.Id, attrbToValGroupMap.get(pard.Controlling_Attribute_Value_Group__c));
            pardDependentMap.put(pard.Id, attrbToValGroupMap.get(pard.Dependent_Attribute_Value_Group__c));
        }
        
        
        
        
        
       
       
       } // end of linestatuslock;
     }//end ProdAttributeGroupmemberId.size() > 0 
     
     populatedefaults(fieldlist);
     parseAttributeValues(prodProposal,pavObject);
       
     //apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'pavObject:'+pavObject));
     if(Resume_Upgrade){ // apply Resume_Upgrade conditions.
         ResumeUpgrade();
         
        
     }
  }
  catch(Exception ex)
  {
   apexpages.addMessage(new apexpages.message(apexpages.severity.error,'+Error: '+ex.getMessage()+'Line:'+ex.getLinenumber()));
  }
  
}//constructor
  
 
  
  
  
  // this method will set default values for the product attribute fields
  // will set the values of the attributes with the values that were saved ealier with.
  public void populatedefaults(String fieldlist){
      system.debug('in populatedefaults  <>field list'+fieldlist);
      //Apttus_Config2__ProductAttributeValue__c pavObject;// = new Apttus_Config2__ProductAttributeValue__c(ID = pavObjectID);
      //system.debug('attribute value'+ pavObject);
      if(pavObjectID != null && pavObjectID != '' && !string.isBlank(fieldlist) && fieldlist != null){
         try{
            String qatt = 'SELECT '+fieldlist+' FROM Apttus_Config2__ProductAttributeValue__c WHERE Id =: pavObjectID';
            system.debug('query attribute object:'+qatt);
            pavObject = Database.query(qatt);
            
            //for product name constrintrules
            pavObject.put('Product_Name__c',product.name);
            }catch(SObjectException e){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Attribute  field name Exception'));
                   System.debug('Error Attribute field Exception :'+ e);
              } 
         //for(AttClassTemplateItem atClass: AttClassTemplateItemList){
         for(string fieldAPIName : pavTemplateMap.keyset()){
                	AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);
             System.debug('atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);

             if(atClass.labelValuetype == 'PICKLIST' || atClass.labelValuetype == 'STRING'){
                //if(atClass.labelValueApi=='Product_Name__c')
                  //atClass.templItemInput ==''+product.name;
                  //system.debug(''+product.name);
               if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                 atClass.templItemInput = (String)pavObject.get(atClass.labelValueApi);
                 system.debug('atClass.templItemInput'+ atClass.templItemInput+'  pavObject.get(atClass.labelValueApi)'+ pavObject.get(atClass.labelValueApi));
               }
             }else{//the attribute is a date
                if(atClass.labelValuetype == 'DATE')
                if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                    atClass.inputdate = (Date)pavObject.get(atClass.labelValueApi);
                }
                if(atClass.labelValuetype == 'DOUBLE')
                if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                    decimal val = (DOUBLE)pavObject.get(atClass.labelValueApi);
                    system.debug('value'+ val +'\n '+pavObject.get(atClass.labelValueApi));
                    atClass.inputItemDOUBLE = val.setScale(0);
                }
                    
             }
             mapinputValues.put(fieldAPIName,string.valueOf(pavObject.get(fieldAPIName)));
          }
          
      }
  }
  
  /*
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description : method Rusume upgrade Validations on Attribute Page allow only 3 attribute to be displayed on the Attribute page with selection >= original selection
                   attributes to have Greater selection Contract_Duration__c, Geography__c, Resume_License_Type__c, View count resume update should have normal selection. 
** @paramaters : 
** @returns : 
*/
//Apttus_Config2__AssetAttributeValue__c
  
    void ResumeUpgrade(){
        system.debug('in ResumeUpgrade '+AssetLineItemId);
        /*Contract_Duration__c 
        maporiginalatt<fieldsApi> <allpicklistvalue>
        mapinputvalues <field Api name > < current selected value>
        fieldmap <field name> <field Api name>*/
        if(AssetLineItemId !=null){
            String assetlist = 'Contract_Duration__c, Geography__c, Resume_License_Type__c';
            Apttus_Config2__AssetAttributeValue__c Assetval = getAssetAttributeValue(assetlist);
            system.debug('Assetval'+Assetval);
            system.debug('maporiginalatt :'+maporiginalatt.get('Contract_Duration__c') );
            if(Assetval !=null){
                    //for(AttClassTemplateItem atClass: AttClassTemplateItemList){
                    for(string fieldAPIName : pavTemplateMap.keyset()){
                	    AttClassTemplateItem atClass=pavTemplateMap.get(fieldAPIName);
                        System.debug('atClass.labelValue :'+atClass.labelValue+'  <>atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
                        String Ruvalues ='';
                        Boolean  Rucondition = false;
                        if(atClass.labelValueApi  == 'Contract_Duration__c' || atClass.labelValueApi  == 'Geography__c' || atClass.labelValueApi  == 'Resume_License_Type__c'){
                            
                            for(String key : maporiginalatt.get(atClass.labelValueApi).split(',')){
                                if(key == (String)Assetval.get(atClass.labelValueApi)){
                                   Rucondition = true;
                                }
                                if(Rucondition){
                                    if(string.isBlank(Ruvalues)){Ruvalues = key;}else{ Ruvalues+=','+key;}
                                        atClass.attrbOption.add(new selectOption(key,key));
                                }
                            }
                            maporiginalatt.put(atClass.labelValueApi,Ruvalues);
                        }
                    
                    }
            }
            
            
        }

        //system.debug('mapinputvalues :'+mapinputvalues.get('Contract_Duration__c'));
        
    }
    
    Apttus_Config2__AssetAttributeValue__c getAssetAttributeValue(String assetlist){
       system.debug('AssetLineItemId  :'+AssetLineItemId+'  assetlist  :'+assetlist);
        if(!string.isBlank(assetlist) && AssetLineItemId != null )
          {
           try{
            /*String qAsset = 'SELECT '+assetlist+' FROM Apttus_Config2__AssetAttributeValue__c WHERE Apttus_Config2__AssetLineItemId__c =: AssetLineItemId';
            system.debug('Assetattributevalue object:'+qAsset);
            Apttus_Config2__AssetAttributeValue__c assetVar = Database.query(qAsset);*/
            List <Apttus_Config2__AssetAttributeValue__c> assetVar = [SELECT Contract_Duration__c, Geography__c, Resume_License_Type__c FROM Apttus_Config2__AssetAttributeValue__c WHERE Apttus_Config2__AssetLineItemId__c =: AssetLineItemId];
            if(assetVar.size() >0){
                System.debug('assetVar'+assetVar);
                return(assetVar[0]);
            
            }
                
            
            }catch(SObjectException e){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Asset Attribute Value field name Exception'));
                   System.debug('Error Asset Attribute Value field Exception :'+ e);
              }
            }
        return null;   
    }
    
    /*public PageReference goToPricing() {
        system.debug('in goto pricing');
        PageReference pg = updateProductAttributeValue();
        //pg = new PageReference('/apex/Apttus_Config2__CartDetailView?id=' +configid+ '&configRequestId='+configRequestId+ '');
        //pg.setredirect(false);
        //return pg;
        return ctrl.doUpdateCart();
    }
        public PageReference goToPricing() {
        PageReference pg = Attchange();
        pg = new PageReference('/apex/pricing?id=' +configid + '&configRequestId=' + configRequestId + '');
        return pg;
    }
    */


// required selection of proposal fields are Queried and sent.
    Apttus_Proposal__Proposal__c getProposal(String Proposalfields){
     system.debug('ProposalId  :'+ProposalId+'  Proposalfields  :'+Proposalfields);
        if(!string.isBlank(Proposalfields) && ProposalId != null )
          {
           try{
            Proposalfields=getUniqueFields(Proposalfields);
            String qProposal = 'SELECT '+Proposalfields+' FROM Apttus_Proposal__Proposal__c WHERE Id =: ProposalId';
            system.debug('proposal object:'+qProposal);
            Apttus_Proposal__Proposal__c proposal = Database.query(qProposal);
            system.debug('proposal result:'+ proposal);
            return(proposal);
            }catch(SObjectException e){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'proposal field name Exception'));
                   System.debug('Error proposal field Exception :'+ e);
              }
            }
        return null;    
      }
      
      //Re-Evaluate AttributeValues
      //Venkata R Sabbella.
      // For revaluating the attributes based on user input.
      void reEvaluateAttributes(map<string,string> mapinputValues)
      {
        //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+AttributeById_reevalMap.keyset().size()));            
                  
           if(AttributeById_reevalMap1.keyset().size()==0)
           return;
           for(Id avgmId:AttributeById_reevalMap1.keyset()){
              attributeValue reevalatt=AttributeById_reevalMap1.get(avgmId);
              attributeValue att=productAttributeValueMap1.get(avgmId);
              
              list<string> attValuesList=reevalatt.attributeValues.split(',',0);
              for(string value:attValuesList)
              {
               if(!value.endsWith('__c'))
                  continue;
                //AttributeById_reevalMap.put(att.id,att);
                //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+pavObject)); //.get(att.Attribute_Values__c)
                 value=String.valueOf(mapinputValues.get(value));
                 //if(pavObject.get(value)!=null)
                   //{ 
                   	
                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+pavObject.get(att.Attribute_Values__c)));           
                    //att.Attribute_Values__c = String.valueOf(pavObject.get(reevalatt.Attribute_Values__c));
                    //updateProductLocation=true;
                  // }
               
              }
              string valueString=string.join(attValuesList,',');//new list<string>(attValuesSet)
          	  att.attributeValues=valueString;   	
            
              
            
             productAttributeValueMap1.put(att.Id, att);            
           }    
       return;
      }
      
      //venkata r sabbella
       // This method will eliminate dupliacate field selection from the proposal query.
      string getUniqueFields(string proposalFields)
      {
       string str=  proposalFields;
       set<string> strset= new set<string>();
       strset.addall(str.split(',',0));
       list<string> strlist=new list<string>(strset);
       string str1=string.join(strlist,',');
       return ' '+str1+' ';
       
      }
      
    public void parseAttributeValues(Apttus_Proposal__proposal__c prodProposal, Apttus_config2__ProductAttributeValue__c pavObject)
    {
    	apexpages.addMessage(new apexpages.message(apexpages.severity.error,'-->'));    
                    
    	for(Id attId: productAttributeValueMap1.keyset()) 
        { // for all attributes
          attributeValue att=productAttributeValueMap1.get(attId);
          list<string> attValuesSet=att.attributeValues.split(',',0);
          // parse attribute values with type product
          if(att.attributeType == 'Product'){
          	 for(string value:attValuesSet){
          	     if(!value.endsWith('__c'))
          	        continue;
          	     AttributeById_reevalMap1.put(att.id,new attributeValue(att));
          	   apexpages.addMessage(new apexpages.message(apexpages.severity.error,'product value1'+value));  
          	     //if(pavObject.get(value)!=null) 
                  value = String.valueOf(pavObject.get(value));
               apexpages.addMessage(new apexpages.message(apexpages.severity.error,'product value2'+value));   
             
          	 }  
          	 string valueString=string.join(attValuesSet,',');//new list<string>(attValuesSet)
          	 att.attributeValues=valueString;    	
            
             productAttributeValueMap1.put(att.Id, att);            
            }
            
            // parse attribute values with type proposal
            if(att.attributeType == 'Proposal'){
            	
               for(string value:attValuesSet){
               apexpages.addMessage(new apexpages.message(apexpages.severity.error,'proposal value2'+value));   
             
                if(value.endsWith('__c') || value.endsWith('__r.Name')){
                    if(value.endsWith('__c')){
                        if(prodProposal.get(value) != null){
                            value = String.valueOf(prodProposal.get(value));
                            //productAttributeValueMap1.put(att.Id,att);
                        }
                    apexpages.addMessage(new apexpages.message(apexpages.severity.error,''+value));    
                    }else if(value.endsWith('__r.Name')){
                             String rvar = value;
                             String obj = rvar.SubString(0,rvar.indexof('.'));
                             String field = rvar.SubString(rvar.indexof('.') + 1,rvar.Length());
                             system.debug('obj :'+obj+' field  :'+ field +'(String)prodProposal.getSObject(obj).get(field)  :'+(String)prodProposal.getSObject(obj).get(field) );
                             if((String)prodProposal.getSObject(obj).get(field) != null){
                                 String sValue = (String)prodProposal.getSObject(obj).get(field);
                                 value = sValue;
                                 //productAttributeValueMap1.put(att.Id,att);
                             }
                             
                          }
                    
                    
                }
               }
               string valueString=string.join(attValuesSet,',');//new list<string>(attValuesSet)
          	   att.attributeValues=valueString;  
          	   productAttributeValueMap1.put(att.Id,att);
          	    
               if(!att.attributeValues.endsWith('__c') && !att.attributeValues.endsWith('__r.Name') && (att.attributeName.endsWith('__c') || att.attributeName.endsWithIgnoreCase('__r.Name'))){
                          //controller proposal.
                          hascontrollerproposalheader = true;
                          if(att.attributeName.endsWith('__c')){
                            
                              //Throw New AttributeException('-->'+);
                              //if(att.attributeName.equals('Country__c' ))
                              //Throw new AttributeException('Attribute Exception'+att.id);
                             //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,':'+att.attributeName+': att Id:'+ att.Id//+':'+prodProposal.get(att.attributeName)));
                              system.debug('controlling proposal __c'+String.valueOf(prodProposal.get(att.attributeName)).trim());
                              system.debug(' con value :'+att.attributeValues);
                              
                              
                                if(prodProposal.get(att.attributeName) != null && String.valueOf(prodProposal.get(att.attributeName)).trim()!=null){
                                 //productAttributeValueMap1.put(att.Id,att);
                                 string svalue=String.valueOf(prodProposal.get(att.attributeName)).trim();
                                 mapproposalInputValues.put(att.attributeName,sValue);
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
                                 //productAttributeValueMap1.put(att.Id,att);
                                 mapproposalInputValues.put(att.attributeName,sValue);
                             }
                             else
                             Throw new AttributeException('Price List values not found for pard');
                              
                                //productAttributeValueMap.put(att.Id,att);
                              system.debug('att.attributeName  :'+att.attributeName+'att.attributeValues  :'+att.attributeValues);
                             }
                          }
                          //productAttributeValueMap1.put();
                          
                          
                }
            //}//end for values 
           } 
        }//enf for all attribubtes
    }
// call for all the attribute list selection.  
  @TestVisible 
    public class AttClassTemplateItem  {
    
        public String  labelValue{get; set;}
        public String  labelValueApi{get; set;}
        public String  labelValuetype{get; set;}
        public List<selectOption> attrbOption;
        public String  templItemInput {get; set;}
        public Decimal inputItemDOUBLE{get; set;}
        public Boolean lockfield{get; set;}
        public List<String> optList{get;set;}
        Public Date inputdate{get; set;}
        public Boolean explicitLock{get;set;}
        public Boolean hidden{get;set;}
                        
        //This is the contructor method
        @TestVisible
        public AttClassTemplateItem(String label,String labelapi,String labletype,List<String> opt) {
            system.debug('Test label:'+label);
            labelValue= label;
            labelValueApi = labelapi;
            labelValuetype = labletype;
            optList = opt;
            attrbOption = new List<selectOption>();
            templItemInput = templItemInput;
            lockfield = false;
            explicitLock=false;
            hidden=false;
                  
        }
        @TestVisible
        public List<selectOption> getAttrbOption(){
        
          if(attrbOption.isEmpty()){
            attrbOption.add(new selectOption('None','None'));
            for(String opVal : optList){
               system.debug(opVal);
               attrbOption.add(new selectOption(opVal,opVal));
            }
                    
        }   
          return attrbOption;
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
		 attributeName=(!string.isBlank(avgm.Attribute_Value__c))?avgm.Attribute_Value_Name__c:avgm.Attribute_Value_Name_Manual__c;
		 attributeValues=(!string.isBlank(avgm.Attribute_Value__c))?avgm.Attribute_Record_Value__c:avgm.Attribute_Record_Value_Manual__c;		 
		 attributeType=(!string.isBlank(avgm.Attribute_Value__c))?avgm.Attribute_Value_Type__c:avgm.Attribute_Value_Type_Manual__c;
		 Id=avgm.id;
		 checkNull();
		 //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,''+avgm));
		 
		}
		
		public attributeValue(attributeValue av)
		{
		 this.attributeName=av.attributeName;
		 this.attributeValues=av.attributeValues;
		 this.attributeType=av.attributeType;
		 this.Id=av.id;
		}
		void checkNull()
		{
		 this.attributeName=(string.isBlank(this.attributeName))?'':this.attributeName;
		 this.attributeValues=(string.isBlank(this.attributeValues))?'':this.attributeValues;
		 this.attributeType=(string.isBlank(this.attributeType))?'':this.attributeType;
		}
	 
	}

 
    

    

}