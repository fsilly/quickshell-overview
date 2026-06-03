{
  description = "Quickshell Overview for Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    forEachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
  in {
    packages = forEachSystem (system: let pkgs = import nixpkgs { inherit system; }; in {
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
    });

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

    nixosModules.default = { lib, pkgs, config, ... }: let
      inherit (lib) types mkOption mkIf;
      cfg = config.services.quickshell-overview;
      configDir = if cfg.settings != {} then
        pkgs.runCommand "quickshell-overview-config" {} ''
          cp -r ${cfg.package}/share/quickshell/overview/* $out/
          cat > $out/config.json <<'JSONEOF'
          ${builtins.toJSON cfg.settings}
          JSONEOF
        ''
      else
        "${cfg.package}/share/quickshell/overview";
    in {
      options.services.quickshell-overview = {
        enable = lib.mkEnableOption "Quickshell Overview";
        package = mkOption {
          type = types.package;
          default = self.packages.${pkgs.system}.default;
        };
        settings = mkOption {
          type = types.attrs;
          default = {};
          description = "Settings serialized to config.json (see config.example.json)";
        };
      };

      config = mkIf cfg.enable {
        environment.etc."xdg/quickshell/overview".source = configDir;
      };
    };

    homeManagerModules.default = { lib, pkgs, config, ... }: let
      inherit (lib) types mkOption mkIf;
      cfg = config.programs.quickshell-overview;
      configDir = if cfg.settings != {} then
        pkgs.runCommand "quickshell-overview-config" {} ''
          cp -r ${cfg.package}/share/quickshell/overview/* $out/
          cat > $out/config.json <<'JSONEOF'
          ${builtins.toJSON cfg.settings}
          JSONEOF
        ''
      else
        "${cfg.package}/share/quickshell/overview";
    in {
      options.programs.quickshell-overview = {
        enable = lib.mkEnableOption "Quickshell Overview";
        package = mkOption {
          type = types.package;
          default = self.packages.${pkgs.system}.default;
        };
        settings = mkOption {
          type = types.attrs;
          default = {};
          description = "Settings serialized to config.json (see config.example.json)";
        };
      };

      config = mkIf cfg.enable {
        xdg.configFile."quickshell/overview".source = configDir;
      };
    };
  };
}
