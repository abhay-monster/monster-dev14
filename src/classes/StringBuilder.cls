/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : class to provide similar functionality to .NET StringBuilder class
*/
public with sharing class StringBuilder{ 
    static final String CLASSNAME = '\n\n**** StringBuilder.METHODNAME()';
    
    //************ PROPERTIES **************
    private list<String> stringList = new list<String>();

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : private class constructor
** @parameters :
** @returns :
*/
    private void StringBuilder(){
        final string METHODNAME = CLASSNAME.replace('.METHODNAME()',' - constructor');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to convert collection of Strings to one (1) single String
** @paramaters : none
** @returns : a String representing ...
*/
    public String AsString(){
        
        // cannot override ToString() method so method is "AsString" instead
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AsString');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        String appendString = '';
        if(this.stringList.size() > 0){
            for(String newString : this.stringList)
            { appendString += newString; }
        }
        
        return appendString;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to clear the stringList property
** @paramaters : none
** @returns : nothing
*/
    public void Clear(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Clear');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        this.stringList.clear();
    }

/*    
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to add a String to the collection
** @paramaters : a String to add to the collection
** @returns : nothing
*/
    public void Append(String pStringToAdd){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','Append');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug(LoggingLevel.INFO, METHODNAME + ' :: String to add = ' + pStringToAdd +'\n\n');
        
        stringList.add(pStringToAdd);
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to add a String to the object's collection in addition to the "new line" characters
** @paramaters : a String to add to the collection
** @returns : nothing
*/
    public void AppendLine(String pStringToAdd){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','AppendLine');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        Append(pStringToAdd + '\r\n');
    }

/*   
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to instantiate a new StringBuilder object
** @paramaters : none
** @returns : new instance of StringBuilder class
*/
    public static StringBuilder NewStringBuilder(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','NewStringBuilder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        StringBuilder stringBuilder = new StringBuilder();
        return stringBuilder;
    }

/*        
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to instantiate a new StringBuilder object AND populate its String collection with an initial value
** @paramaters : a String to add to the collection
** @returns : new instance of StringBuilder class with an initial value in its String collection
*/
    public static StringBuilder NewWithFirstValue(String pValue){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','NewWithFirstValue');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.Append(pValue);
        return stringBuilder;
    } 
}