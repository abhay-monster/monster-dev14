public class AddContactController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public Integer rowLimit{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Contact> conlist{get;set;}
    public List<Apttus_Proposal__Proposal_Line_Item__c> lineItemList{get;set;}
    public List<Contact> conlistFromAttach{get;set;}
    public String urlId{get;set;}
    public String proId{get;set;}
    public String accId{get;set;}
    public String proName{get;set;}
    public String[] lineIdList{get;set;}
    public Attachment att{get;set;}
    public Boolean isDisable{get;set;}
    public Boolean saveDisable{get;set;}
    public List<String> proNames {get;set;}
    @TestVisible public List<wrapperC> wc{get;set;}
    public String[] debugger{get;set;}
    public Boolean closeWindow {get;set;}
     public string userLangString { get{return ApexPages.currentPage().getHeaders().get('Accept-Language');  } set; }
    
    @TestVisible public class wrapperC{

      public String prodName {get; set;}
      public Contact conlist2 {get; set;}
      public String quoteItemId {get; set;}
      //public String orderItemId {get; set;}
      
    }
    // Added by Divino Brinas on Dec 04 2014
    // Story 1783,2895
    public List<Id> contactIdNewlyCreated; 
    public List<ProductUserQuoteLine2OrderLine__c> proposalIdsFromOrderItems;
    //this map is used when uploading a csv, it will create a map of contacts to their products
    private Map<Id,Apttus_Proposal__Proposal_Line_Item__c> contactIdToProduct;
    public AddContactController(){
      system.debug('language test?');
      system.debug(ApexPages.currentPage().getHeaders().get('Accept-Language'));

      for(String header : ApexPages.currentPage().getHeaders().keySet()){
        system.debug('header: ' + header);
      }
        debugger = new  String[]{};
        //try{
            urlId =  ApexPages.currentPage().getParameters().get('ProposalId');
            Id sObjectId = ApexPages.currentPage().getParameters().get('ProposalId');
            Schema.SObjectType token = sObjectId.getSobjectType();
            // Object Name references instead of hardCoded id number
            String objQuote = 'Apttus_Proposal__Proposal__c';
            String objQuoteItem = 'Apttus_Proposal__Proposal_Line_Item__c';
            String objOrderItem = 'Order_Line_Item__c';
            
            String finalTokenName;
            String finalTokenPrefix;
            proposalIdsFromOrderItems = new List<ProductUserQuoteLine2OrderLine__c>();
            System.debug('token >>>>>' +  token);
            wc = new list<wrapperC>();
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Map<String,String> keyPrefixMap = new Map<String,String>{};
            Set<String> keyPrefixSet = gd.keySet();
            // Select all GlobalDescribe and find the equivalent object name accordingly
            for(String sObj : keyPrefixSet){
              Schema.DescribeSObjectResult r = gd.get(sObj).getDescribe();
              String tempName = r.getName();
              String tempPrefix = r.getKeyPrefix();
              System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
              if(urlId.substring(0,3).equals(tempPrefix) ){
                  finalTokenName=tempName;
                  finalTokenPrefix=tempPrefix;
                  break;
                }else if(urlId.substring(0,3).equals(objQuoteItem) ){
                  finalTokenName=tempName;
                  finalTokenPrefix=tempPrefix;
                  break;
                }else if(urlId.substring(0,3).equals(objOrderItem) ){
                  finalTokenName=tempName;
                  finalTokenPrefix=tempPrefix;
                  break;
                }
            }

            
            //a0m=proID; a0k=lineItem; a44=orderItem
            if(finalTokenName.equals(objQuote) ){
            //if(urlId.startsWith('a0m') ){
                 proId = urlId.substring(0,15);
                 urlId = urlId.substring(0,15);
                 system.debug('finalTokenName >>>' + finalTokenName + '===> ' + proId);
                 lineItemList = [SELECT Product_or_Option_Name__c,ProductName__c, Apttus_Proposal__Product__r.Name
                                        , Apttus_Proposal__Product__r.Family, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Id 
                                   FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c =: proId];
            }
            else if(finalTokenName.equals(objQuoteItem) ){
            //else if(urlId.startsWith('a0k') ){
                   urlId = urlId.substring(0,15);
                   lineItemList = [SELECT Product_or_Option_Name__c,ProductName__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Proposal__c
                                          , Apttus_Proposal__Product__r.Family, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Id 
                                     FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id =: urlId];  
                   system.debug('finalTokenName >>>' + finalTokenName);
                   proId = lineItemList[0].Apttus_Proposal__Proposal__c;
            }
            else if(finalTokenName.equals(objOrderItem) ){
            //else if(urlId.startsWith('a44')  ){
                  urlId = urlId.substring(0,15);
                  proposalIdsFromOrderItems = new List<ProductUserQuoteLine2OrderLine__c>();
                  List<ProductUserQuoteLine2OrderLine__c> quoteToOrderList= [SELECT Proposal_Line_Item__c 
                                                                           FROM ProductUserQuoteLine2OrderLine__c
                                                                          WHERE Order_Line_Item__c =: urlId];
                  for(ProductUserQuoteLine2OrderLine__c oQuote2Order : quoteToOrderList){
                      proposalIdsFromOrderItems.add(oQuote2Order);
                  }
                  system.debug('finalTokenName >>>' + finalTokenName);
                  lineItemList = [SELECT Product_or_Option_Name__c,ProductName__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Proposal__c
                                          , Apttus_Proposal__Product__r.Family, Apttus_QPConfig__Quantity2__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Id 
                                     FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Id =: proposalIdsFromOrderItems[0].Proposal_Line_Item__c];  
              proId = lineItemList[0].Apttus_Proposal__Proposal__c;
            }
            /*if(UserInfo.getUserType() == 'Guest' && ApexPages.currentPage().getCookies().get('lang') != null){ // lang is a custom cookie defined.
                           
                    Cookie userLang = ApexPages.currentPage().getCookies().get('lang');
                    userLangString = userLang.getValue();
             }
            
             if(UserInfo.getUserType() != 'Guest'){
                String userlang = [select LanguageLocaleKey from User where Id=:UserInfo.getUserId()].LanguageLocaleKey;
             }    */        
            
            refreshPage();
        /*} catch (Exception e){ 
            //debugger.add('ERROR: ' + e);
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred in attempting to add users. Please make sure to use the downloaded template or the file format is .csv');
            ApexPages.addMessage(errorMessage);
        } */
       
        
    }

    public Pagereference refreshPage(){
        
        csvFileLines = new String[]{};
        conlist = New List<Contact>();
        proNames = new List<String>();
        set<String> setCustomSettings = new set<String>();
        // Get all product family values from custom setting
        for(Product_User_Families__c rec : Product_User_Families__c.getAll().values()){
            setCustomSettings.add(rec.Name);
        }

        for(Apttus_Proposal__Proposal_Line_Item__c lineItem : lineItemList){
            accId = lineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c;
            proName = lineItem.ProductName__c;
            proNames.add(proName);
            System.debug('lineItemId==='+lineItem.Id+'lineItem.Apttus_Proposal__Product__r.Family====='+lineItem.Apttus_Proposal__Product__r.Family);
            
            if(lineItem.Apttus_Proposal__Product__r.Family != null && setCustomSettings.contains(lineItem.Apttus_Proposal__Product__r.Family)){

                rowLimit = lineItem.Apttus_QPConfig__Quantity2__c.intValue();
                for(Integer j=1;j<=rowLimit;j++){
                    wrapperC AE = new wrapperC();
                    AE.prodName = proName;
                    AE.conlist2 = new Contact(AccountId = lineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,
                                          ProposalLineItem__c = lineItem.Id, FirstName = '', LastName= '', Phone = '', Email = '');

                    //added by DinoBrinas
                    AE.quoteItemId = lineItem.id;
                    
                    wc.add(AE);
                    
                }
            } /*else {
                  wrapperC AE = new wrapperC();
                  AE.prodName = proName;
                  AE.conlist2 = new Contact(AccountId = lineItem.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,
                                          ProposalLineItem__c = lineItem.Id, FirstName = '', LastName= '', Phone = '', Email = '');
                  //added by DinoBrinas
                  AE.quoteItemId = lineItem.id;
                           
                  wc.add(AE);


            }  */
        }

        if(wc.size() > 10){
            wc = new list<wrapperC>();
            isDisable = false;
            saveDisable = true;
        } else {
            isDisable = true;
            saveDisable = false;
        }
        //system.assert(false , wc);
        
        /*Cookie c = new Cookie('lang', userLangString,null,-1,true);
                    ApexPages.currentPage().setCookies(new Cookie[]{c});*/

    PageReference p = ApexPages.currentPage();
    p.setRedirect(true);
    return p;
    }

    /*
    public void attachFile(){
      try{
        csvAsString = csvFileBody.toString();
        att = new Attachment();
        att.OwnerId = UserInfo.getUserId();
        att.ParentId = lineItemId;// example '0031100000Xu2aX'
        att.IsPrivate = true;
        
        att.Name = 'Contacts for Proposal Line Item';

        if(csvAsString != ''){
          att.Body = csvFileBody;
          insert att;
        } else {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please select a csv file');
            ApexPages.addMessage(errorMessage);
        }

      } catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred in attempting to add users. Please make sure all fields are populated with valid data');
            ApexPages.addMessage(errorMessage);
      } finally {
            att = new Attachment();
      }

    }*/

  public void importCSVFile(){
       try{
           debugger = new  String[]{};
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           conlistFromAttach = new List<Contact>(); 
           for(Integer i=1;i<csvFileLines.size();i++){
               Contact newCOntact = new Contact() ;
               string[] csvRecordData = csvFileLines[i].split(',');
               //Jeff L added the replace function, otherwise everything is wrapped in ""
               String lineItem = csvRecordData[5].replace('"','');
               newCOntact.Product__c = csvRecordData[0].replace('"','') ;
               newCOntact.FirstName = csvRecordData[1].replace('"','') ;             
               newCOntact.LastName = csvRecordData[2].replace('"','');
               newCOntact.Email = csvRecordData[3].replace('"','');
               newCOntact.Phone = csvRecordData[4].replace('"','');   
               newCOntact.ProposalLineItem__c =  lineItem.deleteWhitespace(); 
               newCOntact.AccountId = accId;
               newCOntact.CurrencyIsoCode = 'USD';
               newCOntact.InvoiceDeliveryMethod__c = 'Email';
               newCOntact.PrimaryPhoneNumber__c = 'Work';                                                                           
               conlistFromAttach.add(newCOntact);
           }
           if(conlistFromAttach.size() > 0){
              //insert conlistFromAttach;
              wc = dupeCheck(conlistFromAttach);

              if(proposalIdsFromOrderItems.size() > 0){
              System.debug('proposalIdsFromOrderItems >>>>>' + proposalIdsFromOrderItems);
              CreatesJunctionRecordForOrderItem();
            } else{
              CreatesJunctionRecord();  
            }
              closeWindow = true;
           }
        } catch (Exception e){ 
            debugger.add('ERROR: ' + e);
            system.debug('Exception at 237' + e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occurred in attempting to add users. Please make sure to use the downloaded template or the file format is .csv');
            ApexPages.addMessage(errorMessage);
        } 
  }

 
  public pageReference  SaveContact(){
      List<Contact> contactToInsert = new List<Contact>();
      debugger = new  String[]{};
     try{
        for(wrapperC wr : wc){
          system.debug('wrapperC:::SaveContact '+wr);
          Contact newCon = new Contact();
          if(wr.conlist2.FirstName != null && wr.conlist2.LastName != null && wr.conlist2.Email != null && wr.conlist2.Phone != null){
            wr.conlist2.CurrencyIsoCode = 'USD';
            wr.conlist2.InvoiceDeliveryMethod__c = 'Email';
            wr.conlist2.PrimaryPhoneNumber__c = 'Work';
            newCon = wr.conlist2;
            contactToInsert.add(newCon);
          } else {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Fill up all required fields');
                ApexPages.addMessage(errorMessage);
            }
        }
        //system.assert(false ,contactToInsert );
        
        if(contactToInsert.size() > 0){
            System.debug('+++Contacts : '+contactToInsert);

            //insert contactToInsert;
            wc = dupeCheck(contactToInsert);
            
            // Added by DinoBrinas
            // This method is use to create records on junctionObject.
            if(proposalIdsFromOrderItems.size() > 0){
              System.debug('proposalIdsFromOrderItems >>>>>' + proposalIdsFromOrderItems);
              CreatesJunctionRecordForOrderItem();
            } else{
              System.debug('contactToInsert >>>>' + contactToInsert);
              CreatesJunctionRecord();  
            }
            
           closeWindow = true;
        }
      }catch(DMLException e){
        debugger.add('ERROR: ' + e);
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occurred in attempting to add users. Please make sure all fields are populated with valid data');
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, wc + e.getMessage());
            system.debug(e.getLineNumber()+ 'An error has occurred in attempting to add users. Please make sure all fields are populated with valid data');
            ApexPages.addMessage(errorMessage);
      }
      return null;
  }
  public void Cancel(){
  }

  /***
  @author Divino Brinas
  @date 12/04/2014
  @story 1783 E2243
  @description Populates the prefered contact based on the value of the a similar Lookup in the
  related line items. This only happens if the save button from AddContact.page is clicked.
  First, get all contactID that just have created and populate it to contactIds.
  Then call in the CreatesContactRecord() method to create Line Items(Quote/Order).
      a. Get Proposal ID on the URL
      b. Get the Quote Line Item on the page
      c. Get all contact ids that are associated to QuoteLineItem Ids.
  ***/
  
  // Method: CreatesJunctionRecord()
  // Saves all contacts that that are related to all Line Item
  public void CreatesJunctionRecord(){
    List<ProductUserQuoteLine2OrderLine__c> lQuoteToOrder = new List<ProductUserQuoteLine2OrderLine__c>();
    // Iterate all values that user have enter on the AddContact.page
    for(wrapperC wr : wc){
      if(wr.conlist2.id != null ){
        system.debug('wrapperC:::1 '+wr);
        ProductUserQuoteLine2OrderLine__c quoteToOrder = new ProductUserQuoteLine2OrderLine__c();
        System.debug('wr.quoteItemId.subString(0,15) >>>>>>' + wr.quoteItemId.subString(0,15));
        // Populate the quoteOrder object on Contact_Name__c
        quoteToOrder.Contact_Name__c = wr.conlist2.id;
        // Populate the quoteOrder object on QuoteName
        quoteToOrder.Quote_Proposal__c = proId;
        // Populate the quoteOrder object on QuoteLineItem
        quoteToOrder.Proposal_Line_Item__c = wr.quoteItemId.subString(0,15);
        lQuoteToOrder.add(quoteToOrder);
      }
    }
    System.debug('lQuoteToOrder >>>>>>' + lQuoteToOrder);
    // When the  lQuoteToOrder has data, insert it to junctionObject
    if(lQuoteToOrder.size() > 0){
      //try{
        insert lQuoteToOrder;
      /*}catch(DMLException e){
        debugger.add('ERROR: ' + e);
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred in attempting to add users. Please make sure all fields are populated with valid data');
        ApexPages.addMessage(errorMessage);
      } */
    }
  }
  public void CreatesJunctionRecordForOrderItem(){
    List<ProductUserQuoteLine2OrderLine__c> lQuoteToOrder = new List<ProductUserQuoteLine2OrderLine__c>();
    // Iterate all values that user have enter on the AddContact.page
    for(wrapperC wr : wc){
      system.debug('wrapperC:::2 '+wr);
      if(wr.conlist2.id != null ){
        ProductUserQuoteLine2OrderLine__c quoteToOrder = new ProductUserQuoteLine2OrderLine__c();
        System.debug('wr.quoteItemId.subString(0,15) >>>>>>' + wr.quoteItemId.subString(0,15));
        // Populate the quoteOrder object on Contact_Name__c
        quoteToOrder.Contact_Name__c = wr.conlist2.id;
        // Populate the quoteOrder object on QuoteName
        quoteToOrder.Quote_Proposal__c = proId;
        // Populate the quoteOrder object on QuoteLineItem
        quoteToOrder.Proposal_Line_Item__c = wr.quoteItemId.subString(0,15);
        // Populate to the list of junction variable
        quoteToOrder.Order_Line_Item__c = urlId.subString(0,15);
        lQuoteToOrder.add(quoteToOrder);
      }
    }
    System.debug('lQuoteToOrder >>>>>>' + lQuoteToOrder);
    // When the  lQuoteToOrder has data, insert it to junctionObject
    if(lQuoteToOrder.size() > 0){
      //try{
        insert lQuoteToOrder;
      /*}catch(DMLException e){
        debugger.add('ERROR: ' + e);
        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred in attempting to add users. Please make sure all fields are populated with valid data');
        ApexPages.addMessage(errorMessage);
      } */
    }
  }

  /**
 * Appirio, Inc
 * Name             : dupeCheck
 * Created Date     : 05 Nov 2015 
 * Created By       : Jeff Lescarbeau (Appirio)
 * Description      : checks based upon set formula if there are duplicates inside of SFDC before inserting contacts
 * Params           : list of contacts to be inserted and checked for dupes
 * Returns          : returns a list of contacts (newly inserted or the duplicates if any were found)
   */
  private List<wrapperC> dupeCheck(List<Contact> contactList){

    List<Contact> returnContactList = new List<Contact>();
    Map<String,Contact> contactMatchMap = new Map<String,Contact>();
    List<wrapperC> returnWrapper = new List<wrapperC>();
    contactIdToProduct = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>(); 
    String dupeQuery = 'Select Id, FirstName, LastName, Email, Phone from Contact Where ';
    boolean first = true;
    for(Contact c : contactList){
      if(first){
        dupeQuery+= '(FirstName=\'' + c.FirstName +'\' '; 
          first=false;
      } else {
        dupeQuery+= 'OR (FirstName=\'' + c.FirstName +'\' '; 
      }
      dupeQuery+= 'AND LastName=\'' + c.LastName +'\' '; 
      dupeQuery+= 'AND Email=\'' + c.Email + '\' ';
      dupeQuery+= 'AND Phone=\'' +c.Phone + '\') ';

      contactMatchMap.put(c.FirstName + c.LastName + c.Email +c.Phone, c);
      system.debug('::: contactMatchMap '+contactMatchMap);

    }
    //now that our query has been put together lets iterate through the contacts returned and see if we find any matches
    system.debug(dupeQuery);
    List<Contact> dupeQueryContacts = database.query(dupeQuery);
    system.debug('::: dupeQueryContacts '+dupeQueryContacts);
    if(dupeQueryContacts.size() > 0){
      for(Contact c : dupeQueryContacts){
        String matchKey = c.FirstName + c.LastName + c.Email +c.Phone;
        //if it contains our matching key, then we need to add the queried contact to our return list
        //as well as remove the contact from our map - since we will use that to insert new contacts 
        if(contactMatchMap.containsKey(matchKey)){
          Contact matchC = contactMatchMap.get(matchKey);

          wrapperC wc = new wrapperC();
          wc.conlist2 = c;
          wc.prodName = matchC.product__c;
          wc.quoteItemId = matchC.ProposalLineItem__c;
          returnWrapper.add(wc);
          system.debug('::: wrapper returnWrapper '+returnWrapper);
          contactMatchMap.remove(matchKey);
        }
      }
    }

    //Now that we have done our duplicate matching it is now time to insert the new contacts.
    List<Contact> insertList = new List<Contact>();
    insertList.addAll(contactMatchMap.values());
    List<Database.SaveResult> res;
    //system.assert(false , insertList);
    if(!insertList.isEmpty()){
      ContactTriggerHandler.ExecuteTriggers = false;
      res = Database.insert(insertList, false);
      
      system.debug('check >>>>>>>' + res );
      ContactTriggerHandler.ExecuteTriggers = true;
      
      
      
      // GG --- for(Contact c : insertList){
      for(Contact c : contactList){
        system.debug('Contact Id test ' + c.Id);
        String matchKey = c.FirstName + c.LastName + c.Email +c.Phone;
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>> Match Key' + matchKey );
        Contact matchC = contactMatchMap.get(matchKey);

        wrapperC wc = new wrapperC();
        wc.conlist2 = matchC;
        wc.prodName = matchC.product__c ;
       // wc.quoteItemId = matchC.ProposalLineItem__c;*/
       // wc.prodName = c.product__c + matchC.Id;
        wc.quoteItemId = c.ProposalLineItem__c;
        

        returnWrapper.add(wc);
      }
      //now add the newly inserted contacts into our return contact list
      ContactList.addAll(insertList);
    }
    system.debug('>>>>>>>>>>>>>>>>>>>>>>>> Return Wrapper' + returnWrapper);
    return returnWrapper;
  }
}