global class APTS_CartApprovalController { 
    public String ProposalId{get; set;}
    public String cartId{get; set;}    
    public String RequestId{get; set;} 
    Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfTermApprovalLineItems{get; set;}    
    
    public string getinstanceurl()
    {
        return Apttus_Approval__ApprovalsSystemProperties__c.getvalues('System Properties').Apttus_Approval__InstanceUrl__c;
    }
    
    public APTS_CartApprovalController()
    {
        
    }
    
    public boolean getshowflag()
    {
        boolean bFlag=true;
        Apttus_Approval__Approval_Request__c OApproval = getApprovalRecord();
        if(OApproval.Apttus_Approval__Approval_Status__c == 'Cancelled' || OApproval.Apttus_Approval__Approval_Status__c == 'Rejected')
        {
            bFlag = False;
        }
        return bFlag;
    }
    
    public boolean getNotifyflag()
    {
        boolean bFlag=true;
        Apttus_Approval__Approval_Request__c OApproval = getApprovalRecord();
        if(OApproval.Apttus_Approval__Approval_Status__c == 'Cancelled' || OApproval.Apttus_Approval__Approval_Status__c == 'Rejected' || OApproval.Apttus_Approval__Approval_Status__c == 'Notified')
        {
            bFlag = False;
        }
        return bFlag;
    }
    
    public Apttus_Config2__ProductConfiguration__c getprodConfig1()
    { 
        System.debug('MS TEST'+cartId);
        
        Apttus_Config2__ProductConfiguration__c prodConfig1 = [select id,   
                                                               name,
                                                               Apttus_QPConfig__Proposald__c ,APTS_Net_Total_With_Tax__c,
                                                               Apttus_QPConfig__Proposald__r.AccountID__c
                                                               from 
                                                               Apttus_Config2__ProductConfiguration__c
                                                               where id = :cartId];
        System.debug('MS TEST'+prodConfig1);
        return prodConfig1;
    }
    
    public Apttus_Proposal__Proposal__c getproposalSO()        
    {
        Apttus_Config2__ProductConfiguration__c oConfig =  getprodConfig1();
        Apttus_Proposal__Proposal__c oProp = [select 
                                              id,
                                              name,
                                              CurrencyIsoCode,                                              
                                              // Quote_Total__c - Commented due to I-191155
                                              Net_Total__c,
                                              APTS_Quote_Type__c,
                                              Gross_Total_with_tax__c,
                                              Quote_Total_With_Tax__c,
                                              Earliest_Start_Date__c,
                                              NetOrderAmount__c,
                                              Latest_End_Date__c,
                                              LatestProdEndDt__c,
                                              TotalDiscount__c,                                              
                                              Quote_Total_Decimal__c,
                                              AccountOrganization__c,
                                              APTPS_Contract_Start_Date__c,
                                              Contract_Category__c,
                                              BillingStartDt__c,
                                              Payment_Method1__c,
                                              PaymentTypeDetails__c,
                                              Apttus_Proposal__Description__c,
                                              Approval_Comments__c,
                                              Payment1_Term__c,
                                              Payment1_Frequency__c,
                                              Conversion_Proposal__c //I-213467 changes
                                              from 
                                              Apttus_Proposal__Proposal__c 
                                              where id =:oConfig.Apttus_QPConfig__Proposald__c]; 
        return oProp;
    } 
    Public List<Apttus_Proposal__Proposal_Line_Item__c> GetListOfProposalLineItems(){
        
        List<Apttus_Proposal__Proposal_Line_Item__c> ListOfProposalLineItems=new List<Apttus_Proposal__Proposal_Line_Item__c>();
        
        ListOfProposalLineItems=[Select Apttus_Proposal__Quantity__c, 
                                 Apttus_Proposal__Unit_Price__c, 
                                 Apttus_Proposal__Sales_Discount__c,
                                 Apttus_Proposal__Ext_Net_Price__c,
                                 Apttus_Proposal__Description__c,
                                 Apttus_Proposal__Unit_Net_Price__c,
                                 Id, 
                                 Name,                  
                                 APTS_Attribute_Display__c,
                                 Apttus_QPConfig__Term__c, Apttus_QPConfig__PriceUom__c ,
                                 Apttus_QPConfig__Quantity2__C, 
                                 Apttus_QPConfig__ExtendedPrice__c,               
                                 Apttus_QPConfig__ItemSequence__c,
                                 Apttus_QPConfig__LineType__c,
                                 Apttus_QPConfig__ChargeType__c,
                                 Apttus_QPConfig__NetPrice__c
                                 //,Budget__c
                                 from Apttus_Proposal__Proposal_Line_Item__c
                                 Where Apttus_Proposal__Proposal__c=:ProposalID];
        
        return ListOfProposalLineItems;
        
    }
    
    
    public Account getAccountObj()
    {
        
        Apttus_Config2__ProductConfiguration__c oConfig =   getprodConfig1();
        Account  oAccount = [select id, name, owner.name
                             FROM Account  
                             WHERE id = :oConfig.Apttus_QPConfig__Proposald__r.AccountID__c];
        
        return oAccount ;
        
    }
    
    public Apttus_Approval__Approval_Request__c getApprovalRequestObj()
    {
        return [select id, 
                ApprovalAction__c,
                Apttus_Approval__Request_Comments__c,
                Apttus_Approval__Assigned_To_Id__c,                
                Apttus_Approval__Date__c,
                Apttus_Approval__Action__c,
                Apttus_Approval__CanEscalate__c,
                Apttus_Approval__DateAssigned__c,
                Apttus_Approval__Approval_Status__c,
                Apttus_Approval__Approver_Comments__c,
                Apttus_Approval__Assigned_To_Name__c,
                Apttus_Approval__SubmissionComment1__c
                from  
                Apttus_Approval__Approval_Request__c 
                where id = :RequestId];
    }
    
    //Updated By Viraj For the request I-231580 : Tracking Issue for S-420008 - Discount/NSSA Approval Email Content Update - Next Steps.
    Public List<wrapperConfigLineItems> GetListExistingLineItem() {
        Map<Id,Apttus_Config2__LineItem__c> mapLineItems=new Map<Id,Apttus_Config2__LineItem__c>([Select
                                                           Apttus_Config2__LineType__c,
                                                           Apttus_Config2__ChargeType__c,
                                                           APTS_Product_Name__c,
                                                           Apttus_Config2__Quantity__c,
                                                           Net_Unit_Price__c,
                                                           Net_Total__c,                                                           
                                                           Apttus_Config2__StartDate__c,
                                                           Apttus_Config2__EndDate__c,
                                                           Apttus_Config2__Guidance__c,
                                                           Apttus_Config2__ProductId__c,
                                                           Apttus_Config2__Comments__c
                                                           from Apttus_Config2__LineItem__c
                                                           Where Apttus_Config2__ConfigurationId__c =:cartId  ANd
                                                           Apttus_Config2__LineStatus__c = 'Converted'
                                                           AND Apttus_Config2__LineType__c = 'Product/Service'
                                                           AND Apttus_Config2__IsPrimaryLine__c = True]);
        List<wrapperConfigLineItems> lstWrapper = getAllLineAttributeValue(mapLineItems);
        return lstWrapper;
    }
    
    
    public boolean getProductConversion()
    {
        Apttus_Proposal__Proposal__c oProposal = getproposalSO();  
        If(oProposal.Conversion_Proposal__c || oProposal.APTS_Quote_Type__c =='Product Conversion')//I-213467 changes
        {
            return true;
        }
        return false;
    }
    
    //Updated By Viraj For the request I-231580 : Tracking Issue for S-420008 - Discount/NSSA Approval Email Content Update - Next Steps.
    Public List<wrapperConfigLineItems> GetListNewLineItem() {
        Map<Id,Apttus_Config2__LineItem__c> mapLineItems= new Map<Id,Apttus_Config2__LineItem__c>([Select  Apttus_Config2__LineType__c,
                                                           Apttus_Config2__ChargeType__c,
                                                           APTS_Product_Name__c,
                                                           Apttus_Config2__Quantity__c,
                                                           Net_Unit_Price__c,
                                                           Net_Total__c,
                                                           Apttus_Config2__StartDate__c,
                                                           Apttus_Config2__EndDate__c,
                                                           Apttus_Config2__Guidance__c,
                                                           Apttus_Config2__BasePrice__c,
                                                           Apts_Discount_del__c,
                                                           Apttus_Config2__ProductId__c,
                                                           Apttus_Config2__NetAdjustmentPercent__c,
                                                           Gross_Unit_Price__c,
                                                           APTS_Extended_List_Price__c,
                                                           Apttus_Config2__NetPrice__c,
                                                           Apttus_Config2__Comments__c
                                                           from Apttus_Config2__LineItem__c
                                                           Where Apttus_Config2__ConfigurationId__c =:cartId  ANd
                                                           Apttus_Config2__LineStatus__c <> 'Converted'
                                                           AND Apttus_Config2__LineType__c = 'Product/Service'
                                                           AND Apttus_Config2__IsPrimaryLine__c = True]) ;

        List<wrapperConfigLineItems> lstWrapper = getAllLineAttributeValue(mapLineItems);
        return lstWrapper;
    }
    /*
Public List<Apttus_Config2__LineItem__c> GetListOfLineItems(){

List<Apttus_Config2__LineItem__c> ListOfLineItems = new List<Apttus_Config2__LineItem__c>();
List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id  
FROM Apttus_Config2__ProductConfiguration__c 
WHERE Apttus_QPConfig__Proposald__c =: ProposalID];
prodConfig = new Apttus_Config2__ProductConfiguration__c();
if(prodConfigs.size() > 0) {
prodConfig = prodConfigs[0];
}
if(prodConfig != null) {
ListOfLineItems=[Select  Apttus_Config2__LineType__c, Apttus_Config2__ChargeType__c,  Apttus_Config2__Guidance__c
from Apttus_Config2__LineItem__c
Where Apttus_Config2__ConfigurationId__c =: prodConfig.Id];
}        
return ListOfLineItems;

}
*/
    
    public Apttus_Approval__Approval_Request__c getApprovalRecord()
    {
        Apttus_Approval__Approval_Request__c OApproval = [select id, Apttus_Approval__ProcessInstanceId__c,
                                                          Apttus_Approval__Approval_Status__c
                                                          FROM 
                                                          Apttus_Approval__Approval_Request__c WhERE id = :RequestId];
        return OApproval;
    }
    Public List<Apttus_Approval__Approval_Request__c> GetApprovalHistory(){
        SYstem.debug('MS TESTs RequestId'+RequestId);
        SYstem.debug('MS TESTs cartId'+cartId);
        Apttus_Config2__ProductConfiguration__c oConfig =   getprodConfig1();
        ListOfApprovalLineItems=new List<Apttus_Approval__Approval_Request__c>();
        
        Apttus_Approval__Approval_Request__c OApproval = getApprovalRecord();
        
        if(OApproval.Apttus_Approval__ProcessInstanceId__c != null)
        {
            ListOfApprovalLineItems = [Select Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                                       Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                       Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                       Apttus_Approval__SubmissionComment1__c
                                       from Apttus_Approval__Approval_Request__c
                                       Where 
                                       Apttus_Approval__ProcessInstanceId__c =: OApproval.Apttus_Approval__ProcessInstanceId__c 
//                                     Apttus_CQApprov__CartId__c =: cartId
        //                                 AND 
    //                                 id <> :RequestId
                                       order by Apttus_Approval__StepSequenceString__c];
        }
        //AND Apttus_Approval__ProcessInstanceId__r.Apttus_Approval__ApprovalProcessId__r.Name='000000'];
        
        return ListOfApprovalLineItems;
        
    }
    
    //Added By Viraj For the request I-231580 : Tracking Issue for S-420008 - Discount/NSSA Approval Email Content Update - Next Steps.
    /*Public List<wrapperConfigLineItems> getAllLineAttributeValue(List<Apttus_Config2__LineItem__c> lstConfigLineItem) {
        Map<Id,Apttus_Proposal__Proposal_Line_Item__c> mapPLI = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>();
        
        for(Apttus_Proposal__Proposal_Line_Item__c  objPLI : [Select Id,
                                                                    Apttus_QPConfig__DerivedFromId__c,
                                                                    APTS_Attribute_Display__c
                                                              From Apttus_Proposal__Proposal_Line_Item__c where Apttus_QPConfig__DerivedFromId__c in : lstConfigLineItem]){
            mapPLI.Put(objPLI.Apttus_QPConfig__DerivedFromId__c,objPLI); 
        }

        List<wrapperConfigLineItems> lstWrapper = new List<wrapperConfigLineItems>();
        for(Apttus_Config2__LineItem__c objLI : lstConfigLineItem){
            wrapperConfigLineItems objWrapperConfigLineItems = new wrapperConfigLineItems();
            objWrapperConfigLineItems.objLineItem = objLI ;
            if(mapPLI.ContainsKey(objLI.Id)){
                objWrapperConfigLineItems.objProposalLineItem = mapPLI.get(objLI.Id);                
            }
            lstWrapper.add(objWrapperConfigLineItems);
        }
        return lstWrapper;
    }*/
    
    Public List<wrapperConfigLineItems> getAllLineAttributeValue(Map<Id,Apttus_Config2__LineItem__c> mapLineItems) {
        Set<String> setProductId = new Set<String>();
        for(String strLineID : mapLineItems.keySet()){
            Apttus_Config2__LineItem__c objLI = mapLineItems.get(strLineID);
            setProductId.add(objLI.Apttus_Config2__ProductId__c);
        }

        Set<String> setAttributeGroupId = new Set<String>();
        Map<String,List<String>> mapProductGroupID = new Map<String,List<String>>();
        Map<String,Set<String>> mapTemp = new Map<String,Set<String>>();
        
        for(Apttus_Config2__ProductAttributeGroupMember__c objPAGM : [
                                                                        Select 
                                                                            Id,
                                                                            Apttus_Config2__AttributeGroupId__c,
                                                                            Apttus_Config2__ProductId__c 
                                                                        From Apttus_Config2__ProductAttributeGroupMember__c 
                                                                        Where Apttus_Config2__ProductId__c in: setProductId
                                                                    ]){
            setAttributeGroupId.add(objPAGM.Apttus_Config2__AttributeGroupId__c);
            if(!mapProductGroupID.Containskey(objPAGM.Apttus_Config2__ProductId__c)){
                mapProductGroupID.put(objPAGM.Apttus_Config2__ProductId__c,new List<String>());
            }
            
            if(!mapTemp.Containskey(objPAGM.Apttus_Config2__ProductId__c)){
                mapTemp.put(objPAGM.Apttus_Config2__ProductId__c,new Set<String>());
            }
            if(mapTemp.Containskey(objPAGM.Apttus_Config2__ProductId__c) && !mapTemp.get(objPAGM.Apttus_Config2__ProductId__c).contains(objPAGM.Apttus_Config2__AttributeGroupId__c)){
                mapProductGroupID.get(objPAGM.Apttus_Config2__ProductId__c).add(objPAGM.Apttus_Config2__AttributeGroupId__c);
            }
        }

        Set<String> setFields = new Set<String>();
        Map<String,Set<String>> mapProductGroupField = new Map<String,Set<String>>();

        String StrQuery = 'Select Id,Apttus_Config2__LineItemId__c ';
        setFields.add('Id');
        setFields.add('Apttus_Config2__LineItemId__c');
        
        for(Apttus_Config2__ProductAttribute__c objPA : [
                                                            Select 
                                                                Id,
                                                                Apttus_Config2__AttributeGroupId__c,
                                                                Apttus_Config2__Field__c 
                                                            From Apttus_Config2__ProductAttribute__c 
                                                            Where Apttus_Config2__AttributeGroupId__c in: setAttributeGroupId
                                                        ]){
            if(!setFields.Contains(objPA.Apttus_Config2__Field__c)){
                StrQuery += ',' +  objPA.Apttus_Config2__Field__c;
            }
            
            if(!mapProductGroupField.Containskey(objPA.Apttus_Config2__AttributeGroupId__c)){
                mapProductGroupField.put(objPA.Apttus_Config2__AttributeGroupId__c,new Set<String>());
            }
            setFields.add(objPA.Apttus_Config2__Field__c);
            mapProductGroupField.get(objPA.Apttus_Config2__AttributeGroupId__c).add(objPA.Apttus_Config2__Field__c);
        }
        Set<Id> setId = mapLineItems.keyset();
        StrQuery += ' From Apttus_Config2__ProductAttributeValue__c where Apttus_Config2__LineItemId__c in : setId ';
        
        System.debug('StrQuery ' + StrQuery );
        List<Apttus_Config2__ProductAttributeValue__c> lstProductAttribute = Database.Query(StrQuery);

        List<wrapperConfigLineItems> lstWrapper = new List<wrapperConfigLineItems>();
        for(Apttus_Config2__ProductAttributeValue__c objProductAttr : lstProductAttribute){
            wrapperConfigLineItems objWrapperConfigLineItems = new wrapperConfigLineItems();
            objWrapperConfigLineItems.objApttusProductAttributeValue = objProductAttr;
            if(mapLineItems.ContainsKey(objProductAttr.Apttus_Config2__LineItemId__c)){
                objWrapperConfigLineItems.objLineItem = mapLineItems.get(objProductAttr.Apttus_Config2__LineItemId__c);
                objWrapperConfigLineItems.fields = new List<String>();
                if(mapProductGroupID.ContainsKey(objWrapperConfigLineItems.objLineItem.Apttus_Config2__ProductId__c)){
                    List<String> setGroup = mapProductGroupID.get(objWrapperConfigLineItems.objLineItem.Apttus_Config2__ProductId__c); 
                    for(String str : setGroup) {
                        if(mapProductGroupField.Containskey(str)){
                            Set<String> StrSet = mapProductGroupField.get(str);
                            objWrapperConfigLineItems.fields.addAll(StrSet);
                        }
                    }
                }
            }
            lstWrapper.add(objWrapperConfigLineItems);
        }
        return lstWrapper;
    }
    
    //Added By Viraj For the request I-231580 : Tracking Issue for S-420008 - Discount/NSSA Approval Email Content Update - Next Steps.
    Public class wrapperConfigLineItems {
        Public Apttus_Config2__LineItem__c objLineItem {get;set;}
        //Public Set<String> setAttributeValueField {get;set;}
        Public Apttus_Config2__ProductAttributeValue__c objApttusProductAttributeValue {get;set;}
        public List<String> fields { get; set; }
        
        Public void wrapperConfigLineItems() {
            objLineItem = new Apttus_Config2__LineItem__c();
            //setAttributeValueField = new Set<String>();
            objApttusProductAttributeValue = new Apttus_Config2__ProductAttributeValue__c();
            fields = new List<String> {};
        }
    }
    
}