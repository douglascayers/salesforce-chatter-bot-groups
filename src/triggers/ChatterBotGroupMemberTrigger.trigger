/**
 * Developed by Doug Ayers
 * douglascayers.com
 */
trigger ChatterBotGroupMemberTrigger on CollaborationGroupMember ( after insert, after update, before delete ) {

    ChatterBotGroupMemberTriggerHandler handler = new ChatterBotGroupMemberTriggerHandler();

    if ( Trigger.isInsert || Trigger.isUpdate ) {

        handler.upsertChatterBotGroupMembers( Trigger.new, true );

    } else if ( Trigger.isDelete ) {

        // so that we can automate actions when group members leave
        // then we need to upsert the members setting their Is_Member__c to false
        handler.upsertChatterBotGroupMembers( Trigger.old, false );

        // now that automation on user leaving group is done
        // we now can do cleanup by deleting the chatter bot group member records
        handler.deleteChatterBotGroupMembers( Trigger.old );

    }

}