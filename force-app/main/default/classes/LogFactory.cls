public with sharing class LogFactory
{
      /*    
Class Name        : LogFactory
Test Class Name   : Test_LogFactory
Purpose/Overview  : his class is mainly used to insert success, info, failure information into Log__c object to capture DML operation in I8 App.
                    No user interface for this call. 
Author            : Purview Ltd.
Code Coverage     : 93%
Change History    : 

*/  
  private static final String TYPE_ERROR = 'ERROR';
  private static final String TYPE_INFO = 'INFO';
  private static final String TYPE_DEBUG = 'DEBUG';
  private static final Set<String> LOG_FIELDS_TO_CREATE = new Set<String>{'Level__c', 'Location__c', 'Description__c', 'SourceClass__c' , 'SourceMethod__c', 'Title__c'};

  /**
  *  @description keeps log availability boolean value
  */
  private static Boolean isLogEnable
  {
    get 
      { 
      if (isLogEnable == null) 
          {
            isLogEnable = Utils.getSystemSetting('LOG_ENABLE') == null ? 
                false : 
                Boolean.valueOf(Utils.getSystemSetting('LOG_ENABLE'));
          }  
          return isLogEnable;
      }
    set;
  }
    
    /**
  *  @description keeps log value
  */
  private static String logLevel
  {
    get 
    { 
      if (logLevel == null) 
      {
        logLevel = Utils.getSystemSetting('LOG_LEVEL') == null ? ''
          : Utils.getSystemSetting('LOG_LEVEL');
      }
      return logLevel;
    }
    set;
  }

  /**
  *  @description all tranzaction logs
  */
  private static List<Log__c> allLogs
  {
    get
    {
      if (allLogs == null)
      {
        allLogs = new List<Log__c>();
      }
      return allLogs;
    }
    set;
  }

  /**
  *  @description add new error log
  */
  public static void error(String sourceClass, String sourceMethod, String title, String message)
  {
    if (isLogEnable && logLevel != null 
        && logLevel.containsIgnoreCase(TYPE_ERROR))
    {
      newLog(TYPE_ERROR, sourceClass, sourceMethod, title, message,null);
    }
  }
  /**
  *  @description add new info log
  */
  public static void info(String sourceClass, String sourceMethod, String title, String message, String location)
  {
    if (isLogEnable && logLevel != null 
      && logLevel.containsIgnoreCase(TYPE_INFO))
    {
      newLog(TYPE_INFO, sourceClass, sourceMethod, title, message,location);
    }
  }

  /**
  *  @description add new debug log
  */
  public static void debug(String sourceClass, String sourceMethod, String title, String message,string location)
  {
    if (isLogEnable && logLevel != null 
      && logLevel.containsIgnoreCase(TYPE_DEBUG))
    {
      newLog(TYPE_DEBUG, sourceClass, sourceMethod, title, message,location);
    }
  }

  /**
  *  @description save all tranzaction logs to db
  */
  public static Boolean savelog()
  {
  Savepoint sp = Database.setSavepoint();
   try{
    if (allLogs != null && allLogs.size() > 0)
     {
        if(Utils.isCreateable('i8__Log__c'))
            insert allLogs;
        allLogs.clear();
        allLogs = new List<Log__c>();
        return true;
     }
    }
    catch(Exception e){
      System.debug('=====>'+e.getMessage());
    }
    return false;
  }

  /**
  *  @description save all tranzaction logs to db
  */
  private static void newLog(String level, String sourceClass, String sourceMethod, String title, String message,string location)
  {
      Log__c logItem = new Log__c(
        Level__c = level,
        Source_Class__c =  sourceClass, 
        Source_Method__c = sourceMethod, 
        Title__c = title,
        Description__c = message,
        Location__c = location);

    allLogs.add(logItem);
    
  }
}