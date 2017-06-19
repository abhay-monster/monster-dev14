public with sharing class LicenseViewCC {
  private final Integer MAX_LICENSE = 20;
  private Integer CurrentPage;

  public List<SelectOption> getPageOptions() {
    List<SelectOption> options = new List<SelectOption>();
    for(Integer i = 1; i <= TotalPage; i++){
      options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
    }
    return options;
  }
  public String NewPage {get; set;}

  public Integer TotalPage {get{
    Double result;
    if(licenseInfoList != null && !licenseInfoList.isEmpty()){
      result = Math.ceil(Double.valueOf(licenseInfoList.size()) / Double.valueOf(MAX_LICENSE));
      result = result == 0 ? 1 : result;
    }else{
      return 1;
    }
    return Integer.valueOf(result);
  }}

  private Id AccountID;

  public String SelectedXcodeId {get; set;}
  private Id PrevSelectedXcodeId;

  public XcodeWrap[] XcodeWrapList {get; set;}
  private map<Id, XcodeWrap> XcodeWrapMap;

  public String LicenseTable {get; set;}

  public List<SelectOption> getViews() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('InventoryView','Job Inventory'));
    options.add(new SelectOption('EnhancementsView','Job Enhancement'));
    options.add(new SelectOption('ResumeUsageView','Resume Inventory'));
    //options.add(new SelectOption('ItemInventoryView','Item Inventory View'));
    return options;
  }
  public Boolean LicenseTableReady {get; private set;}

  public String LicenseView {get; set;}
  private String CurrentXcode;

  private v3_schemasDatacontractOrg200407Monster.LicenseInfo[] licenseInfoList;

  public LicenseViewCC(){
    if(ApexPages.currentPage().getParameters().containsKey('AccountID')){
      AccountID = ApexPages.currentPage().getParameters().get('AccountID');
      init();
    }else{
      AddPageError('Required parameter missing: No Account ID');
    }
  }

  public PageReference Back(){
    if(AccountID != null){
      return new PageReference('/' + AccountID);
    }
    return new PageReference('/' + Schema.Sobjecttype.Account.getKeyPrefix());
  }

  public void SelectXcode(){
    // LicenseTableReady = false;
    LicenseTableReady = true;

    //remove previous selected radio button
    if(PrevSelectedXcodeId != null){
      XcodeWrap pxw = XcodeWrapMap.get(PrevSelectedXcodeId);
      if(pxw != null){
        pxw.Radio = '<input onclick="SelectRadio(this);" name="selector" type="radio" class="radio-select" value="'+pxw.xcodeAccount.Id+'" />';
      }
    }

    //mark selected radio button
    SelectedXcodeId = ApexPages.currentPage().getParameters().get('SelectedXcodeId');
    if(SelectedXcodeId != null){
      PrevSelectedXcodeId = Id.valueOf(SelectedXcodeId);
      XcodeWrap xw = XcodeWrapMap.get(PrevSelectedXcodeId);
      System.debug('PrevSelectedXcodeId: '+PrevSelectedXcodeId);
      if(xw != null){
        xw.Radio = '<input onclick="SelectRadio(this);" name="selector" type="radio" checked="checked" class="radio-select" value="'+xw.xcodeAccount.Id+'" />';
        LicenseView = 'InventoryView';
        getLicenses(LicenseView, xw.xcodeAccount.Xcode__r.Name);
      }
    }
  }

  public void ChangePage(){
    try{
      CurrentPage = Integer.valueOf(NewPage);
      createLicenseTable();
    }catch(Exception e){
      LicenseTable = 'An error occured.';
      system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
    }
  }

  public void ChangeView(){
    if(LicenseView != null && CurrentXcode != null){
      getLicenses(LicenseView, CurrentXcode);
    }
  }

  private void init(){
    try{
      LicenseTable = '&nbsp;Please select xcode.';
      LicenseTableReady = false;

      XcodeAccount__c[] xcodeAccounts = [SELECT Id, Xcode__c, Account__c, Xcode__r.Name,
                                 Initial_Hiring_Need__c, Initial_Hiring_Need_Date__c, IsPrimary__c,
                                Site_Industry__c, Site_Location_Type__c, Site_Sales_Channel__c, Site_Sales_Program__c, Xcode_Employees__c
                                FROM XcodeAccount__c
                                WHERE Account__c = :AccountID];

      XcodeWrapList = new XcodeWrap[]{};
      XcodeWrapMap = new map<Id, XcodeWrap>();

      if(xcodeAccounts.isEmpty()){
        LicenseTable = '&nbsp;No Xcode Account available.';
      }

      for(XcodeAccount__c xa : xcodeAccounts){
        XcodeWrap xw = new XcodeWrap();
        xw.Radio = '<input onclick="SelectRadio(this);" name="selector" type="radio" class="radio-select" value="'+xa.Id+'" />';
        xw.xcodeAccount = xa;
        XcodeWrapList.add(xw);
        XcodeWrapMap.put(xa.Id, xw);
      }

    }catch(Exception e){
      system.debug('\n\nError: ' + e + '\n\nTrace: ' + e.getStackTraceString() + '\n\n');
      AddPageError('Initialization error.');
      AddPageError('Error: ' + e);
      AddPageError('Trace: ' + e.getStackTraceString());
    }
  }

  private void AddPageError(String txt){
    ApexPages.Message PageError = new ApexPages.Message(ApexPages.Severity.FATAL, txt);
    ApexPages.addMessage(PageError);
  }

  public class XcodeWrap{
    public XcodeAccount__c xcodeAccount {get; set;}
    public String Radio {get; set;}
  }

  //LicenseViewCC.test();
  public void getLicenses(String pView, String pXcode)
  {
    if(pXcode == null)
    {
      LicenseTable = 'Invalid xcode.<br />Xcode: ' + pXcode;
      return;
    }

    CurrentXcode = pXcode;

    try
    {
      v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest req = new v3_schemasDatacontractOrg200407Monster.GetCompanyLicenseInfoRequest();
      v3_schemasMicrosoftCom200310SerializA.ArrayOfint intAr = new v3_schemasMicrosoftCom200310SerializA.ArrayOfint();

      String viewType = pView == null ? 'InventoryView' : pView;
      String errorStr = '';

      if(pView == 'InventoryView')
      {
        errorStr = 'Job Inventories';
        intAr.int_x = new Integer[]{233,240};
      }
      else if(pView == 'ResumeUsageView')
      {
        errorStr = 'Resume Inventories';
        intAr.int_x = new Integer[]{2};
      }
      else if(pView == 'EnhancementsView')
      {
        errorStr = 'Job Enhancements';
        intAr.int_x = new Integer[]{244,272,281,282,287};
      }
      else
      {
        errorStr = 'Job Inventories';
        intAr.int_x = new Integer[]{233,240};
      }

      req.ACLIDs = intAr;
      req.ChannelID = 58;
      req.CompanyXCode = pXcode;

      v3_monsterBizappsSiterouterSiterouterws.legacy con = new v3_monsterBizappsSiterouterSiterouterws.legacy();
      v3_schemasDatacontractOrg200407Monster.ArrayOfLicenseInfo res = con.GetCompanyLicenseInfo(req, viewType);

      if(res != null)
      {
        // debug should be inside to check null before printing debug information
        system.debug('\n\n RESULT SIZE: ' + res.LicenseInfo.size() + '\n\n');
        licenseInfoList = res.LicenseInfo;
        CurrentPage = 1;
        createLicenseTable();

        // try{
        //   con.endpoint_x = Utility.getWebServiceEnpoint('RequestBin');
        //   con.GetCompanyLicenseInfo(req, viewType);
        // }catch(Exception e){
        //   system.debug('Sending to Requestb.in');
        //   system.debug('Message: '+e.getMessage()+'; StackTraceString: '+e.getStackTraceString());
        // }
      }
      else
      {
        LicenseTable = 'No '+errorStr+' Were Found.';
        System.debug('\n\n'+LicenseTable+'\n\n');
      }

    }
    catch(Exception e)
    {
      LicenseTable = 'An error occured.';
      system.debug('\n\nError: ' + e + '\nTrace: ' + e.getStackTraceString() + '\n\n');
    }
  }

  private void createLicenseTable(){
    String output = '';
    if(licenseInfoList != null){
      //getting SF license records
      set<Id> OrderIdSet = new set<Id>();
      set<String> SiteLicenseIDSet = new set<String>();

      Integer StartIndex = (CurrentPage -1) * MAX_LICENSE;
      Integer EndIndex = CurrentPage < TotalPage ? CurrentPage * MAX_LICENSE : licenseInfoList.size();

      for(Integer i = StartIndex; i < EndIndex; i++){
        v3_schemasDatacontractOrg200407Monster.LicenseInfo info = licenseInfoList[i];
        if(info.x_licenseID != null){
          SiteLicenseIDSet.add(String.valueOf(info.x_licenseID));
        }

        if(info.x_orderID != null){
          try{
            OrderIdSet.add(Id.valueOf(info.x_orderID));
          }catch(System.StringException strEx){
            system.debug('\n\nInvalid SF ID: ' + info.x_orderID + '\n\n');
          }catch(Exception e){
            system.debug('\n\nError parsing Id: ' + info.x_orderID + '\n\n');
          }
        }
      }

      map<Id, Order__c> orderIdToOrderMap= new map<Id, Order__c>([SELECT Name, Id FROM Order__c WHERE Id IN :OrderIdSet]);

      map<String, LicenseID__c> siteLicenseToLicenseID = new map<String, LicenseID__c>();
      for(LicenseID__c license : [SELECT Id, Name, SiteLicenseID__c, OrderLineItem__r.Order__c, OrderLineItem__r.Order__r.Name FROM LicenseID__c WHERE SiteLicenseID__c IN :SiteLicenseIDSet]){
        if(license.SiteLicenseID__c != null){
          siteLicenseToLicenseID.put(license.SiteLicenseID__c, license);
        }
      }

      output += '<table id="license-table">';
      output += '<tr>';
        output += '<th>SF License ID</th>';
        output += '<th>Site License ID</th>';
        output += generateTableHeader();
      output += '</tr>';
      for(Integer i = StartIndex; i < EndIndex; i++){
        v3_schemasDatacontractOrg200407Monster.LicenseInfo info = licenseInfoList[i];
        output += '<tr class="license-tr">';
          String licenseStr = info.x_licenseID == null ? '' : String.valueOf(info.x_licenseID);
          LicenseID__c sfLicense = siteLicenseToLicenseID.get(licenseStr);
          if(sfLicense != null){
            output += '<td><a href="/'+sfLicense.Id+'">' + sfLicense.Name + '</a></td>';
          }else{
            output += '<td>&nbsp;</td>';
          }

          output += '<td>' + info.x_licenseID + '</td>';
          output += generateTableRow(info);

          if(LicenseView == 'InventoryView'){
            if(sfLicense != null && sfLicense.OrderLineItem__r.Order__c != null){
              output += '<td><a href="/'+sfLicense.OrderLineItem__r.Order__c+'">' + sfLicense.OrderLineItem__r.Order__r.Name + '</a></td>';
            }else{
              if(info.x_orderID != null){
                Order__c sfOrder;
                try{
                  sfOrder = orderIdToOrderMap.get(Id.valueOf(info.x_orderID));
                }catch(Exception e){ system.debug('\n\nInvalid ID\n\n'); }

                if(sfOrder != null){
                  output += '<td><a href="/'+sfOrder.Id+'">' + sfOrder.Name + '</a></td>';
                }else{
                  output += '<td>' + info.x_orderID + '</td>';
                }
              }else{
                output += '<td>&nbsp;</td>';
              }
            }
          }
        output += '</tr>';
      }
      output += '</table>';
      output += '<br /><br />';
    }

    LicenseTableReady = true;

    LicenseTable = output;
  }

  private String generateTableRow(v3_schemasDatacontractOrg200407Monster.LicenseInfo info){
    if(LicenseView == 'InventoryView'){
      return InventoryViewRow(info);
    }else if(LicenseView == 'EnhancementsView'){
      return EnhancementsViewRow(info);
    }else if(LicenseView == 'ResumeUsageView'){
      return ResumeUsageViewRow(info);
    }
    return '';
  }

  private String InventoryViewRow(v3_schemasDatacontractOrg200407Monster.LicenseInfo info){
    String output = '';
    output += '<td>'+ clean(info.x_name) + '</td>';
    output += '<td>'+ clean(info.x_licenseTypeName) + '</td>';
    output += '<td>'+ clean(info.x_jobBoardDescription) + '</td>';
    output += '<td>'+ clean(info.x_locationGroup) + '</td>';
    output += '<td>' + clean(info.x_purchaseCount) + '</td>';
    output += '<td>' + clean(info.x_usedCount) + '</td>';
    output += '<td>' + clean(info.x_holdCount) + '</td>';
    output += '<td>' + clean(info.x_availableCount) + '</td>';
    output += '<td>' + clean(info.x_purchaseDate) + '</td>';
    output += '<td>' + clean(info.x_DateActive) + '</td>';
    output += '<td>' + clean(info.x_expirationDate) + '</td>';

    return output;
  }
  private String EnhancementsViewRow(v3_schemasDatacontractOrg200407Monster.LicenseInfo info){
    String output = '';
    output += '<td>'+ clean(info.x_name) + '</td>';
    output += '<td>'+ clean(info.x_Duration) + '</td>';
    output += '<td>'+ clean(info.x_licenseTypeName) + '</td>';
    output += '<td>'+ clean(info.x_jobBoardDescription) + '</td>';
    output += '<td>'+ clean(info.x_locationGroup) + '</td>';
    output += '<td>'+ clean(info.x_purchaseCount) + '</td>';
    output += '<td>'+ clean(info.x_usedCount) + '</td>';
    output += '<td>'+ clean(info.x_holdCount) + '</td>';
    output += '<td>'+ clean(info.x_availableCount) + '</td>';
    output += '<td>'+ clean(info.x_DateActive) + '</td>';
    output += '<td>'+ clean(info.x_expirationDate) + '</td>';
    return output;
  }
  private String ResumeUsageViewRow(v3_schemasDatacontractOrg200407Monster.LicenseInfo info){
    String output = '';
    output += '<td>'+ clean(info.x_licenseTypeName) + '</td>';
    output += '<td>'+ clean(info.x_locationGroup) + '</td>';
    output += '<td>'+ clean(info.x_purchaseCount) + '</td>';
    output += '<td>'+ clean(info.x_usedCount) + '</td>';
    output += '<td>'+ clean(info.x_availableCount) + '</td>';
    output += '<td>' + clean(info.x_purchaseDate) + '</td>';
    output += '<td>'+ clean(info.x_DateActive) + '</td>';
    output += '<td>'+ clean(info.x_expirationDate) + '</td>';
    output += '<td>'+ clean(info.x_jobBoardDescription) + '</td>';
    output += '<td>'+ clean(info.x_postalCode) + '</td>';
    return output;
  }

  private String generateTableHeader(){
    if(LicenseView == 'InventoryView'){
      return InventoryViewHeader();
    }else if(LicenseView == 'EnhancementsView'){
      return EnhancementsViewHeader();
    }else if(LicenseView == 'ResumeUsageView'){
      return ResumeUsageViewHeader();
    }
    return '';
  }

  private String InventoryViewHeader(){
    String output = '';
    output += '<th>Name</th>';
    output += '<th>License Type</th>';
    output += '<th>Job Board</th>';
    output += '<th>Location Group</th>';
    output += '<th>Purchase Count</th>';
    output += '<th>Used Count</th>';
    output += '<th>Hold Count</th>';
    output += '<th>Available Count</th>';
    output += '<th>Purchase Date</th>';
    output += '<th>Date Active</th>';
    output += '<th>Expiration Date</th>';
    output += '<th>Order</th>';
    return output;
  }
  private String EnhancementsViewHeader(){
    String output = '';
    output += '<th>Name</th>';
    output += '<th>Duration</th>';
    output += '<th>License Type</th>';
    output += '<th>Job Board</th>';
    output += '<th>Location Group</th>';
    output += '<th>Purchase Count</th>';
    output += '<th>Used Count</th>';
    output += '<th>Hold Count</th>';
    output += '<th>Available Count</th>';
    output += '<th>Date Active</th>';
    output += '<th>Expiration Date</th>';
    return output;
  }
  private String ResumeUsageViewHeader(){
    String output = '';
    output += '<th>License Type</th>';
    output += '<th>Location Group</th>';
    output += '<th>Purchase Count</th>';
    output += '<th>Used Count</th>';
    output += '<th>Available Count</th>';
    output += '<th>Purchase Date</th>';
    output += '<th>Date Active</th>';
    output += '<th>Expiration Date</th>';
    output += '<th>Job Board Description</th>';
    output += '<th>Postal Code</th>';
    return output;
  }

  private String clean(Object pStr){
    return pStr == null ? '' : String.valueOf(pStr);
  }
}