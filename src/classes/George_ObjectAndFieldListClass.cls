public class George_ObjectAndFieldListClass
{
  public List<SObjectWrapper> cusTableRows {get;set;}
  public List<SObjectWrapper> stdTableRows {get;set;}
  public List<SObjectWrapper> objects {get;set;}

  public Integer fieldCount {get;set;}
  public Integer objectWithFieldCount {get;set;}

  public ObjectFieldsOptionSet standardObjects {get;set;}
  public ObjectFieldsOptionSet customObjects {get;set;}
  public ObjectFieldsOptionSet managedObjects {get;set;}

  public class ObjectFieldsOptionSet
  {
    public Boolean objectYes {get;set;}
    public Boolean standardFields {get;set;}
    public Boolean customFields {get;set;}
    public Boolean managedFields {get;set;}

    public ObjectFieldsOptionSet(Boolean t, Boolean s, Boolean c, Boolean m)
    {
      this.objectYes = t;
      this.standardFields = s;
      this.customFields = c;
      this.managedFields = m;
    }

    public ObjectFieldsOptionSet()
    {
      this.objectYes = false;
      this.standardFields = false;
      this.customFields = false;
      this.managedFields = false;
    }
  }


  public George_ObjectAndFieldListClass()
  {
    standardObjects = new ObjectFieldsOptionSet();
    customObjects = new ObjectFieldsOptionSet();
    managedObjects = new ObjectFieldsOptionSet(true,false,true,false);

    init();
  }

  private void init()
  {
    Integer nsCheckNum;
    fieldCount = 0;
    objectWithFieldCount = 0;

    objects = new List<SObjectWrapper>();

    for(Schema.SObjectType objTyp: Schema.getGlobalDescribe().Values())
    {
      if(!objTyp.getDescribe().isCustom())
      {
        if(standardObjects.objectYes)
        {
          objects.add(new SObjectWrapper(objTyp,standardObjects));
        }
        else if(managedObjects.objectYes && objTyp.getDescribe().getName().split('__').size() == 2)
        {
          objects.add(new SObjectWrapper(objTyp,managedObjects));
        }
      }
      else if(objTyp.getDescribe().isCustom())
      {
        if(customObjects.objectYes)
        {
          objects.add(new SObjectWrapper(objTyp,customObjects));
        }
        else if(managedObjects.objectYes && objTyp.getDescribe().getName().split('__').size() == 3)
        {
          objects.add(new SObjectWrapper(objTyp,managedObjects));
        }
      }
    }

    for(SObjectWrapper obj:objects)
    {
      if(obj.fields.size() > 0)
      {
        fieldCount += obj.fields.size();
        objectWithFieldCount++;
      }
    }
  }

  public PageReference refresh()
  {
    init();
    return null;
  }

  public class FieldWrapper
  {
    public String formula {get;set;}
    public String label {get;set;}
    public String name {get;set;}
    public String fieldType {get;set;}
    public Boolean isCustom {get;set;}

    public FieldWrapper(Schema.DescribeFieldResult f)
    {
      this.formula = f.isCalculated()?f.getCalculatedFormula():'N/A';
      this.label = f.getLabel();
      this.name = f.getName();
      this.fieldType = f.getType().name();
      this.isCustom = f.isCustom();
    }
  } 


  public class SObjectWrapper
  {
    public FieldWrapper[] fields {get;set;}
    public String name {get;set;}
    public String label {get;set;}
    public String prefix {get;set;}

    public SObjectWrapper(Schema.SObjectType objTyp, ObjectFieldsOptionSet ofos)
    {
      DescribeSObjectResult objectType = objTyp.getDescribe();
      this.name = objectType.getName();
      this.label = objectType.getLabel();
      this.prefix = objectType.getKeyPrefix();

      Map<String,Schema.SObjectField> fieldsMap = objectType.fields.getMap();
      String[] strKeys = new List<String>(fieldsMap.keySet());  
      strKeys.sort();
      fields = new List<FieldWrapper>();
      Schema.DescribeFieldResult field;
      Integer nsCheckNum;

      for(String strKey:strKeys)
      {
        field = fieldsMap.get(strKey).getDescribe();

        if(field.isCustom())
        {
          if(ofos.customFields && field.getName().split('__').size() != 3)
          {
            fields.add(new FieldWrapper(field));
          }
          else if(ofos.managedFields && field.getName().split('__').size() == 3)
          {
            fields.add(new FieldWrapper(field));
          }
        }
        else
        {
          if(ofos.standardFields && field.getName().split('__').size() != 2)
          {
            fields.add(new FieldWrapper(field));
          }
          else if(ofos.managedFields && field.getName().split('__').size() == 2)
          {
            fields.add(new FieldWrapper(field));
          }
        }
      }
    }
  }
}