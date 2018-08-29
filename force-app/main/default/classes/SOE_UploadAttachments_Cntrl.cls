/* 
Class Name        : SOE_uploadAttachments_cntrl
Test Class Name   : Test_SOE_uploadAttachments_cntrl
Purpose/Overview  : Upload Attachments of SOE.
Author            : Purview Ltd.
Code Coverage     : 100%.
Change History    : 
*/
public with sharing class SOE_UploadAttachments_Cntrl {
    public Boolean checkerror { get; set; }
    public Boolean checksuccess { get; set; }
    public Transient Blob fileBody { get; set; }
    public String fileName { get; set; }
    public ID SOEid { get; set; }
    public SOE__c SOE {get;set;}Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    
    public SOE_uploadAttachments_cntrl(){
        SOEid = Apexpages.currentpage().getparameters().get('id');
        if(Utils.isAccessible('i8__SOE__c'))
            SOE =[select id,name,SOE_Title__c,Status__c,Max_End_Time__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Max_Planned_End__c from SOE__c where id =: SOEid];
        ImpMgrMap = new Map<Id,Id>();
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(',');  
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEId  and Access_Level__c != 'Read'  and Role__r.Reference_Role__c  IN : RolesLIst])  
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        if(Schema.SOBjectTYpe.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', '');
    }
    public pagereference  upload() {
        if(Schema.sObjectType.Attachment.isCreateable()){
            Savepoint sp = Database.setSavepoint();
            try{ 
                String filetypeExtension = '.mp3,.mp4';
                if(filename !=null && filetypeExtension.contains(filename.substringAfterLast('.'))){ 
                    Attachment myAttachment  = new Attachment();  
                    checkerror = false;
                    checksuccess = False;      
                    myAttachment.Name = fileName;
                    myAttachment.Body = fileBody;             
                    myAttachment.ParentId = SOEid;     
                    if(myAttachment.Body == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.SOEAttachment003));
                        checkerror = true;
                        return null;
                    }else{
                        LogFactory.debug('SOE_UploadAttachments_Cntrl', 'Upload', 'Attachment', 'Attachment got Successfully','Line - 40');                       
                        if(Schema.SOBjectTYpe.Attachment.isCreateable())    
                            insert myAttachment; 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.confirm,System.Label.SOEAttachment004));           
                        filename = null;
                        filebody = null;  
                        checksuccess = true;      
                    }
                }
                else{
                    checksuccess = false;
                    checkerror = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,System.Label.SOEAttachment003)); 
                }
            }catch(Exception e){
                Database.rollback(sp);
                LogFactory.error('SOE_UploadAttachments_Cntrl', 'Upload', '', e.getMessage() + '' + e.getStackTraceString()); 
                checksuccess = true ;
                ApexPages.Message exceptionMessage = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                ApexPages.addMessage(exceptionMessage);              
            }
        } 
        else
            LogFactory.debug('SOE_UploadAttachments_Cntrl', 'Upload', 'Attachment', System.Label.ADMIN001,'Line - 72');           
        LogFactory.SaveLog();
        return null;
    }
    public pagereference CancelTask(){
        return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}