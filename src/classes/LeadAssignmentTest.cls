/**
 * Appirio, Inc
 * Name             : LeadAssignmentTest
 * Created Date     : 12 Sept 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for LeadAssignment
 */
@isTest
private class LeadAssignmentTest {

    static testMethod void myUnitTest() {
        List<User> users = new List<User>();
        users.add(TestDataSetupUtility.createTestUser('Test User-1', 'first', Userinfo.getProfileId()));
        users.add(TestDataSetupUtility.createTestUser('Test User-2', 'second', Userinfo.getProfileId()));
        users.add(TestDataSetupUtility.createTestUser('Test User-3', 'third', Userinfo.getProfileId()));
        users.add(TestDataSetupUtility.createTestUser('Test User-4', 'forth', Userinfo.getProfileId()));
        users.add(TestDataSetupUtility.createTestUser('Test User-5', 'fifth', Userinfo.getProfileId()));
        insert users;
        
        // Create Assignment rules
        List<Lead_Routing_Rules__c> rules = new List<Lead_Routing_Rules__c>();
        Group g1 = new Group(Name='My test queue', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
        insert q1;        
        
        System.runAs(users.get(4)) {
            
            // US
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-1-USA', Country__c = 'United States', City__c = 'New York', Zipcode_To__c = '100', ZipCode_From__c = '22', User__c = users.get(0).id, Sequence__c = 1));
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-2-USA', Country__c = 'United States', City__c = 'New York', Zipcode_To__c = '120', ZipCode_From__c = '101', Queue__c = 'My test queue', Sequence__c = 2));
            
            //India and Industry 
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-3', Annual_Revenue__c = 100000, Country__c = 'India', Industry__c = 'Goverment', Criteria__c = '>', Employees__c = 100, Lead_Source__c = 'Web', Sequence__c = 3, User__c = users.get(2).id));
            
            // Should be no Lead with this criteria and Lead will go to queue
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-4', Country__c = 'India', Lead_Source__c = 'Test', Country_Catch_All__c = true, Queue__c = 'My test queue', Sequence__c = 4));
            
            //India and Industry but has Queue__c instead of User
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-5', Country__c = 'India', Industry__c = 'Finance', Sequence__c = 5, Queue__c = 'My test queue'));
            
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-6', Annual_Revenue__c = 100000, Employees__c = 100, Country__c = 'India', Criteria__c = '<', User__c = users.get(2).id, Sequence__c = 6)); 
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-7', Annual_Revenue__c = 100000, Employees__c = 100, Country__c = 'India', Criteria__c = '=', User__c = users.get(4).id, Sequence__c = 7));         
            
            rules.add(new Lead_Routing_Rules__c(Name = 'Rule-8-USA', Country__c = 'United States', City__c = 'New York', Zipcode_To__c = '302010', ZipCode_From__c = '302001', Queue__c = 'My test queue', Sequence__c = 8));
            
            insert rules;
            
            // Insert Leads
            List<Lead> leads = new List<Lead>();
            leads.add(TestDataSetupUtility.createTestLead()); // USA
            leads.add(TestDataSetupUtility.createTestLead()); // USA but instead of User, Queue should be populated
            leads.add(TestDataSetupUtility.createTestLead()); // India and has Rule 3
            leads.add(TestDataSetupUtility.createTestLead()); //  no rules but catch all is true
            leads.add(TestDataSetupUtility.createTestLead()); // Rule 5, Same as Rule 3 but queue is populated instead of user
            leads.add(TestDataSetupUtility.createTestLead()); // Rule 6, Anual revenue is leass than 100000
            leads.add(TestDataSetupUtility.createTestLead()); // Rule 7, Anual revenue is 100000
            leads.add(TestDataSetupUtility.createTestLead()); // Rule 8, no matching Lead
            
            leads.get(0).Posting_Zip_Postal_Code__c = '22'; // Rule 1
            leads.get(0).Posting_Country__c = 'United States';
            leads.get(1).Posting_Zip_Postal_Code__c = '110'; // Rule 2
            leads.get(1).Posting_Country__c = 'United States';
            
            leads.get(2).Posting_Country__c = 'India'; // Rule 3
            leads.get(2).Industry = 'Goverment'; // Rule 3
            leads.get(2).NumberOfEmployees = 140; // Rule 3
            leads.get(2).LeadSource = 'Web'; // Rule 3  
            leads.get(2).AnnualRevenue = 1000000; // Rule 3   
            
            leads.get(3).Posting_Country__c = 'India'; // Rule 4
            leads.get(3).Industry = 'Communications'; // Rule 4
            leads.get(3).LeadSource = 'Public Relations'; // Rule 4                               
            
            // Rule 5
            leads.get(4).Posting_Country__c = 'India'; 
            leads.get(4).Industry = 'Finance'; 
            
            // rule 6
            leads.get(5).Posting_Country__c = 'India'; 
            leads.get(5).AnnualRevenue = 1000;      
            
            // rule 7
            leads.get(6).Posting_Country__c = 'India'; 
            leads.get(6).AnnualRevenue = 100000;                                
            
            Test.startTest();
            
            insert leads;
            
            Test.stopTest();
        
            //System.assertEquals(users.get(0).id, [Select ID, ownerID from Lead Where ID =:leads.get(0).id].ownerID);
            //System.assertEquals(g1.id, [Select ID, ownerID from Lead Where ID =:leads.get(1).id].ownerID);
            
            //System.assertEquals(users.get(2).id, [Select ID, ownerID from Lead Where ID =:leads.get(2).id].ownerID);
            //System.assertEquals(g1.id, [Select ID, ownerID from Lead Where ID =:leads.get(3).id].ownerID);
            
            //System.assertEquals(g1.id, [Select ID, ownerID from Lead Where ID =:leads.get(4).id].ownerID);
            //System.assertEquals(users.get(2).id, [Select ID, ownerID from Lead Where ID =:leads.get(5).id].ownerID);
            //System.assertEquals(users.get(4).id, [Select ID, ownerID from Lead Where ID =:leads.get(6).id].ownerID);
            
        }
    }
}