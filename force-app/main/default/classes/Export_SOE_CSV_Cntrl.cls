/* 
Class Name        : Export_SOE_CSV_Cntrl 
Test Class Name   : Test_Export_SOE_CSV_Cntrl
Purpose/Overview  : To export tasks to CSV in one SOE from Import page 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class Export_SOE_CSV_Cntrl {
    public List<Task__c> Task_List{get;set;}    
    Id SOE_Id;
    public Export_SOE_CSV_Cntrl(){
        SOE_Id = ApexPages.CurrentPage().getParameters().get('id');
        if(Utils.isAccessible('I8__Task__c') && Utils.isAccessible('I8__SOE__c')){
        Task_List = new List<Task__c>();
        if(SOE_Id != null)
            Task_List = [select SOE__r.SOE_Title__c,SOE__r.Name,Status__c,id,Name,Is_Stack__c,End_Stack__c,Task_Title__c,Stage__c,ID_Text__c,Stage_Level__c,Days__c,Hours__c,Minutes__c,Advanced_Notifications__c,Description__c,Milestone__c,Technical_Skills__c,Technical_Detail__c,Time_Bound__c from Task__c where SOE__c =: SOE_Id order by Stage_Level__c ,Id_Before_decimal__c,Id_After_Decimal__c];
        }
   }    
}