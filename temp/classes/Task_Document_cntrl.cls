/* 
Class Name        : Task_Document_cntrl 
Test Class Name   : Test_Task_Document
Purpose/Overview  : To add attachment to the task. 
Author            : Purview Ltd.
Code Coverage     : 93%
Change History    : 

*/
public with sharing class Task_Document_cntrl {
    public string page{get;set;}
    public string fileName{get;set;}     
    public Transient Blob fileBody {get;set;}  
    public Id recId {get;set;} 
    public id ParentId{get;set;} 
    public Task__c task{get;set;}
    Public SOE__c SOE{get;set;}
    public string AttId{get;set;}
    public list<Attachment>AttachList{get;set;} 
    public boolean checkerror{get;set;}    
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public string errormsg{get;set;}
    public string AcceptedDocType {get;set;}
    public Integer FileSize{get;set;}
    Id SOEId;
    
    public Task_Document_cntrl(ApexPages.StandardController controller){
        recId =controller.getRecord().Id; 
        page = ApexPages.currentPage().getParameters().get('page');
        SOEId = ApexPAges.CurrentPage().getParameters().get('SId');
        AcceptedDocType = SystemSettings_Util.getSystemSettings().get('Accepted_Document_Types');
        checkerror = false;
        errormsg = null;
        if(Utils.isAccessible('i8__Task__c') && Schema.SobjectType.Attachment.isAccessible()){
            task=[select id,ID_Text__c,Stage__c,Stage_Level__c,Task_Title__c,soe__c,Id_Before_Decimal__c,soe__r.SOE_Title__c,soe__r.Status__c,soe__r.Name from Task__c where id=:recId ];
            if(Utils.isAccessible('i8__SOE__c'))
                SOE = [select id,name,SOE_Title__c,Status__c,Max_End_Time__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Max_Planned_End__c from SOE__c where id =: Task.SOE__c];
            ImpMgrMap = new Map<Id,Id>();
            list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
                for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: Task.soe__c  and Access_Level__c != 'Read' and Role__r.Reference_Role__c  IN: RolesLIst ])  
                    ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
            if(Schema.SObjectType.Profile.isAccessible())
                if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                    ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
            ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');        
            AttachList = [select id,Name,BodyLength,ownerid,createddate,ContentType  from Attachment where parentid=: task.Id order by createddate desc limit 1000]; 
        }else errormsg = System.Label.ADMIN001 ;
    }
    public pagereference  upload() {
        if(Schema.SOBjectType.Attachment.isCreateable()){
            Savepoint sp = Database.setSavepoint();
            try{         
                if(fileName != null && AcceptedDocType.contains(filename.substringAfterLast('.')) && FileSize > 0){
                    Attachment myAttachment  = new Attachment();
                    checkerror = false;  
                    errormsg = null;
                    myAttachment.Name = fileName;
                    myAttachment.Body = fileBody;             
                    myAttachment.ParentId = recId;
                    if(myAttachment.Body == null){
                        checkerror = true;
                        errormsg = System.Label.SOEAttachment003;
                    } 
                    else{ 
                        LogFactory.debug('Task_Document_Cntrl', 'Upload', 'Attachment', 'Attachment got Successfully','Line - 55'); 
                        if(Schema.SobjectType.Attachment.isCreateable())
                            insert myAttachment; 
                        filename = null;
                        filebody = null;                      
                        if(Schema.SOBjectType.Attachment.isAccessible())
                        AttachList = [select id,Name,BodyLength,ownerid,createddate,ContentType  from Attachment where parentid=: task.Id order by createddate desc];               
                    }
                }
                else if(FileSize == 0){
                    checkerror = true;
                    errormsg = System.Label.SOEAttachment006;
                }
                else{
                    checkerror = true;
                    errormsg = System.label.SOEAttachment003+' '+AcceptedDocType+' and FileSize must be less than 10MB'; 
                }
            }catch(Exception e){
                Database.rollback(sp);
                LogFactory.error('Task_Document_Cntrl', 'Upload', '', e.getMessage() + '' + e.getStackTraceString());           
                checkerror = true;
                errormsg = e.getMessage();                  
            }
        }else errormsg = System.Label.ADMIN001;
        LogFactory.SaveLog(); 
        return null;
    }    
    public pagereference delete_attachment(){
        if(Schema.SOBjectTYpe.Attachment.isDeletable() && Schema.SOBjectType.Attachment.isAccessible()){
            Savepoint sp = Database.setSavepoint();
            try{
                Attachment delAttachment  = new Attachment();
                delAttachment = [select id from Attachment where id =: AttId limit 1]; 
                if(Schema.SOBjectType.Attachment.isDeletable())
                    delete delAttachment;    
                AttachList = [select id,Name,BodyLength,ownerid,createddate,ContentType  from Attachment where parentid=: task.Id order by createddate desc limit 1000];
            }catch(Exception e){
                Database.rollback(sp);
                LogFactory.error('Task_Document_cntrl', 'delete_attachment', '', e.getMessage() + '' + e.getStackTraceString());  
                LogFactory.SaveLog(); 
                checkerror = true;
                errormsg = e.getMessage();                  
            }
        } else errormsg = System.Label.ADMIN001;
        return null;
    }
    public pagereference close_action(){
        if(page=='EditStack' && Utils.isAccessible('i8__Task__c')){
            task__c tas = [select id,Id_Before_Decimal__c,SOE__c from task__c where IS_STack__c = true and SOE__C =: task.SOE__c and Stage__c =: task.Stage__c and Id_Before_Decimal__c =: task.Id_Before_Decimal__c ];
            return new PageReference('/apex/EditStack_ClientSide?id='+tas.id +'&SId='+task.SOE__c);
        }
        else if(page=='Modify_Task'){
            Id MISID = ApexPages.CurrentPage().getParameters().get('Mid');
            if(MISID == null)
                return new PageReference('/apex/ModifyTask_ClientSide?id='+recId+'&Sid='+task.SOE__c +'&level='+task.Stage_Level__c+'&page=edit');
            else
                return new PageReference('/apex/ModifyTask_ClientSide?id='+recId+'&Mid='+MISID +'&level='+task.Stage_Level__c+'&page=edit');
        }
        else{
            Id MISID = ApexPages.CurrentPage().getParameters().get('Mid');
            if(MISID != null)
                return new PageReference('/apex/MIS_AllTasks?id='+MISID );
            else
                return new PageReference('/apex/AllTasks_ClientSide?id='+SOEId ); 
        }       
    }
}