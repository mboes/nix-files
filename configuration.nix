{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.cleanTmpDir = true;
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=mbp101
  '';

  networking.hostName = "rio"; # Define your hostname.
  networking.hostId = "cc3535bb";
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.enableB43Firmware = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    file
    git
    lsof
    nmap
    pinentry
    R
    rxvt_unicode
    scrot
    udisks
    unzip
    wget
    xclip
    xcompmgr
    xlibs.xmodmap
    xlibs.xsetroot
    zip
    zsh
  ];

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true; 

  sound.enableMediaKeys = true;

  services.openssh.enable = true;
  services.printing.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "zfs";

  services.xserver = {
    enable = true;
    videoDrivers = [ "intel" ];
    vaapiDrivers = [ pkgs.vaapiIntel ];


    windowManager.xmonad.enable = true;
    windowManager.xmonad.extraPackages = self: [ self.xmonad-contrib ];
    windowManager.default = "xmonad";
    desktopManager.default = "none";

    displayManager.sddm.enable = true;
    displayManager.sessionCommands = ''
      urxvtd &
      xmodmap .Xmodmap
      xsetroot -solid black
      xset r rate 200 40
      xset b off
      '';

    # displayManager.lightdm = {
    #   enable = true;
    #   extraSeatDefaults = ''
    #     greeter-show-manual-login=true
    #     greeter-hide-users=true
    #     allow-guest=false
    #   '';
    # };

    synaptics.enable = true;
    synaptics.twoFingerScroll = true;
    synaptics.tapButtons = false;
    synaptics.additionalOptions = ''
      Option "CoastingFriction" "30"
      Option "VertScrollDelta" "-243"
      Option "HorizScrollDelta" "-243"
      '';

    modules = with pkgs; [
      xf86_input_wacom
    ];

    layout = "us,el";
    xkbVariant = "dvorak,extended";
    xkbOptions = "terminate:ctrl_alt_bksp,ctrl:nocaps,eurosign:e,altwin:swap_alt_win,grp:shifts_toggle,lv3:lalt_switch,eurosign:e";

    config = ''
      Section "InputClass"
          Identifier "touchpad catchall"
          Driver "synaptics"
          MatchIsTouchpad "on"
          MatchDevicePath "/dev/input/event*"
          Option "CoastingFriction"       "30"
          Option "VertScrollDelta"        "-243"
          Option "HorizScrollDelta"       "-243"
      EndSection
    '';

  };

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      inconsolata
      terminus_font
      ubuntu_font_family
    ];
  };

  security.sudo.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mboes = {
    description = "Mathieu Boespflug";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "video" "docker" "vboxusers" ];
    shell = "/run/current-system/sw/bin/zsh";
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  #system.stateVersion = "16.03";
}
