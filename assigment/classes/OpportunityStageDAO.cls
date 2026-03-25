public class OpportunityStageDAO {
    public static List<OpportunityStage> getActiveStagesOrdered() {
        return [
            SELECT MasterLabel, SortOrder 
            FROM OpportunityStage 
            WHERE IsActive = true 
            ORDER BY SortOrder ASC
        ];
    }
}
