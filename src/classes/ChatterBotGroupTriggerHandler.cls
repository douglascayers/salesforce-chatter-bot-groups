/**
 * Developed by Doug Ayers
 * douglascayers.com
 *
 * Note, 'without sharing' is used in this class.
 * Most users will not have sharing access to the Chatter_Bot_Group__c object
 * but we want to ensure this trigger handler can update those records anytime
 * a group is created or updated.
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm
 */
public without sharing class ChatterBotGroupTriggerHandler {

    public void upsertChatterBotGroups( List<CollaborationGroup> groups ) {

        // we must re-query the groups to get their photo urls
        // unfortunately, when users upload new photos to groups in UI the trigger isn't fired
        groups = new List<CollaborationGroup>([
            SELECT
                id, name, description, ownerId, collaborationType, groupEmail,
                smallPhotoURL, mediumPhotoURL, fullPhotoURL, bannerPhotoURL,
                memberCount, informationTitle, informationBody, canHaveGuests,
                isArchived, isBroadcast
            FROM
                CollaborationGroup
            WHERE
                id IN :groups
        ]);

        // do any chatter bot groups exist for these group ids?
        // if yes then we should update those records, else ignore
        // unless custom setting says to auto create records anyways

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> groupIds = new Set<String>();
        for ( CollaborationGroup grp : groups ) {
            groupIds.add( grp.id );
            groupIds.add( String.valueOf( grp.id ).left( 15 ) );
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

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        Boolean autoCreatePublicGroups = ( settings != null && settings.auto_create_public_chatter_groups__c );
        Boolean autoCreatePrivateGroups = ( settings != null && settings.auto_create_private_chatter_groups__c );
        Boolean autoCreateUnlistedGroups = ( settings != null && settings.auto_create_unlisted_chatter_groups__c );

        List<Chatter_Bot_Group__c> chatterBotGroupsToUpsert = new List<Chatter_Bot_Group__c>();
        List<Chatter_Bot_Group__c> chatterBotGroupsToUpdate = new List<Chatter_Bot_Group__c>();

        for ( CollaborationGroup grp : groups ) {

            System.debug( grp );

            Chatter_Bot_Group__c chatterBotGroup = groupIdToChatterBotGroupMap.get( grp.id );

            if ( chatterBotGroup == null ) {

                System.debug( 'No Chatter Bot Group record matches collaboration group id: ' + grp.id + ', collaborationGroupType: ' + grp.collaborationType );
                System.debug( 'Should auto create Chatter Bot Group? public: ' + autoCreatePublicGroups + ', private: ' + autoCreatePrivateGroups + ', unlisted: ' + autoCreateUnlistedGroups + '. This option is controlled by Chatter_Bot_Groups_Setting__c custom setting.' );

                Boolean shouldCreate = ( 'Public' == grp.collaborationType && autoCreatePublicGroups ) ||
                                       ( 'Private' == grp.collaborationType && autoCreatePrivateGroups ) ||
                                       ( 'Unlisted' == grp.collaborationType && autoCreateUnlistedGroups );

                if ( shouldCreate ) {
                    chatterBotGroup = new Chatter_Bot_Group__c(
                        active__c = true
                    );
                }

            }

            if ( chatterBotGroup != null && chatterBotGroup.active__c ) {

                chatterBotGroup.chatter_group_id__c = grp.id;
                chatterBotGroup.group_name__c = grp.name;
                chatterBotGroup.group_owner__c = grp.ownerId;
                chatterBotGroup.group_description__c = grp.description;
                chatterBotGroup.group_email__c = grp.groupEmail;
                chatterBotGroup.member_count__c = grp.memberCount;
                chatterBotGroup.can_have_guests__c = grp.canHaveGuests;
                chatterBotGroup.collaboration_type__c = grp.collaborationType;
                chatterBotGroup.small_photo_url__c = grp.smallPhotoURL;
                chatterBotGroup.medium_photo_url__c = grp.mediumPhotoURL;
                chatterBotGroup.full_photo_url__c = grp.fullPhotoURL;
                chatterBotGroup.banner_photo_url__c = grp.bannerPhotoURL;
                chatterBotGroup.information_title__c = grp.informationTitle;
                chatterBotGroup.information_body__c = grp.informationBody;
                chatterBotGroup.is_archived__c = grp.isArchived;
                chatterBotGroup.is_broadcast__c = grp.isBroadcast;

                if ( String.isNotBlank( chatterBotGroup.id ) ) {
                    chatterBotGroupsToUpdate.add( chatterBotGroup );
                } else {
                    chatterBotGroupsToUpsert.add( chatterBotGroup );
                }

            }

        }

        if ( chatterBotGroupsToUpsert.size() > 0 ) {
            Database.upsert( chatterBotGroupsToUpsert, Chatter_Bot_Group__c.Chatter_Group_ID__c );
        }

        if ( chatterBotGroupsToUpdate.size() > 0 ) {
            Database.update( chatterBotGroupsToUpdate );
        }

    }

    public void deleteChatterBotGroups( List<CollaborationGroup> groups ) {

        // When filtering on lookup fields, Salesforce has special
        // handling to treat 15 and 18 character IDs the same.
        // Since our query is on a text field and not an ID lookup field
        // then we have to handle both 15 and 18 character IDs as unique
        // values in our filter criteria.
        Set<String> groupIds = new Set<String>();
        for ( CollaborationGroup grp : groups ) {
            groupIds.add( grp.id );
            groupIds.add( String.valueOf( grp.id ).left( 15 ) );
        }

        delete [ SELECT id FROM Chatter_Bot_Group__c WHERE chatter_group_id__c IN :groupIds ];

    }

}