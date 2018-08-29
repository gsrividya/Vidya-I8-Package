<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Email_field</fullName>
        <field>Email__c</field>
        <formula>Salesforce_User__r.Email</formula>
        <name>Email_field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Phone_Field</fullName>
        <field>Phone__c</field>
        <formula>Salesforce_User__r.Phone</formula>
        <name>Phone_Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updates_UserID_in_Member</fullName>
        <field>User_Id__c</field>
        <formula>Salesforce_User__c</formula>
        <name>Updates UserID in Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Flow to update Email %26 Phone</fullName>
        <actions>
            <name>Email_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Phone_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISNULL( Salesforce_User__c ) ),NOT(ISBLANK(Salesforce_User__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Flow updates UserID field</fullName>
        <actions>
            <name>Updates_UserID_in_Member</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Member__c.Salesforce_User__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
