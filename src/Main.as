// Get screen height for calculating the ButtonSize and ButtonPosition defaults
float ScreenHeight = Draw::GetHeight();
float ScreenWidth = Draw::GetWidth();

vec2 ButtonSize;
vec2 ButtonPosition;

vec2 AbsoluteButtonPosition;

// States
bool CurrentlyInMap = false;
bool CurrentlyHoveringButton = false;
bool PermissionViewRecords = false;

// Textures
UI::Texture@ ButtonIcon;

void Main() {
    @ButtonIcon = UI::LoadTexture("assets/RefreshLB_icon.png");

    startnew(Leaderboard::Coroutine);
    startnew(Refresh::Coroutine);
}

void Render() {
    if(InterfaceToggle && !UI::IsOverlayShown()) return;
    if(!PermissionViewRecords || !UI::IsGameUIVisible()) return;
	CTrackMania@ app = cast<CTrackMania>(GetApp());
    if(app is null) return;
    if(app.RootMap is null) return;
    if(app.CurrentPlayground is null) return;
    if(app.Editor !is null) return;

    if(!Leaderboard::isVisible) return;

    UI::DrawList@ DrawList = UI::GetBackgroundDrawList();

    if(CurrentlyHoveringButton) {
        DrawList.AddRectFilled(vec4(AbsoluteButtonPosition, ButtonSize), vec4(0.15, 0.15, 0.15, 0.8));
    } else {
        DrawList.AddRectFilled(vec4(AbsoluteButtonPosition, ButtonSize), vec4(0, 0, 0, 0.85));
    }
    DrawList.AddImage(ButtonIcon, AbsoluteButtonPosition, ButtonSize, 0xebebeb40);

}

void Update(float dt) {
    // Check if GetHeight or GetWidth is zero to prevent an error as mentioned in #4: "divide by zero exception (zero height?)"
    if(Draw::GetHeight() != 0) ScreenHeight = Draw::GetHeight();
    if(Draw::GetWidth() != 0) ScreenWidth = Draw::GetWidth();

    // Overwrite position and size if AutoPlaceButton is enabled
    if(AutoPlaceButton) {
        ButtonSizeX = ScreenHeight / 22.5;
        ButtonSizeY = ScreenHeight / 22.5;
    	// Calculate the equivalent position for all resolutions; X = 0.028 on 16/9 display. >16/9 -> offset, <16/9 -> squish
        float IdealWidth = Math::Min(ScreenWidth, ScreenHeight * 16.0 / 9.0);
        float AspectDiff = Math::Max(0.0, ScreenWidth / ScreenHeight - 16.0 / 9.0) / 2.0;

#if DEPENDENCY_ULTRAWIDEUIFIX
        // We have a shift value from UltrawideUIFix, convert it to a fraction of a 16/9 display width and subtract it from the default position
        // PR by @dpeukert: https://github.com/nbeerten/tm-refresh-leaderboard/pull/6
        ButtonPosX = ((0.028125 - (UltrawideUIFix::GetUiShift() / 320)) * IdealWidth + ScreenHeight * AspectDiff) / ScreenWidth;
#else
        ButtonPosX = (0.028125 * IdealWidth + ScreenHeight * AspectDiff) / ScreenWidth;
#endif

        ButtonPosY = 0.333;
    }

    // Revert size if they are invalid (Size of 0 or lower would hide the button)
    if(ButtonSizeX <= 0 || ButtonSizeY <= 0) {
        ButtonSizeX = ScreenHeight / 22.5;
        ButtonSizeY = ScreenHeight / 22.5;
    };

    ButtonSize = vec2(ButtonSizeX, ButtonSizeY);
    ButtonPosition = vec2(ButtonPosX, ButtonPosY);

    AbsoluteButtonPosition = ButtonPosition * vec2(ScreenWidth, ScreenHeight);

    // Declare PermissionViewRecords variable, for reuse in the logic, without the cost of calling Permissions::ViewRecords()
    PermissionViewRecords = Permissions::ViewRecords();
    
    // Declare CurrentlyInMap variable
    CTrackMania@ app = cast<CTrackMania>(GetApp());

    if(app is null) CurrentlyInMap = false;
	else if (app.CurrentPlayground !is null && app.RootMap !is null) CurrentlyInMap = true;
	else CurrentlyInMap = false;
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