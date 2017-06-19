/**
 * @author Cloudsherpas
 * @date 12.4.14
 * @description CustomAccountLookupController class for CustomAccountLookup page
 */
public class CustomAccountLookupController {
	public Account account {get;set;} // new account to create
  	public List<Account> results{get;set;} // search results
  	public string searchString{get;set;} // search keyword from AccountHierarchyDisplay page
  	public string searchStr{get;set;} // search keyword from CustomAccountLookup page
  	public string txtSearchId{get;set;}
  	private set<Id> accWithChildIdSet;
  	public CustomAccountLookupController() {
  		txtSearchId = System.currentPageReference().getParameters().get('txtText');
  		account = new Account();
  		// get the current search string
  		String currId = System.currentPageReference().getParameters().get('lksrch');
  		searchString = 'Select AccountId__c, Name from account';
  		
  		if(currId != '' && currId != null){
  				searchString = searchString + ' where ParentId = \'' + currId + '\'';  			 
  		} 
  		runSearch();  
  	}
    /**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description performs the keyword search
	 * @return will return null
	 */ 
  	public PageReference search() {
  		String soql = 'select AccountId__c, Name from account';
    	if(searchStr != '' && searchStr != null)
      		soql = soql +  ' where AccountId__c LIKE \'%' + searchStr +'%\'';
    	//soql = soql + ' limit 25';
    	System.debug(soql);
    	
    	searchString = soql;
    	runSearch();
    	return null;
  	}
  	/**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description prepare the query and issue the search command
	 */
  	private void runSearch() {
  		// TODO prepare query string for complex serarches & prevent injections
    	results = performSearch(searchString);               
  	} 
  	/**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description run the search and return the records found.
	 * @param searchString - a string type the will hold the query to search.
	 * @return a list of Accounts that has a limit of 50 that will be displayed on the results
	 */
  	private List<Account> performSearch(string searchString) {

    	/*String soql = 'select AccountId__c, Name from account';
    	if(searchString != '' && searchString != null)
      		soql = soql +  ' where AccountId__c LIKE \'%' + searchString +'%\'';
    	soql = soql + ' limit 25';
    	System.debug(soql);*/
    	system.debug(searchString);
    	return database.query(searchString + ' limit 50'); 

  	}
  	/**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description  used by the visualforce page to send the link to the right dom element
	 * @return the string type that is passed on the parameter 'frm' of the page
	 */
  	public string getFormTag() {
    	return System.currentPageReference().getParameters().get('frm');
  	}
    /**
	 * @author Cloudsherpas
	 * @date 12.4.14
	 * @description used by the visualforce page to send the link to the right dom element for the text box
	 * @return the string type that is passed on the parameter 'txt' of the page
	 */
  	public string getTextBox() {
    	return System.currentPageReference().getParameters().get('txt');
  	}
}