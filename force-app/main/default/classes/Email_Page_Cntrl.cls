/* 
Class Name        : Email_Page_Cntrl
Test Class Name   : Test_Email_Page
Purpose/Overview  : To send email to users  
Author            : Purview Ltd.
Code Coverage     : 93%
Change History    : 

*/
public with sharing class Email_Page_Cntrl{    
    public SOE__c SOE{get;set;}
    public list<Task__c> task{get;set;}
    public Map<Id,user> UserMap{get;set;}
    public list<Id> LeftUserList{get;set;}
    public list<Id> RightUserList{get;set;}
    public list<Id> LeftSelected{set;get;}
    public list<Id> RightSelected{get;set;}
    public string ExternalMails{get;set;}
    public string Title{get;set;}
    public String emailBody{get;set;}
    Public User curUser{get;set;}
    public string getid {get;set;}
    public boolean displayPopup {get; set;}
    public string selectaction{get;set;}
    public string page{get;set;} 
    public string ownermail{get;set;} 
    public string errormsg{get;set;}
    public Boolean SOE_Access;
    public Boolean Task_Access;
    public Boolean User_Access;  
    
    public Email_Page_Cntrl(){
        SOE_Access = Utils.isAccessible('I8__SOE__c');
        Task_Access = Utils.isAccessible('I8__Task__c');
        User_Access = Utils.isAccessible('User');
        errormsg = null;
        LeftUserList = new list<Id>();
        RightUserList = new list<Id>();
        UserMap = new Map<Id,user>();
        leftselected = new list<Id>();
        RightSelected = new list<Id>();
        selectaction = 'PDF';
        getid = ApexPages.CurrentPage().getParameters().get('Id');
        page = ApexPages.CurrentPage().getParameters().get('page');
        if(SOE_Access  && Task_Access && User_Access ){
        SOE = [select id,Name,SOE_Title__c,Summary__c,Baseline_Start__c,Conference_Call_No__c,Change_Record__c,Project__r.name,Programme__r.name,Department__r.name,BackOut_Stage__c,Post_Implementation_Stage__c,Pre_Implementation_Stage__c,State__c,Status__c From SOE__c where id =: getid];
        task = [select id,Stage_Level__c,SOE__r.SOE_Title__c,SOE__r.Name,Owner__r.Member__r.Email__c,Task_Title__c,Stage__c,Start_Time__c,Description__c,Duration__c,End_Time__c,State__c,ID_Text__c,Id_After_Decimal__c,Id_Before_Decimal__c,SOE__c,Status__c from task__c where SOE__c =: getid or SOE__r.MIS__c =: getid order by Id_Before_Decimal__c,Id_After_Decimal__c];
        Title = task[0].SOE__r.Name+': '+task[0].SOE__r.SOE_Title__c;
        for(Task__c tas : task){
            if(tas.Id_Text__c == ApexPAges.CurrentPage().getParameters().get('mail') && tas.Stage_Level__c == 'Implementation')
                ownermail = tas.Owner__r.Member__r.Email__c; 
        } 
        curUser = [select id,Name,email from user where id =: userinfo.getuserid()];
        for(User u: [select id, Name,Email from User where IsActive = true and id !=: userinfo.getuserid()]){
            UserMap.put(u.Id,u);
            LeftUserList.add(u.Id);
        }        
        ExternalMails = ownermail ;
        RightUserList.add(userinfo.getuserid());
        }else{errormsg = System.Label.ADMIN001;}
    }
    public list<SelectOption> getLeftUsers(){
        list<SelectOption> LeftList1 = new list<SelectOption>();
        for(Id i: LeftUserList){
            if(i == userinfo.getuserid())
                LeftList1.add(new SelectOption(i,CurUser.Name));
            else
                LeftList1.add(new SelectOption(i,UserMap.get(i).Name));
        }
        return LeftList1;
    }
    public list<SelectOption> getRightUsers(){
        list<SelectOption> RightList = new list<SelectOption>();
        for(Id i: RightUserList ){
            if(i == userinfo.getuserid())
                RightList.add(new SelectOption(i,CurUser.Name));
            else
                RightList.add(new SelectOption(i,UserMap.get(i).Name));
        }
        return RightList;
    }
    public void AddUsers(){
        errormsg = null;
        if(leftselected.size()>0){
            RightUserList.addAll(leftselected);
            for( integer i=0; i<LeftUserList.Size(); i++){
                for(Id j: leftselected){
                    if(LeftUserList[i] == j)
                        LeftUserList.remove(i);
                }
            }
        }
    }
    public void DeleteUsers(){
        errormsg = null;
        if(RightSelected.size()>0){
            LeftUserList.addAll(RightSelected);
            for( integer i=0; i<RightUserList .Size(); i++){
                for(Id j: RightSelected){
                    if(RightUserList [i] == j)
                        RightUserList .remove(i);
                }
            }
        }
    }
    public void AddAllUsers(){
         errormsg = null;
        if(LeftUserList.size()>0){
            RightUserList.clear();
            RightUserList.addAll(UserMap.keyset());
            LeftUserList.clear();
            RightUserList.add(userinfo.getuserid());
        }
    }
    public void DeleteAllUsers(){
         errormsg = null;
        if(RightUserList.size()>0){
            LeftUserList.clear();
            LeftUserList.addAll(UserMap.keyset());
            RightUserList.clear();
            LeftUserList.add(userinfo.getuserid());
        }
    }
    public pagereference SendMail(){
    if(SOE_Access  && Task_Access && User_Access ){
        errormsg = null;
        if( RightUserList.size() == 0  &&  ExternalMails == '')
            errormsg =System.Label.Email001;
        else if(emailbody == '' || emailbody == null )
            errormsg = System.Label.Email002;
        else {
            if(page != 'comm')
                displayPopup = true;
            else{
                Pagereference pag1 = selectformat();
                return pag1;
            }
        }
        }else{errormsg = System.Label.ADMIN001;}
        return null;
    }
    public pagereference reset(){
    if(SOE_Access  && Task_Access && User_Access ){
        errormsg = null;
        RightUserList.clear();
        LeftUserList.clear();
        LeftUserList.addAll(UserMap.keyset());
        RightUserList.add(userinfo.getuserid());
        ExternalMails = '';
        emailBody = '';
        }else{errormsg = System.Label.ADMIN001;}
        return null;
    }
    public void ClearRightUsers(){
        if(SOE_Access  && Task_Access && User_Access ){
        errormsg = null;
        RightUserList.clear();
        LeftUserList.clear();
        LeftUserList.addAll(UserMap.keyset());
        RightUserList.add(userinfo.getuserid());
        }else{errormsg = System.Label.ADMIN001;}
    }
    public pagereference Cancel(){
        if(page == 'detail'){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+getid);
        }
        else
                return new pagereference('/apex/AllTasks_ClientSide?id='+getid);
        return null;
    }
    public list<selectoption> getselectformatoption(){
        list<selectoption> options = new list<selectoption>();
        options.add(new selectoption('PDF','PDF'));
        options.add(new selectoption('Excel','Excel'));
        return options;
    }
    public pagereference selectformat() {
      Savepoint sp = Database.setSavepoint();
        try{
        if(SOE_Access  && Task_Access && User_Access ){
        List<String> sendTo = new List<String>();
        string body='';
        if(RightUserList.size()>0){
            for(Id i: RightUserList){
                if(i == userinfo.getuserid())
                    SendTo.add(CurUser.Email);
                else
                    SendTo.add(UserMap.get(i).Email);
            }
        }
        if(ExternalMails != ''){
            List<String> SplitList = ExternalMails.split(',');
            SendTo.addAll(SplitList);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Integer count =0;
        if(page != 'comm'){
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            body+='<html><body><table background-color="blue" style="font-size:16px;"><tr><th colspan="8">'+SOE.Name+' : '+SOE.SOE_Title__c+'</th></tr></table>';
            body+='<table>';
            body+='<tr><th  align="left">Description</th><td >';
              if(SOE.Summary__c != null)
                body+=SOE.Summary__c;
              else 
                body+= '-' ;
            body+='</td></tr>';
            body+='<tr><th align="left">Baseline Start</th><td>'+SOE.Baseline_Start__c+'</td></tr>';
            body+='<tr><th align="left">Change Request No</th><td >';
                if(SOE.Change_Record__c != null)
                    body+=SOE.Change_Record__c;
                else
                    body+= '-' ;
            body+='</td></tr>' ;
            body+='<tr><th align="left">Audio Call No</th><td>';
                if(SOE.Conference_Call_No__c!= null)
                    body+=SOE.Conference_Call_No__c;
                else 
                    body+= '-' ;
            body+='</td></tr>' ;
            body+='<tr><th align="left">Department</th><td>';
                if(soe.Department__r.name != null && soe.Department__r.name != '')
                    body+=SOE.Department__r.Name;
                else 
                    body+= '-' ;
            body+='</td></tr>' ;
            body+='<tr><th align="left">Programme</th><td>';
                if(soe.programme__r.name != null && soe.programme__r.name != '')
                    body+=SOE.programme__r.name;
                else 
                    body+= '-' ;
            body+='</td></tr>' ;
            body+='<tr><th align="left">Project</th><td>';
                if(soe.project__r.name != null && soe.project__r.name != '')
                    body+=SOE.project__r.name;
                else 
                    body+= '-' ;
            body += '</td></tr></table><table><tr><td></td></tr></table></br></br></br>';
            body+='<table border="1"><div><tr><th>SOE Context</th><th>ID</th><th>Task Title</th><th>Stage</th><th>Start Time</th><th>Duration</th><th>End Time</th></tr></div>';
            for(task__c t : task)
                body+='<tr><td>'+t.Stage_Level__c+'</td><td>'+t.ID_Text__c+'</td><td>'+t.task_Title__c+'</td><td>'+t.Stage__c+'</td><td>'+t.Start_Time__c+'</td><td>'+t.Duration__c+'</td><td>'+t.End_Time__c+'</td></tr>';
            body += '</table></body></html>';
            
            if(selectaction == 'PDF'){
                attach.setContentType('application/pdf');
                attach.setFileName('SOE Record.pdf');
                attach.Body = Blob.toPDF(body);
            }
            else{
                attach.setContentType('application/vnd.ms-excel');
                attach.setFileName('SOE Record.xls');
                attach.Body = Blob.Valueof(body);
            }
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
        }
        mail.setToAddresses(sendTo);
        count += sendTo.SIze();
        mail.setSubject(Title);
        mail.setHtmlBody(emailBody);        
        mails.add(mail);
            Messaging.reserveSingleEmailCapacity(Count);
            Messaging.sendEmail(mails);
        
        if(page == 'detail'){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+getid);
        }
        else
            return new pagereference('/apex/AllTasks_ClientSide?id='+getid);
         }else{errormsg = System.Label.ADMIN001;}   
        }
        catch(Exception e){
            Database.rollback(sp);
            LogFactory.error('Email_Page_Cntrl', 'selectformat', '', e.getMessage() + '' + e.getStackTraceString());  
            LogFactory.SaveLog(); 
            errormsg = e.getMessage(); 
        }
        return null;
    }
    public void close(){
        displayPopup = false;
    }
}