@isTest
public class APTPS_AssetLineItemCallback_Test {

	static testMethod void testAPTPS_AssetLineItemCallback(){
		Test.startTest();
		Apttus_Config2.ProductConfiguration productConfig = null;
		//productConfig.Apttus_Config2__BusinessObjectId__c = 'test Apttus_Config2__BusinessObjectId__c';
		List<String> searchScope = new List<String>{'test1', 'test2', 'test3'};
		APTPS_AssetLineItemCallback assetLineItemCallback = new APTPS_AssetLineItemCallback();
		assetLineItemCallback.start(productConfig, 'test', searchScope);
		assetLineItemCallback.getQueryFilter(null);
		assetLineItemCallback.getAssetSearchScope();
		Apttus_Config2.CustomClass.ActionParams params = null;
		//assetLineItemCallback.getFilterExpr(null);
		assetLineItemCallback.finish();
		Test.stopTest();
	}
}