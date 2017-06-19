@isTest

private with sharing class OpportunityTriggerTest{

  /*static final Integer BULK_RECORD_LIMIT = 100;
  static final String SOBJECT_TASK = 'Task';
  static final String TASK_RECORD_TYPE_ACTION_PLAN_EVENT = 'Action Plan';
  static final Datetime SYSTEM_CURRENT_TIME = System.now().addSeconds(300);
  static final Map<String, Map<String, Id>> RECORD_TYPES = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{SOBJECT_TASK});*/
  static Personal_Settings__c personalSettings;
  static IntegrationConfig__c integConfigSettings;
  static WebServiceEndpoint__c wsEndpoint;
  static Account testacc1 = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST AB Account');
  static Opportunity testOpportunity1 = TestDataSetupUtility.createTestOpportunity('Test AB Opportunity', testacc1.Id);
  static List<Opportunity> listOpp = new List<Opportunity>();
  static OpportunityTriggerHelper oppHelper = new OpportunityTriggerHelper();
  static User testuser;
  static Account_Team_Member__c testTeamMember = new Account_Team_Member__c();
  static {

      Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
      insert testuser;

      personalSettings = TestDataSetupUtility.buildPersonalSetting();
      personalSettings.Trigger_Opportunity__c = true;
      insert personalSettings;
      Method_Kill_List__c testCustomSetting = new Method_Kill_List__c(Name='updateOpptySplit', Kill_Method__c=false);
      insert testCustomSetting;

      integConfigSettings = new IntegrationConfig__c(Name ='USPS Integration',
                                                                Timeout__c=60000,
                                                                IsPaypalTest__c=true,
                                                                EndpointName__c='USPSAddressValidation',
                                                                Username__c='562CLOUD2615');
      insert integConfigSettings;

      wsEndpoint = new WebServiceEndpoint__c(Name='USPSAddressValidation', Endpoint__c='http://production.shippingapis.com/ShippingAPI.dll');
      insert wsEndpoint;

      testacc1.CreditStatus__c = 'OK';
      testacc1.KeyInitiative__c='New Business/Winback';
      testacc1.ownerId=testuser.Id;
   	  insert testacc1;

      testOpportunity1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();

      listOpp.add(testOpportunity1);
      insert listOpp;
      Opportunity o = [SELECT RecordTypeId from Opportunity where Id =:listOpp[0].id];
      System.assertEquals(testOpportunity1.RecordTypeId, o.RecordTypeId);
      oppHelper.CreateOpportunityIdSet(listOpp);

  }


  static testMethod void testSLAMissed() {
     Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
      insert testuser;

      Account acc = TestDataSetupUtility.createTestAccount('testacc', null,null);
      acc.Organization__c = 'North America';
      insert acc;
      Opportunity opp = TestDataSetupUtility.createTestOpportunity('testOpp',acc.Id);
      insert opp;

      opp.SLA_Missed__c = true;
      update opp;

      // Verify SLA missed chatter post created
      List<FeedItem> feedItems = [Select Id, body From FeedItem Where parentId = :opp.Id];
  }
}