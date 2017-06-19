@isTest

//JFreese Appirio 5/10/17 S-483688

Private Class BatchProcessUnresolvedEchsignAgr_Test{
    static echosign_dev1__SIGN_Agreement__c echoSign;
    static Apttus_Proposal__Proposal__c prop;
    static List<Opportunity> ops = new List<Opportunity>();
    static List<Apttus_Proposal__Proposal__c> props = new List<Apttus_Proposal__Proposal__c>();
    static List<echosign_dev1__SIGN_Agreement__c> ags = new List<echosign_dev1__SIGN_Agreement__c>();
    static Map<String,Opportunity> runToOpp = new Map<String,Opportunity>();
    static Map<String,Apttus_Proposal__Proposal__c> runToProp = new Map<String,Apttus_Proposal__Proposal__c>();
    static Map<String,echosign_dev1__SIGN_Agreement__c> runToAgr = new Map<String,echosign_dev1__SIGN_Agreement__c>();


    @testSetup static void methodName() {
        BatchProcessUnresolvedEchsignAgreements__c settings = new BatchProcessUnresolvedEchsignAgreements__c();
        settings.name = 'Defaults';
        settings.minutesBetweenRuns__c = 120;
        settings.numIntervalsToProcess__c = 1;
        settings.isActive__c = true;
        settings.sendEmailWhenFindUnresolvedAgreements__c = false;
        settings.CC_Addresses__c = 'another.user@example.com';
        insert settings;

        Org_Settings__c orgSettings = new Org_Settings__c();
        orgSettings.Echosign_Order_Via_Agreement_Trigger__c = true;
        insert orgSettings;

        Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
        insert acc;

        DateTime thisRun = dateTime.now();
        Integer minBetween = Integer.ValueOf(settings.minutesBetweenRuns__c);
        Integer numInt = Integer.ValueOf(settings.numIntervalsToProcess__c);

        DateTime badTime1 = thisRun.addMinutes(-180); //time for the Agreement error records
        DateTime badTime2 = thisRun.addMinutes(-90); //time for the DML error record
        DateTime goodTime = thisRun.addMinutes(-45); //time for the success record

        for (Integer run=1; run<=3; run++){
            prepareData(run, acc, badTime1, 'No Opp',false,false,'','');
            prepareData(run, acc, badTime1, 'Opp has Order',true,true,'','');
            prepareData(run, acc, badTime1, 'Has Data Mapping Error',true,false,'','Dummy Error');
            prepareData(run, acc, badTime1, 'Still processing',true,false,'Processing','');
            prepareData(run, acc, badTime1, 'Unknown status',true,false,'Dummy','');
            prepareData(run, acc, badTime2, 'Throw DML Exception',true,false,'','');
            prepareData(run, acc, goodTime, 'Valid agreement',true,false,'','');

            if (run == 1) insert ops;
            else if (run == 2) insert props;
            else if (run == 3) insert ags;
        }

        system.debug('Summary of opportunities');
        for (Opportunity op : ops){
            system.debug(op);
        }

        system.debug('Summary of proposals');
        for (Apttus_Proposal__Proposal__c prop1 : props){
            system.debug(prop1);
        }

        system.debug('Summary of agreements');
        for (echosign_dev1__SIGN_Agreement__c ag : ags){
            system.debug(ag);
            system.debug('ag.opp='+ag.echosign_dev1__Opportunity__c);
        }
    }

    @isTest
    static void test1(){
        User user1 = TestDataSetupUtility.createUser('System Administrator', false);
        user1.username = 'testuser5791@test.com';
        insert user1;

        System.runAs(user1){
            //Find the 5 bogus unresolved agreements signed 180 minutes ago, resulting in an Errors Found email
            Test.startTest();
            BatchProcessUnresolvedEchsignAgreements bp = new BatchProcessUnresolvedEchsignAgreements();
            bp.execute(null);
            Test.stopTest();
        }
    }

    @isTest
    static void test2(){
        User user2 = TestDataSetupUtility.createUser('System Administrator', false);
        user2.username = 'testuser4680@test.Monster.com.Dev';
        insert user2;

        System.runAs(user2){
            Test.startTest();
            BatchProcessUnresolvedEchsignAgreements__c settings = [SELECT id, name, minutesBetweenRuns__c,
                                                                   sendEmailWhenFindUnresolvedAgreements__c
                                                                   FROM BatchProcessUnresolvedEchsignAgreements__c
                                                                   WHERE name = 'Defaults'];
            settings.minutesBetweenRuns__c = 60;
            update settings;

            /*Find the Agreement signed 90 minutes ago that throws a DML error, resulting in an Errors Found email
              This uses the TESTING_ONLY VR which throws an error on a specific name, when the agreement is
              updated with a Data Mapping Error, which is what BatchProcessUnresolvedEchsignAgreements will try to do.*/
            BatchProcessUnresolvedEchsignAgreements bp2 = new BatchProcessUnresolvedEchsignAgreements();
            bp2.execute(null);

            settings.minutesBetweenRuns__c = 30;
            settings.sendEmailWhenFindUnresolvedAgreements__c = true;
            update settings;

            //Find the one valid unresolved agreement signed 45 minutes ago, resulting in Success email and order creation
            BatchProcessUnresolvedEchsignAgreements bp3 = new BatchProcessUnresolvedEchsignAgreements();
            bp3.execute(null);

            Test.stopTest();
        }
    }

    static void prepareData(Integer run, Account acc, DateTime signTime, String thisName,
                            Boolean gotOpp, Boolean orderCreated,
                            String dataMappingResult, String dataMappingError){

        if (run == 1 && gotOpp){
            Opportunity opp = TestDataSetupUtility.createTestOpportunity(thisName, acc.Id);
            opp.OrderCreated__c = orderCreated;
            opp.Lost_Reason__c = null; //set by TestDataSetupUtility but not needed
            opp.TeamingType__c = null; //set by TestDataSetupUtility but not needed
            ops.add(opp);
            runToOpp.put(thisName,opp);
        } else if (run == 2 && gotOpp){
            prop = TestDataSetupUtility.createApttusProposal(runToOpp.get(thisName));
            prop.Apttus_Proposal__Proposal_Name__c = thisName;
            prop.Apttus_Proposal__Account__c = acc.Id;
            props.add(prop);
            runToProp.put(thisName,prop);
        }else if (run == 3){
            echoSign = new echosign_dev1__SIGN_Agreement__c ();
            echoSign.name = thisName;
            echoSign.echosign_dev1__Account__c = acc.Id;
            if (gotOpp){
                echoSign.echosign_dev1__Opportunity__c = runToOpp.get(thisName).Id;
                echoSign.Apttus_QPESign__Apttus_Proposal__c = runToProp.get(thisName).Id;
            }
            echoSign.echosign_dev1__Status__c = 'Signed';
            echoSign.echosign_dev1__DateSigned__c = signTime;
            echoSign.echosign_dev1__Data_Mapping_Result__c = dataMappingResult;
            echoSign.echosign_dev1__Data_Mapping_Error__c = dataMappingError;
            ags.add(echoSign);
        }
    }

}