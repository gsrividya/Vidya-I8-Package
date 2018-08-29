<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Mail_to_TaskOwner</fullName>
        <description>Mail to TaskOwner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner_Mail_ID__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Notifications/Advanced_Notifications</template>
    </alerts>
    <fieldUpdates>
        <fullName>Mail_ID_Update</fullName>
        <field>Owner_Mail_ID__c</field>
        <formula>Owner__r.Member__r.Email__c</formula>
        <name>Mail ID Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Owner Mail ID</fullName>
        <actions>
            <name>Mail_ID_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Owner__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
