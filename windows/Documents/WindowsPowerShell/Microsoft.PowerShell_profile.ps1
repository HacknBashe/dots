if (Get-Module -ListAvailable -Name "PSReadline") {
    # PSReadLine 1
    if ((Get-Module -ListAvailable -Name "PSReadline").Version.Major -eq 1) {
        # Reset
        Set-PSReadlineOption -ResetTokenColors

        $options = Get-PSReadlineOption
        # Token Foreground                                # base16 colors
        $options.CommandForegroundColor   = "DarkBlue"    # base0D
        $options.CommentForegroundColor   = "Yellow"      # base03
        $options.KeywordForegroundColor   = "DarkMagenta" # base0E
        $options.MemberForegroundColor    = "DarkBlue"    # base0D
        $options.NumberForegroundColor    = "Red"         # base09
        $options.OperatorForegroundColor  = "DarkCyan"    # base0C
        $options.ParameterForegroundColor = "Red"         # base09
        $options.StringForegroundColor    = "DarkGreen"   # base0B
        $options.TypeForegroundColor      = "DarkYellow"  # base0A
        $options.VariableForegroundColor  = "DarkRed"     # base08
    } else {
        # Token Foreground                                # base16 colors
        Set-PSReadLineOption -Colors @{
            "Command"   = [ConsoleColor]::DarkBlue        # base0D
            "Comment"   = [ConsoleColor]::Yellow          # base03
            "Keyword"   = [ConsoleColor]::DarkMagenta     # base0E
            "Member"    = [ConsoleColor]::DarkBlue        # base0D
            "Number"    = [ConsoleColor]::Red             # base09
            "Operator"  = [ConsoleColor]::DarkCyan        # base0C
            "Parameter" = [ConsoleColor]::Red             # base09
            "String"    = [ConsoleColor]::DarkGreen       # base0B
            "Type"      = [ConsoleColor]::DarkYellow      # base0A
            "Variable"  = [ConsoleColor]::DarkRed         # base08
        }
    }
}