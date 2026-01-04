public with sharing class SpeakerController {

    @AuraEnabled
    public static List<Speaker__c> searchSpeakers(String name, String speciality) {
        
        String query = 'SELECT Id, Name, Email__c, Speciality__c FROM Speaker__c WHERE Id != null';
        
        if (String.isNotBlank(name)) {
            query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(name) + '%\'';
        }
        
        if (String.isNotBlank(speciality)) {
            query += ' AND Speciality__c = \'' + String.escapeSingleQuotes(speciality) + '\'';
        }
        
        return Database.query(query);
    }


  @AuraEnabled(cacheable=true)
public static List<Session__c> getSessionsByDate(String sessionDate) {

    Date selectedDate = Date.valueOf(sessionDate);

    return [
        SELECT Id, Name, Title__c, Session_Date__c, Start_Time__c, End_Time__c
        FROM Session__c
        WHERE Session_Date__c = :selectedDate
        ORDER BY Start_Time__c
    ];
}


    @AuraEnabled
    public static Boolean isSpeakerAvailable(Id speakerId, Id sessionId) {

        Session__c newSession = [
            SELECT Session_Date__c, Start_Time__c, End_Time__c
            FROM Session__c WHERE Id = :sessionId
        ];

        for (Speaker_Assignment__c sa : [
            SELECT Session__r.Session_Date__c,
                   Session__r.Start_Time__c,
                   Session__r.End_Time__c
            FROM Speaker_Assignment__c
            WHERE Speaker__c = :speakerId
        ]) {
            if (sa.Session__r.Session_Date__c == newSession.Session_Date__c) {
                Boolean overlap =
                    newSession.Start_Time__c < sa.Session__r.End_Time__c &&
                    newSession.End_Time__c > sa.Session__r.Start_Time__c;
                if (overlap) return false;
            }
        }
        return true;
    }

    @AuraEnabled
    public static void createAssignment(Id speakerId, Id sessionId) {
        insert new Speaker_Assignment__c(
            Speaker__c = speakerId,
            Session__c = sessionId
        );
    }

}