global class BatchMassUpdateUser implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, Name, Combined_Region__c, Job_Type__c, Position_Account_Size__c, Position_Group__c, Position_Job_Title__c, Position_Organization__c, ';
				query += ' Processed__c, Region__c, Region_Group__c, Segment__c, User__c, Sales_Channel__c ';
				query += ' FROM Mass_User_Update__c ';
				query += ' WHERE Processed__c = false';
				
				system.debug('=======query=====' + query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Mass_User_Update__c> scope) {
		list<User> listUserToUpdate = new List<User>();
		for (Mass_User_Update__c muu : scope) {
			if(muu.User__c != null) {
				User u = new User(Id = muu.User__c);
				u.Combined_Region__c = muu.Combined_Region__c;  
				u.Job_Type__c = muu.Job_Type__c;
				u.Position_Account_Size__c = muu.Position_Account_Size__c; 
				u.PositionSalesGroup__c = muu.Position_Group__c;
				u.PositionJobTitle__c = muu.Position_Job_Title__c;
				u.Position_Organization__c = muu.Position_Organization__c; 
				u.PositionSalesChannel__c = muu.Sales_Channel__c;
				u.UserPositionRegion__c = muu.Region__c;
				u.Region_Group__c = muu.Region_Group__c; 
				u.Segment__c = muu.Segment__c;
				listUserToUpdate.add(u); 
			}
		}
		if(listUserToUpdate != null && listUserToUpdate.size() > 0) {
			update listUserToUpdate;
		}
	}
	global void finish(Database.BatchableContext BC) {
		 
	}
	
}