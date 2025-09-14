public with sharing class EngagementSummaryController {
    
    @AuraEnabled(cacheable=true)
    public static EngagementSummaryWrapper getEngagementSummary(Id engagementId) {
        Engagement__c eng = [SELECT Id, Name, Related_Opportunity__c, Related_Opportunity__r.Amount
        FROM Engagement__c
        WHERE Id = :engagementId
        LIMIT 1];
        
        Integer completedTasks = [SELECT COUNT() FROM Task 
        WHERE WhatId = :engagementId AND Status = 'Completed'];
        
        Integer upcomingEvents = [SELECT COUNT() FROM Event
        WHERE WhatId = :engagementId AND StartDateTime >= :System.now()];
        
        return new EngagementSummaryWrapper(
            eng.Name,
            eng.Related_Opportunity__r != null ? eng.Related_Opportunity__r.Amount : 0,
            completedTasks,
            upcomingEvents
        );
    }
    
    @AuraEnabled
    public static Task createQuickFollowUpCall(Id engagementId, String engagementName) {
        Task t = new Task();
        t.WhatId = engagementId;
        t.Type = 'Call';
        t.Subject = 'Follow-up on ' + engagementName;
        t.ActivityDate = System.today().addDays(1); // Due Date = mañana
        insert t;
        return t;
    }
    
    public class EngagementSummaryWrapper {
        @AuraEnabled public String engagementName;
        @AuraEnabled public Decimal opportunityAmount;
        @AuraEnabled public Integer completedTasks;
        @AuraEnabled public Integer upcomingEvents;
        
        public EngagementSummaryWrapper(String engagementName, Decimal opportunityAmount, Integer completedTasks, Integer upcomingEvents) {
            this.engagementName = engagementName;
            this.opportunityAmount = opportunityAmount;
            this.completedTasks = completedTasks;
            this.upcomingEvents = upcomingEvents;
        }
    }
}

