// Get screen height for calculating the ButtonSize and ButtonPosition defaults
float ScreenHeight = Draw::GetHeight();
float ScreenWidth = Draw::GetWidth();

vec2 ButtonSize;
vec2 ButtonPosition;

vec2 AbsoluteButtonPosition;

// States
bool CurrentlyInMap;
bool CurrentlyHoveringButton;

bool PermissionViewRecords = false;


// Textures
UI::Texture@ ButtonNormal;
UI::Texture@ ButtonHover;

void Main() {
    @ButtonNormal = UI::LoadTexture("assets/RefreshLB_normal.png");
    @ButtonHover = UI::LoadTexture("assets/RefreshLB_hover.png");

    startnew(Leaderboard::Coroutine);
    startnew(Refresh::Coroutine);
}

void Render() {
    if(!PermissionViewRecords || !UI::IsGameUIVisible()) return;
	auto app = cast<CTrackMania>(GetApp());
    if(app !is null && app.RootMap !is null && app.CurrentPlayground !is null && app.Editor is null) {
        if(Leaderboard::isVisible) {
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

    ScreenHeight = Draw::GetHeight();
    ScreenWidth = Draw::GetWidth();

    if(AutoPlaceButton) {
        ButtonSizeX = ScreenHeight / 22.5;
        ButtonSizeY = ScreenHeight / 22.5;
    	// Calculate the equivalent position for all resolutions; X = 0.028 on 16/9 display. >16/9 -> offset, <16/9 -> squish
        float IdealWidth = Math::Min(ScreenWidth, ScreenHeight * 16.0 / 9.0);
        float AspectDiff = Math::Max(0.0, ScreenWidth / ScreenHeight - 16.0 / 9.0) / 2.0;
        ButtonPosX = (0.028125 * IdealWidth + ScreenHeight * AspectDiff) / ScreenWidth;
        ButtonPosY = 0.333;
    }

    ButtonSize = vec2(ButtonSizeX, ButtonSizeY);
    ButtonPosition = vec2(ButtonPosX, ButtonPosY);
    AbsoluteButtonPosition = ButtonPosition * vec2(ScreenWidth, ScreenHeight);

	if (app.CurrentPlayground !is null && app.RootMap !is null) CurrentlyInMap = true;
	else CurrentlyInMap = false;

    PermissionViewRecords = Permissions::ViewRecords();
}

void OnMouseMove(int x, int y) {
    if(!Leaderboard::isVisible || !PermissionViewRecords || !UI::IsGameUIVisible()) return;
	CurrentlyHoveringButton = (x > AbsoluteButtonPosition.x && x < AbsoluteButtonPosition.x + ButtonSize.x && y > AbsoluteButtonPosition.y && y < AbsoluteButtonPosition.y + ButtonSize.y);
}

UI::InputBlocking OnMouseButton(bool down, int button, int x, int y) {
    if(!PermissionViewRecords || !UI::IsGameUIVisible()) return UI::InputBlocking::DoNothing;
	if (Leaderboard::isVisible && down && button == 0 && (x > AbsoluteButtonPosition.x && x < AbsoluteButtonPosition.x + ButtonSize.x && y > AbsoluteButtonPosition.y && y < AbsoluteButtonPosition.y + ButtonSize.y)) {
		Refresh::Refresh();
		return UI::InputBlocking::Block;
	}
	return UI::InputBlocking::DoNothing;
}