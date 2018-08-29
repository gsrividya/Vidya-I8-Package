@isTest 
Public class Test_PostInstallClass{
    static testmethod void testInstallScript() {
        PostInstallClass postinstall = new PostInstallClass();
        Test.testInstall(postinstall, null);
        Role__c role = [Select id, name,REference_Role__c  from ROle__C where REference_Role__c ='Imp Manager'];
        System.assertEquals(role.REference_Role__c ,'Imp Manager');
    }
}