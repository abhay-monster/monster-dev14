/**
* @description generic class for both the custom UI and the merge batch / trigger.
* @author Cloudsherpas
* @date 01-06-2015
* @last modified 09-03-2015
*/
public without sharing class AccountMergeHelper{

  public Account winningAccount;
  public Account losingAccount;

  public List<Contact> winningAccountCons;
  public List<Contact> losingAccountCons;

  public List<Contact> dupeContactsList;
  public List<Contact> forUpdContactsList;

  public List<Account> forUpdAccountList;

  public List<XcodeAccount__c> dupeXCodesList;

  public List<RelatedPartner__c> dupePartnersList;

  public List<CompetitiveLandscape__c> dupeCompetitorsList;

  public List<Account_Team_Member__c> losAccTeamMemberList;

  private String losingRegistrationNumber;

  /**
  * @description main method where entry of winning and losing account Ids occur.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 03-10-2015
  */
  public string mergeAccounts(Id winningAccountId, Id losingAccountId){
    string res = '';
    //instantiate the accounts in scope
    winningAccount = new Account();
    losingAccount = new Account();

    Account winningAccWithCreatedDate;
    Account losingAccWithCreatedDate;

    //retrieve the account records using the supplied winning and losing account Ids
    for(Account acc: [
      SELECT  Id, Name, OwnerId, DomesticHQAccount__c, GlobalHQAccount__c, ParentId, NewspaperStatus__c, OtherPhone__c,Fax,
              IsGlobalHQ__c, IsDomesticHQ__c, DUNSNumber, RegistrationNumber__c, Score__c, AccountStatus__c, CreditStatus__c,
              Fax_Area_Code_Do_Not_Call__c, Fax_Number_Mobile_Phone_Do_Not_call__c, Fax_Number_National_Do_Not_Call__c, FaxDoNotCall__c,PostingAddressDoNotMail__c,DoNotMail__c,BillingAddressDoNotMail__c,
              Other_Phone_Mobile_Do_Not_Call__c, Other_Phone_National_Do_Not_Call_Registr__c, OtherDoNotCall__c, Phone_Mobile_Do_Not_Call__c, Phone_National_Do_Not_Call_Registry__c, PhoneDoNotCall__c,ResumeExpires__c,
              DoNotMerge__c, ShippingCountry, PrimaryBillingContact__c, Registration__c, CustomerDate__c , CreatedDate, DateMerged__c,JobPostzExpires__c,CustomerLapsedDate__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
              BillingCountry, BillingStreet, BillingCity, BillingState, BillingPostalCode,AccountProgram__c, Lead_Account_Status__c, Hierarchy_Locked__c
      FROM    Account
      WHERE   Id = :winningAccountId Or Id =:losingAccountId
    ]){
      if(acc.Id == winningAccountId){

          // I-179696 : New method introduced to create variable without created date field since with created date, merge doesn't support
          winningAccount = getAccountWithoutCreatedDate(acc);

          System.debug('winning account without created date is ' + winningAccount);
          winningAccWithCreatedDate = acc;
          //system.assert(false,winningAccWithCreatedDate);
      }
      else{

        // I-179696 : New method introduced to create variable without created date field since with created date, merge doesn't support
        losingAccount = getAccountWithoutCreatedDate(acc);
        losingAccWithCreatedDate = acc;

          System.debug('losing account without created date is ' + losingAccount);

        // T-431240 - Check if losing account is a primary account on RegistrationNumber__c
        if (losingAccount.Registration__c != null){
            List<RegistrationNumber__c> registrationNums = [Select id, PrimaryBillingAccount__c
                                                                                                        from RegistrationNumber__c
                                                                                                        where id =: losingAccount.Registration__c
                                                                                                        and PrimaryBillingAccount__c =: losingAccount.id];
            if (registrationNums.size() > 0){
                losingRegistrationNumber = losingAccount.Registration__c;
            }
        }
      }

    }
    // validate winning and losing account data
    res = validateAccounts();
    //if all validations passed, perform a query on winning and losing account's child records.
    if(res == Label.CS_AccountMerge_Info_Success_Merge){
      // collect dupe contacts
      retrieveContacts();
      // collect dupe XCodes
      retrieveXCodes();
      // collect dupe partners
      retrievePartners();
      // collect dupe competitors
      retrieveCompetitors();
      // collect losing account account team members
      retrieveTeamMembers();
      // cleanup the account team members before the merge
      purgeLosAccountTeamMembers();
      // update surviving contact's Do Not Call and Primary Billing flags
      updateContacts();
      // update reparented accounts

      //update winning account's Account Program field
      updateAccountProgram();

      updateAccounts();
      //perform standard merge on the two accounts
      merge winningAccount losingAccount;
      //update the winning account's newspaper status
        updateNewsPaperStatus();

      //update winning account's DUNS Number with the duplicate's DUNS Number if the winning account's DUNS Number is blank
      updateDUNSNumber();
      //update winning account's RegistrationNumber with duplicate's RegistrationNumber only if winning account have it blank
      updateRegistrationNumber();
       //update winning account's Do Not Call fields with duplicate's Do Not Call fields only if winning account have it blank
      updateDNC();
      //system.assert(false , winningAccount.FaxDoNotCall__c +'>>>>>>>>>'+winningAccount.Fax);
      // update winningAccount parent lookups
      // updateParentLookups();
      if(winningAccount.ShippingCountry != 'Canada'){//score logic only for non-Canadian Accounts
        //update winning account's score
        updateScore();
      }
      //cleanup the dupe contacts
      dedupeContacts();
      //cleanup the dupeXcodes
      dedupeXCodes();
      //cleanup the dupePartners
      dedupePartners();
      //cleanup the competitors
      dedupeCompetitors();
      // added by George Huene 1/29/2015
      // indicate the date the accounts were merged on the winning record
      //winningAccount.DateMerged__c = Datetime.now();
        checktCreditStatus(); //update status of winning account based on the priority list, from the losing account
        onlyOnePrimary();
      // I-179696 : New variables introduced with created date field, Original code was failing in merge operation
        System.debug('after merging acount is now '+ winningAccount);
        System.debug('after merging winningaccwithoutdate is ' + winningAccWithCreatedDate);

       /*if(winningAccWithCreatedDate.DateMerged__c == null)
            winningAccount.DateMerged__c = winningAccWithCreatedDate.createddate;

        if(winningAccWithCreatedDate.createddate < winningAccount.DateMerged__c)
            winningAccount.DateMerged__c = winningAccWithCreatedDate.createddate;

        if(losingAccWithCreatedDate.createddate < winningAccount.DateMerged__c)
            winningAccount.DateMerged__c = losingAccWithCreatedDate.createddate;

        if(losingAccWithCreatedDate.DateMerged__c != null)
            if(losingAccWithCreatedDate.DateMerged__c < winningAccount.DateMerged__c)
                winningAccount.DateMerged__c = losingAccWithCreatedDate.DateMerged__c;
          if(losingAccWithCreatedDate != null )
            winningAccount.JobPostzExpires__c = losingAccWithCreatedDate.JobPostzExpires__c;

        */

        // I-212589

        if(losingAccWithCreatedDate.AccountStatus__c == 'Customer' && winningAccWithCreatedDate.AccountStatus__c == 'Lapsed Customer'){
            winningAccount.AccountStatus__c = 'Customer';
            winningAccount.CustomerLapsedDate__c = null;
        }

        /* I-212560 - Commented above code and updated related to date fields populated on winner account
            Customer Date (CustomerDate__c) - should be the EARLIEST between the winner and loser accounts.
            Original Create Date (DateMerged__c) -  should be the EARLIEST between winner and loser accounts.
            Job Post Expires (JobPostzExpires__c) - should be the MOST RECENT between winner and loser accounts
            Resume Expires (ResumeExpires__c) - should be the MOST RECENT between winner and loser accounts.
        */

        winningAccount.CustomerDate__c = compareDates(winningAccount.CustomerDate__c, losingAccWithCreatedDate.CustomerDate__c,true);
        winningAccount.DateMerged__c = compareDateTime(winningAccount.DateMerged__c, losingAccWithCreatedDate.DateMerged__c,true);
        winningAccount.JobPostzExpires__c = compareDates(winningAccount.JobPostzExpires__c, losingAccWithCreatedDate.JobPostzExpires__c,false);
        winningAccount.ResumeExpires__c = compareDates(winningAccount.ResumeExpires__c, losingAccWithCreatedDate.ResumeExpires__c,false);

        // Account Program Association
        if(winningAccWithCreatedDate.AccountProgram__c   == null )
            winningAccWithCreatedDate.AccountProgram__c = losingAccWithCreatedDate.AccountProgram__c ;
        else{
            winningAccount.AccountProgram__c =  winningAccWithCreatedDate.AccountProgram__c;
         }

        // Shyam - 3/20 : S-471841 
        winningAccount.Lead_Account_Status__c = winningAccWithCreatedDate.Lead_Account_Status__c;
        
        if(winningAccWithCreatedDate.ParentId == null && losingAccWithCreatedDate.ParentId != null && losingAccWithCreatedDate.Hierarchy_Locked__c){
            winningAccount.Hierarchy_Locked__c = losingAccWithCreatedDate.Hierarchy_Locked__c;
        }
        
        // write changes to the system
        update winningAccount;

      // T-431240 - added by parul gupta
      if(winningAccount.Registration__c != null && losingRegistrationNumber != null){
        updateEntityAssociatedAccounts();
      }
    }

    return res;
  }

  /**
  * @description reparent child accounts from the losing record to the winning record - Story: 3386
  * @author George Huene
  * @date 03-18-2015
  * @last
  */
  public String reparentChildAccounts()
  {
    forUpdAccountList = new List<Account>();

    Account tempLose;
    Account tempWin;

    Map<Id,Account> forUpdAccountMap; // to prevent dupe ids

    // grab child records for the winning and losing accounts
    for(Account acc:reparentAccountQuery())
    {
      if(acc.Id == losingAccount.Id) {

        tempLose = acc;
        System.debug('----tempLose ' + tempLose);
      }
      else {
        tempWin = acc;
        System.debug('----tempWin ' + tempWin);
      }
    }

    if(tempLose == null || tempWin == null)
    {
      return 'An unexpected error occurred. Please try again.';// TODO: make label
    }
    else
    {
      // REPARENT WINNING ACCOUNT

      // Global HQ Account is the ultimate parent, so validation is more involved
      // if losing account is a global HQ and winning account is looking up to a global hq

        System.debug('global isss' + tempLose.GlobalHQAccounts__r + 'boolean isss' + tempLose.IsGlobalHQ__c + tempLose  );

        Boolean temp = tempLose.GlobalHQAccounts__r != null ;
            Boolean temp1 = !tempLose.GlobalHQAccounts__r.isEmpty();
            Boolean temp2 = tempLose.IsGlobalHQ__c;

        System.debug('condition iss' + temp + temp1 + temp2 + 'value iss __c ' + tempLose.GlobalHQAccount__c + '__r is ' + tempLose.GlobalHQAccounts__r);

      if((tempLose.GlobalHQAccounts__r != null && !tempLose.GlobalHQAccounts__r.isEmpty()) || tempLose.IsGlobalHQ__c)
      {
        if(tempWin.GlobalHQAccount__c != null && tempWin.GlobalHQAccount__c != tempLose.Id)
        {
          // winning account can't become a global hq if it is looking up to a different global hq
          return 'Winning account is referencing a different global headquarters and cannot become a global headquarters.';// TODO: make label
        }
        else
        {
          // winning account becomes global HQ
          winningAccount.GlobalHQAccount__c = null;
          winningAccount.IsGlobalHQ__c = true;
        }
      }
      else if(

        //  System.debug('tempLose.GlobalHQAccounts__r'+ tempLose.GlobalHQAccounts__r + ' !tempLose.IsGlobalHQ__c' +  tempLose.IsGlobalHQ__c + 'tempLose.GlobalHQAccount__c != null' + tempLose.GlobalHQAccount__c + 'tempWin.GlobalHQAccounts__r == null' + tempWin.GlobalHQAccounts__r  + ' !tempWin.IsGlobalHQ__c' +  tempWin.IsGlobalHQ__c + ' tempWin.GlobalHQAccount__c == null' +  tempWin.GlobalHQAccount__c);
        tempLose.GlobalHQAccounts__r == null && // losing account does not have children
        !tempLose.IsGlobalHQ__c && // losing account is not a global HQ
        tempLose.GlobalHQAccount__c != null && // losing account has a parent
        tempWin.GlobalHQAccounts__r == null && // winning account does not have children
        !tempWin.IsGlobalHQ__c && // winning account is not a global HQ
        tempWin.GlobalHQAccount__c == null // winning account does not have a parent
      ){
        winningAccount.GlobalHQAccount__c = tempLose.GlobalHQAccount__c; // winning account enherits losing account's parent
      }

      // if winning account is looking to to losing account as Domestic HQ
      if(tempWin.DomesticHQAccount__c != null && tempWin.DomesticHQAccount__c == tempLose.Id)
      {
        if(tempLose.DomesticHQAccount__c != null)
        {
          winningAccount.DomesticHQAccount__c = tempLose.DomesticHQAccount__c; // winning account inherits losing account's parent
        }
        else
        {
          // winning account becomes domestic hq
          winningAccount.DomesticHQAccount__c = null;
          winningAccount.IsDomesticHQ__c = true;
        }
      }
      else if(tempWin.DomesticHQAccount__c == null && tempLose.DomesticHQAccount__c != null)
      {
        winningAccount.DomesticHQAccount__c = tempLose.DomesticHQAccount__c; // winning account inherits losing account's parent
      }

      if(tempWin.ParentId != null && tempWin.ParentId == tempLose.Id)
      {
        if(tempLose.ParentId != null)
          winningAccount.ParentId = tempLose.ParentId; // winning account inherits losing account's parent
        else
          winningAccount.ParentId = null;
      }
      else if(tempWin.ParentId == null && tempLose.ParentId != null)
      {
        winningAccount.ParentId = tempLose.ParentId; // winning account inherits losing account's parent
      }

      // REPARENT CHILD ACCOUNTS

      forUpdAccountMap = new Map<Id,Account>();

      if(tempLose.ChildAccounts != null && !tempLose.ChildAccounts.isEmpty())
      {
        for(Account ca:tempLose.ChildAccounts)
        {
          // takes care of losing account being winning account's parent
          if(ca.Id != winningAccount.Id)
          {
            // reparent child account
            ca.ParentId = winningAccount.Id;
            forUpdAccountMap.put(ca.Id,ca);
          }
        }
      }

      if(tempLose.DomesticHQAccounts__r != null && !tempLose.DomesticHQAccounts__r.isEmpty())
      {
        for(Account ca:tempLose.ChildAccounts)
        {
          // takes care of losing account being winning account's parent
          if(ca.Id != winningAccount.Id)
          {
            // checks for account in update map
            if(forUpdAccountMap.containsKey(ca.Id))
            {
              // if it exists, it changes the parent
              forUpdAccountMap.get(ca.Id).DomesticHQAccount__c = winningAccount.Id;
            }
            else
            {
              // if not, it changes the parent before adding it to the map
              ca.DomesticHQAccount__c = winningAccount.Id;
              forUpdAccountMap.put(ca.Id,ca);
            }
          }
        }
      }

      if(tempLose.GlobalHQAccounts__r != null && !tempLose.GlobalHQAccounts__r.isEmpty())
      {
        for(Account ghqa:tempLose.GlobalHQAccounts__r)
        {
          // takes care of losing account being winning account's parent
          if(ghqa.Id != winningAccount.Id)
          {
            // checks for account in update map
            if(forUpdAccountMap.containsKey(ghqa.Id))
            {
              // if it exists, it changes the parent
              forUpdAccountMap.get(ghqa.Id).GlobalHQAccount__c = winningAccount.Id;
            }
            else
            {
              // if not, it changes the parent before adding it to the map
              ghqa.GlobalHQAccount__c = winningAccount.Id;
              forUpdAccountMap.put(ghqa.Id,ghqa);
            }
          }
        }
      }

      if(forUpdAccountMap != null && !forUpdAccountMap.isEmpty())
        forUpdAccountList.addAll(forUpdAccountMap.values());
    }
    return null;
  }

  // query used for reparenting of accounts
  public List<Account> reparentAccountQuery()
  {
    return
    [
      SELECT  Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c,IsGlobalHQ__c,IsDomesticHQ__c,
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM ChildAccounts),
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM GlobalHQAccounts__r),
              (SELECT Id,Name,ParentId,GlobalHQAccount__c,DomesticHQAccount__c FROM DomesticHQAccounts__r)
      FROM    Account
      WHERE   Id =: losingAccount.Id
      OR      Id =: winningAccount.Id
    ];
  }

  // updates accounts that were reparented
  public void updateAccounts()
  {
    if(forUpdAccountList != null && !forUpdAccountList.isEmpty())
      /*JFreese Appirio 02/06/17 S-453964
        forUpdAccountList was created in reparentChildAccounts() when it was run in validateAccounts()
        But the winner's AccountProgram may have been subsequently modified in updateAccountProgram().
        So set each child's AccountProgram value here to match the winner's if (it has one)*/
      for(Account a : forUpdAccountList){
        if (winningAccount.AccountProgram__c != null){
          a.AccountProgram__c = winningAccount.AccountProgram__c;
        }
      }
      update forUpdAccountList;
  }

  /**
  * @description custom logic for updating the winning account's score value
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void updateScore(){
    if(winningAccount.Score__c == null && losingAccount.Score__c != null){
        winningAccount.Score__c = losingAccount.Score__c;
    }

    if((winningAccount.Score__c >= 10 && winningAccount.Score__c <= 90) && (losingAccount.Score__c >= 1 && losingAccount.Score__c <= 9)){
      winningAccount.Score__c = losingAccount.Score__c;
    }
  }

  /**
  * @description winning account gets the DUNS Number from the losing account if the winning account doesn't have a DUNS Number.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void updateDUNSNumber(){
    if(winningAccount.DUNSNumber == null && losingAccount.DUNSNumber != null)
    {
      winningAccount.DUNSNumber = losingAccount.DUNSNumber;
    }
  }

  /**
  * @description update winning account's RegistrationNumber with duplicate's RegistrationNumber only if winning account have it blank
  * @author appirio
  * @date 09-2-2016
  */
  public void updateRegistrationNumber(){
    if(winningAccount.RegistrationNumber__c == null && losingAccount.RegistrationNumber__c != null)
    {
      winningAccount.RegistrationNumber__c = losingAccount.RegistrationNumber__c;
    }
  }

  /**
  * @description update winning account's Do Not Call fields with duplicate's Do Not Call fields only if winning account have it blank
  * @author Pratibha Chhimpa Appirio
  * @date 10FEB2016
  */
  public void updateDNC(){

  system.debug('check if its working' + winningAccount);
  system.debug('check if its working' + losingAccount);

    if(winningAccount.OtherPhone__c == null && losingAccount.OtherPhone__c != null)
    {
      winningAccount.OtherPhone__c= losingAccount.OtherPhone__c;
    }

    if(winningAccount.Fax == null && losingAccount.Fax != null)
    {
      winningAccount.Fax = losingAccount.Fax;
    }

    if(winningAccount.Fax_Number_Mobile_Phone_Do_Not_call__c == false && losingAccount.Fax_Number_Mobile_Phone_Do_Not_call__c != false)
    {
      winningAccount.Fax_Number_Mobile_Phone_Do_Not_call__c = losingAccount.Fax_Number_Mobile_Phone_Do_Not_call__c;
    }

    if(winningAccount.Fax_Number_National_Do_Not_Call__c == false && losingAccount.Fax_Number_National_Do_Not_Call__c != false)
    {
      winningAccount.Fax_Number_National_Do_Not_Call__c = losingAccount.Fax_Number_National_Do_Not_Call__c;
    }

    if(winningAccount.FaxDoNotCall__c == false && losingAccount.FaxDoNotCall__c != false )
    {
      winningAccount.FaxDoNotCall__c = losingAccount.FaxDoNotCall__c;
      winningAccount.Fax = losingAccount.Fax;
    }

    if(winningAccount.Other_Phone_Mobile_Do_Not_Call__c == false && losingAccount.Other_Phone_Mobile_Do_Not_Call__c != false )
    {
      winningAccount.Other_Phone_Mobile_Do_Not_Call__c = losingAccount.Other_Phone_Mobile_Do_Not_Call__c;
    }

    if(winningAccount.Other_Phone_National_Do_Not_Call_Registr__c == false && losingAccount.Other_Phone_National_Do_Not_Call_Registr__c != false )
    {
      winningAccount.Other_Phone_National_Do_Not_Call_Registr__c = losingAccount.Other_Phone_National_Do_Not_Call_Registr__c;
    }

    if(winningAccount.OtherDoNotCall__c == false && losingAccount.OtherDoNotCall__c != false )
    {
      winningAccount.OtherDoNotCall__c = losingAccount.OtherDoNotCall__c;
    }

    if(winningAccount.Phone_Mobile_Do_Not_Call__c == false && losingAccount.Phone_Mobile_Do_Not_Call__c != false)
    {
      winningAccount.Phone_Mobile_Do_Not_Call__c = losingAccount.Phone_Mobile_Do_Not_Call__c;
    }

    if(winningAccount.Phone_National_Do_Not_Call_Registry__c == false && losingAccount.Phone_National_Do_Not_Call_Registry__c != false)
    {
      winningAccount.Phone_National_Do_Not_Call_Registry__c = losingAccount.Phone_National_Do_Not_Call_Registry__c;
    }

    if(winningAccount.PhoneDoNotCall__c == false && losingAccount.PhoneDoNotCall__c != false )
    {
      winningAccount.PhoneDoNotCall__c = losingAccount.PhoneDoNotCall__c;
    }

    if(winningAccount.DoNotMail__c == false && losingAccount.DoNotMail__c != false )
    {
      winningAccount.DoNotMail__c = losingAccount.DoNotMail__c;
    }
    // Update Do Not mail Fields
    if((winningAccount.BillingStreet == null && winningAccount.BillingCountry == null && winningAccount.BillingCity == null
        && winningAccount.BillingState == null && winningAccount.BillingPostalCode == null)
        && (losingAccount.BillingStreet == null || losingAccount.BillingCountry == null || losingAccount.BillingCity == null
        || losingAccount.BillingState == null || losingAccount.BillingPostalCode == null))
    {
      winningAccount.BillingStreet = losingAccount.BillingStreet;
      winningAccount.BillingCountry = losingAccount.BillingCountry;
      winningAccount.BillingCity = losingAccount.BillingCity;
      winningAccount.BillingState = losingAccount.BillingState;
      winningAccount.BillingPostalCode = losingAccount.BillingPostalCode;
    }
    if((winningAccount.ShippingStreet == null && winningAccount.ShippingCountry == null && winningAccount.ShippingCity == null
        && winningAccount.ShippingState == null && winningAccount.ShippingPostalCode == null)
        && (losingAccount.ShippingStreet == null || losingAccount.ShippingCountry == null || losingAccount.ShippingCity == null
        || losingAccount.ShippingState == null || losingAccount.ShippingPostalCode == null))
    {
      winningAccount.ShippingStreet = losingAccount.ShippingStreet;
      winningAccount.ShippingCountry = losingAccount.ShippingCountry;
      winningAccount.ShippingCity = losingAccount.ShippingCity;
      winningAccount.ShippingState = losingAccount.ShippingState;
      winningAccount.ShippingPostalCode = losingAccount.ShippingPostalCode;
    }

    if(winningAccount.BillingAddressDoNotMail__c == false && losingAccount.BillingAddressDoNotMail__c != false &&
        !(winningAccount.BillingStreet == null || winningAccount.BillingCountry == null || winningAccount.BillingCity == null
        || winningAccount.BillingState == null || winningAccount.BillingPostalCode == null))
    {
      winningAccount.BillingAddressDoNotMail__c = losingAccount.BillingAddressDoNotMail__c;
    }
    if(winningAccount.PostingAddressDoNotMail__c == false && losingAccount.PostingAddressDoNotMail__c != false &&
        !(winningAccount.ShippingStreet == null || winningAccount.ShippingCountry == null || winningAccount.ShippingCity == null
        || winningAccount.ShippingState == null || winningAccount.ShippingPostalCode == null))
    {
      winningAccount.PostingAddressDoNotMail__c = losingAccount.PostingAddressDoNotMail__c;
    }
  }

  /**
  * @description custom logic for updating the winning account's newspaper status field.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void updateNewsPaperStatus(){
    if((winningAccount.NewspaperStatus__c == 'Monster Exclusive' && losingAccount.NewspaperStatus__c == 'Partner Exclusive') ||
       (winningAccount.NewspaperStatus__c == 'Partner Exclusive' && losingAccount.NewspaperStatus__c == 'Monster Exclusive')
      )
    {
      winningAccount.NewspaperStatus__c = 'Joint';
    }
  }

   /**
  * @description : custom logic for updating the winning account's Account Program field.
  * @author : Deepanshu Soni (Appirio)
  * @date : 18-NOV-2016
  * @last : modified 18-NOV-2016
  * @Reference : S-453964
  */
  public void updateAccountProgram(){

    if(winningAccount.AccountProgram__c ==null ){
        if(losingAccount.AccountProgram__c !=null){
            winningAccount.AccountProgram__c = losingAccount.AccountProgram__c;
        }
        //system.assert(false,'<<winningAccount.AccountProgram__c>>'+winningAccount.AccountProgram__c);
    }


  }
  /**
  * @description delete losing account's custom account team member records
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void purgeLosAccountTeamMembers(){
    if(losAccTeamMemberList.size() > 0){
      AccountTeamMemberTriggerHandler.CanThrowError = false;
      delete losAccTeamMemberList;
    }
  }

  /**
  * @description retrieve losing account's custom account team members
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void retrieveTeamMembers(){
    losAccTeamMemberList = new List<Account_Team_Member__c>();
    for(Account_Team_Member__c atm:[select Id, AccountId__c from Account_Team_Member__c where AccountId__c =:losingAccount.Id]){
      losAccTeamMemberList.add(atm);
    }
    system.debug('^^Losing Account Team Members ' + losAccTeamMemberList);
  }

  /**
  * @description delete losing account's duplicate competitors
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void dedupeCompetitors(){
    if(dupeCompetitorsList.size() > 0){
      delete dupeCompetitorsList;
    }
  }

  /**
  * @description retrieve competitors and identify duplicate competitors by name.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void retrieveCompetitors(){
    dupeCompetitorsList = new List<CompetitiveLandscape__c>();

    set<string> winAcCompetitors = new set<string>();
    set<string> losAcCompetitors = new set<string>();

    map<string, CompetitiveLandscape__c> competitorsMap = new map<string, CompetitiveLandscape__c>();
    //retrieve competitors related to the winning or losing accounts
    for(CompetitiveLandscape__c comp :[select Id, Competitor__c, Account__c
                        from CompetitiveLandscape__c
                        where Account__c = :winningAccount.Id Or Account__c =:losingAccount.Id]){
      if(comp.Account__c == winningAccount.Id){
        //collect winning account competitors
        winAcCompetitors.add(comp.Competitor__c.toLowerCase());
      }
      else if(comp.Account__c == losingAccount.Id){
        //collect losing account competitors
        losAcCompetitors.add(comp.Competitor__c.toLowerCase());
      }
      competitorsMap.put(comp.Id, comp);
    }
    //iterate over the collection and identify the dupes by competitor name
    for(Id key :competitorsMap.keySet()){
      CompetitiveLandscape__c tempComp = competitorsMap.get(key);
      //if the Competitor is both on the winning and losing account, then tag this as a dupe Competitor
      if(tempComp.Account__c == losingAccount.Id && winAcCompetitors.contains(tempComp.Competitor__c.toLowerCase()) && losAcCompetitors.contains(tempComp.Competitor__c.toLowerCase())){
        dupeCompetitorsList.add(tempComp);
      }
    }
    system.debug('^^competitorsDUPE ' + dupeCompetitorsList);
  }

  /**
  * @description delete duplicate partners
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void dedupePartners(){
    if(dupePartnersList.size() > 0){
      delete dupePartnersList;
    }
  }

  /**
  * @description retrieve partners and identify duplicates by matching account id (lookup field) between the winning and losing account.
  * @author Cloudsherpas
  * @date 01-13-2015
  * @last modified 01-15-2015
  */
  public void retrievePartners(){
    dupePartnersList = new List<RelatedPartner__c>();

    set<Id> winAcPartners = new set<Id>();
    set<Id> losAcPartners = new set<Id>();

    map<Id, RelatedPartner__c> partnersMap = new map<Id, RelatedPartner__c>();
    //retrieve partners related to the winning or losing accounts
    for(RelatedPartner__c par :[select Id, Partner__c, Account__c
                   from RelatedPartner__c
                   where Account__c = :winningAccount.Id Or Account__c =:losingAccount.Id]){
      if(par.Account__c == winningAccount.Id){
        //collect winning account partners
        winAcPartners.add(par.Partner__c);
      }
      else if(par.Account__c == losingAccount.Id){
        //collect losing account partners
        losAcPartners.add(par.Partner__c);
      }
      partnersMap.put(par.Id, par);
    }

    //iterate over the collection and identify the dupes by Account lookup
    for(Id key :partnersMap.keySet()){
      RelatedPartner__c tempPar = partnersMap.get(key);
      //if the Partner is both on the winning and losing account, then tag this as a dupe Partner
      if(tempPar.Account__c == losingAccount.Id && winAcPartners.contains(tempPar.Partner__c) && losAcPartners.contains(tempPar.Partner__c)){
        dupePartnersList.add(tempPar);
      }
    }
    system.debug('^^partnersDUPE ' + dupePartnersList);
  }

  /**
  * @description update surviving contacts. Update value for Primary billing, and Do Not Call / Email flags.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void updateContacts(){
    if(forUpdContactsList.size() > 0){
      system.debug('&&1 ' + forUpdContactsList );
      update forUpdContactsList;
    }
  }

  /**
  * @description delete duplicate contacts
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void dedupeContacts(){
    if(dupeContactsList.size() > 0){
      delete dupeContactsList;
    }
  }

  /**
  * @description retrieve contacts and identify dupes by matching First and Last name (case insensitive).
  * @author Cloudsherpas
  * @date 01-13-2015
  * @last modified 01-15-2015
  */

  public static List<Contact> contactQuery(Id winningAccId, Id losingAccId)
  {
    return
    [
      SELECT  Id, AccountId, DoNotCall, AlternateDoNotEmail__c, Email,
              Home_Customer_Requested_Do__c, Mobile_Customer_Requested_Do__c, FirstName, LastName,
              Phone, AssistantPhone, HomePhone, MobilePhone, HasOptedOutOfFax, HasOptedOutOfEmail,
              PrimaryBillingContact__c, PrimarySalesContact__c, PrimaryServiceContact__c
      FROM    Contact
      WHERE   AccountId =:winningAccId Or AccountId =:losingAccId
    ];
  }

  public void retrieveContacts()
  {
    dupeContactsList   = new List<Contact>(); //list of contacts for deletion (dupes)
    forUpdContactsList = new List<Contact>(); //list of contacts for update, removal of primary flag for losing none-dupe accounts.

    map<String, List<Contact>> winAccConMap = new map<String, List<Contact>>();
    map<String, List<Contact>> losAccConMap = new map<String, List<Contact>>();

    String fName;
    String name;

    //retrieve contacts related to the winning or losing accounts
    for(Contact con : contactQuery(winningAccount.Id, losingAccount.Id))
    {
      fName = String.isNotBlank(con.FirstName) ? con.FirstName : '';

        System.debug('first name is ' + con.FirstName + ' last name is ' + con.LastName );

      //build dupe identifier for contacts (FirstName + '-' + LastName)
      name = (fName + '-' + con.LastName).toLowerCase();
System.debug('name initially is ' + name);
      if(con.AccountId == winningAccount.Id) // winning acc con
      {
        if(winAccConMap.containsKey(name))
          winAccConMap.get(name).add(con);
        else
            System.debug('name in win is ' + name);
          winAccConMap.put(name, new List<Contact>{con});
      }
      else if(con.AccountId == losingAccount.Id) // losing acc con
      {
        if(losAccConMap.containsKey(name))
          losAccConMap.get(name).add(con);
        else
          losAccConMap.put(name, new List<Contact>{con});
      }
    }

    Contact tempCon;

    // iterate over list of losing account contacts
    // remove any primary flag tag from losing / non-duplicate contacts
    // dedupe / delete duplicate contacts via matching first name and last name

      System.debug('los key iss' + losAccConMap.keySet());
      System.debug('win key iss ' + winAccConMap.keySet());

      for(string key : losAccConMap.keySet())
    {
      if(winAccConMap.containsKey(key))
      {
        if(losAccConMap.get(key).size() > 1) // merge losing contact values for Do Not Call/Email flags.
          tempCon = mergeLosingContact(losAccConMap.get(key));
        else
          tempCon = losAccConMap.get(key)[0];

        // tag the losing account contacts for deletion
        dupeContactsList.addAll(losAccConMap.get(key));

        // update the winning account Do Not Call flags based on losing account data.
        for(Contact con : winAccConMap.get(key))
        {
          if(tempCon.DoNotCall && !con.DoNotCall)
            con.DoNotCall = true;

          if(tempCon.AlternateDoNotEmail__c && !con.AlternateDoNotEmail__c)
            con.AlternateDoNotEmail__c = true;

          if(tempCon.Home_Customer_Requested_Do__c && !con.Home_Customer_Requested_Do__c)
            con.Home_Customer_Requested_Do__c = true;

          if(tempCon.Mobile_Customer_Requested_Do__c && !con.Mobile_Customer_Requested_Do__c)
            con.Mobile_Customer_Requested_Do__c = true;


          // added by George Huene 2015-03-09
          if(tempCon.HasOptedOutOfFax && !con.HasOptedOutOfFax)
            con.HasOptedOutOfFax = true;

          if(tempCon.HasOptedOutOfEmail && !con.HasOptedOutOfEmail)
            con.HasOptedOutOfEmail = true;

          // added by George Huene 2015-02-25
          if(String.isNotBlank(tempCon.AssistantPhone) && String.isBlank(con.AssistantPhone))
            con.AssistantPhone = tempCon.AssistantPhone;

          if(String.isNotBlank(tempCon.MobilePhone) && String.isBlank(con.MobilePhone))
            con.MobilePhone = tempCon.MobilePhone;

          if(String.isNotBlank(tempCon.HomePhone) && String.isBlank(con.HomePhone))
            con.HomePhone = tempCon.HomePhone;

          if(String.isNotBlank(tempCon.Phone) && String.isBlank(con.Phone))
            con.Phone = tempCon.Phone;

          if(String.isNotBlank(tempCon.Email) && String.isBlank(con.Email))
            con.Email = tempCon.Email;
          // =================================

          forUpdContactsList.add(con);
        }
      }
      else
      {
        //unflag any primary non duplicate losing contacts
        for(Contact con :losAccConMap.get(key))
        {
          if(con.PrimaryBillingContact__c)
            con.PrimaryBillingContact__c = false;

          if(con.PrimarySalesContact__c)
            con.PrimarySalesContact__c = false;

          if(con.PrimaryServiceContact__c)
            con.PrimaryServiceContact__c = false;

          forUpdContactsList.add(con);
        }
      }
    }
      system.debug('<<dupeContactsList>>' + dupeContactsList);
      system.debug('<<forUpdContactsList>>' + forUpdContactsList);
    /*Code added for I-218867 by Deepanshu Soni Appirio, starts*/
     Set<Id> relatedContactsIdSet = new Set<Id>();
     Set<Id> dupeContactIdSet = new Set<Id>();
      for(Contact c: dupeContactsList)
      {
          dupeContactIdSet.add(c.Id);
      }
      system.debug('<<dupeContactIdSet>>' + dupeContactIdSet);
      //OPPORTUNITY
      for(Opportunity opp : [select Champion__c, Economic_Buyer__c, Lead_Contact__c from Opportunity where Champion__c IN :dupeContactIdSet OR Economic_Buyer__c IN :dupeContactIdSet OR Lead_Contact__c IN :dupeContactIdSet])
      {
          if(dupeContactIdSet.contains(opp.Champion__c))
          {
               relatedContactsIdSet.add(opp.Champion__c);
          }
          if(dupeContactIdSet.contains(opp.Economic_Buyer__c))
          {
               relatedContactsIdSet.add(opp.Economic_Buyer__c);
          }
          if(dupeContactIdSet.contains(opp.Lead_Contact__c))
          {
               relatedContactsIdSet.add(opp.Lead_Contact__c);
          }

      }
      // ORDER
      for(Order__c ord : [select AgencyBillingContact__c, BillingContact__c, Contact__c,Contact_for_Training__c, Posting_Contact__c,PrContact__c,Primary_Contact__c,Send_Welcome_Letter_to__c,ShippingContact__c from Order__c where AgencyBillingContact__c IN :dupeContactIdSet OR BillingContact__c IN :dupeContactIdSet OR Posting_Contact__c IN :dupeContactIdSet OR Contact_for_Training__c IN :dupeContactIdSet OR PrContact__c IN :dupeContactIdSet OR Contact__c IN :dupeContactIdSet OR Primary_Contact__c IN :dupeContactIdSet OR Send_Welcome_Letter_to__c IN :dupeContactIdSet OR ShippingContact__c IN :dupeContactIdSet])
      {
          if(dupeContactIdSet.contains(ord.AgencyBillingContact__c))
          {
               relatedContactsIdSet.add(ord.AgencyBillingContact__c);
          }
          if(dupeContactIdSet.contains(ord.BillingContact__c))
          {
               relatedContactsIdSet.add(ord.BillingContact__c);
          }
          if(dupeContactIdSet.contains(ord.Contact__c))
          {
               relatedContactsIdSet.add(ord.Contact__c);
          }
          if(dupeContactIdSet.contains(ord.Contact_for_Training__c))
          {
               relatedContactsIdSet.add(ord.Contact_for_Training__c);
          }
          if(dupeContactIdSet.contains(ord.Posting_Contact__c))
          {
               relatedContactsIdSet.add(ord.Posting_Contact__c);
          }
          if(dupeContactIdSet.contains(ord.PrContact__c))
          {
               relatedContactsIdSet.add(ord.PrContact__c);
          }if(dupeContactIdSet.contains(ord.Primary_Contact__c))
          {
               relatedContactsIdSet.add(ord.Primary_Contact__c);
          }
          if(dupeContactIdSet.contains(ord.Send_Welcome_Letter_to__c))
          {
               relatedContactsIdSet.add(ord.Send_Welcome_Letter_to__c);
          }
          if(dupeContactIdSet.contains(ord.ShippingContact__c))
          {
               relatedContactsIdSet.add(ord.ShippingContact__c);
          }

      }
      // QUOTE/PROPOSAL
      for(Apttus_Proposal__Proposal__c appc : [select AgencyBillingContact__c, BillContact__c, Contact__c,Contact_for_Training__c, PostingContact__c,PrContact__c,Apttus_Proposal__Primary_Contact__c,Primary_Customer_Contact__c,Send_Welcome_Letter_to__c from Apttus_Proposal__Proposal__c where AgencyBillingContact__c IN :dupeContactIdSet OR BillContact__c IN :dupeContactIdSet OR Contact__c IN :dupeContactIdSet OR Contact_for_Training__c IN :dupeContactIdSet OR PrContact__c IN :dupeContactIdSet OR PostingContact__c IN :dupeContactIdSet OR Apttus_Proposal__Primary_Contact__c IN :dupeContactIdSet OR Primary_Customer_Contact__c IN :dupeContactIdSet OR Send_Welcome_Letter_to__c IN :dupeContactIdSet])
      {
          if(dupeContactIdSet.contains(appc.AgencyBillingContact__c))
          {
               relatedContactsIdSet.add(appc.AgencyBillingContact__c);
          }
          if(dupeContactIdSet.contains(appc.BillContact__c))
          {
               relatedContactsIdSet.add(appc.BillContact__c);
          }
          if(dupeContactIdSet.contains(appc.Contact__c))
          {
               relatedContactsIdSet.add(appc.Contact__c);
          }
          if(dupeContactIdSet.contains(appc.Contact_for_Training__c))
          {
               relatedContactsIdSet.add(appc.Contact_for_Training__c);
          }
          if(dupeContactIdSet.contains(appc.PostingContact__c))
          {
               relatedContactsIdSet.add(appc.PostingContact__c);
          }
          if(dupeContactIdSet.contains(appc.PrContact__c))
          {
               relatedContactsIdSet.add(appc.PrContact__c);
          }if(dupeContactIdSet.contains(appc.Apttus_Proposal__Primary_Contact__c))
          {
               relatedContactsIdSet.add(appc.Apttus_Proposal__Primary_Contact__c);
          }
          if(dupeContactIdSet.contains(appc.Primary_Customer_Contact__c))
          {
               relatedContactsIdSet.add(appc.Primary_Customer_Contact__c);
          }
          if(dupeContactIdSet.contains(appc.Send_Welcome_Letter_to__c))
          {
               relatedContactsIdSet.add(appc.Send_Welcome_Letter_to__c);
          }

      }
      // CASE
      for(Case case1 : [select Contact.Id from Case where Contact.Id IN :dupeContactIdSet ])
      {
          if(dupeContactIdSet.contains(case1.Contact.Id))
          {
               relatedContactsIdSet.add(case1.Contact.Id);
          }

      }
      // EVENTS
      for(Event event1 : [select Who.Id from Event where Who.Id IN :dupeContactIdSet ])
      {
          if(dupeContactIdSet.contains(event1.Who.Id))
          {
               relatedContactsIdSet.add(event1.Who.Id);
          }

      }
      // TASKS
      for(Task task1 : [select Who.Id from Task where Who.Id IN :dupeContactIdSet ])
      {
          if(dupeContactIdSet.contains(task1.Who.Id))
          {
               relatedContactsIdSet.add(task1.Who.Id);
          }

      }
        system.debug('<<relatedContactsIdSet>>' + relatedContactsIdSet);
      Integer i = 0;
      for (i=0; i<dupeContactsList.size();)
      {
          if (relatedContactsIdSet.contains(dupeContactsList.get(i).Id))
          {
              system.debug('<<dupeContactsList.record>>' + dupeContactsList.get(i).Id);
              //forUpdContactsList.add(dupeContactsList[i]);
              dupeContactsList.remove(i);
          } else { i++; }
      }

    /*Code added for I-218867 by Deepanshu Soni Appirio, ends*/
    system.debug('^^contactsDUPE ' + dupeContactsList);
    system.debug('^^contactsDUPESIZE ' + dupeContactsList.size());
    system.debug('^^contactsUPD ' + forUpdContactsList);
    system.debug('^^contactsUPDSIZE ' + forUpdContactsList.size());
  }

  /**
  * @description if losing account also have duplicate contacts, combine the losing contact Do Not Call / Email flag values.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public Contact mergeLosingContact(List<Contact> conList)
  {
    Contact tempCon = new Contact();

    tempCon.DoNotCall = false;
    tempCon.AlternateDoNotEmail__c = false;
    tempCon.Home_Customer_Requested_Do__c = false;
    tempCon.Mobile_Customer_Requested_Do__c = false;

    //iterate over the list of contacts
    //as long as a Do Not flag field among any of the contacts is true, mark the field as true

    for(Contact con :conList)
    {
      if(con.DoNotCall && !tempCon.DoNotCall)
        tempCon.DoNotCall = true;

      if(con.AlternateDoNotEmail__c && !tempCon.AlternateDoNotEmail__c)
        tempCon.AlternateDoNotEmail__c = true;

      if(con.Home_Customer_Requested_Do__c && !tempCon.Home_Customer_Requested_Do__c)
        tempCon.Home_Customer_Requested_Do__c = true;

      if(con.Mobile_Customer_Requested_Do__c && !tempCon.Mobile_Customer_Requested_Do__c)
        tempCon.Mobile_Customer_Requested_Do__c = true;

      // added by George Huene 2015-03-09
      if(con.HasOptedOutOfFax && !tempCon.HasOptedOutOfFax)
        tempCon.HasOptedOutOfFax = true;

      if(con.HasOptedOutOfEmail && !tempCon.HasOptedOutOfEmail)
        tempCon.HasOptedOutOfEmail = true;

      // added by George Huene 2015-02-25
      if(String.isNotBlank(con.AssistantPhone) && String.isBlank(tempCon.AssistantPhone))
        tempCon.AssistantPhone = con.AssistantPhone;

      if(String.isNotBlank(con.MobilePhone) && String.isBlank(tempCon.MobilePhone))
        tempCon.MobilePhone = con.MobilePhone;

      if(String.isNotBlank(con.HomePhone) && String.isBlank(tempCon.HomePhone))
        tempCon.HomePhone = con.HomePhone;

      if(String.isNotBlank(con.Phone) && String.isBlank(tempCon.Phone))
        tempCon.Phone = con.Phone;

      if(String.isNotBlank(con.Email) && String.isBlank(tempCon.Email))
        tempCon.Email = con.Email;
      // =================================

    }
    return tempCon;
  }

  /**
  * @description delete duplicate xCodes
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void dedupeXCodes(){
    if(dupeXCodesList.size() > 0){
      delete dupeXCodesList;
    }
  }

  /**
  * @description retrieve xCodes and identify dupes by matching id (lookup on xCode) shared by the winning and losing account.
  * @author Cloudsherpas
  * @date 01-12-2015
  * @last modified 01-15-2015
  */
  public void retrieveXCodes(){
    dupeXCodesList = new List<XcodeAccount__c>();

    set<Id> winAcXCodes = new set<Id>();
    set<Id> losAcXCodes = new set<Id>();

    map<Id, XcodeAccount__c> xCodeMap = new map<Id, XcodeAccount__c>();
    //retrieve XCodes related to the winning or losing accounts
    for(XcodeAccount__c xc :[select Id, Xcode__c, Account__c
                 from XcodeAccount__c
                 where Account__c = :winningAccount.Id Or Account__c =:losingAccount.Id]){
      if(xc.Account__c == winningAccount.Id){
        //collect winning account xcodes
        winAcXCodes.add(xc.Xcode__c);
      }
      else if(xc.Account__c == losingAccount.Id){
        //collect losing account xcodes
        losAcXCodes.add(xc.Xcode__c);
      }
      xCodeMap.put(xc.Id, xc);
    }
    //iterate over the collection and identify the dupes by XCode
    for(Id key :xCodeMap.keySet()){
      XcodeAccount__c tempXC = xCodeMap.get(key);
      //if the XCode is both on the winning and losing account, then tag this as a dupe XCode
      if(tempXC.Account__c == losingAccount.Id && winAcXCodes.contains(tempXC.XCode__c) && losAcXCodes.contains(tempXC.XCode__c)){
        dupeXCodesList.add(tempXC);
      }
    }
    system.debug('^^xCodeDUPE ' + dupeXCodesList);
  }

  /**
  * @description losing account field value checks before executing the actual merge.
  * @author Cloudsherpas
  * @date 01-11-2015
  * @last modified 09-03-2015
  */
  public string validateAccounts(){
    System.debug('----validateAccounts');
    //verify that the accounts exists
    if(winningAccount == null){
      System.debug('----Label.CS_AccountMerge_Err_Winning_Account' + Label.CS_AccountMerge_Err_Winning_Account);
      return Label.CS_AccountMerge_Err_Winning_Account;

    }
    if(losingAccount == null){
      System.debug('----Label.CS_AccountMerge_Err_Losing_Account' + Label.CS_AccountMerge_Err_Losing_Account);
      return Label.CS_AccountMerge_Err_Losing_Account;
    }
    //verify that losing account does not have a Domestic HQ Account
    /* Commenting due to I-193088
    if(losingAccount.DomesticHQAccount__c != null){
      return Label.CS_AccountMerger_Err_Domestic_Account;
    }
    */
    //Customer/Lapsed Customer cannot merge to a Candidate
     // T-431249 - Minor update to validation
    if(winningAccount.AccountStatus__c == 'Candidate' && losingAccount.CustomerDate__c != null)
    {
      System.debug('----Label.CS_Account_Merge_Err_Account_With_Customer_Date_Cannot_be_Loser' + Label.CS_Account_Merge_Err_Account_With_Customer_Date_Cannot_be_Loser);
        return Label.CS_Account_Merge_Err_Account_With_Customer_Date_Cannot_be_Loser;
    }
    else if(
        // I-179322 : Basically "Candidate" accounts can never be the "winner" when merging with actual customers.
      (winningAccount.AccountStatus__c == 'Candidate' && losingAccount.AccountStatus__c == 'Customer') ||
      (winningAccount.AccountStatus__c == 'Candidate' && losingAccount.AccountStatus__c == 'Lapsed Customer')
      //(winningAccount.AccountStatus__c == 'Customer' && losingAccount.AccountStatus__c == 'Candidate') ||
      //(winningAccount.AccountStatus__c == 'Lapsed Customer' && losingAccount.AccountStatus__c == 'Candidate')
    ){
            System.debug('----Label.CS_AccountMerger_Err_Customer_To_Candidate' + Label.CS_AccountMerger_Err_Customer_To_Candidate);

      return Label.CS_AccountMerger_Err_Customer_To_Candidate;
    }

    //Losing Account cannot be merged if Do Not Merge flag is true
    if(losingAccount.DoNotMerge__c){
      System.debug('----Label.CS_AccountMerge_Err_Do_Not_Merge' + Label.CS_AccountMerge_Err_Do_Not_Merge);
      return Label.CS_AccountMerge_Err_Do_Not_Merge;// Edited by George Huene, 2015-02-04
    }

    String reparentError = reparentChildAccounts();

    if(reparentError != null)
      return reparentError;
      System.debug('----Label.CS_AccountMerge_Info_Success_Merge' + Label.CS_AccountMerge_Info_Success_Merge);
    return Label.CS_AccountMerge_Info_Success_Merge;
  }

   /**
  * @description take all the other accounts associated to that Entity ID of losing
  *              account and assign them to the "winning" accounts Entity ID
  * @author Parul Gupta
  * @date 09-01-2015
  * @task ref T-431240
  */
  private void updateEntityAssociatedAccounts(){
    List<Account> accountsToUpdate = new List<Account>();
    for (Account associatedAcc : [Select id, Registration__c from account where Registration__c =: losingRegistrationNumber]){
        associatedAcc.Registration__c = winningAccount.Registration__c;
        accountsToUpdate.add(associatedAcc);
    }
    if (accountsToUpdate.size() > 0){
        update accountsToUpdate;
    }
  }

  // Method returns account without createddate field
  private Account getAccountWithoutCreatedDate(Account acc){
    Account account = new Account(Id = acc.id, Name = acc.Name, OwnerId = acc.OwnerId, DomesticHQAccount__c = acc.DomesticHQAccount__c,
                        GlobalHQAccount__c = acc.GlobalHQAccount__c, ParentId = acc.ParentId, NewspaperStatus__c = acc.NewspaperStatus__c,
              IsGlobalHQ__c = acc.IsGlobalHQ__c, IsDomesticHQ__c = acc.IsDomesticHQ__c, DUNSNumber = acc.DUNSNumber, Score__c = acc.Score__c,
              AccountStatus__c = acc.AccountStatus__c, CreditStatus__c = acc.CreditStatus__c, RegistrationNumber__c = acc.RegistrationNumber__c ,
              DoNotMerge__c = acc.DoNotMerge__c, ShippingCountry = acc.ShippingCountry, PrimaryBillingContact__c = acc.PrimaryBillingContact__c, Lead_Account_Status__c = acc.Lead_Account_Status__c, 
              Registration__c = acc.Registration__c, CustomerDate__c = acc.CustomerDate__c, DateMerged__c = acc.DateMerged__c, Hierarchy_Locked__c = acc.Hierarchy_Locked__c, 
              Fax_Number_Mobile_Phone_Do_Not_call__c = acc.Fax_Number_Mobile_Phone_Do_Not_call__c , Fax_Number_National_Do_Not_Call__c = acc.Fax_Number_National_Do_Not_Call__c,
              FaxDoNotCall__c = acc.FaxDoNotCall__c ,Other_Phone_Mobile_Do_Not_Call__c = acc.Other_Phone_Mobile_Do_Not_Call__c, Other_Phone_National_Do_Not_Call_Registr__c = acc.Other_Phone_National_Do_Not_Call_Registr__c,
              OtherDoNotCall__c = acc.OtherDoNotCall__c, Phone_Mobile_Do_Not_Call__c = acc.Phone_Mobile_Do_Not_Call__c, Phone_National_Do_Not_Call_Registry__c = acc.Phone_National_Do_Not_Call_Registry__c,
              PhoneDoNotCall__c = acc.PhoneDoNotCall__c,OtherPhone__c = acc.OtherPhone__c,DoNotMail__c = acc.DoNotMail__c,JobPostzExpires__c = acc.JobPostzExpires__c, Fax = acc.Fax,ResumeExpires__c = acc.ResumeExpires__c, BillingAddressDoNotMail__c = acc.BillingAddressDoNotMail__c, PostingAddressDoNotMail__c = acc.PostingAddressDoNotMail__c, ShippingStreet = acc.ShippingStreet, ShippingCity = acc.ShippingCity, ShippingState = acc.ShippingState, ShippingPostalCode = acc.ShippingPostalCode,
              BillingCountry = acc.BillingCountry, BillingStreet = acc.BillingStreet, BillingCity = acc.BillingCity, BillingState = acc.BillingState, BillingPostalCode = acc.BillingPostalCode,AccountProgram__c = acc.AccountProgram__c);

      return account;
  }


  // Compare dates as earliest and recent

  private Date compareDates(Date winnerDate, Date loserDate, boolean IsEarliest){

        if(winnerDate == null && loserDate == null) {
            return null;
        }
        if(winnerDate == null || loserDate == null){
            if(winnerDate == null)
                return loserDate;
            else
                return winnerDate;
        }
        if(winnerDate != null && loserDate != null){
            if(IsEarliest) {
                if(loserDate < winnerDate)
                    return loserDate;
                else
                    return winnerDate;
            }
            else {
                if(loserDate > winnerDate)
                    return loserDate;
                else
                    return winnerDate;

            }
        }
        return null;
  }

  // Compare dates as earliest and recent

  private Datetime CompareDateTime(DateTime winnerDate, DateTime loserDate, boolean IsEarliest){

        if(winnerDate == null && loserDate == null) {
            return null;
        }
        if(winnerDate == null || loserDate == null){
            if(winnerDate == null)
                return loserDate;
            else
                return winnerDate;
        }
        if(winnerDate != null && loserDate != null){
            if(IsEarliest) {
                if(loserDate < winnerDate)
                    return loserDate;
                else
                    return winnerDate;
            }
            else {
                if(loserDate > winnerDate)
                    return loserDate;
                else
                    return winnerDate;

            }
        }
        return null;
  }

      /* Function added to update the Creditstatus of winning account
  if the CreditStatus of winning account has a lower priority than the CreditStatus of the losing account
  Priority List
    1.Fraud
    2.Terminated - Compliance
    3.Bankrupt
    4.On Hold - Both
    4.On Hold - Finance
    4.On Hold - Compliance
    5.Suspend
    6.PrePay Terms Required
    6.Approved PrePay
    7.Discretionary
    8.Progressive
    9.Ok
  I-195554 - Deepanshu Soni (Appirio)
  */
    public void checktCreditStatus(){

        map<String,Integer> priorityMap = new map<String,Integer>();
        priorityMap.put('Fraud', 1);
        priorityMap.put('Terminated - Compliance', 2);
        priorityMap.put('Bankrupt', 3);
        priorityMap.put('On Hold - Both', 4);
        priorityMap.put('On Hold - Finance', 4);
        priorityMap.put('On Hold - Compliance', 4);
        priorityMap.put('Suspend', 5);
        priorityMap.put('PrePay Terms Required', 6);
        priorityMap.put('Approved PrePay', 6);
        priorityMap.put('Discretionary', 7);
        priorityMap.put('Progressive', 8);
        priorityMap.put('Ok', 9);
        if(losingAccount.CreditStatus__c != null){
            if(winningAccount.CreditStatus__c != null){
                if((priorityMap.containsKey(winningAccount.CreditStatus__c)) && (priorityMap.containsKey(losingAccount.CreditStatus__c))){
                    if(priorityMap.get(winningAccount.CreditStatus__c) > priorityMap.get(losingAccount.CreditStatus__c)){

                        winningAccount.CreditStatus__c = losingAccount.CreditStatus__c;
                    }
                }
            }
            else{
                winningAccount.CreditStatus__c = losingAccount.CreditStatus__c;
            }
        }
    }
    /*
  S-445813
  When merging 2 accounts both with primary xcodes, only the winning account's primary xcode will
  remain primary.
  */
  public void onlyOnePrimary() {
    XcodeAccount__c[] xcodeacct = [select Id, Xcode__c, Account__c
                 from XcodeAccount__c
                 where Account__c = :winningAccount.Id];
    if(xcodeacct.size() > 1) {
      for(Integer i=1; i<xcodeacct.size(); i++) {
        xcodeacct[i].IsPrimary__c = false;
      }
      update xcodeacct;
    }
  }

  /*
** @author : Cloud Sherpas Inc.
** @date : 07/03/2014
** @description :  called by onAfterDelete in XCodeAccountTriggerHandler
** @paramaters : an array of XcodeAccount__c objects
** @returns : nothing
*/
    public static void DeletingOfPrimaryXCodeImplemention(XcodeAccount__c[] pXcodeAccountList){

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
            System.debug('Primary XCodeAccount delete logic failed. - please see system log for details.' + e);
        }
    }

}