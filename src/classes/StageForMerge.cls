global class StageForMerge {
    
    webservice static String updateMergeWinnerOnAccount(Id caseId) {
        
        String error = '';
        Id userId;
        List<SetupEntityAccess> access;
        List<CustomPermission> customPerms;
        Boolean hasAccess;
        
        userId = UserInfo.getUserId();
        access =[SELECT SetupEntityId 
                    FROM SetupEntityAccess 
                    WHERE SetupEntityType='CustomPermission' 
                    AND ParentId IN (SELECT PermissionSetId 
                                    FROM PermissionSetAssignment 
                                    WHERE AssigneeId=:userId)];
                                    
        Set<Id> customPermIds = new Set<Id>();
        for (SetupEntityAccess sea : access) {
            customPermIds.add(sea.SetupEntityId);
        }
        customPerms = [SELECT Id, DeveloperName, MasterLabel FROM CustomPermission WHERE Id IN : customPermIds];
        
        
        hasAccess = checkAccess('Stage_For_Merge', customPerms);
        
        if(hasAccess) {
            Case cas = [SELECT Id, AccountId, Duplicate_Account__c, Master_Account__c
                        FROM Case
                        WHERE Id =: caseId];
            system.debug('debug ' + cas );
             system.debug('debug ' + caseId);
            if(cas.Duplicate_Account__c != null && cas.AccountId != null) {         
                Account acc = new Account(id = cas.Duplicate_Account__c);
                acc.Merge_Winner__c = cas.AccountId;
                try {
                    update acc;
                } catch (Exception e) {
                    error = e.getMessage();
                }
            } else {
                error = 'Both Duplicate Account and Master Account must be populated';
            }
            
            cas.SubStatus__c = 'In Process';
            try {
                update cas;
            } catch (Exception e) {
                error = e.getMessage();
            }
            //Update the Merge Winner field on the Case.Duplicate_Account__c with the Case.Master_Account__c
            //If either are blank than throw an error "Both Duplicate Account and Master Account must be populated"
            //Set the Case.SubStatus__c - "In Process"
            
            
        } else {
            error = 'You do not have permission to use this feature';
        }
        
        if(error == '') {
            error = 'SUCCESSFULL';
        }
        
        return error;
    }
    
    private static boolean checkAccess(String devName, List<CustomPermission> customPerms) {
        for (CustomPermission perm : customPerms) {
            if (perm.DeveloperName.equals(devName)) return true;
        }
        return false;
    }
}