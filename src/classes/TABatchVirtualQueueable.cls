public virtual without sharing class TABatchVirtualQueueable implements Queueable {
	final String CLASSNAME = '\n\n**** TABatchVirtualQueueable.METHODNAME()';
	protected Map<Id,AccountWrapper> accountWrapperMap;
	protected List<Id> objectIdList; //The complete list of child object records to process
	protected List<Id> subObjectIdList; // The list of child object records for a given queueable
    protected String customMetadataString;
	protected Integer offSet;
	protected Integer recordCountToProcess;
	protected String TA_RunID;
	private   Map<Id,Id> oldAccountOwnerMap;
	protected String Queue_Thread;
	protected TABatchConfiguration configObject;
	/*protected Boolean Set_TA_Team_Member_flag_on_Existing_ATM;
	protected Boolean Set_TA_Team_Member_flag_on_Existing_OTM;*/

	public void execute(QueueableContext context) {
		final string METHODNAME = CLASSNAME.replace('METHODNAME','execute');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //Order of operations:
        //1. perform any before logic (querying for records etc)
        //2. fire the main logic
        //3. do any final logic, updating queueuable log etc

        //1.
        updateQueueableLogBegin(context.getJobId());
        executeBeforeLogic();

		//2.
		executeMainLogic();

		//3.
		executeAfterLogic();
		updateQueueableLogEnd(context.getJobId());

	}

	public Id enqueueTA(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','enqueueTA');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		//Jeff L added for test class debugging:
		System.debug('getQueueableJobs()? ' + Limits.getQueueableJobs());
		System.debug('getLimitQueueableJobs()? ' + Limits.getLimitQueueableJobs());

		Id jobId = System.enqueueJob(this);
		insertNewQueueableLog(jobId);
		return jobId;
	}

	//constructor
	protected TABatchVirtualQueueable(List<Account> pAccountList, Map<Id,Id> pOldAccountOwnerMap, List<Id> pObjectIdList, Integer pOffSet, String pCustomMetadataString, String pObjectName){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','constructor');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		oldAccountOwnerMap = pOldAccountOwnerMap;
        processAccountList(pAccountList);
        objectIdList = pObjectIdList;
        offSet = pOffSet;
        customMetadataString = pcustomMetadataString;

        getRecordCountToProcess();
        subObjectIdList = generateSubObjectList();

        TABatchConfiguration newConfig = new TABatchConfiguration(accountWrapperMap, objectIdList, customMetadataString, offSet, recordCountToProcess, pObjectName, TA_RunID);
        configObject = newConfig;
        /*Set_TA_Team_Member_flag_on_Existing_ATM = getSetFlagIfExists('ATM');
        Set_TA_Team_Member_flag_on_Existing_OTM = getSetFlagIfExists('OTM');
        system.debug('Set_TA_Team_Member_flag_on_Existing_ATM='+Set_TA_Team_Member_flag_on_Existing_ATM+', Set_TA_Team_Member_flag_on_Existing_OTM='+Set_TA_Team_Member_flag_on_Existing_OTM);*/
    }

    //this constructor will get used inside of the queueables themselves, configuration object makes the constructor a lot neater
    protected TABatchVirtualQueueable(TABatchConfiguration pConfigObject){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','constructor3');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		parseConfigObject(pConfigObject);
    }

    protected TABatchVirtualQueueable(){
    	final string METHODNAME = CLASSNAME.replace('METHODNAME','constructor with 0 args');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    	//empty 0 argument constructor
    }

    private void parseConfigObject(TABatchConfiguration pConfigObject){
    	configObject = pConfigObject;
    	accountWrapperMap = configObject.accountWrapperMap;
    	TA_RunID = configObject.TA_RunID;
    	Queue_Thread = configObject.Queue_Thread;
    	objectIdList = configObject.objectIdList;

    	offSet = configObject.offSet;
    	customMetadataString = configObject.customMetadataString;
    	if(configObject.recordCountToProcess == null){
    		getRecordCountToProcess();
    	} else {
    		recordCountToProcess = configObject.recordCountToProcess;
    	}

    	subObjectIdList = generateSubObjectList();
    	system.debug('^^^ Inside parseConfigObject: Queue_Thread=' + Queue_Thread + ', TA_RunID=' + TA_RunID + ', offset=' + offset + ', customMetadataString=' + customMetadataString + ', recordCountToProcess=' + recordCountToProcess+ ', objectName=' + configObject.objectName);

        /*Set_TA_Team_Member_flag_on_Existing_ATM = getSetFlagIfExists('ATM');
        Set_TA_Team_Member_flag_on_Existing_OTM = getSetFlagIfExists('OTM');
        system.debug('Set_TA_Team_Member_flag_on_Existing_ATM='+Set_TA_Team_Member_flag_on_Existing_ATM+', Set_TA_Team_Member_flag_on_Existing_OTM='+Set_TA_Team_Member_flag_on_Existing_OTM);*/
    }

    private void getRecordCountToProcess() {
    	final string METHODNAME = CLASSNAME.replace('METHODNAME','getRecordCountToProcess');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    	if(recordCountToProcess == null){
        	if(String.isNotBlank(customMetadataString)){
            	TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();
            	recordCountToProcess = ((Decimal)batchSetting.get(customMetadataString)).intValue(); //need to round since it's a decimal
	        } else {
	            //default value
	            recordCountToProcess = 100;
	        }
    	}
    	system.debug('^^^recordCountToProcess='+recordCountToProcess);
    }
    /*private Boolean getSetFlagIfExists(String obj) {
    	final string METHODNAME = CLASSNAME.replace('METHODNAME','getSetFlagIfExists');
    	system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    	String field = 'Set_TA_Team_Member_flag_on_Existing_' + obj + '__c';
        TA_Records_per_Queueable__mdt batchSetting = getCustomMetadata();
        Boolean retval = boolean.valueOf(batchSetting.get(field));
        return retval;
    }*/

	private boolean isFirst(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','isFirst');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		return offSet == 0;
	}

	private boolean isLast(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','isLast');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		return (offSet + recordCountToProcess >= objectIdList.size());
	}

	//JFreese Appirio S-435483 4/6/17 add Debug_Mode__c & Bypass_Validation_Rules__c
	public TA_Records_per_Queueable__mdt getCustomMetadata(){
	 	TA_Records_per_Queueable__mdt returnSetting =
            [Select DeveloperName,
               /*AccountTeamMember__c,*/
               Activity__c, Contact__c, Opportunity__c,
               /*OpportunityTeamMember__c,*/
               Proposal__c,
               /*Set_TA_Team_Member_flag_on_Existing_ATM__c, Set_TA_Team_Member_flag_on_Existing_OTM__c,*/
               Debug_Mode__c, Bypass_Validation_Rules__c
               from TA_Records_per_Queueable__mdt
               where DeveloperName='Master' Limit 1];

 	    return returnSetting;
	}

	//this is the method that will log when the queueable has completed
	protected void updateQueueableLogEnd(Id pAsyncApexId){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','updateQueueableLogEnd');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		set_Status_Values(pAsyncApexId, 'end');

		/*String Job_ID = String.valueOf(pAsyncApexId);

		TA_Queueable_Tracker__c thisTracker =
			[SELECT ID, Status__c, Queue_ID__c from TA_Queueable_Tracker__c WHERE Job_ID__c =: Job_ID LIMIT 1 ];

		if(thisTracker.Id != null){
			thisTracker.Status__c = 'Finished';

			System.Debug('Preparing to Finish tracker ID=' + thistracker.Id + ', Queue_ID__c=' + thisTracker.Queue_ID__c + ', Status__c=' + thisTracker.Status__c);

	        try{
		        update thisTracker;
	        }catch(DMLException e){
	            throw BaseApplicationException.NewException(METHODNAME, e.getmessage(), 'Failed to update TA Queueable Tracker record to Finished.');
	        }
	    }*/
	}

	//this method will log when the queuable has started
	protected void updateQueueableLogBegin(Id pAsyncApexId){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','updateQueueableLogBegin');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		set_Status_Values(pAsyncApexId, 'begin');

		/*String Job_ID = String.valueOf(pAsyncApexId);

		system.debug('Whats my Job_Id? ' + Job_ID);
		TA_Queueable_Tracker__c thisTracker;

		//if this is a test Job_Id__c is set to null (due to the way test.startTest and test.stopTest work with queueables)
		if(Test.isRunningTest()){
			thisTracker =
				[SELECT ID, Status__c, Queue_ID__c from TA_Queueable_Tracker__c WHERE Job_ID__c = null LIMIT 1];

		} else {
			thisTracker =
				[SELECT ID, Status__c, Queue_ID__c from TA_Queueable_Tracker__c WHERE Job_ID__c =: Job_ID LIMIT 1 ];
		}



		if(thisTracker.Id != null){
			thisTracker.Status__c = 'Started';

			System.Debug('Preparing to Start tracker ID=' + thistracker.Id + ', Queue_ID__c=' + thisTracker.Queue_ID__c + ', Status__c=' + thisTracker.Status__c);

			configObject.Queue_Id = thisTracker.Queue_Id__c;

			if(configObject.Queue_Thread == null && isFirst()){
				Queue_Thread = String.valueOf(thisTracker.Queue_ID__c);
				Queue_Thread = 'QT' + Queue_Thread.mid(1,Queue_Thread.length() - 1);
				configObject.Queue_Thread = Queue_Thread;

		        //set the list of Account IDs being processed
		        Set<Id> AcctIds = new Set<Id>();
		        for(Id accountId : accountWrapperMap.keySet()){
		        	AcctIds.add(accountId);
				}
		        String AccountList = stringifySet(AcctIds);
				thisTracker.Account_List__c = AccountList;
			}
			system.debug('After Setting Queue_Thread=' + Queue_Thread + ', configObject.Queue_Thread=' + configObject.Queue_Thread + ', isFirst()=' + isFirst() + ', configObject.Queue_Id=' + configObject.Queue_Id);

			thisTracker.Queue_Thread__c = configObject.Queue_Thread;

			//see comment above, if this is a test we need to set this value as well due to the way queueables are handled
			if(Test.isRunningTest()){
				thisTracker.Job_Id__c = Job_ID;
			}

	        try{
		        update thisTracker;
	        }catch(DMLException e){
	            throw BaseApplicationException.NewException(METHODNAME, e.getmessage(), 'Failed to update TA Queueable Tracker record to Started.');
	        }
	    }*/
	}

	//this method will insert the next queueableId into our log
	protected void insertNewQueueableLog(Id pAsyncApexId){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','insertNewQueueableLog');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		String Child_Object = customMetadataString;
		if (String.isNotBlank(Child_Object)){
			Child_Object = Child_Object.left(Child_Object.length() - 3); //drop the __c
		}


		TA_Queueable_Tracker__c newTracker = new TA_Queueable_Tracker__c();
		newTracker.Job_ID__c = pAsyncApexId;
		newTracker.Status__c = 'Queued';
		newTracker.TA_RunID__c = TA_RunID;
		newTracker.Maximum_Record_Count__c = recordCountToProcess;
		newTracker.Child_Object__c = configObject.objectName;
		newTracker.Batch_Size__c = objectIdList.size();

        system.debug('newTracker: ' + newTracker);

        try{
	        insert newTracker;
        }catch(DMLException e){
            throw BaseApplicationException.NewException(METHODNAME, e.getmessage(), 'Failed to insert new TA Queueable Tracker record.');
        }

        TA_Queueable_Tracker__c thisTracker =
	        [SELECT ID, Queue_ID__c, Batch_Size__c, Job_ID__c from TA_Queueable_Tracker__c WHERE Job_ID__c =: pAsyncApexId LIMIT 1 ];
	    System.debug('^^^ New Tracker ID = ' + thisTracker.Id + ', Queue_ID__c=' + thisTracker.Queue_ID__c + ', Batch_Size__c = '+ thisTracker.Batch_Size__c + ', Job_ID__c = ' + thisTracker.Job_ID__c);
	}

	//This method will be called by either the Queueable Begin or End methods and will set the status values
	protected void set_Status_Values(Id pAsyncApexId, String calledBy){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','set_Status_Values');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		String Job_ID = String.valueOf(pAsyncApexId);
		system.debug('Job_Id=' + Job_ID);

		String QueryStr = 'SELECT ID, Job_ID__c, Queue_ID__c, Queue_Thread__c, QT_Status__c, ' +
		                  'TA_RunID__c, TA_Run_Status__c FROM TA_Queueable_Tracker__c';

		if(calledBy == 'begin' && Test.isRunningTest()){
		    QueryStr += ' WHERE Job_ID__c = null LIMIT 1';
		}else{
		    QueryStr += ' WHERE Job_ID__c = ' + '\'' + Job_ID + '\'';

			if(configObject.TA_RunID != null){
				QueryStr += ' OR TA_RunID__c = ' + '\'' + configObject.TA_RunID + '\'';
			}else {
				QueryStr += ' OR Queue_Thread__c = ' + '\'' + configObject.Queue_Thread + '\'';
			}
		}
		system.debug('QueryStr=' + QueryStr);

		List<TA_Queueable_Tracker__c> QT = Database.query(QueryStr);

		//First, set the status value for the current enqueueable record and set Queue Thread
		for(TA_Queueable_Tracker__c currTracker : QT){
			if (currTracker.Job_ID__c == Job_ID){ //this is the current enqueueable record
				if(calledBy == 'begin'){
					currTracker.Status__c = 'Started';
					currTracker.QT_Status__c = 'In Progress';
					if (configObject.TA_RunID != null){
						currTracker.TA_Run_Status__c = 'In Progress';
					}

					System.Debug('Preparing to Start tracker ID=' + currtracker.Id + ', Queue_ID__c=' + currTracker.Queue_ID__c + ', Status__c=' + currTracker.Status__c);

					configObject.Queue_Id = currTracker.Queue_Id__c;

					if(configObject.Queue_Thread == null && isFirst()){
						Queue_Thread = String.valueOf(currTracker.Queue_ID__c);
						Queue_Thread = 'QT' + Queue_Thread.mid(1,Queue_Thread.length() - 1);
						configObject.Queue_Thread = Queue_Thread;

				        //set the list of Account IDs being processed
				        Set<Id> AcctIds = new Set<Id>();
				        for(Id accountId : accountWrapperMap.keySet()){
				        	AcctIds.add(accountId);
						}
				        String AccountList = stringifySet(AcctIds);
						currTracker.Account_List__c = AccountList;
					}
					system.debug('After Setting Queue_Thread=' + Queue_Thread + ', configObject.Queue_Thread=' + configObject.Queue_Thread + ', isFirst()=' + isFirst() + ', configObject.Queue_Id=' + configObject.Queue_Id);

					currTracker.Queue_Thread__c = configObject.Queue_Thread;
				}else if(calledBy == 'end'){
					currTracker.Status__c = 'Finished';
					System.Debug('Preparing to Finish tracker ID=' + currtracker.Id + ', Queue_ID__c=' + currTracker.Queue_ID__c + ', Status__c=' + currTracker.Status__c);
				}

		        try{
			        update currTracker;
			    }catch(DMLException e){
		    	    throw BaseApplicationException.NewException(METHODNAME, e.getmessage(), 'Failed to update TA Queueable Tracker record.');
		    	}
			}
		}

		//If this is the last queueable in this thread, set QT Status to Finished
		//If they provided a TA_RunID, evaluate and update the TA Run Status
		List<TA_Queueable_Tracker__c> QT_toUpdate = new List<TA_Queueable_Tracker__c>();
		Boolean Got_Other_Queue_Thread_s = false;
		Boolean All_Other_QT_Status_Finished = true;
		Boolean Some_Other_TA_Run_Status_Finished = false;
		Set<String>  Other_TA_Run_Status_Finished  = new Set<String>();
		Set<String> Other_QT_Threads_In_Progress = new Set<String>();
		Boolean OK_to_set_TA_Run_Status_to_Finished = false;
		Boolean Need_to_set_TA_Run_Status_back_to_In_Progress = false;
		String beginMsg = '';
		String endMsg = ''; //Summary which only gets written at the end of the last Event queueuable
		Boolean LastCall = false;
		if(calledBy == 'end' && configObject.objectName == 'Event' && isLast()){LastCall = true;}

		if (configObject.TA_RunID == null){
			beginMsg = 'The user did not provide a TA_RunID, so TA_Run_Status will not be considered or populated';
			endMsg = beginMsg;
		}else{
			for(TA_Queueable_Tracker__c thisTracker : QT){
				if(thisTracker.Queue_Thread__c != null && thisTracker.Queue_Thread__c != configObject.Queue_Thread){
					Got_Other_Queue_Thread_s = true;

					if(thisTracker.TA_Run_Status__c == 'Finished') {
						Some_Other_TA_Run_Status_Finished = true;
						Other_TA_Run_Status_Finished.add(thisTracker.Queue_Thread__c);
					}
					if(thisTracker.QT_Status__c == null || thisTracker.QT_Status__c == 'In Progress'){
						//THIS ASSUMES THAT THE ONLY QT_Status__c VALUES ARE 'In Progress' OR 'Finished'
						//We have to do it this way because other QT records initially have a null QT_Status__c
						All_Other_QT_Status_Finished = false;
						Other_QT_Threads_In_Progress.add(thisTracker.Queue_Thread__c);
					}
				}
			}

			if(Got_Other_Queue_Thread_s){
				if (Some_Other_TA_Run_Status_Finished){
					if (All_Other_QT_Status_Finished){
						endMsg = '!!! The other Queue Threads in the TA_Run are Finished.' +
						      ' This implies that the current Queue_Thread ' + configObject.Queue_Thread +
						      ' started after all other threads in the TA_Run had finished.';
						if (LastCall){
							endMsg += ' This is OK - we\'ll set this thread to Finished too.';
						}else{
							endMsg += ' This is OK - when we get to the end of the thread we\'ll set this one to Finished too.';
						}
						OK_to_set_TA_Run_Status_to_Finished = true;
					}else{
						beginMsg = '!!! The QT Thread(s) shown below have TA_Run_Status == Finished, BUT' +
						      ' there are other Queue Thread(s) which are NOT Finished.' +
						      ' This implies that two or more threads (including the current one ' + configObject.Queue_Thread + ')' +
					          ' started after other threads in the TA_Run had finished.' +
					          ' This will be fixed by setting ALL Finished threads in the TA_Run back to In Progress.\n' +
					          ' The other Queue Thread(s) which are NOT Finished include: ' + Other_QT_Threads_In_Progress + '\n' +
					          ' The Finished Queue Thread(s) which will be set back to In Progress include: ' + Other_TA_Run_Status_Finished;
					    Need_to_set_TA_Run_Status_back_to_In_Progress = true;
					}
				}else if (All_Other_QT_Status_Finished){
					endMsg = ' All other QT Threads in the TA_Run have QT_Status__c == Finished.' +
					         ' This implies that the current Queue_Thread ' + configObject.Queue_Thread +
					         ' is the last one to finish,';
					if (LastCall){
						endMsg += ' so we\'ll set TA_Run_Status to Finished for this and other Queue Threads';
					}else{
						endMsg += ' so when we get to the end of the thread, we\'ll set TA_Run_Status to Finished for this and other Queue Threads.';
					}
					OK_to_set_TA_Run_Status_to_Finished = true;
				}else{
					endMsg = 'There are other Queue Thread(s) in the TA_Run which are not Finished,' +
					         ' so TA_Run_Status will not be set to Finished.\n' +
						     ' NOTE that if the TA_RunID provided is NOT unique, ' +
						     ' earlier runs which used it will be grouped with this one.\n' +
					         ' The other Queue Thread(s) which are NOT Finished include: ' + Other_QT_Threads_In_Progress + '\n';
				}
			}else{
				beginMsg = 'This appears to be the only QT Thread in the TA_Run at this time.\n' +
						   ' If this is still the case when this thread is completed, ' +
						   ' we\'ll set its TA_Run_Status to Finished.';
				if(!LastCall){
					endMsg = beginMsg;
				}else{
					endMsg = 'This is the only QT Thread in the TA_Run.\n' +
							 ' This thread is completed, so we\'ll set its TA_Run_Status to Finished';
					OK_to_set_TA_Run_Status_to_Finished = true;
				}
			}
		}

		System.debug('Flag summary: calledBy=' + calledBy + ', object=' + configObject.objectName +
			         ', LastCall=' +  LastCall +
			         ',\nGot_Other_Queue_Thread_s=' + Got_Other_Queue_Thread_s +
			         ', All_Other_QT_Status_Finished=' + All_Other_QT_Status_Finished +
			         ', Some_Other_TA_Run_Status_Finished=' + Some_Other_TA_Run_Status_Finished +
			         ',\nOK_to_set_TA_Run_Status_to_Finished=' +OK_to_set_TA_Run_Status_to_Finished +
			         ', Need_to_set_TA_Run_Status_back_to_In_Progress=' + Need_to_set_TA_Run_Status_back_to_In_Progress);

		if (calledBy == 'begin' && beginMsg != null){System.debug(beginMsg);}
		else if (calledBy == 'end' && endMsg != null){System.debug(endMsg);}

		for(TA_Queueable_Tracker__c updateQT : QT){
			if(calledBy == 'begin' && Need_to_set_TA_Run_Status_back_to_In_Progress){
				if(updateQT.TA_Run_Status__c == 'Finished'){
					updateQT.TA_Run_Status__c = 'In Progress';
					QT_toUpdate.add(updateQT);
				}
			}else if(LastCall){
				if (updateQT.Queue_Thread__c == configObject.Queue_Thread){
					updateQT.QT_Status__c = 'Finished'; //ALLWAYS set the current thread status to Finished
					if(OK_to_set_TA_Run_Status_to_Finished){
						updateQT.TA_Run_Status__c = 'Finished';
					}
					QT_toUpdate.add(updateQT);
				}else if (OK_to_set_TA_Run_Status_to_Finished){
						updateQT.TA_Run_Status__c = 'Finished';
						QT_toUpdate.add(updateQT);
				}
			}
		}
		if(QT_toUpdate.size() > 0){
			System.Debug('Updating ' + QT_toUpdate.size() + ' records.');
		    try{
		        update QT_toUpdate;
		    }catch(DMLException e){
		        throw BaseApplicationException.NewException(METHODNAME, e.getmessage(), 'Failed to update TA Queueable Tracker records to set QT_Status/TA_Run_Status to Finished.');
		    }
		}
	}

	private void processAccountList(List<Account> pAccountList){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','processAccountList');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		accountWrapperMap = new Map<Id,AccountWrapper>();
		for(Account a : pAccountList){
			AccountWrapper aw = new AccountWrapper(a,oldAccountOwnerMap);
			accountWrapperMap.put(a.Id,aw);
        	if(TA_RunID == null){
				TA_RunID = accountWrapperMap.get(a.Id).runID;
			}
		}
		system.debug('^^^Processed '+pAccountList.size()+' accounts');
	}

	private List<Id> generateSubObjectList(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','generateSubObjectList');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
		List<Id> returnList = new List<Id>();
		Integer startIndex = offSet;
		Integer endIndex;


		if(isLast()){
			endIndex = objectIdList.size();
		} else {
			endIndex = offSet + recordCountToProcess;
		}

		for(Integer i=startIndex;i<endIndex;i++){
			returnList.add(objectIdList[i]);
		}
		system.debug('^^^SubObjectList.size()='+returnList.size());
		return returnList;
	}

	protected void handleSaveErrors(List<Database.SaveResult> pSaveResultList, List<Id> saveIds){
		List<ExceptionLog__c> exceptionList = new List<ExceptionLog__c>();
		Integer errCt = 0;
		for(Integer i=0;i<pSaveResultList.size();i++){
			Database.SaveResult sr = pSaveResultList[i];
			//we don't care if its succesful, only if it failed
			//Debugging code:
			/*ExceptionLog__c ex = ExceptionLog.addTAException('JonathanTest','Jonathan',subObjectIdList[i],'did the exception get logged?',configObject.Queue_Id, configObject.TA_RunID);
			exceptionList.add(ex);*/
			if(!sr.isSuccess()){
				/*JFreese Appirio S-435483 4/6/17 Discovered that the indexing in the Database.SaveResult can be out of synch
				  with the subObjectIdList, resulting in ExceptionLog entries with the wrong recordId.
				  This is because objectIdList (and its subset subObjectIdList) is derived from a query based on the account list.
				  But the list of records to save is derived from a new query based on subObjectIdList.
				  An ID which happens to be at the start of the objectIdList (a list of child Ids for each account)
				  can end up being at the end of the records to save (they come out sorted on Id) which means that subObjectIdList
				  can be out of synch with Database.SaveResult.  So build a list of Ids to save and pass it in.*/
				//Id recordId = subObjectIdList[i];
				Id recordId = saveIds[i];
				for(Database.Error err : sr.getErrors()){
					exceptionList.add(logSaveError(err,recordId));
				}
				errCt++;
			}
		}
		system.debug('^^^SaveResult: '+errCt+' errors were encountered in saving '+saveIds.size()+' records');
		ExceptionLog.addTAExceptionBulk(exceptionList);
	}

	private ExceptionLog__c logSaveError(Database.Error pError, Id pRecordId){
		return ExceptionLog.addTAException(
			'DML Update Exception', configObject.objectName,
			 pRecordId, pError.getMessage() + ' \n' + pError.getFields(),
			 configObject.Queue_Id, configObject.TA_RunID);
	}

	protected void handleDeleteErrors(List<Database.DeleteResult> pDeleteResultList, List<Id> deleteIds){
		List<ExceptionLog__c> exceptionList = new List<ExceptionLog__c>();
		Integer errCt = 0;
		for(Integer i=0;i<pDeleteResultList.size();i++){
			Database.DeleteResult dr = pDeleteResultList[i];
			if(!dr.isSuccess()){
				//Id recordId = subObjectIdList[i];
				Id recordId = deleteIds[i];
				for(Database.Error err : dr.getErrors()){
					system.debug('^^^Delete error recordId = '+recordId+', error: '+err);
					exceptionList.add(logDeleteError(err,recordId));
				}
				errCt++;
			}
		}
		system.debug('^^^DeleteResult: '+errCt+' errors were encountered in deleting '+deleteIds.size()+' records');
		ExceptionLog.addTAExceptionBulk(exceptionList);
	}

	private ExceptionLog__c logDeleteError(Database.Error pError, Id pRecordId){
		return ExceptionLog.addTAException(
			'DML Delete Exception', configObject.objectName,
			 pRecordId, pError.getMessage() + ' \n' + pError.getFields(),
			 configObject.Queue_Id, configObject.TA_RunID);
	}

	private String stringifySet(Set<Id> idSet){
		String returnString;
		returnString = '';
		for(Id i : idSet){
			returnString += '\'' + i + '\',';
		}
		//cut off last comma
		returnString = returnString.left(returnString.length() -1 );

		return returnString;
	}

	//Stub
	virtual protected void executeBeforeLogic(){

	}

	//stub
	virtual protected void executeMainLogic(){

	}

	//stub
	virtual protected void executeNextQueueable(){

	}

	//stub
	virtual protected void executeLastLogic(){

	}

	//stub
	private void executeAfterLogic(){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','executeAfterLogic');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		if(!isLast()){
			executeNextQueueable();
		} else {
			executeLastLogic();
		}

	}

	protected String Queue_Id{
		get{
			if(configObject != null){
				return configObject.Queue_ID;
			} else {
				return null;
			}
		}

	}

	public Class AccountWrapper{
		final String CLASSNAME = '\n\n**** AccountWrapper.METHODNAME()';
		public Id accountId;
		public String organization;
		public Id newOwnerId;
		public String runID;
		public Id oldOwnerId;

		AccountWrapper(Account a, Map<Id,Id> oldAccountMap){
			final string METHODNAME = CLASSNAME.replace('METHODNAME','constructor');
			//system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
			accountId = a.Id;
			organization = a.Organization__c;
			newOwnerId = a.OwnerId;
			oldOwnerId = oldAccountMap.get(a.Id);
			runID = a.TA_RunID__c;
		}
	}

	public Class TABatchConfiguration{
		public Map<Id,AccountWrapper> accountWrapperMap;
		public List<Id> objectIdList; //The complete list of child object records to process
	    public String customMetadataString;
	    public String objectName;
		public Integer offSet;
		public Integer recordCountToProcess;
		public String TA_RunID;
		public String Queue_Thread;
		public String Queue_Id;

		public TABatchConfiguration(){
			// 0 argument constructor
		}

		public TABatchConfiguration(Map<Id,AccountWrapper> pAccountWrapperMap, List<Id> pObjectIdList, String pCustomMetadataString, Integer pOffSet, Integer pRecordCountToProcess, String pObjectName, String pTA_RunID){
			accountWrapperMap = pAccountWrapperMap;
			objectIdList = pObjectIdList;
			customMetadataString = pCustomMetadataString;
			offSet = pOffSet;
			recordCountToProcess = pRecordCountToProcess;
			objectName = pObjectName;
			TA_RunID = pTA_RunID;
		}

		//small method to make a clone that copies the values that are needed to be
		//kept within a thread
		public TABatchConfiguration cloneForNextBatch(){
			TABatchConfiguration tab =  new TABatchConfiguration();
			tab.accountWrapperMap = this.accountWrapperMap;
			tab.TA_RunID = this.TA_RunID;
			tab.Queue_Thread = this.Queue_Thread;
			tab.offSet = 0;

	    	system.debug('^^^ Inside cloneForNextBatch: Queue_Thread=' + Queue_Thread + ', TA_RunID=' + TA_RunID + ', offset=' + offset + ', customMetadataString=' + customMetadataString + ', recordCountToProcess=' + recordCountToProcess + ', objectName=' + objectName);
	    	system.debug('^^^ Inside cloneForNextBatch: tab Queue_Thread=' + tab.Queue_Thread + ', TA_RunID=' + tab.TA_RunID + ', offset=' + tab.offset + ', customMetadataString=' + tab.customMetadataString + ', recordCountToProcess=' + tab.recordCountToProcess+ ', objectName=' + tab.objectName);

			return tab;
		}

	}
}