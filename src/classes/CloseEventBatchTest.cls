//
// Appirio Inc. (c)
//
// A test class for an apex class "CloseEventBatch"
//
// 22nd of May, 2015         Sudhir Kr. Jagetiya        Original
//
@isTest
private class CloseEventBatchTest {
  static final Integer BULK_RECORD_LIMIT = 100;
  static final String SOBJECT_EVENT = 'Event';
  static final String EVENT_RECORD_TYPE_ACTION_PLAN_EVENT = 'Action Plan Event';
  static final Datetime SYSTEM_CURRENT_TIME = System.now().addSeconds(300);
  static final Map<String, Map<String, Id>> RECORD_TYPES = Utility.GetRecordTypeIdsBySObjectNameSet(new set<String>{SOBJECT_EVENT});

  // @description: a test method that validate the batch functionality
  // @param: none
  // @return: void
  // @author: Sudhir Kumar Jagetiya
	static testMethod void validateBatch() {
    Account account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
    insert account;

    Contact contact = TestDataSetupUtility.createTestContact(account.Id, 'Test Last Name', 'Test First Name', 'test@gmail.com');
    insert contact;

    List<Event> eventList = new List<Event>();
    for(Integer index = 0; index < BULK_RECORD_LIMIT; index++) {
    	eventList.add(new Event(ActivityDateTime = SYSTEM_CURRENT_TIME, DurationInMinutes = 15, Subject = 'Call', WhatId = account.Id, RecordTypeId = RECORD_TYPES.get(SOBJECT_EVENT).get(EVENT_RECORD_TYPE_ACTION_PLAN_EVENT)));
    	eventList.get(index).EventStatus__c = 'Open';
    }
    insert eventList;

    Test.startTest();
      //The code can't be validated in test class as we have a a check on last modified date (90 days prior from last modified date)
      //And this field can't be editable in test class.
      Database.executeBatch(new CloseEventBatch());
      String chronExpression = '' + SYSTEM_CURRENT_TIME.second() + ' ' + SYSTEM_CURRENT_TIME.minute() + ' ' + SYSTEM_CURRENT_TIME.hour() + ' ' + SYSTEM_CURRENT_TIME.day() + ' ' + SYSTEM_CURRENT_TIME.month() + ' ? ' + SYSTEM_CURRENT_TIME.year();
      system.schedule('CloseEventSchedule Test Class', chronExpression, new CloseEventSchedule());
    Test.stopTest();
	}
}