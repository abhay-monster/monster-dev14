@isTest
public with sharing class EKBController_Test{

	static User testUser ;
	
    static void preTestSetup(){
   		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
         testUser =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
         testUser.UserPermissionsKnowledgeUser = true;
         insert testUser;
   
    }
	@isTest
	static void testLanding(){
		Brand__c b = TestDataSetupUtility.createBrand(true);

 		PageReference pageRef = Page.EKBLanding;
    	Test.setCurrentPage(pageRef);
    	EKBController controller = new EKBController();
    	String retURL = controller.setLanding().geturl();

    	System.assert(returL.contains('EKBAnswer'));

    	b.Default_Tab__c = 'Training';
    	update b;
    	controller = new EKBController();
    	retURL = controller.setLanding().geturl();
    	System.assert(returL.contains('EKBTraining'));

    	b.Default_Tab__c = 'Testing';
    	update b;
    	controller = new EKBController();
    	retURL = controller.setLanding().geturl();
    	System.assert(returL.contains('EKBHome'));

        b.Default_Tab__c = 'Contact Us';
        update b;
        controller = new EKBController();
        retURL = controller.setLanding().geturl();
        System.assert(returL.contains('EKBContactUs'));
	}

	@isTest
	static void testHomePage(){
		preTestSetup();
		Brand__c b = TestDataSetupUtility.createBrand(true);
		Answers__kav answer = TestDataSetupUtility.createAnswer(true);
		Article_Relationship__c ar1 = TestDataSetupUtility.createAR(b.Id, answer,'Administration', true);
        Article_Relationship__c ar2 = TestDataSetupUtility.createAR(b.Id, answer,'Fraud', true);
        Article_Relationship__c ar3 = TestDataSetupUtility.createAR(b.Id, answer,'Resume', true);
        Article_Relationship__c ar4 = TestDataSetupUtility.createAR(b.Id, answer,'Support', true);
        Answers__DataCategorySelection dcs1 = TestDataSetupUtility.assignDataCategoryToAnswer(answer.id,'EKB','Administration');
        Answers__DataCategorySelection dcs2 = TestDataSetupUtility.assignDataCategoryToAnswer(answer.id,'EKB','Fraud');
        Answers__DataCategorySelection dcs3 = TestDataSetupUtility.assignDataCategoryToAnswer(answer.id,'EKB','Resume');
        Answers__DataCategorySelection dcs4 = TestDataSetupUtility.assignDataCategoryToAnswer(answer.id,'EKB','Support');
        List<Answers__DataCategorySelection> dcsList = new List<Answers__DataCategorySelection>{dcs1,dcs2,dcs3,dcs4};
        insert dcslist;
        answer = [Select id, KnowledgeArticleId From Answers__kav Where Id = :answer.Id];
        System.runAs(testUser){
	        KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
	
	 		PageReference pageRef = Page.EKBHome;
	    	Test.setCurrentPage(pageRef);
	    	EKBController controller = new EKBController();
	    	controller.setupHomePage();
	
	        List<KnowledgeArticleVersion> KAV = [Select id, Title, KnowledgeArticleId From KnowledgeArticleVersion Where islatestversion = true and publishstatus = 'Online' and language = 'en_US' and KnowledgeArticleId = :answer.KnowledgeArticleId WITH DATA CATEGORY EKB__c AT (Administration__c)];
	        System.assertEquals(kav.size(),1);
        }
	}

	@isTest
	static void testsetupContactUs(){
		Brand__c b = TestDataSetupUtility.createBrand(false);
		b.Brand_Tag__c = 'test';
		insert b;
		Contact_Us_Options__c cuo = TestDataSetupUtility.createCUO(b.id, true);
		b.Contact_Us__c = cuo.id;
		update b;

 		PageReference pageRef = Page.EKBContactUs;
 		ApexPages.currentPage().getParameters().put('brand', b.Brand_Tag__c );
	    	
    	Test.setCurrentPage(pageRef);
    	EKBController controller = new EKBController();
    	controller.setupContactUs();
        controller.getCategories();
        controller.setAttachment(null);
		Attachment att = controller.getAttachment();
		att.Body = Blob.valueOf('tst');
		att.Name = 'test';
		controller.attach  = att;
        controller.setAttachment(att);
    	Case CU = controller.ContactUs;
    	RecordType cRT = [Select id From RecordType Where SobjectType ='Case' and Name = 'GCS'];
    	System.assertEquals(crt.Id, CU.recordTypeId);

    	controller.SubmitCase();

    	CU = controller.ContactUs;
    	System.assertNotEquals(CU.Id,null);
	}

	@isTest
	static void testArticleDetailByID(){
		preTestSetup();
		Brand__c b = TestDataSetupUtility.createBrand(true);
		Answers__kav answer = TestDataSetupUtility.createAnswer(true);
        answer = [Select id, KnowledgeArticleId From Answers__kav Where id = :answer.id];
        System.runAs(testUser){
	        KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
	
			PageReference pageRef = Page.EKBDetail;
	    	Test.setCurrentPage(pageRef);
	    	EKBController controller = new EKBController();
	    	ApexPages.currentPage().getParameters().put('id', answer.KnowledgeArticleId);
	    	controller.getArticleDetails();
	    	controller.getSiteURL();
	
	    	EKBController.ArticleWrapper article = controller.AW;
	    	System.assertEquals(answer.knowledgearticleid,article.articleId);
        }
	}

    @isTest
    static void testArticleDetailByURL(){
        preTestSetup();
		Brand__c b = TestDataSetupUtility.createBrand(true);
        Answers__kav answer = TestDataSetupUtility.createAnswer(true);
        answer = [Select id, urlName, KnowledgeArticleId From Answers__kav Where id = :answer.id];
        System.runAs(testUser){
	        KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
	
	        PageReference pageRef = Page.EKBDetail;
	        Test.setCurrentPage(pageRef);
	        EKBController controller = new EKBController();
	        ApexPages.currentPage().getParameters().put('url', answer.urlName);
	        controller.getArticleDetails();
	        controller.getSiteURL();
	
	        EKBController.ArticleWrapper article = controller.AW;
	        System.assertEquals(answer.knowledgearticleid,article.articleId);
        }
    }

	@isTest
	static void testRatings(){
		preTestSetup();
		Brand__c b = TestDataSetupUtility.createBrand(true);
		Answers__kav answer = TestDataSetupUtility.createanswer(true);
		Article_Relationship__c ar = TestDataSetupUtility.createAR(b.Id, answer, 'Jobs', true);
        answer = [Select id, KnowledgeArticleId From Answers__kav Where id = :answer.id];
        System.runAs(testUser){
		    KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
	
			PageReference pageRef = Page.EKBDetail;
	    	Test.setCurrentPage(pageRef);
	    	EKBController controller = new EKBController();
	    	ApexPages.currentPage().getParameters().put('id', answer.KnowledgeArticleId);
	    	controller.getArticleDetails();
	
	    	controller.ratedNo();
	    	controller.ratedYes();
	
	    	List<Article_Relationship__c> listAR = [Select id, Times_not_found_useful__c, Times_found_useful__c From Article_Relationship__c Where Id = :ar.id];
	    	//System.assertEquals(listAR[0].Times_not_found_useful__c,1);
        }
	}

	@isTest
	static void testResults(){
		preTestSetup();
		Brand__c b = TestDataSetupUtility.createBrand(true);
		Answers__kav answer = TestDataSetupUtility.createAnswer(true);
		Article_Relationship__c ar = TestDataSetupUtility.createAR(b.Id, answer,'Jobs', true);
		answer = [Select id, KnowledgeArticleId From Answers__kav Where Id = :answer.Id];
		System.runAs(testUser){
		     KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
			PageReference pageRef = Page.EKBAnswers;
	    	Test.setCurrentPage(pageRef);
	
	    	EKBController controller = new EKBController();
	        controller.searchArticles();
	        controller.getResults();
	        ApexPages.currentPage().getParameters().put('Search', 'loren');
	    	controller.getResults();
	        ApexPages.currentPage().getParameters().put('type', 'Account_Profile');
	        controller.getResults();
	
	        List<KnowledgeArticleversion> kav = [select id From KnowledgeArticleVersion Where KnowledgeArticleId = :answer.KnowledgeArticleId and PublishStatus = 'Online' and islatestversion = true ];
	        System.assertEquals(kav.size(), 1);
		}
	}

	/*@isTest
	static void testSearch(){
		Brand__c b = TestDataSetupUtility.createBrand(true);
		Answers__kav answer = TestDataSetupUtility.createAnswer(true);
		answer = [Select id, KnowledgeArticleId From Answers__kav Where Id = :answer.Id];
		Article_Relationship__c ar = TestDataSetupUtility.createAR(b.Id, answer,'Account Profile', true);
		KbManagement.PublishingService.publishArticle(answer.KnowledgeArticleId, true);
		PageReference pageRef = Page.EKBAnswers;
    	Test.setCurrentPage(pageRef);
    	EKBController controller = new EKBController();

    	ApexPages.currentPage().getParameters().put('Search', 'loren');
        controller.searchArticles();
        //EKBController.setSearchString('loren');
        controller.getResults();

    	List<KnowledgeArticleversion> lstKav = controller.SearchResults;
    	System.assertEquals(lstKav.size(),1);
        //List<KnowledgeArticleVersion> lstKAVSA = EKBController.SuggestedArticles(lstKav[0].Title, b.Id, 'en_US');
	}*/

    @isTest
    static void testAdditionalMethods(){
        Brand__c b = TestDataSetupUtility.createBrand(true);
        Answers__kav answer = TestDataSetupUtility.createAnswer(true);
        Article_Relationship__c ar = TestDataSetupUtility.createAR(b.Id, answer,'Jobs', true);

        Contact_Us_Options__c cuo = TestDataSetupUtility.createCUO(b.id, true);
        b.Contact_Us__c = cuo.id;
        update b;

        PageReference pageRef = Page.EKBContactUs;
        Test.setCurrentPage(pageRef);
        EKBController controller = new EKBController();
        controller.setupContactUs();

        controller.ContactUs.Subject = 'Job Search';
        //controller.SubmitCase();

        System.assertEquals(controller.ContactUs.Subject, 'Job Search');
        controller.QuestionAnswered();
        controller.Suggestions();
        Attachment att = controller.getAttachment();
        controller.setAttachment(att);
        controller.getLogoPath();
        EKBController.SuggestedArticles(controller.ContactUs.Subject, b.id, 'en_US');
    }
    
}