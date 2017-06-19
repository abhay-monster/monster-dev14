public class GH_QueriableMetaDataLookupController
{
  public String currentTypeStr {get;set;}
  public List<SelectOption> typeOptions {get;set;}
  public String queryStr {get;set;}
  public List<MetaDataWrapper> results {get;set;}
  public Integer numOfResults {get;set;}
  public String notQueryStr {get;set;}
  public String soqlStr {get;set;}

  public class MetaDataWrapper
  {
    public SObject obj {get;set;}
    public String objId {get;set;}
    public String objNamespacePrefix {get;set;}
    public String objName {get;set;}

    public MetaDataWrapper(SObject o)
    {
      this.obj = o;
      this.objId = (String)o.get('Id');
      this.objName = (String)o.get('Name');
      this.objNamespacePrefix = (String)o.get('NamespacePrefix');
    }
  }

  public GH_QueriableMetaDataLookupController()
  {
    queryStr = '';
    currentTypeStr = 'ApexClass';
    typeOptions = new List<SelectOption>();
    typeOptions.add(new SelectOption('ApexPage','Visualforce Pages'));
    typeOptions.add(new SelectOption('ApexClass','Apex Classes'));
    typeOptions.add(new SelectOption('ApexTrigger','Apex Triggers'));
    getResults();
  }

  public void getResults()
  {
    soqlStr = '';

    results = new List<MetaDataWrapper>();
    
    queryStr.trim();
    
    System.debug('queryStr: '+queryStr);
    
    if(String.isNotBlank(queryStr))
    {
      for(SObject so:querySObject())
        results.add(new MetaDataWrapper(so));
    }
    else
    {
      soqlStr = '';
    }

    numOfResults = results.size();

    System.debug('number of results: '+numOfResults);
  }

  private List<SObject> querySObject()
  {
    soqlStr = 
      'SELECT Id, Name, NamespacePrefix FROM '+currentTypeStr+
      ' WHERE Name LIKE \'%'+String.escapeSingleQuotes(queryStr)+'%\'';

    if(String.isNotBlank(notQueryStr))
      soqlStr += ' AND (NOT Name LIKE \'%'+String.escapeSingleQuotes(notQueryStr)+'%\')';

    soqlStr += ' LIMIT 999';

    return Database.query(soqlStr);
  }

  public PageReference updateResults()
  {
    getResults();
    return null;
  }
}