/* 
Class Name        : SOEPageHeader
Test Class Name   : Test_SOEPageHeader
Purpose/Overview  : To display SOE Header / MIS Header in all pages.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class SOEPageHeader {
    public string SOEId{get;set;}
    public string MISID{get;set;}
    public List<MIS__c> MISObj{get;set;}
    public List<SOE__c> SOEObj{get;set;}
    
    public List<SOE__c> getSOE () {
        if(Utils.isAccessible('i8__SOE__c'))
        SOEObj = [select id,name,Max_Planned_End__c,SOE_RAG__c ,Max_Forecast_End__c,Min_Start_Time__c,Min_Planned_Start__c ,Imp_Duration__c,Max_End_Time__c,RAG__c,SOE_Title__c,State__c,Status__c,Dealy_Ahead_mins__c
                  from SOE__c where id=: SOEId];
        else SOEObj = new list<SOE__c>();
        return SOEObj;
    }    
    public List<MIS__c> getMIS () {
        if(Utils.isAccessible('i8__MIS__c'))
            MISObj = [select id,name,MIS_PlannedEnd__c,MIS_PlannedStart__c,MIS_Title__c from MIS__c where id=: MISID];
        else
            MISObj = new list<MIS__c>();
        return MISObj;
    }
}