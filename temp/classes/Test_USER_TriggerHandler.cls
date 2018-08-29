@istest
Public class Test_USER_TriggerHandler{
    Public Static testmethod void User_Insert(){
           SOEUtility.SystemSettings_Insert();
    Test.StartTest();
       Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
       User u = new User(Alias = 'standt', Email='venkatesh.2630@gmail.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', Phone = '323232',UserName='rss@org.com');
        System.runAs(u) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }
        System.assertEquals(u.Alias , 'standt');
    Test.StopTest();
    }
}