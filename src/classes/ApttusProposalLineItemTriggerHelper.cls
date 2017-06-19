public class ApttusProposalLineItemTriggerHelper {
    final String CLASSNAME = '\n\n**** ApttusProposalLineItemTriggerHelper.METHODNAME()';
    private apttusProposalLineItemTriggerHelperWithoutSharing privateWithoutSharingHelper;
    
    /*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the ApttusProposalLineItemTriggerHelper class
*/
    public static ApttusProposalLineItemTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        return NewTriggerHelper();
        
    }
    public static ApttusProposalLineItemTriggerHelper NewTriggerHelper(){
        ApttusProposalLineItemTriggerHelper newHelper = new ApttusProposalLineItemTriggerHelper();
        return newHelper;
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 04/09/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private ApttusProposalLineItemTriggerHelper(){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','ApttusProposalLineItemTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
    }
    
    /*
** @author : Cloud Sherpas, Inc.
** @date : 08/15/2014
** @description : User Story 0817: Remove Decimal from pricing fields and make it an Integer.  
** @paramaters : an array of Apttus_Proposal__Proposal_Line_Item__c objects
** @returns : nothing
*/
    /**** NO LONGER REQUIRED BY MONSTER    
public void convertPricingToInteger(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems){ 
final string METHODNAME = CLASSNAME.replace('METHODNAME','convertPricingToInteger');
system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems){
//Adjusted Price - Apttus_QPConfig__AdjustedPrice__c
if(pli.Apttus_QPConfig__AdjustedPrice__c != null){
pli.Apttus_QPConfig__AdjustedPrice__c = pli.Apttus_QPConfig__AdjustedPrice__c.round(System.RoundingMode.DOWN);
System.Debug(LoggingLevel.DEBUG, '>>> PLI ID='+ pli.ID +' Adjusted Price' + pli.Apttus_QPConfig__AdjustedPrice__c);
}
//Net Price - Apttus_QPConfig__NetPrice__c
if(pli.Apttus_QPConfig__NetPrice__c != null){
pli.Apttus_QPConfig__NetPrice__c = pli.Apttus_QPConfig__NetPrice__c.round(System.RoundingMode.DOWN);
System.Debug(LoggingLevel.DEBUG, '>>> PLI ID='+ pli.ID +' Net Price' + pli.Apttus_QPConfig__NetPrice__c);
}

}
}
*/
    /*
** @author : Cloud Sherpas, Inc.
** @date : 08/15/2014
** @description : User Story : Mass update the product line item on Proposallineitem update for start date, end date and comments 
** @paramaters : an array of Apttus_Proposal__Proposal_Line_Item__c objects
** @returns : nothing
*/
    public void Mass_edit_update(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems){ 
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Mass_edit_update');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('in trigger after update');
        List<ID> lineitemid = new List<ID>();
        List<Apttus_Config2__LineItem__c> limeitemlist = new List<Apttus_Config2__LineItem__c>();
        
        
        for(Apttus_Proposal__Proposal_Line_Item__c eachproposalline: pUpdatedLineItems){
            lineitemid.add(eachproposalline.Apttus_QPConfig__DerivedFromId__c);
        }
        Map<Id,Apttus_Config2__LineItem__c> maplineitem = new Map<Id,Apttus_Config2__LineItem__c>([select Id, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Comments__c from Apttus_Config2__LineItem__c where Id in :lineitemid]); 
        for(Apttus_Proposal__Proposal_Line_Item__c eachproposalline: pUpdatedLineItems){
            Boolean changed = false;
            if(maplineitem.get(eachproposalline.Apttus_QPConfig__DerivedFromId__c) != null){
                Apttus_Config2__LineItem__c temlineitem = maplineitem.get(eachproposalline.Apttus_QPConfig__DerivedFromId__c);
                if(temlineitem.Apttus_Config2__StartDate__c != eachproposalline.Apttus_QPConfig__StartDate__c){
                    temlineitem.Apttus_Config2__StartDate__c = eachproposalline.Apttus_QPConfig__StartDate__c;
                    changed = true;
                }
                if(temlineitem.Apttus_Config2__EndDate__c != eachproposalline.Apttus_QPConfig__EndDate__c){
                    temlineitem.Apttus_Config2__EndDate__c = eachproposalline.Apttus_QPConfig__EndDate__c;
                    changed = true;
                    
                }
                if(temlineitem.Apttus_Config2__Comments__c != eachproposalline.Apttus_QPConfig__Comments__c){
                    temlineitem.Apttus_Config2__Comments__c = eachproposalline.Apttus_QPConfig__Comments__c;
                    changed = true;
                }
                
                if(changed){
                    limeitemlist.add(temlineitem);
                }
            }
        }
        
        if( limeitemlist != null && !limeitemlist.isEmpty()) 
            update limeitemlist;
        
    }

    public void Terms_and_Condition_on_proposal(List<Apttus_Proposal__Proposal_Line_Item__c> pUpdatedLineItems){
        privateWithoutSharingHelper = new apttusProposalLineItemTriggerHelperWithoutSharing(); 
        privateWithoutSharingHelper.Terms_and_Condition_on_proposal(pUpdatedLineItems);
    }

    //S-386409 -- 
    public void SalesCredit(List<Apttus_Proposal__Proposal_Line_Item__c> pUpdatedLineItems){
        set<id> products = new set<id>();
        MAP<id,product2> ProductMAP ;
        for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems)
        {
            products.add(pli.Apttus_Proposal__Product__c);
            
            If(pli.Apttus_QPConfig__OptionId__c != null)
            {
                products.add(pli.Apttus_QPConfig__OptionId__c);
            }
        }
        
        ProductMAP =  new MAP<id,product2>([select  id,APTPS_Rev_Share__c,APTPS_Rev_Share_Type__c
                                            FROM product2 where id = :products]);  
        System.debug ('ProductMAP'+ProductMAP) ;
        for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems)
        {
            System.debug ('pli.Apttus_QPConfig__OptionId__c'+pli.Apttus_QPConfig__OptionId__c) ;
            
            If(pli.Apttus_QPConfig__OptionId__c != null)
            {
                If(ProductMAP.containsKey(pli.Apttus_QPConfig__OptionId__c))
                {
                    pli.Rev_Share__c= ProductMAP.get(pli.Apttus_QPConfig__OptionId__c).APTPS_Rev_Share__c;
                    pli.Rev_Share_Type__c= ProductMAP.get(pli.Apttus_QPConfig__OptionId__c).APTPS_Rev_Share_Type__c;
                }
            }
            else
            {
                If(ProductMAP.containsKey(pli.Apttus_Proposal__Product__c))
                {
                    pli.Rev_Share__c= ProductMAP.get(pli.Apttus_Proposal__Product__c).APTPS_Rev_Share__c;
                    pli.Rev_Share_Type__c= ProductMAP.get(pli.Apttus_Proposal__Product__c).APTPS_Rev_Share_Type__c;
                }
            }
            System.debug ('pli.Rev_Share_Type__c'+pli.Rev_Share_Type__c) ;
            System.debug ('pli.Net_Total__c'+pli.Net_Total__c) ;
            System.debug ('pli.Gross_Total__c'+pli.Gross_Total__c) ;
            System.debug ('pli.Rev_Share_Amount__c'+pli.Rev_Share_Amount__c) ;
            If(pli.Rev_Share_Type__c !=null && pli.Rev_Share__c!=null) // I-215209 changes , added null check
            {
                
                Decimal Revshare  = 0 ;
                IF(pli.Rev_Share_Type__c == 'Net')
                {
                    Revshare = pli.Net_Total__c * pli.Rev_Share__c;
                }
                else if(pli.Rev_Share_Type__c== 'Gross' )
                {
                    Revshare = pli.Gross_Total__c * pli.Rev_Share__c;
                }   
                 System.debug ('pli.Revshare'+Revshare) ;
                pli.Sales_Credit__c  = pli.Net_Total__c - (Revshare/100); 
            }
            else
            {   pli.Sales_Credit__c = 0;
                pli.Sales_Credit__c =pli.Net_Total__c ;
            }
        }
    }
    
 
  /*  
    // method to get proposal values for the controllin fields
    Apttus_Proposal__Proposal__c getProposal(String Proposalfields, Id ProposalId){
        system.debug('ProposalId  :'+ProposalId+'  Proposalfields  :'+Proposalfields);
        if(!string.isBlank(Proposalfields) && ProposalId != null )
        {
            try{
                String qProposal = 'SELECT '+Proposalfields+' FROM Apttus_Proposal__Proposal__c WHERE Id =: ProposalId';
                system.debug('proposal object:'+qProposal);
                Apttus_Proposal__Proposal__c proposal = Database.query(qProposal);
                return(proposal);
            }catch(SObjectException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'proposal field name Exception'));
                System.debug('Error proposal field Exception :'+ e);
            }
        }
        return null;    
    }
    
   

    
    
    // Apttus_Proposal__Proposal_Line_Item__c -->, Apttus_QPConfig__DerivedFromId__c(line item)-->, Apttus_Config2__ProductAttributeValue__c ( for product attribute selection.)
    // method to get Product attribute values for the controllin fields
    Apttus_Config2__ProductAttributeValue__c getProposalAtt(String prodattfields, Id propAtt){
        system.debug('Apttus_Config2__LineItemId__c :'+propAtt+'  product att fields  :'+prodattfields);
        if(!string.isBlank(prodattfields) && propAtt!= null )
        {
            try{
                String qProposalAtt = 'SELECT '+prodattfields+' FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c =: propAtt Limit 1';
                system.debug('proposal Attribute object Query :'+qProposalAtt);
                Apttus_Config2__ProductAttributeValue__c proposalAtt = Database.query(qProposalAtt);
                return(proposalAtt);
            }catch(SObjectException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Product Attribute field name Exception'));
                System.debug('Error Product Attribute field Exception :'+ e);
            }
        }
        return null; 
        
    } 
    
    */
    /*
** @author : Cloud Sherpas, Inc.
** @date : 08/15/2014
** @description :  update Attribute Display, Product Name Foreign field on Proposal Line Item for the Attribut having show on report checked with there approprate Attribute Value 
** @paramaters : an array of Apttus_Proposal__Proposal_Line_Item__c objects
** @returns : nothing
** Updated: 01/12/2017 - ASuchanek - for S-428879
*/
    public void AttributeDisplayPLI(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems){ 
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AttributeDisplayPLI');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        privateWithoutSharingHelper = new apttusProposalLineItemTriggerHelperWithoutSharing();
        Set<String> setStatus = new Set<String>{'Finalized','Ready For Finalization'}; //For S-440763. 
        Set<String> StdJobAdLangSet = new Set<String>{'German','AT_German','CH_German','CH_French'}; //For S-428879 temporary hardcoded
        
        Map<String,Set<String>> displayFilterMap = privateWithoutSharingHelper.populateAttribDisplayFilterMap(); //For S-428879 - map of Attributes showable per Country
        
        List<Apttus_Proposal__Proposal_Line_Item__c> pUpdatedLineItemsupdate = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItems){
            if(pli.Configuration_Status__c == 'Finalized' ||  pli.Configuration_Status__c =='Ready For Finalization' || pli.Configuration_Status__c =='Saved' || 
               pli.Configuration_Status__c ==  'Ready For Approvals' || pli.Configuration_Status__c == 'Pending Approval' || pli.Configuration_Status__c == 'Approval Required'
            ){//I-219414 changes                
                pUpdatedLineItemsupdate.add(pli);
            }
        }
        if(pUpdatedLineItemsupdate != null && !pUpdatedLineItemsupdate.isEmpty()){
            
            Schema.SObjectType t = Schema.getGlobalDescribe().get('Apttus_Config2__ProductAttributeValue__c');  
            Schema.DescribeSObjectResult r = t.getDescribe();
            MAP<string, string> labelToAPIMap = new MAP<string, string>();
            Map<String, Schema.SObjectField> M = r.fields.getMap();
            for(String key : M.KeySet())
            {
                labelToAPIMap.put(M.get(key).getDescribe().getLabel(), key);
            }                
            List<Id> products = new List<Id>();
            Set<String> Qlanguage = new Set<String>();
            List<Apttus_Config2__ProductAttributeGroupMember__c> AttributeGroupId = new List<Apttus_Config2__ProductAttributeGroupMember__c>();
            Map<Id,List<Apttus_Config2__ProductAttribute__c>> productAttributeMap = new Map<Id,List<Apttus_Config2__ProductAttribute__c>>(); // product id,list of Attributes
            Map<Id,Apttus_Config2__ProductAttributeGroupMember__c> AttributeGroupIdMap = new Map<Id,Apttus_Config2__ProductAttributeGroupMember__c>(); // Attribute Group Id, Attributegroup object
            Map<Id,List<Karma_To_SFDC_Product_Name_Translation__c>> KarmaMap  = new Map<Id,List<Karma_To_SFDC_Product_Name_Translation__c>>(); // Attribute Group Id, Attributegroup object
            
            Map<String,Map<String,String>> TranslationMap = new Map<String,Map<String,String>>();
            String linefields ='';
            for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItemsupdate){
                products.add(pli.Apttus_Proposal__Product__c);
                //I-199046 added Option                
                 If(pli.Apttus_QPConfig__OptionId__c != null)
                {
                     products.add(pli.Apttus_QPConfig__OptionId__c);
                }
                Qlanguage.add(pli.Quote_Language__c );
            }
            System.debug('products**********'+products);
            List<Apttus_Config2__ProductAttributeGroupMember__c> AttributeGroupIdList  = [SELECT Id,Apttus_Config2__AttributeGroupId__c,
                                                                                          Apttus_Config2__ProductId__r.Id 
                                                                                          FROM Apttus_Config2__ProductAttributeGroupMember__c 
                                                                                          WHERE Apttus_Config2__ProductId__r.Id IN:products];
            
            //AttributeGroupIdMap 
            for(Apttus_Config2__ProductAttributeGroupMember__c eachprodAttributeGroup : AttributeGroupIdList){
                AttributeGroupIdMap.put(eachprodAttributeGroup.Apttus_Config2__AttributeGroupId__c,eachprodAttributeGroup);
            }
            System.debug('AttributeGroupIdMap**********'+AttributeGroupIdMap.keyset());
            List<Apttus_Config2__ProductAttribute__c> productAttribute = [SELECT Apttus_Config2__AttributeGroupId__c,Apttus_Config2__Field__c,
                                                                          Apttus_Config2__Sequence__c,CreatedById,Show_on_Report__c FROM 
                                                                          Apttus_Config2__ProductAttribute__c WHERE Show_on_Report__c = True 
                                                                          AND Apttus_Config2__AttributeGroupId__c IN : AttributeGroupIdMap.keySet()];
            
            System.debug('AttributeGroupIdMap**********'+productAttribute);
            List<Apttus_Config2__ProductAttribute__c> temp;
            for(Apttus_Config2__ProductAttribute__c eachproductAttribute : productAttribute){
                if(productAttributeMap.containsKey(AttributeGroupIdMap.get(eachproductAttribute.Apttus_Config2__AttributeGroupId__c).Apttus_Config2__ProductId__r.Id)){
                    temp = productAttributeMap.get(AttributeGroupIdMap.get(eachproductAttribute.Apttus_Config2__AttributeGroupId__c).Apttus_Config2__ProductId__r.Id);
                }else{
                    temp = new List<Apttus_Config2__ProductAttribute__c>();
                }
                temp.add(eachproductAttribute);
                productAttributeMap.put(AttributeGroupIdMap.get(eachproductAttribute.Apttus_Config2__AttributeGroupId__c).Apttus_Config2__ProductId__r.Id,temp);
            }
            
            ///S-317514-- Start Added logic to fetch product classification on the line Item
            list<Karma_To_SFDC_Product_Name_Translation__c> KarmaList = [select id,
                                                                         Attribute_Field__c,
                                                                         Attribute_Value__c,
                                                                         Media_Group__c,
                                                                         Media_Type__c,
                                                                         Product_Cateogry__c,
                                                                         Product_Family__c,
                                                                         Product_SubCategory__c,
                                                                         SFDC_Product_Name__c
                                                                         FROM Karma_To_SFDC_Product_Name_Translation__c
                                                                         WHERE SFDC_Product_Name__c = :products];
            for(Karma_To_SFDC_Product_Name_Translation__c oTempRecord  : KarmaList)
            {
                If(KarmaMap.containsKey(oTempRecord.SFDC_Product_Name__c))
                {
                    List<Karma_To_SFDC_Product_Name_Translation__c>  tempList = KarmaMap.get(oTempRecord.SFDC_Product_Name__c);
                    tempList.add(oTempRecord);
                    
                }else
                {
                    List<Karma_To_SFDC_Product_Name_Translation__c>  tempList = new List<Karma_To_SFDC_Product_Name_Translation__c>();
                    tempList.add(oTempRecord);
                    KarmaMap.put(oTempRecord.SFDC_Product_Name__c, tempList);
                    
                }
            }
            ///S-317514--  End
            
            system.debug('product : \nproductAttributeMap '+productAttributeMap );
            // get all the Product Attribute values from the line Item
            List<Id> Lineitem = new List<Id>();
            Set<string> RetrievedFieldList = new set<string>();
            for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItemsupdate){
                ID Prod = pli.Apttus_QPConfig__OptionId__c != null ? pli.Apttus_QPConfig__OptionId__c :  pli.Apttus_Proposal__Product__c; //I-199046
                
                system.debug('product :'+ Prod +' \nproductAttributeMap.get(Prod) '+productAttributeMap.get(Prod) );
                if(productAttributeMap.get(Prod) != null){
                    for(Apttus_Config2__ProductAttribute__c eaclattribute: productAttributeMap.get(Prod)){
                        system.debug('eaclattribute :'+ eaclattribute);
                        
                        
                        // It was calculating fields as duplicate : if(!linefields.contains(','+eaclattribute.Apttus_Config2__Field__c+','))
                        if(!linefields.contains(','+eaclattribute.Apttus_Config2__Field__c)) {
                            linefields+=','+eaclattribute.Apttus_Config2__Field__c;
                            RetrievedFieldList.add(eaclattribute.Apttus_Config2__Field__c);
                        }
                        
                    }
                    
                    
                    Lineitem.add(pli.Apttus_QPConfig__DerivedFromId__c);
                }
            }
            //S-428879 - add Country__c if not present, for use in the 428879 logic, even when this is not for display itself
            if(!linefields.contains('Country__c')) {
                linefields+=',Country__c';
            }
            
            linefields = linefields.right(linefields.length()  - 1); //stripping off the leading comma
            System.debug('MS TEST20:'+linefields);
            

            List<Apttus_Config2__ProductAttributeValue__c> ProductattributedataList = privateWithoutSharingHelper.getProposalAttvalues(linefields,Lineitem);
            
            Map<Id,Apttus_Config2__ProductAttributeValue__c> ProdAttributeMap = new Map<Id,Apttus_Config2__ProductAttributeValue__c>();
            if(ProductattributedataList != null){
                for(Apttus_Config2__ProductAttributeValue__c eachproductAttributedata :ProductattributedataList ){
                    ProdAttributeMap.put(eachproductAttributedata.Apttus_Config2__LineItemId__c,eachproductAttributedata);
                }
            }
            
            List<Translated_Product_Attribute__c> Translation = [select English_Value__c,
                                                                 Language__c,
                                                                 Product__c,
                                                                 Translated_Value__c,
                                                                 Type__c FROM Translated_Product_Attribute__c 
                                                                 WHERE Language__c IN: Qlanguage and (Product__c IN:products OR English_Value__c != null)];
            Map<String,String> tempMap;
            for(Translated_Product_Attribute__c eachTranslation: Translation){
                if(TranslationMap.containsKey(eachTranslation.Language__c)){
                    tempMap = TranslationMap.get(eachTranslation.Language__c);
                }else{
                    tempMap = new Map<String,String>();
                }
                if(eachTranslation.Type__c == 'Attribute Name' || eachTranslation.Type__c == 'Attribute Value'){
                    tempMap.put(eachTranslation.English_Value__c,eachTranslation.Translated_Value__c);
                } else if(eachTranslation.Type__c == 'Product Name'){
                    tempMap.put(eachTranslation.Product__c,eachTranslation.Translated_Value__c);
                }
                TranslationMap.put(eachTranslation.Language__c,tempMap);
            }
            
            
            
            for(Apttus_Proposal__Proposal_Line_Item__c pli : pUpdatedLineItemsupdate){
                ID Prod = pli.Apttus_QPConfig__OptionId__c != null ? pli.Apttus_QPConfig__OptionId__c :  pli.Apttus_Proposal__Product__c; //I-199046
                ID Lineitempli = pli.Apttus_QPConfig__DerivedFromId__c;
                
                system.debug('product in process  :'+Prod);
                pli.APTS_Attribute_Display__c = '';
                if(ProdAttributeMap.get(Lineitempli) != null){
                    Apttus_Config2__ProductAttributeValue__c Productattributedata = ProdAttributeMap.get(Lineitempli);
                    System.debug('MS TEST0:'+pli.Quote_Language__c);
                    System.debug('MS TEST1:'+TranslationMap.get(pli.Quote_Language__c));
                    ///S-317514-- Start Added logic to fetch product classification on the line Item
                    //S-440763 -- Updated If condition, Execute only for the status = Finalized and ready for Finalized.
                    If(KarmaMap.containsKey(Prod) && setStatus.Contains(pli.Configuration_Status__c)) 
                    {
                        List<Karma_To_SFDC_Product_Name_Translation__c> KarmaProductwiseList = KarmaMap.get(Prod);
                        boolean bComplete = False;
                        for( Karma_To_SFDC_Product_Name_Translation__c oTempRecord  : KarmaProductwiseList)
                        {
                            If(!bComplete)
                            {
                                if(labelToAPIMap.containsKey(oTempRecord.Attribute_Field__c)  && RetrievedFieldList.contains(oTempRecord.Attribute_Field__c))
                                {
                                    string labelAPI =  labelToAPIMap.get(oTempRecord.Attribute_Field__c);
                                    string AttribVal = (String)Productattributedata.get(labelAPI); 
                                    
                                    If(string.isnotblank(AttribVal) && (oTempRecord.Attribute_Value__c.equalsIgnoreCase(AttribVal) || oTempRecord.Attribute_Value__c.equalsIgnoreCase('All')))
                                    {
                                        pli.Media_Group__c = oTempRecord.Media_Group__c;
                                        pli.Product_Cateogry__c = oTempRecord.Product_Cateogry__c;
                                        pli.Product_SubCategory__c = oTempRecord.Product_SubCategory__c;
                                        pli.Product_Family__c = oTempRecord.Product_Family__c;
                                        pli.Media_Type__c = oTempRecord.Media_Type__c;
                                        bComplete = true;
                                    }
                                }
                                else if(oTempRecord.Attribute_Field__c.equalsIgnoreCase('All'))
                                {
                                    pli.Media_Group__c = oTempRecord.Media_Group__c;
                                    pli.Product_Cateogry__c = oTempRecord.Product_Cateogry__c;
                                    pli.Product_SubCategory__c = oTempRecord.Product_SubCategory__c;
                                    pli.Product_Family__c = oTempRecord.Product_Family__c;
                                    pli.Media_Type__c = oTempRecord.Media_Type__c;                                    
                                    bComplete = true;
                                }
                            }
                        }
                    }
                    ///S-317514-- End
                    if(pli.Quote_Language__c != 'English' && TranslationMap.get(pli.Quote_Language__c) != null){
                        Map<String,String> tempMapcon = new Map<String,String>();
                        tempMapcon = TranslationMap.get(pli.Quote_Language__c);
                        //S-428879
                        Boolean doFilterDisplay = False;   //1. Define boolean to drive applying this story logic or no. 
                        Boolean doRender = True;
                        String attrCountry = (String)Productattributedata.get('Country__c');  //2.determine the country attribute from the current PLI 
                                                
                        //3. if the product is Monster Standard Job Ad and Quote Language is one of the selected then set the boolean
                        system.debug('S-428879: PLI Product Name: ' + pli.Product_or_Option_Name__c);
                        if (pli.Product_or_Option_Name__c == 'Monster Standard Job Ad' && StdJobAdLangSet.contains(pli.Quote_Language__c) )
                        {
                          doFilterDisplay = True; 
                          system.debug('S-428879: Product and Laungage applicable');
                        }
                        

                        
                        for(Apttus_Config2__ProductAttribute__c eaclattribute: productAttributeMap.get(Prod)){ 
                        


                            Schema.DescribeFieldResult f = r.fields.getMap().get(eaclattribute.Apttus_Config2__Field__c).getDescribe();
                            string label = f.getLabel();
                            
                            string display = (String)Productattributedata.get(eaclattribute.Apttus_Config2__Field__c); 

                            //S-428879 - here the doFilterDisplay will play
                            doRender = True;  //default for attributes that I don't have special logic for
                            if(doFilterDisplay ) {
                                system.debug('S-428879: determining rule for attribute: ' + label + ' and Country: ' + attrCountry);
                                system.debug('S-428879: Set of countries for the label: ' + displayFilterMap.get(label));
                                if (displayFilterMap.containsKey(label)) 
                                   doRender = displayFilterMap.get(label).contains(attrCountry);
                                 else 
                                   doRender = False;
                                system.debug('S-428879: determined ' + doRender);
                            }

                            //now update  the APTS_Attribute_Display__c only if doRender is true
                            if (doRender) {

                                iF(tempMapcon.get(label)!= null)
                                {
                                  label =  tempMapcon.get(label);
                                }
                                iF(tempMapcon.get(display)!= null)
                                {
                                  display =  tempMapcon.get(display);
                                }
                            
                                if(string.isBlank(pli.APTS_Attribute_Display__c)) 
                                   pli.APTS_Attribute_Display__c = label+' = '+display;
                                else 
                                   pli.APTS_Attribute_Display__c+= ' \r\n'+label+' = ' +display;
                            }
                            
                       
                        }
                        //I-199046
                         If(pli.Apttus_QPConfig__OptionId__c != null)
                        {
                            if(tempMapcon.get(pli.Apttus_QPConfig__OptionId__c) != null)
                            pli.Product_Name_Foreign__c = tempMapcon.get(pli.Apttus_QPConfig__OptionId__c);
                        }else
                        {
                        if(tempMapcon.get(pli.Apttus_Proposal__Product__c) != null)
                            pli.Product_Name_Foreign__c = tempMapcon.get(pli.Apttus_Proposal__Product__c);
                        }
                        
                    }
                    if(pli.Quote_Language__c == 'English'){
                        
                        if(productAttributeMap.get(Prod) != null){
                            system.debug('MS20 :'+ productAttributeMap.get(Prod));
                            for(Apttus_Config2__ProductAttribute__c eaclattribute: productAttributeMap.get(Prod)){
                                Schema.DescribeFieldResult f = r.fields.getMap().get(eaclattribute.Apttus_Config2__Field__c).getDescribe();
                                string label = f.getLabel();
                                
                                string display = string.valueof(productattributedata.get(eaclattribute.Apttus_Config2__Field__c));                                        
                                if(string.isBlank(pli.APTS_Attribute_Display__c))
                                {
                                    pli.APTS_Attribute_Display__c = label+' = '+display; 
                                }
                                else 
                                {
                                    pli.APTS_Attribute_Display__c+= ' \r\n'+label+' = ' +display;
                                }
                            }
                            
                        }
                    }
                }
                system.debug('pli.APTS_Attribute_Display__c:'+pli.APTS_Attribute_Display__c); 
                system.debug('pli.Product_Name_Foreign__c  :'+pli.Product_Name_Foreign__c);  
            }
        }
    }// end of AttributeDisplayPLI

    private without sharing class apttusProposalLineItemTriggerHelperWithoutSharing {
        final String CLASSNAME = '\n\n**** apttusProposalLineItemTriggerHelperWithoutSharing.METHODNAME()';

        public apttusProposalLineItemTriggerHelperWithoutSharing(){
            final string METHODNAME = CLASSNAME.replace('METHODNAME','apttusProposalLineItemTriggerHelperWithoutSharing');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        }

        /*
        ** @author : Cloud Sherpas, Inc.
        ** @date : 09/10/2014
        ** @description : User Story : 
        Terms and condition trigger for attaching terms and condition to each Proposal lineitem
        Use case 1: terms and condition on Product  & language 
        these types of terms and condition are retrived from  (Terms and condition object)

        Use case 2 :Terms and condition on Proposal fields, Product & Language
        these types of terms and condition are saved on (controller dependent Attribute_workfow_junction_object__c)

        Use case 3 :Terms and condition on product Attribute fields, Product & Language
        these types of terms and condition are saved on (controller dependent Attribute_workfow_junction_object__c)

        -- implemented in Proposal trigger ----------
        Use case 4 :Terms and condition on Proposal Quote type, Language & NO Product assocation.
        these types of terms and condition are saved on (Terms and condition object)

        ** @paramaters : an array of Apttus_Proposal__Proposal_Line_Item__c objects
        ** @returns : nothing
        */
        
        public void Terms_and_Condition_on_proposal(Apttus_Proposal__Proposal_Line_Item__c[] pUpdatedLineItems){ 
            final string METHODNAME = CLASSNAME.replace('METHODNAME','Terms_and_Condition_on_proposal');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            system.debug('in trigger AfterInsert Terms_and_Condition_on_proposal');
            List <Terms_and_Conditions_Proposal_Line_Item__c> jtermproposal = new List <Terms_and_Conditions_Proposal_Line_Item__c>();
            Map<Id,Apttus_Proposal__Proposal__c> proposallangmap = new Map<Id,Apttus_Proposal__Proposal__c>();
            Map<Id,Set<Id>> eliminateduplicate = new Map<Id,Set<Id>>(); // <Proposallineitem ID, Setof terms and condition> Apttus_Proposal__Proposal__c
            Set<String> propLanguage = new Set<String>();
            Set<Id> productsid = new Set<Id>();
            Set<Id> Proposalid = new Set<Id>();
            Set<Id> lineitemid = new Set<Id>();
            for(Apttus_Proposal__Proposal_Line_Item__c eachpline: pUpdatedLineItems){
                productsid.add(eachpline.Apttus_Proposal__Product__c);
                If(eachpline.Apttus_QPConfig__OptionId__c != null)
                {
                    productsid.add(eachpline.Apttus_QPConfig__OptionId__c);
                }
                propLanguage.add(eachpline.Quote_Language__c);
                Proposalid.add(eachpline.Apttus_Proposal__Proposal__c);
                lineitemid.add(eachpline.Apttus_QPConfig__DerivedFromId__c);
                
            }
            
            List <Terms_and_Conditions__c> TandCproductList = [select Id,
                                                               Product__c,
                                                               Language__c,
                                                               Attribute_1__c 
                                                               from Terms_and_Conditions__c 
                                                               where Product__c IN:productsid and Language__c IN:propLanguage];
            System.debug('MS  TEST TandCproductList'+TandCproductList);  
            Map<Id,List<Terms_and_Conditions__c>> TandCproductMap = new Map<Id,List<Terms_and_Conditions__c>>(); // <PLI.ID,TERMS AND CONDITION>
            List<Terms_and_Conditions__c> tempTandCList;
            if(TandCproductList != null && !TandCproductList.isEmpty()){
                for(Apttus_Proposal__Proposal_Line_Item__c eachpline: pUpdatedLineItems){
                     id productid = eachpline.Apttus_QPConfig__OptionId__c != null ? eachpline.Apttus_QPConfig__OptionId__c : eachpline.Apttus_Proposal__Product__c; // S-38065
                      
                        System.debug('MS TEST eachpline'+eachpline.id);
                    
                        
                    for(Terms_and_Conditions__c eachTandC: TandCproductList){
                       
                        
                        System.debug('MS TEST productid:'+productid);
                        System.debug('MS TEST eachTandC.Product__c:'+eachTandC.Product__c);
                        if(eachpline.Quote_Language__c == eachTandC.Language__c && productid == eachTandC.Product__c){
                            System.debug('MS TEST eachTandC.Product__c: inside'+eachpline.id);
                            if(TandCproductMap.containsKey(eachpline.Id)){
                                tempTandCList = TandCproductMap.get(eachpline.Id);
                            }else{
                                tempTandCList = new List<Terms_and_Conditions__c>();
                            }
                            tempTandCList.add(eachTandC);
                            TandCproductMap.put(eachpline.Id,tempTandCList);    
                        }  
                    }
                    System.debug('MS TEST productid2:'+productid +'  inside'+eachpline.id);
                    System.debug('MS TEST TandCproductMap2:'+TandCproductMap+'  inside'+eachpline.id);
                }
            }
            system.debug('TandCproductMap  :'+ TandCproductMap );
            List<Attribute_workfow_junction_object__c> jtermsList = [SELECT Controlling_Attribute_workflow_Object__r.Attribute_type__c,
                                                                     Controlling_Attribute_workflow_Object__r.attribute_values__c, 
                                                                     Controlling_Attribute_workflow_Object__r.Controlling_attributes__c,
                                                                     Controlling_Attribute_workflow_Object__r.Id, 
                                                                     Controlling_Attribute_workflow_Object__r.Controlling_Attribute_workflow_Object__c, 
                                                                     Dependent_Attribute_workflow_object__r.Id, 
                                                                     Dependent_Attribute_workflow_object__r.DEP_attrib_values__c,
                                                                     Dependent_Attribute_workflow_object__r.attribute_values__c,
                                                                     Dependent_Attribute_workflow_object__r.Attribute_type__c,
                                                                     Product_Group__c
                                                                     FROM Attribute_workfow_junction_object__c 
                                                                     WHERE Product_Group__c IN:productsid 
                                                                     and Dependent_Attribute_workflow_object__r.Attribute_type__c =: 'Language T & C'];
            system.debug('jtermsList  :'+jtermsList);
            String proposalfieldlist;
            String PropAttfieldlist;
            Set<String> PropAttfieldSet=new Set<String>();
            //List <Attribute_workfow_junction_object__c> tempjatt = new List <Attribute_workfow_junction_object__c>();
            Map<Id,List<Attribute_workfow_junction_object__c>> jtermsMap = new Map<Id,List<Attribute_workfow_junction_object__c>>(); // map <PLI.ID, Attribute_workfow_junction_object__c>
            List<Attribute_workfow_junction_object__c> tempjtermsList;                                                                
            if(jtermsList != null && !jtermsList.isEmpty()){
                for(Apttus_Proposal__Proposal_Line_Item__c eachpline: pUpdatedLineItems){
                    id productid = eachpline.Apttus_QPConfig__OptionId__c != null ? eachpline.Apttus_QPConfig__OptionId__c : eachpline.Apttus_Proposal__Product__c; // S-38065
                    for(Attribute_workfow_junction_object__c eachterm :jtermsList){
                        if(productid == eachterm.Product_Group__c){
                            if(jtermsMap.containsKey(eachpline.Id)){
                                tempjtermsList = jtermsMap.get(eachpline.Id);
                            }else{
                                tempjtermsList = new List<Attribute_workfow_junction_object__c>();
                            }
                            tempjtermsList.add(eachterm);
                            jtermsMap.put(eachpline.Id,tempjtermsList);  
                        }
                        if(eachterm.Controlling_Attribute_workflow_Object__r.attribute_values__c !='' &&
                           eachterm.Controlling_Attribute_workflow_Object__r.attribute_values__c !=null &&
                           eachterm.Controlling_Attribute_workflow_Object__r.Attribute_type__c == 'Proposal' &&
                           eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c != null){
                               
                               if(string.isBlank(proposalfieldlist)){
                                   proposalfieldlist = eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                               }else{
                                   if(!proposalfieldlist.contains(eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c))
                                       proposalfieldlist+=','+eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                               }
                               //tempjatt.add(eachterm);
                               
                           }
                        
                        if(eachterm.Controlling_Attribute_workflow_Object__r.attribute_values__c !='' &&
                           eachterm.Controlling_Attribute_workflow_Object__r.attribute_values__c !=null &&
                           eachterm.Controlling_Attribute_workflow_Object__r.Attribute_type__c == 'Product' &&
                           eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c != null){
                               
                               //I-220493 changes -- adding the attribute in set instead of string so type__c  can be appended to the string although video_type__c is there in set
                               if(string.isBlank(PropAttfieldlist)){
                                   PropAttfieldlist = eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                                   PropAttfieldSet.add(eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c);
                               }else{ 
                                   if(!PropAttfieldSet.contains(eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c))
                                   {
                                       PropAttfieldlist+=','+eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                                       PropAttfieldSet.add(eachterm.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c);
                                   }
                                       
                               }
                               //tempjatt.add(eachterm);
                           }
                        
                    }
                }
            }
            
            system.debug('jtermsMap  :'+jtermsMap);
            //system.debug('tempjatt  :'+tempjatt);
            
            //getProposalvalues
            Map<Id,Apttus_Proposal__Proposal__c> proposalMap = new Map<Id,Apttus_Proposal__Proposal__c>();// MAP <PLI.ID, PROPOSAL>
            //List<Apttus_Proposal__Proposal__c> tempproposalList; 
            if(!string.isBlank(proposalfieldlist)){
                List<Apttus_Proposal__Proposal__c> proposal = getProposalvalues(proposalfieldlist,Proposalid);
                if(proposal != null){
                    for(Apttus_Proposal__Proposal__c eachprop: proposal){
                        proposalMap.put(eachprop.Id,eachprop);       
                    }
                }
            }
            system.debug('proposalMap  :' + proposalMap);
            
            //getproposallineitemvalues   Apttus_Config2__LineItemId__c
            Map<Id,Apttus_Config2__ProductAttributeValue__c> productattMap = new Map<Id,Apttus_Config2__ProductAttributeValue__c>();
            //List<Apttus_Config2__ProductAttributeValue__c> tempproductattList;
            if(!string.isBlank(PropAttfieldlist)){
                List<Apttus_Config2__ProductAttributeValue__c> productatt = getProposalAttvalues(PropAttfieldlist,new List<Id>(lineitemid));
                if(productatt != null){
                    system.debug('productatt  :' + productatt);
                    for(Apttus_Config2__ProductAttributeValue__c eachproductatt: productatt){
                        productattMap.put(eachproductatt.Apttus_Config2__LineItemId__c,eachproductatt);       
                    }
                }
            }
            system.debug('productattMap  :' + productattMap);
            /////done creating all maps.
            
            /*Use case 1: terms and condition on Product  & language 
            *these types of terms and condition are retrived from  (Terms and condition object)
            */
            
            for(Apttus_Proposal__Proposal_Line_Item__c eachpline: pUpdatedLineItems){
                List <Terms_and_Conditions__c> TandCproduct = new List <Terms_and_Conditions__c>();
                if(TandCproductMap.get(eachpline.Id) != null)
                    TandCproduct = TandCproductMap.get(eachpline.Id);
                if(TandCproduct != null && !TandCproduct.isEmpty()){
                    for(Terms_and_Conditions__c eachTandCproduct :TandCproduct){
                        Terms_and_Conditions_Proposal_Line_Item__c temp = new Terms_and_Conditions_Proposal_Line_Item__c();
                        if(eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c) == null){
                            // logic to verify if this type of Tems and condition is already created then thon dont create T & C PLI
                            Set<Id> tempset = new Set<Id>();
                            tempset.add(eachTandCproduct.Id);
                            eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                            
                            //cretate a new Terms and condition Proposal Line Item record for new terms and condition.
                            temp.Proposal_Line_Item__c = eachpline.Id;
                            temp.Terms_and_Conditions__c = eachTandCproduct.Id;
                            System.debug('MS Test1:'+eachpline.Id);
                            temp.Term_text__c = eachTandCproduct.Attribute_1__c;
                            jtermproposal.add(temp);
                        }else{
                            Set<Id> tempset = eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c);
                            if(!tempset.contains(eachTandCproduct.Id)){
                                // logic to verify if this type of Tems and condition is already created then thon dont create T & C PLI
                                tempset.add(eachTandCproduct.Id);
                                eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                                
                                //cretate a new Terms and condition Proposal Line Item record for new terms and condition.
                                temp.Proposal_Line_Item__c = eachpline.Id;
                                temp.Terms_and_Conditions__c = eachTandCproduct.Id;
                                System.debug('MS Test2:'+eachpline.Id);
                                temp.Term_text__c = eachTandCproduct.Attribute_1__c;
                                jtermproposal.add(temp);  
                            }
                        }
                        
                        
                    }
                    
                }else{
                    List <Attribute_workfow_junction_object__c> jterms = new List <Attribute_workfow_junction_object__c>();
                    if(jtermsMap.get(eachpline.Id) != null)
                        jterms = jtermsMap.get(eachpline.Id);
                    system.debug('Dependent junction terms '+jterms);
                    /*
                    *Use case 2 :Terms and condition on Proposal fields, Product & Language
                    *these types of terms and condition are saved on (controller dependent Attribute_workfow_junction_object__c)
                    */
                    
                    if(jterms != null && !jterms.isEmpty()){
                        Apttus_Proposal__Proposal__c proposal;
                        system.debug('*****eachpline.Id'+eachpline.Id+'\n proposalMap.get(eachpline.Apttus_Proposal__Proposal__c)'+proposalMap.get(eachpline.Apttus_Proposal__Proposal__c) );
                        if(proposalMap.get(eachpline.Apttus_Proposal__Proposal__c) != null)
                            proposal = proposalMap.get(eachpline.Apttus_Proposal__Proposal__c);
                        
                        if(proposal != null){
                            system.debug('******proposal  :'+ proposal);
                            for(Attribute_workfow_junction_object__c jtermprop :jtermsList){
                                if(jtermprop.Controlling_Attribute_workflow_Object__r.Attribute_type__c == 'Proposal'){
                                    system.debug('*****jtermproposal'+ jtermprop);
                                    String conattvar = jtermprop.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                                    system.debug('conattvar  :'+conattvar);
                                    string popval = (String)proposal.get(conattvar);
                                    system.debug('popval   :'+popval+'jtermprop.Controlling_Attribute_workflow_Object__r.attribute_values__c :'+jtermprop.Controlling_Attribute_workflow_Object__r.attribute_values__c);
                                    system.debug('eachpline.Quote_Language__c  :'+eachpline.Quote_Language__c+'jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c'+jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c);
                                    id productid = eachpline.Apttus_QPConfig__OptionId__c != null ? eachpline.Apttus_QPConfig__OptionId__c : eachpline.Apttus_Proposal__Product__c; // S-38065
                                    if(popval!= null && popval!= '' && conattvar !=null && conattvar !='' && eachpline.Quote_Language__c!= null && eachpline.Quote_Language__c!= '' && jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c != null && jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c != '')
                                        if(popval == (String)jtermprop.Controlling_Attribute_workflow_Object__r.attribute_values__c && eachpline.Quote_Language__c == jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c && productid == jtermprop.Product_Group__c){
                                            
                                            Terms_and_Conditions_Proposal_Line_Item__c temp = new Terms_and_Conditions_Proposal_Line_Item__c();
                                            if(eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c) == null){
                                                // logic to verify if this type of Tems and condition is already created then dont create T & C PLI
                                                Set<Id> tempset = new Set<Id>();
                                                tempset.add(jtermprop.Id);
                                                eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                                                
                                                //cretate a new Terms and condition Proposal Line Item record for new terms and condition.
                                                temp.Proposal_Line_Item__c = eachpline.Id;
                                                temp.Attribute_workfow_junction_object__c = jtermprop.Id;
                                                System.debug('MS Test3:'+jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c);
                                                temp.Term_text__c = jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c;
                                                jtermproposal.add(temp);
                                            }else{
                                                Set<Id> tempset = eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c);
                                                if(!tempset.contains(jtermprop.Id)){
                                                    // logic to verify if this type of Tems and condition is already created then thon dont create T & C PLI
                                                    tempset.add(jtermprop.Id);
                                                    eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                                                    
                                                    //cretate a new Terms and condition Proposal Line Item record for new terms and condition. as its not already existing
                                                    temp.Proposal_Line_Item__c = eachpline.Id;
                                                    temp.Attribute_workfow_junction_object__c = jtermprop.Id;
                                                    System.debug('MS Test4:'+jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c);
                                                    temp.Term_text__c = jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c;
                                                    jtermproposal.add(temp);
                                                }
                                                
                                            }
                                            
                                        }
                                } 
                            }
                        }
                    }// end T&C for proposal
                    
                    /*
                    *Use case 3 :Terms and condition on product Attribute fields, Product & Language
                    *these types of terms and condition are saved on (controller dependent Attribute_workfow_junction_object__c)
                    */
                    
                    if(!string.isBlank(PropAttfieldlist)){
                        system.debug('Derived from lineitem.ProductAttributeValue'+eachpline.Apttus_QPConfig__DerivedFromId__c);
                        Apttus_Config2__ProductAttributeValue__c productatt;
                        if(productattMap.get(eachpline.Apttus_QPConfig__DerivedFromId__c) != null)
                            productatt = productattMap.get(eachpline.Apttus_QPConfig__DerivedFromId__c);
                        if(productatt != null){
                            for(Attribute_workfow_junction_object__c jtermprop :jtermsList){
                                if(jtermprop.Controlling_Attribute_workflow_Object__r.Attribute_type__c == 'Product'){
                                    system.debug('jtermproposal'+ jtermprop);
                                    String conattvar = jtermprop.Controlling_Attribute_workflow_Object__r.Controlling_attributes__c;
                                    string prodval = (String)productatt.get(conattvar);
                                    id productid = eachpline.Apttus_QPConfig__OptionId__c != null ? eachpline.Apttus_QPConfig__OptionId__c : eachpline.Apttus_Proposal__Product__c; // S-38065
                                    if(prodval!= null && prodval!= '' && conattvar !=null && conattvar !='' && eachpline.Quote_Language__c!= null && eachpline.Quote_Language__c!= '' && jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c != null && jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c != '')
                                        if(prodval == (String)jtermprop.Controlling_Attribute_workflow_Object__r.attribute_values__c && eachpline.Quote_Language__c == jtermprop.Dependent_Attribute_workflow_object__r.DEP_attrib_values__c && productid == jtermprop.Product_Group__c){
                                            Terms_and_Conditions_Proposal_Line_Item__c temp = new Terms_and_Conditions_Proposal_Line_Item__c();
                                            
                                            if(eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c) == null){
                                                // logic to verify if this type of Tems and condition is already created then thon dont create T & C PLI
                                                Set<Id> tempset = new Set<Id>();
                                                tempset.add(jtermprop.Id);
                                                eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                                                
                                                //cretate a new Terms and condition Proposal Line Item record for new terms and condition.
                                                temp.Proposal_Line_Item__c = eachpline.Id;
                                                temp.Attribute_workfow_junction_object__c = jtermprop.Id;
                                                System.debug('MS Test5:'+jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c);
                                                temp.Term_text__c = jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c;
                                                jtermproposal.add(temp);
                                                
                                            }else{
                                                Set<Id> tempset = eliminateduplicate.get(eachpline.Apttus_Proposal__Proposal__c);
                                                if(!tempset.contains(jtermprop.Id)){
                                                    // logic to verify if this type of Tems and condition is already created then thon dont create T & C PLI
                                                    tempset.add(jtermprop.Id);
                                                    eliminateduplicate.put(eachpline.Apttus_Proposal__Proposal__c,tempset);
                                                    
                                                    //cretate a new Terms and condition Proposal Line Item record for new terms and condition. as its not already existing
                                                    temp.Proposal_Line_Item__c = eachpline.Id;
                                                    temp.Attribute_workfow_junction_object__c = jtermprop.Id;
                                                    System.debug('MS Test6:'+jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c);
                                                    temp.Term_text__c = jtermprop.Dependent_Attribute_workflow_object__r.attribute_values__c;
                                                    jtermproposal.add(temp);
                                                }
                                                
                                            }
                                            
                                        }
                                }
                            }
                            
                        }
                    }// end  T & C Productattribute
                    
                }//end of if else T & C product empty
                
            }//end for eachpline
            system.debug('jtermproposal: '+jtermproposal);
            if(jtermproposal.size() > 0){
                insert jtermproposal; 
            }
        }

        //  method to get list of proposal values for the controlling fields
        List<Apttus_Proposal__Proposal__c> getProposalvalues(String Proposalfields, Set<Id> ProposalId){
            system.debug('ProposalId  :'+ProposalId+'  Proposalfields  :'+Proposalfields);
            if(!string.isBlank(Proposalfields) && ProposalId != null )
            {
                try{
                    String qProposal = 'SELECT Id, '+Proposalfields+' FROM Apttus_Proposal__Proposal__c WHERE Id IN: ProposalId';
                    system.debug('proposal object:'+qProposal);
                    List<Apttus_Proposal__Proposal__c> proposal = Database.query(qProposal);
                    return(proposal);
                }catch(SObjectException e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'proposal field name Exception'));
                    System.debug('Error proposal field Exception :'+ e);
                }
            }
            return null;    
        }

        List<Apttus_Config2__ProductAttributeValue__c> getProposalAttvalues(String prodattfields, List<Id> propAtt){
            system.debug('Apttus_Config2__LineItemId__c :'+propAtt+'  product att fields  :'+prodattfields);
            if(!string.isBlank(prodattfields) && propAtt!= null )
            {
                try{
                    String qProposalAtt = 'SELECT Id, Apttus_Config2__LineItemId__c,'+prodattfields+' FROM Apttus_Config2__ProductAttributeValue__c WHERE Apttus_Config2__LineItemId__c IN: propAtt';
                    system.debug('proposal Attribute object Query :'+qProposalAtt);
                    List<Apttus_Config2__ProductAttributeValue__c> proposalAtt = Database.query(qProposalAtt);
                    return(proposalAtt);
                }catch(SObjectException e){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Product Attribute field name Exception'));
                    System.debug('Error Product Attribute field Exception :'+ e);
                }
            }
            return null; 
        } 

        /* 
        S-428879 Method to populate the Map of sets defining visibility of attributes for Monster Standard Job Ad
        */ 
        Map<String,Set<String>> populateAttribDisplayFilterMap(){
            system.debug('S-428879: Populating AttribDisplayFilterMap');
            Map<String,Set<String>> tempMap = new Map<String,Set<String>>();
            final String strDE = 'Germany';
            final String strAT = 'Austria';
            final String strCH = 'Switzerland';
            final String strUK = 'United Kingdom';
            final String strIE = 'Ireland';
            final String strFR = 'France';
            final String strNL = 'Netherlands';
            final String strBE = 'Belgium';
            final String strLU = 'Luxembourg';
            final String strES = 'Spain';
            final String strIT = 'Italy';
            tempMap.put('Boards',new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Contract Duration', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Country', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Design Type', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Has Bolding', new Set<String>{strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Max Categories', new Set<String>{strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Max Locations Group', new Set<String>{strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Payment Method', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT} );
            tempMap.put('Posting Duration', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Posting Location', new Set<String>{strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Posting Method', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Recommended Resume', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            tempMap.put('Refresh Interval', new Set<String>{strDE, strAT, strCH,strUK,strIE,strFR,strNL,strBE,strLU,strES,strIT});
            return(tempMap);
        }
    }
}