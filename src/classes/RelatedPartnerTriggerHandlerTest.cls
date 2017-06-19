@isTest
private class RelatedPartnerTriggerHandlerTest{

 static testMethod void relatedPartner(){
 
     RelatedPartnerTriggerHandler relatedPartner = new RelatedPartnerTriggerHandler(true,3);
     Map<Id,RelatedPartner__c> oldMap = new Map<Id,RelatedPartner__c>();
     Map<Id,RelatedPartner__c> newMap = new Map<Id,RelatedPartner__c>();
     List<RelatedPartner__c> partnerLst = new List<RelatedPartner__c>();
     List<RelatedPartner__c> partnerLstNew = new List<RelatedPartner__c>();
     Account acc = new account(name='test',billingcountry='india');
     Account acc1 = new account(name='test1',billingcountry='india');
     acc.AgencyFlag__c = true;
     try{
        insert acc;
        insert acc1;
    }catch(Exception e){
            system.assert(false,'Account not created');
        }
     
     Test.startTest();
      RelatedPartnerTriggerHelper.NewTriggerHelper();
      RelatedPartner__c partner = TestDataSetupUtility.createTestRelatedPartner(acc1.id,acc.id);
      partnerLst.add(partner);
      relatedPartner.OnBeforeInsert(partnerLst); 
      insert partner;
      oldMap.put(partner.Id,partner);
      partner.Role__c = 'Broker';
      partnerLstNew.add(partner); 
      newMap.put(partner.Id,partner); 
      relatedPartner.OnBeforeUpdate(partnerLst,partnerLstNew ,newMap,oldMap);
      try{
        update partner;
      
      }catch(Exception e){
          system.assertEquals(false,e.getMessage().contains('if the partner is an agency'));
      }
      relatedPartner.OnUndeleted(partnerLst);
      relatedPartner.OnBeforeDelete(partnerLstNew,newMap);
      delete partner;
      
      undelete partner;
       
      //}catch(exception e){
      //    system.assert(false,'Related Partner Not inserted/updated/deleted');
     //}
     
     
     
     Test.stopTest();
 
 }
}