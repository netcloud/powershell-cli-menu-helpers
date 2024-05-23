# Global path vars
$menu_script_root_dir = Split-Path -Path $PSScriptRoot -Parent # The path of the current folder
$menu_funciton_dir = '.\functions' # The path to all helper functions
$menu_menu_dir = Join-Path -Path $menu_script_root_dir -ChildPath '\Example PowerShell CLI Menu' # The path to the menu structuree