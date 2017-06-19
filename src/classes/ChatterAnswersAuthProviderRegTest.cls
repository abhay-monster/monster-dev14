@isTest
Private Class ChatterAnswersAuthProviderRegTest{
     static User user;
    static testmethod void testChatterAnswersAuthProviderRegistration(){
        prepareData();
        System.runAs(user){
        Test.startTest();

        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
        
        system.debug('===test== '+sampleData.firstname + sampleData.lastname);
        
        ChatterAnswersAuthProviderRegistration obj = new ChatterAnswersAuthProviderRegistration();
        obj.createUser(null, sampleData);
        //obj.updateUser(UserInfo.getUserId(),null,sampleData);

        Test.stopTest();
        }
    }
    
    static void prepareData(){
    	Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess','CspLitePortal'};
		Account acc = new Account (
		Name = 'newAcc1'
		);  
		insert acc;
		Contact con = new Contact (
		AccountId = acc.id,email='test123@gmail.com',
		LastName = 'portalTestUser'
		);
		insert con;
		Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
		UserRole role = [select Id,name from UserRole limit 1]; 
		user = new User(
		profileId = p.id,
		username = 'newUser@yahoo.com',
		email = 'pb@ff.com',
		emailencodingkey = 'UTF-8',
		localesidkey = 'en_US',
		languagelocalekey = 'en_US',
		timezonesidkey = 'America/Los_Angeles',
		alias='nuser',
		lastname='lastname',
		contactId = con.id
        //,UserroleId = role.Id
		);
		
     	insert user;
    } 

}