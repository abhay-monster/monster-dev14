/**
 *  Apttus Config & Pricing
 *  APTPS_AssetLineItemCallback
 *  - AssetLineItem Callback method to apply asset filters  
 */
 global class APTPS_AssetLineItemCallback implements Apttus_Config2.CustomClass.IAssetLineItemCallback2 {

    public static final String FIELD_NAME_ACCOUNT_ID = 'AccountId__c';    

    private List<String> assetSearchScope;
    private String assetSearchFilter;    
    private ID proposalId = null;

    /**
     * Callback at the beginning of the call.
     * Use the start method to initialize state
     * @param cart the cart object. The cart could be null when used from account detail page
     * @param assetSearchFilter search filter can be null, this is the query filter fetched from the config request
     * @param assetSearchScope the list for search scope can be empty or null, search scope is fetched from the config request
     */
    global void start(Apttus_Config2.ProductConfiguration cart, String assetSearchFilter, List<String> assetSearchScope) {

        this.assetSearchFilter = assetSearchFilter;
        this.assetSearchScope = assetSearchScope;
        System.debug('assetSearchFilter = ' + assetSearchFilter );
        System.debug('assetSearchScope = ' + assetSearchScope);

        if(cart != null) {
            proposalId = cart.getConfigSO().Apttus_Config2__BusinessObjectId__c;            
        }
    }

    /**
     * Callback to create and return query filter
     * @param accountId the context acountId
     * @return the query filter
     */
    global String getQueryFilter(ID accountId) {		
        return assetSearchFilter;
    }

    /**
     * returns asset search scope set in the start method
     */
    global List<String> getAssetSearchScope() {
        System.debug('============================ getAssetSearchScope ');       
        return assetSearchScope;
    }
    
    global String getFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
    	System.debug('*** getFilterExpr called with params = ' + params);
		
		//in case the asset search filter should be returned as it is
		String filter = 'Apttus_Config2__' + FIELD_NAME_ACCOUNT_ID + ' = \'' + params.AccountId + '\'';
		
        if (proposalId != null) {            
            filter += ' AND Is_Advanced_Quote_Item__c  = true';            
        }
        System.debug('****** Asset Search Filter = ' + filter);
		return filter;
	}
    

    /**
     * Callback to help reinitialize
     * Use the finish method to release state
     */
    global void finish() {
        // do nothing

    }

}