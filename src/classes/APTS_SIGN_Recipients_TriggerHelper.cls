public class APTS_SIGN_Recipients_TriggerHelper {
    final String CLASSNAME = '\n\n**** APTS_EchoSignAgreementTriggerHelper.METHODNAME()';
    
    private Set<String> DataGovernanceProfiles = new Set<String> {
        'Data Steward',
            'Sales Operations'
            };
                
                private Set<String> OtherPermittedProfiles = new Set<String> {
                    'Sales Rep (APAC)',
                        'Sales Rep (EU)',
                        'Sales Rep (NA)',
                        'Sales Manager (APAC)',
                        'Sales Manager (EU)',
                        'Sales Manager (NA)',
                        'System Administrator'
                        };
                            
                            private Set<String> editabilityProfiles = new Set<String> {
                                'Sales Operations',
                                    'System Administrator'
                                    };
                                        
                                        private String UserProfileName{get; private set;}
    
    /*private map<Id, User> UserIdToUserMap {
get{
if(UserIdToUserMap == NULL){
UserIdToUserMap = new map<Id,User>([SELECT Id, ManagerId FROM User]);
}
return UserIdToUserMap;
}
private set;
}*/
    public static APTS_SIGN_Recipients_TriggerHelper NewTriggerHelper(String pUserProfileName) {
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        APTS_SIGN_Recipients_TriggerHelper newHelper = new APTS_SIGN_Recipients_TriggerHelper(pUserProfileName);
        return newHelper;
    }
    
    private APTS_SIGN_Recipients_TriggerHelper(String pUserProfileName) {  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','APTS_SIGN_Recipients_TriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName; 
    }
    
    public boolean CheckContact(List<echosign_dev1__SIGN_Recipients__c> ReceipientList)
    {
        MAP<id,set<id>> MAPRecipientAccountList = new MAP<id,set<id>>();
        MAP<id,id>  MAPAgreementAccountList = new MAP<id,id>();
        MAP<id,set<id>>  MAPAgreementAllRelatedAccountList = new MAP<id,set<id>>();
        
        for(echosign_dev1__SIGN_Recipients__c oTemp : ReceipientList)
        {
            If(oTemp.echosign_dev1__Recipient_Type__c == 'Contact' && oTemp.Contact_Account__c != null && !oTemp.Is_Agency_Contact__c)
            {
                if(MAPRecipientAccountList.containsKey(oTemp.echosign_dev1__Agreement__c))
                {
                    set<id> TempSet = MAPRecipientAccountList.get(oTemp.echosign_dev1__Agreement__c);
                    TempSet.add(oTemp.Contact_Account__c);
                }
                else
                {
                    set<id> TempSet = new set<id>();
                    TempSet.add(oTemp.Contact_Account__c);
                    MAPRecipientAccountList.put(OTemp.echosign_dev1__Agreement__c,TempSet);
                }
                
                if(!MAPAgreementAccountList.containsKey(oTemp.Agreement_Account__c))
                {
                    MAPAgreementAccountList.put(Otemp.Agreement_Account__c,OTemp.echosign_dev1__Agreement__c); 
                    set<id> tempSet = new set<id>();
                    tempSet.add(oTemp.Agreement_Account__c);
                    MAPAgreementAllRelatedAccountList.put(OTemp.echosign_dev1__Agreement__c, tempSet); 
                }
            }
        }
        
        system.debug(LoggingLevel.INFO,'MAPAgreementAccountList++++'+MAPAgreementAccountList);
        system.debug(LoggingLevel.INFO,'MAPAgreementAllRelatedAccountList++++'+MAPAgreementAllRelatedAccountList);
        system.debug(LoggingLevel.INFO,'MAPRecipientAccountList++++'+MAPRecipientAccountList);
        
             
        List<RelatedPartner__c> PArtnerList = new List<RelatedPartner__c>(); 
        If(MAPAgreementAccountList.size() > 0)
        {
        PArtnerList = [select id, Account__c, Partner__c 
                                               FROM RelatedPartner__c
                                               WHERE Account__c =:MAPAgreementAccountList.keySet() ];
        system.debug(LoggingLevel.INFO,'PArtnerList++++'+PArtnerList);
        }
        for(RelatedPartner__c oTemp : PArtnerList)
        {
            If(MAPAgreementAccountList.containsKey(oTemp.Account__c))
            {
                id Tempid = MAPAgreementAccountList.get(oTemp.Account__c);
                If(MAPAgreementAllRelatedAccountList.containsKey(Tempid))
                {
                    set<id> tempSet =   MAPAgreementAllRelatedAccountList.get(Tempid) ;
                    tempSet.add(oTemp.Account__c);
                    tempSet.add(oTemp.Partner__c);
                }
                
            }
        }
        
        for(id tempId : MAPRecipientAccountList.keySet() )
        {
            set<id> ContactAccountSet = MAPRecipientAccountList.get(tempId);
            set<id> RelatedAccountSet = MAPAgreementAllRelatedAccountList.get(tempId);
            system.debug(LoggingLevel.INFO,'ContactAccountSet++++'+ContactAccountSet);
            system.debug(LoggingLevel.INFO,'RelatedAccountSet++++'+RelatedAccountSet);
            for(id AccountId : ContactAccountSet)
            {
                If(!RelatedAccountSet.contains(AccountId))
                {
                    return False;
                }
            }
        }
        return true;
    }
}