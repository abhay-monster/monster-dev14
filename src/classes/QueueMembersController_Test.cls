@isTest
Private Class QueueMembersController_Test{
    static Group testGroup;
    static testmethod void testQueueMembersController (){
        prepareData();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('queueId', testGroup.Id);
        QueueMembersController ctrl = new QueueMembersController ();
        System.assert(ctrl.queueId != null);
        System.assertNotEquals(ctrl.selectedQueue, null);
        System.assertEquals(ctrl.queueMembers.size(),1); 
        System.assert(ctrl.getQueueOptions().size() > 0);              
        ctrl.refresh();
        Test.stopTest();
    }
   
    static void prepareData(){
        testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        insert testQueue;
        GroupMember gm = new GroupMember ();
        gm.GroupId = testGroup.Id;
        gm.userOrGroupId = UserInfo.getUserId();
        insert gm;
       
    }

}