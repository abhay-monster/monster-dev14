/*
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description :   class to extend the Exception class and provide the user the ability to throw custom exceptions related to business rules, etc.;
                    supports user-defined error messages as well as "user-friendly" error messages
*/
global virtual class BaseApplicationException extends Exception
{
    final String CLASSNAME = '\n\n**** BaseApplicationException.METHODNAME()';
    
    // ******** Properties *****************
    public String UserFriendlyMessage{get; set;}
    public String Message
    {
        get
        {
            return this.getMessage();
        }
    }
    private String privateMethodName;
    public String SourceMethodName
    {
        get
        {
            return privateMethodName; 
        }
        set
        {
            privateMethodName = value.Replace('*','').Replace(' ','');
        }
    }

/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : Constructor
** @paramaters : String - Source Method Name, String - Message
** @returns : nothing
*/
    protected BaseApplicationException(String pSourceMethodName, String pMessage){
        this.SourceMethodName = pSourceMethodName;
        this.setMessage(pMessage);      
    } 
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : Constructor
** @paramaters : String - Source Method Name, String - Message, Exception
** @returns : nothing
*/
    protected BaseApplicationException(String pSourceMethodName, String pMessage, Exception pException){
        this(pSourceMethodName, pMessage);
        this.initCause(pException);
    }
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error with a user friendly message
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : nothing
*/
    public static BaseApplicationException NewException(String pSourceMethodName, String pMessage, String pUserFriendlyMessage){
        BaseApplicationException bae = new BaseApplicationException(pSourceMethodName,pMessage);
        bae.UserFriendlyMessage = pUserFriendlyMessage;
        bae.LogException();
        return bae;
    }

/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : New Base Exception
*/
    public static BaseApplicationException NewException(String pSourceMethodName, String pMessage){
        return BaseApplicationException.NewException(pSourceMethodName, pMessage, pMessage);
    }
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : nothing
*/
    public static BaseApplicationException NewExceptionWithInnerException(String pSourceMethodName, String pMessage, Exception pException){
        return BaseApplicationException.NewExceptionWithInnerException(pSourceMethodName, pMessage, pMessage, pException);
    }
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : nothing
*/
    public static BaseApplicationException NewExceptionWithInnerException(String pSourceMethodName, String pMessage, String pUserFriendlyMessage, Exception pException){
        BaseApplicationException bae = new BaseApplicationException(pSourceMethodName, pMessage, pException);
        bae.UserFriendlyMessage = pUserFriendlyMessage;
        bae.LogException();
        return bae;
    }
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : nothing
*/
    public virtual void LogException(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','LogException');
        
        try
        {
            //system.Debug(LoggingLevel.INFO, '\n\n' + METHODNAME + ' :: Gathering Exception Details\n\n');
            String errorDetails = this.SourceMethodName + ' :: ' + ExceptionHandler.GetExceptionDetailsAsString(this);
           
            StringBuilder sb = StringBuilder.NewWithFirstValue('\n\n******************************************************************************************************');
            sb.Append('\n          ERROR DETAILS          ');
            sb.Append('\n******************************************************************************************************\n');
            sb.Append('\n' + errorDetails + '\n');
            sb.Append('\n\n******************************************************************************************************\n\n');
            system.Debug(LoggingLevel.INFO, sb.AsString());
        }
        catch (Exception ex)
        {
            // TODO
        } 
    }
    
/*  
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : method returns a new Base Exception Error
** @paramaters : String - Source Method Name, String - Message, String - User Friendly Message
** @returns : nothing
*/
    public virtual String GetExceptionDetailsAsString(){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','GetExceptionDetailsAsString');
        return '';
    }

}