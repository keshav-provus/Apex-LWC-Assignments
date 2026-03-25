public class QuoteTriggerHandler {
    public static void afterUpdate(Map<Id, Quote> oldMap, Map<Id, Quote> newMap) {
        Set<Id> oppIdsToUpdate = new Set<Id>();
        
        for (Quote quote : newMap.values()) {
            Quote oldQuote = oldMap.get(quote.Id);
            if (quote.Status == 'Approved' && oldQuote.Status != 'Approved' && quote.OpportunityId != null) {
                oppIdsToUpdate.add(quote.OpportunityId);
            }
        }
        
        if (oppIdsToUpdate.isEmpty()) {
            return;
        }
        
        List<OpportunityStage> activeStages = OpportunityStageDAO.getActiveStagesOrdered();
        
        Map<String, String> nextStageMap = new Map<String, String>();
        for (Integer i = 0; i < activeStages.size() - 1; i++) {
            nextStageMap.put(activeStages[i].MasterLabel, activeStages[i+1].MasterLabel);
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Opportunity> opps = OpportunityDAO.getByIds(oppIdsToUpdate);
        
        for (Opportunity opp : opps) {
            String currentStage = opp.StageName;
            if (nextStageMap.containsKey(currentStage)) {
                opp.StageName = nextStageMap.get(currentStage);
                oppsToUpdate.add(opp);
            }
        }
        
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}
