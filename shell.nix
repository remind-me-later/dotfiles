{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    shfmt
    shellcheck
    nixfmt
  ];
  # Use the repo's hooks (.githooks/pre-commit runs the checks above)
  shellHook = ''
    git config core.hooksPath .githooks
  '';
}
