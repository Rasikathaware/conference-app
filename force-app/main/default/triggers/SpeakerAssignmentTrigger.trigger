trigger SpeakerAssignmentTrigger on Speaker_Assignment__c (before insert, before update) {
    if (Trigger.isBefore) {
        SpeakerAssignmentHandler.checkTimeConflicts(Trigger.new, Trigger.oldMap);
    }
}