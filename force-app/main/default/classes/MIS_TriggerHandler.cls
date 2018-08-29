/* 
Class Name        : MIS_TriggerHandler
Trigger Name      : MIS_Trigger
Test Class Name   : Test_MIS_SOEs_cntrl
Purpose/Overview  : Trigger Handler for MIS Trigger
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%.
                    Trigger - 100%
Change History    : 
*/
public class MIS_TriggerHandler{
    public static void BeforeUpdate(Map<Id,MIS__c> MISMap){
        Map<Id,Set<Id>> MIS_MgrMap = new Map<Id,Set<Id>>();
        set<Id> UserIds = new Set<Id>();         
        if(Utils.isAccessible('i8__MIS_Manager__c'))
        for(MIS_Manager__c mismgr: [select id,MIS_Manager__c,MIS__c from MIS_Manager__c where MIS__c IN: MISMap.keyset()]){
            if(!MIS_MgrMap.containskey(mismgr.MIS__c))   
                 MIS_MgrMap.put(mismgr.MIS__c, new set<ID>());
            MIS_MgrMap.get(mismgr.MIS__c).add(mismgr.MIS_Manager__c);
            userIds.add(mismgr.MIS_Manager__c);
        }
        string soes =''; 
        Map<string,Id> SOE_MISMap = new Map<string,Id>();       
        for(MIS__c mis: MISMAP.values()){
            soes += mis.SOEs__c;
            list<string> SOEList1 = soes.split(',');
            for(string str: SOEList1)
                SOE_MISMap.put(str,mis.Id);
        }
        list<string> SOEList = soes.split(',');
        Map<String,Id> SOEMAP = new MAp<String,Id>();
        if(Utils.isAccessible('i8__SOE__c'))
        for(SOE__c soe: [Select id,Name from SOE__c where Name =: SOEList])
            SOEMap.put(soe.Name,soe.id);
            
              
        Map<id,set<id>> SoETeamMemberMap = new Map<Id,set<id>>();
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
         for(SOE_Team_Member__c team_mem : [select id,SOE__c,Team_Member__r.Salesforce_User__c from SOE_Team_Member__c where SOE__c IN: SOEMap.values()]){
            if(!SoETeamMemberMap.ContainsKey(team_mem.SOE__c) )
                SoETeamMemberMap.put(team_mem.SOE__c,new set<Id>());                 
            SoETeamMemberMap.get(team_mem.SOE__c).add(team_mem.Team_member__r.Salesforce_User__c); 
        }
        Map<id,Member__c> MemberMap = new Map<Id,Member__c>();
        if(Utils.isAccessible('i8__Member__c'))
        for(Member__c member : [select id,Salesforce_User__c from Member__c where Salesforce_User__c In : USerIds])
            MemberMap.put(member.Salesforce_User__c,member);
        Set<ID> memberIds= new set<ID>();
        list<SOE_Team_Member__c> insertlist = new list<SOE_Team_Member__c>();
        list<Role__c> role;
        if(Utils.isAccessible('i8__Role__c'))
        role  =  [select id,Reference_Role__c from  Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE_Team_Member__c stm;
        for(string SOEName: SOEMap.keyset()){
            memberIds.clear();            
            memberIds.addAll(SoETeamMemberMap.get(SOEMap.get(SOENAme)));
            for(Id MisMgrId : MIS_MgrMap.get(SOE_MISMap.get(SOEName))){
                if(!memberIds.contains(MisMgrId)){
                    stm = new SOE_Team_Member__c(SOE__c =SOEMap.get(SOENAme),Access_Level__c = 'Edit',Team_Member__c = MemberMap.get(MisMgrId).id,Role__c = role[0].id);
                    insertlist.add(stm);
                }
            }            
        }
        if(insertlist.size() > 0 && Utils.isCreateable('i8__SOE_Team_Member__c'))
            insert insertlist ;  
        for(MIS__c mis: MISMAp.Values())
            mis.SOEs__c = null;
    }
}