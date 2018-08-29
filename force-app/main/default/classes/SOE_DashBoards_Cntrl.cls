/* 
Class Name        : SOE_DashBoards_Cntrl
Test Class Name   : Test_SOE_DashBoards_Cntrl
Purpose/Overview  : To display dashbords related to SOE.
Author            : Purview Ltd.
Code Coverage     : 87%.
Change History    : 
*/
public with sharing class SOE_DashBoards_Cntrl {
    public Id TaskReportId { get; set; }
    public Id IncidentReportId { get; set; }
    public Id MileStoneReportId  { get; set; }
    public Id CPReportId  { get; set; }
    public Id IncidentsByType{get;set;}   
    public Id LessonsLearned{get;set;}
    public Id AccessRequest {get;set;}
    public Id SOEID{get;set;}
    public SOE__C Soe{get;set;}
    public decimal CT{get;set;}
    public decimal PE{get;set;}
    public decimal PS{get;set;}
    public decimal FE{get;set;}
    public decimal ME{get;set;}
    public DateTime dt{get;set;}
    public i8Constants i8{get;set;}   
    public Integer green{get;set;}
    public Integer orange{get;set;}
    public Integer red{get;set;} 
    public string current{get;set;}
    public string statusmsg{get;set;} 
    
    public SOE_DashBoards_Cntrl (){
        try{
        i8 = new I8Constants();
        SOEId= ApexPages.CurrentPAge().getParameters().get('Id');
        if(Utils.isAccessible('i8__SOE__c'))
        Soe=  [select id,name,State__c,SOE_Title__c,Completed__c,Schedule_Start__c,Schedule_End__c,BAU_Impact__c,Warning_Zone__c,Min_Planned_Start__c,Max_Planned_End__c,Min_Forecast_Start__c,Status__c,Imp_Duration__c,Dealy_Ahead_mins__c,
        Max_Forecast_End__C,Max_End_Time__c,Min_Start_Time__c  from SOE__C where id=: SOEID];
        soe.Current_Time__c = System.Now();
        if(soe.Status__c != i8.STATUS_BUILD && soe.Status__c != i8.STATUS_REVIEW){
            integer total = Integer.valueof((soe.BAU_Impact__c.getTime() - soe.Schedule_Start__c.getTime())/(1000*60));
            green =  (Integer.valueof((soe.Schedule_End__c.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;
            orange =  (Integer.valueof((soe.Warning_Zone__c.getTime() - soe.Schedule_End__c.getTime())/(1000*60))*100) / total;
            red =  (Integer.valueof((soe.BAU_Impact__c.getTime() - soe.Warning_Zone__c.getTime())/(1000*60))*100) / total;
            if(green+orange+red <=100)
                red = 100-(green+orange);
            dt = System.Now();
            current = string.valueof(dt);
            PS = (Integer.valueof((soe.Min_Planned_Start__c.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;
            PE = (Integer.valueof((soe.Max_Planned_End__c.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;
            FE = (Integer.valueof((soe.Max_Forecast_End__c.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;
            if(Soe.Status__c == i8.STATUS_IMP_COMP || Soe.Status__c == I8.STATUS_SOE_COMP)
                ME = (Integer.valueof((soe.Max_End_Time__c.getTime() - soe.Min_Start_Time__c.getTime())/(1000*60))*100) / total;
            else if(Soe.Status__c == i8.STATUS_IMPINPROGRESS && soe.Min_Start_Time__c != null)
                ME = (Integer.valueof((dt.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;
            else
                ME = 0;
            if(PS > 100)
                PS= 100;
            if(PE > 100)
                PE= 100;
            if(FE > 100)
                FE= 100;
            if(ME > 100)
                ME= 100;
            if(Soe.Status__c == i8.STATUS_IMPINPROGRESS || Soe.Status__c == i8.STATUS_SCHEDULED || Soe.Status__c == i8.STATUS_FREEZE){
                CT = (Integer.valueof((dt.getTime() - soe.Schedule_Start__c.getTime())/(1000*60))*100) / total;           
                if(CT > 100)
                    CT = 100;
            }
            else if(Soe.Status__c == i8.STATUS_IMP_COMP || Soe.Status__c == I8.STATUS_SOE_COMP)
                CT = 100;
            else
                CT = 0;
        }
        else{
            green = 50; orange = 30; red = 20;
            PS = 0;PE =0;FE=0;ME=0;CT=0;
        }
        if(Schema.SOBjectType.Report.isAccessible()){
            taskreportId  = [Select Id, Name From Report Where name='Task Status Report IN SOE'].Id;
            IncidentReportId  = [Select Id, Name From Report Where name='Incident Status Report'].Id;
            MileStoneReportId  = [Select Id, Name From Report Where name='Milestone Tasks Report in SOE'].Id;
            CPReportId  = [Select Id, Name From Report Where name='Critical Path Tasks in SOE'].Id;
            IncidentsByType = [Select Id, Name From Report Where name='Incidents By Type'].Id;       
            LessonsLearned = [Select Id, Name From Report Where name='Lessons Learned'].Id;
            AccessRequest = [Select Id, Name From Report Where name='SOE With AccessRequests'].Id;
            Reports.ReportDescribeResult descRes = Reports.ReportManager.describeReport(AccessRequest);
        }        
        }
        catch(Exception e){
                   statusmsg = e.getMessage();                  
        }
    }   
    public pagereference openCancel(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    } 
    public pagereference OpenReport(){
       return new pagereference('/apex/Report?id='+SOEId+'&url='+taskreportId  );
    }
}