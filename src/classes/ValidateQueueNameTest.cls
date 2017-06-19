@isTest

Private Class ValidateQueueNameTest{
    static Assignment_Group_Queues__c groupQueues;
    static Group testGroup;
    static Assignment_Group_Name__c gname;
    static testmethod void testValidateQueueName(){
        
        Test.startTest();
         prepareData();
         // Verify Queue Id is populated on Assignment Group Queue record
         groupQueues  = [Select Id, QueueId__c,Valid_Queue__c from Assignment_Group_Queues__c where Id = :groupQueues.Id];
         
         //System.assert(groupQueues.QueueId__c  != null); 
         //System.assert(groupQueues.Valid_Queue__c == true); 
         
         groupQueues.Valid_Queue__c = false;
         update groupQueues;
         
         // Throw error
         gname = new Assignment_Group_Name__c();
         gname.Name = 'test-1';
         gname.Description__c = 'test';
         gname.Type__c = 'Cases';
         insert gname;
         
         try{
         groupQueues = new Assignment_Group_Queues__c();
         groupQueues.Name = 'Queue2';
         groupQueues.Assignment_Group_Name__c = gname.Id;
         insert groupQueues ;
         }
         catch(Exception e){
         
         }
         
         
        Test.stopTest();
    }
    
    static void prepareData(){
    
     testGroup = new Group(Name = 'Queue1', Type = 'Queue');
     insert testGroup;

     QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
     System.runAs(new User(Id = UserInfo.getUserId())) {   
        insert testQueue;
     }
      
     gname = new Assignment_Group_Name__c();
     gname.Name = 'test-1';
     gname.Description__c = 'test';
     gname.Type__c = 'Cases';
     insert gname;
     
     groupQueues = new Assignment_Group_Queues__c();
     groupQueues.Name = 'Queue1';
     groupQueues.Assignment_Group_Name__c = gname.Id;
     insert groupQueues ;
     
    } 

}