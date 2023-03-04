namespace SettingsTab {
    namespace UI {
        void ResetButton(const string&in category, const string&in button_label = 'Reset to default', const vec2&in dummy_size = vec2(0, 2)) {
            if(UI::Button(button_label)) {
                SettingsTab::resetCategory(category);
            }
            UI::Dummy(dummy_size);
        }
    }

    void resetCategory(const string&in category) {
        Meta::Plugin@ Plugin = Meta::ExecutingPlugin();
        Meta::PluginSetting@[]@ Settings = Plugin.GetSettings();

        for(uint i = 0; i < Settings.Length; i++) {
            Meta::PluginSetting@ Setting = Settings[i];
            if(Setting.Category != category) {
                Settings.RemoveAt(i);
            }
        }

        for(uint i = 0; i < Settings.Length; i++) {
            Meta::PluginSetting@ Setting = Settings[i];
            Setting.Reset();
        }
    }
}