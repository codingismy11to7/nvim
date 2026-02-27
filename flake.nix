{
  description = "My neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # In case you want nightly
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nixPatch = {
      url = "git+https://codeberg.org/NicoElbers/nixPatch-nvim.git";
      inputs.nixpkgs.follows = "nixpkgs";

      # We do this so that we ensure neovim nightly actually updates
      # inputs.neovim-nightly-overlay.follows = "neovim-nightly-overlay";
    };
  };

  outputs =
    {
      nixpkgs,
      nixPatch,
      ...
    }:
    let
      # Copied from flake utils
      eachSystem =
        with builtins;
        systems: f:
        let
          # Merge together the outputs for all systems.
          op =
            attrs: system:
            let
              ret = f system;
              op =
                attrs: key:
                attrs
                // {
                  ${key} = (attrs.${key} or { }) // {
                    ${system} = ret.${key};
                  };
                };
            in
            foldl' op attrs (attrNames ret);
        in
        foldl' op { } (
          systems
          # add the current system if --impure is used
          ++ (
            if builtins ? currentSystem then
              if elem currentSystem systems then [ ] else [ currentSystem ]
            else
              [ ]
          )
        );

      forEachSystem = eachSystem nixpkgs.lib.platforms.all;

      # Easily configure a custom name, this will affect the name of the standard
      # executable, you can add as many aliases as you'd like in the configuration.
      name = "Neovim";

      # Any custom package config you would like to do.
      extra_pkg_config = {
        allowUnfree = true;
      };

      configuration =
        theme:
        { pkgs, system, ... }:
        let
          patchUtils = nixPatch.patchUtils.${pkgs.stdenv.hostPlatform.system};
        in
        {
          # The path to your neovim configuration.
          luaPath =
            if theme != null then
              pkgs.runCommand "nvim-config" { } ''
                cp -r ${./.} $out
                chmod -R u+w $out
                cp ${pkgs.writeText "theme.lua" theme.content} $out/lua/plugins/theme.lua
              ''
            else
              ./.;

          # Plugins you use in your configuration.
          plugins =
            (with pkgs.vimPlugins; [
              # LazyVim
              lazy-nvim
              LazyVim
              bufferline-nvim
              lazydev-nvim
              conform-nvim
              flash-nvim
              friendly-snippets
              gitsigns-nvim
              grug-far-nvim
              noice-nvim
              lualine-nvim
              mini-files
              mini-hipatterns
              nui-nvim
              nvim-lint
              nvim-lspconfig
              nvim-ts-autotag
              ts-comments-nvim
              blink-cmp
              nvim-web-devicons
              persistence-nvim
              plenary-nvim
              telescope-fzf-native-nvim
              telescope-nvim
              todo-comments-nvim
              tokyonight-nvim
              trouble-nvim
              vim-illuminate
              vim-startuptime
              which-key-nvim
              snacks-nvim
              zellij-nvim
              nvim-treesitter-context
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              # This is for if you only want some of the grammars
              # (nvim-treesitter.withPlugins (
              #   plugins: with plugins; [
              #     nix
              #     lua
              #   ]
              # ))

              mini-ai
              mini-icons
              mini-pairs
            ])
            ++ (if theme != null then theme.plugins or [ ] else [ ]);

          # Runtime dependencies. This is thing like tree-sitter, lsps or programs
          # like ripgrep.
          runtimeDeps = with pkgs; [
            universal-ctags
            ast-grep
            biome
            curl
            lazygit
            ripgrep
            fd
            imagemagick
            shfmt
            stdenv.cc
            alejandra
            deadnix
            dockerfile-language-server
            lua-language-server
            markdown-toc
            markdownlint-cli2
            marksman
            nil
            nixfmt
            statix
            stylua
            taplo
            tree-sitter
            vscode-langservers-extracted
            vtsls
            wl-clipboard
          ];

          # Environment variables set during neovim runtime.
          environmentVariables = { };

          # Aliases for the patched config
          aliases = [
            "nvim"
            "vim"
            "vi"
          ];

          # Extra wrapper args you want to pass.
          # Look here if you don't know what those are:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = [ ];

          # Extra python packages for the neovim provider.
          # This must be a list of functions returning lists.
          python3Packages = [ ];

          # Wrapper args but then for the python provider.
          extraPython3WrapperArgs = [ ];

          # Extra lua packages for the neovim lua runtime.
          luaPackages = [ ];

          # Extra shared libraries available at runtime.
          sharedLibraries = [ ];

          # Extra lua configuration put at the top of your init.lua
          # This cannot replace your init.lua, if none exists in your configuration
          # this will not be writtern.
          # Must be provided as a list of strings.
          extraConfig = [ ];

          # Custom subsitutions you want the patcher to make. Custom subsitutions
          # can be generated using
          customSubs =
            [ ]
            ++ (patchUtils.githubUrlSub "saghen/blink.cmp" pkgs.vimPlugins.blink-cmp)
            ++ (patchUtils.githubUrlSub "treesitter-context/nvim-treesitter-context" pkgs.vimPlugins.nvim-treesitter-context);
          # For example, if you want to add a plugin with the short url
          # "cool/plugin" which is in nixpkgs as plugin-nvim you would do:
          # ++ (patchUtils.githubUrlSub "cool/plugin" plugin-nvim);
          # If you would want to replace the string "replace_me" with "replaced"
          # you would have to do:
          # ++ (patchUtils.stringSub "replace_me" "replaced")
          # For more examples look here: https://github.com/NicoElbers/nixPatch-nvim/blob/main/subPatches.nix

          settings = {
            withNodeJs = true;
            withPython3 = true;
            withRuby = false;
            withPerl = false;

            # Any extra name
            extraName = "";

            # The default config directory for neovim
            configDirName = "nvim";

            # Any other neovim package you would like to use, for example nightly
            neovim-unwrapped = null;

            # When using nightly, it's best to use the version nixPatch exposes,
            # this prevents potential linking errors if nixPatch isn't updated in a
            # while
            # neovim-unwrapped = inputs.nixPatch.neovim-nightly.${system};

            # Whether to add custom subsitution made in the original repo, makes for
            # a better out of the box experience
            patchSubs = true;

            # Whether to add runtime dependencies to the back of the path
            suffix-path = false;

            # Whether to add shared libraries dependencies to the back of the path
            suffix-LD = false;
          };
        };

      mkNeovim =
        {
          system,
          pkgs ? nixpkgs.legacyPackages.${system},
          theme ? null,
        }:
        nixPatch.configWrapper.${system} {
          configuration = configuration theme;
          inherit extra_pkg_config name;
        };
    in
    {
      lib.mkNeovim = mkNeovim;
    }
    // forEachSystem (system: {
      packages.default = mkNeovim { inherit system; };

      formatter = nixpkgs.legacyPackages.${system}.nixfmt;
    });
}
