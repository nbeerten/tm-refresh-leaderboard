// Get screen height for calculating the ButtonSize and ButtonPosition defaults
float ScreenHeight = Draw::GetHeight();
float ScreenWidth = Draw::GetWidth();

vec2 ButtonSize;
vec2 ButtonPosition;

vec2 AbsoluteButtonPosition;

// Execute refresh of leaderboard (as in the while() loop in the Main() function)
bool ExecuteRefreshNow = false;

// States
bool CurrentlyInMap;
bool CurrentlyHoveringButton;

bool PermissionViewRecords;
// States for isVisible() function
bool ManialinkVisibility = false; // Visible as per Manialink contents
bool ManialinkIsVisible = true; // Visible as per IsVisible boolean of Manialink CGameUILayer
bool GamemodeVisibility = false; // Visible as per gamemode

bool isLeaderboardVisible;

// Textures
UI::Texture@ ButtonNormal;
UI::Texture@ ButtonHover;

void Main() {
    @ButtonNormal = UI::LoadTexture("assets/RefreshLB_normal.png");
    @ButtonHover = UI::LoadTexture("assets/RefreshLB_hover.png");
    while(true) {
        if(PermissionViewRecords && Enabled && ExecuteRefreshNow) {
            auto app = cast<CTrackMania>(GetApp());
            if(app !is null) {
                app.UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords = !app.UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords;
                sleep(1);
                app.UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords = !app.UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords;
                ExecuteRefreshNow = false;
                if(MoreLogging) trace(Icons::Refresh + " Refreshed Leaderboard");
            }
        }
        yield();
    }
}

void Render() {
    if(!PermissionViewRecords || !Enabled || !UI::IsGameUIVisible()) return;
	auto app = cast<CTrackMania>(GetApp());
    if(app !is null && app.RootMap !is null && app.CurrentPlayground !is null && app.Editor is null) {
        if(isLeaderboardVisible) {
            UI::DrawList@ DrawList = UI::GetBackgroundDrawList();
            if(CurrentlyHoveringButton) {
                DrawList.AddImage(ButtonHover, AbsoluteButtonPosition, ButtonSize);
            } else {
                DrawList.AddImage(ButtonNormal, AbsoluteButtonPosition, ButtonSize);
            }
        }
    }
}

