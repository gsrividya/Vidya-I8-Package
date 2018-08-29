<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_a_mail_to_Assignee_when_an_asset_is_assigned</fullName>
        <description>Send a mail to Assignee when an asset is assigned.</description>
        <protected>false</protected>
        <recipients>
            <field>AssigneeEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Asset/Mail_to_Assignee</template>
    </alerts>
    <alerts>
        <fullName>To_inform_assigner_and_assignee_two_days_before_the_end_date_of_asset_access</fullName>
        <description>To inform assigner and assignee two days before the end date of asset access</description>
        <protected>false</protected>
        <recipients>
            <field>AssigneeEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>AssignerEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Asset/Alert_Mail_2_days_prior_to_end_date</template>
    </alerts>
</Workflow>
