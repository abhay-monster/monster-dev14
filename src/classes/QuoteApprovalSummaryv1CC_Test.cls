@isTest
public class QuoteApprovalSummaryv1CC_Test {

    static Credit_Request__c  creditRequest;
    static Apttus_Approval__Approval_Request__c approvalRequest;
    
    static testmethod void QuoteApprovalSummaryTest(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Operations (NA)' LIMIT 1];
        User testUser = TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert testUser;
    
           system.runas(testUser){
                Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
                insert acc;
           
                Opportunity testOpp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
                insert testOpp;
                
                Apttus_Proposal__Proposal__c testAPP = TestDataSetupUtility.createApttusProposal(testOpp);
                testAPP.Apttus_Proposal__Account__c = acc.Id;
                insert testAPP; 
       
       
                Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'confirst1', 'conlast1', 'con1@email.com');
                insert con;
                Order__c orderRec = TestDataSetupUtility.createOrder(acc.Id, con.Id);
                insert orderRec;
                creditRequest = TestDataSetupUtility.createCreditRequest(orderRec.Id);
                insert creditRequest ;
                approvalRequest = new Apttus_Approval__Approval_Request__c ();
                approvalRequest.Apttus_Approval__Object_Id__c = creditRequest .Id;
                approvalRequest.Apttus_QPApprov__ProposalId__c = testAPP.id;
                insert approvalRequest ; 
                
                QuoteApprovalSummaryv1CC  controllerClass = new QuoteApprovalSummaryv1CC (new ApexPages.StandardController(approvalRequest ));
                controllerClass.apptus.RejectedReason__c = 'Test';
                ApexPages.currentPage().getParameters().put('Id',approvalRequest .id);
        
        
                controllerClass .approve();
                controllerClass .save();      
        }
    }
    

  }