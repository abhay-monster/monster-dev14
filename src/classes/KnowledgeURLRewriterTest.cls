@isTest
public class KnowledgeURLRewriterTest {

	static testMethod void testKnowledgeURLRewriter(){
        Test.startTest();
		KnowledgeURLRewriter wr = new KnowledgeURLRewriter();
		PageReference pageRef = new PageReference('http://www.google.com');
		wr.mapRequestUrl(pageRef);
		wr.generateUrlFor(new PageReference[]{pageRef});
        Test.stopTest();
	}
}