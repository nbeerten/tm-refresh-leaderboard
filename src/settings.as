[Setting category="General" name="Enabled"]
bool Enabled = true;
[Setting category="General" name="Log more information"]
bool MoreLogging = false;

[Setting hidden category="Button" name="Automatic placement of button"]
bool AutoPlaceButton = true;

[Setting hidden category="General" name="Button Size X"]
float ButtonSizeX = ScreenHeight / 22.5;
[Setting hidden category="General" name="Button Size Y"]
float ButtonSizeY = ScreenHeight / 22.5;
[Setting hidden category="General" name="Button Position X"]
float ButtonPosX = (ScreenHeight / 35.556) / ScreenHeight;
[Setting hidden category="General" name="Button Position Y"]
float ButtonPosY = (ScreenHeight * 0.333) / ScreenWidth;

[SettingsTab name="Button"]
void RenderSettingsButton()
{
    if(UI::Button('Reset to default')) {
        if(!AutoPlaceButton) {
            ScreenHeight = Draw::GetHeight();
            ButtonSizeX = ScreenHeight / 22.5;
            ButtonSizeY = ScreenHeight / 22.5;
            ButtonPosX = 0.028;
            ButtonPosY = 0.333;
        }
    }
	UI::TextWrapped("Disable Automatic placement of button to customize button size and position.");

	AutoPlaceButton = UI::Checkbox("Automatic placement of button", AutoPlaceButton);

    if(!AutoPlaceButton) {
        UI::Dummy(vec2(0,5));
        UI::Separator();
        UI::Dummy(vec2(0,5));

	    UI::TextWrapped("Button size in pixels. Won't scale with resolution.");

        UI::Columns(2, "ButtonSize", false);
            ButtonSizeX = UI::SliderFloat("X (Pixels)", ButtonSizeX, 0, ScreenWidth);
            UI::NextColumn();
            ButtonSizeY = UI::SliderFloat("Y (Pixels)", ButtonSizeY, 0, ScreenHeight);
        UI::Columns(1);
        UI::Dummy(vec2(0,10));
        UI::TextWrapped("Button position. Value between 0 and 1. Will scale with resolution.");
        UI::Columns(2, "ButtonPos", false);
            ButtonPosX = UI::SliderFloat("X", ButtonPosX, 0, 1);
            UI::NextColumn();
            ButtonPosY = UI::SliderFloat("Y", ButtonPosY, 0, 1);
        UI::Columns(1);
    }
}

[SettingsTab name="Debug"]
void RenderSettingsDebug()
{
    UI::Markdown("## Debug information");
    UI::Text("CurrentlyInMap" + (CurrentlyInMap ? Icons::Check : Icons::Times));
    bool AlwaysDisplayRecords = GetApp().UserManagerScript.Users[0].Config.Interface_AlwaysDisplayRecords;
    UI::Text("AlwaysDisplayRecords" + (AlwaysDisplayRecords ? Icons::Check : Icons::Times));
    UI::Separator();
    UI::Markdown("### Items below should all be checked for button to be visible");
    UI::Text("ManialinkVisibility" + (ManialinkVisibility ? Icons::Check : Icons::Times));
    UI::Text("ManialinkIsVisible" + (ManialinkIsVisible ? Icons::Check : Icons::Times));
    UI::Text("GamemodeVisibility" + (GamemodeVisibility ? Icons::Check : Icons::Times));
    UI::Separator();
    UI::Markdown("### Button Information");
    UI::Text("CurrentlyHoveringButton" + (CurrentlyHoveringButton ? Icons::Check : Icons::Times));
    UI::Text("Size: " + tostring(ButtonSize));
    UI::Text("Position: " + tostring(ButtonPosition));
    UI::Text("Absolute Position: " + tostring(AbsoluteButtonPosition));
}