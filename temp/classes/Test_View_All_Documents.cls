@istest
 public class Test_View_All_Documents{
 i8Constants i8 = new I8Constants();
 Static testmethod void View_All_Documents(){
           SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1'); 
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');       
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp1234',service1.Id,true,true,false,false); 
        System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp1234');  
        MIS__c mis1 = SOEUtility.MIS_Insert('dds');
        System.assertEquals(mis1.MIS_Title__c , 'dds');
        soe1.MIS__c = mis1.id;
        update soe1;        
        Task__c Task1=SOEUtility.Task_Insert('pre','taskt',false,'1.3',SOE1.id,'Implementation',0,0,5,false);        
        Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=Task1.id;
        insert attach;
        
        Test.starttest();
            apexpages.currentpage().getparameters().put('id',SOE1.id); 
            View_All_Documents_Cntrl viewDocuments= new View_All_Documents_Cntrl();
            viewDocuments.CancelTask();       
            
            apexpages.currentpage().getparameters().put('id',mis1.id); 
            viewDocuments= new View_All_Documents_Cntrl();
            viewDocuments.CancelTask();
        Test.stoptest();
        
     }
 }