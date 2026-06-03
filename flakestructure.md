
### Flake structure

**Line 13 to 21 :**
```nix
    mkConfigDir = { package, settings, pkgs }: if settings != {} then
       pkgs.runCommand "quickshell-overview-config" {} ''
        cp -r ${package}/share/quickshell/overview/* $out/
        cat > $out/config.json <<'JSONEOF'
        ${builtins.toJSON settings}
        JSONEOF
      ''
      else
        "${package}/share/quickshell/overview";
```
1. This will later be used by both home manager and nixos config to simply create the package folder in the nix store. I do not know why the additional /share/quikchsell/overview is required
2. It turns the nix optional and user defined `settings` into `config.json`.


**Line 23 to 34 :**
```nix
    baseOptions = { lib, system }: with lib; {
      enable = mkEnableOption "Quickshell Overview";
      package = mkOption {
        type = types.package;
        default = self.packages.${system}.default;
      };
      settings = mkOption {
        type = types.attrs;
        default = {};
        description = "Settings serialized to config.json (see config.example.json)";
      };
    };

```
1. This creates the option `settings` for both installations as exaplined above
2. and the optional `package` option for user overwrite with default value : the user nix flake input.


**Line 38 to 52 :**
```nix
default = pkgs.stdenvNoCC.mkDerivation {
  name = "quickshell-overview";
  src = self;

  installPhase = ''
    mkdir -p $out/share/quickshell/overview
    cp -r . $out/share/quickshell/overview/
  '';

  meta = with pkgs.lib; {
    description = "Standalone workspace overview for Hyprland using Quickshell";
    homepage = "https://github.com/Shanu-Kumawat/quickshell-overview";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
};
```
1. This calls the builtin nixpkgs mkdDerivation in order to build the package into the nix store.
2. the installPhase is required since the its default value calls `make install` (or so I have heard)
3. meta is just metadata for the package, this is where to licence can be specified (GPL3 for example :D)

**line 55 to 68 :**
```nix
    devShells = forEachSystem (system: let pkgs = import nixpkgs { inherit system; }; in {
      default = pkgs.mkShell {
        name = "quickshell-overview-dev";
        buildInputs = with pkgs; [ quickshell qt6.qtwayland ];

        shellHook = ''
          src="${self.packages.${system}.default}/share/quickshell/overview"
          dst="$HOME/.config/quickshell/overview"
          mkdir -p "$(dirname "$dst")"
          ln -sfT "$src" "$dst"
          echo "quickshell-overview → $dst"
        '';
      };
    });
```
1. Specify the nixpkgs dependency specified in the readme
2. Creates a devshell for developpement purposes, it creates a symlink from local ./result folder created when running `nix build` the way nixos would do it on a regular install. This symlink is automatically overwritten when rebuilding and also by home-manager upon install.


**line 70 to 79 :**
```nix
    nixosModules.default = { lib, pkgs, config, ... }: let
      cfg = config.services.quickshell-overview;
    in {
      options.services.quickshell-overview = baseOptions { inherit lib; system = pkgs.system; };
      config = lib.mkIf cfg.enable {
        environment.etc."xdg/quickshell/overview".source = mkConfigDir {
          package = cfg.package; inherit (cfg) settings; inherit pkgs;
        };
      };
    };
```
1. This allows for non-home-manager installations using the system module `config` to speicify config quickshell config location. Only if services.quickshell.enable.


**line 81 to 88 :**
```nix
    homeManagerModules.default = { lib, pkgs, config, ... }: { 
      options.programs.quickshell-overview = baseOptions { inherit lib; system = pkgs.system; };
      config = lib.mkIf cfg.enable {
        xdg.configFile."quickshell/overview".source = mkConfigDir {
          package = cfg.package; inherit (cfg) settings; inherit pkgs;
        };
      };
    };
```
1. This is the home-manager installation, it does the same as above. 
