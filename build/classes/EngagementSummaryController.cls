public with sharing class EngagementSummaryController {

    @AuraEnabled(cacheable=true)
    public static SummaryData getSummaryData(Id engagementId) {
        SummaryData result = new SummaryData();

        Engagement__c eng = [
            SELECT Id, Name, Related_Opportunity__c,
                   Related_Opportunity__r.Amount
            FROM Engagement__c
            WHERE Id = :engagementId
            LIMIT 1
        ];

        result.engagementName = eng.Name;
        result.opportunityAmount =
            eng.Related_Opportunity__r != null ?
            eng.Related_Opportunity__r.Amount : null;

        result.completedTasks = [
            SELECT COUNT()
            FROM Task
            WHERE WhatId = :engagementId
            AND Status = 'Completed'
        ];

        result.upcomingEvents = [
            SELECT COUNT()
            FROM Event
            WHERE WhatId = :engagementId
            AND StartDateTime > :System.now()
        ];

        return result;
    }

    public class SummaryData {
        @AuraEnabled public String engagementName;
        @AuraEnabled public Decimal opportunityAmount;
        @AuraEnabled public Integer completedTasks;
        @AuraEnabled public Integer upcomingEvents;
    }

    @AuraEnabled
    public static Id createFollowUpTask(Id engagementId) {
        Engagement__c eng = [
            SELECT Id, Name
            FROM Engagement__c
            WHERE Id = :engagementId
            LIMIT 1
        ];

        Task t = new Task(
            WhatId = engagementId,
            Subject = 'Follow-up on ' + eng.Name,
            Type = 'Call',
            ActivityDate = Date.today().addDays(1)
        );

        insert t;
        return t.Id;
    }
}
