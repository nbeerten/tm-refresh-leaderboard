// /**
//  * Logic for checking if a gamemode equals a gamemode of a given array/Json::Value, or if a gamemode equals a given string.
//  * Related files: src.Settings.Gamemodes, src.Leaderboard
//  */

// namespace Gamemode {
//     // Check if current gamemode **Is in** a Json string or object
//     bool IsAndIn(const string &in Input) {
//         Json::Value@ Gamemodes = Json::Parse(Input);

//         return Gamemode::IsAndIn(Gamemodes);
//     };
//     bool IsAndIn(const Json::Value@ &in Input) {
//         CTrackMania@ app = cast<CTrackMania>(GetApp());
//         if(app is null) return false;
//         CGameCtnNetwork@ Network = app.Network;
//         if(Network is null) return false;
//         CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
//         if(ServerInfo is null) return false;

//         string CurGameMode = ServerInfo.CurGameModeStr;
//         CurGameMode = CurGameMode.ToLower().Trim();
        
//         bool forLoopResult = false;
//         for(uint i = 0; i < Input.Length; i++) {   
//             string Gamemode = Input[i];   
//             Gamemode = Gamemode.ToLower().Trim();
//             if(Gamemode == CurGameMode) {
//                 forLoopResult = true;
//                 break;
//             }
//         }

//         return forLoopResult;        
//     };

//     bool Is(const string &in input) {
//         CTrackMania@ app = cast<CTrackMania>(GetApp());
//         if(app is null) return false;
//         CGameCtnNetwork@ Network = app.Network;
//         if(Network is null) return false;
//         CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo>(Network.ServerInfo);
//         if(ServerInfo is null) return false;

//         string CurGameMode = ServerInfo.CurGameModeStr;
//         CurGameMode = CurGameMode.ToLower().Trim();
//         string InputGameMode = input.ToLower().Trim();

//         if(CurGameMode == InputGameMode) return true;

//         return false;
//     };
// }