void Update(float dt) {
    auto app = cast<CTrackMania>(GetApp());
    if(app is null) return;
    auto Network = cast<CGameCtnNetwork>(GetApp().Network);
    auto ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);

    ScreenHeight = Draw::GetHeight();
    ScreenWidth = Draw::GetWidth();

    if(AutoPlaceButton) {
        ButtonSizeX = ScreenHeight / 22.5;
        ButtonSizeY = ScreenHeight / 22.5;
        ButtonPosX = 0.028;
        ButtonPosY = 0.333;
    }

    ButtonSize = vec2(ButtonSizeX, ButtonSizeY);
    ButtonPosition = vec2(ButtonPosX, ButtonPosY);
    AbsoluteButtonPosition = ButtonPosition * vec2(ScreenWidth, ScreenHeight);

	if (app.CurrentPlayground !is null && app.RootMap !is null) CurrentlyInMap = true;
	else CurrentlyInMap = false;

    PermissionViewRecords = Permissions::ViewRecords();

    if(PermissionViewRecords && Enabled && UI::IsGameUIVisible()) {

        string sCurGameModeStr = ServerInfo.CurGameModeStr;

        if(!ShowButtonWithCollapsedLeaderboard) {
            // Thanks to chips for the code in the if-statement below!
            if (Network.ClientManiaAppPlayground !is null && Network.ClientManiaAppPlayground.Playground !is null && Network.ClientManiaAppPlayground.UILayers.Length > 0) {
                auto uilayers = Network.ClientManiaAppPlayground.UILayers;

                for (uint i = 0; i < uilayers.Length; i++) {
                    CGameUILayer@ curLayer = uilayers[i];
                    int start = curLayer.ManialinkPageUtf8.IndexOf("<");
                    int end = curLayer.ManialinkPageUtf8.IndexOf(">");
                    if (start != -1 && end != -1) {
                        auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
                        if (manialinkname.Contains("UIModule_Race_Record")) {
                            CGameManialinkQuad@ mButton = cast<CGameManialinkQuad@>(curLayer.LocalPage.GetFirstChild("quad-toggle-records-icon"));
                            ManialinkIsVisible = curLayer.IsVisible;
                            
                            if(mButton !is null) {
                                if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMxSM/Race/Icon_ArrowLeft.dds") {
                                    ManialinkVisibility = true;
                                } else if (mButton.ImageUrl == "file://Media/Manialinks/Nadeo/TMxSM/Race/Icon_WorldRecords.dds") {
                                    ManialinkVisibility = false;
                                }
                            }
                        }
                    }
                }
            } else { ManialinkVisibility = false; ManialinkIsVisible = false; };
        } else { ManialinkVisibility = true; ManialinkIsVisible = true; };

        // pb > gold
        if(sCurGameModeStr != "") {
            if(sCurGameModeStr == "TM_TimeAttack_Online" || sCurGameModeStr == "TM_Campaign_Local" || sCurGameModeStr == "TM_PlayMap_Local") {
                if(Network.ClientManiaAppPlayground !is null) {
                    auto userMgr = Network.ClientManiaAppPlayground.UserMgr;
                    MwId userId;
                    if (userMgr.Users.Length > 0) {
                        userId = userMgr.Users[0].Id;
                    } else {
                        userId.Value = uint(-1);
                    }
                    auto scoreMgr = Network.ClientManiaAppPlayground.ScoreMgr;
                    auto RootMap = app.RootMap;
                    string MapUid;
                    if(RootMap !is null){ MapUid = RootMap.MapInfo.MapUid; }
                    else { MapUid = ""; }
                    
                    int pb = -1;
                    int gold = -1;
                    if(MapUid != ""){
                    pb = scoreMgr.Map_GetRecord_v2(userId, MapUid, "PersonalBest", "", "TimeAttack", "");
                    gold = RootMap.TMObjective_GoldTime;
                    } else {  pb = -1; gold = -1; };

                    bool AlwaysDisplayRecords = app.UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords;

                    if(AlwaysDisplayRecords){
                        GamemodeVisibility = true;
                    } else if(!AlwaysDisplayRecords) {
                        if(pb < 0) {
                            GamemodeVisibility = false;
                        } else if(pb > gold) {
                            GamemodeVisibility = false;
                        } else if(pb < gold) {
                            GamemodeVisibility = true;
                        } else GamemodeVisibility = false;
                    } else GamemodeVisibility = false;
                }
            } else GamemodeVisibility = false;
        } else GamemodeVisibility = false;

        if(ManialinkVisibility && GamemodeVisibility && ManialinkIsVisible) isLeaderboardVisible = true;
        else isLeaderboardVisible = false;
    } else {ManialinkVisibility = false; GamemodeVisibility = false; ManialinkIsVisible = false; isLeaderboardVisible = false;};
}

void OnMouseMove(int x, int y) {
    if(!isLeaderboardVisible || !PermissionViewRecords || !Enabled || !UI::IsGameUIVisible()) return;
	CurrentlyHoveringButton = (x > AbsoluteButtonPosition.x && x < AbsoluteButtonPosition.x + ButtonSize.x && y > AbsoluteButtonPosition.y && y < AbsoluteButtonPosition.y + ButtonSize.y);
}

UI::InputBlocking OnMouseButton(bool down, int button, int x, int y) {
    if(!PermissionViewRecords || !Enabled || !UI::IsGameUIVisible()) return UI::InputBlocking::DoNothing;
	if (isLeaderboardVisible && down && button == 0 && (x > AbsoluteButtonPosition.x && x < AbsoluteButtonPosition.x + ButtonSize.x && y > AbsoluteButtonPosition.y && y < AbsoluteButtonPosition.y + ButtonSize.y)) {
		ExecuteRefreshNow = true;
		return UI::InputBlocking::Block;
	}
	return UI::InputBlocking::DoNothing;
}