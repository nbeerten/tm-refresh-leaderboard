namespace Refresh {
    bool RefreshNow = false;

    void Coroutine() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());

        while(true) {
            if(RefreshNow) {
                if(app !is null) {
                    app.CurrentProfile.Interface_AlwaysDisplayRecords = !app.CurrentProfile.Interface_AlwaysDisplayRecords;
                    yield();
                    app.CurrentProfile.Interface_AlwaysDisplayRecords = !app.CurrentProfile.Interface_AlwaysDisplayRecords;
                
                    RefreshNow = false;
                    if(MoreLogging) trace(Icons::Refresh + " Refreshed Leaderboard");
                }
            };
            yield();
        }
    }

    void Refresh() {
        RefreshNow = true;
    }
}