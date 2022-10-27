{
  description = "dpc's flake utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs, ... }: {
    templates = {
      basic = {
        path = ./templates/basic;
        description = "dpc's basic flake template";
      };
      rust= {
        path = ./templates/rust;
        description = "dpc's basic rust flake template";
      };
    };
  };
}
