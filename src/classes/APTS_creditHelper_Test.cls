@isTest
public class APTS_creditHelper_Test {
    static testMethod void testAPTS_creditHelper(){  
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        
        Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
        insert oppt;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(oppt);
        prop.Conversion_Proposal__c = true;
        insert prop;
        
        Set<ID> setOID = new Set<ID>();
            Order__c order = TestDataSetupUtility.createOrder(acct.id);
            order.AgencyCommission__c = 10.2;
            order.Opportunity__c = oppt.id;
            order.QuoteProposal__c = prop.id;
            order.OrderDate__c = System.Today();
            order.PrimarySalesRep__c = userInfo.getUserID();
            order.SalesChannel__c = 'Partner';
            order.SentToVerificationBy2__c = userInfo.getUserID();
            order.OrderStatus__c = 'Sent To Verification';
            insert order;
        setOID.add(order.id);
        
        Credit_Request__c credReq = TestDataSetupUtility.createCreditRequest(order.id);
        insert credReq;
        
        CreditRequestLineItem__c crLI = TestDataSetupUtility.createCreditRequestLineItem(credReq.id);
        crLI.CreditType__c = 'Inventory';
        insert crLI;
        
        Product2 pro = TestDataSetupUtility.createTestProduct2('TestProduct');
        pro.Service_Type__c = 'Subscription';
        insert pro;
        
        List<LicenseID__c> LstLicence = new List<LicenseID__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(order.id);
        
            LicenseID__c license =new LicenseID__c();
            license.OrderLineItem__c  = oli.id;
            LstLicence.add(license);
        oli.NetTotalAmount__c = 9.2;
        oli.GrossRemainingCreditAmount__c = 9.0;
        oli.APTS_Tax_Amount__c = 9.0;
        oli.VATNationalTaxCode__c = 'tax';
        oli.VATNationalTaxRate__c = null;
        oli.VATNationalTaxAmount__c = null;
        oli.StateProvinceTaxCode__c = 'PNB'; 
        oli.BasePrice__c = 1500;
        oli.Remaining_Credit_Amount__c = 15.8;
        oli.Quantity__c = 6;
        oli.Quantity2__c = 2;
        oli.BaseUnitPrice__c = 10.2;
        oli.NetRemainingCreditAmount__c = 5.5;
        oli.AgencyCommission__c = 10;
        oli.NetCreditAmount__c = 4.0;
        insert oli;
        
        
        
        Apttus_Config2__AssetLineItem__c  ali =  TestDataSetupUtility.createAssetLineItem('Assest',acct.id,true);
        ali.Order_Line_Item__c = oli.id;
        update ali;
        
        Apttus_Proposal__Proposal_Line_Item__c pli = TestDataSetupUtility.createProposalLineItem(prop.id);
        pli.Apttus_QPConfig__AssetLineItemId__c = ali.id;
        pli.Apttus_QPConfig__Quantity2__c = 3;
        pli.Apttus_Proposal__Product__c = pro.id;                                                                     
        pli.Apttus_QPConfig__StartDate__c = System.Today();
        pli.Apttus_QPConfig__EndDate__c = System.Today().AddMonths(1);
        insert pli;
        
        list<Credit_Request__c>  CRSet = new list<Credit_Request__c>();
        CRSet.add(credReq);
        
        list<CreditRequestLineItem__c>  CRLI_lst = new list<CreditRequestLineItem__c>();
        CRLI_lst.add(crLI);
        
        Map<id,Order__c> mapOrder = new Map<id,Order__c>();
        mapOrder.put(order.id,order);
        
        Map<id,id> mapProposalOrder = new Map<id,id>();
        mapProposalOrder.put(prop.id,order.id);
        
        Map<id,id> mapOrderCR = new Map<id,id>();
        mapOrderCR.put(order.id,credReq.id);
        
        Map<id,id> mapCROrder = new Map<id,id>();
        mapCROrder.put(credReq.id,order.id);
        
        Set<ID> setProp = new Set<ID>();
        setProp.add(prop.id);
        
        APTS_creditHelper objCls = new APTS_creditHelper();
        APTS_creditHelper.getOrderMAP(setOID);
        APTS_creditHelper.GenerateCR(setOID,mapOrder);
        APTS_creditHelper.GenerateOrder(CRSet,mapOrder);
        APTS_creditHelper.GenerateLicense(CRLI_lst);
        APTS_creditHelper.GenerateLineItems(setOID,mapProposalOrder,mapOrderCR);
        
        pro.Service_Type__c = 'Usage';
        update pro;
        
        APTS_creditHelper.GenerateLineItems(setOID,mapProposalOrder,mapOrderCR);
        objCls.SendForVerification(setProp);
        APTS_creditHelper.generateOrderLineItem(CRLI_lst,mapCROrder);
    }
}