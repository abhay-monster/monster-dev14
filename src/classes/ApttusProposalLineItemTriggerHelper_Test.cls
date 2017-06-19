@isTest
public class ApttusProposalLineItemTriggerHelper_Test {


	static testMethod void testApttusProposalLineItemTriggerHelper(){
	    Apttus_Proposal__Proposal__c proposal = null;
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		
		
	   
	  /* account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
	   insert account;*/
	        
	        
	        //create Opportunity
	   Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acct.Id);
	   opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
	   insert opp;
	        
       proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, opp.Id, 'test', false);
	   insert proposal;
        
	        //Create product2
	   Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
	   product.Convert_From__c = true;
       product.APTPS_Rev_Share__c=10;
       product.APTPS_Rev_Share_Type__c='Net';
	   insert product;
	   
	   Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	   insert priceList; 
	        
	   
	   proposal_n = TestDataSetupUtility.createProposal('Test Proposal', acct.Id, opp.Id, 'Accepted Online', false);
	   proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
       proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
       proposal_n.Language__c = 'English';
	   
	   Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,acct,priceList);
       config.Apttus_Config2__Status__c = 'Saved';
       insert config;
       config.Apttus_Config2__Status__c = 'Finalized';
       update config;
       
       
       Apttus_Config2__LineItem__c lineitem = TestDataSetupUtility.createLineItemApttus(config.ID);
       insert lineitem;
       
       Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
            pav.Apttus_Config2__LineItemId__c = lineitem.ID;
            pav.CurrencyIsoCode = 'USD';
            pav.Product_Type__c = 'Sourcing Services-GL';
            insert pav;
        
	   Apttus_Proposal__Proposal_Line_Item__c propLineItem = New Apttus_Proposal__Proposal_Line_Item__c();
	   propLineItem.Apttus_QPConfig__ConfigurationId__c = config.Id;
	   propLineItem.Apttus_QPConfig__NetPrice__c=3400;
	   propLineItem.Apttus_QPConfig__BaseExtendedPrice__c=2040;
	   propLineItem.Apttus_Proposal__Proposal__c =proposal.Id; 
       propLineItem.Apttus_QPConfig__OptionId__c = null;
       propLineItem.Rev_Share_Type__c='Net';
       propLineItem.Apttus_QPConfig__OptionId__c=product.ID;
       propLineItem.Rev_Share__c=10;
       propLineItem.Apttus_QPConfig__DerivedFromId__c = lineitem.Id;
      // propLineItem.Configuration_Status__c = 'Finalized';
	   insert propLineItem;
	   
	   Apttus_Proposal__Proposal_Line_Item__c temp1 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
	       											  Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
	        										  Apttus_QPConfig__Comments__c,Apttus_QPConfig__OptionId__c,Rev_Share_Type__c,Rev_Share__c,Net_Total__c,Gross_Total__c,Rev_Share_Amount__c,
	        										  Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where id=:propLineItem.ID];
	   
	   System.debug ( logginglevel.error,'hellllo: ' + temp1.Configuration_Status__c);
        System.debug ( logginglevel.error,'hellllo Base Price: ' + temp1.Apttus_QPConfig__BaseExtendedPrice__c);
	   
	   List<Apttus_Proposal__Proposal_Line_Item__c> listLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
	   listLineItem.add(temp1);
	   
	   Terms_and_Conditions__c term=new Terms_and_Conditions__c();
            term.Name='testTerm';
            term.Product__c=propLineItem.Apttus_Proposal__Product__c;
            term.Language__c=propLineItem.Quote_Language__c;
            
            /*
            Terms_and_Conditions__c term2 = new Terms_and_Conditions__c();
            term2.Name = 'testTerm2';
            term2.Product__c = propLineItem3.Apttus_Proposal__Product__c;
            term2.Language__c = propLineItem3.Quote_Language__c;
            */
            Terms_and_Conditions__c term1=new Terms_and_Conditions__c();
            term1.Name='testTerm';
            term1.Product__c=propLineItem.Apttus_Proposal__Product__c;
            term1.Language__c=propLineItem.Quote_Language__c;
            
            //term.T_and_C_External_ID__c = proposal_n.Id;
            insert term;
            //insert term2;
            insert term1;
            
          //create Controlling_Attribute_workflow_Object__c list
	        
	        List<Controlling_Attribute_workflow_Object__c> controllingAttributeWorkflowList=new List<Controlling_Attribute_workflow_Object__c>();
	        
	         
	        Controlling_Attribute_workflow_Object__c controlling1 = new Controlling_Attribute_workflow_Object__c();
	        controlling1.Controlling_attributes__c = 'Selling_Country__c';
	        controlling1.Attribute_type__c= 'Proposal';
	        controlling1.attribute_values__c = 'United States';
	        controllingAttributeWorkflowList.add(controlling1);
	        
	        Controlling_Attribute_workflow_Object__c controlling2 = new Controlling_Attribute_workflow_Object__c();
	        controlling2.Controlling_attributes__c = 'Product_Type__c';
	        controlling2.Attribute_type__c= 'Product';
	        controlling2.attribute_values__c = 'Sourcing Services-GL';
	        controllingAttributeWorkflowList.add(controlling2);
	        
	        Controlling_Attribute_workflow_Object__c controlling3 = new Controlling_Attribute_workflow_Object__c();
	        controlling3.Controlling_attributes__c = 'Selling_Country__c';
	        controlling3.Attribute_type__c= 'Proposal';
	        controlling3.attribute_values__c = 'United States';
	        controllingAttributeWorkflowList.add(controlling3);
	        
	        insert controllingAttributeWorkflowList;
	        
	        
	       
	        
	        Dependent_Attribute_workflow_object__c dependent1 = new Dependent_Attribute_workflow_object__c();
	        dependent1.Attribute_type__c = 'Language T & C';
	        dependent1.DEP_attrib_values__c = 'English';
	        insert dependent1;
	        
            List<Attribute_workfow_junction_object__c> jterms=new List<Attribute_workfow_junction_object__c>();

	        Attribute_workfow_junction_object__c attr_junction_obj = new Attribute_workfow_junction_object__c();
	        attr_junction_obj.Controlling_Attribute_workflow_Object__c = controlling1.Id;
	        attr_junction_obj.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj.Product_Group__c=product.Id;//propLineItem2.Apttus_Proposal__Product__c;

	        jterms.add(attr_junction_obj);
	        
	        Attribute_workfow_junction_object__c attr_junction_obj2 = new Attribute_workfow_junction_object__c();
	        attr_junction_obj2.Controlling_Attribute_workflow_Object__c = controlling3.Id;
	        attr_junction_obj2.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj2.Product_Group__c= product.Id;//propLineItem2.Apttus_Proposal__Product__c;
	        jterms.add(attr_junction_obj2);
	        
	        Attribute_workfow_junction_object__c attr_junction_obj1 = new Attribute_workfow_junction_object__c();
	        attr_junction_obj1.Controlling_Attribute_workflow_Object__c = controlling2.Id;
	        attr_junction_obj1.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj1.Product_Group__c=product.Id;//propLineItem3.Apttus_Proposal__Product__c;
	        jterms.add(attr_junction_obj1);
	        
	        insert jterms;
            
            attr_junction_obj = [select id ,Controlling_Attribute_workflow_Object__c,Dependent_Attribute_workflow_object__c,
            Product_Group__c from Attribute_workfow_junction_object__c where id = : attr_junction_obj.ID ];
            
            update attr_junction_obj;
            
            attr_junction_obj1 = [select id ,Controlling_Attribute_workflow_Object__c,Dependent_Attribute_workflow_object__c,
            Product_Group__c from Attribute_workfow_junction_object__c where id = : attr_junction_obj1.ID ];
            
            update attr_junction_obj1;
            
            Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		    insert prodAttrGrp;
		
		    Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		    prodAttrGrpMember.Apttus_Config2__ProductId__c = product.Id;
		    insert prodAttrGrpMember;
		
		    Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='CurrencyIsoCode',Apttus_Config2__Sequence__c=6);
		    prodAttr.Show_on_Report__c = true;
		    List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		    insert listProdAttr;
            
            List<Karma_To_SFDC_Product_Name_Translation__c> karma_list = new List<Karma_To_SFDC_Product_Name_Translation__c>();

            Karma_To_SFDC_Product_Name_Translation__c karma = new Karma_To_SFDC_Product_Name_Translation__c();
            karma.SFDC_Product_Name__c = product.Id;
            karma.Attribute_Value__c = pav.ID;
            karma.Attribute_Field__c = 'All';
            karma_list.add(karma);
            
            Karma_To_SFDC_Product_Name_Translation__c karma2 = new Karma_To_SFDC_Product_Name_Translation__c();
            karma2.Attribute_Field__c = 'All';
            karma2.Attribute_Value__c = pav.ID;
            karma2.SFDC_Product_Name__c = product.Id;
            karma_list.add(karma2);
            
            Karma_To_SFDC_Product_Name_Translation__c karma3 = new Karma_To_SFDC_Product_Name_Translation__c();
            karma3.Attribute_Field__c = 'PositionsPerInventory';
            karma3.Attribute_Value__c = pav.ID;
            karma3.SFDC_Product_Name__c = product.Id;
            karma_list.add(karma3);
            
            insert karma_list;
            
            List<Translated_Product_Attribute__c> tpa_list = new List<Translated_Product_Attribute__c>();
            Translated_Product_Attribute__c tpa = new Translated_Product_Attribute__c(Name = 'test tpa');
            tpa.Language__c = 'English';
            tpa.Product__c = product.Id;
            tpa.English_Value__c = 'test tpa';
            tpa.Type__c = 'Attribute Name';
            tpa_list.add(tpa);
            
            Translated_Product_Attribute__c tpa2 = new Translated_Product_Attribute__c(Name = 'test tpa2');
            tpa2.Language__c = 'French';
            tpa2.Product__c = product.Id;
            tpa2.English_Value__c = 'test tpa2';
            tpa2.Type__c = 'Product Name';
            tpa2.Translated_Value__c = 'test tpa2';
            tpa_list.add(tpa2);
            
            insert tpa_list;
	   
	   ApttusProposalLineItemTriggerHelper helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper('');
       
       Personal_Settings__c persetting=TestDataSetupUtility.buildPersonalSetting();
       persetting.Trigger_Quote__c =true;
       insert persetting; 
       ApttusProposalLineItemTriggerHandler handler=new ApttusProposalLineItemTriggerHandler(true,2); 
	   helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper();
	   helper.AttributeDisplayPLI(listLineItem);
	   helper.Mass_edit_update(listLineItem);
	   helper.Terms_and_Condition_on_proposal(listLineItem);
       helper.SalesCredit(listLineItem);
	   
	}
	
	
	
	// @author: Aakash Khatri
	static User manager, testUser;
	static Account account;
	static Apttus_Proposal__Proposal__c proposal_n;
	static testMethod void testLineItems() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;
	    
	    System.runAs(testUser){
			// Create test account
	        account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
	        system.debug('after account ' + account);
	        insert account;
	        
	        
	        //create Opportunity
	        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', account.Id);
	        opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
	        insert opp;
	        
	        //Create product2
	        Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
	        product.Convert_From__c = true;
	        insert product;
	        
	        Product2 product1 = TestDataSetupUtility.createProduct('Test Product2', false);
	        product.Convert_From__c = true;
	        insert product1;
	        
	        
	        //Create price list
	        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
	        insert priceList; 

            
            Apttus_Config2__PriceListItem__c pli = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 10, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        	insert pli;



	        
	        //create proposal
	        proposal_n = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n.Language__c = 'English';
	        insert proposal_n;	
	        
	        Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal_n,account,priceList);
            config.Apttus_Config2__Status__c = 'Finalized';
            insert config;
	        

	        
	        Apttus_Proposal__Proposal__c proposal_n1 = TestDataSetupUtility.createProposal('Test Proposal', account.Id, opp.Id, 'Accepted Online', false);
	        proposal_n1.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Apttus_Proposal__Proposal__c', 'Proposal');
            proposal_n1.Apttus_QPConfig__PriceListId__c = priceList.id; 
            proposal_n1.Language__c = 'French';
	        insert proposal_n1;	


	        

            
            //System.debug('config:'+config);
        
            Apttus_Config2__LineItem__c aptusLineItem = TestDataSetupUtility.createLineItemApttus(config.Id);
            aptusLineItem.Apttus_Config2__StartDate__c=System.today();
            aptusLineItem.Apttus_Config2__EndDate__c=System.today()+60;
            aptusLineItem.Apttus_Config2__Comments__c='test';
            
            insert aptusLineItem;
            
            Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
            pav.Apttus_Config2__LineItemId__c = aptusLineItem.ID;
            pav.CurrencyIsoCode = 'USD';
            pav.Product_Type__c = 'Sourcing Services-GL';
            insert pav;
            
            
            Apttus_Proposal__Proposal_Line_Item__c propLineItem2 = New Apttus_Proposal__Proposal_Line_Item__c();
            
            propLineItem2.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem2.Apttus_Proposal__Product__c=product.Id;
	        propLineItem2.Apttus_QPConfig__NetPrice__c=3400;
	        propLineItem2.Apttus_QPConfig__BaseExtendedPrice__c=2040;
	        propLineItem2.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
	        propLineItem2.Apttus_Proposal__Proposal__c =proposal_n.Id;
	        //propLineItem2.Proposal_Locked__c = proposal_n.ID;
	        insert propLineItem2;
	        propLineItem2 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
	        Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
	        Apttus_QPConfig__Comments__c,Apttus_QPConfig__OptionId__c,
	        Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem2.Id];
	        
	        Apttus_Proposal__Proposal_Line_Item__c propLineItem3 = New Apttus_Proposal__Proposal_Line_Item__c();
	        propLineItem3.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem3.Apttus_Proposal__Product__c=product1.Id;
	        propLineItem3.Apttus_QPConfig__NetPrice__c=4000;
	        propLineItem3.Apttus_QPConfig__BaseExtendedPrice__c=2500;
	        propLineItem3.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
	        propLineItem3.Apttus_Proposal__Proposal__c =proposal_n.Id;
	        //propLineItem3.Proposal_Locked__c = proposal_n.ID;
	        insert propLineItem3;
	        propLineItem3 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
	        Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
	        Apttus_QPConfig__Comments__c,Apttus_QPConfig__OptionId__c,
	        Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem3.Id];
	        
	        Apttus_Proposal__Proposal_Line_Item__c propLineItem4 = New Apttus_Proposal__Proposal_Line_Item__c();
	        propLineItem4.Apttus_QPConfig__ConfigurationId__c = config.Id;
            propLineItem4.Apttus_Proposal__Product__c=product.Id;
	        propLineItem4.Apttus_QPConfig__NetPrice__c=5000;
	        propLineItem4.Apttus_QPConfig__BaseExtendedPrice__c=2600;
	        propLineItem4.Apttus_QPConfig__DerivedFromId__c=aptusLineItem.Id;
	        propLineItem4.Apttus_Proposal__Proposal__c =proposal_n1.Id;
	        insert propLineItem4;
	        propLineItem4 = [select Id,Apttus_QPConfig__ConfigurationId__c, Quote_Language__c,Configuration_Status__c, ProposalLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__NetPrice__c,
	        Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__DerivedFromId__c,Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c,
	        Apttus_QPConfig__Comments__c,Apttus_QPConfig__OptionId__c,
	        Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLineItem4.Id];
	        
	        
	        system.debug('*****************:propLineItem2 ' + propLineItem2.Quote_Language__c + ' ********* ' + propLineItem2.ProposalLineItemId__c);
	        system.debug('*****************:propLineItem3 ' + propLineItem3.Quote_Language__c + ' ********* ' + propLineItem3.ProposalLineItemId__c);
	        update propLineItem2;
	        update propLineItem3;
	        Apttus_Proposal__Proposal_Line_Item__c[] listLineItem2 = new Apttus_Proposal__Proposal_Line_Item__c[]{propLineItem2, propLineItem3,propLineItem4};
	      
        
            Terms_and_Conditions__c term=new Terms_and_Conditions__c();
            term.Name='testTerm';
            term.Product__c=propLineItem2.Apttus_Proposal__Product__c;
            term.Language__c=propLineItem2.Quote_Language__c;
            
            /*
            Terms_and_Conditions__c term2 = new Terms_and_Conditions__c();
            term2.Name = 'testTerm2';
            term2.Product__c = propLineItem3.Apttus_Proposal__Product__c;
            term2.Language__c = propLineItem3.Quote_Language__c;
            */
            Terms_and_Conditions__c term1=new Terms_and_Conditions__c();
            term1.Name='testTerm';
            term1.Product__c=propLineItem2.Apttus_Proposal__Product__c;
            term1.Language__c=propLineItem2.Quote_Language__c;
            
            //term.T_and_C_External_ID__c = proposal_n.Id;
            insert term;
            //insert term2;
            insert term1;
            
          //create Controlling_Attribute_workflow_Object__c list
	        
	        List<Controlling_Attribute_workflow_Object__c> controllingAttributeWorkflowList=new List<Controlling_Attribute_workflow_Object__c>();
	        
	         
	        Controlling_Attribute_workflow_Object__c controlling1 = new Controlling_Attribute_workflow_Object__c();
	        controlling1.Controlling_attributes__c = 'Selling_Country__c';
	        controlling1.Attribute_type__c= 'Proposal';
	        controlling1.attribute_values__c = 'United States';
	        controllingAttributeWorkflowList.add(controlling1);
	        
	        Controlling_Attribute_workflow_Object__c controlling2 = new Controlling_Attribute_workflow_Object__c();
	        controlling2.Controlling_attributes__c = 'Product_Type__c';
	        controlling2.Attribute_type__c= 'Product';
	        controlling2.attribute_values__c = 'Sourcing Services-GL';
	        controllingAttributeWorkflowList.add(controlling2);
	        
	        Controlling_Attribute_workflow_Object__c controlling3 = new Controlling_Attribute_workflow_Object__c();
	        controlling3.Controlling_attributes__c = 'Selling_Country__c';
	        controlling3.Attribute_type__c= 'Proposal';
	        controlling3.attribute_values__c = 'United States';
	        controllingAttributeWorkflowList.add(controlling3);
	        
	        insert controllingAttributeWorkflowList;
	        
	        
	       
	        
	        Dependent_Attribute_workflow_object__c dependent1 = new Dependent_Attribute_workflow_object__c();
	        dependent1.Attribute_type__c = 'Language T & C';
	        dependent1.DEP_attrib_values__c = 'English';
	        insert dependent1;
	        
            List<Attribute_workfow_junction_object__c> jterms=new List<Attribute_workfow_junction_object__c>();

	        Attribute_workfow_junction_object__c attr_junction_obj = new Attribute_workfow_junction_object__c();
	        attr_junction_obj.Controlling_Attribute_workflow_Object__c = controlling1.Id;
	        attr_junction_obj.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj.Product_Group__c=product.Id;//propLineItem2.Apttus_Proposal__Product__c;

	        jterms.add(attr_junction_obj);
	        
	        Attribute_workfow_junction_object__c attr_junction_obj2 = new Attribute_workfow_junction_object__c();
	        attr_junction_obj2.Controlling_Attribute_workflow_Object__c = controlling3.Id;
	        attr_junction_obj2.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj2.Product_Group__c= product1.Id;//propLineItem2.Apttus_Proposal__Product__c;
	        jterms.add(attr_junction_obj2);
	        
	        Attribute_workfow_junction_object__c attr_junction_obj1 = new Attribute_workfow_junction_object__c();
	        attr_junction_obj1.Controlling_Attribute_workflow_Object__c = controlling2.Id;
	        attr_junction_obj1.Dependent_Attribute_workflow_object__c = dependent1.Id;
	        attr_junction_obj1.Product_Group__c=product1.Id;//propLineItem3.Apttus_Proposal__Product__c;
	        jterms.add(attr_junction_obj1);
	        
	        insert jterms;
            
            attr_junction_obj = [select id ,Controlling_Attribute_workflow_Object__c,Dependent_Attribute_workflow_object__c,
            Product_Group__c from Attribute_workfow_junction_object__c where id = : attr_junction_obj.ID ];
            
            update attr_junction_obj;
            
            attr_junction_obj1 = [select id ,Controlling_Attribute_workflow_Object__c,Dependent_Attribute_workflow_object__c,
            Product_Group__c from Attribute_workfow_junction_object__c where id = : attr_junction_obj1.ID ];
            
            update attr_junction_obj1;
            
            Apttus_Config2__ProductAttributeGroup__c prodAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		    insert prodAttrGrp;
		
		    Apttus_Config2__ProductAttributeGroupMember__c prodAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,name='Tst Member',Apttus_Config2__Sequence__c=6);
		    prodAttrGrpMember.Apttus_Config2__ProductId__c = product.Id;
		    insert prodAttrGrpMember;
		
		    Apttus_Config2__ProductAttribute__c prodAttr = new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodAttrGrp.Id,Apttus_Config2__Field__c='CurrencyIsoCode',Apttus_Config2__Sequence__c=6);
		    prodAttr.Show_on_Report__c = true;

		    
		    List<Apttus_Config2__ProductAttribute__c> listProdAttr = new List<Apttus_Config2__ProductAttribute__c>{prodAttr};
		    insert listProdAttr;
            
            List<Karma_To_SFDC_Product_Name_Translation__c> karma_list = new List<Karma_To_SFDC_Product_Name_Translation__c>();

            Karma_To_SFDC_Product_Name_Translation__c karma = new Karma_To_SFDC_Product_Name_Translation__c();
            karma.SFDC_Product_Name__c = product.Id;
            karma.Attribute_Value__c = pav.ID;
            karma.Attribute_Field__c = 'All';
            karma_list.add(karma);
            
            Karma_To_SFDC_Product_Name_Translation__c karma2 = new Karma_To_SFDC_Product_Name_Translation__c();
            karma2.Attribute_Field__c = 'All';
            karma2.Attribute_Value__c = pav.ID;
            karma2.SFDC_Product_Name__c = product1.Id;
            karma_list.add(karma2);
            
            Karma_To_SFDC_Product_Name_Translation__c karma3 = new Karma_To_SFDC_Product_Name_Translation__c();
            karma3.Attribute_Field__c = 'PositionsPerInventory';
            karma3.Attribute_Value__c = pav.ID;
            karma3.SFDC_Product_Name__c = product.Id;
            karma_list.add(karma3);
            
            insert karma_list;
            
            List<Translated_Product_Attribute__c> tpa_list = new List<Translated_Product_Attribute__c>();
            Translated_Product_Attribute__c tpa = new Translated_Product_Attribute__c(Name = 'test tpa');
            tpa.Language__c = 'English';
            tpa.Product__c = product.Id;
            tpa.English_Value__c = 'test tpa';
            tpa.Type__c = 'Attribute Name';
            tpa_list.add(tpa);
            
            Translated_Product_Attribute__c tpa2 = new Translated_Product_Attribute__c(Name = 'test tpa2');
            tpa2.Language__c = 'French';
            tpa2.Product__c = product.Id;
            tpa2.English_Value__c = 'test tpa2';
            tpa2.Type__c = 'Product Name';
            tpa2.Translated_Value__c = 'test tpa2';
            tpa_list.add(tpa2);
            
            insert tpa_list;
            
            ApttusProposalLineItemTriggerHelper helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper('');
	        helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper();
	        helper.Mass_edit_update(listLineItem2);
	        helper.Terms_and_Condition_on_proposal(listLineItem2);
	        helper.AttributeDisplayPLI(listLineItem2);  

	        //ApttusProposalLineItemTriggerHelper new_helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper();
	       // Apttus_Proposal__Proposal__c prop_helper = new_helper.getProposal('asd', proposal_n.Id);
	        //helper.getProposal('AgencyIO__c','a0mq0000000KBRO');

        } 
	}

	static testMethod void testAttributeDisplay() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
	    manager = TestDataSetupUtility.createTestUser('Test Manager', 'System Admin', p.Id);
		insert manager;
	    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
	    testUser.ManagerId = manager.Id;
	    testUser.Discount_Threshold__c  = 10.0;
	    insert testuser;



	    account = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
	        
	    insert account;

        //Create price list
        Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
        insert priceList; 


        //Products to test S-428879
            Product2 prodJobAd = TestDataSetupUtility.createProduct('Monster Standard Job Ad', false);
            insert prodJobAd;
            Apttus_Config2__PriceListItem__c pliJobAd = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, 
        	Apttus_Config2__ListPrice__c = 100, 
        	Apttus_Config2__ProductId__c = prodJobAd.Id, 
        	Apttus_Config2__ChargeType__c = 'Standard Price');
            insert pliJobAd;

        
   

            //Product Attribute definitions


            Apttus_Config2__ProductAttributeGroup__c prodJobAdAttrGrp = new Apttus_Config2__ProductAttributeGroup__c();
		    insert prodJobAdAttrGrp;
		
		    Apttus_Config2__ProductAttributeGroupMember__c prodJobAdAttrGrpMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	name='Job Ad Test Member',
		    	Apttus_Config2__Sequence__c=1);
		    prodJobAdAttrGrpMember.Apttus_Config2__ProductId__c = prodJobAd.Id;
		    insert prodJobAdAttrGrpMember;
		
		    //Product Attribute Definitions
		    List<Apttus_Config2__ProductAttribute__c> listProdJobAdAttr = new List<Apttus_Config2__ProductAttribute__c>();

		    listProdJobAdAttr.add( new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Geography__c',
		    	Apttus_Config2__Sequence__c=1,
		    	Show_on_Report__c = true));
		    
		     listProdJobAdAttr.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Country__c',
		    	Apttus_Config2__Sequence__c=2,
		    	Show_on_Report__c = true));

		     listProdJobAdAttr.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Contract_Duration__c',
		    	Apttus_Config2__Sequence__c=3,
		    	Show_on_Report__c = true));
		     listProdJobAdAttr.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Contract_Type__c',
		    	Apttus_Config2__Sequence__c=4,
		    	Show_on_Report__c = true));
		     listProdJobAdAttr.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Ad_Type__c',
		    	Apttus_Config2__Sequence__c=5,
		    	Show_on_Report__c = true));
		     listProdJobAdAttr.add(new Apttus_Config2__ProductAttribute__c(Apttus_Config2__AttributeGroupId__c=prodJobAdAttrGrp.Id,
		    	Apttus_Config2__Field__c='Job_Inventory__c',
		    	Apttus_Config2__Sequence__c=6,
		    	Show_on_Report__c = true));
		    
		    insert listProdJobAdAttr;


        // Oppty and Proposal,  for S-428879
            Opportunity oppJobAd = TestDataSetupUtility.createTestOpportunity('Job Ad Opportunity', account.Id);
            oppJobAd.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
	        insert oppJobAd;
            Apttus_Proposal__Proposal__c proposal_Job = TestDataSetupUtility.createProposal('Job Ad Proposal', account.Id, oppJobAd.Id, 'In Progress', false);
            proposal_Job.Apttus_QPConfig__PriceListId__c = priceList.id;
            proposal_Job.Language__c = 'German';
            proposal_Job.Selling_Country__c = 'Germany';
            insert proposal_Job;

	        Apttus_Config2__ProductConfiguration__c configJob = TestDataSetupUtility.createTestProductConfig(proposal_Job, account, pricelist);
	        configJob.Apttus_Config2__Status__c = 'Saved';
	        insert configJob;

	        Apttus_Config2__LineItem__c aptItemJob = TestDataSetupUtility.createLineItemApttus(ConfigJob.Id);
	        aptItemJob.Apttus_Config2__StartDate__c=System.today();
	        aptItemJob.Apttus_Config2__EndDate__c= system.today()+60;
	        aptItemJob.Apttus_Config2__Comments__c='test';
	        insert aptItemJob;

            Apttus_Config2__ProductAttributeValue__c pavJob = new Apttus_Config2__ProductAttributeValue__c();
            pavJob.Apttus_Config2__LineItemId__c = aptItemJob.Id;
            pavJob.CurrencyIsoCode = 'EUR';
            pavJob.Product_Type__c = 'Job Ad';
            pavJob.Custom_Impressions__c = '200000';
            pavJob.Additional_Targeting__c = 'None';
            pavjob.Contract_Duration__c = '6 Months';
            pavJob.Job_Inventory__c = 'Standard';
            pavJob.Job_Board__c = 'Core';
            pavJob.Posting_Duration__c = '365 Days';
            pavJob.Posting_Locations__c = 'Germany';
            pavJob.Country__c = 'Germany';
            pavJob.Geography__c = 'National';
            insert pavJob;

            // Still to add Translations in order to run throu all the AttribDisplay
            List<Karma_To_SFDC_Product_Name_Translation__c> transprod_list = new List<Karma_To_SFDC_Product_Name_Translation__c>();

            transprod_list.add(new Karma_To_SFDC_Product_Name_Translation__c(SFDC_Product_Name__c = prodJobAd.Id,
            	Attribute_Value__c = 'All',
            	Attribute_Field__c = 'All',
            	Media_Group__c = '',
            	Media_Type__c = '',
            	Product_Cateogry__c = 'Job Posting Standard',
            	Product_Family__c = 'Job Posting',
            	Product_SubCategory__c = 'Job Post Std - Any Location'));

            insert transprod_list;
            
            //attribute translations
            /*English_Value__c,
                                                                 Language__c,
                                                                 Product__c,
                                                                 Translated_Value__c,
                                                                 Type__c*/
            List<Translated_Product_Attribute__c> transattr_list = new List<Translated_Product_Attribute__c>();
            transattr_list.add(new Translated_Product_Attribute__c(Product__c = prodJobAd.Id,
            	Language__c = 'German',
            	English_Value__c = 'Germany',
            	Translated_Value__c = 'Deutschland',
            	Type__c = 'Attribute Value'));
            transattr_list.add(new Translated_Product_Attribute__c(Product__c = prodJobAd.Id,
            	Language__c = 'German',
            	English_Value__c = 'Country',
            	Translated_Value__c = 'Land',
            	Type__c = 'Attribute Name'));
            transattr_list.add(new Translated_Product_Attribute__c(Product__c = prodJobAd.Id,
            	Language__c = 'German',
            	English_Value__c = 'Monster Standard Job Ad',
            	Translated_Value__c = 'Monster Stellenanzeige Standard',
            	Type__c = 'Product Name'));

            insert transattr_list;


            Apttus_Proposal__Proposal_Line_Item__c propLIJob = new Apttus_Proposal__Proposal_Line_Item__c();
            propLIJob.Apttus_QPConfig__ConfigurationId__c = configJob.Id;
            propLIJob.Apttus_Proposal__Proposal__c = proposal_Job.Id;
            propLIJob.Apttus_QPConfig__DerivedFromId__c = aptItemJob.Id;
            propLIJob.Apttus_Proposal__Product__c = prodJobAd.Id;
            propLIJob.Apttus_QPConfig__NetPrice__c = 100;
            propLIJob.Apttus_QPConfig__BaseExtendedPrice__c = 100;
            propLIJob.Apttus_QPConfig__Quantity2__c = 1;
            insert propLIJob;
            propLIJob = [select Id,
                 Apttus_QPConfig__ConfigurationId__c, 
                 Quote_Language__c,
                 Configuration_Status__c, 
                 ProposalLineItemId__c,
                 Apttus_Proposal__Product__c,
                 Product_or_Option_Name__c,
                 Apttus_QPConfig__NetPrice__c,
	             Apttus_QPConfig__BaseExtendedPrice__c, 
	             Apttus_QPConfig__DerivedFromId__c,
	             Apttus_QPConfig__StartDate__c,
	             Apttus_QPConfig__EndDate__c,
	             Apttus_QPConfig__Comments__c,
	             Apttus_QPConfig__OptionId__c,
	             Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c where Id = :propLIJob.Id];
            Apttus_Proposal__Proposal_Line_Item__c[] listofItems = new Apttus_Proposal__Proposal_Line_Item__c[]{propLIJob};
            ApttusProposalLineItemTriggerHelper helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper('');
	        helper = ApttusProposalLineItemTriggerHelper.NewTriggerHelper();
	        helper.AttributeDisplayPLI(listofItems);

            


	}

	

	
	private static Apttus_Proposal__Proposal__c getProposal(){
		Apttus_Proposal__Proposal__c proposal = null;
		Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
		insert acct;
		Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
		insert con;
		Opportunity oppt = TestDataSetupUtility.createTestOpportunity('TestOppt_28_07_15', acct.Id);
		insert oppt;
		proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, oppt.Id, 'test', false);
		insert proposal;
		return proposal;
	}
}