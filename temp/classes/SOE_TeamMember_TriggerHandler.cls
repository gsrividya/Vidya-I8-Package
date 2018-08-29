/* 
Class Name        : SOE_TeamMember_TriggerHandler 
Trigger Name      : SOE_TeamMember_Trigger
Test Class Name   : Test_SOE_TeamMember_TriggerHandler
Purpose/Overview  : Trigger Handler for SOETeamMember.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 97%
                    Trigger - 100%
Change History    : 
*/

public class SOE_TeamMember_TriggerHandler {   
     
    public static void SOEShareToSOETeamMember(List<SOE_Team_Member__c> teamlist)
    {
        List<SOE__Share> SOEShareList  = new List<SOE__Share>();         
        set<id> teammember_ids = new set<id>();
        set<id> SOE_ids = new set<id>();
        map<id,id> team_member_map = new map<id,id>();
        map<id,id> soe_map = new map<id,id>(); 
        if(Schema.sObjectTYpe.SOE__Share.isCreateable()){                  
            for(SOE_Team_Member__c teammember: teamlist){
                teammember_ids.add(teammember.Team_Member__c);
                SOE_ids.add(teammember.soe__c);
            }                   
            list<SOE__c> SOElist;
            if(Utils.isAccessible('i8__SOE__c'))
            SOEList  = [select id,Status__c,ownerid,Pre_Implementation_Stage__c,Post_Implementation_Stage__c,BackOut_Stage__c from SOE__c where id =: SOE_ids]; 
            for(SOE__c soe: SOElist){
                soe_map.put(soe.id,soe.ownerid);
            }
             list<member__c> member_list;
            if(Utils.isAccessible('i8__Member__c'))             
            member_list = [select id,Salesforce_User__c,Employment_Status__c,Role__c from member__c where id=: teammember_ids];
            for(member__c member : member_list){
                team_member_map.put(member.id,member.Salesforce_User__c); 
            }        
            for(SOE_Team_Member__c teammember: teamlist ){
                if(team_member_map.get(teammember.Team_Member__c)!=null && team_member_map.get(teammember.Team_Member__c) != soe_map.get(teammember.soe__c)) { 
                    SOE__Share SOEShare = new SOE__Share();
                    SOEShare.ParentId =teammember.SOE__c;
                    SOEShare.UserOrGroupId = team_member_map.get(teammember.Team_Member__c);
                    SOEShare.AccessLevel = teammember.Access_Level__c;
                    SOEShareList.add(SOEShare );  
                }         
            }
            if(SOEShareList.size()>0&& Schema.sObjectTYpe.SOE__Share.isCreateable())
                insert SOEShareList;
         }else{LogFactory.debug('SOE_TeamMember_TriggerHandler ', 'SOEShareToSOETeamMember', 'SOE SHare Info', System.Label.ADMIN001,'Line - 49');
         LogFactory.SaveLog();        }
    }  
    public static void SOEShareToSOETeamMember(List<SOE_Team_Member__c> Newteamlist, Map<Id,SOE_Team_Member__c> OldteammemberMap)
    {
        List<SOE__Share> SOEShareList  = new List<SOE__Share>();
        set<id> teammember_ids = new set<id>();
        map<id,id> team_member_map = new map<id,id>();
        set<id> SOE_ids = new set<id>();
        map<id,id> soe_map = new map<id,id>(); 
        map<id,id> oldteam_member_map = new map<id,id>(); 
        if(Schema.sObjectTYpe.SOE__Share.isCreateable() && Schema.sObjectType.SOE__SHare.isDeletable()){          
            for(SOE_Team_Member__c teammember: Newteamlist){
                teammember_ids.add(teammember.Team_Member__c);
                SOE_ids.add(teammember.soe__c);
            }
            list<SOE__c> SOElist;
            if(Utils.isAccessible('i8__SOE__c'))
            SOELIst  = [select id,Status__c,ownerid,Pre_Implementation_Stage__c,Post_Implementation_Stage__c,BackOut_Stage__c from SOE__c where id =: SOE_ids]; 
            for(SOE__c soe: SOElist){
                soe_map.put(soe.id,soe.ownerid);
            } 
            list<member__c> member_list;
            list<member__c> oldmember_list;
            if(Utils.isAccessible('i8__Member__c')){
                member_List  = [select id,Salesforce_User__c,Employment_Status__c,Role__c from member__c where id=: teammember_ids];
                oldmember_list = [select id,Salesforce_User__c,Employment_Status__c,Role__c from member__c where id=: OldteammemberMap.keyset()];
            }
            for(member__c member : member_list){
                team_member_map.put(member.id,member.Salesforce_User__c); 
            }
            for(member__c member : oldmember_list){
                oldteam_member_map.put(member.id,member.Salesforce_User__c); 
            }
            Map<Id,Id> DelMap = new Map<Id,Id>();
            List<SOE__Share> DelSOEShareList = new List<SOE__Share>();
            for(SOE_Team_Member__c teammember: Newteamlist){
                if(team_member_map.get(teammember.Team_Member__c) != oldteam_member_map.get(teammember.Team_Member__c) && teammember.Access_Level__c != OldteammemberMap.get(teammember.id).Access_Level__c && team_member_map.get(teammember.Team_Member__c) != soe_map.get(teammember.soe__c)){
                    DelMap.put(oldteam_member_map.get(teammember.Team_Member__c),OldteammemberMap.get(teammember.Id).SOE__c);
                    SOE__Share SOEShare = new SOE__Share();
                    SOEShare.ParentId =teammember.SOE__c;
                    SOEShare.UserOrGroupId = team_member_map.get(teammember.Team_Member__c);
                    SOEShare.AccessLevel = teammember.Access_Level__c;
                    SOEShareList.add(SOEShare );
                }
            }
            if(DelMap.values().size()>0 && Schema.sObjectTYpe.SOE__Share.isAccessible())
                DelSOEShareList = [select id from SOE__Share where parentid IN: DelMap.values() and UserOrGroupId IN:DelMap.keyset()];
            if(DelSOEShareList.size()>0 && Schema.SOBjectType.SOE__Share.isDeletable())
                delete DelSOEShareList ;
            if(SOEShareList.size()>0 && Schema.sObjectTYpe.SOE__Share.isCreateable())
                insert SOEShareList;
         }else{LogFactory.debug('SOE_TeamMember_TriggerHandler ', 'SOEShareToSOETeamMember', 'SOE SHare Info', System.Label.ADMIN001,'Line - 101');
         LogFactory.SaveLog();        }
    }
    public static void DelSOEShare(List<SOE_Team_Member__c> DelTeamList){
        Map<Id,Id> DelMap = new Map<Id,Id>();
        List<SOE__Share> DelSOEShareList =new list<SOE__Share>();
        set<id> teammember_ids = new set<id>();
        map<id,id> team_member_map = new map<id,id>();   
        if(Schema.sObjectTYpe.SOE__Share.isDeletable()) {       
            for(SOE_Team_Member__c teammember: DelTeamList){
                teammember_ids.add(teammember.Team_Member__c);
            }
            list<member__c> member_list;
            if(Utils.isAccessible('i8__Member__c'))
            member_list  = [select id,Salesforce_User__c,Employment_Status__c,Role__c from member__c where id=: teammember_ids];
            for(member__c member : member_list){
                team_member_map.put(member.id,member.Salesforce_User__c); 
            }
            for(SOE_Team_Member__c teammember: DelTeamList){
                if(team_member_map.get(teammember.Team_Member__c)!=null)
                    DelMap.put(team_member_map.get(teammember.Team_Member__c),teammember.SOE__c);
            }
            if(DelMap.values().size()>0 && Schema.sObjectTYpe.SOE__Share.isAccessible())
                DelSOEShareList = [select id from SOE__Share where parentid IN: DelMap.values() and UserOrGroupId IN:DelMap.keyset()];
            if(DelSOEShareList.size()>0 && Schema.SOBjectTYpe.SOE__Share.isDeletable())
                delete DelSOEShareList ;
         }else{
             LogFactory.debug('SOE_TeamMember_TriggerHandler ', 'DelSOESHare', 'SOE SHare Info', System.Label.ADMIN001,'Line -128');
             LogFactory.SaveLog();
         }
    }    
}