[Setting hidden category="Button" name="Automatic placement of button"]
bool AutoPlaceButton = true;

[Setting hidden category="Button" name="Button Size X"]
float ButtonSizeX = ScreenHeight / 22.5;
[Setting hidden category="Button" name="Button Size Y"]
float ButtonSizeY = ScreenHeight / 22.5;
[Setting hidden category="Button" name="Button Position X"]
float ButtonPosX = (ScreenHeight / 35.556) / ScreenHeight;
[Setting hidden category="Button" name="Button Position Y"]
float ButtonPosY = (ScreenHeight * 0.333) / ScreenWidth;

[Setting hidden category="Button" name="Show button if leaderboard is collapsed"]
bool ShowButtonWithCollapsedLeaderboard = false;

[SettingsTab name="Button" icon="Square" order="1"]
void RenderSettingsButton()
{
    if(UI::Button('Reset to default')) {
        if(!AutoPlaceButton) {
            ButtonSizeX = ScreenHeight / 22.5;
            ButtonSizeY = ScreenHeight / 22.5;
            // Calculate the equivalent position for all resolutions; X = 0.028 on 16/9 display. >16/9 -> offset, <16/9 -> squish
            float IdealWidth = Math::Min(ScreenWidth, ScreenHeight * 16.0 / 9.0);
            float AspectDiff = Math::Max(0.0, ScreenWidth / ScreenHeight - 16.0 / 9.0) / 2.0;
            ButtonPosX = (0.028125 * IdealWidth + ScreenHeight * AspectDiff) / ScreenWidth;
            ButtonPosY = 0.333;
        }
        ShowButtonWithCollapsedLeaderboard = false;
    }
	UI::TextWrapped("Disable Automatic placement of button to customize button size and position.");

	AutoPlaceButton = UI::Checkbox("Automatic placement of button", AutoPlaceButton);

    if(!AutoPlaceButton) {
        UI::Dummy(vec2(0,5));
        UI::Separator();
        UI::Dummy(vec2(0,5));

	    UI::TextWrapped("Button size in pixels. Won't scale with resolution.");

        UI::Columns(2, "ButtonSize", false);
            ButtonSizeX = UI::SliderFloat("X##size", ButtonSizeX, 0, ScreenWidth);
            UI::NextColumn();
            ButtonSizeY = UI::SliderFloat("Y##size", ButtonSizeY, 0, ScreenHeight);
        UI::Columns(1);
        UI::Dummy(vec2(0,10));
        UI::TextWrapped("Button position. Value between 0 and 1. Will scale with resolution.");
        UI::Columns(2, "ButtonPos", false);
            ButtonPosX = UI::SliderFloat("X##pos", ButtonPosX, 0, 1);
            UI::NextColumn();
            ButtonPosY = UI::SliderFloat("Y##pos", ButtonPosY, 0, 1);
        UI::Columns(1);
    }

    UI::Separator();
    UI::Markdown("Show the button if the leaderboard is collapsed, or when the leaderboard is hidden by other plugins (e.g. HUD Picker). **Might improve performance slightly if turned on.** By default turned off.");
    ShowButtonWithCollapsedLeaderboard = UI::Checkbox("Show button if leaderboard is collapsed", ShowButtonWithCollapsedLeaderboard);
}