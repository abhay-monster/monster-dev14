@isTest
private class ArchiveQuoteBatchTest {
	static List <Apttus_Proposal__Proposal__c> proList;
	static {
		Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
		insert acc;
		Contact con = TestDataSetupUtility.createTestContact(acc.Id, 'PrimaryBillingTestLastnameOne', 'PrimaryBillingTestFirstnameOne', 'email1@testContact.com');
		con.PrimaryBillingContact__c = true;
		insert con;
		Id oppRT = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
		Opportunity opp = TestDataSetupUtility.createTestOpportunity('test', acc.Id);
		opp.InternationalDeal__c = true;
		opp.recordTypeId = oppRT;

		Opportunity opp1 = TestDataSetupUtility.createTestOpportunity('test', acc.Id);
		opp1.InternationalDeal__c = true;
		opp1.recordTypeId = oppRT;
		opp1.StageName = 'Order Placed';
		insert (new List<Opportunity>{opp,opp1}); 
		

		Id CreditOrderRecordType = Utility.GetRecordTypeIdBySObjectNameAndType('Order__c', 'Credit');
		Order__c order1 = TestDataSetupUtility.createOrder(acc.Id);
		order1.OrderStatus__c = 'Sent To Verification';
		order1.RecordTypeId = CreditOrderRecordType;
		order1.Opportunity__c = opp.Id;
		order1.BillingAccount__c = acc.id;
		order1.BillingContact__c = con.id;
		order1.Posting_Contact__c = con.id;
		insert order1;
		//Inserting proposal line item with old created dates
		 
		proList = new List < Apttus_Proposal__Proposal__c > ();

		Date dtOneYear = Date.today().addYears(-1);
		dtOneYear = dtOneYear.addDays(-1);
		String strOneYear = dtOneYear.year() + '-'+ dtOneYear.month() + '-' + dtOneYear.day()+ 'T00:01:26.000+0000';
		String proJson1 = '{"CreatedDate":"'+strOneYear+'"}';
		Apttus_Proposal__Proposal__c pro1 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJson1, Apttus_Proposal__Proposal__c.class );
		pro1.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal1';
        pro1.Apttus_Proposal__Account__c = acc.Id;
        pro1.Apttus_Proposal__Opportunity__c = opp.Id;
        pro1.Selling_Country__c ='United States';
        pro1.Language__c ='English';
		proList.add(pro1);

		
		Apttus_Proposal__Proposal__c pro2 = TestDataSetupUtility.createProposal('Test Proposal1', null, opp.Id, 'Accepted Online', false);
		proList.add(pro2);
		 
