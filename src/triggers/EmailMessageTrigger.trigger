trigger EmailMessageTrigger on EmailMessage (before delete, after insert) {
	if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
			handler.afterInsert(Trigger.new, Trigger.oldMap);
		}

	} else if(Trigger.isDelete && Trigger.isBefore){
    // before delete event  
    // event not implemented

    // added per S--352424
    Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
	String pname = p.name;
    Object hasPermission = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Delete_Cases'];
    System.debug('hasPermission = ' + hasPermission);
    for  (EmailMessage e: trigger.old){
        //if (hasPermission != null && pname != 'System Administrator'){
        //  TK I-222393: changed != to ==, non-SysAdmin users with proper permission set were still not able to delete    
          if (hasPermission == null && pname != 'System Administrator'){  
            System.debug('doesn\'t have permission - prevent delete');
              e.adderror('You do not have permission to delete email messages.');
        }
    }
        
    /*
    Profile_Permissions__c permissionToDeleteActivity = Profile_Permissions__c.getInstance(userinfo.getProfileId());
    if(permissionToDeleteActivity.Delete_Activities__c == false)
    throw new PermissionCheck.NoPermissionException(Label.Cannot_Delete_Activities);
    */
	}
}