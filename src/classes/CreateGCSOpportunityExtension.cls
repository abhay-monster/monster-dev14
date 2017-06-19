/******************************************************************************************
 *  Name    : CreateGCSOpportunityExtension
 *  Purpose : Extension of VF page CreateGCSOpportunity to prepolate a Custom Field
 *  Author  : Gaurav Gupta
 *  Date    : 2015-07-21
 *  Version : 1.0
 *
 *  Modification History
 *  Date  Who   Description
 *
 ********************************************************************************************/
public class CreateGCSOpportunityExtension{

       public Apttus_Proposal__Proposal__c accountProposal {get;set;}
       //public Apttus_Proposal__Proposal__c proposal {get;set;}
       public List<RelatedPartner__c> relatedPartnerList = new List<RelatedPartner__c>();
       public string selectPartnerId {get;set;}
       //public Account proposalAccount {get;set;}
       public Opportunity opportunity {get;set;}
       public boolean IsNewsPaperrecordType {get;set;}
       

       public map<string,string> mapPartner = new map<string,string> ();

       public List<SelectOption> partnerListOptions {
            get{
                    if(partnerListOptions == null){
                       partnerListOptions  = new List<SelectOption>();
                       SelectOption option = new SelectOption('None', '---None---');
                       partnerListOptions.add(option);
                       for(RelatedPartner__c partner : [SELECT Id, Partner__r.Name, Account__c, Partner__c FROM RelatedPartner__c 
                                                        WHERE Account__c = :accountProposal.Apttus_Proposal__Account__c
                                                        AND Partner__c != null]){

                            option = new SelectOption(partner.Partner__c, partner.Partner__r.Name);
                            mapPartner.put(partner.Partner__c, partner.Id);
                            partnerListOptions.add(option);
                        }
                    }
                    return partnerListOptions;
                }set;
        } 

        String priceListLabel ;

        public CreateGCSOpportunityExtension(){ 

            //accountProposal  = (Apttus_Proposal__Proposal__c )con.getRecord();
            Id proposalId = ApexPages.CurrentPage().getParameters().get('Id'); 
            System.debug('@@==proposalId===='+proposalId);
            IsNewsPaperrecordType = false;
            selectPartnerId = null;
            accountProposal = [Select Id,Site_Channel_ID__c,
                                        APTS_Quote_Type__c ,order_type__c,
                                        Agency__c,Apttus_Proposal__Account__c,Apttus_QPConfig__PriceListId__c,RecordTypeId,
                                        Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c Where Id = :proposalId];

            opportunity = [Select Id,APTS_Related_Partner__c,Agency__c from Opportunity Where Id = :accountProposal.Apttus_Proposal__Opportunity__c]; 

            User U = [select UserDefaultPriceList__c from User where Id = :Userinfo.getUserId()];

            if(U.UserDefaultPriceList__c != null)
                priceListLabel = U.UserDefaultPriceList__c;
            else 
                priceListLabel = Label.USD_Price_List_Label ;
           
            if(priceListLabel  != null){  
                List<Apttus_Config2__PriceList__c> priceList = [select id from Apttus_Config2__PriceList__c where Name = :priceListLabel];
             
                if(priceList.size()>0)
                    accountProposal .Apttus_QPConfig__PriceListId__c = priceList[0].id; 

            }

          accountProposal.RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
                // Changes start : I-199130
                //accountProposal.APTS_Quote_Type__c ='GCS Opportunity';
                // Changes End: I-199130

        }
        
       public PageReference findPartner(){
            if(Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Newspaper Partner').getRecordTypeId() == accountProposal.RecordTypeId){
                IsNewsPaperrecordType = true;
            }
            else {
                IsNewsPaperrecordType = false;
                selectPartnerId = null;
            }
            return null;
       }

       public PageReference Save(){

            System.debug('@@==selectPartnerId===='+selectPartnerId);
            System.debug('@@==mapPartner===='+mapPartner);

            if(selectPartnerId != null){
                // Set Opportunity's APTS_Related_Partner__c with selected Partner__c
                if(mapPartner.containsKey(selectPartnerId)){
                    opportunity.APTS_Related_Partner__c = mapPartner.get(selectPartnerId);
                }

                // Set Site Channel ID : To populate this field we need to query the Partner_Revenue_Share__c 
                //object where Partner__c = to the Opportunity.APTS_Related_Partner__c and grab the SiteChannelID__c
                for(Partner_Revenue_Share__c partnerRevenueShare : [Select Id, Partner__c, SiteChannelID__c from Partner_Revenue_Share__c 
                                                                    Where Partner__c = :selectPartnerId] ) {

                   accountProposal.Site_Channel_ID__c =  partnerRevenueShare.SiteChannelID__c;

                }
                


                // Set Owner Id of Quote with aprtner account id
                for(Account partnerAcc : [Select ownerId,Id,AgencyFlag__c,Partner_Flag__c,CreditStatus__c from Account Where Id = :selectPartnerId]) {
                   // Set Agency field on Opportunity with selected partner Id as per T-424274
                   // When Account match the lookupfilter criteria
                   if( (partnerAcc.AgencyFlag__c || partnerAcc.Partner_Flag__c) && (partnerAcc.CreditStatus__c == '' || partnerAcc.CreditStatus__c == null || partnerAcc.CreditStatus__c =='Ok')) {
                    opportunity.Agency__c = selectPartnerId;    
                   } 
                  // Set Agency on Quote/Proposal
                  accountProposal.Agency__c = selectPartnerId; 
                  accountProposal.ownerId = partnerAcc.ownerId;
                }
                
                for(User usr : [Select id, PositionSalesChannel__c From User Where Id =:accountProposal.ownerId]){
                    accountProposal.SalesChannel__c = usr.PositionSalesChannel__c;                 
                }
                

                
                System.debug('@@==accountProposal.Site_Channel_ID===='+accountProposal.Site_Channel_ID__c);                
                update opportunity; 
                
                if(Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Newspaper Partner').getRecordTypeId() == accountProposal.RecordTypeId){
                    accountProposal.Order_Type__c = 'Upsell'; 
                }else if (Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('GCS Proposal').getRecordTypeId() == accountProposal.RecordTypeId){
                    accountProposal.Order_Type__c = 'Non-Revenue'; 
                }
                          
                update accountProposal;
                return new PageReference('/' + accountProposal.Id + '/e?retURL=%2F' + accountProposal.id);
           }
           else if(accountProposal.RecordTypeId != null) {
                if(Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Newspaper Partner').getRecordTypeId() == accountProposal.RecordTypeId){
                    accountProposal.Order_Type__c = 'Upsell'; 
                }else if (Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('GCS Proposal').getRecordTypeId() == accountProposal.RecordTypeId){
                    accountProposal.Order_Type__c = 'Non-Revenue'; 
                }
           
                update accountProposal;
           }
           
                Apttus_Proposal__Proposal__c p = [select APTS_Quote_Type__c ,order_type__c from Apttus_Proposal__Proposal__c  where id = :accountProposal.Id ];
                //system.assert(false , p);
           
           return new PageReference('/' + accountProposal.Id);
         
       }

       public PageReference Cancel(){
           return new PageReference('/' + accountProposal.Id);
       }



    }