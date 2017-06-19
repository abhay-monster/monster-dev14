/*
** @author : CloudSherpas
** @date : 06/04/2014
** @description : Controller for the Monster Links Component.
** @story : 0640
*/
public class MonsterLinksComponentCC{
    final String CLASSNAME = '\n\n**** MonsterLinksComponentCC.METHODNAME()';
    public Id objectId{get; set;}
    public List<Monster_Links__c> monsterLinks{get; set;}
    public List<Monster_Links__c> columnLinks1{get; set;}
    public List<Monster_Links__c> columnLinks2{get; set;}
    public List<Monster_Links__c> columnLinks3{get; set;}
    public List<Monster_Links__c> generalLinks{get; set;}
    public List<Monster_Links__c> germanyLinks{get; set;}
    public List<Monster_Links__c> polandLinks{get; set;}
    public List<Monster_Links__c> austriaLinks{get; set;}
    public List<Monster_Links__c> UKLinks{get;set;}
    public List<Monster_Links__c> brazilLinks{get;set;}
    public List<Monster_Links__c> switzerlandLinks{get;set;}
    public List<Monster_Links__c> turkeyLinks{get;set;}
    public List<Monster_Links__c> russiaLinks{get;set;}
    public List<Monster_Links__c> slovakiaLinks{get;set;}
    public List<Monster_Links__c> irelandLinks{get;set;}
    public List<Monster_Links__c> netherlandLinks{get;set;}
    public List<Monster_Links__c> czechLinks{get;set;}
    public List<Monster_Links__c> mexicoLinks{get;set;}
    public List<Monster_Links__c> swedenLinks{get;set;}
    public List<Monster_Links__c> italyLinks{get;set;}
    public List<Monster_Links__c> franceLinks{get;set;}
    public List<Monster_Links__c> norwayLinks{get;set;}
    public List<Monster_Links__c> latinAmericaLinks{get;set;}
    public List<Monster_Links__c> denmarkLinks{get;set;}
    public List<Monster_Links__c> luxembourgLinks{get;set;}
    public List<Monster_Links__c> belguimLinks{get;set;}
    public List<Account> accountName{get; set;}
    public User userName{get; set;}
    public String idObj{get; set;}
    public String billingAdd{get; set;}
    public Integer count{get; set;}

