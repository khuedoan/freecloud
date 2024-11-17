{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      with nixpkgs.legacyPackages.${system};
      {
        devShells.default = mkShell {
          packages = [
            age
            ansible
            ansible-lint
            cue
            git
            gnumake
            go
            k3d
            k9s
            kubectl
            neovim
            openssh
            opentofu
            pre-commit
            shellcheck
            sops
            step-cli
            timoni
            wireguard-tools
            yamllint
          ];
        };
      }
    );
}
