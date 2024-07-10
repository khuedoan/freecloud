{
  description = "Horus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
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
            git
            gnumake
            k3d
            k9s
            kubectl
            neovim
            openssh
            opentofu
            pre-commit
            shellcheck
            sops
            timoni
            yamllint

            (python3.withPackages (p: with p; [
              kubernetes
            ]))
          ];
        };
      }
    );
}
