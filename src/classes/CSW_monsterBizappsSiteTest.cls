@isTest
private class CSW_monsterBizappsSiteTest{

  static testMethod void CSW_monsterBizapps(){

      Test.startTest();
      v3_monsterBizappsSiterouterSiterouterws.GetVersion_element obj = new v3_monsterBizappsSiterouterSiterouterws.GetVersion_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderItemResult obj1 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderItemResult ();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq obj2 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesReq();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryResponseItem obj3 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment obj4 = new v3_monsterBizappsSiterouterSiterouterws.LicenseAdjustment();
      v3_monsterBizappsSiterouterSiterouterws.submitOrderRequest_element obj5 = new v3_monsterBizappsSiterouterSiterouterws.submitOrderRequest_element();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseInfoByLicenseID_element obj6 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseInfoByLicenseID_element();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAdjustmentsResponse_element obj7 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAdjustmentsResponse_element();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq obj8 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesReq();
      v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element obj9 = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResult_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResponseItem obj10 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResult_element obj11 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResult_element();
      v3_monsterBizappsSiterouterSiterouterws.SubmitAdjustLicenseResult_element obj12 = new v3_monsterBizappsSiterouterSiterouterws.SubmitAdjustLicenseResult_element();
      v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem obj13 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp obj14 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResp();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp obj15 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfGetLicenseAndRelativesResp();
      v3_monsterBizappsSiterouterSiterouterws.transferInventoryRequest_element obj16 = new v3_monsterBizappsSiterouterSiterouterws.transferInventoryRequest_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryItem obj17 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTransferInventoryItem();
      v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem obj18 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryItem();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute obj19 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAttribute();
      v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element obj20 = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesRequest_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminateAllLicensesResponseItem obj21 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminateAllLicensesResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.Attribute obj22 = new v3_monsterBizappsSiterouterSiterouterws.Attribute();
      v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult obj23 = new v3_monsterBizappsSiterouterSiterouterws.AdjustmentItemResult();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfAdjustmentItemResult obj24 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfAdjustmentItemResult();
      v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesReq_element obj25 = new v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesReq_element();
      v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem obj26 = new v3_monsterBizappsSiterouterSiterouterws.TerminateAllLicensesResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.OrderItemResult obj27 = new v3_monsterBizappsSiterouterSiterouterws.OrderItemResult();
      v3_monsterBizappsSiterouterSiterouterws.ResponseResult obj28 = new v3_monsterBizappsSiterouterSiterouterws.ResponseResult();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseInfoByLicenseIDResponse_element obj29 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseInfoByLicenseIDResponse_element();
      v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense obj30 = new v3_monsterBizappsSiterouterSiterouterws.TerminatedLicense();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAdjustments_element obj31 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAdjustments_element();
      v3_monsterBizappsSiterouterSiterouterws.getLicenseAndRelativesRequest_element obj45 = new v3_monsterBizappsSiterouterSiterouterws.getLicenseAndRelativesRequest_element ();
      v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element obj32 = new v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse_element();
      v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element obj33 = new v3_monsterBizappsSiterouterSiterouterws.GetMultipleLicenseAndRelativesResp_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderLineItem obj34 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfOrderLineItem();
      v3_monsterBizappsSiterouterSiterouterws.SubmitOrderResult_element obj35 = new v3_monsterBizappsSiterouterSiterouterws.SubmitOrderResult_element();
      v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResult_element obj36 = new v3_monsterBizappsSiterouterSiterouterws.TransferInventoryResult_element();
      v3_monsterBizappsSiterouterSiterouterws.GetVersionResponse_element obj37 = new v3_monsterBizappsSiterouterSiterouterws.GetVersionResponse_element();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfLicenseAdjustment obj38 = new  v3_monsterBizappsSiterouterSiterouterws.ArrayOfLicenseAdjustment();
      v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminatedLicense obj39 = new v3_monsterBizappsSiterouterSiterouterws.ArrayOfTerminatedLicense();
      v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem obj40 = new v3_monsterBizappsSiterouterSiterouterws.GetLicenseAndRelativesResponseItem();
      v3_monsterBizappsSiterouterSiterouterws.OrderLineItem obj41 = new v3_monsterBizappsSiterouterSiterouterws.OrderLineItem ();
      v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfo_element obj42 = new v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfo_element();
      //v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse obj43 = new v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfoResponse();
      //v3_monsterBizappsSiterouterSiterouterws.legacy obj44 = new v3_monsterBizappsSiterouterSiterouterws.legacy();

      v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest ctrl = new v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest();
      //v3_monsterBizappsSiterouterSiterouterws.GetCompanyLicenseInfo(ctrl,'Test');
      Test.stopTest();
      }
   }