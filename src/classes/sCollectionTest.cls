@isTest
public class sCollectionTest {
    static testmethod void TestsCollection()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;       
        System.runAs(u) 
        {
            Test.startTest();
            String OBJ_NAME = 'Account';
            List<Id> idList = new List<Id>();
            List<sObject> sObjList = new List<sObject>();
            sObject sobj = null;
            Account acc1 = new Account(name ='Test1');
            insert acc1;
            Account acc2 = new Account(name ='Test2');
            insert acc2;
            idList.add(acc1.Id);
            idList.add(acc2.Id);
            
            DescribeFieldResult F = Account.Id.getDescribe();
            sObjectField idField = F.getSObjectField();
            F = Account.Name.getDescribe();
            sObjectField nameField = F.getSObjectField();
            F = Account.PersonBirthdate.getDescribe();
            sObjectField dateField = F.getSObjectField();
            
            //sobj = Schema.getGlobalDescribe().get(OBJ_NAME).newSObject() ;
            sObjList.add((sObject)acc1);
            sObjList.add((sObject)acc2);
            
            system.debug('===> sObjList : '+sObjList);
            //insert sObjList;
            List<Object> ObjLst= new List<Object>();
            String i = 's1',j='s2';
            ObjLst.add(i);
            ObjLst.add(j);
            
            map<Id, list<sObject>> idlistMap = new map<Id, list<sObject>>();
            for (sObject sObj1 : sObjList) {
                Id sObjId = (Id) sObj1.get(idField);
                list<sObject> temp = idlistMap.get(sObjId) == null ? new list<sObject>() : idlistMap.get(sObjId);
                temp.add(sObj1);
                idlistMap.put(sObjId, temp);
            }
            map<String, list<sObject>> strlistMap = new map<String, list<sObject>>();
            for (sObject sObj2 : sObjList) {
                String sObjId = (String) sObj2.get(nameField);
                list<sObject> temp = strlistMap.get(sObjId) == null ? new list<sObject>() : strlistMap.get(sObjId);
                temp.add(sObj2);
                strlistMap.put(sObjId, temp);
            }
            map<Id, set<string>> idlistset = new map<Id, set<string>>();
            for (sObject sObj3 : sObjList) {
                Id sObjId = (Id) sObj3.get(idField);
                set<string> temp = idlistset.get(sObjId) == null ? new set<string>() : idlistset.get(sObjId);
                temp.add((string)sObj3.get(nameField));
                idlistset.put(sObjId, temp);
            }
            
            sCollection.idMap(sObjList, 'Id');
            sCollection.idMap(sObjList, idField);
            sCollection.stringMap(sObjList, nameField);
             map<String, sObject> stringMap = sCollection.stringMap(sObjList, 'Name'); 
            sCollection.dateMap(sObjList,dateField );
            sCollection.dateMap(sObjList,'PersonBirthdate' );
            sCollection.stringSet(sObjList, nameField);
            sCollection.stringSet(sObjList, 'Name');
            sCollection.idSet(sObjList, 'Id');
            sCollection.idSet(sObjList, idField);
            sCollection.idListMap(sObjList, 'Id');
            sCollection.idListMap(sObjList, idField);
            sCollection.stringListMap(sObjList, nameField);
            sCollection.stringListMap(sObjList, 'Name');
            sCollection.idListSet(sObjList,idField, nameField);
            sCollection.idListSet(sObjList, 'Id','Name');
            sCollection.puts(sObjList, nameField, ObjLst);
            sCollection.puts(sObjList, nameField, ObjLst.get(0));
            sCollection.puts(sObjList, 'Name', ObjLst.get(0));
            sCollection.flatten(idlistMap);
            sCollection.flatten(strlistMap);
            sCollection.filter(sObjList, nameField, ObjLst.get(0));
            sCollection.filter(sObjList, 'Name', ObjLst.get(0));
            sCollection.filterNotEqual(sObjList, nameField, ObjLst.get(0));
            sCollection.filterNotEqual(sObjList, 'Name', ObjLst.get(0));
            sCollection.sortByString(strlistMap);
            sCollection.sortByString(stringMap);
            sCollection.partition(sObjList, 1);
            sCollection.idPartition(idList, 1);
            //idlistset
            Test.stopTest();
        }
    }

}