@IsTest
private class EKBAddArticlesController_Test{

	static testmethod void getArticles(){
		List<GCS__kav> lstGCS = new List<GCS__kav>();
		for(Integer i=0;i<10;i++){
			GCS__kav gcs = new GCS__kav();
			gcs.urlname = 'url'+i;
			gcs.title = 'loren ipsum';
			gcs.summary = 'loren ipsum';
			lstGCS.add(gcs);
		}
		insert lstGCS;

		Brand__c b = new Brand__c();
		b.Active__c = true;
		b.Brand_Tag__c = 'monster';
		b.Language__c = UserInfo.getLanguage();
		insert b;

		Article_Relationship__c ar = new Article_Relationship__c();
		ar.Brand__c = b.id;
		ar.Knowledge_Article_Id__c = lstGCS[0].id;
		insert ar;

		PageReference pageref = Page.EKBAddArticles;
		Test.setCurrentPage(pageref);
		ApexPages.currentPage().getParameters().put('brand', b.Id);
		ApexPages.currentPage().getParameters().put('lang', b.Language__c);
        EKBAddArticlesController controller = new EKBAddArticlesController();
		

		List<KnowledgeArticleVersion> lstKAV = controller.getNewArticles();
		System.assertNotEquals(lstKAV.size(),lstGCS.size());

		controller.getlistWrapper();
		//controller.listWrapper[0].isselected = true;

		controller.add();

		List<Article_Relationship__c> lstAR = [select id From Article_Relationship__c Where Brand__c = :b.id];
		System.assertEquals(1,lstAr.size());

	}

}