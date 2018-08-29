/* 
Class Name        : Review_Cntrl 
Test Class Name   : Test_AllTasks_ClientSide_Cntrl
Purpose/Overview  : Complete QA Review and WalkThrough for an SOE. 
Author            : Purview Ltd.
Code Coverage     : 95%
Change History    : 

*/
public with sharing class Review_Cntrl {    
    Public list<task__c> TaskList{get;set;}
    Public list<task__c> QA_TaskList{get;set;}
    Public SOE__c SOE{get;set;}
    Public id SOEID{get;set;}
    public static boolean review_comp{get;set;}
    public i8Constants i8{get;set;}
    public set<String> EmailList = new set<String>();
    Public Integer NextPage{get;set;}
    Public Integer PrevPage{get;set;}
    Public boolean Next{get;set;}
    public String  statusmsg{get;set;}
    boolean Task_Access_Update;
    
    Public Review_Cntrl(){
        statusmsg = null;
        review_comp = false;
        i8 = new i8Constants();
        Next = true;
        TaskList = new list<task__c>();
        QA_TaskList = new list<task__c>();
        SOE = New SOE__c();
        SOEID = ApexPages.CurrentPage().getparameters().get('Id');
        Task_Access_Update = Utils.isAccess_Update('i8__Task__c');
        if(Task_Access_Update)
            TaskList = [select id,name,State__c,Stage__c,RV_Comments__c,WalkThrough_Comments__c,Status__c,ID_Text__c,Technical_Detail__c,Technical_Skills__c,Description__c,Task_Title__c,Start_Time__c,Duration__c,Review_Comments__c,End_Time__c,Stack_Owner_Name__c,Team__c from Task__c where SOE__c =: SOEID and Stage_Level__c=: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c limit 50000];
        if(Utils.isAccessible('i8__SOE__c'))
            SOE = [select id,name,State__c,QA_Manager__c,QA_Manager__r.FirstName,Owner.FirstName,SOE_Title__c,Status__c,Dealy_Ahead_mins__c,Max_End_Time__c,Max_Forecast_End__c,QA_Review_Required__c,Max_Planned_End__c,QA_Review__c,WalkThrough__c,WalkThrough_Required__c from SOE__c where id =: SOEID];
        NextPage = 0;
        Next();
    }
    
    Public void Next(){
        Integer j = NextPage;
        PrevPage = NextPage;
        NextPage = NextPage + 1000;
        If(NextPage > TaskList.size()){
            NextPage = TaskList.size();
            Next = false;
        }
        If(NextPage > 1000){
            TaskUpdate();
            QA_TaskList.clear();
        }
        For(Integer i=j; i<NextPage; i++){
            QA_TaskList.add(TaskList[i]);
        }
    }
    
    Public void Prev(){
        TaskUpdate();
        Next = true;
        QA_TaskList.clear();
        if(PrevPage > 1000){
            For(Integer i=(PrevPage-1000); i<PrevPage; i++)
                QA_TaskList.add(TaskList[i]);
            PrevPage = PrevPage - 1000;
        }
    }
    
    public Id getWorkItemId(Id targetObjectId){
        Id retVal = null;
        if(Schema.sObjectTYpe.ProcessInstanceWorkitem.isAccessible())
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: SOE.Id])
            retVal  =  workItem.Id;
        return retVal;
    }

    public pagereference QAComplete(){
        if(Task_Access_Update){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('QA Review Completed ');
            req.setAction('Approve');
            Id workItemId = getWorkItemId(SOE.Id);         
            if(workItemId == null)
                SOE.addError('Error Occured ');
            else        {
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
            }
            review_comp =true;
            TaskUpdate();
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEID);
        }else{LogFactory.debug('Review_Cntrl', 'QA Complete', 'Task Info ', System.Label.ADDTask007,'Line - 93');
        LogFactory.SaveLog();}
        return null;
    }
    
    public pagereference QAFeedBack(){
        if(Task_Access_Update){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('QA Review is under Feedback');
            req.setAction('Reject');
            Id workItemId = getWorkItemId(SOE.Id);         
            if(workItemId == null)
                SOE.addError('Error Occured ');
            else{    
                integer count =0;    
                req.setWorkitemId(workItemId);
                Approval.ProcessResult result =  Approval.process(req);
                if(Utils.isAccessible('i8__SOE_Team_Member__c'))
                for(SOE_Team_Member__c STM : [select id,name,Team_Member__r.Email__c from SOE_Team_Member__c where SOE__c =: SOE.Id and Role__r.Reference_Role__c= 'Imp Manager'])
                    EmailList.add(STM.Team_Member__r.Email__c);
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                list<string> AddList = new list<string>();
                AddList.AddAll(EmailList);
                mail.setToAddresses(AddList);
                mail.setSubject('QA Review Rejected for '+SOE.Name +':'+ SOE.SOE_Title__c);
                String body = 'Hi Imp Managers';
                body += '<br/>QA Review is Rejected  for '+ SOE.Name +':'+ SOE.SOE_Title__c +'<br/><br/> ';            
                body+= '<br/><br/> Regards,<br/>'; 
                    body+= '<b>'+UserInfo.getFirstName()+' '+UserInfo.getLastName()+'</b><br/>';  
                mail.setHtmlBody(body);
                mails.add(mail);
                count += AddList.SIze();
                Savepoint sp = Database.setSavepoint();
                try{
                    Messaging.reserveSingleEmailCapacity(Count);
                    Messaging.sendEmail(mails);
                }
                catch(Exception e){
                    Database.rollback(sp);
                    LogFactory.error('Review_Cntrl', 'QAFeedBack', '', e.getMessage() + '' + e.getStackTraceString());  
                    LogFactory.SaveLog(); 
                    statusmsg = e.getMessage();
                }
            }
            
            TaskUpdate();
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEID);
          }else{LogFactory.debug('Review_Cntrl', 'QA FeedBack', 'Task Info ', System.Label.ADDTask007,'Line - 140');
        LogFactory.SaveLog();}
        return null;
    }
    
    public pagereference WalkThroughComplete(){
        if(Task_Access_Update){
                Savepoint sp = Database.setSavepoint();
                try{
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('WalkThrough Completed');
                req.setAction('Approve');
                Id workItemId = getWorkItemId(SOE.Id); 
                if(workItemId == null)
                    SOE.addError('Error Occured ');
                else{       
                    req.setWorkitemId(workItemId);
                    Approval.ProcessResult result =  Approval.process(req);
                }
                if(Utils.isUpdateable('i8__Task__c'))
                update QA_TaskList;
                return new pagereference('/apex/AllTasks_ClientSide?id='+SOEID);
              }
                catch(Exception e){
                    Database.rollback(sp);
                    LogFactory.error('Review_Cntrl', 'WalkThroughComplete', '', e.getMessage() + '' + e.getStackTraceString());  
                    LogFactory.SaveLog(); 
                    statusmsg = e.getMessage();                  
               }
            }else{LogFactory.debug('Review_Cntrl', 'QA Complete', 'Task Info ', System.Label.ADDTask007,'Line - 168');
        LogFactory.SaveLog();}
           return null;    
        }
    public void TaskUpdate(){
        if(Task_Access_Update){    
              Savepoint sp = Database.setSavepoint();
                try{
                string comment;
                for(task__c tas : QA_TaskList){ 
                    if(tas.RV_Comments__c !=null){
                            comment = tas.Review_Comments__c; 
                            tas.Review_Comments__c ='';
                        if(string.isnotempty(comment))
                            tas.Review_Comments__c +=system.Now()+'-'+UserInfo.getFirstname()+':'+tas.RV_Comments__c+ '\n'+comment ;
                        else
                            tas.Review_Comments__c +=system.Now()+'-'+UserInfo.getFirstname()+':'+tas.RV_Comments__c; 
                        tas.RV_Comments__c ='';
                    }               
                }
                if(Utils.isUpdateable('i8__Task__c'))
                update QA_TaskList;
             }
             catch(Exception e){
                           Database.rollback(sp);
                           LogFactory.error('Review_Cntrl', 'TaskUpdate', '', e.getMessage() + '' + e.getStackTraceString());  
                           LogFactory.SaveLog(); 
                           statusmsg = e.getMessage();                  
            }  
         }else{LogFactory.debug('Review_Cntrl', 'QA Complete', 'Task Info ', System.Label.ADDTask007,'Line - 197');
        LogFactory.SaveLog();}
    }
    
    Public pagereference Cancel(){
        return new pagereference('/apex/AllTasks_ClientSide?id='+SOEID);
    }
}