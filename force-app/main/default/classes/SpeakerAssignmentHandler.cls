public class SpeakerAssignmentHandler {

    public static void checkTimeConflicts(
        List<Speaker_Assignment__c> newList,
        Map<Id, Speaker_Assignment__c> oldMap
    ) {
        Set<Id> speakerIds = new Set<Id>();
        Set<Id> sessionIds = new Set<Id>();

        
        for (Speaker_Assignment__c sa : newList) {
            if (sa.Speaker__c != null && sa.Session__c != null) {
                speakerIds.add(sa.Speaker__c);
                sessionIds.add(sa.Session__c);
            }
        }

        if (speakerIds.isEmpty() || sessionIds.isEmpty()) {
            return;
        }

        Map<Id, Session__c> sessionMap = new Map<Id, Session__c>(
            [SELECT Id, Session_Date__c, Start_Time__c, End_Time__c
             FROM Session__c
             WHERE Id IN :sessionIds]
        );

        List<Speaker_Assignment__c> existingAssignments = [
            SELECT Id, Speaker__c,
                   Session__r.Session_Date__c,
                   Session__r.Start_Time__c,
                   Session__r.End_Time__c
            FROM Speaker_Assignment__c
            WHERE Speaker__c IN :speakerIds
            AND Id NOT IN :newList
        ];

        Map<Id, List<Speaker_Assignment__c>> speakerToAssignments =
            new Map<Id, List<Speaker_Assignment__c>>();

        for (Speaker_Assignment__c sa : existingAssignments) {
            if (!speakerToAssignments.containsKey(sa.Speaker__c)) {
                speakerToAssignments.put(sa.Speaker__c, new List<Speaker_Assignment__c>());
            }
            speakerToAssignments.get(sa.Speaker__c).add(sa);
        }

        for (Speaker_Assignment__c newSa : newList) {
            Session__c newSession = sessionMap.get(newSa.Session__c);
            if (newSession == null || newSa.Speaker__c == null) {
                continue;
            }

            List<Speaker_Assignment__c> assignedSessions =
                speakerToAssignments.get(newSa.Speaker__c);

            if (assignedSessions == null) {
                continue;
            }

            for (Speaker_Assignment__c oldSa : assignedSessions) {

           
                if (oldSa.Session__r.Session_Date__c ==
                    newSession.Session_Date__c) {

                    Boolean isOverlap =
                        newSession.Start_Time__c < oldSa.Session__r.End_Time__c &&
                        newSession.End_Time__c > oldSa.Session__r.Start_Time__c;

                    if (isOverlap) {
                        newSa.addError('Speaker is already booked for this time.');
                        break; 
                    }
                }
            }
        }
    }
}