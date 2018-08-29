/* 
Class Name        : Import_SOE_Tasks_Cntrl 
Test Class Name   : Test_Import_SOE_Tasks_Cntrl
Purpose/Overview  : To import tasks to already existing SOE or create new SOE from this page and then import tasks
Author            : Purview Ltd.
Code Coverage     : 84%
Change History    : 

*/
public with sharing class Import_SOE_Tasks_Cntrl {
    public boolean renSOEFields{get;set;}
    public boolean hidefields{get;set;}
    public String Seact_ip{get;set;}
    public String selected_SOE{get;set;}
    public List<SelectOption> SOE_Options{get;set;}
    public string nameFile{get;set;}
    public Transient Blob contentFile{get;set;}
    public List<SOE__c> SOE_Rec{get;set;}
    public String[] filelines = new String[]{};
    Public String sid{get;set;}
    public SOE__c soe_rec_det;
    Public Map<Id,SOE__c> SOE_Map;
    Public Set<Id> SOEIds;
    public i8Constants i8;
    public Boolean SOE_Access;
    public Boolean SOE_Task_Access{get;set;}
    
    public Import_SOE_Tasks_Cntrl(){
        SOE_Access = Utils.isAccessible('I8__SOE__c');
        SOE_Task_Access = SOE_Access && Utils.isAccess_Create_Update('I8__Task__c');
        if(SOE_Task_Access == false){
        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
        SOE_Rec = new List<SOE__c>();
        i8 = new I8Constants();
        SOEIds = New Set<Id>();
        soe_rec_det = new SOE__c();
        soe_rec_det.Status__c = 'Build';
        SOE_Rec.add(soe_rec_det);
        renSOEFields = true;
        hidefields  = false;
        SOE_Map = New Map<id,soe__c>();
        getSOEOptions();
    }
    public List<SelectOption> getSOEOptions(){
        SOE_Options = new List<SelectOption>();
        if(SOE_Access){
            if(Schema.sObjectTYpe.SOE__Share.isAccessible())
            For(SOE__Share Share : [select id,parentid from soe__share where accessLevel != 'read' and userorgroupid =: userinfo.getuserid()])
                SOEIds.add(Share.parentid);
            for(SOE__c soe : [select id,Name,SOE_Title__c,Status__c from SOE__c where id IN : SOEIds and Is_Template__c = false order by name desc]){
                SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
                SOE_Map.put(soe.id,soe);
            }
            return SOE_Options;
        }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
        return null;
    }
    public void SOE_List(){
      if(SOE_Access){
        selected_SOE = '';
        SOE_Options = new List<SelectOption>();
        String val ='%'+Seact_ip+'%';
        for(SOE__c soe : [select id,Name,SOE_Title__c,Status__c from SOE__c where id IN : SOEIds and SOE_Title__c Like: val and Is_Template__c = false]){
            SOE_Options.add(new selectoption(soe.id,soe.Name+' - '+soe.SOE_Title__c));
            SOE_Map.put(soe.id,soe);
        }
        If(SOE_Options.size() == 0){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport002);
            ApexPages.addMessage(errormsg);
        }
       }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
    }
    List<Task__c> taskupload;
    public Pagereference ReadFile(){
        if(SOE_Task_Access){
        sid = '';
        String TaskID;
        String status;
        if(selected_soe == '' || selected_soe == null){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.CloneSOE007);
            ApexPages.addMessage(errormsg);
        }
        Else{
            If( SOE_Map.get(selected_soe).Status__c != i8.STATUS_BUILD && SOE_Map.get(selected_soe).Status__c != i8.STATUS_REVIEW && SOE_Map.get(selected_soe).Status__c != i8.STATUS_SCHEDULED && SOE_Map.get(selected_soe).Status__c != i8.STATUS_FREEZE ){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.AddTask002);
                ApexPages.addMessage(errormsg);
            }
            else If(contentFile == Null || namefile.right(4) != '.csv'){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport001);
                ApexPages.addMessage(errormsg);
            }
            else{  
                Savepoint sp = Database.setSavepoint();
                try{   
                    string s;
                    nameFile=contentFile.toString();
                    filelines = nameFile.split('\n');
                    for (Integer i=4;i<filelines .size();i++){
                        String[] inputvalues = new String[]{};
                            inputvalues = filelines[i].split(',');
                        Task__c tas = new Task__c();                       
                        if(inputvalues[12].trim().length() >= 15){
                            TaskId = inputvalues[12].trim();
                            break;
                        }
                    }
                    Task__c TAS = [Select id,SOE__c from task__c where id =: TaskId];
                    If(Tas != Null && TAS.SOE__c != selected_soe){
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport003);
                        ApexPages.addMessage(errormsg);
                    }
                    else{
                        if(filelines.Size()> 2504){
                            UploadTasksFuture(filelines,selected_soe,SOE_Map.get(selected_soe).SOE_Title__c);
                            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,System.Label.SOEImport004);
                            ApexPages.addMessage(errormsg);
                        }
                        else{
                            UploadTasks(filelines,selected_soe,SOE_Map.get(selected_soe).SOE_Title__c);
                            return new pagereference('/'+selected_soe);
                        }
                    }
                }
                catch(Exception e){
                    Database.rollback(sp);
                    LogFactory.error('Import_SOE_Tasks_Cntrl ', 'ReadFile', '', e.getMessage() + '' + e.getStackTraceString());  
                    LogFactory.SaveLog(); 
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                    ApexPages.addMessage(errormsg);                  
                } 
            }
        }
        }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
        return null;
    }
    public void ClrStr(){
        Seact_ip = '';
        selected_SOE = '';
        getSOEOptions();
    }    
    public void Create_SOE(){
        if(Utils.isAccess_Create_Update('I8__SOE__c')){
        if(SOE_Rec != null){
            if(string.isblank(SOE_Rec[0].SOE_Title__c)){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.CloneSOE001);
                ApexPages.addMessage(errormsg);
            }
            else if(!string.isblank(SOE_Rec[0].SOE_Title__c)){
                Integer SOE_Title = [Select count() from soe__c where SOE_Title__c =: SOE_Rec[0].SOE_Title__c];
                If(SOE_Title > 0){
                    ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport005);
                    ApexPages.addMessage(errormsg);
                }
                Else{
                    try{
                        LogFactory.info('Import_SOE_Tasks_Cntrl', 'CreateSOE', 'SOE', JSON.Serialize(SOE_Rec),'Line - 131');
                        if(Utils.isCreate_Update('i8__SOE__c'))
                            Upsert SOE_Rec;
                        SOE_Map.put(SOE_Rec[0].id,SOE_Rec[0]);
                        selected_soe = SOE_Rec[0].id;
                        renSOEFields = false;
                        hidefields  = true;
                    }
                    catch(exception e){
                        LogFactory.error('Import_SOE_Tasks_Cntrl', 'CreateSOE', '', e.getMessage() + '' + e.getStackTraceString());
                        ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                        ApexPages.addMessage(errormsg);    
                    }
                    LOgFactory.SaveLog();
                }
            }
        }
        }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
    }
    public void Edit_SOE(){
        renSOEFields = true;
    }
    @future
    public static void UploadTasksFuture(list<String> Lines,String selected_soe,string title){
    try{
        UploadTasks(Lines,selected_soe,title);
        if(Schema.sObjectType.User.isAccessible()){
        Messaging.Singleemailmessage theEmails = new Messaging.Singleemailmessage();  
        list<string> Addresses = new list<String>();
        Addresses.add([select id,name,Email from User where id=: UserInfo.getUserId()].Email);          
        theEmails.setToAddresses(Addresses) ;
        string body = '<html><b> SOE Title :</b>'+title;
        body += '<br/>Tasks imported successfully to this SOE. </html>';
        theEmails.setSubject('Tasks import Completed'); 
        theEmails.setHtmlBody(body);
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {theEmails});
         }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}
        }
        catch(Exception e){
            system.debug('---------'+e.getMessage());
        }
    }
    public static void UploadTasks(list<String> Lines,string selected_soe,string title){
        list<Task__c> taskupload = new List<Task__c>();
        SavePOint sp = Database.SetSavePOint();
        try{ 
            if(Utils.isAccess_Create_Update('I8__Task__c')){                   
            for (Integer i=4;i<Lines.size();i++){
                String[] inputvalues = new String[]{};
                    inputvalues = Lines[i].split(',');
                Task__c tas = new Task__c();
                tas.Stage_Level__c = inputvalues[0];
                tas.Status__c = inputvalues[1];  
                tas.Stage__c = inputvalues[2];                 
                tas.ID_Text__c = inputvalues[3].substring(1,inputvalues[3].length());
                tas.Task_Title__c = inputvalues[4];
                tas.Days__c = decimal.valueOF(inputvalues[5].trim());
                tas.Hours__c = decimal.valueOF(inputvalues[6].trim());
                tas.Minutes__c = decimal.valueOF(inputvalues[7].trim());                      
                tas.SOE__c = selected_soe;
                if(inputvalues[8] == 'false')
                    tas.Is_Stack__c = false;
                else
                    tas.Is_Stack__c = true;
                if(inputvalues[9] == 'false')
                    tas.End_Stack__c = false;
                else
                    tas.End_Stack__c = true;
                tas.Description__c = inputvalues[10].trim();
                tas.Technical_Detail__c = inputvalues[11].trim();
                if(inputvalues[12].trim().length() >= 15)
                    tas.Id = inputvalues[12].trim();
                if(tas.Is_Stack__c == true)
                    tas.Status__c = null;
                taskupload.add(tas);                        
            } 
            if(taskupload.size() > 0 && Utils.isCreate_Update('i8__Task__c'))
                upsert taskupload;
          }else{ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg);}          
        }catch (Exception e)
        {
            Database.RollBack(sp);
            LogFactory.error('Import_SOE_Tasks_Cntrl', 'UploadTasks', '', e.getMessage() + '' + e.getStackTraceString());
            LogFactory.SaveLog();
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.SOEImport007);
            ApexPages.addMessage(errormsg);
            if(Utils.isAccessible('User')){
            Messaging.Singleemailmessage theEmails = new Messaging.Singleemailmessage();  
            list<string> Addresses = new list<String>();
            Addresses.add([select id,name,Email from User where id=: UserInfo.getUserId()].Email);          
            theEmails.setToAddresses(Addresses) ;
            string body = '<html><b> SOE Title: '+title ;
            body += '<br/>An error has occured. Please check the Template.</html>';
            theEmails.setSubject('Tasks import Failed'); 
            theEmails.setHtmlBody(body);
            try{
                Messaging.reserveSingleEmailCapacity(1);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {theEmails});
            }
            catch(Exception e1){                
                system.debug('---------'+e1.getMessage());
            }
          }else{ApexPages.Message errormsg1 = new ApexPages.Message(ApexPages.severity.ERROR,System.Label.ADMIN001);ApexPages.addMessage(errormsg1);}  
        }                
    }
    public pagereference CancelSOE(){
        return new pagereference('/'+SOE__c.sobjecttype.getDescribe().getKeyPrefix()+'/o');
    }
}