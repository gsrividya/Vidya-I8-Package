/* 
Class Name        : Incident_TriggerHandler 
Trigger Name      : Incident_Trigger 
Test Class Name   : Test_Incident_TriggerHandler
Purpose/Overview  : Trigger Handler for Incident Trigger.
                    When Incident is closed, SOE Managers wil receive mail.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%
                    Trigger - 100%
Change History    : 

*/
public class Incident_TriggerHandler {
    public static i8Constants I8 = new i8Constants ();
    
    Public static void AfterUpdate(list<Incident__c> Incident_list,Map<Id,Incident__c> INC_Map){
        set<Id> SOEId = new set<Id>();
        set<Id> USERId = new set<Id>();
        list<Incident__c> Incident_list1 = new list<Incident__c> ();
        for(Incident__c Inc : Incident_list){
            if(Inc.Status__c == 'Closed' && INC_Map.Get(Inc.Id).Status__c != 'Closed'){
                SOEId.add(Inc.SOE1__c);
                USERId.add(Inc.LastModifiedByiD);
                Incident_list1.add(inc);
            }
        }
        if(Incident_list1.SIze() > 0){
            Map<id,set<String>> SOETeamMemberMap = new Map<Id,set<String>>();
            Map<Id,String> SOEMap = new Map<Id,String>();
            Map<Id,String> MemberMap = new Map<Id,String>();
            if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for(SOE_Team_Member__c team_mem : [Select id,SOE__c,SOE__r.name,Team_Member__c,Team_Member__r.Name,Team_Member__r.Email__c from SOE_Team_Member__c where SOE__c IN : SOEId]){
                If(!SOETeamMemberMap.Containskey(team_mem.SOE__c))
                    SOETeamMemberMap.put(team_mem.SOE__c,new set<string>());
                SOETeamMemberMap.get(team_mem.SOE__c).Add(team_mem.Team_Member__r.Email__c); 
                SOEMap.put( team_mem.SOE__c,team_mem.SOE__r.Name); 
                MemberMap.put( team_mem.Team_Member__c,team_mem.Team_Member__r.Name);  
            }
            Map<id,user> User_Map;
            if(Utils.isAccessible('User'))
            User_Map  = New Map<id,user>([select id,name from user where id IN : USERId]);
            Set<String> MailList = New Set<String>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            Integer count =0;
            string body;
            For(Incident__c Inc : Incident_list1){
                mail = new Messaging.SingleEmailMessage();
                mail.setSubject(Inc.Name +' : Incident Closed');
                body = '';
                body+='<html><body><table><tr>Dear SOE  Managers'+',</tr><br/><br/><tr>'+Inc.Name+' : Incident  has been Closed, brief details are as follows:</tr><br/><tr>Incident: '+Inc.Name+'</tr><br/><tr>SOE : '+SOEMap.get(inc.SOE1__c)+'</tr>';
                If(Inc.Summary__c != Null)
                    body+='<br/><tr>Description: '+Inc.Summary__c+'</tr><br/>';
                body+='<br/><br/><tr>Regards, </tr><br/><tr>';
                if(User_Map.containskey(Inc.LastModifiedById))
                    body+= User_Map.get(Inc.LastModifiedById).name+'</tr></table></body><html>';
                if(SOETeamMemberMap.containskey(inc.SOE1__c))
                    MailList.AddAll(SOETeamMemberMap.get(inc.SOE1__c));
                If(Inc.Assignee_Email__c != NULL)
                    MailList.add(Inc.Assignee_Email__c);
                list<string> Mails1 = new list<string>();
                mails1.AddAll(MailList);
                count+= mails1.Size();
                mail.setHtmlBody(body);          
                mail.setToAddresses(mails1);
                mails.add(mail);
                MailList.clear();
            }
            try{
                Messaging.reserveSingleEmailCapacity(Count);
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                system.debug('---------'+e.getMessage());
            }
        }
    }
}