{
  pkgs,
  config,
  lib,
  ...
}: let
  # Use ANSI colors instead of base16
  c = config.theme.colors;

  # Helper function to convert a single hex digit to decimal
  hexDigitToInt = c:
    if c == "0" then 0
    else if c == "1" then 1
    else if c == "2" then 2
    else if c == "3" then 3
    else if c == "4" then 4
    else if c == "5" then 5
    else if c == "6" then 6
    else if c == "7" then 7
    else if c == "8" then 8
    else if c == "9" then 9
    else if c == "a" || c == "A" then 10
    else if c == "b" || c == "B" then 11
    else if c == "c" || c == "C" then 12
    else if c == "d" || c == "D" then 13
    else if c == "e" || c == "E" then 14
    else if c == "f" || c == "F" then 15
    else 0;

  # Convert two hex characters to a decimal number
  hexPairToInt = hex:
    (hexDigitToInt (builtins.substring 0 1 hex)) * 16 + (hexDigitToInt (builtins.substring 1 1 hex));

  # Helper function to convert hex to RGB string "r,g,b"
  hexToRgb = hex: let
    # Remove # prefix if present
    cleanHex = lib.removePrefix "#" hex;
    r = hexPairToInt (builtins.substring 0 2 cleanHex);
    g = hexPairToInt (builtins.substring 2 2 cleanHex);
    b = hexPairToInt (builtins.substring 4 2 cleanHex);
  in "${toString r},${toString g},${toString b}";

  # Color mappings using ANSI colors
  # KDE uses RGB format: r,g,b
  kdeColors = {
    # Window/View backgrounds and foregrounds
    windowBg = hexToRgb c.default.black; # Dark background
    windowFg = hexToRgb c.default.white; # Normal text
    viewBg = hexToRgb c.default.black; # View background
    viewFg = hexToRgb c.default.white; # View text

    # Buttons
    buttonBg = hexToRgb c.indexed.bgHighlight; # Mid-tone button background
    buttonFg = hexToRgb c.default.white; # Button text

    # Selection/highlight
    selectionBg = hexToRgb c.default.blue; # Blue accent
    selectionFg = hexToRgb c.default.black; # Dark text on selection

    # Tooltips
    tooltipBg = hexToRgb c.background; # Background color
    tooltipFg = hexToRgb c.default.white; # Tooltip text

    # Links
    linkColor = hexToRgb c.default.blue; # Blue links
    visitedLink = hexToRgb c.default.magenta; # Purple visited links

    # Negative/Positive/Neutral for status
    negativeText = hexToRgb c.default.red; # Red for errors
    positiveText = hexToRgb c.default.green; # Green for success
    neutralText = hexToRgb c.default.yellow; # Yellow for warnings

    # Inactive/disabled states (dimmed versions)
    inactiveFg = hexToRgb c.bright.black; # Dimmed text
    disabledFg = hexToRgb c.bright.black; # Disabled text

    # Header/titlebar
    headerBg = hexToRgb c.background; # Background color
    headerFg = hexToRgb c.default.white; # Header text

    # Complementary colors
    complementaryBg = hexToRgb c.background; # Background color
    complementaryFg = hexToRgb c.bright.white; # Brighter text
    complementaryHover = hexToRgb c.indexed.bgHighlight; # Mid-tone hover
    complementaryFocus = hexToRgb c.default.blue; # Blue focus

    # Focus decoration
    focusColor = hexToRgb c.default.blue; # Blue accent
    hoverColor = hexToRgb c.indexed.bgHighlight; # Subtle hover
  };

  # Generate the kdeglobals content
  kdeglobalsContent = ''
    [ColorEffects:Disabled]
    Color=${kdeColors.disabledFg}
    ColorAmount=0
    ColorEffect=0
    ContrastAmount=0.65
    ContrastEffect=1
    IntensityAmount=0.1
    IntensityEffect=2

    [ColorEffects:Inactive]
    ChangeSelectionColor=true
    Color=${kdeColors.inactiveFg}
    ColorAmount=0.025
    ColorEffect=2
    ContrastAmount=0.1
    ContrastEffect=2
    Enable=false
    IntensityAmount=0
    IntensityEffect=0

    [Colors:Button]
    BackgroundAlternate=${kdeColors.buttonBg}
    BackgroundNormal=${kdeColors.buttonBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.buttonFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Complementary]
    BackgroundAlternate=${kdeColors.complementaryBg}
    BackgroundNormal=${kdeColors.complementaryBg}
    DecorationFocus=${kdeColors.complementaryFocus}
    DecorationHover=${kdeColors.complementaryHover}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.complementaryFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Header]
    BackgroundAlternate=${kdeColors.headerBg}
    BackgroundNormal=${kdeColors.headerBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.headerFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Header][Inactive]
    BackgroundAlternate=${kdeColors.headerBg}
    BackgroundNormal=${kdeColors.headerBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.headerFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Selection]
    BackgroundAlternate=${kdeColors.selectionBg}
    BackgroundNormal=${kdeColors.selectionBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionFg}
    ForegroundInactive=${kdeColors.selectionFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.selectionFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Tooltip]
    BackgroundAlternate=${kdeColors.tooltipBg}
    BackgroundNormal=${kdeColors.tooltipBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.tooltipFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:View]
    BackgroundAlternate=${kdeColors.viewBg}
    BackgroundNormal=${kdeColors.viewBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.viewFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [Colors:Window]
    BackgroundAlternate=${kdeColors.windowBg}
    BackgroundNormal=${kdeColors.windowBg}
    DecorationFocus=${kdeColors.focusColor}
    DecorationHover=${kdeColors.hoverColor}
    ForegroundActive=${kdeColors.selectionBg}
    ForegroundInactive=${kdeColors.inactiveFg}
    ForegroundLink=${kdeColors.linkColor}
    ForegroundNegative=${kdeColors.negativeText}
    ForegroundNeutral=${kdeColors.neutralText}
    ForegroundNormal=${kdeColors.windowFg}
    ForegroundPositive=${kdeColors.positiveText}
    ForegroundVisited=${kdeColors.visitedLink}

    [General]
    AccentColor=${kdeColors.selectionBg}
    ColorScheme=TokyoNight
    Name=Tokyo Night
    shadeSortColumn=true
    TerminalApplication=ghostty
    TerminalService=com.mitchellh.ghostty.desktop

    [Icons]
    Theme=breeze-dark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
    ShowDeleteCommand=true
    SingleClick=false
    widgetStyle=Breeze

    [KFileDialog Settings]
    Allow Expansion=false
    Automatically select filename extension=true
    Breadcrumb Navigation=true
    Decoration position=2
    LocationCombo Coverage=3
    Preview Width=300
    Show Bookmarks=true
    Show Full Path=true
    Show hidden files=true
    Show Preview=true
    Show Speedbar=true
    Sort by=Name
    Sort directories first=true
    Sort hidden files last=false
    Sort reversed=false
    Speedbar Width=150
    View Style=DetailTree

    [WM]
    activeBackground=${kdeColors.headerBg}
    activeBlend=${kdeColors.headerFg}
    activeForeground=${kdeColors.headerFg}
    inactiveBackground=${kdeColors.headerBg}
    inactiveBlend=${kdeColors.inactiveFg}
    inactiveForeground=${kdeColors.inactiveFg}
  '';
in {
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  # Install required Qt/KDE packages for theming
  home.packages = with pkgs.kdePackages; [
    breeze # Widget style
    breeze-icons # Icon theme
    qqc2-breeze-style # Qt Quick Controls 2 style
    kde-gtk-config # GTK integration
  ];

  # Generate kdeglobals declaratively
  xdg.configFile."kdeglobals".text = kdeglobalsContent;

  # Also set the color scheme file for apps that read it directly
  xdg.dataFile."color-schemes/TokyoNight.colors".text = kdeglobalsContent;
}
