/* 
Class Name        : History_Tracking_Cntrl
Test Class Name   : Test_History_Tracking_Cntrl
Purpose/Overview  : To DIsplay History Records related to that SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class History_Tracking_Cntrl {
    public list<History__c> HistoryList { get;set;}
    public id SOEid{get;set;}
    Public string SOEidstring{get;set;}
    Public Boolean SOE{get;set;}
    public string errmsg {get;set;}
    
    public  History_Tracking_Cntrl (){
        SOEid=ApexPages.currentPage().getParameters().get('id');
        SOEidstring = string.valueof(SOEid);
        boolean History_Access = Utils.isAccessible('i8__History__c');
            If(SOEidstring.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix()  ){
                 SOE = False;
                if(History_Access )
                    HistoryList = [select id,name,SOE__c,Action__c,Task_Id__c,Old_value__c,New_value__c,Field__c,Modified_By__c from History__c where SOE__c =: SOEid limit 10000];
                else errmsg = System.Label.ADMIN001;
            }
            Else If(SOEidstring.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix()){
                SOE = True;
                if(Utils.isAccessible('i8__SOE__c') && History_Access ){
                    List<SOE__c> MISSOE_list = [Select Id,MIS__c from SOE__c where MIS__c =: SOEid];
                    Set<Id> SOEIds = New Set<Id>();
                    for(SOE__c MIS_SOE : MISSOE_list)
                        SOEIds.add(MIS_SOE.id); 
                    HistoryList = [select id,name,SOE__c,Action__c,Task_Id__c,Old_value__c,New_value__c,Field__c,Modified_By__c from History__c where SOE__c IN : SOEIds limit 10000];
                }else errmsg = System.Label.ADMIN001; 
            }
    }
    Public pagereference cancel(){
        If(SOE == True)
            return New PageReference('/apex/MIS_AllTasks?id='+SOEid);
        return New PageReference('/apex/AllTasks_ClientSide?id='+SOEid);
    }
}