/**
 * This class has been generated to allow customization of Account creation for Chatter Answers Portal Users.
 * Chatter Answers requires that this class exist and implement ChatterAnswers.AccountCreator, renaming the class
 *   or removing the interface implementation is prohibited. */
public class ChatterAnswersRegistration implements ChatterAnswers.AccountCreator {
    public String createAccount(String firstname, String lastname, Id siteAdminId) {
        // need to create a business account so we need to get the right record type
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
		map<String, Schema.RecordTypeInfo> rt_map = dsr.getRecordTypeInfosByName();
    	String bussAccountId = rt_map.get('Business Accounts').getRecordTypeId();
   	
         Account a = new Account(RecordTypeId =bussAccountId, name = firstname + ' ' + lastname, ownerId = siteAdminId);
         insert a;
         return a.Id;
    }
}