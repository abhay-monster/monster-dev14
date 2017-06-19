public class kn_controller {
    public static String fullName { get; private set; }
    public static String roleName { get; private set; }
    public static String profileName { get; private set; }
    public static String recordType {get; private set; }
    public static String cp {get; private set; }
    public static String cfResultString {get; private set; }

    public static String id=UserInfo.getUserId();
    public static ID roleId=UserInfo.getUserRoleId();
    public static ID profileId=UserInfo.getProfileId();
    public static String recordID=ApexPages.CurrentPage().getparameters().get('id');
    public static String recordTypeID;
    
    public static List<String> customFields = new List<String> {''};
    
    //RDK - Initialization section
    {
        recordType='';
        fullName=UserInfo.getName();
        cp=ApexPages.CurrentPage().getparameters().get('cp');

        try {
            roleName=[select Name from userrole where id = :roleId].name;
        } catch (Exception e) {
            roleName='';
        }

        try {
            profileName=[select Name from profile where id = :profileId].name;
        } catch (Exception e) {
            profileName='';
        }

        //RDK Get the ID of the current detail record
        recordID = ApexPages.CurrentPage().getparameters().get('id');
        ID i;
        try {
            i = recordID;
        } catch (Exception e) {
            recordID='';
        }

        if(!String.isBlank(recordID)) {
            try {
                Schema.SObjectType token = i.getSObjectType();
                Schema.DescribeSObjectResult dr = token.getDescribe();
                try { //RDK Get the recordtypeid and recordtype name
                    String queryString = 'SELECT Id, RecordTypeId FROM ' + dr.getName() + 
                                            ' WHERE Id=\'' + recordID + '\' limit 1';
                    sObject result=Database.query(queryString);
                    recordTypeId=String.ValueOf(result.get('recordTypeId'));
                    queryString = 'select name from RecordType where Id=\'' + String.ValueOf(result.get('RecordTypeId') + '\'');
                    result=Database.query(queryString);
                    recordType=String.ValueOf(result.get('Name'));
                } catch (Exception e) {
                    //RDK Couldn't get the recordtype for whatever reason
                    recordType='';
                }
                
                //RDK Loop through the custom fields, and try to get the data
                integer cfCount=0;
                for (String customField: customFields) {
                    cfCount++;
                    try { //RDK Get custom field
                        String queryString = 'SELECT Id, ' + customField + ' FROM ' + dr.getName() + 
                                                ' WHERE Id=\'' + recordID + '\' limit 1';
                        sObject result=Database.query(queryString);

                        cfResultString+='&cf' + cfCount + '=' + EncodingUtil.urlEncode(String.ValueOf(result.get(customField)), 'UTF-8');
                    } catch (Exception e) {
                        //RDK Couldn't get the custom field for whatever reason
                    }
                }
            } catch (Exception e) {
                recordType='';
            }
        }
    }
}