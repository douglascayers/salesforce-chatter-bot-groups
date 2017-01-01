Salesforce Chatter Bot for Groups
=================================

Overview
--------

Chatter Bot for Groups is a way to easily listen for Chatter Groups being created or updated.
It also lets you take action when users are added or removed from those groups or their role within a group changes.
An example would be to automatically send welcome email or onboarding materials to new members of specific groups, like new hires.
Unfortunately, you cannot just leverage Process Builder to monitor for updates to CollaborationGroup or CollaborationGroupMember objects.
This project makes it easy by monitoring for updates on CollaborationGroup and CollaborationGroupMember objects and then updating custom objects that you can leverage within Process Builder.


Installation
----------------------

* [Deploy from Github](https://githubsfdeploy.herokuapp.com)


Getting Started
----------------------

1. Deploy code using link above.
2. Assign **Chatter Bot Groups Admin** permission set to your admin user.
3. Create a default organization default value for the **Chatter Bot Groups Setting** custom setting.
4. Switch to **Chatter Bot Groups** app.
5. Click on **Chatter Bot Group** tab and click New button. Enter a Chatter Group ID value in the `Chatter Group ID` field then click Save button.
6. Test it out! Update the Chatter Group's description or information text, or maybe add or remove someone from the group. Now navigate back to your **Chatter Bot Group** record to see it's been updated with current details.


Chatter Group Photos
--------------------

Although the **Chatter Bot Group** record has fields for various photo urls, the act of uploading or changing a Chatter Group's photo does not cause the triggers to fire and so that will not cause the **Chatter Bot Group** record to update. After a group's photo has changed then you'll need to navigate to the group's edit page and click Save to fire the trigger update event.


Chatter Group Membership Changes
--------------------------------

FYI, any time a user is added or removed from a group that will cause the **Chatter Bot Group** record to be updated because it's member count (`CollaborationGroup.MemberCount`) value changes.

Whenever a user is removed from a group then the associated **Chatter Bot Group Member** record will be updated by setting the `Chatter_Bot_Group_Member__c.Is_Member__c` field to false, then the trigger will delete the record. The update occurs so that if desired you can leverage Workflow Rules or Process Builder to take action when users leave groups.


Deleted Chatter Groups
----------------------

If the Chatter Group (`CollaborationGroup`) record is **deleted** then the associated **Chatter Bot Group** record and its related **Chatter Bot Group Member** records are also deleted.
