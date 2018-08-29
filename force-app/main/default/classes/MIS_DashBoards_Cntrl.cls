/* 
Class Name        : MIS_DashBoards_Cntrl 
Test Class Name   : Test_MIS_DashBoards_Cntrl
Purpose/Overview  : To display dashboards and reports
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class MIS_DashBoards_Cntrl {   
    public Id TaskReportId { get; set; }
    public Id IncidentReportId { get; set; }
    public Id MileStoneReportId  { get; set; }
    public Id CPReportId  { get; set; }
    public Id IncidentsByType{get;set;}   
    public Id LessonsLearned{get;set;}
    public Id AccessRequest {get;set;}
    public id MISID{get;set;}
    public MIS__c MIS{get;set;}
    Public String SOE_Names{get;set;}
    public string statusmsg{get;set;}

    public MIS_DashBoards_Cntrl(){
       Try{
        MISID= ApexPages.CurrentPAge().getParameters().get('Id');
        if(Utils.isAccessible('i8__MIS__c') && Utils.isAccessible('i8__SOE__c')) {
            MIS=[select id,Name,(select id,name from SOEs__r),MIS_PlannedEnd__c,MIS_PlannedStart__c,MIS_Title__c from MIS__c where id=:MISID];
        SOE_Names = '';
        If(MIS.SOEs__r.size() > 0){
            Integer i=1;
            For(SOE__c SOE : MIS.SOEs__r){
                If(i != MIS.SOEs__r.size())
                    SOE_Names += SOE.Name+',';
                Else
                    SOE_Names += SOE.Name;
                i++;
            }
        }
        if(Schema.SObjectTYpe.Report.isAccessible()){
        taskreportId  = [Select Id, Name From Report Where name='Task Status Report IN SOE'].Id;
        IncidentReportId  = [Select Id, Name From Report Where name='MIS Incidents By Status'].Id;
        MileStoneReportId  = [Select Id, Name From Report Where name='Milestone Tasks Report in SOE'].Id;
        CPReportId  = [Select Id, Name From Report Where name='Critical Path Tasks in SOE'].Id;
        IncidentsByType= [Select Id, Name From Report Where name='MIS Incidents By Type'].Id;       
        LessonsLearned = [Select Id, Name From Report Where name='Lessons Learned'].Id;
        AccessRequest = [Select Id, Name From Report Where name='SOE With AccessRequests'].Id;
        Reports.ReportDescribeResult descRes = Reports.ReportManager.describeReport(IncidentsByType);
        }
        }else statusmsg = System.Label.ADMIN001;
        }catch(Exception e){
           statusmsg = e.getMessage();                  
        }
    }
     public pagereference openCancel(){
        return new pagereference ('/apex/MIS_AllTasks?id='+MISID);
    } 
    public pagereference OpenReport(){
       return new pagereference('/apex/Report?id='+MISID+'&url='+taskreportId  );
    }    
}