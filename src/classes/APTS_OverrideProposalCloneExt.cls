/* 
* Class Name  : APTS_OverrideProposalCloneExt
* Description : Extension for APTS_OverrideProposalCloneExt
              : Incase of exception the quote will role back to old quote  
* Created By  : Viraj Rana
* Created On  : 11/25/2016
*
* Modification log:                                                                       
*/ 

global with sharing class APTS_OverrideProposalCloneExt{

    private final Apttus_Proposal__Proposal__c mysObject;
    public String sRecordId{get; private set;}
    public String sRetURL{get; private set;}
    public boolean DisplayError {get;set;}

    public list<Apttus_Proposal__Proposal__c> QProposalList = new List<Apttus_Proposal__Proposal__c>();
    public list<Apttus_Config2__ProductConfiguration__c> old_lProductConfiguration = new list <Apttus_Config2__ProductConfiguration__c>();    
    public string NewProductConfigIds{get; private set;}
    public string OldConfigID{get; private set;}
    public string NewProposalID{get; private set;}
    Public set<String> setRestrictedProfiles;
    public APTS_OverrideProposalCloneExt(ApexPages.StandardController stdController) {
        this.mysObject = (Apttus_Proposal__Proposal__c )stdController.getRecord();
        sRecordId = System.currentPagereference().getParameters().get('id');    
        DisplayError = false; 
    }
    
    //create a clone for the Quote and child objects like , Apttus_Config2__AppliedRuleInfo__c
    public PageReference init() {
        setRestrictedProfiles = new Set<String>{'CRM Team - Other','Sales Manager (APAC)',
                                                'Sales Manager (EU)','Sales Manager (NA)','Sales Operations (APAC)','Sales Operations (EU)',
                                                'Sales Operations (EU) TA','Sales Operations (NA)','Sales Operations (TA)','Sales Rep (APAC)',
                                                'Sales Rep (EU)','Sales Rep (NA)','Sales Rep - Agency (EU)','System Administrator','Telemarketing/Inbound'
                                                };
        
        list<Apttus_Config2__ProductConfiguration__c> lProductConfiguration = new list <Apttus_Config2__ProductConfiguration__c>();
        list<Id> lOLDProductConfiguration = new list <Id>();  
        string QuoteStatusBeforeCloning='';
        Apttus_Proposal__Proposal__c oProposal = new Apttus_Proposal__Proposal__c();
        
        CreateParentToChildDynamicQueryForQuoteProposal();
        
        if(QProposalList.size()>0){
             oProposal=QProposalList[0];
             
             //Added By Matt Request to clone the Proposal by Admin.
             
             
             //S-452973 : Modified By Viraj Rna.
             Set<String> invalidOppStage = new Set<String>{'Closed Lost','Rejected','Stage 4 - Won','Stage 5 - Verified by Finance'};             
             Set<String> setAllowProfileToClone = new Set<String>{'System Administrator'};
             
             for(User objUser: [Select id,name from User where Profile.Name not in :setAllowProfileToClone and Id=: UserInfo.getUserID()]){
                 if(invalidOppStage.Contains(oProposal.OpportunityStage__c)){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot clone proposal when opportunity Stage is : ' + oProposal.OpportunityStage__c + '.');
                        ApexPages.addMessage(myMsg);
                        DisplayError = true;
                        return null;
                 }
             }
             
             for(User objUser: [Select id,name from User where Profile.Name not in: setRestrictedProfiles and Id=: UserInfo.getUserID()]){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not enough access to clone proposal.');
                ApexPages.addMessage(myMsg);
                DisplayError = true;
                return null;
             }

        }
        
        
        
        Apttus_Proposal__Proposal__c oNewProposal = oProposal.clone(false,true); // Clones to create a new Proposal Record            
        String sProposalName = oProposal.Apttus_Proposal__Proposal_Name__c ;
       
        try{
        
            RecordType oRecordType = [SELECT id,Name from RecordType where SobjectType= 'Apttus_Proposal__Proposal__c' AND Name='Proposal' AND isActive=true];
            
            oNewProposal.Apttus_QPApprov__Approval_Status__c=null;                    
            oNewProposal.Apttus_Proposal__Proposal_Expiration_Date__c=null;
            oNewProposal.Apttus_Proposal__Proposal_Approval_Date__c=null;
            oNewProposal.RecordTypeId = oRecordType.Id;
            oNewProposal.Apttus_QPConfig__PONumber__c='';
            oNewProposal.Clone_Indicator__c = oProposal.ID;
            QuoteStatusBeforeCloning=oNewProposal.Apttus_Proposal__Approval_Stage__c;
            
            if(oNewProposal.Apttus_Proposal__Approval_Stage__c=='In Review')
                oNewProposal.Apttus_Proposal__Approval_Stage__c='Approval Required';
            else
                oNewProposal.Apttus_Proposal__Approval_Stage__c='Draft';
            
            // Don't Copy Order Created and Freight Fields 
            oNewProposal.Apttus_QPConfig__AutoActivateOrder__c = false;
            
            //ApttusProposalTriggerHandler.ExecuteTriggers  = false;
            ApttusProposalTriggerHandler.IsTriggerForCloneProposal = true;
            insert oNewProposal;
            ApttusProposalTriggerHandler.IsTriggerForCloneProposal = false;
            
            /*oNewProposal.AccountOrganization__c = oProposal.AccountOrganization__c; 
            oNewProposal.Payment_Method1__c = oProposal.Payment_Method1__c; 
            oNewProposal.Apttus_Proposal__Payment_Term__c = oProposal.Apttus_Proposal__Payment_Term__c; 
            oNewProposal.Apttus_QPConfig__PaymentTermId__c = oProposal.Apttus_QPConfig__PaymentTermId__c;
            oNewProposal.Payment_Discount__c = oProposal.Payment_Discount__c; 
            oNewProposal.Billing_Account_DD_Discount__c = oProposal.Billing_Account_DD_Discount__c;
            oNewProposal.Non_Standard_Payment_Request__c = oProposal.Non_Standard_Payment_Request__c;
            oNewProposal.PaymentTypeDetails__c = oProposal.PaymentTypeDetails__c;
            oNewProposal.True_Term__c = oProposal.True_Term__c;
            oNewProposal.Installment__c = oProposal.Installment__c;
            oNewProposal.OwnerId = oProposal.Apttus_Proposal__Account__r.OwnerID;

            
            //ApttusProposalTriggerHandler.ExecuteTriggers  = false;*/
            //update oNewProposal;
            
            
            System.debug('oNewProposal' + oNewProposal.Payment_Method1__c);
            //ApttusProposalTriggerHandler.ExecuteTriggers  = true;            
            
            NewProposalID = oNewProposal.Id;
            
            for (Apttus_Config2__ProductConfiguration__c oProductConfiguration: old_lProductConfiguration){
                Apttus_Config2__ProductConfiguration__c oNewProductConfiguration = oProductConfiguration.clone(false,true);
                oNewProductConfiguration.Apttus_QPConfig__Proposald__c = oNewProposal.Id;
                oNewProductConfiguration.Apttus_Config2__BusinessObjectId__c= oNewProposal.Id;
                oNewProductConfiguration.Name= 'Product Config -'+oNewProposal.Apttus_Proposal__Proposal_Name__c;
                
                if(QuoteStatusBeforeCloning=='In Review'){
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Preview_Status__c='Pending';
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Status__c='Approval Required';
                }
                else{
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Preview_Status__c='Pending';
                    oNewProductConfiguration.Apttus_CQApprov__Approval_Status__c='Approval Required';
                }
                oNewProductConfiguration.Apttus_Config2__Status__c='Saved';
                lProductConfiguration.add(oNewProductConfiguration);
                lOLDProductConfiguration.add(oProductConfiguration.Id);
                OldConfigID = oProductConfiguration.Id;
            }
            // New Product Config Inserted.
            if(lProductConfiguration.size() > 0){
                insert lProductConfiguration;
                NewProductConfigIds = lProductConfiguration[0].Id;
                
                //Description: Copy Applied rule info from parent Quote during cloning.
                Apttus_Config2__AppliedRuleInfo__c appldRuleInfoInstance;
                list<Apttus_Config2__AppliedRuleInfo__c> InsertListRecs = new list<Apttus_Config2__AppliedRuleInfo__c>();
    
                for(Apttus_Config2__AppliedRuleInfo__c AppldRuleInfo_Rec : [Select Id, Name, Apttus_Config2__ConfigurationId__c, Apttus_Config2__ConstraintRuleId__c, Apttus_Config2__CriteriaFields__c, Apttus_Config2__HasCriteriaInCondition__c, Apttus_Config2__Invalid__c, Apttus_Config2__IsSourceLineRequired__c, Apttus_Config2__MatchInLocation__c, Apttus_Config2__NeedProcessing__c, Apttus_Config2__PrimaryLineNumber__c, Apttus_Config2__SourceLineNumber__c, Apttus_Config2__WasFinalized__c from Apttus_Config2__AppliedRuleInfo__c where Apttus_Config2__ConfigurationId__c =: OldConfigID]){
                    appldRuleInfoInstance = new Apttus_Config2__AppliedRuleInfo__c();                
                    appldRuleInfoINstance.Name = AppldRuleInfo_Rec.id;
                    appldRuleInfoINstance.Apttus_Config2__ConfigurationId__c=NewProductConfigIds ;
                    appldRuleInfoINstance.Apttus_Config2__ConstraintRuleId__c=AppldRuleInfo_Rec.Apttus_Config2__ConstraintRuleId__c;
                    appldRuleInfoINstance.Apttus_Config2__CriteriaFields__c=AppldRuleInfo_Rec.Apttus_Config2__CriteriaFields__c;
                    appldRuleInfoINstance.Apttus_Config2__HasCriteriaInCondition__c=TRUE;
                    appldRuleInfoINstance.Apttus_Config2__Invalid__c=FALSE;
                    appldRuleInfoINstance.Apttus_Config2__IsSourceLineRequired__c=FALSE;
                    appldRuleInfoINstance.Apttus_Config2__MatchInLocation__c=FALSE;
                    appldRuleInfoINstance.Apttus_Config2__NeedProcessing__c=TRUE;
                    appldRuleInfoINstance.Apttus_Config2__WasFinalized__c=FALSE;                
                    appldRuleInfoINstance.Apttus_Config2__PrimaryLineNumber__c=AppldRuleInfo_Rec.Apttus_Config2__PrimaryLineNumber__c;
                    appldRuleInfoINstance.Apttus_Config2__SourceLineNumber__c=AppldRuleInfo_Rec.Apttus_Config2__SourceLineNumber__c;
                    InsertListRecs.add(appldRuleInfoINstance);
                }
                insert InsertListRecs;
            }
            
        }catch(DmlException ex){
            if(StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY == ex.getDmlType(0)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not a member of opportunity team or you do not have access to clone this quote.');
                ApexPages.addMessage(myMsg);
                DisplayError = true;
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage());
                ApexPages.addMessage(myMsg);
                DisplayError = true;
            }
        }
        return null;               
    }
    
    //create a clone of the Apttus_Config2__TempObject__c and Apttus_Config2__SummaryGroup__c child objects 
   @RemoteAction
   global static string CloneChildRecords(String NewProductConfigIds,String OldConfigID,String NewProposalID){
       try {
            
            list<Apttus_Config2__TempObject__c> lTempObjectCPQ = new list<Apttus_Config2__TempObject__c>();
            list<Apttus_Config2__SummaryGroup__c> lSummaryGroup = new list<Apttus_Config2__SummaryGroup__c>();
            
            
            // we are passing the object API name to our custom method to get all the fields API Name
            string QueryStringFrTempObj='select '+ObjectFields('Apttus_Config2__TempObject__c')+' from Apttus_Config2__TempObject__c where Apttus_Config2__ConfigurationId__c =: OldConfigID';
            List<Apttus_Config2__TempObject__c> oTempObjectCPQLst = new List <Apttus_Config2__TempObject__c>();
            oTempObjectCPQLst = Database.query(QueryStringFrTempObj);
            for(Apttus_Config2__TempObject__c oTempObjectCPQ: oTempObjectCPQLst ){
                Apttus_Config2__TempObject__c oNewTempObjectCPQ = oTempObjectCPQ.clone(false,true);
                oNewTempObjectCPQ.Apttus_Config2__ConfigurationId__c = NewProductConfigIds;
                lTempObjectCPQ.add(oNewTempObjectCPQ);
            }
            // New Line Item Inserted
            insert lTempObjectCPQ;

            // we are passing the object API name to our custom method to get all the fields API Name
            string QueryStringFrSummaryGroup='select '+ObjectFields('Apttus_Config2__SummaryGroup__c')+' from Apttus_Config2__SummaryGroup__c where Apttus_Config2__ConfigurationId__c =: OldConfigID';
            List <Apttus_Config2__SummaryGroup__c> summaryGroupLst = new List <Apttus_Config2__SummaryGroup__c>();
            summaryGroupLst = Database.query(QueryStringFrSummaryGroup);
            for(Apttus_Config2__SummaryGroup__c oSummaryObject :summaryGroupLst){ 
                Apttus_Config2__SummaryGroup__c oNewSummaryGroup = oSummaryObject.clone(false,true);
                oNewSummaryGroup.Apttus_Config2__ConfigurationId__c = NewProductConfigIds;
                lSummaryGroup.add(oNewSummaryGroup);
            }        
            // New Summary Group inserted
            insert lSummaryGroup;
       }
       Catch(Exception ex)
       {
           return 'Exception:' + ex.getMessage(); 
       }
       return 'done';
   } 
   
    //create a clone of the Apttus_Proposal__Proposal_Line_Item__c,Apttus_Config2__ProductAttributeValue__c
    //Apttus_Config2__LineItem__c and Apttus_QPConfig__ProposalProductAttributeValue__c child objects 
   @RemoteAction
   global static string ClonLineItemRecords(String NewProductConfigIds,String OldConfigID,String NewProposalID,String OldProposalID){
       try {
            
            Map<String,Apttus_Proposal__Proposal_Line_Item__c > mapProposalLineItem = new Map<String,Apttus_Proposal__Proposal_Line_Item__c >();     
            Map<String,Apttus_Config2__ProductAttributeValue__c> mapPAV= new Map<String,Apttus_Config2__ProductAttributeValue__c>();     
            
            Map<String,Apttus_Config2__LineItem__c> mapLineItem = new Map<String,Apttus_Config2__LineItem__c>();     
            Map<String,Apttus_QPConfig__ProposalProductAttributeValue__c> mapPPAV = new Map<String,Apttus_QPConfig__ProposalProductAttributeValue__c>();     
            
            string QueryStringFrLineItem='select '+ObjectFields1('Apttus_Config2__LineItem__c')+',Apttus_Config2__ProductId__r.IsActive, ' + 
                                         ' Apttus_Config2__OptionId__r.IsActive from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: OldConfigID';
                                         
            for(Apttus_Config2__LineItem__c oLineItem: Database.query(QueryStringFrLineItem)){  
                
                boolean CreateLineItem = false;
                if(String.isEmpty(oLineItem.Apttus_Config2__OptionId__c) && !String.isEmpty(oLineItem.Apttus_Config2__ProductId__c)){
                    if(oLineItem.Apttus_Config2__ProductId__r.IsActive == True ){
                        CreateLineItem = True;
                    }
                }else if(!String.isEmpty(oLineItem.Apttus_Config2__OptionId__c) && !String.isEmpty(oLineItem.Apttus_Config2__ProductId__c)){
                    if(oLineItem.Apttus_Config2__ProductId__r.IsActive == True  && oLineItem.Apttus_Config2__OptionId__r.IsActive == True ){
                        CreateLineItem = True;
                    }
                }
                
                if(CreateLineItem){    
                    Apttus_Config2__LineItem__c oNewLineItem = oLineItem.clone(false, true);
                    oNewLineItem.Apttus_Config2__ConfigurationId__c = NewProductConfigIds;
                    mapLineItem.put(oLineItem.Id,oNewLineItem); 
                    
                }
            }
            if(mapLineItem.size() > 0){
                    Insert mapLineItem.Values();
                    Set<String> keys = mapLineItem.keySet(); 
                    
                    String FinalProductAttributeString = 'select '+ ObjectFields('Apttus_Config2__ProductAttributeValue__c') +' from Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c In : keys ';
                    
                    List<Apttus_Config2__ProductAttributeValue__c> lstNewPAV = new List<Apttus_Config2__ProductAttributeValue__c>();
                     
                    for(Apttus_Config2__ProductAttributeValue__c objPAV : Database.query(FinalProductAttributeString )){                
                        if(mapLineItem.Containskey(objPAV.Apttus_Config2__LineItemId__c)){
                            Apttus_Config2__ProductAttributeValue__c oNewPPV = objPAV.clone(false, true);
                            oNewPPV.Apttus_Config2__LineItemId__c = mapLineItem.get(objPAV.Apttus_Config2__LineItemId__c).Id;
                            mapPAV.Put(oNewPPV.Apttus_Config2__LineItemId__c ,oNewPPV); 
                        }
                    }
                    Insert mapPAV.Values();
                    
                    for(String key : mapLineItem.keyset()){
                        if(mapPAV.Containskey(mapLineItem.get(key).Id)){
                            mapLineItem.get(key).Apttus_Config2__AttributeValueId__c =  mapPAV.get(mapLineItem.get(key).Id).ID;
                        }
                    }
                    update mapLineItem.Values();           
                    
                    
                    String FinalProposalLineItemQueryString = 'select '+ ObjectFields('Apttus_Proposal__Proposal_Line_Item__c') +',Apttus_Proposal__Product__r.IsActive,Apttus_QPConfig__OptionId__r.IsActive from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =: OldProposalID';
                    List<Apttus_Proposal__Proposal_Line_Item__c> old_lProposalLineItem = Database.query(FinalProposalLineItemQueryString);
                
                    for(Apttus_Proposal__Proposal_Line_Item__c oProposalLineItem: old_lProposalLineItem){
                        boolean CreateLineItem = false;
                        if(String.isEmpty(oProposalLineItem.Apttus_QPConfig__OptionId__c) && !String.isEmpty(oProposalLineItem.Apttus_Proposal__Product__c)){
                            if(oProposalLineItem.Apttus_Proposal__Product__r.IsActive == True ){
                                CreateLineItem = True;
                            }
                        }else if(!String.isEmpty(oProposalLineItem.Apttus_QPConfig__OptionId__c) && !String.isEmpty(oProposalLineItem.Apttus_Proposal__Product__c)){
                            if(oProposalLineItem.Apttus_Proposal__Product__r.IsActive == True  && oProposalLineItem.Apttus_QPConfig__OptionId__r.IsActive == True ){
                                CreateLineItem = True;
                            }
                        }
                        if(CreateLineItem){
                            Apttus_Proposal__Proposal_Line_Item__c oNewProposalLineItem = oProposalLineItem.clone(false,true);
                            oNewProposalLineItem.Apttus_Proposal__Proposal__c = NewProposalID;
                            if(mapLineItem.Containskey(oProposalLineItem.Apttus_QPConfig__DerivedFromId__c)){
                                oNewProposalLineItem.Apttus_QPConfig__DerivedFromId__c = mapLineItem.get(oProposalLineItem.Apttus_QPConfig__DerivedFromId__c).Id;
                            }
                            mapProposalLineItem.put(oProposalLineItem.Id,oNewProposalLineItem);
                        }
                    }        
                    insert mapProposalLineItem.values();
                    
                    keys = mapProposalLineItem.keySet(); 
                    
                    String FinalProductAttributeValueString = 'Select '+ ObjectFields('Apttus_QPConfig__ProposalProductAttributeValue__c')  +
                                                              ' from Apttus_QPConfig__ProposalProductAttributeValue__c where Apttus_QPConfig__LineItemId__c in : keys';
                    
                    List<Apttus_QPConfig__ProposalProductAttributeValue__c> lstNewPPAV = new List<Apttus_QPConfig__ProposalProductAttributeValue__c>();
                     
                    for(Apttus_QPConfig__ProposalProductAttributeValue__c objPPAV : Database.query(FinalProductAttributeValueString)){                
                        if(mapProposalLineItem.Containskey(objPPAV.Apttus_QPConfig__LineItemId__c)){
                            Apttus_QPConfig__ProposalProductAttributeValue__c  oNewPPAV = objPPAV.clone(false, true);
                            oNewPPAV.Apttus_QPConfig__LineItemId__c= mapProposalLineItem.get(objPPAV.Apttus_QPConfig__LineItemId__c).Id;
                            mapPPAV.Put(oNewPPAV.Apttus_QPConfig__LineItemId__c,oNewPPAV); 
                        }
                    }
                    Insert mapPPAV.Values();
                    System.debug(logginglevel.Info,'mapPPAVmapPPAV' + mapPPAV);
                    for(String key : mapProposalLineItem.keyset()){
                        System.debug(logginglevel.Info,'key ' + key );
                        System.debug(logginglevel.Info,'mapProposalLineItem.get(key).Id' + mapProposalLineItem.get(key).Id);
                        if(mapPPAV.Containskey(mapProposalLineItem.get(key).Id)){
                            mapProposalLineItem.get(key).Apttus_QPConfig__AttributeValueId__c =  mapPPAV.get(mapProposalLineItem.get(key).Id).ID;
                        }
                    }
                   
                    update mapProposalLineItem.Values();
            }
       }
       Catch(Exception ex)
       {
           return 'Exception:' + ex.getMessage(); 
       }
       return 'done';
   
   }   
    
    /***************************************************************************************************************************************
    * Method Name: CreateParentToChildDynamicQueryForQuoteProposal
    * Description: Below Method is used to generate the dynamic query for Apttus_Proposal__Proposal__c
    * Return Type: string.
    ***************************************************************************************************************************************/
    public void CreateParentToChildDynamicQueryForQuoteProposal(){        

        string FinalQuoteQueryString='';
        string FinalProposalLineItemQueryString='';
        string FinalProductConfigQueryString='';

        try{
            
            string FieldsFrQuoteProposal = ObjectFields('Apttus_Proposal__Proposal__c');   
            string FieldsFrProductConfiguration = ObjectFields('Apttus_Config2__ProductConfiguration__c');
            
            FinalQuoteQueryString = 'Select '+FieldsFrQuoteProposal+' , Apttus_Proposal__Account__r.OwnerId from Apttus_Proposal__Proposal__c where id =: sRecordId';
            QProposalList = Database.query(FinalQuoteQueryString);

            FinalProductConfigQueryString = 'select '+FieldsFrProductConfiguration+' from Apttus_Config2__ProductConfiguration__c where Apttus_QPConfig__Proposald__c =: sRecordId order by Apttus_Config2__VersionNumber__c desc limit 1';
            old_lProductConfiguration = Database.query(FinalProductConfigQueryString);

        }
        catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('________Exception in CreateParentToChildDynamicQueryForQuoteProposal Method of APTS_OverrideProposalCloneExt__________________'+e.getMessage());
        }
    }
    
    
    /***************************************************************************************************************************************
    * Method Name: ObjectFields
    * Description: Getting the fields from object
    * Return Type: string.
    ***************************************************************************************************************************************/
    global static String ObjectFields(String ObjectNameval){
        try{
            string fieldsVal = '';
            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();       
            Set<String> fieldSet = fields.keySet();     
            for(string f : fieldSet){
                fieldsVal += f +',';
            }   
            if(fieldsVal.endsWith(','))
                fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
            return fieldsVal;
        }catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('________Exception in ObjectFields Method of APTS_OverrideProposalCloneExt__________________'+e.getMessage());
            return null;
        }
        return null;
    }
    
    static String ObjectFields1(String ObjectNameval){
        try{
            string fieldsVal = '';
            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectNameval);
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> fields = objDef.fields.getMap();       
            Set<String> fieldSet = fields.keySet();     
            for(string f : fieldSet){
                fieldsVal += f +',';
            }   
            if(fieldsVal.endsWith(','))
                fieldsVal= fieldsVal.substring(0,fieldsVal.length()-1);
            return fieldsVal;
        }catch(Exception e){
            ApexPages.addMessages(e);
            system.debug('________Exception in ObjectFields Method of APTS_OverrideProposalCloneExt__________________'+e.getMessage());
            return null;
        }
        return null;
    }
            
    Public PageReference  doCancel(){
        String Url = '/'+ sRecordId ;
        PageReference oPage = new PageReference(Url);
        oPage.setRedirect(True);
        return oPage;
    }
}