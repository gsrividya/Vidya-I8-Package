@istest
public class Test_Task_Document{
    static testmethod void Task_Document(){        
        Department__c  service1 = SOEUtility.Dep_Insert('Service1'); 
        SOEUtility.SystemSettings_Insert(); 
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');       
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,false,false); 
        User user1 = SOEUtility.USer_Insert('user--27--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--27--@gmail.com'];
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe1.id,role.id);       
        System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
        Task__c Task1=SOEUtility.Task_Insert('pre','taskt',false,'1.3',SOE1.id,'Implementation',0,0,5,false);
        Test.StartTest();
            ApexPages.currentPage().getParameters().put('id',Task1.id);     
            ApexPages.StandardController TaskDoc= new ApexPages.StandardController(Task1);
            Task_Document_cntrl TaskDocument = new Task_Document_cntrl(TaskDoc); 
            TaskDocument.upload(); 
            TaskDocument.fileName='abc.docx';
            string mystring='stringtoblob';
            TaskDocument.fileBody=Blob.valueof(mystring);
            TaskDocument.FileSize =1;
            TaskDocument.upload(); 
            TaskDocument.AttId = [select id from Attachment where Parentid =: Task1.id limit 1].id; 
            TaskDocument.Parentid = Task1.id;
            TaskDocument.delete_attachment();  
            TaskDocument.page = 'EditStack';
            TaskDocument.close_action(); 
            TaskDocument.page = 'SOE';
            TaskDocument.close_action();
            TaskDocument.page = 'Modify_Task';
            TaskDocument.close_action();           
            MIS__c mis = SOEUtility.MIS_Insert('adasda');
            ApexPages.currentPage().getParameters().put('Mid',mis.id);   
            TaskDocument.close_action();  
            TaskDocument.page = null;
            TaskDocument.close_action();
            TaskDocument.AttId= null;  
            TaskDocument.delete_attachment();  
        Test.StopTest();
    }     
}