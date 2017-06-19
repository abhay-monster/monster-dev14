public with sharing class StrategicAccountPlanTriggerHelper {
    final String CLASSNAME = '\n\n**** StrategicAccountPlanTriggerHelper.METHODNAME()';
    public static boolean updateChildFlag = false;
    private String UserProfileName{get; private set;}
    public Org_Settings__c   settings = Org_Settings__c.getInstance();
/*
** @author : Cloud Sherpas Inc.
** @date : 04/17/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the AccountTriggerHelper class
*/
    public StrategicAccountPlanTriggerHelper(){

    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 09/2/2014
** @description : update the Billing agency field of strategic account plan.
** @paramaters : List of related partners
** @returns : nothing
*/
    public void updateBillingAgency(map<ID, Strategic_Account_Plan__c> newStrategicAccountPlanMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateBillingAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            List<Strategic_Account_Plan__c> newSap = [SELECT Id, BillingAgency__c,Account_Name__c FROM Strategic_Account_Plan__c WHERE Id In : newStrategicAccountPlanMap.keySet()];
            Set<ID> accID = new Set<ID>();
            for(Strategic_Account_Plan__c sapList : newSap){
                accID.add(sapList.Account_Name__c);
            }
            List<Strategic_Account_Plan__c> sapToUpdate = new List<Strategic_Account_Plan__c>();
            List<Account> acc = [SELECT Id, (SELECT Id, AgencyType__c, Partner__c,Account__c,Name FROM Related_Partners__r) FROM Account WHERE Id In: accID ];
            List<RelatedPartner__c> repPartner = new List<RelatedPartner__c>();

            for(Account a : acc){
                Boolean haveBillingAGency = false;
                for(RelatedPartner__c rp : a.Related_Partners__r){
                    if(!haveBillingAGency){
                        if(rp.AgencyType__c == 'Billing'){
                            for(Strategic_Account_Plan__c sap : newSap){
                                if(sap.Account_Name__c ==  rp.Account__c){
                                    //I-187239 JFreese Appirio - following line prevents infinite loop - too many SOQL
                                    if(sap.BillingAgency__c != rp.Name){
                                        sap.BillingAgency__c = rp.Name;
                                        haveBillingAGency = true;
                                        sapToUpdate.add(sap);
                                        break;
                                    }
                                }
                            }
                        }
                    } else {
                        break;
                    }
                }
            }
            if(sapToUpdate.size() > 0){
                update sapToUpdate;
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, ' NO Strategic_Account_Plan__c updated .', bae);
        }
    }
    /*
** @author : Cloud Sherpas, Inc.
** @date : 09/2/2014
** @description : update the Billing agency field of strategic account plan.
** @paramaters : List of related partners
** @returns : nothing
*/
    public void checkAccount(List<Strategic_Account_Plan__c> newStrategicAccountPlanList){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateBillingAgency');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        try{
            Set<Id> accId = new Set<Id>();
            Map<Id, Strategic_Account_Plan__c> planMap = new Map<Id, Strategic_Account_Plan__c>();
            for(Strategic_Account_Plan__c sapList : newStrategicAccountPlanList){
                planMap.put(sapList.Account_Name__c, sapList);
                accId.add(sapList.Account_Name__c);
            }
            //Change start by Gaurav Gupta on 30 Jan 2016 for S-447685
            map<id , contact> mapAccountContact = new map<id , contact>();
            list<contact> lstContacts = [select Title,id, Email , AccountId from contact where accountId in: accId and PrimarySalesContact__c = true];
            for(Contact c : lstContacts){
                if(!mapAccountContact.containskey(c.AccountId))
                       mapAccountContact.put(c.AccountId , c);
            }
           // system.assert(false,accId);
            for(Strategic_Account_Plan__c saP :newStrategicAccountPlanList){
                saP.PPC_Specialist__c = saP.CreatedById;
                if(mapAccountContact.containskey(saP.Account_Name__c)){
                    saP.Primary_Contact__c = mapAccountContact.get(saP.Account_Name__c).id;
                    saP.Primary_Contact_Email__c = mapAccountContact.get(saP.Account_Name__c).Email;
                    saP.Primary_Contact_Title__c = mapAccountContact.get(saP.Account_Name__c).Title;
                    }
            }
            //Change end by Gaurav Gupta on 30 Jan 2016 for S-447685
            
            List<Strategic_Account_Plan__c> sap = [SELECT Id, Account_Name__c,Plan_Type__c FROM Strategic_Account_Plan__c WHERE Account_Name__c in: accId];
            if(!sap.isEmpty()){
                for(Strategic_Account_Plan__c sapListError : sap){
                    if(planMap.get(sapListError.Account_Name__c).Id == null){
                        if(planMap.containsKey(sapListError.Account_Name__c)){
                            if(planMap.get(sapListError.Account_Name__c).Plan_Type__c == sapListError.Plan_Type__c){
                                planMap.get(sapListError.Account_Name__c).addError('Account already have the plan type. Pick another Plan type');
                            }
                        }
                    } else {
                        if(planMap.containsKey(sapListError.Account_Name__c)){
                            if(planMap.get(sapListError.Account_Name__c).Id != sapListError.Id){
                                if(planMap.get(sapListError.Account_Name__c).Plan_Type__c == sapListError.Plan_Type__c){
                                    planMap.get(sapListError.Account_Name__c).addError('Account already have the plan type. Pick another Plan type');
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception bae){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, ' NO Strategic_Account_Plan__c updated .', bae);
        }
    }
}