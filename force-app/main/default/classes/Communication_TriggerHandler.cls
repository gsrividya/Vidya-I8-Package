/* 
Class Name        : Communication_TriggerHandler
Trigger Name      : Communication_Trigger
Test Class Name   : Test_Communication_TriggerHandler
Purpose/Overview  : To Update Phone and Email Fields in a Single Field.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 87%.
                    Trigger - 100%
Change History    : 
*/
public class Communication_TriggerHandler {
    public static void BeforeInsert(list<Communication__c> ComList,string context,Map<id,Communication__c> ComMap){
        if(Utils.isCreateable('i8__Communication__c'))
            UpdateMailsPhones(ComList,context,ComMap);
        else {
            LogFactory.debug('Communication_TriggerHandler', 'Before Insert', 'CommunicationInfo', System.Label.AddTask006 ,'Line - 16');
            LogFactory.SaveLog();
        }
    }
    public static void BeforeUpdate(list<Communication__c> ComList,string context,Map<id,Communication__c> ComMap){
        if(Utils.isUpdateable('i8__Communication__c'))
            UpdateMailsPhones(ComList,context,ComMap);
        else {
            LogFactory.debug('Communication_TriggerHandler', 'Before Update', 'Communication Info', System.Label.AddTask007 ,'Line - 24');
            LOgFactory.SaveLog();
        }
    }
    public static void UpdateMailsPhones(list<Communication__c> ComList,string context,Map<id,Communication__c> ComMap){
        set<id> SOEIds = new set<ID>();
        set<id> TaskIds = new set<ID>();
        list<string> MemberIds = new list<string>();
        for(Communication__c com : ComList){
            if( com.Milestone__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.MileStone_for_default_Imp_Mngrs__c != ComMap.get(com.id).MileStone_for_default_Imp_Mngrs__c ) ||
                (context == 'update' && com.Milestone_Members__c != ComMap.get(com.id).Milestone_Members__c) ||
                (context == 'update' && com.Additinal_Emails_Milestone__c != ComMap.get(com.id).Additinal_Emails_Milestone__c ) ||
                (context == 'update' && com.Additional_Phone_Milestone__c != ComMap.get(com.id).Additional_Phone_Milestone__c)  
            )){
                if(com.MileStone_for_default_Imp_Mngrs__c == true   )
                    SOEIds.add(com.SOE__c);   
                if(com.Milestone_Members__c != null )
                     MemberIds.AddAll(com.Milestone_Members__c.split(','));
            }
            if( com.Task_Ready__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.Default_Owner_Task_ready__c != ComMap.get(com.id).Default_Owner_Task_ready__c) ||
                (context == 'update' && com.Task_Ready_Members__c != ComMap.get(com.id).Task_Ready_Members__c) ||
                (context == 'update' && com.Additinal_Emails_Task_Ready__c != ComMap.get(com.id).Additinal_Emails_Task_Ready__c) ||
                (context == 'update' && com.Additional_Phone_Task_Ready__c != ComMap.get(com.id).Additional_Phone_Task_Ready__c)  
            )){
                if(com.Default_Owner_Task_ready__c == true   )
                    TaskIds.add(com.Task__c);   
                if(com.Task_Ready_Members__c != null )
                     MemberIds.AddAll(com.Task_Ready_Members__c.split(','));
            }
            if( com.Task_Completed__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.Default_Owner_Completed__c != ComMap.get(com.id).Default_Owner_Completed__c) ||
                (context == 'update' && com.Completed_Members__c != ComMap.get(com.id).Completed_Members__c) ||
                (context == 'update' && com.Additional_Emails_Completed__c != ComMap.get(com.id).Additional_Emails_Completed__c) ||
                (context == 'update' && com.Additional_Phone_Completed__c != ComMap.get(com.id).Additional_Phone_Completed__c )  
            )){
                if(com.Default_Owner_Completed__c == true   )
                    SOEIds.add(com.SOE__c);   
                if(com.Completed_Members__c != null )
                     MemberIds.AddAll(com.Completed_Members__c.split(','));
            }
        }
        Map<id,Task__c> TaskMap ;
        if(Utils.isAccessible('i8__Task__c'))
           TaskMap = new Map<Id,Task__c>([select id,Owner__c,Owner__r.Member__r.Email__c,Owner__r.Member__r.Phone__c from Task__c where id IN: TaskIds]);
        Map<Id,Member__c> MemberMap;
        if(Utils.isAccessible('i8__Member__c'))
           MemberMap = new Map<Id,Member__c>([select id,Name,Email__c,Phone__c from Member__c where Id IN : MemberIds]);
        Map<Id,list<SOE_Team_Member__c >> SOEManagersMap = new Map<Id,list<SOE_Team_Member__c>>();
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))      
            for(SOE_Team_Member__c  member : [select id, name,Team_Member__c,Team_Member__r.Email__c,Team_Member__r.Phone__c,SOE__c  from SOE_Team_Member__c where SOE__C In : SOEIds]){
                if(! SOEManagersMap.containskey(member.SOE__c))
                   SOEManagersMap.put(member.SOE__c,new list<SOE_Team_Member__c >()); 
                SOEManagersMap.get(member.SOE__c).add(member);
            }
        for(communication__c com : ComList){
            if(com.Milestone__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.MileStone_for_default_Imp_Mngrs__c != ComMap.get(com.id).MileStone_for_default_Imp_Mngrs__c ) ||
                (context == 'update' && com.Milestone_Members__c != ComMap.get(com.id).Milestone_Members__c) ||
                (context == 'update' && com.Additinal_Emails_Milestone__c != ComMap.get(com.id).Additinal_Emails_Milestone__c )  ||
                (context == 'update' && com.Additional_Phone_Milestone__c != ComMap.get(com.id).Additional_Phone_Milestone__c)
            )){
                com.Milestone_Mails__c ='';
                com.Milestone_Phones__c ='';
                if(com.MileStone_for_default_Imp_Mngrs__c == true){
                    for(SOE_Team_Member__c  member : SOEManagersMap.get(com.SOE__c)){
                        if(member.Team_Member__r.Email__c != null && ! com.Milestone_Mails__c.contains(member.Team_Member__r.Email__c))
                            com.Milestone_Mails__c += member.Team_Member__r.Email__c+','; 
                        if( member.Team_Member__r.Phone__c != null && ! com.Milestone_Phones__c .contains(member.Team_Member__r.Phone__c))
                            com.Milestone_Phones__c += member.Team_Member__r.Phone__c+',';                          
                    }
                }
                if(com.Milestone_Members__c != null){
                    for(string str : com.Milestone_Members__c.split(',')){
                        if(MemberMap.get(str).Email__c != null && ! com.Milestone_Mails__c.contains(MemberMap.get(str).Email__c))
                            com.Milestone_Mails__c += MemberMap.get(str).Email__c+','; 
                        if(MemberMap.get(str).Phone__c != null  && ! com.Milestone_Phones__c .contains(MemberMap.get(str).Phone__c))
                            com.Milestone_Phones__c += MemberMap.get(str).Phone__c+','; 
                    }
                }
                if(com.Additinal_Emails_Milestone__c != null){
                    for(string str : com.Additinal_Emails_Milestone__c.split(',')){
                        if(! com.Milestone_Mails__c.contains(str))
                            com.Milestone_Mails__c += str+',';
                    }
                }                
                 if(com.Additional_Phone_Milestone__c != null){
                    for(string str : com.Additional_Phone_Milestone__c.split(',')){
                        if(! com.Milestone_Phones__c .contains(str))
                            com.Milestone_Phones__c += str+',';  
                    }
                }
            } // end -----if
            if( com.Task_Ready__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.Default_Owner_Task_ready__c != ComMap.get(com.id).Default_Owner_Task_ready__c) ||
                (context == 'update' && com.Task_Ready_Members__c != ComMap.get(com.id).Task_Ready_Members__c) ||
                (context == 'update' && com.Additinal_Emails_Task_Ready__c != ComMap.get(com.id).Additinal_Emails_Task_Ready__c) ||
                (context == 'update' && com.Additional_Phone_Task_Ready__c != ComMap.get(com.id).Additional_Phone_Task_Ready__c)  
            )){
                com.Ready_Mails__c ='';
                com.Ready_Phones__c ='';
                if(com.Default_Owner_Task_ready__c == true){
                    if( TaskMap.get(com.Task__c).Owner__c != null && ! com.Ready_Mails__c.contains(TaskMap.get(com.Task__c).Owner__r.Member__r.Email__c))
                        com.Ready_Mails__c += TaskMap.get(com.Task__c).Owner__r.Member__r.Email__c+','; 
                    if(TaskMap.get(com.Task__c).Owner__c != null && ! com.Ready_Phones__c.contains(TaskMap.get(com.Task__c).Owner__r.Member__r.Phone__c))
                        com.Ready_Phones__c += TaskMap.get(com.Task__c).Owner__r.Member__r.Phone__c+',';                          
                 }
                if(com.Task_Ready_Members__c != null){
                    for(string str : com.Task_Ready_Members__c.split(',')){
                        if(MemberMap.get(str).Email__c != null && ! com.Ready_Mails__c.contains(MemberMap.get(str).Email__c))
                            com.Ready_Mails__c += MemberMap.get(str).Email__c+','; 
                        if(MemberMap.get(str).Phone__c != null && ! com.Ready_Phones__c.contains(MemberMap.get(str).Phone__c))
                            com.Ready_Phones__c += MemberMap.get(str).Phone__c+','; 
                    }
                }
                if(com.Additinal_Emails_Task_Ready__c != null){
                    for(string str : com.Additinal_Emails_Task_Ready__c.split(',')){
                        if(! com.Ready_Mails__c.contains(str))
                            com.Ready_Mails__c+= str+',';
                    }
                }                
                 if(com.Additional_Phone_Task_Ready__c != null){
                    for(string str : com.Additional_Phone_Task_Ready__c.split(',')){
                        if(! com.Ready_Phones__c.contains(str))
                            com.Ready_Phones__c += str+',';  
                    }
                }
                
            } // end --------if
            if( com.Task_Completed__c == true &&  ( context == 'insert' || 
                (context == 'update' && com.Default_Owner_Completed__c != ComMap.get(com.id).Default_Owner_Completed__c) ||
                (context == 'update' && com.Completed_Members__c != ComMap.get(com.id).Completed_Members__c) ||
                (context == 'update' && com.Additional_Emails_Completed__c != ComMap.get(com.id).Additional_Emails_Completed__c) ||
                (context == 'update' && com.Additional_Phone_Completed__c != ComMap.get(com.id).Additional_Phone_Completed__c )  
            )){
                com.Completed_Mails__c ='';
                com.Completed_Phones__c ='';
                if(com.Default_Owner_Completed__c == true){                    
                    for(SOE_Team_Member__c  member : SOEManagersMap.get(com.SOE__c)){
                        if( member.Team_Member__r.Email__c!= null &&  ! com.Completed_Mails__c.contains(member.Team_Member__r.Email__c))
                            com.Completed_Mails__c += member.Team_Member__r.Email__c+','; 
                        if( member.Team_Member__r.Phone__c != null && ! com.Completed_Phones__c.contains(member.Team_Member__r.Phone__c))
                            com.Completed_Phones__c += member.Team_Member__r.Phone__c+',';                          
                    }                         
                 }
                if(com.Completed_Members__c != null){
                    for(string str : com.Completed_Members__c.split(',')){
                        if(MemberMap.get(str).Email__c != null && ! com.Completed_Mails__c.contains(MemberMap.get(str).Email__c))
                            com.Completed_Mails__c+= MemberMap.get(str).Email__c+','; 
                        if(MemberMap.get(str).Phone__c != null && ! com.Completed_Phones__c.contains(MemberMap.get(str).Phone__c))
                            com.Completed_Phones__c+= MemberMap.get(str).Phone__c+','; 
                    }
                }
                if(com.Additional_Emails_Completed__c != null){
                    for(string str : com.Additional_Emails_Completed__c.split(',')){
                        if(! com.Completed_Mails__c.contains(str))
                            com.Completed_Mails__c+= str+',';
                    }
                }                
                 if(com.Additional_Phone_Completed__c != null){
                    for(string str : com.Additional_Phone_Completed__c.split(',')){
                        if(! com.Completed_Phones__c.contains(str))
                            com.Completed_Phones__c+= str+',';  
                    }
                }
            } // end------------if
        }
    }
}