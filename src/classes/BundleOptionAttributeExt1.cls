/*
Updated: Venkata R Sabbella, Cascading attributes.


for supporting the option groups within the constraint rules
Created 08/10/2015.
Updated.



Updated: 09/10/2015
Request from Padma
1. 1.  Locking of Cascaded attributes from leading option.

Updated: 9/11/2015
Updated: 09/22/2015. QA has issues after migration

Updated: 10/29/2015

Update: Sorting of attributes. 09/25

Update : Cascading issue 10/11.

Update: Multipicklist Change 10/10/2016
*/


public with sharing class BundleOptionAttributeExt1 {
    
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
    

    list<string> pardRuleIds=new list<string>{'From: Page:'};
        
        
        public PageReference Attchange() {
            //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Attribute Id'+pavObject.id));
            Sysflow+='Attchange-->';
            //system.debug(' in Attchange input :'+ inputlabel +' '+inputvalue);
            //system.debug('\nResume_Upgrade'+Resume_Upgrade);
            if(!Mid_Contract || !Product_Extension || !Product_Conversion){

                // for current input values selected <field>, <value>
                Map<String,String> mapinputvalues = new Map<String,String>();
                //set<String> setinputfields = new set<String>();
                set<String> setinputfieldsapi = new set<String>();
                if(hascontrollerproposalheader){
                    //mapinputvalues.put('Quoteheader__c','TRUE');
                    //setinputfieldsapi.add('Quoteheader__c');
                    for(string attnamekey:mapproposalInputValues.keyset())
                    {
                        mapinputvalues.put(attnamekey,mapproposalInputValues.get(attnamekey));
                        setinputfieldsapi.add(attnamekey);
                    }
                }
                for(AttClassTemplateItem t: AttClassTemplateItemList){
                    
                    mapinputvalues.put(t.labelValueApi,t.templItemInput);// save the current selection values(needs logic to save other than picklist)
                    //system.debug('t.labelValueApi  : '+t.labelValueApi+'  t.templItemInput:'+ t.templItemInput);
                    if(t.templItemInput != 'None' && t.templItemInput != null){
                        //setinputfields.add(t.labelValue); // the current field labels that have been modified
                        setinputfieldsapi.add(t.labelValueApi);// the current field labels api that have been modified
                        //t.templItemInput = 'None';
                    }
                    //system.debug('maporiginalatt:'+maporiginalatt.get(t.labelValueApi));
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
                    //system.debug('t.labelValueApi'+t.labelValueApi+'\n maporiginalatt.get(t.labelValueApi) :'+maporiginalatt.get(t.labelValueApi));
                    //system.debug('after t.attrbOption'+t.attrbOption);
                    if(t.labelValueApi=='Country__c')
                    {
                        //pavObject.Country__c=t.templItemInput;
                    }
                    if(t.labelValueApi=='Duration__c')
                  {
                      pavObject.Duration__c=t.templItemInput;
                   }
                     if(t.labelValueApi=='Contract_Duration__c')
                   {
                      pavObject.Contract_Duration__c=t.templItemInput;
                    }
                    if(t.labelValuetype == 'MultiPicklist'){
                        pavObject.put(t.labelValueApi,t.templItemInput);
                    }
                }//for
                // add mapinputvalues.put('Quoteheader__c','TRUE') if there is any Quote header controller 
                reEvaluateAttributes();
                //system.debug('AttClassTemplateItemList:'+AttClassTemplateItemList);                     
                //system.debug('map original values :'+maporiginalatt);
                //system.debug('mapinputvalues:'+mapinputvalues); 
                //system.debug('setinputfieldsapi  :'+setinputfieldsapi);

                populatefields(setinputfieldsapi, mapinputvalues);
            }// end if locked
            else{ // should allow from resume updgrade midcontract.
                LockProductAttributes();
                updateProductAttributeValue();
            }
            //system.debug('cascadeAttributesOnLeadConfiguration before');
            cascadeAttributesOnLeadConfiguration();
            return null;
        }
    
    public void sortAttributes()
    {
        for(AttClassTemplateItem opt: AttClassTemplateItemList)
        {
            for(string str:opt.OptList)
            {
                if(str.isNumeric())
                {

                    //OptList=NumericSort(OptList);
                    break;
                }

                else
                {

                    opt.OptList.sort();
                    break;
                }

            }
            for(string str:opt.OptList)
            {
                opt.attrbOption.add(new selectOption(str,str));
                
            }     
        }

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
    
    public PageReference populatefields(set<String> setinputfieldsapi,Map<String,String> mapinputvalues){
        try{ 
            Sysflow+='populatefields-->';
            // logic to dynamically populate the picklist values.
            Set<Id> executedPARDS = new Set<Id>();


            for(String PARDid :pardControllingmap.keyset() ){//controllingMap.get(st)
                pardRuleIds.add(PARDid);
                sysflow+='pard loop-->';
                pardpath+='PardId: '+pardId+'-->';

                Boolean Any_failed = false;
                //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Run'+pardRulesById.get(PARDid).name));

                
                if(!executedPARDS.contains(PARDid)){
                    //system.debug('Executed pards size'+executedPARDS.size());
                    List<Attribute_Value__c> controllinglistAV = new List<Attribute_Value__c>();
                    //pardpath+='Executing pards:'+PardId+'-->';

                    for(String eachAvid : pardControllingMap.get(PARDid)){
                        //system.debug('@@pardControllingMap:keyset'+pardControllingMap.keyset());
                        //system.debug('@@pardControllinglist:'+pardControllingMap.get(PARDid));


                        
                        if(productAttributeValueMap.get(eachAvid) != null)
                            controllinglistAV.add(productAttributeValueMap.get(eachAvid));
                    }

                    //system.debug('controllinglistAV :'+controllinglistAV);
                    Map<String,List<Attribute_Value__c>> controllinggrops = new Map<String,List<Attribute_Value__c>>();
                    controllinggrops = creatgroups(controllinglistAV);
                    
                    if(controllinggrops.keyset().size()==1)
                    {
                        //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'contrl grop ==1'+controllinggrops.keyset().size()));
                        
                        pardpath+='cont groups:-->'+controllinggrops.keyset().size();
                        string attributeName1=new list<string>(controllinggrops.keyset())[0];
                        List<Attribute_Value__c> attvaluesbyattribute=controllinggrops.get(attributeName1);
                        set<string> attrvalues= new set<string>();
                        for(Attribute_Value__c atval1:attvaluesbyattribute)
                        {
                            attrvalues.add(atval1.Attribute_Values__c);
                        }
                        if(mapinputvalues.ContainsKey(attributeName1) && 
                           !String.isBlank(mapinputvalues.get(attributeName1)) && //!mapinputvalues.get(attributeName1).contains('TRUE') &&
                           !attrvalues.contains(mapinputvalues.get(attributeName1)))
                        {

                            Any_failed=true;
                            pardpath+='failed';
                        }
                    }
                    else if(controllinggrops.keyset().size()>1){

                        
                        for(String eachatt : controllinggrops.keySet()){
                            pardpath+='attribute value Id:'+eachatt+'-->';
                            //system.debug('controllinggrops.get(eachatt) :'+controllinggrops.get(eachatt));
                            for(Attribute_Value__c eachAV : controllinggrops.get(eachatt)){
                                pardpath+='attribute value:'+eachAV+'-->';

                                //system.debug('eachAV.Attributes_Name__c :'+eachAV.Attributes_Name__c+'eachAV.Attribute_Values__c :'+eachAV.Attribute_Values__c);
                                if(mapinputvalues.get(eachAV.Attributes_Name__c) == null || eachAV.Attribute_Values__c != mapinputvalues.get(eachAV.Attributes_Name__c)){
                                   // system.debug('eachAV.Attributes_Name__c  :'+ eachAV.Attributes_Name__c+'\n mapinputvalues.get(eachAV.Attributes_Name__c)'+mapinputvalues.get(eachAV.Attributes_Name__c));
                                    Any_failed = true;
                                    //debugString+='anyfailed=true:'+pardId;
                                    pardpath+='failed: eachAV.Attributes_Name__c'+eachAV.Attributes_Name__c+'selected values on page'+mapinputvalues.get(eachAV.Attributes_Name__c);
                                    break;
                                    //resetDependentValues(PARDid);
                                    
                                }else if(mapinputvalues.get(eachAV.Attributes_Name__c) != null && eachAV.Attribute_Values__c == mapinputvalues.get(eachAV.Attributes_Name__c)){
                                    //system.debug('anyfailed: attr value:'+eachAV.Attribute_Values__c+' mapinputvalues.get(attr value):'+mapinputvalues.get(eachAV.Attributes_Name__c));
                                    Any_failed = false; 

                                    pardpath+='passed';
                                    // debugString+='anyfailed=false:'+pardId;
                                    //break;
                                }
                            }
                            if(Any_failed){
                                break;

                            }
                        }
                    }
                    else{
                        //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'contr. groups:'+controllinggrops.keyset().size()));
                    }
                    if(!Any_failed){

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
                    }
                    if(!Any_failed)
                        executedPARDS.add(PARDid);
                    //system.debug('executedPARDS  :'+ executedPARDS);
                }else { 
                    //Any_failed = true;
                }
                //system.debug('Any_failed :'+Any_failed);
                
            }
            
        }catch(Exception e){
            //debugString+=''e.getMessage()+''+ex.getLineNumber();
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'controlling and dependent attribute didnot load correctly please contact your Admin'+e.getLineNumber()));
            //System.debug('Error Attribute field Exception controlling and dependent fields :'+ e);
            
        }
        
        LockProductAttributes();
        updateProductAttributeValue();
        lineItem.Attributes_Defaulted__c = True;          //Test 10/11/2015 - Code Change
        Update lineItem;                                  //Test 10/11/2015 - Code Change
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
    
    public map<string,string> includeDependents(String PARDid, map<string,string> mapinputvalueUpdates){
        sysflow+='include dependents-->';
        List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
        List<ProductAttributeValue> lstTempAttr = new List<ProductAttributeValue>(); 
        Boolean blnIsNumeric = true;
        for(String eachAvid : pardDependentMap.get(PARDid)){
            if(productAttributeValueMap.get(eachAvid) != null)
                listAV.add(productAttributeValueMap.get(eachAvid));
                System.debug(Logginglevel.info, 'productAttributeValueMap.get(eachAvid)' + productAttributeValueMap.get(eachAvid));
                if(productAttributeValueMap.get(eachAvid).Attribute_Values__c.isNumeric()){
                    ProductAttributeValue objAttrValue = new ProductAttributeValue(Decimal.Valueof(productAttributeValueMap.get(eachAvid).Attribute_Values__c),productAttributeValueMap.get(eachAvid));
                    
                    //objAttrValue.objAtt= productAttributeValueMap.get(eachAvid);
                    //objAttrValue.value = objAttrValue.objAtt.Attribute_Values__c;
                    lstTempAttr.add(objAttrValue);
                }else{
                    blnIsNumeric = false;
                }
        }
        
        //System.debug(Logginglevel.info, 'lstTempAttr' +  lstTempAttr);
        if(blnIsNumeric == true){
                lstTempAttr.Sort();
                listAV.Clear(); 
                for(ProductAttributeValue obj : lstTempAttr){
                    listAV.add(obj.objAtt);
                }
        }
        //System.debug(Logginglevel.info, 'listAV' + listAV);
        
        //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'listAV'+listAV));
        //system.debug('to be execute dependent list :'+listAV);
        Product_Attribute_Rule_Definitions__c pardrule= pardRulesById.get(PARDid);   
        
        if(pardrule==null)
            Throw new AttributeException('No Pard Exists');

        
        
        
        for(AttClassTemplateItem opt: AttClassTemplateItemList){
            Integer count = 0;
            String lockvalue;
            set<String> inputs = new Set<String>();

            for(Attribute_Value__c eachAv : listAV){

                //if(eachAv.APTS_Required__c)
                
                if(eachAv.Attributes_Name__c == opt.labelValueApi && count == 0){
                    //apexpages.addMessage(new apexpages.message(apexpages.severity.error,'include rule'));
                    opt.attrbOption.clear();

                    if(opt.labelValuetype != 'MultiPicklist'){
                        opt.attrbOption.add(new selectOption('None','None'));
                    }else if(opt.labelValuetype == 'MultiPicklist'){
                        opt.lstOtionLeftSelected.clear();
                        opt.leftselected.clear();
                        opt.leftvalues.clear();
                        opt.lstOtionRightSelected.clear();
                        if(!opt.rightvalues.Contains(eachAv.Attribute_Values__c)){
                            opt.lstOtionLeftSelected.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
                            opt.leftselected.add(eachAv.Attribute_Values__c);
                            opt.leftvalues.add(eachAv.Attribute_Values__c);
                        }else{
                            opt.lstOtionRightSelected.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
                        }
                    }
                    
                    opt.optList=new list<string>();
                    
                    count++;
                    lockvalue = eachAv.Attribute_Values__c;


                    opt.attrbOption.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));



                    opt.optList.add(eachAv.Attribute_Values__c);
                    inputs.add(eachAv.Attribute_Values__c);
                    opt.hidden=pardrule.hide__c;

                    opt.required=pardrule.APTS_Required__c;
                    
                    
                    //mapinputvalueUpdates.put(opt.labelValueApi,lockvalue);
                    
                }else if(eachAv.Attributes_Name__c == opt.labelValueApi && count != 0){
                    count++;
                    if(opt.labelValuetype == 'MultiPicklist'){
                        if(!opt.rightvalues.Contains(eachAv.Attribute_Values__c)){
                            opt.lstOtionLeftSelected.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
                            opt.leftselected.add(eachAv.Attribute_Values__c);
                            opt.leftvalues.add(eachAv.Attribute_Values__c);
                        }else{
                            opt.lstOtionRightSelected.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));

                        }
                    }
                    //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Include Rule Encountered+count'+count));
                    opt.attrbOption.add(new selectOption(eachAv.Attribute_Values__c,eachAv.Attribute_Values__c));
                    opt.optList.add(eachAv.Attribute_Values__c);              
                    inputs.add(eachAv.Attribute_Values__c);
                }
                
            }

            if(count == 1){
                opt.templItemInput = lockvalue;
            }
            //opt.attrbOption.Sort();
            //system.debug('opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption+' count  :'+ count);
            mapinputvalueUpdates.put(opt.labelValueApi, opt.templItemInput);                       
        }
        
        return mapinputvalueUpdates;
        
    }
    
    public void makeRequired()
    {
        
        
    }
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 13/1/2015
** @description : method to exclude attribute values.
** @paramaters : 
** @returns : 
*/
    
    public void excludeDependents(String PARDid){
        
        List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
        
        for(String eachAvid : pardDependentMap.get(PARDid)){
            if(productAttributeValueMap.get(eachAvid) != null)
                listAV.add(productAttributeValueMap.get(eachAvid));
            //System.debug(Logginglevel.info, 'productAttributeValueMap.get(eachAvid)productAttributeValueMap.get(eachAvid)' + productAttributeValueMap.get(eachAvid));
        }
        //system.debug('to be execute dependent list :'+listAV);

        for(AttClassTemplateItem opt: AttClassTemplateItemList){
            List<selectOption> OptionList = new List<selectOption>();
            set<string> ExcludeValues  = new set<string>();
            //system.debug('Before exclude'+'  opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption);
            set<String> inputs = new Set<String>();
            for(Attribute_Value__c eachAv : listAV){
                if(eachAv.Attributes_Name__c == opt.labelValueApi){
                    /*
                    for(integer i=0;i< opt.attrbOption.Size();i++){
                     system.debug('1111 Before exclude opt.attrbOption[i].getValue() :' +  opt.attrbOption[i].getValue()  +'eachAv.Attribute_Values__c:'+eachAv.Attribute_Values__c);
                        if(opt.attrbOption[i].getValue() == eachAv.Attribute_Values__c)
                            system.debug('222 Before exclude opt.attrbOption[i].getValue() :'+  opt.attrbOption[i].getValue()  +'eachAv.Attribute_Values__c:'+eachAv.Attribute_Values__c);  
                            opt.attrbOption.remove(i);
                            OptionList.remove(i);
                            
                    }
                    */
                    //***New code
                  
                    for(integer i=0;i< opt.attrbOption.Size();i++){ 
                     //system.debug('1111 Before exclude opt.attrbOption[i].getValue() :' +  opt.attrbOption[i].getValue()  + ' eachAv.Attribute_Values__c:'+eachAv.Attribute_Values__c);
                        if(opt.attrbOption[i].getValue() == eachAv.Attribute_Values__c)
                            //system.debug('222 Before exclude opt.attrbOption[i].getValue() :'+  opt.attrbOption[i].getValue()  +' eachAv.Attribute_Values__c:'+eachAv.Attribute_Values__c);  
                            //opt.attrbOption.remove(i);
                             // OptionList.remove(i);
                             ExcludeValues.add(eachAv.Attribute_Values__c);
                    }
                     
                }
                
            }
            //System.debug('ExcludeValues' +ExcludeValues +' opt.labelValueApi:'+opt.labelValueApi);
            If(ExcludeValues.size() > 0 )
            {
                 for(integer i=0;i< opt.attrbOption.Size();i++){
                     If(!ExcludeValues.contains(opt.attrbOption[i].getValue()))
                     {
                        OptionList.add(opt.attrbOption[i]);
                     }
                 }
                 opt.attrbOption.clear();
                opt.attrbOption.addall(OptionList);
                //System.debug(Logginglevel.info, 'OptionList' + OptionList);
            }
           
            //system.debug('After exclude'+'  opt.labelValueApi  :'+opt.labelValueApi+'  opt.attrbOption :'+opt.attrbOption);
            
        }
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
        debugString+='Lock Dependents';
        List<Attribute_Value__c> listAV = new List<Attribute_Value__c>();
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
        }    
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

        for(AttClassTemplateItem opt: AttClassTemplateItemList){
            //system.debug(' size opt.labelValueApi  :'+opt.labelValueApi+' = size :'+opt.attrbOption.size()+' <>option values'+opt.attrbOption);
            if(!Resume_Upgrade && !Product_Extension && !Mid_Contract && !Product_Conversion){
                opt.lockfield = false;
            }
            
            // unlock quaantity for bundles. Change requested by anush
            if(opt.attrbOption.size() == 2 && !Resume_Upgrade 
               && opt.labelValueApi!='Quantity__c'){
                   opt.lockfield = true;
                   //system.debug('opt.attrbOption size:'+opt.attrbOption[opt.attrbOption.size()-1].getValue()+'\n opt.templItemInput :'+opt.templItemInput);
                   if(opt.attrbOption[opt.attrbOption.size()-1].getValue() != null && opt.templItemInput != opt.attrbOption[opt.attrbOption.size()-1].getValue() && (opt.templItemInput == null || opt.templItemInput == 'Select One')){
                       opt.templItemInput = opt.attrbOption[opt.attrbOption.size()-1].getValue();
                   }
                   
               } 
            if(LineItem.Copy_Fields_From_Lead__c!=null
               && LineItem.Copy_Fields_From_Lead__c.contains(opt.labelValueApi))
            {
                opt.lockfield = true;
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
        //system.debug('in mid contract : contract end date:'+contrectEndDate+'  today Date'+currentDate);
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
        //system.debug('contractDurationstr '+contractDurationstr);

        for(AttClassTemplateItem atClass: AttClassTemplateItemList){
            if(atClass.labelValueApi  == 'Contract_Duration__c'){
                atClass.attrbOption.clear();
                atClass.attrbOption.add(new selectOption('None','None'));
                for(String key : contractDurationstr.split(',')){
                    atClass.attrbOption.add(new selectOption(key,key));
                }
                
            }
        }
    }
    
    // update the Attribute sellection to the line item.
    public PageReference updateProductAttributeValue(){
        Apttus_Config2__ProductAttributeValue__c pavObject = new Apttus_Config2__ProductAttributeValue__c(ID = pavObjectID);
        // date dateVar = null;
        if(Product_Extension){
            pavObject.put('APTS_Updated_From_Attributes_Page__c',true);
        }

        
        pavObject.put('Apttus_Config2__LineItemId__c',lineItemId);
        for(AttClassTemplateItem atClass: AttClassTemplateItemList){
            //System.debug('atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
            
            if(atClass.labelValuetype =='DATE'){// the attribute type is Date
                pavObject.put(atClass.labelValueApi, atClass.inputdate);
            }else if(atClass.labelValuetype =='DOUBLE'){// the attribute type is Double
                pavObject.put(atClass.labelValueApi, atClass.inputItemDOUBLE);
            }else if(atClass.labelValuetype =='MultiPicklist'){
                //Author Viraj Rana: I-229495
                // the attribute type is multipicklist
                //pavObject.put(atClass.labelValueApi, atClass.attrbOption);
                String strMultiSelect = '';
                for(String str : atClass.rightvalues){
                    strMultiSelect += str + '; ';
                }
                strMultiSelect = strMultiSelect.removeEnd('; ');
                //atClass.templItemInput = String.Valueof(pavObject.get(atClass.labelValueApi));
                pavObject.put(atClass.labelValueApi, strMultiSelect );
            }else{// the attribute type is picklist or String
                pavObject.put(atClass.labelValueApi, atClass.templItemInput); 
            }
            
        }//for
        /*
Attribute Debugger.
*/
        //pavObject.put('Attribute_Debugger__c',string.join(pardRuleIds,','));
        //System.debug('pavObject : '+pavObject);
        if(pavObjectID == null || pavObjectID ==''){
            insert pavObject;
            Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c (id = lineItemId,Apttus_Config2__AttributeValueId__c = pavObject.Id );  //Code Changes 28/10/2015
            update lineItem;
            
        }
        else 
            update pavObject;
        //System.debug('pavObject updated.');
        // for passing pavObject as a parameters to cascading constructor.
        pavObject1=pavObject;
        
        return null;
    } // End updateproductAttributevalue
    
    
    //dynamic picing code when Calculate price button on click.
    // this method will call the pricing web service and result is recived set the lineitem status to pendingstatus.
    public PageReference pricingcalls(){ 
        //system.debug('starting pricing code <> actionpollar :'+ actionpollar);
        //system.debug('configSO :'+configid+' <>prodLineItems :'+lineItemId);
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
    public List<AttClassTemplateItem> AttClassTemplateItemList  = new List<AttClassTemplateItem>();
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
    public Map<String,List<String>> controllingMap = new Map<String,List<String>>();
    public Map<String,List<String>> pardDependentMap = new Map<String,List<String>>();
    public Map<String,Attribute_Value__c> productAttributeValueMap = new Map<String,Attribute_Value__c>();
    public Map<Id,String> PARDAction = new Map<Id,String>();//map to maintain Action type of PARD records.
    public map<Id,Product_Attribute_Rule_Definitions__c> pardRulesById=new map<Id,Product_Attribute_Rule_Definitions__c>();
    public map<string,string> mapproposalInputValues=new map<string,string>();
    Apttus_Config2__ProductAttributeValue__c pavObject;
    //for passing as a parameter to cascading attribute constructor.
    Apttus_Config2__ProductAttributeValue__c pavObject1;
    map<Id,Attribute_Value__c> AttributeById_reevalMap=new map<Id,Attribute_Value__c>();
    map<Integer,Id> PardSequenceMap=new map<Integer,Id>();

    Apttus_Config2__LineItem__c lineItem;
    
    
    public List<AttClassTemplateItem> getAttClassTemplateItemList(){  
        return AttClassTemplateItemList;

    }   
    
    //this is the constructor
    Public BundleOptionAttributeExt1(ApexPages.StandardController controller){ 
        // get parameter values
        //ctrl = new Apttus_Config2.ProductAttributeDetailController2(controller);
        //debugString='';
        try{
            lineItemId = System.currentPageReference().getParameters().get('id');
            configRequestId =  System.currentPageReference().getParameters().get('configRequestId');
            lineItem = [select ID, Apttus_Config2__LineStatus__c,Copy_Fields_From_Lead__c,
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
                        Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Latest_End_Date__c,


                        Attributes_Defaulted__c
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
            // donot allow editing of attributes if the Line item status = Incremented or Amended or Renewed
               pavObject=[select id,name,country__c,
                        License_Duration__c,
                        Contract_Duration__c,
                        service_Duration__c,
                        Duration__c,
                       Fixed_Location__c  from Apttus_Config2__ProductAttributeValue__c where id=:pavObjectID];   
            
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
                        //system.debug('field name field[j]:'+field[j]);
                        Schema.DescribeFieldResult f = r.fields.getMap().get(field[j]).getDescribe();
                        fieldname.add(f.getLabel());// get field names
                        //system.debug(' field type: '+ f.getType());
                        //set datatype for field
                        if(f.getType() == Schema.DisplayType.PICKLIST) {
                            datatype.add('PICKLIST');  
                        }else if(f.getType() == Schema.DisplayType.DATE){
                            datatype.add('DATE');
                        }else if(f.getType() == Schema.DisplayType.DOUBLE){
                            datatype.add('DOUBLE');
                        }else if(f.getType() == Schema.DisplayType.STRING){
                            datatype.add('STRING'); 
                        }else if(f.getType() == Schema.DisplayType.MultiPicklist){             //Added On 10/10/2016 By Viraj
                            datatype.add('MultiPicklist'); 
                        }
                        
                        //system.debug('field[j] :'+field[j]+' fieldname:'+fieldname[j]+' type :'+datatype[j]);
                        

                        //Added On 10/07/2016 By Viraj Rana Start                        
                        String[] multiselected = new String[]{};
                        List<selectOption> lstOtionLeftSelected = new List<selectOption>();
                        List<selectOption> lstOtionRightSelected = new List<selectOption>();
                        Set<string> templeftvalues = new Set<String>();
                        Set<string> temprightvalues = new Set<String>();
                        
                        //End Variable Declaration for Multipicklist
                        
                        List<String> lstPickvals = new List<String>();
                        String orgpicklistval;
                        if(datatype[j] == 'PICKLIST'){
                            for (Schema.PicklistEntry a : F.getPicklistValues()) { //for all values in the picklist list
                                lstPickvals.add(a.getValue());//add the value  to our final list
                                //system.debug('fieldname[j]'+fieldname[j]+'a.getValue():'+a.getValue());
                                //system.debug('before orgpicklistval'+orgpicklistval);
                                if(string.isBlank(orgpicklistval)){orgpicklistval = a.getValue();}else{ orgpicklistval+=','+a.getValue();}
                                //system.debug('orgpicklistval'+orgpicklistval);
                            }//for
                            //system.debug('orgpicklistval'+orgpicklistval);

                        }else if(datatype[j] == 'MultiPicklist'){                 //Author Viraj Rana: I-229495
                            for (Schema.PicklistEntry a : F.getPicklistValues()) { //for all values in the picklist list
                                multiselected.add(a.getValue());//add the value  to our final list                                
                            }
                        }
                        
                        //if
                        AttClassTemplateItemList.add(new AttClassTemplateItem(fieldname[j],field[j],datatype[j],lstPickvals,multiselected,lstOtionLeftSelected,lstOtionRightSelected,templeftvalues,temprightvalues));
                        //adds value to the picklist
                        maporiginalatt.put(field[j],orgpicklistval);
                        // add values to field map <Apiname, fieldname>
                        fieldmap.put(fieldname[j],field[j]);
                        //system.debug('fieldmap :'+fieldmap);
                        
                        if(string.isBlank(fieldlist)){fieldlist = field[j];}else{ fieldlist+=','+field[j];}
                    }
                    //apexpages.addMessage(new apexpages.message(apexpages.severity.info,'Template list'+AttClassTemplateItemList.size()));
                    
                }catch(Exception e) { 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'product attribute fields issue'+e.getlineNumber()));
                    //System.debug(LoggingLevel.ERROR, 'cannot access DescribeFieldResult'); 
                } 
                
                if(!Mid_Contract || !Product_Extension || !Product_Conversion){ // if the Line Itme is Locked i:e status =Incremented or Amended or Renewed then dont do the controling dependent attribute 
                    
                    List<Product_Attribute_Rule_Definitions__c> prodPardList = new List<Product_Attribute_Rule_Definitions__c>();
                    List<Attribute_Value__c> attValues = new  List<Attribute_Value__c>();
                    Set<Id> avgIdSet = new Set<Id>();
                    // get all controlling and dependents records from PARD object for selected product.
                    
                    /*  prodPardList=  [SELECT Id,Name,
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
((Primary_Product__c =:OptionId  and Bundle_Product__c=null) 

or
(Primary_Product__c =:OptionId and Bundle_Product__c=: prodId)
)
order by Primary_Product__c,bundle_product__c nulls first,sequence__c];    */
                    
                    
                    prodPardList=[SELECT Id,Name,
                                  bundle_product__r.name,Primary_Product__r.name,
                                  Controlling_Attribute_Value_Group__c,
                                  Dependent_Attribute_Value_Group__c ,
                                  Hide__c,APTS_Required__c,
                                  Primary_Product__c,
                                  Action__c,
                                  sequence__c,
                                  Leading_Produc_Option__c,Leading_Product_Option_Group__c,
                                  active__c
                                  FROM Product_Attribute_Rule_Definitions__c 
                                  Where active__c=true and sequence__c>0 and 
                                  ((Primary_Product__c =:OptionId  and Product_Option_Group__c=null
                                    //and hide__c=false
                                   ) 
                                   or
                                   (Primary_Product__c =:OptionId and Product_Option_Group__c=: optionGroupId)
                                  )
                                  order by Primary_Product__c,Product_Option_Group__c nulls first,sequence__c];                                               
                  //  Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Rules Size'+prodPardList.size()));                        
                    
                    for(Product_Attribute_Rule_Definitions__c pd: prodPardList){

                        avgIdSet.add(pd.Controlling_Attribute_Value_Group__c);
                        PARDAction.put(pd.Id,pd.Action__c);
                        avgIdSet.add(pd.Dependent_Attribute_Value_Group__c);
                        pardRulesById.put(pd.id,Pd);
                        // PardSequenceMap.put(pd,);
                    }
                    
                    attValues = AttributeUtilityClass.getAttribueValueList(avgIdSet);
                    
                    
                    
                    String queryProposal;
                    
                    // prepare the query for proposal record based on attribute values
                    //system.debug(logginglevel.Info,'########' + attValues);
                    for(Attribute_Value__c att: attValues){
                        //system.debug(logginglevel.Info,'########' + att);
                        if(att.Attribute_Type__c == 'Product')
                            productAttributeValueMap.put(att.Id, att);
                        
                        if(att.Attribute_Type__c == 'Proposal'){
                            if(att.Attribute_Values__c.endsWith('__c') || att.Attribute_Values__c.endsWith('__r.Name')){
                                if(String.isBlank(queryProposal)){
                                    queryProposal = att.Attribute_Values__c;
                                } else {
                                    queryProposal = queryProposal + ',' + att.Attribute_Values__c;
                                }
                            } else if(!att.attribute_values__c.endsWith('__c') && !att.attribute_values__c.endsWith('__r.Name') && (att.Attributes_Name__c.endsWith('__c') || att.Attributes_Name__c.endsWithIgnoreCase('__r.Name'))){
                                if(String.isBlank(queryProposal)){
                                    queryProposal = att.Attributes_Name__c;
                                } else {
                                    queryProposal = queryProposal + ',' + att.Attributes_Name__c;
                                }   
                            }
                        }
                        //queryProposal = ' Pricing_Channel_Account__c ';
                        
                    }
                    
                    Apttus_Proposal__Proposal__c prodProposal = getProposal(queryProposal);
                    
                    //Preparing a map of attributes and attribute values for attribute type proposal.
                    for(Attribute_Value__c att: attValues){
                        if(att.Attribute_Type__c == 'Product'){
                            if(att.Attribute_Values__c.endsWith('__c')){
                                AttributeById_reevalMap.put(att.id,new Attribute_Value__c(Attribute_Type__c=att.Attribute_Type__c,
                                                                                          Attributes_Name__c=att.Attributes_Name__c,
                                                                                          Attribute_Values__c=att.Attribute_Values__c));
                                if(pavObject.get(att.Attribute_Values__c)!=null){ 
                                    att.Attribute_Values__c = String.valueOf(pavObject.get(att.Attribute_Values__c));
                                    //updateProductLocation=true;
                                }
                            }
                            productAttributeValueMap.put(att.Id, att);            
                        }
                        if(att.Attribute_Type__c == 'Proposal'){
                            if(att.Attribute_Values__c.endsWith('__c') || att.Attribute_Values__c.endsWith('__r.Name')){
                                if(att.Attribute_Values__c.endsWith('__c')){
                                    if(prodProposal.get(att.Attribute_Values__c) != null){
                                        att.Attribute_Values__c = String.valueOf(prodProposal.get(att.Attribute_Values__c));
                                        productAttributeValueMap.put(att.Id,att);
                                    }
                                }else if(att.Attribute_Values__c.endsWith('__r.Name')){
                                    String rvar = att.Attribute_Values__c;
                                    String obj = rvar.SubString(0,rvar.indexof('.'));
                                    String field = rvar.SubString(rvar.indexof('.') + 1,rvar.Length());
                                    //system.debug('obj :'+obj+' field  :'+ field +'(String)prodProposal.getSObject(obj).get(field)  :'+(String)prodProposal.getSObject(obj).get(field) );
                                    if((String)prodProposal.getSObject(obj).get(field) != null){
                                        String sValue = (String)prodProposal.getSObject(obj).get(field);
                                        att.Attribute_Values__c = sValue;
                                        productAttributeValueMap.put(att.Id,att);
                                    }
                                    
                                }
                                
                                
                            } else if(!att.attribute_values__c.endsWith('__c') && !att.attribute_values__c.endsWith('__r.Name') && (att.Attributes_Name__c.endsWith('__c') || att.Attributes_Name__c.endsWithIgnoreCase('__r.Name'))){
                                //controller proposal.
                                hascontrollerproposalheader = true;
                                if(att.Attributes_Name__c.endsWith('__c')){
                                    
                                    
                                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,':'+att.Attributes_Name__c+': att Id:'+ att.Id//+':'+prodProposal.get(att.Attributes_Name__c)));
                                    //system.debug('controlling proposal __c'+String.valueOf(prodProposal.get(att.Attributes_Name__c)).trim());
                                    //system.debug(' con value :'+att.Attribute_Values__c);
                                    
                                    if(prodProposal.get(att.Attributes_Name__c) != null && String.valueOf(prodProposal.get(att.Attributes_Name__c)).trim()!=null){
                                        productAttributeValueMap.put(att.Id,att);
                                        string svalue=String.valueOf(prodProposal.get(att.Attributes_Name__c)).trim();
                                        mapproposalInputValues.put(att.Attributes_Name__c,sValue);
                                    }
                                    else{
                                        Throw new AttributeException('Attribute'+att.Attributes_Name__c+'not found on proposal');
                                    }
                                    
                                } else {
                                    //system.debug(' in here __r');
                                    //system.debug('att.Attributes_Name__c  :'+ att.Attributes_Name__c);
                                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.error,':'+att.Attributes_Name__c
                                    //+':'+prodProposal.get(att.Attributes_Name__c)
                                    //                                           ));
                                    
                                    if(att.Attributes_Name__c.endsWithIgnoreCase('__r.Name')){
                                        String rvar = att.Attributes_Name__c;
                                        String obj = rvar.SubString(0,rvar.indexof('.'));
                                        String field = rvar.SubString(rvar.indexof('.') + 1,rvar.Length());
                                        //system.debug('obj :'+obj+' field  :'+ field +'(String)prodProposal.getSObject(obj).get(field)  :'+(String)prodProposal.getSObject(obj).get(field));
                                        
                                        //system.debug(' con value :'+att.Attribute_Values__c);
                                        if((String)prodProposal.getSObject(obj).get(field) != null){
                                            String sValue = (String)prodProposal.getSObject(obj).get(field);
                                            //att.Attribute_Values__c = sValue;
                                            productAttributeValueMap.put(att.Id,att);
                                            mapproposalInputValues.put(att.Attributes_Name__c,sValue);
                                        }
                                        else
                                            Throw new AttributeException('Price List values not found for pard');
                                        
                                        //productAttributeValueMap.put(att.Id,att);
                                       // system.debug('att.Attributes_Name__c  :'+att.Attributes_Name__c+'att.Attribute_Values__c  :'+att.Attribute_Values__c);
                                    }
                                }
                            }
                        } 
                    }
                    
                    

                    Map<String,String> pardAvgContMap = new Map<String,String>();
                    Map<String,String> pardAvgDepMap = new Map<String,String>();
                    
                    
                    Map<String,List<String>> attrbToValGroupMap = new Map<String,List<String>>();
                    
                    Set<Id> contAvgs = new Set<Id>();
                    Set<Id> depAvgs = new Set<Id>();
                    Set<Id> allAvgs = new Set<Id>();
                    Set<ID> allAttributes = new Set<Id>();
                    
                    for(Product_Attribute_Rule_Definitions__c pard: prodPardList){
                        if(pard.Controlling_Attribute_Value_Group__c != null){
                            contAvgs.add(pard.Controlling_Attribute_Value_Group__c);
                            depAvgs.add(pard.Dependent_Attribute_Value_Group__c);
                            pardAvgContMap.put(pard.Id, pard.Controlling_Attribute_Value_Group__c);
                            pardAvgDepMap.put(pard.Id, pard.Dependent_Attribute_Value_Group__c);
                        }
                        
                    }
                    
                    allAvgs.addAll(contAvgs);
                    allAvgs.addAll(depAvgs);
                    
                    //constructing a map of attribute group to attribute value
                    //map < attributegroup=> attributevalue list >
                    
                    //Viraj Rana Added order by condition
                    for(Attribute_Value_Group_Member__c gp: [SELECT Attribute_Value__c, Attribute_Value_Group__c From Attribute_Value_Group_Member__c Where Attribute_Value_Group__c IN:allAvgs order by Attribute_Value__c asc]){
                        allAttributes.add(gp.Attribute_Value__c);
                        if(attrbToValGroupMap.containsKey(gp.Attribute_Value_Group__c)){
                            attrbToValGroupMap.get(gp.Attribute_Value_Group__c).add(gp.Attribute_Value__c);
                        } else {
                            attrbToValGroupMap.put(gp.Attribute_Value_Group__c, new List<String>{gp.Attribute_Value__c});
                        }
                    }
                    
                    //map<Pard => controlling attribute values Ids>
                    // map<Pard=> Dependenet attribute values ids >
                    //system.debug(logginglevel.info , 'prodPardList' + prodPardList);
                    for(Product_Attribute_Rule_Definitions__c pard: prodPardList){
                        //system.debug(logginglevel.info , 'pard' + pard);
                        pardControllingMap.put(pard.Id, attrbToValGroupMap.get(pard.Controlling_Attribute_Value_Group__c));
                        pardDependentMap.put(pard.Id, attrbToValGroupMap.get(pard.Dependent_Attribute_Value_Group__c));
                    }
                    //system.debug(logginglevel.info , 'pardControllingMap' + pardControllingMap);
                    //system.debug(logginglevel.info , 'pardDependentMap' + pardDependentMap);
                    Set<String> contAttrValuesId = new Set<String>();
                    Map<String,String> attrbToPardIdMap = new Map<String,String>();
                    Map<String,String> attrbIdToNameMap = new Map<String,String>();
                    
                    
                    for(String pardId: pardControllingMap.keySet()){
                        //debugString+='@@pardId:'+pardId;
                        //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Test:'+pardId+': '+pardControllingMap.get(pardId)));
                        
                        contAttrValuesId.addAll(pardControllingMap.get(pardId));
                        for(String attrId: pardControllingMap.get(pardId)){
                            attrbToPardIdMap.put(attrId,pardId);

                        }
                    }
                    
                    for(Attribute_Value__c attribute: [SELECT Id, Attributes_Name__c, Attribute_Values__c, Attribute_Type__c from Attribute_Value__c Where Id IN: contAttrValuesId]){
                        
                        if(controllingMap.containsKey(attribute.Attributes_Name__c)){
                            controllingMap.get(attribute.Attributes_Name__c).add(attrbToPardIdMap.get(attribute.Id));              
                            
                            
                        } else {
                            controllingMap.put(attribute.Attributes_Name__c, new List<String>{attrbToPardIdMap.get(attribute.Id)});
                        }       
                    }
                    
                    //system.debug('controllingMap :'+controllingMap);
                    //system.debug('pardDependentMap  :'+pardDependentMap);
                    //system.debug('pardcontrollingMap  :'+pardcontrollingMap);
                    
                    
                    // end new code 
                    set<string> pardIdsset=new set<string>();
                    list<string> pardIdlist=new list<string>();
                    for(string key:controllingmap.keyset())
                    {
                        pardIdsset.addAll(controllingmap.get(key));
                        
                    }
                    //debugString+='@@'+pardIdsset.size()+''+pardIdsset;
                    
                } // end of linestatuslock;
            }//end ProdAttributeGroupmemberId.size() > 0 
            
            populatedefaults(fieldlist);
            //apexpages.addMessage(new apexpages.message(apexpages.severity.warning,'pavObject:'+pavObject));
            if(Resume_Upgrade){ // apply Resume_Upgrade conditions.
                ResumeUpgrade();
                
                
            }
        }
        catch(Exception ex)
        {
            apexpages.addMessage(new apexpages.message(apexpages.severity.error,'+Error:'+ex.getLinenumber()));
        }
        
    }//constructor
    
    // this method will set default values for the product attribute fields
    // will set the values of the attributes with the values that were saved ealier with.
    public void populatedefaults(String fieldlist){
        //system.debug('in populatedefaults  <>field list'+fieldlist);
        //Apttus_Config2__ProductAttributeValue__c pavObject;// = new Apttus_Config2__ProductAttributeValue__c(ID = pavObjectID);
        //system.debug('attribute value'+ pavObject);
        if(pavObjectID != null && pavObjectID != '' && !string.isBlank(fieldlist) && fieldlist != null){
            try{
                String qatt = 'SELECT '+fieldlist+' FROM Apttus_Config2__ProductAttributeValue__c WHERE Id =: pavObjectID';
                //system.debug('query attribute object:'+qatt);
                pavObject = Database.query(qatt);
                
                //for product name constrintrules
                pavObject.put('Product_Name__c',product.name);
            }catch(SObjectException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Attribute  field name Exception'));
                //System.debug('Error Attribute field Exception :'+ e);
            } 
            for(AttClassTemplateItem atClass: AttClassTemplateItemList){
                //system.debug('atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
                

                //Author Viraj Rana: I-229495 - MultiSelect field Change
                if(atClass.labelValuetype == 'MultiPicklist'){ 
                    if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                        List<String> arrMultiselected = String.Valueof(pavObject.get(atClass.labelValueApi)).split(';');
                        atClass.rightvalues = new Set<String>(arrMultiselected);
                        atClass.rightselected = arrMultiselected;
                        atClass.templItemInput = String.Valueof(pavObject.get(atClass.labelValueApi));
                    }
                }else if(atClass.labelValuetype == 'PICKLIST' || atClass.labelValuetype == 'STRING'){
                    //if(atClass.labelValueApi=='Product_Name__c')
                    //atClass.templItemInput ==''+product.name;
                    //system.debug(''+product.name);
                    if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                        atClass.templItemInput = (String)pavObject.get(atClass.labelValueApi);
                        //system.debug('atClass.templItemInput'+ atClass.templItemInput+'  pavObject.get(atClass.labelValueApi)'+ pavObject.get(atClass.labelValueApi));
                    }
                }else{//the attribute is a date
                    if(atClass.labelValuetype == 'DATE')
                        if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                            atClass.inputdate = (Date)pavObject.get(atClass.labelValueApi);
                        }
                    if(atClass.labelValuetype == 'DOUBLE')
                        if(pavObject.get(atClass.labelValueApi) != null && pavObject.get(atClass.labelValueApi) !=''){
                            decimal val = (DOUBLE)pavObject.get(atClass.labelValueApi);
                            //system.debug('value'+ val +'\n '+pavObject.get(atClass.labelValueApi));
                            atClass.inputItemDOUBLE = val.setScale(0);
                        }
                    
                }
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
        //system.debug('in ResumeUpgrade '+AssetLineItemId);
        /*Contract_Duration__c 
maporiginalatt<fieldsApi> <allpicklistvalue>
mapinputvalues <field Api name > < current selected value>
fieldmap <field name> <field Api name>*/
        if(AssetLineItemId !=null){
            String assetlist = 'Contract_Duration__c, Geography__c, Resume_License_Type__c';
            Apttus_Config2__AssetAttributeValue__c Assetval = getAssetAttributeValue(assetlist);
            //system.debug('Assetval'+Assetval);
            //system.debug('maporiginalatt :'+maporiginalatt.get('Contract_Duration__c') );
            if(Assetval !=null){
                for(AttClassTemplateItem atClass: AttClassTemplateItemList){
                    //System.debug('atClass.labelValue :'+atClass.labelValue+'  <>atClass.labelValueApi : '+atClass.labelValueApi + '<> atClass.templItemInput : ' + atClass.templItemInput+' <> atClass.inputdate'+ atClass.inputdate);
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
        //system.debug('AssetLineItemId  :'+AssetLineItemId+'  assetlist  :'+assetlist);
        if(!string.isBlank(assetlist) && AssetLineItemId != null )
        {
            try{
                /*String qAsset = 'SELECT '+assetlist+' FROM Apttus_Config2__AssetAttributeValue__c WHERE Apttus_Config2__AssetLineItemId__c =: AssetLineItemId';
system.debug('Assetattributevalue object:'+qAsset);
Apttus_Config2__AssetAttributeValue__c assetVar = Database.query(qAsset);*/
                List <Apttus_Config2__AssetAttributeValue__c> assetVar = [SELECT Contract_Duration__c, Geography__c, Resume_License_Type__c FROM Apttus_Config2__AssetAttributeValue__c WHERE Apttus_Config2__AssetLineItemId__c =: AssetLineItemId];
                if(assetVar.size() >0){
                    //System.debug('assetVar'+assetVar);
                    return(assetVar[0]);
                    
                }
                
                
            }catch(SObjectException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Asset Attribute Value field name Exception'));
                //System.debug('Error Asset Attribute Value field Exception :'+ e);
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
        //system.debug('ProposalId  :'+ProposalId+'  Proposalfields  :'+Proposalfields);
        if(!string.isBlank(Proposalfields) && ProposalId != null )
        {
            try{
                Proposalfields=getUniqueFields(Proposalfields);
                String qProposal = 'SELECT '+Proposalfields+' FROM Apttus_Proposal__Proposal__c WHERE Id =: ProposalId';
                //system.debug('proposal object:'+qProposal);
                Apttus_Proposal__Proposal__c proposal = Database.query(qProposal);
                //system.debug('proposal result:'+ proposal);
                return(proposal);
            }catch(SObjectException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'proposal field name Exception'));
                //System.debug('Error proposal field Exception :'+ e);
            }
        }
        return null;    
    }
    
    //Re-Evaluate AttributeValues
    //Venkata R Sabbella.
    // For revaluating the attributes based on user input.
    void reEvaluateAttributes()
    {
        //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+AttributeById_reevalMap.keyset().size()));            
        
        if(AttributeById_reevalMap.keyset().size()==0)
            return;
        for(Id attId:AttributeById_reevalMap.keyset()){
            Attribute_Value__c reevalatt=AttributeById_reevalMap.get(attId);
            Attribute_Value__c att=productAttributeValueMap.get(attId);
            
            if(reevalatt.Attribute_Values__c.endsWith('__c')){
                //AttributeById_reevalMap.put(att.id,att);
                //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+pavObject)); //.get(att.Attribute_Values__c)
                if(pavObject.get(reevalatt.Attribute_Values__c)!=null)
                { 
                    //apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'re-evaluation:'+pavObject.get(att.Attribute_Values__c)));           
                    att.Attribute_Values__c = String.valueOf(pavObject.get(reevalatt.Attribute_Values__c));
                    //updateProductLocation=true;
                }
            }
            productAttributeValueMap.put(att.Id, att);            
        }    
        return;
    }
    
    //Author Viraj Rana: I-229495: Build Multiselect Picklist for right Side
    public void selectclick(){
        String fieldAPIName = ApexPages.currentPage().getParameters().get('APIName');
        Integer intWrapperIndex = 0;
        Integer getIndexNo = 0;
        for(AttClassTemplateItem t: AttClassTemplateItemList){
            if(t.labelValueApi == fieldAPIName){
                intWrapperIndex = getIndexNo;
            }
            getIndexNo++;
        }
        
        
        AttClassTemplateItemList[intWrapperIndex].rightselected.clear();
        for(String s : AttClassTemplateItemList[intWrapperIndex].leftselected){
            AttClassTemplateItemList[intWrapperIndex].leftvalues.remove(s);
            AttClassTemplateItemList[intWrapperIndex].rightvalues.add(s);
        }
        
        AttClassTemplateItemList[intWrapperIndex].lstOtionLeftSelected = getunSelectedValues(AttClassTemplateItemList[intWrapperIndex].leftvalues);
        AttClassTemplateItemList[intWrapperIndex].lstOtionRightSelected  = getunSelectedValues(AttClassTemplateItemList[intWrapperIndex].rightvalues);
        Attchange();
        
    }
    
    //Author Viraj Rana: I-229495: Build Multiselect Picklist for left Side
    public void unselectclick(){
        
        String fieldAPIName = ApexPages.currentPage().getParameters().get('APIName');
        Integer intWrapperIndex = 0;
        Integer getIndexNo = 0;
        for(AttClassTemplateItem t: AttClassTemplateItemList){
            if(t.labelValueApi == fieldAPIName){
                intWrapperIndex = getIndexNo;
            }
            getIndexNo++;
        }
        
        AttClassTemplateItemList[intWrapperIndex].leftselected.clear();
        
        for(String s : AttClassTemplateItemList[intWrapperIndex].rightselected){
            AttClassTemplateItemList[intWrapperIndex].rightvalues.remove(s);
            AttClassTemplateItemList[intWrapperIndex].leftvalues.add(s);
        }
        
        AttClassTemplateItemList[intWrapperIndex].lstOtionLeftSelected = getunSelectedValues(AttClassTemplateItemList[intWrapperIndex].leftvalues);
        AttClassTemplateItemList[intWrapperIndex].lstOtionRightSelected = getunSelectedValues(AttClassTemplateItemList[intWrapperIndex].rightvalues);
        Attchange();
        
    }
    
    //Author Viraj Rana: I-229495: Build Multiselect Picklist for left Side
    public List<SelectOption> getunSelectedValues(Set<string> templeftvalues){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(templeftvalues);
        tempList.sort();
        for(string s : tempList){
            options.add(new SelectOption(s,s));
        }

        return options;
    }

    //Author Viraj Rana: I-229495: Build Multiselect Picklist for right Side
    public List<SelectOption> getSelectedValues(Set<string> temprightvalues){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(temprightvalues);
        tempList.sort();
        for(String s : tempList){
            options1.add(new SelectOption(s,s));
        }
        return options1;
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
        public Boolean required{get;set;}
        
        
        //Added On 10/18/2016 By Viraj Rana Start
        Public List<string> leftselected{get;set;}
        Public List<string> rightselected{get;set;}
        Public String[] multiselected{get;set;}
        public List<selectOption> lstOtionLeftSelected{get;set;}
        public List<selectOption> lstOtionRightSelected{get;set;}
        
        public Set<string> leftvalues{get;set;}
        public Set<string> rightvalues{get;set;}
        //End Variable Declaration for Multipicklist

            
        //This is the contructor method
        @TestVisible
        public AttClassTemplateItem(String label,String labelapi,String labletype,List<String> opt,String[] multiselectedValue,
                                    List<selectOption> tempOtionLeftSelected, List<selectOption> tempOtionRightSelected,
                                    Set<string> setleftvalues , Set<string>  setrightselected) {



            //system.debug('Test label:'+label);

            labelValue= label;
            labelValueApi = labelapi;
            labelValuetype = labletype;
            optList = opt;
            attrbOption = new List<selectOption>();
            templItemInput = templItemInput;
            lockfield = false;
            explicitLock=false;
            hidden=false;

            
            //Added On 10/18/2016 By Viraj Rana Start
            multiselected = multiselectedValue;
            lstOtionLeftSelected = tempOtionLeftSelected;
            lstOtionRightSelected = tempOtionRightSelected;
            leftselected = new list<String>();
            rightselected = new list<String>();
            leftvalues = setleftvalues;
            rightvalues = setrightselected;
            //End Variable Declaration for Multipicklist
            
        }
        @TestVisible
        public List<selectOption> getAttrbOption(){
            //system.debug('optList' + optList);
            if(attrbOption.isEmpty()){
                attrbOption.add(new selectOption('None','None'));
                for(String opVal : optList){
                    //system.debug(opVal);
                    attrbOption.add(new selectOption(opVal,opVal));
                }

                
            }   
            return attrbOption;
        }
    }
    
    public  class ProductAttributeValue implements Comparable {
       
        public decimal value;
        public Attribute_Value__c objAtt;
        
        // Constructor
        public ProductAttributeValue (decimal d, Attribute_Value__c  attr) {
            value = d;
            objAtt= attr;
        }
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            ProductAttributeValue  compareToAttr = (ProductAttributeValue)compareTo;
            if (value == compareToAttr.value) return 0;
            if (value > compareToAttr.value) return 1;
            return -1;        
        }
    }
}