@istest
public class Test_newSOEteammember{
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Department__c  service1 = SOEUtility.Dep_Insert('Service1');
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,false,false); 
           System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
    }
    static Testmethod void newSOEteammember_Cntrl(){
        Test.StartTest();  
        role__c role = [select id from Role__c where Reference_Role__c = 'Imp Manager' limit 1];      
        SOE__c SOE1 = [Select id,SOE_Title__c from SOE__c where SOE_Title__c = 'newsoetemp' limit 1];
        System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
        ApexPages.currentPage().getParameters().put('id',SOE1.id);
        newSOEteammember_cntrl soeteammember = new newSOEteammember_cntrl();
        user user1 = SOEUtility.user_insert('user--2@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--2@gmail.com'];
        user user2 = SOEUtility.user_insert1('user--3@gmail.com');
        Member__c member2 = [select id from Member__c where Email__c ='user--3@gmail.com'];
        soeteammember.wrapperlist[0].Teammember.Team_Member__c = member1.id;
        soeteammember.wrapperlist[0].Teammember.Access_Level__c = 'Edit';
        soeteammember.wrapperlist[0].Teammember.Role__c = Role.Id;
        soeteammember.save();
        soeteammember.EntryCount = 1;
        soeteammember.Additem();        
        soeteammember.wrapperlist[1].Teammember.SOE__c = SOE1.id; 
        soeteammember.wrapperlist[1].Teammember.Team_Member__c = member1.id;
        soeteammember.wrapperlist[1].Teammember.Access_Level__c = 'Edit';
        soeteammember.wrapperlist[1].Teammember.Role__c = Role.Id;
        soeteammember.save();
        soeteammember.MemberId = 0;
        soeteamMember.HavingSalesforceUser();       
        soeteammember.EntryCount = 2;   
        soeteammember.Additem();        
        soeteammember.wrapperlist[2].Teammember.SOE__c = SOE1.id; 
        soeteammember.wrapperlist[2].Teammember.Team_Member__c = member1.id;
        soeteammember.wrapperlist[2].Teammember.Access_Level__c = 'Edit';  
        soeteammember.wrapperlist[2].Teammember.Role__c = Role.Id;  
        soeteammember.EntryCount = 2;   
        soeteammember.delitem();
        soeteammember.Additem();        
        soeteammember.EntryCount = 0;
        soeteammember.delitem();
        soeteammember.EntryCount = 1;
        soeteammember.Additem();        
        soeteammember.wrapperlist[1].Teammember.SOE__c = SOE1.id; 
        soeteammember.wrapperlist[1].Teammember.Team_Member__c = member1.id;
        soeteammember.wrapperlist[1].Teammember.Access_Level__c = 'Edit';
        soeteammember.wrapperlist[1].Teammember.Role__c = Role.Id;
        soeteammember.save();
        soeteammember = new newSOEteammember_cntrl();
        soeteammember.MemberId = 1;
        soeteamMember.HavingSalesforceUser();
        soeteammember.cancel();  
        Test.StopTest();   
    }
    static Testmethod void newSOEteammember_Cntrl1(){
        Test.StartTest();
            role__c role = [select id from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
            SOE__c SOE1 = [Select id,SOE_Title__c from SOE__c where SOE_Title__c = 'newsoetemp' limit 1]; 
            System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
            ApexPages.currentPage().getParameters().put('id',SOE1.id);
            newSOEteammember_cntrl soeteammember = new newSOEteammember_cntrl();
            user user1 = SOEUtility.user_insert('user--2@gmail.com');
            Member__c member1 = [select id from Member__c where Email__c ='user--2@gmail.com'];
            soeteammember.EntryCount = 1;
            soeteammember.Additem();
            soeteammember.save();
            soeteammember.wrapperlist[0].Teammember.Team_Member__c = member1.id;
            soeteammember.wrapperlist[0].Teammember.Access_Level__c = 'Edit';
            soeteammember.wrapperlist[0].Teammember.Role__c = Role.Id;
            soeteammember.save();
            soeteammember.EntryCount = 1;
            soeteammember.Additem();
            soeteammember.wrapperlist[1].Teammember.Team_Member__c = member1.id;
            soeteammember.Additem();
            soeteammember.save();
            Member__c member12 = new Member__c(Name = 'abc123',Email__c = 'abs@123.com',Phone__c = '1234566656');
            insert member12;
            soeteammember.wrapperlist[0].Teammember.Team_Member__c = member12.id;
            soeteammember.MemberId = 0;
            soeteammember.HavingSalesforceUser();   
            soeteammember.EntryCount = 1;
            soeteammember.wrapperlist[0].Teammember.Team_Member__c = member1.id; 
            soeteammember.Additem();
            soeteammember.wrapperlist[1].Teammember.Team_Member__c = soe1.id; 
            soeteammember.wrapperlist[1].Teammember.Access_Level__c = 'Edit';
            soeteammember.wrapperlist[1].Teammember.Role__c = Role.Id;      
            soeteammember.Save();
            SOE_Team_Member__c tm = [select id from SOE_TEam_Member__c where SOE__c =: soe1.id limit 1];
            delete tm;
            soeteammember.EntryCount = 0;    
            soeteammember.delitem(); 
        Test.StopTest();
    }
}