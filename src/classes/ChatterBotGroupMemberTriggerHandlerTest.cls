/**
 * Developed by Doug Ayers
 * douglascayers.com
 */
@isTest
private class ChatterBotGroupMemberTriggerHandlerTest {

    @isTest
    static void test_add_group_member() {

        Profile p = [ SELECT id FROM Profile WHERE name = 'Standard User' ];

        User user1;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user1 = newUser( p.id, 'Alpha', 'User 1', 'user_1@example.com' );

            insert new List<User>{ user1 };

        }

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        settings.auto_create_public_chatter_groups__c = true;
        upsert settings;

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        Test.startTest();

        CollaborationGroupMember groupMember = new CollaborationGroupMember(
            collaborationGroupId = grp.id,
            memberId = user1.id,
            collaborationRole = 'Standard'
        );

        insert groupMember;

        Test.stopTest();

        Chatter_Bot_Group_Member__c chatterBotGroupMember = [ SELECT id, chatter_group_member_id__c, member__c, role__c, is_member__c FROM Chatter_Bot_Group_Member__c WHERE member__c = :user1.id ];

        System.assertEquals( groupMember.id, chatterBotGroupMember.chatter_group_member_id__c );
        System.assertEquals( groupMember.collaborationRole, chatterBotGroupMember.role__c );
        System.assertEquals( true, chatterBotGroupMember.is_member__c );

    }

    @isTest
    static void test_remove_group_member() {

        Profile p = [ SELECT id FROM Profile WHERE name = 'Standard User' ];

        User user1;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
        System.runAs( new User( id = UserInfo.getUserId() ) ) {

            user1 = newUser( p.id, 'Alpha', 'User 1', 'user_1@example.com' );

            insert new List<User>{ user1 };

        }

        Chatter_Bot_Groups_Setting__c settings = Chatter_Bot_Groups_Setting__c.getInstance();
        settings.auto_create_public_chatter_groups__c = true;
        upsert settings;

        CollaborationGroup grp = new CollaborationGroup(
            name = 'Test Group',
            collaborationType = 'Public'
        );

        insert grp;

        CollaborationGroupMember groupMember = new CollaborationGroupMember(
            collaborationGroupId = grp.id,
            memberId = user1.id,
            collaborationRole = 'Standard'
        );

        insert groupMember;

        System.assertEquals( 1, [ SELECT count() FROM Chatter_Bot_Group_Member__c WHERE chatter_group_member_id__c = :groupMember.id ] );

        Test.startTest();

        delete groupMember;

        Test.stopTest();

        System.assertEquals( 0, [ SELECT count() FROM Chatter_Bot_Group_Member__c WHERE chatter_group_member_id__c = :groupMember.id ] );

    }

    private static User newUser( ID profileId, String firstName, String lastName, String email ) {
        Integer rand = Math.round( Math.random() * 1000 );
        return new User(
            isActive = true,
            profileId = profileId,
            alias = firstName.substring(0,1) + lastName.substring(1,5),
            firstName = firstName,
            lastName = lastName,
            email = email,
            username = rand + email,
            emailEncodingKey = 'UTF-8',
            languageLocaleKey = 'en_US',
            localeSidKey = 'en_US',
            timeZoneSidKey = 'America/Chicago'
        );
    }

}