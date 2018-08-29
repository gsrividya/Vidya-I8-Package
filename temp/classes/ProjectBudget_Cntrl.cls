/* 
Class Name        : ProjectBudget_Cntrl 
Test Class Name   : Test_ProjectBudget_Cntrl
Purpose/Overview  : To calculate project budget with respect to SOE.  
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class ProjectBudget_Cntrl {
    public Id RecordId{get;set;}
    public String SOE_Flag{get;set;}
    public Project_Budget__c ProjBudg{get;set;}
    public list<Project_Budget__c> ProjBudgList{get;set;}
    Public SOE__c SOE{get;set;}
    public Id SOEId{get;set;}
    public List<Expenses__c> ExpenseList{get;set;}
    public List<Timesheet_Entry__c> TimeSheetEntryList{get;set;}
    Public Decimal GeneralExpence{get;set;}
    Public Decimal ManpowerCost{get;set;}
    public boolean error{get;set;}
    public string errormsg{get;set;}
    
//-----------------Constructor-------------------  
    public ProjectBudget_Cntrl (){
            RecordId = apexpages.currentpage().getparameters().get('id');
            SOE_Flag = apexpages.currentpage().getparameters().get('SOE_Flag');
            ExpenseList = new List<Expenses__c>();
            TimeSheetEntryList = new List<Timesheet_Entry__c>();
            GeneralExpence = 0;
            ManpowerCost = 0;
            if(UTils.isAccessible('i8__Project_Budget__c') && Utils.isAccessible('i8__Expenses__c')&& Utils.isAccessible('i8__Timesheet_Entry__c')){
                if(RecordId != null){
                    if(SOE_Flag == 'soerec'){
                        ProjBudg = [Select Id,Name,SOE__c,General_Expenses__c,Manpower_Cost__c from Project_Budget__c where Id =: RecordId LIMIT 1];
                        SOEId = ProjBudg.SOE__c;                    
                    }
                    if(SOE_Flag == 'True'){
                        if(Utils.isAccessible('i8__SOE__c'))
                            SOE = [Select Id,Name from SOE__c where Id =: RecordId LIMIT 1];
                        SOEId = SOE.Id;    
                        ProjBudgList = [Select Id,Name,SOE__c,General_Expenses__c,Manpower_Cost__c from Project_Budget__c where SOE__c =: SOEId  LIMIT 1];
                        if(ProjBudgList.Size() > 0)
                            ProjBudg = ProjBudgList[0];
                    }
                }
                if(SOEId != null){
                        ExpenseList = [Select Id,Name,SOE__c,Amount__c from Expenses__c where SOE__c =: SOEId];
                        TimeSheetEntryList = [Select Id,Name,SOE__c,Net_Pay__c from Timesheet_Entry__c where Timesheet__r.Status__c =: 'Approved' and SOE__c =: SOEId];
                }
                if(ExpenseList != null){
                    for(Expenses__c Exp : ExpenseList){
                        if(Exp.Amount__c != null)
                        GeneralExpence = GeneralExpence + Exp.Amount__c;                   
                    }
                }
                if(TimeSheetEntryList != null){
                    for(Timesheet_Entry__c Tim : TimeSheetEntryList){
                        if(Tim.Net_Pay__c != null)
                        ManpowerCost = ManpowerCost + Tim.Net_Pay__c; 
                    }
                }
           } else{error = true;errormsg = System.Label.ADMIN001;}
    }
//--------------End Of the Constructor------------
    public pagereference ProjectBudgUpdate(){
    if(Utils.isUpdateable('i8__Project_Budget__c')){
        Savepoint sp = Database.setSavepoint();
        try{
        if(ProjBudg != null && (GeneralExpence != 0 || ManpowerCost != 0)){
                ProjBudg.General_Expenses__c = GeneralExpence ;
                ProjBudg.Manpower_Cost__c = ManpowerCost ;
                if(Utils.isUpdateable('i8__Project_Budget__c'))
                    Update ProjBudg;   
         }  
        if(SOE_Flag == 'soerec')
            return new pagereference('/'+ProjBudg.Id);
        else if(SOE_Flag == 'True' && ProjBudgList.Size()>0)
            return new pagereference('/'+SOE.Id);
            }catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('ProjectBudget_Cntrl', 'ProjectBudgUpdate', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog(); 
                   error = true;
                   errormsg = e.getMessage();                  
            }
        }
        else{error = true;errormsg = System.LAbel.ADMIN001;}
        return null;
    }
    public pagereference Close(){
        if(projBudg != null || SOE != null){
        if(SOE_Flag == 'soerec')
            return new pagereference('/'+ProjBudg.Id);
        else
            return new pagereference('/'+SOE.Id);
        }else return new pagereference('/'+RecordId);
    }
}