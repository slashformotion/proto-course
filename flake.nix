{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    # System types to support.
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    # Add dependencies that are only needed for development
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        TYPST_FONT_PATHS = "${pkgs.excalifont}:${pkgs.fantasque-sans-mono}:${pkgs.andika}";
        buildInputs = with pkgs; [
          git
          go
          gopls
          gotools
          go-tools
          delve

          protobuf

          buf

          # for prez
          typst
        ];
      };
    });
  };
}