    /*
    ** @author : CloudSherpas
    ** @date : 06/04/2014
    ** @description : Class constructor.
    ** @param : nothing
    ** @returns : nothing
    */
    public MonsterLinksComponentCC(){
        objectId = ApexPages.currentPage().getParameters().get('id');
        system.debug('objectId'+objectId);
        idObj = string.ValueOf(objectId).substring(0, 3);
        system.debug('idObj'+idObj);
        accountName = new List<Account>();
        accountName = [SELECT Name , AccountId__c, ShippingStreet,
                            FirstName, Primary_Xcode__c,
                            ShippingCity,ShippingState,ShippingCountry,
                            GlobalUltimateDUNSNumber__c,
                            DomesticUltimateDUNSNumber__c,
                            ParentCompanyDUNSNumber__c,
                            GlobalHQAccount__c,
                            GlobalHQAccount__r.Name,
                            DomesticHQAccount__c,
                            DomesticHQAccount__r.Name FROM Account Where Id =: objectId];
        userName = new User();
        userName = [SELECT Id, Alias, FirstName, Network_Domain_Login__c FROM User WHERE Username =: UserInfo.getUserName()];
        getLinks();
    }
    /*
    ** @author : CloudSherpas
    ** @date : 06/04/2014
    ** @description : Get the link depends on the sObject.
    ** @param : nothing
    ** @returns : nothing
    */
    public void getLinks(){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','getLinks');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        List<Monster_Links__c> allLinks = Monster_Links__c.getall().values();
        system.debug('links!!! ' + allLinks);
        monsterLinks = new List<Monster_Links__c>();
        germanyLinks = new List<Monster_Links__c>();
        generalLinks = new List<Monster_Links__c>();
        polandLinks = new List<Monster_Links__c>();
        austriaLinks = new List<Monster_Links__c>();
        UKLinks = new List<Monster_Links__c>();
        brazilLinks = new List<Monster_Links__c>();
        switzerlandLinks = new List<Monster_Links__c>();
        turkeyLinks = new List<Monster_Links__c>();
        russiaLinks = new List<Monster_Links__c>();
        slovakiaLinks = new List<Monster_Links__c>();
        irelandLinks = new List<Monster_Links__c>();
        netherlandLinks = new List<Monster_Links__c>();
        czechLinks = new List<Monster_Links__c>();
        mexicoLinks = new List<Monster_Links__c>();
        swedenLinks = new List<Monster_Links__c>();
        italyLinks = new List<Monster_Links__c>();
        franceLinks = new List<Monster_Links__c>();
        norwayLinks = new List<Monster_Links__c>();
        latinAmericaLinks = new List<Monster_Links__c>();
        denmarkLinks = new List<Monster_Links__c>();
        luxembourgLinks = new List<Monster_Links__c>();
        belguimLinks = new List<Monster_Links__c>();
        billingAdd = '';

        /*Line from 269 moved above as the query is same for all loops and is executing n times . Changed in due of I-171257 by Sunny Gill*/
        String oName = null;
            for(Order__c o : [ SELECT Id, Name FROM Order__c WHERE Id = :objectId ]){
                oName = o.Name;
        }
        for(Monster_Links__c aLinks : allLinks){
            //Account
            if(idObj == '001' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Account')){
                for(Account a : accountName){
                    String newLink = '';
                    newLink = string.ValueOf(alinks.Link__c);

                    if(billingAdd == ''){
                        //Address Parameter
                        if(a.ShippingStreet != null){
                            billingAdd += a.ShippingStreet + ' ';
                        }
                        if(a.ShippingCity != null){
                            billingAdd += a.ShippingCity + ', ';
                        }
                        if(a.ShippingState != null){
                            billingAdd += a.ShippingState + ' ';
                        }
                        if(a.ShippingCountry != null){
                            billingAdd += a.ShippingCountry;
                        }
                    }
                    newLink = newLink.replace('{ACCOUNTADDRESS}', billingAdd);
                    //username
                    //T-413762 To replace federation identifier with Network_Domain_Login__c
                    if(userName.Network_Domain_Login__c != null)
                    newLink = newLink.replace('{USERNAME}', userName.Network_Domain_Login__c);
                    //User Firstname
                    newLink = newLink.replace('{FIRSTNAME}', userName.FirstName);

                    String finalID = string.valueOf(objectId).substring(0, 15);
                    if(a.GlobalHQAccount__c != null){
                        //String finalGlobalHQID = string.valueOf(a.GlobalHQAccount__c).substring(0, 15);
                        newLink = newLink.replace('{GlobalHQAcc18}', a.GlobalHQAccount__c );
                    } else {
                        newLink = newLink.replace('{GlobalHQAcc18}', '');
                    }
                    if(a.DomesticHQAccount__c != null){
                        //String finalDomesticlHQID = string.valueOf(a.DomesticHQAccount__c).substring(0, 15);
                        newLink = newLink.replace('{DomesticHQAcc18}', a.DomesticHQAccount__c );
                    } else {
                        newLink = newLink.replace('{DomesticHQAcc18}', '');
                    }
                    newLink = newLink.replace('{ACCOUNTID18}', objectId);
                    newLink = newLink.replace('{ACCOUNTID}', finalID);
                    //Global DUNS Parameter
                    if(a.GlobalUltimateDUNSNumber__c != null){
                        newLink = newLink.replace('{DUNS}', a.GlobalUltimateDUNSNumber__c);
                    }else{
                        newLink = newLink.replace('{DUNS}', '');
                    }

                    //Domestic DUNS Parameter
                    if(a.DomesticUltimateDUNSNumber__c != null){
                        newLink = newLink.replace('{DomDUNS}', a.DomesticUltimateDUNSNumber__c);
                    }else{
                        newLink = newLink.replace('{DomDUNS}', '');
                    }

                    //Parent DUNS Parameter
                    if(a.ParentCompanyDUNSNumber__c != null){
                        newLink = newLink.replace('{ParDUNS}', a.ParentCompanyDUNSNumber__c);
                    }else{
                        newLink = newLink.replace('{ParDUNS}', '');
                    }

                    //xcode
                    if(a.Primary_Xcode__c != null){
                        newLink = newLink.replace('{XCODE}', a.Primary_Xcode__c);
                    }else{
                        newLink = newLink.replace('{XCODE}', '');
                    }

                    //Name Parameter
                    a.Name = a.Name.replace('&', '%26');
                    newLink = newLink.replace('{ACCOUNTNAME}', a.Name);
                    //Account Id %3A
                    newLink = newLink.replace('{ACCOUNTIDNAME}', a.AccountId__c);
                    aLinks.Link__c = newLink;
                }
                system.debug(alinks);
                monsterLinks.add(aLinks);
            }
            //Opportunity
            if(idObj == '006' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Opportunity')){
                monsterLinks.add(aLinks);
            }
            //Case
            if(idObj == '500' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Case')){
                monsterLinks.add(aLinks);
                //assign links per country
                if(aLinks.Country__c == 'General' ){
                    generalLinks.add(aLinks);
                }else if(aLinks.Country__c == 'Germany' ){
                    germanyLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Poland' ){
                    polandLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Austria' ){
                    austriaLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'UK' ){
                    UKLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Brazil' ){
                    brazilLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Switzerland' ){
                    switzerlandLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Turkey' ){
                    turkeyLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Russia' ){
                    russiaLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Slovakia' ){
                    slovakiaLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Ireland' ){
                    irelandLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Netherlands' ){
                    netherlandLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Czech' ){
                    czechLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Mexico' ){
                    mexicoLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Sweden' ){
                    swedenLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Italy' ){
                    italyLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'France' ){
                    franceLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Norway' ){
                    norwayLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'latin America' ){
                    latinAmericaLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Denmark' ){
                    denmarkLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Luxembourg' ){
                    luxembourgLinks.add(aLinks);
                }
                else if(aLinks.Country__c == 'Belgium' ){
                    belguimLinks.add(aLinks);
                }
            }

            //Order__c
            Schema.DescribeSObjectResult r = Order__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            /* Moving the below sql query above line no 107 to avoid multiple execution in due of I-171257*/
            /*String oName = null;
            for(Order__c o : [ SELECT Id, Name FROM Order__c WHERE Id = :objectId ]){
                oName = o.Name;
            }*/

            /*Jonathan Freese Appirio 5/10/16

              The next block of code started failing on Dev after Dev was upgraded to Summer 2016.
              The statement
            if(idObj  == keyPrefix && aLinks.Object_Name__c.contains('Order__c')){
              started failing with FATAL_ERROR|System.NullPointerException: Attempt to de-reference a null object

              The null field is on the link named 'External Links'.

              Neither the code nor the custom setting record have been modified since July 2015.
              The code really should have been failing all this time but for some reason did not;
              fixed it here and everywhere.*/

            if(idObj  == keyPrefix && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Order__c')){
                aLinks.link__c += '?pv0=' + oName ;
                monsterLinks.add(aLinks);
            }

            //Order
            if(idObj == 'a3t' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Order')){
                monsterLinks.add(aLinks);
            }
            //Xcode
            if(idObj == 'a3K' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Xcode')){
                monsterLinks.add(aLinks);
            }
            //Activity
            if((idObj == '00T' || idObj == '00U') && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Activity')){
                monsterLinks.add(aLinks);
            }
            //User
            if(idObj == '005' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('User')){
                    String newLink = '';
                    newLink = string.ValueOf(alinks.Link__c);
                    newLink = newLink.replace('{USERNAME}', userName.Alias);
                    aLinks.Link__c = newLink;
                    monsterLinks.add(aLinks);

            }
            //Proposal
            if(idObj == 'a0m' && aLinks.Object_Name__c != null && aLinks.Object_Name__c.contains('Proposal')){
                monsterLinks.add(aLinks);
            }

            monsterLinks.sort();

            columnLinks1 = new List<Monster_Links__c>();
            columnLinks2 = new List<Monster_Links__c>();
            columnLinks3 = new List<Monster_Links__c>();
            Integer flag = 0;
            for(count = 0; count < monsterLinks.size(); count++){

                if(count>2){
                    for(flag = count; flag > 2; flag){
                        flag = flag - 3;
                    }
                }
                if(flag == 0){
                    columnLinks1.add(monsterLinks[count]);
                }
                if(flag == 1){
                    columnLinks2.add(monsterLinks[count]);
                }
                if(flag == 2){
                    columnLinks3.add(monsterLinks[count]);
                }
                flag++;
            }

        }
    }

}