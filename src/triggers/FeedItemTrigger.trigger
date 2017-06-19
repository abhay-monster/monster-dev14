trigger FeedItemTrigger on FeedItem (before delete) {

	//added per S--352424

	Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
	String pname = p.name;
    Object hasPermission = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'Delete_Cases'];

    for(FeedItem f : Trigger.old){
        if (((String)f.parentId).startsWith('500') && hasPermission != null && pname != 'System Administrator') {
            f.addError('You are not allowed to delete Case feed comments.'); 
        }
    }
}