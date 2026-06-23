# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Add 32GB of swap memory
  swapDevices = [
    { device = "/var/lib/swap/swapfile"; size = 32768; } # MiB (32 GiB)
  ];
  
  # Enable flakes and the new nix CLI system-wide
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;   # deduplicates identical files in /nix/store
  };

  # Automatically clean up old generations so /nix/store doesn't grow forever
  nix.gc = {
    automatic = true;
    dates     = "daily";
    options   = "--delete-older-than 7d";
  };
 
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking (also required for Noctalia wifi widget)
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ---------------------------------------------------------------------------
  # Display server / compositor
  # ---------------------------------------------------------------------------
  # greetd launches niri-session directly
  services.greetd = {
    enable = true;
    settings = {
	default_session = {
		command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.niri}/bin/niri-session";
		user = "greeter";
	};
      };
    };

  # greetd handles its own VT, xserver doesn't need to manage the display manager 
  # but we keep it enabled for the Xwayland/portal infrastructure.
  services.xserver.enable = true;

  # GDM display manager with Wayland support (required for Niri sessions).
  services.displayManager.gdm.enable = false;

  # GNOME desktop manager REMOVED — it fights Niri for the session and
  # installs a pile of services you don't need on a tiling WM setup.
  services.desktopManager.gnome.enable = false;

  # Configure keymap in X11 / Wayland
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  # ---------------------------------------------------------------------------
  # Niri window manager
  # ---------------------------------------------------------------------------

  # Enables Niri and registers its Wayland session with GDM.
  # After rebuild: log out, select "Niri" at the GDM session picker, log in.
  programs.niri.enable = true;

  # ---------------------------------------------------------------------------
  # XDG portals (required for screen sharing, file pickers, etc. under Wayland)
  # ---------------------------------------------------------------------------

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome  # handles file picker and screen cast
    ];
    config.common.default = "*";
  };

  # ---------------------------------------------------------------------------
  # Bluetooth (required for Noctalia bluetooth widget)
  # ---------------------------------------------------------------------------

  hardware.bluetooth = {
    enable       = true;
    powerOnBoot  = true;
  };
  services.blueman.enable = true;  # provides a system tray / GUI for BT management

  # ---------------------------------------------------------------------------
  # Power management (required for Noctalia power-profile widget)
  # ---------------------------------------------------------------------------

  services.power-profiles-daemon.enable = true;

  # ---------------------------------------------------------------------------
  # UPower (required for Noctalia battery widget)
  # ---------------------------------------------------------------------------

  services.upower.enable = true;

  # ---------------------------------------------------------------------------
  # Audio — PipeWire
  # ---------------------------------------------------------------------------

  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    # jack.enable     = true;  # uncomment if you need JACK
  };

  # ---------------------------------------------------------------------------
  # Printing
  # ---------------------------------------------------------------------------

  services.printing.enable = true;

  # ---------------------------------------------------------------------------
  # ZeroTier
  # ---------------------------------------------------------------------------

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "166359304e086746" ];
  };

  # ---------------------------------------------------------------------------
  # SSH
  # ---------------------------------------------------------------------------

  services.openssh.enable = true;

  # ---------------------------------------------------------------------------
  # Wayland environment variables
  # Ensures Electron, Firefox, Qt, SDL, and Java apps use Wayland natively.
  # ---------------------------------------------------------------------------

  environment.sessionVariables = {
    NIXOS_OZONE_WL              = "1";      # Electron apps (VS Code, etc.)
    MOZ_ENABLE_WAYLAND          = "1";      # Firefox
    QT_QPA_PLATFORM             = "wayland";
    SDL_VIDEODRIVER             = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";      # Java Swing apps (e.g. some ROS tools)
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    # GStreamer plugin discovery for global shell instances
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };

  # ---------------------------------------------------------------------------
  # User account
  # ---------------------------------------------------------------------------

  users.users."obiwan" = {
    isNormalUser = true;
    description  = "obiwan";
    extraGroups  = [ "networkmanager" "wheel" "docker" "dialout" "plugdev" ];
    packages     = with pkgs; [
      # per-user packages go here or in home.nix — prefer home.nix
    ];
  };

  # ---------------------------------------------------------------------------
  # System-wide programs
  # ---------------------------------------------------------------------------

  programs.firefox.enable   = true;
  programs.localsend.enable = true;

  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Dev Tools
    git
    gh
    openocd         # On-Chip Debugger for flashing embedded targets
    minicom         # Serial monitor for debugging UART/UART-to-USB boards

    # Terminal
    ghostty

    # Browsers
    google-chrome

    # Niri / Wayland utilities
    fuzzel           # app launcher (pairs well with Noctalia)
    wl-clipboard     # wl-copy / wl-paste for Wayland clipboard
    cliphist         # clipboard history daemon (Noctalia can hook into this)
    grim             # screenshot tool
    slurp            # region selector for screenshots
    swaylock-effects # lock screen fallback if needed outside Noctalia
    xwayland-satellite # fixes "error spawning xwayland-satellite" in logs
    adwaita-icon-theme # fixes all "error loading xcursor default@48" errors
   
    # Media / audio controls (Noctalia media widget uses these)
    playerctl
    pavucontrol
    brightnessctl

    # GStreamer immediate CLI access anywhere
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad 
    gst_all_1.gst-plugins-ugly

    # Networking tools (useful for robotics networking debug)
    networkmanagerapplet
    wireshark
    nmap
    inetutils

    # System monitoring
    htop
    btop

    # Misc productivity
    signal-desktop
  ];

  # ---------------------------------------------------------------------------
  # Firewall
  # ---------------------------------------------------------------------------

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # ---------------------------------------------------------------------------

  system.stateVersion = "26.05"; # Did you read the comment?
}
