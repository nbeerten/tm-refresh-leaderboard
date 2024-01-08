namespace Leaderboard {
    bool isVisible = false;

    void Coroutine()
    {
        while (true) {
            yield();
            isVisible = byPauseMenu() && byStartTime() && byUISequence() && byGamemode() && byPersonalBest() && byManialink();
        }
    }

    bool byPauseMenu() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
        if (Network is null)
            return false;

        CGamePlaygroundClientScriptAPI@ ScriptAPI = Network.PlaygroundClientScriptAPI;
        if (ScriptAPI is null || ScriptAPI.IsInGameMenuDisplayed)
            return false;

        return true;
    }

    bool byStartTime() {
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode@>(App.PlaygroundScript);
        if (PlaygroundScript is null)  // null when on servers, can't check StartTime in this case
            return true;

        if (PlaygroundScript.StartTime > 2147483000)
            return false;

        return true;
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

    bool byUISequence() {
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        if(app is null) return false;
        CGameCtnNetwork@ Network = app.Network;
        if(
            Network is null
            || Network.ClientManiaAppPlayground is null
            || Network.ClientManiaAppPlayground.UI is null
        ) return false;

        CGamePlaygroundUIConfig::EUISequence uiSeq = Network.ClientManiaAppPlayground.UI.UISequence;

        return uiSeq == CGamePlaygroundUIConfig::EUISequence::Playing
            || uiSeq == CGamePlaygroundUIConfig::EUISequence::Finish;
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
        if(ClientManiaAppPlayground is null || ClientManiaAppPlayground.Playground is null)
            return false;

        MwFastBuffer<CGameUILayer@> UILayers = ClientManiaAppPlayground.UILayers;
        if (UILayers.Length < 2)
            return false;

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
                        if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMGame/Modes/Record/Icon_ArrowLeft.dds") {
                            forLoopResult = true;
                            break;
                        } else if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMGame/Modes/Record/Icon_WorldRecords.dds") {
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
