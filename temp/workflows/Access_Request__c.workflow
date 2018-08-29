<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Access_Approved</fullName>
        <description>Mail alert to owner as Access Accepted.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Access_Request/Access_Approved</template>
    </alerts>
    <alerts>
        <fullName>Access_Rejected</fullName>
        <description>Mail alert to owner as Access rejected.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Access_Request/Access_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Access_Request_Status_to_Complete</fullName>
        <field>Request_Raised_Status__c</field>
        <literalValue>Complete</literalValue>
        <name>Access Request Status to Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Access_Request_Status_to_Issue</fullName>
        <field>Request_Raised_Status__c</field>
        <literalValue>Issue</literalValue>
        <name>Access Request Status to Issue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
