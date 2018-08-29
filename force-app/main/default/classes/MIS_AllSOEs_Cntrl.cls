/* 
Class Name        : MIS_AllSOEs_Cntrl
Test Class Name   : Test_MIS_AllSOEs_Cntrl
Purpose/Overview  : To Display All SOE's in that MIS in single view 
Author            : Purview Ltd.
Code Coverage     : 98%
Change History    : 

*/
public with sharing class MIS_AllSOEs_Cntrl{
    public MIS__c mis{get;set;}
    public list<SOE__c> SOEList;
    public list<SOE__c> SOEList1{get;set;}
    public i8Constants i8{get;set;}
    public boolean Freeze{get;set;}
    public boolean InProgress{get;set;}
    public boolean PreImp{get;set;}
    public boolean Schedule{get;set;}
    public string errormessage {get;set;}
    Id MISID ;
        
    public MIS_AllSOEs_Cntrl(){
        i8 = new i8Constants();
        PreImp = false;
        Schedule = false;
        MISID = ApexPages.CurrentPage().getParameters().get('id') ;
        if(Utils.isAccessible('I8__MIS__c') && Utils.isAccessible('I8__SOE__c')){
        mis = [select id,Name,MIS_Title__c,MIS_PlannedStart__c,MIS_PlannedEnd__c from MIS__c where id=: ApexPages.CurrentPage().getParameters().get('id')];
        SOEList1 = [select id,Name,Status__c,SOE_Title__c,Min_Planned_Start__c ,Max_Planned_End__c,SOE_RAG__c,RAG__c,Imp_Duration__c,Schedule_Start__c,
        Min_Forecast_Start__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,OwnerId,Not_Comp_Pre_Stacks__c,Comp_Pre_Stacks__c,  
        BAU_Impact__c,Schedule_End__c,Max_End_Time__c from SOE__c where MIS__c =: ApexPages.CurrentPage().getParameters().get('id') order by Schedule_Start__c,Min_Planned_Start__c]; 
        for(SOE__c soe: SOEList1){
            if(soe.Status__c != i8.STATUS_FREEZE && soe.Status__c != i8.STATUS_IMPINPROGRESS && soe.Status__c != i8.STATUS_IMP_COMP && soe.Status__c != i8.STATUS_SOE_COMP){
                Freeze = false;
                break;
            }
            else if(soe.Status__c == i8.STATUS_FREEZE)
                Freeze = true;
        }
         for(SOE__c soe: SOEList1){
           if(soe.Status__c != i8.STATUS_IMPINPROGRESS && soe.Status__c != i8.STATUS_IMP_COMP && soe.Status__c != i8.STATUS_SOE_COMP){
               InProgress  = false;
               break;
           }
           else if(soe.Status__c == i8.STATUS_IMPINPROGRESS || soe.Status__c == i8.STATUS_IMP_COMP || soe.Status__c == i8.STATUS_SOE_COMP)
               InProgress = true;
        } 
      }else{ errormessage = System.Label.Admin001;}        
    }
    public void Execute(){
        try{
        if( Utils.isUpdateable('i8__SOE__c')   ) {  
            for(SOE__c soe: SOEList1){
                 if(soe.Not_Comp_Pre_Stacks__c != soe.Comp_Pre_Stacks__c){
                     PreImp = true;
                     break;
                 }
                 else if(soe.Schedule_Start__c > System.Now() || soe.Max_End_Time__c >= soe.BAU_Impact__c){
                     Schedule= true;
                     break;
                 }
             }
             if(PreImp == false && Schedule == false){
                 SOEList = new list<SOE__c>();
                 for(SOE__c soe: SOEList1){
                     if(soe.Status__c == i8.STATUS_FREEZE ){
                        soe.Status__c = i8.STATUS_IMPINPROGRESS;
                        SOEList.add(soe);
                     }
                 }            
                 LogFactory.Debug('MIS_ALlSOEs_Cntrl','Execute', 'SOE List', 'SOE Executed Successfully','Line - 65');
                 if(SOEList.size()>0){
                     if(Utils.isUpdateable('i8__SOE__c') )
                         update SOEList; 
                     list<id> SOEIds = new list<Id>();                   
                     for(integer i=0;i<SOEList.size();i++)
                         SOEIds.add(SOEList[i].id);
                     Task_TriggerHandler.UpdateAllTasks(SOEIds,i8.CONTEXT_IMP);
                 }
            }else{errorMessage =  System.Label.AddTask007;}
         }
         }Catch(Exception e){
             LogFactory.error('MIS_AllSOes_Cntrl','Execute','',e.getMessage() + ''+ e.getStackTraceString());             
         }
         LOgFactory.SaveLog();    
      }
     public pagereference Cancel(){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+MISID );
    }
}