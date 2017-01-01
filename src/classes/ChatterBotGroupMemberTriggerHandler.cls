/**
 * Developed by Doug Ayers
 * douglascayers.com
 *
 * Note, 'without sharing' is used in this class.
 * Most users will not have sharing access to the Chatter_Bot_Group_Member__c object
 * but we want to ensure this trigger handler can update those records anytime
 * a group member is added or removed.
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm
 */
public without sharing class ChatterBotGroupMemberTriggerHandler {

    public void upsertChatterBotGroupMembers( List<CollaborationGroupMember> groupMembers, Boolean isMember ) {

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> groupIds = new Set<String>();
        for ( CollaborationGroupMember member : groupMembers ) {
            groupIds.add( member.collaborationGroupId );
            groupIds.add( String.valueOf( member.collaborationGroupId ).left( 15 ) );
        }

        // group id => chatter bot group
        Map<ID, Chatter_Bot_Group__c> groupIdToChatterBotGroupMap = new Map<ID, Chatter_Bot_Group__c>();
        for ( Chatter_Bot_Group__c chatterBotGroup : [
            SELECT
                id, chatter_group_id__c, active__c
            FROM
                Chatter_Bot_Group__c
            WHERE
                chatter_group_id__c IN :groupIds
        ]) {
            groupIdToChatterBotGroupMap.put( chatterBotGroup.chatter_group_id__c, chatterBotGroup );
        }

        List<Chatter_Bot_Group_Member__c> chatterBotGroupMembersToUpsert = new List<Chatter_Bot_Group_Member__c>();

        for ( CollaborationGroupMember member : groupMembers ) {

            Chatter_Bot_Group__c chatterBotGroup = groupIdToChatterBotGroupMap.get( member.collaborationGroupId );

            if ( chatterBotGroup != null && chatterBotGroup.active__c ) {

                chatterBotGroupMembersToUpsert.add( new Chatter_Bot_Group_Member__c(
                    chatter_bot_group__c = chatterBotGroup.id,
                    chatter_group_member_id__c = member.id,
                    member__c = member.memberId,
                    role__c = member.collaborationRole,
                    is_member__c = isMember
                ));

            }

        }

        if ( chatterBotGroupMembersToUpsert.size() > 0 ) {
            Database.upsert( chatterBotGroupMembersToUpsert, Chatter_Bot_Group_Member__c.Chatter_Group_Member_ID__c );
        }

    }

    public void deleteChatterBotGroupMembers( List<CollaborationGroupMember> groupMembers ) {

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> groupMemberIds = new Set<String>();
        for ( CollaborationGroupMember member : groupMembers ) {
            groupMemberIds.add( member.id );
            groupMemberIds.add( String.valueOf( member.id ).left( 15 ) );
        }

        List<Chatter_Bot_Group_Member__c> chatterBotGroupMembers = new List<Chatter_Bot_Group_Member__c>([
            SELECT
                id, is_member__c
            FROM
                Chatter_Bot_Group_Member__c
            WHERE
                chatter_group_member_id__c IN :groupMemberIds
            ORDER BY
                chatter_bot_group__c
        ]);

        // delete records since users no longer group members
        delete chatterBotGroupMembers;

    }

}