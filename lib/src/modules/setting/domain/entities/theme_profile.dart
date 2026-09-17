enum ThemeProfile { light, dark }

extension ThemeProfileToggle on ThemeProfile {
  ThemeProfile get toggled =>
      this == ThemeProfile.light ? ThemeProfile.dark : ThemeProfile.light;
}
