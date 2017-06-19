/***************************************************************************************************************
* @author Jonathan Freese, Appirio S-470331
* @date   Apr 16 2017
* @description: Tool for extracting Approval Process data in a manner which will permit comparison between orgs
* @note: Tool is currently run via APEX anonymous
****************************************************************************************************************/

public without sharing class ApprovalProcessTool{

    public void run(){
        runApprovalProcessTool();
    }

    @future
    public static void runApprovalProcessTool(){
        Approval_Process_Tool__c settings = Approval_Process_Tool__c.getValues('Defaults');
        Map<String, String> obj = new Map<String, String>{
            'Credit_Request__c' => 'CR',
            'Case' => 'CS',
            'Apttus_Config2__ProductConfiguration__c' => 'PC',
            'Apttus_Proposal__Proposal__c' => 'QP'
        };

        String prefix = settings.csvPrefix__c;
        Boolean getIds = settings.getIds__c;
        Boolean getIdsForCSVert = settings.getIdsForCSVert__c; //unlikely anyone would want this as all will differ, but...
        Boolean getLev1EntryCriteria = settings.getLev1EntryCriteria__c;
        Boolean getLev1Sequence = settings.getLev1Sequence__c;
        Boolean getLev2StepSequence = settings.getLev2StepSequence__c;
        Boolean getLev2StepFilterLogic = settings.getLev2StepFilterLogic__c;
        Boolean getLev3StepNumber = settings.getLev3StepNumber__c; //this does not exist in the data,
                                                                   //it is the order in which the IDs occur
        Boolean getLev3StepFilter = settings.getLev3StepFilter__c; //the level 2 ID that connects the level 3 records
        Boolean getLev3ExtraFields = settings.getLev3ExtraFields__c; //other populated fields (needed for delete & replace)
        Boolean getVertLev1 = settings.getVertLev1__c;
        Boolean getVertLev2 = settings.getVertLev2__c;
        Boolean getVertLev3 = settings.getVertLev3__c;
        Integer debugCutoff = Integer.ValueOf(settings.debugCutoff__c);
        Boolean makeCSV = settings.makeCSV__c;
        String delim = settings.delim__c; //Hard returns (\n) inside long text fields will break the csv file,
                                          //so replace them with this
        String qt = settings.qt__c; //CSV files like double quotes for surrounding each value,
                                    //but may want something else (or nothing)

        if (test.isRunningTest()){
            prefix = 'Test_';
            getIds = true;
            getIdsForCSVert = true;
            getLev1EntryCriteria = true;
            getLev1Sequence = true;
            getLev2StepSequence = true;
            getLev2StepFilterLogic = true;
            getLev3StepNumber = true;
            getLev3StepFilter = true;
            getLev3ExtraFields = true;
            getVertLev1 = true;
            getVertLev2 = true;
            getVertLev3 = true;
            debugCutoff = 100;
            makeCSV = true;
            delim = '^';
            qt = '"';
        }

        String key = '';
        Set<ID> Lev1IDs = new Set<ID>();
        Set<ID> Lev2IDs = new Set<ID>();
        Set<ID> Lev3IDs = new Set<ID>();
        Map<ID, String> Lev1IdToKey = new Map<ID, String>();
        Map<ID, String> Lev2IdToKey = new Map<ID, String>();
        Map<ID, String> Lev3IdToKey = new Map<ID, String>();
        Integer ctr = 0;
        Integer keyLen = 0;
        Integer maxLen = 0;
        String query = '';
        String hold = '';
        String csvert = 'Key,Field,Value\n'; //transposed combined version of csv1-3


        //set up csv1 fields
        List<String> csv1Fields = new List<String>();
        if (getIds == true) csv1Fields.add('ID'); //If included, want it right after Key
        Set<String> csv1FieldSet1 = new Set<String>{'Apttus_Approval__Object_Label__c','Apttus_Approval__Process_Name__c',
                                                    'Apttus_Approval__Object_Name__c'};
        if (getLev1Sequence == true) csv1FieldSet1.add('Apttus_Approval__Sequence__c');
        Set<String> csv1FieldSet2 = new Set<String>{'Apttus_Approval__ContextType__c',
                                                    'Apttus_Approval__BackupAdminUser__c',
                                                    'Apttus_Approval__Assignment_Email_Template__c',
                                                    'Apttus_Approval__ApprovalSummaryPage__c',
                                                    'Apttus_Approval__Reassignment_Email_Template__c',
                                                    'Apttus_Approval__CustomMyApprovalsPage__c',
                                                    'Apttus_Approval__Escalation_Email_Template__c',
                                                    'Apttus_Approval__ConsolidateApprovals__c',
                                                    'Apttus_Approval__Cancellation_Email_Template__c',
                                                    'Apttus_Approval__ConsolidateNotifications__c',
                                                    'Apttus_Approval__NotifyOnly_Email_Template__c',
                                                    'Apttus_Approval__ContinuePendingApprovalsOnAReject__c',
                                                    'Apttus_Approval__SubmissionCommentsEnabled__c',
                                                    'Apttus_Approval__SubmissionCommentsType__c',
                                                    'Apttus_Approval__SubmissionCommentsPerStep__c',
                                                    'Apttus_Approval__SubmissionComment1Label__c',
                                                    'Apttus_Approval__SubmissionComment2Label__c',
                                                    'Apttus_Approval__SubmissionComment3Label__c'};
        csv1Fields.addAll(csv1FieldSet1);
        csv1Fields.addAll(csv1FieldSet2);
        String csv1FieldStr = string.join(csv1Fields,',');

        String insertBefore = 'Apttus_Approval__Assignment_Email_Template__c';
        String csv1 = 'Key';
        for (String fld : csv1Fields){
            if (getLev1EntryCriteria == true && fld == insertBefore){
                csv1 += ',EntryCriteria,'+fld;
            }else{
                csv1 += ','+fld;
            }
        }
        csv1 += '\n'; //this is the header line for the csv1 file

        //set up the csv1 subquery fields
        List<String> csv1subHeader = new List<String>{'Apttus_Approval__Entry_Criteria__c',
                                                      'Apttus_Approval__Entry_Criteria_Active__c'};
        String csv1subHeaderStr = string.join(csv1subHeader,',');
        List<String> csv1subFields = new List<String>{'Apttus_Approval__Entry_Criteria_Field__c',
                                                      'Apttus_Approval__Entry_Criteria_Comparison_Type__c',
                                                      'Apttus_Approval__Entry_Criteria_Field_Value__c',
                                                      'Apttus_Approval__Entry_Criteria_BoolOper__c'};
        String csv1subFieldStr = string.join(csv1subFields,',');


        //set up csv2 fields
        List<String> csv2Fields = new List<String>();
        if (getIds == true) csv2Fields.add('ID'); //If included, want it right after Key
        Set<String> csv2FieldSet = new Set<String>{'Apttus_Approval__Step_Active__c','Apttus_Approval__StepLabel__c',
                                                   'Apttus_Approval__Step_Name__c','Apttus_Approval__StepType__c',
                                                   'Apttus_Approval__Step_Assignee_Type__c',
                                                   'Apttus_Approval__Step_Assignee__c','Apttus_Approval__DependsOn__c',
                                                   'Apttus_Approval__Step_Auto_Complete__c',
                                                   'Apttus_Approval__StepAutoEscalate__c',
                                                   'Apttus_Approval__Send_Email__c','Apttus_Approval__Step_Notify_Only__c'};
        csv2Fields.addAll(csv2FieldSet);
        if (getLev2StepSequence == true) csv2Fields.add('Apttus_Approval__StepSequence__c');
        if (getLev2StepFilterLogic == true) csv2Fields.add('Apttus_Approval__StepFilterLogic__c');
        String csv2FieldStr = string.join(csv2Fields,',');
        String csv2 = 'Key,'+csv2FieldStr+'\n';  //this is the header line for the csv2 file

        //set up csv3 fields
        List<String> csv3Fields = new List<String>();
        List<String> csv3ExtraFields = new List<String>();
        Set<String> csv3FieldSet = new Set<String>{'Apttus_Approval__Step_Filter_Field__c',
                                                   'Apttus_Approval__Step_Filter_Comparison_Type__c',
                                                   'Apttus_Approval__Step_Filter_Field_Value__c'};
        Set<String> csv3ExtraFieldSet = new Set<String>{'APTS_Ext_ID__c','Apttus_Approval__Active__c',
                                                        'Apttus_Approval__CancelPendingRequestsOnAReject__c',
                                                        'Apttus_Approval__ConsolidateApprovals__c',
                                                        'Apttus_Approval__ConsolidateNotifications__c',
                                                        'Apttus_Approval__ContinuePendingApprovalsOnAReject__c',
                                                        'Apttus_Approval__Entry_Criteria_Active__c',
                                                        'Apttus_Approval__Entry_Criteria_BoolOper__c',
                                                        'Apttus_Approval__Final_Action_Field_Name_Source__c',
                                                        'Apttus_Approval__Initial_Submission_Field_Name_Source__c',
                                                        'Apttus_Approval__ProcessAutoEscalate__c',
                                                        'Apttus_Approval__Send_Email__c',
                                                        'Apttus_Approval__Step_Active__c',
                                                        'Apttus_Approval__Step_Auto_Complete__c',
                                                        'Apttus_Approval__Step_Filter_BoolOper__c',
                                                        'Apttus_Approval__Step_Filter_Field_Object__c',
                                                        'Apttus_Approval__Step_Group_Action_Field_Name_Source__c',
                                                        'Apttus_Approval__Step_Group_Active__c',
                                                        'Apttus_Approval__Step_Notify_Only__c',
                                                        'Apttus_Approval__StepAutoEscalate__c',
                                                        'Apttus_Approval__StepAutoReapprove__c',
                                                        'Apttus_Approval__StepSubmissionComment1Enabled__c',
                                                        'Apttus_Approval__StepSubmissionComment2Enabled__c',
                                                        'Apttus_Approval__StepSubmissionComment3Enabled__c',
                                                        'Apttus_Approval__StepSubmissionCommentsEnabled__c',
                                                        'Apttus_Approval__SubmissionCommentsEnabled__c',
                                                        'Apttus_Approval__SubmissionCommentsEnabledCount__c',
                                                        'Apttus_Approval__SubmissionCommentsPerStep__c',
                                                        'Apttus_Approval__SubmissionCommentsType__c',
                                                        'CreatedById','CreatedDate','CurrencyIsoCode','IsDeleted',
                                                        'LastModifiedById','LastModifiedDate','OwnerId',
                                                        'RecordType_Text__c','RecordTypeId','SystemModstamp'};
        csv3Fields.addAll(csv3FieldSet);
        csv3ExtraFields.addAll(csv3ExtraFieldSet);

        String csv3FieldStr = string.join(csv3Fields,',');
        String csv3 = 'Key';
        if (getLev3StepFilter == true) csv3 += ',Apttus_Approval__Step_Filter__c';
        if (getIds == true) csv3 += ',ID';
        if (getLev3StepNumber == true) csv3 += ',StepNumber';
        csv3 += '\n';  //this is the header line for the csv3 file


        //Level 1
        query =  'SELECT ';
        if (getIds == false) query += 'ID,'; // always need this internally
        query += csv1FieldStr;
        query += ', (SELECT '+csv1subHeaderStr+','+csv1subFieldStr+' ';
        query += 'FROM Apttus_Approval__Approval_Process__c.Apttus_Approval__Entry_Criteria__r) ';
        query += 'FROM Apttus_Approval__Approval_Process__c ';
        query += 'WHERE Apttus_Approval__Active__c = true AND Apttus_Approval__Object_Name__c != null ';
        query += 'ORDER BY Apttus_Approval__Object_Name__c, Apttus_Approval__Sequence__c';

        List <Apttus_Approval__Approval_Process__c> lev1Recs = Database.query(query);
        keyLen = String.ValueOf(lev1Recs.size()).length();
        Map <String,Apttus_Approval__Approval_Process__c> lev1KeyToRec= new Map <String,Apttus_Approval__Approval_Process__c>();
        List <String> lev1Keys = new List<string>();

        for (Apttus_Approval__Approval_Process__c lev1 : lev1Recs){
            if (obj.containsKey(lev1.Apttus_Approval__Object_Name__c)){
                key = obj.get(lev1.Apttus_Approval__Object_Name__c);
            }
            else{
                String err = 'Map<String, String> obj has no key for object '+lev1.Apttus_Approval__Object_Name__c;
                throw BaseApplicationException.NewException('ApprovalProcessTool', err);
                return;
            }

            if (lev1.Apttus_Approval__Sequence__c != null){
               key += '.'+String.ValueOf(lev1.Apttus_Approval__Sequence__c).leftPad(keyLen).replaceAll(' ','0');
            }
            lev1Keys.add(key);
            lev1KeyToRec.put(key,lev1);
        }
        lev1Keys.sort();

        for (String thisKey : lev1Keys){
            Apttus_Approval__Approval_Process__c lev1 = lev1KeyToRec.get(thisKey);

            String entryCriteria = '';
            /*NOTE: The Apttus code does a lot of processing on the subquery fields to present them to the user,
                    including but not limited to:
                    1) puts each comparison in parentheses()
                    2) surrounds each text comparator with single ticks ''
                    3) changes comparison operators from text to symbol (not equal to > !=, contains > LIKE, etc)
                    4) drops the last AND if there is one

                    Rather than trying to reproduce their processing, just show the data as it is.*/
            for(Apttus_Approval__Approval_Process__c lev1subRec : lev1.Apttus_Approval__Entry_Criteria__r) {
                String thisId = String.valueof(lev1subRec.get('Apttus_Approval__Entry_Criteria__c'));
                Boolean active = Boolean.valueof(lev1subRec.get('Apttus_Approval__Entry_Criteria_Active__c'));
                if (active){
                    for(String fld : csv1subFields){
                        if (entryCriteria != ''){
                            entryCriteria += ' ';
                        }
                        entryCriteria += getFld(lev1subRec,fld,delim);
                    }
                }
            }
            //system.debug('Name='+lev1.Apttus_Approval__Process_Name__c+', entryCriteria='+entryCriteria);

            csv1 += thisKey;
            for(String fld : csv1Fields){
                if (fld == 'ID' && getIds == true){
                    csv1 += ','+lev1.get(fld);
                    if (getIdsForCSVert == true && getVertLev1 == true){
                        csvert += thisKey+',ID,'+lev1.get(fld)+'\n';
                    }
                }
                else if (getLev1EntryCriteria == true && fld == insertBefore){
                    csv1 += ','+qt+entryCriteria+qt+','+qt+getFld(lev1,fld,delim)+qt;
                    if (getVertLev1 == true) csvert += thisKey+',EntryCriteria,'+qt+EntryCriteria+qt+'\n'+thisKey+','+fld+','+qt+getFld(lev1,fld,delim)+qt+'\n';
                }
                else {
                    csv1 += ','+qt+getFld(lev1,fld,delim)+qt;
                    if (getVertLev1 == true) csvert += thisKey+','+fld+','+qt+getFld(lev1,fld,delim)+qt+'\n';
                }
            }
            csv1 += '\n';

            Lev1IDs.add(lev1.Id);
            Lev1IdToKey.put(lev1.Id, thisKey);
        }
        system.debug('Lev1IDs.size()='+Lev1IDs.size());
        debugCSV('csv1',csv1,debugCutoff);
        if (makeCSV == true) createCSVfile(prefix,'Level_1',csv1);
        //return;

        //Level 2
        query =  'SELECT Id, Apttus_Approval__Step_Group__c, (SELECT ';
        if (getIds == false) query += 'ID,'; // always need this internally
        query += csv2FieldStr+' FROM Apttus_Approval__Approval_Process__c.Apttus_Approval__Step__r ';
        query += 'ORDER BY Apttus_Approval__StepSequence__c) FROM Apttus_Approval__Approval_Process__c ';
        query += 'WHERE Apttus_Approval__Step_Group__c IN: Lev1IDs';
        List <Apttus_Approval__Approval_Process__c> all_lev2Recs = Database.query(query);

        Map <String,Apttus_Approval__Approval_Process__c> lev2KeyToRec= new Map <String,Apttus_Approval__Approval_Process__c>();
        List <String> lev2Keys = new List<string>();

        //Go through the data once to find the longest list of approval steps for the keyLen zero padding
        maxLen = 0;
        for (Id thisId : Lev1IdToKey.keySet()){
            ctr=0;
            Apttus_Approval__Approval_Process__c lev2Rec = new Apttus_Approval__Approval_Process__c();

            for(Apttus_Approval__Approval_Process__c thisRec : all_lev2Recs){
                if(thisRec.Apttus_Approval__Step_Group__c == thisId) lev2Rec = thisRec;
            }
            for(Apttus_Approval__Approval_Process__c lev2 : lev2Rec.Apttus_Approval__Step__r){
                ctr++;
            }
            if (ctr > maxLen) maxLen = ctr;
        }
        keyLen = String.ValueOf(maxLen).length();

        //now process the data
        for (Id thisId : Lev1IdToKey.keySet()){
            ctr=0;
            Apttus_Approval__Approval_Process__c lev2Rec = new Apttus_Approval__Approval_Process__c();

            for(Apttus_Approval__Approval_Process__c thisRec : all_lev2Recs){
                if(thisRec.Apttus_Approval__Step_Group__c == thisId) lev2Rec = thisRec;
            }
            for(Apttus_Approval__Approval_Process__c lev2 : lev2Rec.Apttus_Approval__Step__r) {
                ctr++;
                key = Lev1IdToKey.get(thisId) + '.' + String.ValueOf(ctr).leftPad(keyLen).replaceAll(' ','0');
                lev2Keys.add(key);
                lev2KeyToRec.put(key,lev2);
            }
        }
        lev2Keys.sort();

        for (String thisKey : lev2Keys){
            Apttus_Approval__Approval_Process__c lev2 = lev2KeyToRec.get(thisKey);

            hold = thisKey;
            for(String fld : csv2Fields){
                if (fld == 'ID' && getIds == true){
                    hold += ','+lev2.get(fld);
                    if (getIdsForCSVert == true && getVertLev2 == true){
                        csvert += thisKey+',ID,'+lev2.get(fld)+'\n';
                    }
                }else{
                    hold += ','+qt+lev2.get(fld)+qt;
                    if (getVertLev2 == true) csvert += thisKey+','+fld+','+qt+getFld(lev2,fld,delim)+qt+'\n';
                }
            }
            csv2 += replaceAll(hold, '\n', delim, debugCutoff);
            csv2 += '\n';

            Lev2IDs.add(lev2.Id);
            Lev2IdToKey.put(lev2.Id, thisKey);
        }
        system.debug('Lev2IDs.size()='+Lev2IDs.size());
        debugCSV('csv2',csv2,debugCutoff);
        if (makeCSV == true) createCSVfile(prefix,'Level_2',csv2);
        //return;

        //Level 3
        query =  'SELECT Apttus_Approval__Step_Filter__c, Name, ';
        if (getIds == false) query += 'ID,'; // always need this internally
        query += csv3FieldStr+' FROM Apttus_Approval__Approval_Process__c ';
        query += 'WHERE Apttus_Approval__Step_Filter__c IN: Lev2IDs ';
        query += 'ORDER BY Apttus_Approval__Step_Filter__c, Name';
        List <Apttus_Approval__Approval_Process__c> lev3Recs = Database.query(query);

        Map <String,Apttus_Approval__Approval_Process__c> lev3KeyToRec= new Map <String,Apttus_Approval__Approval_Process__c>();
        List <String> lev3Keys = new List<string>();


        //Go through the data once to find the longest list of approval steps for the keyLen zero padding
        maxLen = 0;
        hold = '';
        for(Apttus_Approval__Approval_Process__c lev3 : lev3Recs){
            String thisId = lev3.Apttus_Approval__Step_Filter__c;
            if (thisId != hold) ctr = 1;
            else ctr++;
            hold = thisId;
            if (ctr > maxLen) maxLen = ctr;
        }
        keyLen = String.ValueOf(maxLen).length();

        //now process the data
        hold = '';
        for(Apttus_Approval__Approval_Process__c lev3 : lev3Recs){
            String thisId = lev3.Apttus_Approval__Step_Filter__c;

            if (thisId != hold) ctr = 1;
            else ctr++;

            hold = thisId;

            //make a throw-away key to use for sorting the records
            key = qt + Lev2IdToKey.get(thisId)+'.'+String.ValueOf(ctr).leftPad(keyLen).replaceAll(' ','0');
            lev3Keys.add(key);
            lev3KeyToRec.put(key,lev3);
        }
        lev3Keys.sort();

        for (String thisKey : lev3Keys){
            Apttus_Approval__Approval_Process__c lev3 = lev3KeyToRec.get(thisKey);
            String thisId = lev3.Apttus_Approval__Step_Filter__c;
            ctr = Integer.ValueOf(thisKey.right(keyLen));

            key = qt + Lev2IdToKey.get(thisId)+
                  '.'+lev3.Apttus_Approval__Step_Filter_Field__c+
                  '.'+lev3.Apttus_Approval__Step_Filter_Comparison_Type__c+
                  '.'+lev3.Apttus_Approval__Step_Filter_Field_Value__c + qt;

            csv3 += key;

            if (getLev3StepFilter == true){
                csv3 += ','+thisId;
                if (getVertLev3 == true) csvert += key+',Apttus_Approval__Step_Filter__c,'+thisId+'\n';
            }
            if (getIds == true){
                csv3 += ','+lev3.Id;
                if (getIdsForCSVert == true && getVertLev3 == true){
                    csvert += key+',ID,'+lev3.Id+'\n';
                }
            }

            if (getLev3StepNumber == true){
                csv3 += ','+ctr;
                if (getVertLev3 == true) csvert += key+',StepNumber,'+ctr+'\n';
            }

            csv3 += '\n';

            Lev3IDs.add(lev3.Id);
            Lev3IdToKey.put(lev3.Id, key);
        }
        system.debug('Lev3IDs.size()='+Lev3IDs.size());
        debugCSV('csv3',csv3,debugCutoff);
        if (makeCSV == true) createCSVfile(prefix,'Level_3',csv3);
        if (makeCSV == true) createCSVfile(prefix,'Vertical',csvert);

        if (getLev3ExtraFields == true) {
            String dbg = '\n\nThe getLev3ExtraFields option was intended to add '+csv3ExtraFields.size()+' fields\n';
            dbg += 'to the csv3 file.  But this results in an APEX HEAP error because there is simply too much\n';
            dbg += 'data to add to the csv3 string and output to the file.  One fix could be process the csv3 data\n';
            dbg += 'in batches and output multiple csv3 files.  But this is not worth the effort at present, because\n';
            dbg += 'thie option is only intended for when Level 3 records are to be deleted from (e.g.) Dev and\n';
            dbg += 're-inserted in the same order as (e.g.) Prod, which is rare enough that we can use dataloader\n';
            dbg += 'to extract the extra data to combine in Excel.\n\n';
            dbg += 'This is the SOQL query to use to extract the extra data:\n\n';
            dbg += 'SELECT ID, name, Apttus_Approval__Step_Filter__c';
            for(String fld : csv3ExtraFields){
                dbg += ', '+fld;
            }
            dbg += '\nFROM Apttus_Approval__Approval_Process__c WHERE Apttus_Approval__Step_Filter__c IN ()\n';
            dbg += ' ORDER BY Apttus_Approval__Step_Filter__c, Name\n';
            system.debug(dbg);
        }
    }

    public static void createCSVfile(String prefix, String levName, String contents){
        String csvFile = prefix+levName+'.csv';
        ContentVersion file = new ContentVersion(
            title=csvFile,
            versionData = Blob.valueOf(contents),
            pathOnClient = '/'+csvFile
        );
        if (!test.isRunningTest()) insert file;
        System.debug(file);
    }

    public static String getFld(Apttus_Approval__Approval_Process__c thisRec, String thisFld, String delim){
        //Get the value, then swap all internal hard returns for a designated delimiter
        String hold = String.ValueOf(thisRec.get(thisFld));
        //system.debug('hold='+hold);
        String retVal = '';
        if (hold != '' && hold != null) retVal = hold.replaceAll('[\n]',delim);
        return retVal;
    }

    public static String replaceAll(String input, String targ, String delim, Integer cutoff){
        String retVal = '';
        String hold = '';
        Integer ptr = input.IndexOf(targ);
        if (ptr < 0){
            retVal = input;
        }else{
            if (cutoff <= 5) system.debug('Found hard return(s): '+input);
            hold = input;
            while(ptr >= 0){
                hold = hold.left(ptr) + delim+ hold.subString(ptr + 1);
                ptr = hold.IndexOf(targ);
            }
            retVal = hold;
            if (cutoff <= 5) system.debug('Replaced w/ '+delim+': '+ retVal);
        }
        return retVal;
    }

    public static void debugCSV(string csvName, string csv, Integer cutoff){
        List<String> lines = csv.split('\n');
        Integer numLines = 0;
        if (cutoff > lines.size()){
            numLines = lines.size();
            system.debug('All '+numLines+' lines of '+csvName+'.csv');
        }else {
            numLines = cutoff;
            system.debug('First '+numLines+' lines of '+csvName+'.csv');
        }
        for (Integer i=0; i<numLines; i++){
            system.debug(lines[i]);
        }
    }
}