@isTest
public class SendEmailToCaseOwnerTest {
	static testmethod void testSendEmailToCaseOwner()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
        User testUser = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert testUser;    
        System.runAs(testUser) 
        {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            
            List<Id> ownerIdList = new List<Id>();
            for(Case cs : [select ownerId,id from Case])
            {
                ownerIdList.add(cs.ownerId);
            }
            Group GrpEmailQueue = new Group(Name='test group', Type='Queue',email='test@abc.com');
            insert GrpEmailQueue;
            QueueSobject testQueue = new QueueSObject(QueueId = GrpEmailQueue.Id, SobjectType = 'Case');
            insert testQueue;
            GroupMember gm = new GroupMember ();
            gm.GroupId = GrpEmailQueue.Id;
            gm.userOrGroupId = testUser.Id;
            insert gm;
            /*Group GrpEmailQueue = [Select id, Email From Group where id IN: ownerIdList and Email !=null LIMIT 1];
            GroupMember  gm = [Select Id, UserOrGroupId,GroupId,Group.type 
                               From GroupMember Where GroupId = :GrpEmailQueue.Id limit 1];
                                  
            Case cs = [select id,ownerId from Case Limit 1 ];
            cs.OwnerId = GrpEmailQueue.Id;
            update cs;
 			*/
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.BillingCountry = 'Philippines';
            testAccount.PrimaryServiceRep__c = testUser.id;
            testAccount.Organization__c = 'Europe';
            testAccount.ServiceTier__c = 'Core';
            insert testAccount;
            Contact testContact1 = TestDataSetupUtility.createTestContact(testAccount.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
            testContact1.PrimaryBillingContact__c = true;
            insert testContact1;
            
            map<String, map<String, Id>> CaseRecordTypes = Utility.GetRecordTypeIdsBySObjectNameSet(new set<string>{'Case'});
            Id caseProductImplementationRecordTypeId = CaseRecordTypes.get('Case').get('Product Implementation');
            Id caseGCSRecordTypeId = CaseRecordTypes.get('Case').get('GCS');

            Case mainCase = new Case(
                AccountId = testAccount.Id,
                ContactId = testContact1.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent' ,
            	RecordTypeId = caseProductImplementationRecordTypeId,            	
            	OwnerId = GrpEmailQueue.Id
            );
            insert mainCase;
            SendEmailToCaseOwner.sendEmail(mainCase.Id);
            
            system.assertEquals(mainCase.OwnerId, GrpEmailQueue.Id);
        }   
    }
}