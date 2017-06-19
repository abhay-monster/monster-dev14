/*
** @author : Dino brinas, Cloud Sherpas Inc.
** @date : 01/12/2015
** @description : Channel Allignment tab from Chatter profile test 
*/
@isTest
public class UserRecordAccessControllerTest{
    static testmethod void myUnitTest(){
        Id DataSteward_PROFILE_ID = [select Id From Profile Where Name = 'Data Steward'].Id;
        Boolean isSaveInfoDisplayed = false;

        //Creating running user
        String profileIdSysAdmin = TestDataSetupUtility.PROFILE_ID;
        User usedUserSysAdmin = TestDataSetupUtility.createTestUser('Test First Name', 'Test Last Name', profileIdSysAdmin );
        insert usedUserSysAdmin;

        //Creating user to be modified
        String profileDataSteward = DataSteward_PROFILE_ID;
        User usedUserDataSteward = TestDataSetupUtility.createTestUser('Test First Name Test User', 'Test Last Name Test User', profileDataSteward );
        insert usedUserDataSteward;

        PageReference pageref = Page.UserRecordAccess;
        Test.setCurrentPage(pageref);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(usedUserDataSteward);
        ApexPages.currentPage().getParameters().put('sfdc.userId',usedUserDataSteward.id);
        UserRecordAccessController controller = new UserRecordAccessController(sc);


        //Page run as System Administrator profile
        System.runAs(usedUserSysAdmin){
            Test.startTest();
            usedUserDataSteward.Combined_Region__c = 'Southeast';
            controller.save();
            Test.stopTest();
            List<ApexPages.Message> lMessage = ApexPages.getMessages();
            for(ApexPages.Message lMsg : lMessage){
                if(lMsg.getDetail().contains('The record has been saved successfully')){
                    isSaveInfoDisplayed = true;
                }
            }
            System.assert(isSaveInfoDisplayed);
            System.assertEquals('Southeast', usedUserDataSteward.Combined_Region__c);
        }
        
        PageReference pageref1 = Page.UserRecordAccess;
        Test.setCurrentPage(pageref1);
        ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(usedUserDataSteward);
        //ApexPages.currentPage().getParameters().put('sfdc.userId',usedUserDataSteward.id);
        UserRecordAccessController controller1 = new UserRecordAccessController(sc1);

    }
}