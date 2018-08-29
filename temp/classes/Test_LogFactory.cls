@istest
Public class Test_LogFactory{
    Static testmethod void LOgFactory1(){
        Test.STartTest();
        SOEUtility.SystemSettings_Insert();
        system.assertequals(Utils.getSystemSetting('LOG_ENABLE'),'false');
        LogFactory.error('LoFactory','Insert','','');
        LogFactory.info('LoFactory','Insert','','','');
        LogFactory.debug('LoFactory','Insert','','','');
        LogFactory.SaveLog();
        Test.StopTest();
    }     
}