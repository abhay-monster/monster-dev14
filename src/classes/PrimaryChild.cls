/**
 * @description contains all primary object implementation
 * @author B. Espiridion
 * @Story 0085
 * @Element E1711
 * @date 22.JULY.2013
*/
abstract public with sharing class PrimaryChild {
    //flag that will make sure that setting of household will not enter into an infinite loop when updating
    private static Boolean run = false;
    protected String CLASSNAME = '\n\n**** PrimeChild.METHODNAME()';
    private static String CLASSNAME = '\n\n**** PrimeChild.METHODNAME()';
/**
 * @description constructor will log the first execution of this class
 * @author B. Espiridion
 * @date 18.JULY.2013
 * @returns Nothing
 */
    public PrimaryChild(String calledFrom){


        String METHODNAME = CLASSNAME.replace('METHODNAME', 'PrimeChild');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nInside constructor called from ' + calledFrom + '\n\n');
    }


    public class PrimaryChildConfig{
        public String ParentType;
        public String ParentRecordTypes {get{return ParentRecordTypes == null ? '' : ParentRecordTypes;} set;} //comma separated
        public String ParentFieldsToUpdate {get{return ParentFieldsToUpdate == null ? '' : ParentFieldsToUpdate;} set;} //comma separated string of parent field that can be referenced in the houskeeping method


        public String ChildType;
        public String ParentLookupField;
        public String ChildPrimaryField;
        public String ChildFieldsToUpdate {get{return ChildFieldsToUpdate == null ? '' : ChildFieldsToUpdate;} set;}  //comma separated


        public list<SObject> ChildObjectList;
    }
 /**
 * @description
    -Sets the child record of a parent record as prime record for that specific
     record when the child is currently the first child of its parent
    -Removes the previous prime child when setting a new prime child
    -sets necessary field updates or the like based on the functionality provided in housekeeping() method
     for the parent and the current child record
    -Can adds a field error when a specified criteria is provided in the noError() method
 * @author B. Espiridion
 * @param objParent is the API name of the parent object (e.g. Account, My_Object__c)
 * @param parentRecTypes is a comma separated string of the parent record type (e.g. Household, Provider, Competitor)
 * @param parentField is the API name of the parent object in child object (e.g. AccountId, My_ParentObj__c)
 * @param parentUpdatedFields is a comma separated string of the fields will be modified in housekeeping() method


 * @param objChild is the API name of the child record (e.g. Contact, My_Child_Obj__c)
 * @param primaryField is the name of the checkbox field in the child object that will act as the identifier when
    the child object is set as the prime child (e.g. Primary_Household__c, SSA__c)
 * @param childUpdateFields is a comma separated string of child fields that will be modified in the hosekeeping() method
 * @param list of childs that will be modified (e.g. Trigger.new, Trigger.old)
 * @date 22.JULY.2013
 * @returns Nothing
 */

    public void setPrimaryChildObj(PrimaryChildConfig pConfig){
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'setPrimaryChildObj');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');


        String objParent = pConfig.ParentType;
        String parentRecTypes = pConfig.ParentRecordTypes;
        String parentField = pConfig.ParentLookupField;
        String parentUpdateFields = pConfig.ParentFieldsToUpdate;
        String objChild = pConfig.ChildType;
        String primaryField = pConfig.ChildPrimaryField;
        String childUpdateFields = pConfig.ChildFieldsToUpdate;
        List<SObject> childList = pConfig.ChildObjectList;


        String[] parentRecordTypes = parentRecTypes.split(',');
        //prevents infinite loop of this trigger
        if(!run){
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nCHILD LIST HAS :: ' + childList.size() + 'objects to check.\n\n');
            run = true; //for infinit loop prevention
            SObject[] parents;
            Map<Id, SObject> childrenToUpdate;

                //Commented by -- Prashant Gupta (Appirio) for S-455154
                //The try catch surrounding this functionality has been commented out to ensure that any error generated on account Update get
                //reported to the user while creating new XCode. Refer chatters and screencast on The story.
                //try{
                //End
                //extract parent object
                String parentIds = '(';
                //sets the map that has a Child object id as the key and the child object as the value
                Map<Id, SObject> parentToChildMap = new Map<Id, SObject>();
                for(SObject child : childList){
                    if(child.get(parentField) != null){
                        parentIds += '\'' + child.get(parentField) + '\',';
                        parentToChildMap.put((Id)child.get('Id'), child);
                    }
                }
                parentIds = parentIds.removeEnd(','); //removes the extra comma at the end of the generated parent ids
                parentIds += ')'; //add the closing parenthesis to complete the clause


                if(parentIds == '()'){ //the init value + the last value will be generated if theres no parent record
                    //this will prevent the execution of unnecessary codes when the contact being updated has no parent contact
                    //i.e. the contact's account name field is null
                    system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nSTOPS :: There are no  ' + objChild + 'that has a parent '+ objChild +'\n\n');
                    return;
                }


                //prepares the account's address fields that will be used for primary household implementation
                parentUpdateFields = parentUpdateFields != '' && parentUpdateFields != null ? parentUpdateFields+',' : '';


                //builds up the query for parents
                String pQuery = 'SELECT ' +parentUpdateFields+ ' Id ' +
                                ' FROM ' + objParent +

                                ' WHERE Id IN ' + parentIds;


                //builds record type for parent objects
                String pTypes = ' AND RecordTypeId IN (';
                for(String rt : parentRecordTypes){
                    Id rtId = Utility.GetRecordTypeIdBySObjectNameAndType(objParent, rt);
                    if(rtId == null){
                        continue;
                    }
                    pTypes += '\'' + rtId + '\',';
                }
                pTypes = pTypes.removeEnd(',');
                pTypes += ')';


                //adds the recordtype condition to the parent query if there's a valid record type
                pQuery += (pTypes != ' AND RecordTypeId IN ()') ? pTypes : '';


                //actual parents query excecution
                parents = Database.query(pQuery);


                //prepares the contact's address fields that will be used for primary household implementation
                childUpdateFields = childUpdateFields != '' && childUpdateFields != null ? childUpdateFields+',' : '';


                //actual child extraction based on the parent Ids
                SObject[] children = Database.query('SELECT Id, ' + childUpdateFields + primaryField + ', ' + parentField +
                                                    ' FROM ' + objChild +

                                                    ' WHERE ' + parentField + ' IN ' + parentIds);


                //prepare all child(List/value) based on their parent id(Id/key)
                //e.g. Key is the Account Id and value is a list of all contacts in that Account
                Map<Id, List<SObject>> childrenMap = new Map<Id, List<SObject>>();
                for(SObject child : children){
                    if(!childrenMap.containsKey((id)child.get(parentField))){
                        childrenMap.put((Id)child.get(parentField), new List<SObject>());
                    }
                    childrenMap.get((Id)child.get(parentField)).add(child);
                }


                childrenToUpdate = new Map<Id, SObject>();

               /*  Commented due to extra loop used in logic
                 for(SObject p : parents){
                    Id pId = (Id)p.get('Id');
                    if(childrenMap.containsKey(pId)){
                        //a parent obj has/have child/children being updated/created
                        List<SObject> cs = childrenMap.get(pId); //get all child object
                        for(SObject c : cs){
                            if(cs.size() == 1){//if the parent obj has only one child that child will be set as its prime child
                                cs[0].put(primaryField, true); //the setting of the primary field (e.g. Primary_Contact__c, SSA__c)
                                //noError check if there are no error based on the parent and child fields
                                //an error will be presented if there's an error
                                //this method is overridable in every sublass ro customize the functionality
                                noError(p, cs[0], parentToChildMap.get((Id)cs[0].get('Id')), true);
                                //house keeping will ensure any relevant steps or field setting after the prime child is selected
                                //this method is overridable in every sublass ro customize the functionality
                                housekeeping(p, cs[0]);
                                //addObj will check if the child is alredy added for UPDATE if not it will be added
                                addObj(childrenToUpdate,cs[0]);
                            }else if(cs.size() > 1){ //for multiple children
                                SObject prevPrime; //will be populated if theres an exisitng prime child prioir to the current prime child
                                String valid = 'N/A'; //prevent the excecution failure when the prevChild is also the current prime child
                                for(SObject ci : cs){ //loops all the child of a specific parent obj
                                    Id ciId = (Id)ci.get('Id');
                                    if(parentToChildMap.containsKey(ciId)){
                                        //if the current child in the current loop iteration is a prime child
                                        Boolean childIsPrime = (Boolean)parentToChildMap.get(ciId).get(primaryField);
                                        if(childIsPrime){
                                            //house keeping will ensure any relevant steps or field setting after the prime child is selected
                                            //this method is overridable in every sublass ro customize the functionality
                                            housekeeping(p, ci);
                                            //addObj will check if the child is alredy added for UPDATE if not it will be added
                                            addObj(childrenToUpdate,ci);
                                            //noError check if there are no error based on the parent and child fields
                                            //an error will be presented if there's an error
                                            //this method is overridable in every sublass ro customize the functionality
                                            noError(p, ci, parentToChildMap.get(ciId), false);
                                            //flags the prev prime as not the current prime child
                                            valid = 'Yes';
                                        }else{
                                            //flags the prev prime as the current prime child
                                            valid = 'No';
                                        }
                                    }else if((Boolean)ci.get(primaryField) && !parentToChildMap.containsKey(ciId)){
                                        //extract the previous prime child (Note: prev prime child could be the current prime child)
                                        prevPrime = ci;
                                    }
                                }
                                if(valid == 'Yes' && prevPrime != null){
                                    //check if the preve prime child is not the current prime child,
                                    //set the prev prime child us not prime child
                                    prevPrime.put(primaryField, false);
                                    //and will set the prev prime child for update
                                    addObj(childrenToUpdate,prevPrime);
                                }
                            }
                        }
                    }
                }

                */

                for(SObject p : parents){
                    Id pId = (Id)p.get('Id');
                    if(childrenMap.containsKey(pId)){
                        //a parent obj has/have child/children being updated/created
                        List<SObject> cs = childrenMap.get(pId); //get all child object
                        if(cs.size() == 1){
                                cs[0].put(primaryField, true);
                                noError(p, cs[0], parentToChildMap.get((Id)cs[0].get('Id')), true);
                                housekeeping(p, cs[0]);
                                addObj(childrenToUpdate,cs[0]);
                        }


                        if(cs.size() > 1){
                            SObject prevPrime;
                            String valid = 'N/A';   // JARVIND - changed it from Boolean to String for S-453872                                        
                            List<sObject> sObjectCount = Database.query('select Id from XcodeAccount__c where IsPrimary__c = true and  Account__r.Id = : pId');
                            system.debug('\n\n 11 sObjectCount =' + sObjectCount.size() + '\n\n');   
                            for(SObject ci : cs){
                                Id ciId = (Id)ci.get('Id');
                                system.debug('\n\n 3333 parentToChildMap.containsKey(ciId) = ' + parentToChildMap.containsKey(ciId) + '\n\n');    
                                system.debug('\n\n 4444 (Boolean)ci.get(primaryField) ' + (Boolean)ci.get(primaryField) +  ' \n\n');  
                                if(parentToChildMap.containsKey(ciId)){
                                    //if the current child in the current loop iteration is a prime child
                                    Boolean childIsPrime = (Boolean)parentToChildMap.get(ciId).get(primaryField);
                                    if(childIsPrime){
                                        housekeeping(p, ci);
                                        addObj(childrenToUpdate,ci);
                                        noError(p, ci, parentToChildMap.get(ciId), false);
                                        valid = 'Yes';
                                    }else{
                                        valid = 'No';
                                    }
                                }else if((Boolean)ci.get(primaryField) && !parentToChildMap.containsKey(ciId))  {
                                    // When the primary is changed on an account with mupliple Xcodes
                                    prevPrime = ci;
                                }

                                system.debug('\n\n valid outside of the blcok: ' + valid +  ' \n\n'); 
                                if(valid == 'Yes' && prevPrime != null){ 
                                    system.debug('\n\n inside the final if block  \n\n');        
                                    prevPrime.put(primaryField, false);
                                    addObj(childrenToUpdate,prevPrime);
                                }
                            }
                        }

                    }
                }

                if(childrenToUpdate.size() > 0){
                    update childrenToUpdate.values();
                }
                update parents;
                system.debug('\n\nInside PrimeChild.PrimeChild() Accounts: After updating objects\n' + parents + '\nContacts: ' + childrenToUpdate + '\n\n');
            //Commented by -- Prashant Gupta (Appirio) for S-455154
            /*}catch(Exception e){
                System.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nError in Prime.setPrimaryChildObj(): ' + e + ' (ON LINE: '+ e.getLineNumber() +')\n\n');
            }*/
            //End


        }


    }


    public class PrimaryChildRemovalConfig{
        public String ObjectType;
        public String ParentLookupField;
        public String PrimaryField;
        public String RecordTypes {get{return RecordTypes == null ? '' : RecordTypes;} set;} //comma separated record type names
        public SObject[] OldChildren;
    }


    public void checkPrimaryChildRemoval(PrimaryChildRemovalConfig config){
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'checkPrimaryChildRemoval');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');


        String childObj = config.ObjectType;
        SObject[] oldChildren = config.OldChildren;
        String parentField = config.ParentLookupField;
        String primeField = config.PrimaryField;
        String childRecordTypes = config.RecordTypes;


        system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nHave '+oldChildren.size()+' child/children to check.\n\n');


        Set<Id> validRecType = validContactRecType(childObj, childRecordTypes);
        Map<Id, SObject> parentToChild = new Map<Id, SObject>();
        for(SObject c : oldChildren){
            if(childRecordTypes == '' || (validRecType.contains((Id)c.get('RecordTypeId')) && (Boolean)c.get(primeField))){
                parentToChild.put((Id)c.get(parentField), c);
            }
        }




        if(parentToChild.size() == 0){
            //this will prevent the execution of the rest of the code when the contact being updated or deleted is not
            //set as primary contact (i.e. contact's Primary_Contact field is set to false)
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nThere are no contact that is previously set as primary contact.\n\n');
             return;
        }


        try{
            String parentIds = ' IN (';
            for(Id pIds : parentToChild.keySet()){
                parentIds += '\'' + pIds + '\',';
            }


            parentIds = parentIds.removeEnd(',');
            parentIds += ')';


            //adds the recordtype condition to the parent query if there's a valid record type
            parentIds = (parentIds != ' IN ()') ? parentField + ' ' +parentIds : '';


            String query = 'SELECT COUNT(Id), '+parentField+' FROM '+childObj+' WHERE '+parentIds+' GROUP BY '+parentField;
            AggregateResult[] results = Database.query(query);
            String primeLabel = primeField.removeEnd('__c').replace('_', ' ');
            for(AggregateResult ar : results){
                Id parentId = (Id)ar.get(parentField);
                if(parentToChild.containsKey(parentId)){
                    if((Integer)ar.get('expr0') > 1){
                        parentToChild.get(parentId).addError('You can not delete a Primary '+childObj+'. Please mark other '+childObj+' as '+primeLabel+' to delete this record.');
                    }else{
                        parentToChild.get(parentId).addError('This is the only '+childObj+' remaining. This record\'s parent must have atleast one '+primeLabel+'.');
                    }
                }
            }
        }catch(Exception e){
            system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nError on checkPrimaryContactRemoval: ' + e + ' On line: ' + e.getLineNumber() + '\n\n');
        }
    }

