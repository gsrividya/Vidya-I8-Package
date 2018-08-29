@istest
Public class Test_Search_and_Replace_cntrl {
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Search_and_Replace_cntrl(){
    SOEUtility.SystemSettings_Insert();
    Department__c service = SOEUtility.Dep_Insert('Service2');
    Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
    SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);  
    System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
    User user1 = SOEUtility.USer_Insert('user--36--@gmail.com');
    Member__c member1 = [select id from Member__c where Email__c ='user--36--@gmail.com'];
    SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
    list<Task__c> tas = [select id,Id_Text__c,Task_Title__c,Description__c,Technical_Detail__c from Task__c where SOE__c=: SOE .id order by Id_Before_Decimal__c,Id_After_Decimal__c];      
       tas[0].Description__c='decription';  
       update tas;
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
            Search_and_Replace_cntrl SR = new Search_and_Replace_cntrl();
             SR.SearchValue='pre';
             SR.Go_Method();
             SR.SearchValue='1.0';
             SR.Go_Method(); 
             SR.Go_Method();             
             SR.strng='pre';
             SR.cancel_method();
             SR.Replace_action();
             SR.Search_string='Pre-Imp Stack';
             SR.Replace_action();
             SR.Search_string='Pre-Imp Stack';
             SR.Replace='pre1';
             SR.TitleCheck=true;
             SR.selectall=true;
             SR.SelectAllCheckbox();
             SR.Replace_action();
             SR.Search_string='Pre-Imp Stack';
             SR.Replace='pre1';
             SR.selectall=true;
             SR.SelectAllCheckbox();
             SR.Technical_DetailCheck=true;
             SR.Replace_action();
             SR.Clear_Method();
             
             tas[0].Technical_Detail__c ='sap';
             update tas;
             SR=new Search_and_Replace_cntrl();
             SR.Search_string='';
             SR.Replace='hi';
             SR.DescriptionCheck=true;
             SR.selectall=true;
             SR.SelectAllCheckbox();
             SR.Replace_action(); 
                          
             SR.Search_string='sap';
             SR.Replace='hi';
             SR.Technical_DetailCheck=true;
             SR.selectall=true;
             SR.SelectAllCheckbox();  
             SR.Replace_action();                
             SR.Search_string='decription';
             SR.Replace='decription1';
             SR.str='decription';
             SR.STR1=true;
             SR.DescriptionCheck=true;             
             SR.selectall=true;
             SR.SelectAllCheckbox();
             SR.Replace_action();  
             SR.selectall=false;
             SR.SelectAllCheckbox();
             
            Test.StopTest();
    }
}