		Date dtNineMonths = Date.today().addMonths(-9);
		dtNineMonths = dtNineMonths.addDays(-1);
		String strNineMonths = dtNineMonths.year() + '-'+ dtNineMonths.month() + '-' + dtNineMonths.day()+ 'T00:01:26.000+0000';
		String proJson2 = '{"CreatedDate":"'+strNineMonths+'"}';
		Apttus_Proposal__Proposal__c pro3 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJson2, Apttus_Proposal__Proposal__c.class );
		pro3.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal2';
        pro3.Apttus_Proposal__Account__c = acc.Id;
        pro3.Apttus_Proposal__Opportunity__c = opp.Id;
        pro3.Selling_Country__c ='United States';
        pro3.Language__c ='English';
		proList.add(pro3);


		Date dtThreeYear = Date.today().addYears(-3);
		dtThreeYear = dtThreeYear.addDays(-1);
		String strThreeYear = dtThreeYear.year() + '-'+ dtThreeYear.month() + '-' + dtThreeYear.day()+ 'T00:01:26.000+0000';
		String proJson3 = '{"CreatedDate":"'+strThreeYear+'"}';
		Apttus_Proposal__Proposal__c pro4 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJson3, Apttus_Proposal__Proposal__c.class );
		pro4.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal3';
        pro4.Apttus_Proposal__Account__c = acc.Id;
        pro4.Apttus_Proposal__Opportunity__c = opp1.Id;
        pro4.Selling_Country__c ='United States';
        pro4.Language__c ='English';
		proList.add(pro4);

		Apttus_Proposal__Proposal__c pro5 = TestDataSetupUtility.createProposal('Test Proposal1', null, opp.Id, 'Accepted Online', false);
		proList.add(pro5);

		Apttus_Proposal__Proposal__c pro6 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJson1, Apttus_Proposal__Proposal__c.class );
		pro6.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal4';
        pro6.Apttus_Proposal__Account__c = acc.Id;
        pro6.Apttus_Proposal__Opportunity__c = opp.Id;
        pro6.Selling_Country__c ='United States';
        pro6.Language__c ='English'; 
        pro6.NSSAType__c = 'Long Term Contract';
		proList.add(pro6); 
		
		
		Date dtFiveYear = Date.today().addYears(-5);
		dtFiveYear = dtFiveYear.addDays(-1);
		String strFiveYear = dtFiveYear.year() + '-'+ dtFiveYear.month() + '-' + dtFiveYear.day()+ 'T00:01:26.000+0000';
		String proJson5 = '{"CreatedDate":"'+strFiveYear+'"}';
		Apttus_Proposal__Proposal__c pro7 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJson5, Apttus_Proposal__Proposal__c.class );
		pro7.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal5';
        pro7.Apttus_Proposal__Account__c = acc.Id;
        pro7.Apttus_Proposal__Opportunity__c = opp1.Id;
        pro7.Selling_Country__c ='United States';
        pro7.Language__c ='English';
        pro7.NSSAType__c = 'Long Term Contract';
		proList.add(pro7);


		Date dtTwoYear = Date.today().addYears(-2);
		dtTwoYear = dtTwoYear.addDays(-1);
		String strTwoYear = dtTwoYear.year() + '-'+ dtTwoYear.month() + '-' + dtTwoYear.day()+ 'T00:01:26.000+0000';
		String proJsonTwo = '{"CreatedDate":"'+strTwoYear+'"}';
		Apttus_Proposal__Proposal__c pro8 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJsonTwo, Apttus_Proposal__Proposal__c.class );
		pro8.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal6';
        pro8.Apttus_Proposal__Account__c = acc.Id;
        pro8.Apttus_Proposal__Opportunity__c = opp1.Id;
        pro8.Selling_Country__c ='United States';
        pro8.Language__c ='English';
        pro8.NSSAType__c = 'Long Term Contract';
        pro8.QuoteStatus__c = 'In Progress' ;
		proList.add(pro8); 


		Date dtYesterday = Date.today().addDays(-1);
		String strYesterday = dtYesterday.year() + '-'+ dtYesterday.month() + '-' + dtYesterday.day()+ 'T00:01:26.000+0000';
		String proJsonYesterday = '{"CreatedDate":"'+strYesterday+'"}';
		Apttus_Proposal__Proposal__c pro9 = (Apttus_Proposal__Proposal__c) JSON.deserialize(proJsonYesterday, Apttus_Proposal__Proposal__c.class );
		pro9.Apttus_Proposal__Proposal_Name__c = 'Proposal for Test Proposal7';
        pro9.Apttus_Proposal__Account__c = acc.Id;
        pro9.Apttus_Proposal__Opportunity__c = opp1.Id;
        pro9.Selling_Country__c ='United States';
        pro9.Language__c ='English';
        pro9.NSSAType__c = 'Long Term Contract';
        pro9.QuoteStatus__c = 'Expired';
        pro9.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(-100);
		proList.add(pro9); 

		insert proList;
		Apttus_Proposal__Proposal_Line_Item__c lineitem1 = TestDataSetupUtility.createProposalLineItem(pro1.Id);
		lineitem1.Apttus_QPConfig__OptionPrice__c = null;
		lineitem1.Apttus_QPConfig__LineStatus__c = 'New';
		lineitem1.APTS_Is_Agency_Commission_Different__c = 1;
		lineitem1.Apttus_QPConfig__NetPrice__c = 10000;
		lineitem1.APTS_Extended_List_Price__c = 100;
		lineitem1.Apttus_QPConfig__BaseExtendedPrice__c = 1;


		Apttus_Proposal__Proposal_Line_Item__c lineitem2 = TestDataSetupUtility.createProposalLineItem(pro2.Id);
		lineitem2.Apttus_QPConfig__OptionPrice__c = null;
		lineitem2.Apttus_QPConfig__LineStatus__c = 'New';
		lineitem2.APTS_Is_Agency_Commission_Different__c = 1;
		lineitem2.Apttus_QPConfig__NetPrice__c = 10000;
		lineitem2.APTS_Extended_List_Price__c = 100;
		lineitem2.Apttus_QPConfig__BaseExtendedPrice__c = 1;


		Apttus_Proposal__Proposal_Line_Item__c lineitem3 = TestDataSetupUtility.createProposalLineItem(pro2.Id);
		lineitem3.Apttus_QPConfig__OptionPrice__c = null;
		lineitem3.Apttus_QPConfig__LineStatus__c = 'New';
		lineitem3.APTS_Is_Agency_Commission_Different__c = 1;
		lineitem3.Apttus_QPConfig__NetPrice__c = 10000;
		lineitem3.APTS_Extended_List_Price__c = 100;
		lineitem3.Apttus_QPConfig__BaseExtendedPrice__c = 1;



		Apttus_Proposal__Proposal_Line_Item__c lineitem4 = TestDataSetupUtility.createProposalLineItem(pro4.Id);
		lineitem4.Apttus_QPConfig__OptionPrice__c = null;
		lineitem4.Apttus_QPConfig__LineStatus__c = 'New';
		lineitem4.APTS_Is_Agency_Commission_Different__c = 1;
		lineitem4.Apttus_QPConfig__NetPrice__c = 10000;
		lineitem4.APTS_Extended_List_Price__c = 100;
		lineitem4.Apttus_QPConfig__BaseExtendedPrice__c = 1;
		 
		
		 
		
		
		insert(new List < Apttus_Proposal__Proposal_Line_Item__c > {   
			lineitem1, lineitem2 , lineitem3,lineitem4
		});


	}
	static testMethod void testBatch() {
		Test.startTest(); 
		User sysAdmin = TestDataSetupUtility.createUser('System Administrator', true);
		BatchUser__c batchuser = TestDataSetupUtility.createBatchUser(sysAdmin.Id);
		insert batchUser;
		System.runAs(sysAdmin) {
			ArchiveQuoteBatch c = new ArchiveQuoteBatch();
			Database.executeBatch(c);
			List<Apttus_Proposal__Proposal__c> newList1 = [ SELECT Id,Apttus_Proposal__Account__c,NSSAType__c 
														FROM Apttus_Proposal__Proposal__c WHERE 
														ArchivalStatus__c = 'Expired'];
			List<Apttus_Proposal__Proposal__c> newList2 = [ SELECT Id,Apttus_Proposal__Account__c,NSSAType__c 
														FROM Apttus_Proposal__Proposal__c WHERE 
														ArchivalStatus__c = 'Archived'];

			System.assert(newList1 != null,'Records have been expired');
			System.assert(newList2 != null , 'Records have been archived'); 
			
			 
		}
		Test.stopTest();
	}
}