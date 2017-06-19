//Not sure the origin of this class, Jeff L added comments and cleaned up the code 8/25/16
public class PermissionCheck {
    public class NoPermissionException extends Exception{}
    
    public static Set<String> DataGovernanceProfiles = new Set<String>{
        'Data Steward',
        'Sales Operations'
    };
    
    //this queries to get all the custom permissions available to the current user
    private static List<SetupEntityAccess>  access{
        get {
            if (access==null){
               access =[SELECT SetupEntityId 
                        FROM SetupEntityAccess 
                        WHERE SetupEntityType='CustomPermission' 
                        AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId())];
            }
            return access;
        }
        private set;
    }
    
    //this will return a set of strings of the names of the permissions available to the current user 
    private static Set<String> permissions{
        get {
            if (permissions ==null){
                permissions = new set<string>();
                Set<Id> customPermIds = new Set<Id>();
                for (SetupEntityAccess sea : access) {
                    customPermIds.add(sea.SetupEntityId);
                }
                for (CustomPermission perm: [SELECT Id, DeveloperName, MasterLabel 
                                                     FROM CustomPermission
                                             WHERE Id IN :customPermIds]) {
                    permissions.add(perm.DeveloperName);                                 
                }
              }
            return permissions;
        }
        private set;
    }

    //uses the two properties above to determine if the custom permission is available for this user
    public static boolean hasPermission(String permissionName){
        return permissions.contains(permissionName);
    } 
}