{ inputs, pkgs, ... }:

{
  home.username      = "obiwan";
  home.homeDirectory = "/home/obiwan";
  home.stateVersion  = "26.05";

  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools
        ms-python.python
        rust-lang.rust-analyzer
        mkhl.direnv
      ];

      userSettings = {
        "editor.formatOnSave" = true;
        "terminal.integrated.defaultProfile.linux" = "bash";
      };
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      palette = "noctalia";
      format = "\\[$username@$hostname:$directory\\]$git_branch$character";

      username = {
        style_user = "green bold";
        show_always = true;
        format = "[$user]($style)";
      };

      hostname = {
        style = "green bold";
        ssh_only = false;
        format = "[$hostname]($style)";
      };

      directory = {
        style = "blue bold";
        truncation_length = 8;
        truncation_symbol = "…/";
      };

      git_branch = {
        style = "yellow bold";
        symbol = ""; 
        format = "([$branch]($style))";
      };

      character = {
        success_symbol = "[\\$ ](bold white)";
        error_symbol = "[\\$ ](bold red)";
      };

      # Static noctalia palette fallback to keep warnings completely silent
      palettes.noctalia = {
        black = "#11111b";
        blue = "#89b4fa";
        green = "#a6e3a1";
        red = "#f38ba8";
        white = "#cdd6f4";
        yellow = "#f9e2af";
      };
    };
  };

  xdg.configFile."niri/config.kdl".text = ''
    // Input
    input {
      keyboard {
        repeat-delay 200
        repeat-rate 35
        xkb {
          layout "us"
        }
      }

      touchpad {
        tap
        natural-scroll
        scroll-method "two-finger"
      }

      focus-follows-mouse
    }

    // Appearance
    prefer-no-csd

    // Force matching rounded corners for all windows
    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
    }

    layout {
      gaps 8
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      border {
        off
      }
    }

    // Autostart — ORDER MATTERS
    spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=niri"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia"

    // Clipboard history daemon
    spawn-at-startup "wl-paste" "--type" "text" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "image" "--watch" "cliphist" "store"
    spawn-at-startup "wl-paste" "--type" "text" "--primary" "--watch" "cliphist" "store"

    // Keybinds
    binds {
      Mod+Return      { spawn "ghostty"; }
      Mod+B           { spawn "google-chrome"; }
      Mod+Space       { spawn "fuzzel"; }
      
      Mod+W           { close-window; }
      Mod+F           { maximize-column; }
      Mod+Shift+F     { fullscreen-window; }
      Mod+C           { center-column; }

      Mod+L           { spawn "swaylock"; }

      Mod+Left        { focus-column-left; }
      Mod+Right       { focus-column-right; }
      Mod+Up          { focus-window-up; }
      Mod+Down        { focus-window-down; }

      Mod+Shift+Left  { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Down  { move-window-down; }
      Mod+Comma       { consume-or-expel-window-left; }
      Mod+Period      { consume-or-expel-window-right; }

      Mod+Minus       { set-column-width "-10%"; }
      Mod+Equal       { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+R           { switch-preset-column-width; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+BracketLeft  { focus-workspace-up; }
      Mod+BracketRight { focus-workspace-down; }
      
      Mod+S     { screenshot; }
      Print     { screenshot-screen; }
      Alt+Print { screenshot-window; }

      Mod+Shift+E { quit; }
      Mod+Shift+P { power-off-monitors; }
    }
    
   include "~/.config/niri/noctalia.kdl"
  '';

  programs.bash.initExtra = ''
    nix() {
      if [ "$1" = "rebuild" ]; then
        # Check if we are currently sandboxed inside a project shell
        if [ -n "$IN_NIX_SHELL" ] || [ -n "$PRISTINE_ENV" ]; then
          echo -e "\033[1;31m[ERROR]\033[0m You are currently inside a project development shell."
          echo "Exit this shell ('exit') before altering the global system configuration."
          return 1
        fi
        
        sudo nixos-rebuild switch --flake path:/home/obiwan/dotfiles/nixos#nixos
      else
        command nix "$@"
      fi
    }
  '';
 
   
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark"; # The foundational engine mapped by Noctalia
      package = pkgs.adw-gtk3;
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      # Removes header artifacts
      window-decoration = false; 
      gtk-titlebar = false;      
    
      # Injects the smooth AMOLED translucent layout canvas
      background-opacity = 0.70;
      background-blur = true;
    };
   };
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      wl-clipboard
      cliphist
    ];

    extraConfig = ''
      set number
      set relativenumber
    '';

    initLua = ''
      vim.g.clipboard = {
        name = 'wl-clipboard',
        copy = {
          ['+'] = 'wl-copy',
          ['*'] = 'wl-copy',
        },
        paste = {
          ['+'] = 'wl-paste --no-newline',
          ['*'] = 'wl-paste --no-newline',
        },
        cache_enabled = 1,
      }
      vim.opt.clipboard = "unnamedplus"
    '';
  };
}
