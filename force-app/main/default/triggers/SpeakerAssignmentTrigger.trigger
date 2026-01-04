trigger SpeakerAssignmentTrigger on Speaker_Assignment__c (before insert, before update) {
  if (Trigger.isBefore && Trigger.isInsert) {
    SpeakerAssignmentHandler.checkTimeConflicts(Trigger.new, null); 
}
if (Trigger.isBefore && Trigger.isUpdate) {
    SpeakerAssignmentHandler.checkTimeConflicts(Trigger.new, Trigger.oldMap);
}

}
