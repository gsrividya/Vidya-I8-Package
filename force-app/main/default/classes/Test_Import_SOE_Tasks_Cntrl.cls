@isTest
public class Test_Import_SOE_Tasks_Cntrl{
    @testSetup static void setup() {
        SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOETESTSOE1212',service1.Id,false,false,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOETESTSOE1212');
    }
    static TestMethod void Test_Import_SOE_Tasks_Cntrl(){
        Department__c  service1 = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOETESTSOE',service1.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOETESTSOE');
        list<Task__c> tas =[select id from Task__c where SOE__C =: soe.id];
        
        Test.StartTest();
        Import_SOE_Tasks_Cntrl imp_tas_cntrl = new Import_SOE_Tasks_Cntrl();
        imp_tas_cntrl.Seact_ip = 'SOETEST213';
        imp_tas_cntrl.SOE_List();
        imp_tas_cntrl.Seact_ip = 'SOETESTSOE';
        imp_tas_cntrl.SOE_List();
        imp_tas_cntrl.ReadFile();
        imp_tas_cntrl.soe_rec_det.SOE_Title__c = 'SOETESTSOE';
        imp_tas_cntrl.soe_rec_det.Baseline_Start__c = system.now();
        imp_tas_cntrl.Create_SOE();
        imp_tas_cntrl.soe_rec_det.SOE_Title__c = 'SOETESTSOE_NEW';
        imp_tas_cntrl.soe_rec_det.Baseline_Start__c = system.now();
        imp_tas_cntrl.Create_SOE();
        imp_tas_cntrl.Edit_SOE();
        imp_tas_cntrl.ClrStr();
        imp_tas_cntrl.selected_soe = SOE.id;
        String Task = 'Implementation,Build,Imp,1.2,Task Insert,1,2,3,false,false,null,null,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,false,false,null,null,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,true,true,null,null,'+tas[0].Id+'\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,false,false,null,null,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,false,false,null,null,'+tas[0].Id+'';
        Blob csvfile = Blob.valueof(Task);
        imp_tas_cntrl.nameFile = 'file.csv';
        imp_tas_cntrl.contentFile = csvfile;
        imp_tas_cntrl.ReadFile();
        imp_tas_cntrl.selected_soe = null;
        String Task1 = 'Implementation,Build,Imp,1.2,Task Insert,1,2,3,false,false\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,false,false,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,true,true,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,true,true,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,true,true,null\nImplementation,Build,Imp,1.3,Task Insert,1,2,3,false,false,null';
        Blob csvfile1 = Blob.valueof(Task1);
        imp_tas_cntrl.contentFile = csvfile1;
        imp_tas_cntrl.ReadFile();        
        Test.StopTest();
    }
    static TestMethod void Test_Import_SOE_Tasks_Cntrl1(){
        Department__c  service1 = SOEUtility.Dep_Insert('Service3');
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='SOETESTSOE1212']; 
        System.assertEquals(SOE.SOE_Title__c , 'SOETESTSOE1212');
        list<Task__c> tas = [select id from TAsk__C where SOE__c =: soe.id order by Id_Before_Decimal__c,Id_After_Decimal__c];
        
        Test.StartTest();
        Import_SOE_Tasks_Cntrl imp = new Import_SOE_Tasks_Cntrl();
        imp.Seact_ip = 'SOETESTSOE1212';
        imp.SOE_List();
        imp.selected_soe = soe.id; 
         String Task = 'aaa\nbbb\nccc\nddd\nImplementation,Build,Imp,1.0,Task Insert,1,2,3,true,false,null,null,'+tas[0].id+'\nImplementation,Build,Imp,1.1,Task Insert,1,2,3,false,false,null,null,'+tas[1].id+'\nImplementation,Build,Imp,1.2,Task Insert,1,2,3,false,true,null,null,'+tas[2].Id+'';
        Blob csvfile = Blob.valueof(Task);
        imp.nameFile = 'file.csv';
        imp.contentFile = csvfile;
        imp.ReadFile();
        string nameFile = imp.contentFile.toString();
        string[] filelines = nameFile.split('\n');
        Import_SOE_Tasks_Cntrl.UploadTasksFuture(filelines ,soe.id,soe.SOE_Title__c);
         imp.contentFile = null;
        imp.ReadFile();
        soe.Status__c  ='SOE Completed';
        update soe;
        imp = new Import_SOE_Tasks_Cntrl();
        imp.Seact_ip = 'SOETESTSOE1212';
        imp.SOE_List();
        imp.selected_soe = soe.id; 
        imp.ReadFile();
         SOE__c SOE1 = SOEUtility.SOE_Insert('SOETESTSOE121223',service1.Id,false,false,false,false);
          imp.getSOEOptions();
          imp.selected_soe = soe1.id; 
         Task = 'aaa\nbbb\nccc\nddd\nImplementation,Build,Imp,1.0,Task Insert,1,2,3,true,false,null,null,'+tas[0].id+'\nImplementation,Build,Imp,1.1,Task Insert,1,2,3,false,false,null,null,'+tas[1].id+'\nImplementation,Build,Imp,1.2,Task Insert,1,2,3,false,true,null,null'+tas[2].Id+'';
        csvfile = Blob.valueof(Task);
        imp.nameFile = 'file.csv';
        imp.contentFile = csvfile;
        imp.ReadFile();
        imp.CancelSOE();
        Test.StopTest();
    }
}