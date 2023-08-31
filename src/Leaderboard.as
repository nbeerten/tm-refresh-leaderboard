namespace Leaderboard {
    bool isVisible = false;

    void Coroutine()
    {
        while (true) {
            yield();

            if(!byGamemode()) isVisible = false;
            else if(!byPersonalBest()) isVisible = false;
            else if(byManialink()) isVisible = true;
            else isVisible = false;
        }
    }

    bool byGamemode() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if(app is null) return false;
        CGameCtnNetwork@ Network = app.Network;
        if(Network is null) return false;
        CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
        if(ServerInfo is null) return false;

        string CurGameMode = ServerInfo.CurGameModeStr;
        CurGameMode = CurGameMode.Trim();

        const string[] Gamemodes = {
            "TM_TimeAttack_Online",
            "TM_Campaign_Local",
            "TM_PlayMap_Local"
        };
        // The Archivist script name changes regularly to avoid caching, but this will reliably detect it.
        bool isArchivist = CurGameMode.StartsWith("TM_Archivist_");
        
        if(isArchivist || Gamemodes.Find(CurGameMode) >= 0) {
            return true;
        } else {
            return false;
        }
    }

    bool byPersonalBest() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if(app is null) return false;
        CGameCtnNetwork@ Network = app.Network;
        CGameCtnChallenge@ RootMap = app.RootMap;
        CGameUserProfileWrapper@ CurrentProfile = app.CurrentProfile;

        bool AlwaysDisplayRecords = CurrentProfile.Interface_AlwaysDisplayRecords;

        // Return true, because with AlwaysDisplayRecords leaderboard is always shown 
        if(AlwaysDisplayRecords) return true;

        CGameManiaAppPlayground@ ClientManiaAppPlayground = Network.ClientManiaAppPlayground;
        if(ClientManiaAppPlayground is null) return false;
        CGameUserManagerScript@ UserMgr = ClientManiaAppPlayground.UserMgr;
        if(UserMgr is null) return false;
        
        MwId UserId;
        if (UserMgr.Users.Length > 0) {
            UserId = UserMgr.Users[0].Id;
        } else {
            UserId.Value = uint(-1);
        }

        CGameScoreAndLeaderBoardManagerScript@ scoreMgr = Network.ClientManiaAppPlayground.ScoreMgr;
        string MapUid;
        if(RootMap !is null){ MapUid = RootMap.MapInfo.MapUid; }
        else { MapUid = ""; };
        
        int pb = -1;
        int gold = -1;
        if(MapUid != "") {
            pb = scoreMgr.Map_GetRecord_v2(UserId, MapUid, "PersonalBest", "", "TimeAttack", "");
            gold = RootMap.TMObjective_GoldTime;
        } else {  
            pb = -1;
            gold = -1;
        };
        
        if(pb < 0) {
            return false;
        } else if(pb > gold) {
            return false;
        } else if(pb < gold) {
            return true;
        }
        
        return false;
    }

    bool byManialink() {
        if(ShowButtonWithCollapsedLeaderboard) return true;
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if(app is null) return false;
        CGameCtnNetwork@ Network = app.Network;
        if(Network is null) return false;
        CGameManiaAppPlayground@ ClientManiaAppPlayground = app.Network.ClientManiaAppPlayground;
        if(ClientManiaAppPlayground is null) return false;

        MwFastBuffer<CGameUILayer@> UILayers = ClientManiaAppPlayground.UILayers;

        if (Network.ClientManiaAppPlayground is null ||
            Network.ClientManiaAppPlayground.Playground is null ||
            !(Network.ClientManiaAppPlayground.UILayers.Length > 0)
        ){
            return false;
        };

        bool forLoopResult;
        for (uint i = 0; i < UILayers.Length; i++) {
            CGameUILayer@ curLayer = UILayers[i];
            int start = curLayer.ManialinkPageUtf8.IndexOf('<');
            int end = curLayer.ManialinkPageUtf8.IndexOf('>');
            if (start != -1 && end != -1) {
                string manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                if (manialinkname.Contains("UIModule_Race_Record")) {
                    CGameManialinkQuad@ mButton = cast<CGameManialinkQuad@>(curLayer.LocalPage.GetFirstChild("quad-toggle-records-icon"));

                    if(!curLayer.IsVisible) {
                        forLoopResult = false;
                        break;
                    };
                    
                    if(mButton !is null) {
                        if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMxSM/Race/Icon_ArrowLeft.dds") {
                            forLoopResult = true;
                            break;
                        } else if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMxSM/Race/Icon_WorldRecords.dds") {
                            forLoopResult = false;
                            break;
                        }
                    }
                }
            }
        };

        if(forLoopResult == true || forLoopResult == false) return forLoopResult;

        return false;
    }
}
