/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description :   class to ...
*/
public with sharing class ExceptionHandler
{

    final static String CLASSNAME = 'ExceptionHandler.METHODNAME()';

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to ...
** @paramaters : 
** @returns :
*/ 
    public static String GetExceptionDetailsAsString(Exception ex){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetExceptionDetailsAsString');
        
        StringBuilder sb = StringBuilder.NewStringBuilder();

        sb.Append(GetCommonExceptionDetails(ex));
        sb.Append(GetSpecificExceptionDetails(ex)); 

        // TODO: make sure that call to GetSpecificExceptionDetails() does NOT cause an infinite loop until crashes with a limit exception.
        
        if (ex.getCause() != null)      
            sb.Append(GetExceptionDetailsAsString(ex.getCause()));
        
        return sb.AsString();
    }

/*  
** @author : Cloud Sherpas, Inc.
** @date : 03/03/2014
** @description : method to ...
** @paramaters : 
** @returns :
*/ 
    private static String GetCommonExceptionDetails(Exception ex){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetCommonExceptionDetails');
        
        StringBuilder sb = StringBuilder.NewStringBuilder();
        
        sb.AppendLine(' EXCEPTION : \nMessage: ' + ex.getMessage());
        sb.AppendLine('Source Exception Type: ' + ex.getTypeName());
        sb.AppendLine('Line Number: ' + String.valueof(ex.getLineNumber()));
        sb.AppendLine('Stack Trace: ');
        sb.AppendLine(ex.getStackTraceString());
        
        return sb.asString();
    }
    
    //@author : Cloud Sherpas, Inc.
    //@date : 03/03/2014
    //@description : method to ...
    //@paramaters : 
    //@returns : 
    private static String GetDmlEmailExceptionDetailsAsString(System.Exception ex){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetDmlEmailExceptionDetailsAsString');
        
        if (ex instanceof DmlException)
            ex = (DmlException)ex;
        else if (ex instanceof EmailException)
            ex = (EmailException)ex;
                 
        StringBuilder sb = StringBuilder.NewStringBuilder();
        
        // build message with all errors
        for (Integer i = 0; i < ex.getNumDml(); i++)
        {              
            sb.AppendLine('Exception Message: ' + ex.getDmlMessage(i));
            
            sb.Append('Field Names: ');
            for(String s : ex.getDmlFieldNames(i))
            {
                sb.Append(s + '; ');
            }
            sb.AppendLine('');
            
            sb.AppendLine('Status Code: ' + ex.getDmlType(i));                      
        }
        return sb.asString();
    }

    //@author : Cloud Sherpas, Inc.
    //@date : 03/03/2014
    //@description : method to ...
    //@paramaters : 
    //@returns : 
    private static String GetSpecificExceptionDetails(Exception pException){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetSpecificExceptionDetails');
        
        String errMessage = '';
        String Details = '';
        
        if(pException instanceof System.Dmlexception)
        {
            Details = GetDmlEmailExceptionDetailsAsString(pException);
        }
        else if(pException instanceof System.Emailexception)
        {
            Details = GetDmlEmailExceptionDetailsAsString(pException);
        }
        else if (pException instanceof BaseApplicationException)
        {
            //Details = ((BaseApplicationException)pException).GetSpecificExceptionDetails();
            Details = ((BaseApplicationException)pException).Message;
        }
        return Details;
    }
}