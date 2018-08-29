/* 
Class Name        : ThisWeekSOEs 
Test Class Name   : Test_ThisWeekSOEs
Purpose/Overview  : To display this week running SOEs in home page 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class ThisWeekSOEs {
    public List<SOE__c> SOEList{get;set;}
    
    public ThisWeekSOEs(){
        SOEList = new list<SOE__c>();
        if(Utils.isAccessible('i8__SOE__c'))
            SOEList = [Select id,name,SOE_Title__c,Baseline_Start__c,BAU_Impact__c,Imp_Duration__c,Schedule_Start__c,Schedule_End__c,Warning_Zone__c 
        from SOE__c where Schedule_Start__c = THIS_WEEK ];
    }
}