/**
 * @description override this method to process all field updates (in parent ob or child obj) when updating a child
 * @author B. Espiridion
 * @date 22.JULY.2013
 * @returns Nothing
 * @param the parent object (i.g. Account obj in Account/Contat relationship)
 * @param the child object (i.g. Contact obj in Account/Contat relationship)
 */
    virtual protected void housekeeping(SObject parent, SObject child){


    }
/**
 * @description override this method check field error/validtions (e.g. when checking field consistency between parent and child fields)
 * @author B. Espiridion
 * @date 22.JULY.2013
 * @returns True by default
 * @param the parent object (i.e. Account obj in Account/Contat relationship)
 * @param the child object (i.e. Contact obj in Account/Contat relationship)
 * @param the object where to fire the error
 * @param set this arg if the child is the first record in its parent object
 */
    virtual protected Boolean noError(SObject parent, SObject child, SObject errorCarrier, Boolean isFirst){
        return true;
    }



    protected Set<Id> validContactRecType(String obj, String recordTypes){


        String METHODNAME = CLASSNAME.replace('METHODNAME', 'validContactRecType');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');


        Set<Id> output = new Set<Id>();
        for(String s : recordTypes.split(',')){
            output.add(Utility.GetRecordTypeIdBySObjectNameAndType(obj, s));
        }
      return output;
    }


    private void addObj(Map<Id, SObject> objContainer, SObject obj){


        String METHODNAME = CLASSNAME.replace('METHODNAME', 'addObj');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');


        if(!objContainer.containsKey(obj.Id)){
            objContainer.put(obj.Id, obj);
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 07/03/2014
** @description :  called by onAfterInsert and onAfterUpdate in XCodeAccountTriggerHandler
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/

    public static void SettingOfPrimaryXCodeImplemention(XcodeAccount__c[] pXcodeAccountList){
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'SettingOfPrimaryXCodeImplemention');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');


        PrimaryChild.PrimaryChildConfig config = new PrimaryChild.PrimaryChildConfig();
        config.ParentType = 'Account';
        config.ParentRecordTypes = '';
        config.ParentFieldsToUpdate = 'Primary_Xcode__c';
        config.ParentLookupField = 'Account__c';


        config.ChildType = 'XcodeAccount__c';
        //Sberron - S-445832
        //Commented out to prevent new xcode account from setting existing IsPrimary to false
        // JARVIND - undid the changes made by SBERRON for story S-453872 (enabled the code just below this line)
        config.ChildPrimaryField = 'IsPrimary__c';
        System.debug('----IsPrimary__c' + config.ChildPrimaryField + '----');
        System.debug('----config' + config + '----');
        config.ChildFieldsToUpdate = 'Xcode__r.Name,Xcode__c';
        config.ChildObjectList = pXcodeAccountList;


        PrimaryXCode imlementation = new PrimaryXCode();
        imlementation.setPrimaryChildObj(config);
    }


/*
** @author : Cloud Sherpas Inc.
** @date : 07/03/2014
** @description :  called by onAfterDelete in XCodeAccountTriggerHandler
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
/*
    public static void DeletingOfPrimaryXCodeImplemention(XcodeAccount__c[] pXcodeAccountList){
        String METHODNAME = CLASSNAME.replace('METHODNAME', 'DeletingOfPrimaryXCodeImplemention');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + '\n\n');
        try{
            system.debug('pXcodeAccountList='+ pXcodeAccountList);
            set<Id> ParentAccountOfPrimaryXCode = new set<Id>();


            for(XcodeAccount__c xa : pXcodeAccountList){
                if(xa.IsPrimary__c){
                    ParentAccountOfPrimaryXCode.add(xa.Account__c);
                }
            }


            if(ParentAccountOfPrimaryXCode.size() == 0){
                system.debug('No Deleted Primary XCodeAccount to process.');
                return;
            }
            system.debug('ParentAccountOfPrimaryXCode=' + ParentAccountOfPrimaryXCode);


            Account[] parentAccountToUpdateList = [SELECT Primary_Xcode__c, Id,
                                                        (SELECT Id, Account__c, IsPrimary__c, Xcode__r.IntegrationXcode__c, Xcode__r.Name FROM Xcodes_Accounts__r ORDER BY CreatedDate ASC LIMIT 1)
                                                        FROM Account WHERE Id IN :ParentAccountOfPrimaryXCode];
            system.debug('initial parentAccountToUpdateList=' + parentAccountToUpdateList);


            XcodeAccount__c[] xcodeAccountToUpdate = new XcodeAccount__c[]{};


            for(Account a : parentAccountToUpdateList){
                if(a.Xcodes_Accounts__r != null && a.Xcodes_Accounts__r.size() > 0){
                    a.Xcodes_Accounts__r[0].IsPrimary__c = true;
                    xcodeAccountToUpdate.add(a.Xcodes_Accounts__r[0]);


                    a.Primary_Xcode__c = a.Xcodes_Accounts__r[0].Xcode__r.Name;
                }else{
                    a.Primary_Xcode__c = null;
                }
            }
            system.debug('revised parentAccountToUpdateList=' + parentAccountToUpdateList);
            system.debug('Updating parentAccountToUpdateList');

            update parentAccountToUpdateList;
            system.debug('Updated parentAccountToUpdateList');
            if(xcodeAccountToUpdate.size() > 0){
                update xcodeAccountToUpdate;
            }
        }catch(Exception e){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'Primary XCodeAccount delete logic failed. - please see system log for details.', e);
        }
    }
    */


    public class PrimaryXCode extends PrimaryChild{
        public PrimaryXCode(){
            super('From PrimaryXCode');
        }
        override protected void housekeeping(SObject parent, SObject child){
            Account p = (Account)parent;
            XcodeAccount__c c = (XcodeAccount__c)child;
            if(c.Xcode__c != null){
                p.Primary_Xcode__c = c.Xcode__r.Name;
            }
        }
    }
/*
** @author : Cloud Sherpas Inc.
** @date : 08/28/2014
** @description :  Updates the record when
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public static void updateXCodeAccountFieldsFromMAPP(XcodeAccount__c[] pXcodeAccountList){
        for(XcodeAccount__c xa: pXcodeAccountList){
            //if(xa.MAPPCreatedById__c != null){
            //  xa.CreatedById = xa.MAPPCreatedById__c;
            //}
            //if(con.MAPPLastModifiedById__c != poldContactMap.get(con.Id).MAPPLastModifiedById__c){
            //  con.LastModifiedById = con.MAPPLastModifiedById__c;
            //}
        }

    }


}