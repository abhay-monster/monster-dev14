@isTest
public class TransferAndAdjustmentProcessCC_Test {
    static testmethod void TransferAndAdjustmentProcess_Test(){

        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'Site Integration';
        endpoint.Name = 'Site Integration';
        insert endpoint;

        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'Site Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;


       Account acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;

        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp ', acc.Id);
        insert opp;

        Apttus_Proposal__Proposal__c quote = TestDataSetupUtility.createApttusProposal(opp);
        insert quote;
        Apttus_Proposal__Proposal__c APP = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Id = :quote.Id];
        System.assertEquals(quote.Id, app.Id);

        Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
        insert con;
        Order__c ord = TestDataSetupUtility.createOrder(acc.Id, con.Id);
        ord.Opportunity__c = opp.Id;
        ord.QuoteProposal__c = quote.Id;
        insert ord;

        List<Order_Line_Item__c> OLIList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oli = TestDataSetupUtility.createOrderLineItem(ord.Id);
        OLIList.add(oli);
        insert oli;

        LicenseID__c lId = new LicenseID__c();
        lId.OrderLineItem__c = oli.Id;
        lId.MAPP_OrderLineItem__c = oli.Id;
        lId.SiteLicenseID__c = '1234';
        lId.AvailableInventory__c = 10;

        insert lId;


        ApexPages.currentPage().getParameters().put('Id',oli.id);
        ApexPages.currentPage().getParameters().put('type','adjustment');

        TransferAndAdjustmentProcessCC controller = new TransferAndAdjustmentProcessCC();
        controller.ProcessType = 'adjustment';
        controller.init();
        for(TransferAndAdjustmentProcessCC.LicenseIDWrap wrap : controller.LicenseIDList){
            wrap.IsAdded = true;
        }

      	PageReference ref = null;
        controller.LicenseIDClicked = lId.Id;
        controller.AddLicense();
        controller.CreateLines();
        controller.DeleteLines();
        controller.SyncLicenses();
        controller.ChangeProcess();
        controller.save();
        controller.back();
        controller.getBackURL();
        controller.upload();

        String str = controller.getUploadURL();
        Order_Line_Item__c[]  OrderLineItemList = controller.OrderLineItemList;
        LicenseID__c CurrentLicenseID = controller.CurrentLicenseID;
        Boolean ShowTransferParts = controller.ShowTransferParts;
        Boolean ShowAdjustmentParts = controller.ShowAdjustmentParts;
        String LineToAdd = controller.LineToAdd;
        String ProcessTypeText  = controller.ProcessTypeText;
        SelectOption[] ProcessTypeOptionList = controller.ProcessTypeOptionList;
        SelectOption[] AdjustmentTypeOptions = controller.AdjustmentTypeOptions;
        Boolean DisableSave = controller.DisableSave;
        String InitMessage = controller.InitMessage;
        SelectOption[] LineNumOptionList = controller.LineNumOptionList;
        Boolean HasSyncError = controller.HasSyncError;

    }

}