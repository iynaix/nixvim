{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.plugins.neo-tree;
  helpers = import ../helpers.nix {inherit lib;};
in {
  options.plugins.neo-tree = let
    listOfRendererComponents = with types; listOf (either str attrs);

    mkRendererComponentListOption = helpers.defaultNullOpts.mkNullable listOfRendererComponents;

    mkMappingsOption = defaults:
      helpers.defaultNullOpts.mkNullable
      (with types; attrsOf (either str attrs))
      defaults
      "Mapping options";

    mkWindowMappingsOption = defaults:
      helpers.mkCompositeOption "Window options" {
        mappings = mkMappingsOption defaults;
      };
  in
    helpers.extraOptionsOptions
    // {
      enable = mkEnableOption "neo-tree";

      package = helpers.mkPackageOption "neo-tree" pkgs.vimPlugins.neo-tree-nvim;

      sources =
        helpers.defaultNullOpts.mkNullable (types.listOf types.str)
        ''["filesystem" "buffers" "git_status"]''
        ''
          If a user has a sources list it will replace this one.
          Only sources listed here will be loaded.
          You can also add an external source by adding it's name to this list.
          The name used here must be the same name you would use in a require() call.
        '';

      extraSources = helpers.mkNullOrOption (types.listOf types.str) ''
        Extra sources to be added to the sources. This is an internal nixvim option.
      '';

      addBlankLineAtTop =
        helpers.defaultNullOpts.mkBool false
        "Add a blank line at the top of the tree.";

      autoCleanAfterSessionRestore =
        helpers.defaultNullOpts.mkBool false
        "Automatically clean up broken neo-tree buffers saved in sessions";

      closeIfLastWindow =
        helpers.defaultNullOpts.mkBool false
        "Close Neo-tree if it is the last window left in the tab";

      closeFloatsOnEscapeKey = helpers.defaultNullOpts.mkBool true "";

      defaultSource = helpers.defaultNullOpts.mkStr "filesystem" "";

      enableDiagnostics = helpers.defaultNullOpts.mkBool true "";

      enableGitStatus = helpers.defaultNullOpts.mkBool true "";

      enableModifiedMarkers =
        helpers.defaultNullOpts.mkBool true
        "Show markers for files with unsaved changes.";

      enableRefreshOnWrite =
        helpers.defaultNullOpts.mkBool true
        "Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.";

      gitStatusAsync = helpers.defaultNullOpts.mkBool true "";

      gitStatusAsyncOptions =
        helpers.mkCompositeOption
        "These options are for people with VERY large git repos" {
          batchSize =
            helpers.defaultNullOpts.mkInt 1000
            "How many lines of git status results to process at a time";

          batchDelay =
            helpers.defaultNullOpts.mkInt 10
            "delay in ms between batches. Spreads out the workload to let other processes run.";

          maxLines =
            helpers.defaultNullOpts.mkInt 10000
            ''
              How many lines of git status results to process. Anything after this will be dropped.
              Anything before this will be used.
              The last items to be processed are the untracked files.
            '';
        };

      hideRootNode = helpers.defaultNullOpts.mkBool false "Hide the root node.";

      retainHiddenRootIndent =
        helpers.defaultNullOpts.mkBool false
        ''
          If the root node is hidden, keep the indentation anyhow.
          This is needed if you use expanders because they render in the indent.
        '';

      logLevel =
        helpers.defaultNullOpts.mkEnum
        ["trace" "debug" "info" "warn" "error" "fatal"] "info" "";

      logToFile =
        helpers.defaultNullOpts.mkNullable (types.either types.bool types.str)
        "false"
        "use :NeoTreeLogs to show the file";

      openFilesInLastWindow =
        helpers.defaultNullOpts.mkBool true
        "If `false`, open files in top left window";

      popupBorderStyle =
        helpers.defaultNullOpts.mkEnum
        ["NC" "double" "none" "rounded" "shadow" "single" "solid"] "NC" "";

      resizeTimerInterval =
        helpers.defaultNullOpts.mkInt 500
        ''
          In ms, needed for containers to redraw right aligned and faded content.
          Set to -1 to disable the resize timer entirely.

          NOTE: this will speed up to 50 ms for 1 second following a resize
        '';

      sortCaseInsensitive =
        helpers.defaultNullOpts.mkBool false
        "Used when sorting files and directories in the tree";

      sortFunction =
        helpers.defaultNullOpts.mkStr "nil"
        "Uses a custom function for sorting files and directories in the tree";

      usePopupsForInput =
        helpers.defaultNullOpts.mkBool true
        "If false, inputs will use vim.ui.input() instead of custom floats.";

      useDefaultMappings = helpers.defaultNullOpts.mkBool true "";

      sourceSelector =
        helpers.mkCompositeOption
        "sourceSelector provides clickable tabs to switch between sources."
        {
          winbar =
            helpers.defaultNullOpts.mkBool false
            "toggle to show selector on winbar";

          statusline =
            helpers.defaultNullOpts.mkBool false
            "toggle to show selector on statusline";

          showScrolledOffParentNode = helpers.defaultNullOpts.mkBool false ''
            If `true`, tabs are replaced with the parent path of the top visible node when
            scrolled down.
          '';

          tabLabels =
            helpers.mkCompositeOption
            ''
              Configure the characters shown on each tab.
              Keys of the table should match the source names defined in `sources`.
              Value is what is printed inside the tab.
              If value is `nil` or not set, the source name is used instead.
            '' {
              filesystem = helpers.defaultNullOpts.mkStr "  Files " "tab label for files";
              buffers = helpers.defaultNullOpts.mkStr "  Buffers " "tab label for buffers";
              gitStatus = helpers.defaultNullOpts.mkStr "  Git " "tab label for git status";
              diagnostics =
                helpers.defaultNullOpts.mkStr " 裂Diagnostics "
                "tab label for diagnostics";
            };

          contentLayout =
            helpers.defaultNullOpts.mkEnumFirstDefault ["start" "end" "focus"]
            ''
              Defines how the labels are placed inside a tab.
              This only takes effect when the tab width is greater than the length of label i.e.
              `tabsLayout = "equal", "focus"` or when `tabsMinWidth` is large enough.

              Following options are available.
                  "start"  : left aligned                  / 裡 bufname     \/..
                  "end"    : right aligned                 /     裡 bufname \/...
                  "center" : centered with equal padding   /   裡 bufname   \/...
            '';

          tabsLayout =
            helpers.defaultNullOpts.mkEnum
            ["start" "end" "center" "equal" "focus"]
            "equal"
            ''
              Defines how the tabs are aligned inside the window when there is more than enough
              space.
              The following options are available.
              `active` will expand the focused tab as much as possible. Bars denote the edge of window.

                  "start"  : left aligned                                       ┃/  ~  \/  ~  \/  ~  \            ┃
                  "end"    : right aligned                                      ┃            /  ~  \/  ~  \/  ~  \┃
                  "center" : centered with equal padding                        ┃      /  ~  \/  ~  \/  ~  \      ┃
                  "equal"  : expand all tabs equally to fit the window width    ┃/    ~    \/    ~    \/    ~    \┃
                  "active" : expand the focused tab to fit the window width     ┃/  focused tab    \/  ~  \/  ~  \┃
            '';

          truncationCharacter =
            helpers.defaultNullOpts.mkStr "…"
            "Character to use when truncating the tab label";

          tabsMinWidth =
            helpers.defaultNullOpts.mkNullable types.int "null"
            "If int padding is added based on `contentLayout`";

          tabsMaxWidth =
            helpers.defaultNullOpts.mkNullable types.int "null"
            "This will truncate text even if `textTruncToFit = false`";

          padding =
            helpers.defaultNullOpts.mkNullable
            (with types; either int (attrsOf int))
            "0"
            ''
              Defines the global padding of the source selector.
              It can be an integer or an attrs with keys `left` and `right`.
              Setting `padding = 2` is exactly the same as `{ left = 2; right = 2; }`.

              Example: `{ left = 2; right = 0; }`
            '';

          separator =
            helpers.defaultNullOpts.mkNullable
            (
              with types;
                either str (submodule {
                  options = {
                    left = helpers.defaultNullOpts.mkStr "▏" "";
                    right = helpers.defaultNullOpts.mkStr "\\" "";
                    override = helpers.defaultNullOpts.mkStr null "";
                  };
                })
            )
            "Can be a string or a table"
            ''{ left = "▏"; right= "▕"; }'';

          separatorActive =
            helpers.defaultNullOpts.mkNullable
            (
              with types;
                either str (submodule {
                  options = {
                    left = helpers.mkNullOrOption types.str "";
                    right = helpers.mkNullOrOption types.str "";
                    override = helpers.mkNullOrOption types.str "";
                  };
                })
            )
            ''
              Set separators around the active tab.
              null falls back to `sourceSelector.separator`.
            ''
            "null";

          showSeparatorOnEdge =
            helpers.defaultNullOpts.mkBool false
            ''
              Takes a boolean value where `false` (default) hides the separators on the far
              left / right.
              Especially useful when left and right separator are the same.

                  'true'  : ┃/    ~    \/    ~    \/    ~    \┃
                  'false' : ┃     ~    \/    ~    \/    ~     ┃
            '';

          highlightTab = helpers.defaultNullOpts.mkStr "NeoTreeTabInactive" "";

          highlightTabActive = helpers.defaultNullOpts.mkStr "NeoTreeTabActive" "";

          highlightBackground = helpers.defaultNullOpts.mkStr "NeoTreeTabInactive" "";

          highlightSeparator = helpers.defaultNullOpts.mkStr "NeoTreeTabSeparatorInactive" "";

          highlightSeparatorActive = helpers.defaultNullOpts.mkStr "NeoTreeTabSeparatorActive" "";
        };
      eventHandlers =
        helpers.mkNullOrOption
        (types.attrsOf types.str)
        ''
          Configuration of event handlers.
          Attrs:
          - keys are the events (e.g. `before_render`, `file_opened`)
          - values are lua code defining the callback function.

          Example:
          ```
          {
            before_render = \'\'
              function (state)
                -- add something to the state that can be used by custom components
              end
            \'\';

            file_opened = \'\'
              function(file_path)
                --auto close
                require("neo-tree").close_all()
              end
            \'\';
          }
          ```
        '';

      defaultComponentConfigs = helpers.mkCompositeOption "Configuration for default components." {
        container = helpers.mkCompositeOption "Container options" {
          enableCharacterFade = helpers.defaultNullOpts.mkBool true "";

          width = helpers.defaultNullOpts.mkStr "100%" "";

          rightPadding = helpers.defaultNullOpts.mkInt 0 "";
        };

        diagnostics = helpers.mkCompositeOption "diagnostics" {
          symbols = helpers.mkCompositeOption "symbols" {
            hint = helpers.defaultNullOpts.mkStr "H" "";

            info = helpers.defaultNullOpts.mkStr "I" "";

            warn = helpers.defaultNullOpts.mkStr "!" "";

            error = helpers.defaultNullOpts.mkStr "X" "";
          };

          highlights = helpers.mkCompositeOption "highlights" {
            hint = helpers.defaultNullOpts.mkStr "DiagnosticSignHint" "";

            info = helpers.defaultNullOpts.mkStr "DiagnosticSignInfo" "";

            warn = helpers.defaultNullOpts.mkStr "DiagnosticSignWarn" "";

            error = helpers.defaultNullOpts.mkStr "DiagnosticSignError" "";
          };
        };

        indent = helpers.mkCompositeOption "indent" {
          indentSize = helpers.defaultNullOpts.mkInt 2 "";

          padding = helpers.defaultNullOpts.mkInt 1 "";

          withMarkers = helpers.defaultNullOpts.mkBool true "";

          indentMarker = helpers.defaultNullOpts.mkStr "│" "";

          lastIndentMarker = helpers.defaultNullOpts.mkStr "└" "";

          highlight = helpers.defaultNullOpts.mkStr "NeoTreeIndentMarker" "";

          withExpanders =
            helpers.defaultNullOpts.mkNullable types.bool "null"
            "If null and file nesting is enabled, will enable expanders.";

          expanderCollapsed = helpers.defaultNullOpts.mkStr "" "";

          expanderExpanded = helpers.defaultNullOpts.mkStr "" "";

          expanderHighlight = helpers.defaultNullOpts.mkStr "NeoTreeExpander" "";
        };

        icon = {
          folderClosed = helpers.defaultNullOpts.mkStr "" "";

          folderOpen = helpers.defaultNullOpts.mkStr "" "";

          folderEmpty = helpers.defaultNullOpts.mkStr "ﰊ" "";

          folderEmptyOpen = helpers.defaultNullOpts.mkStr "ﰊ" "";

          default = helpers.defaultNullOpts.mkStr "*" ''
            Only a fallback, if you use nvim-web-devicons and configure default icons there
            then this will never be used.
          '';

          highlight = helpers.defaultNullOpts.mkStr "NeoTreeFileIcon" ''
            Only a fallback, if you use nvim-web-devicons and configure default icons there
            then this will never be used.
          '';
        };

        modified = helpers.mkCompositeOption "modified" {
          symbol = helpers.defaultNullOpts.mkStr "[+] " "";

          highlight = helpers.defaultNullOpts.mkStr "NeoTreeModified" "";
        };

        name = helpers.mkCompositeOption "name" {
          trailingSlash = helpers.defaultNullOpts.mkBool false "";

          useGitStatusColors = helpers.defaultNullOpts.mkBool true "";

          highlight = helpers.defaultNullOpts.mkStr "NeoTreeFileName" "";
        };

        gitStatus = helpers.mkCompositeOption "git status" {
          symbols =
            helpers.mkCompositeOption
            ''
              Symbol characters for git status.
              Set to empty string to not show them.
            ''
            (
              mapAttrs
              (
                optionName: default:
                  helpers.defaultNullOpts.mkStr default optionName
              )
              {
                added = "✚";
                deleted = "✖";
                modified = "";
                renamed = "";
                untracked = "";
                ignored = "";
                unstaged = "";
                staged = "";
                conflict = "";
              }
            );

          align = helpers.defaultNullOpts.mkStr "right" "icon alignment";
        };
      };

      renderers = helpers.mkCompositeOption "Renderers configuration" {
        directory =
          mkRendererComponentListOption
          ''
            [
              "indent"
              "icon"
              "current_filter"
              {
                name = "container";
                content = [
                  {
                    name = "name";
                    zindex = 10;
                  }
                  {
                    name = "clipboard";
                    zindex = 10;
                  }
                  {
                    name = "diagnostics";
                    errors_only = true;
                    zindex = 20;
                    align = "right";
                    hide_when_expanded = true;
                  }
                  {
                    name = "git_status";
                    zindex = 20;
                    align = "right";
                    hide_when_expanded = true;
                  }
                ];
              }
            ]
          ''
          "directory renderers";

        file =
          mkRendererComponentListOption
          ''
            [
              "indent"
              "icon"
              {
                name = "container";
                content = [
                  {
                    name = "name";
                    zindex = 10;
                  }
                  {
                    name = "clipboard";
                    zindex = 10;
                  }
                  {
                    name = "bufnr";
                    zindex = 10;
                  }
                  {
                    name = "modified";
                    zindex = 20;
                    align = "right";
                  }
                  {
                    name = "diagnostics";
                    zindex = 20;
                    align = "right";
                  }
                  {
                    name = "git_status";
                    zindex = 20;
                    align = "right";
                  }
                ];
              }
            ]
          ''
          "file renderers";

        message =
          mkRendererComponentListOption
          ''
            [
              {
                name = "indent";
                with_markers = false;
              }
              {
                name = "name";
                highlight = "NeoTreeMessage";
              }
            ]
          ''
          "message renderers";

        terminal =
          mkRendererComponentListOption
          ''
            [
              "indent"
              "icon"
              "name"
              "bufnr"
            ]
          ''
          "message renderers";
      };

      nestingRules =
        helpers.defaultNullOpts.mkNullable (types.attrsOf types.str) "{}"
        "nesting rules";

      window =
        helpers.mkCompositeOption
        ''
          Window options.
          See https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for possible options.
          These can also be functions that return these options.
        ''
        {
          position =
            helpers.defaultNullOpts.mkEnum
            ["left" "right" "top" "bottom" "float" "current"] "left" "position";

          width = helpers.defaultNullOpts.mkInt 40 "Applies to left and right positions";

          height = helpers.defaultNullOpts.mkInt 15 "Applies to top and bottom positions";

          autoExpandWidth =
            helpers.defaultNullOpts.mkBool false
            ''
              Expand the window when file exceeds the window width. does not work with
              position = "float"
            '';

          popup = helpers.mkCompositeOption "Settings that apply to float position only" {
            size = helpers.mkCompositeOption "size" {
              height = helpers.defaultNullOpts.mkStr "80%" "height";

              width = helpers.defaultNullOpts.mkStr "50%" "height";
            };

            position = helpers.defaultNullOpts.mkStr "80%" ''
              50% means center it.
              You can also specify border here, if you want a different setting from the global
              `popupBorderStyle`.
            '';
          };

          sameLevel = helpers.defaultNullOpts.mkBool false ''
            Create and paste/move files/directories on the same level as the directory under cursor
            (as opposed to within the directory under cursor).
          '';

          insertAs = helpers.defaultNullOpts.mkEnumFirstDefault ["child" "sibling"] ''
            Affects how nodes get inserted into the tree during creation/pasting/moving of files if
            the node under the cursor is a directory:

            - "child":   Insert nodes as children of the directory under cursor.
            - "sibling": Insert nodes  as siblings of the directory under cursor.
          '';

          mappingOptions = helpers.mkCompositeOption "Mapping options" {
            noremap = helpers.defaultNullOpts.mkBool true "noremap";

            nowait = helpers.defaultNullOpts.mkBool true "nowait";
          };

          mappings = mkMappingsOption ''
            {
              "<space>" = {
                command = "toggle_node";
                # disable `nowait` if you have existing combos starting with this char that you want to use
                nowait = false;
              };
              "<2-LeftMouse>" = "open";
              "<cr>" = "open";
              "<esc>" = "revert_preview";
              P = {
                command = "toggle_preview";
                config = { use_float = true; };
              };
              l = "focus_preview";
              S = "open_split";
              # S = "split_with_window_picker";
              s = "open_vsplit";
              # s = "vsplit_with_window_picker";
              t = "open_tabnew";
              # "<cr>" = "open_drop";
              # t = "open_tab_drop";
              w = "open_with_window_picker";
              C = "close_node";
              z = "close_all_nodes";
              # Z = "expand_all_nodes";
              R = "refresh";
              a = {
                command = "add";
                # some commands may take optional config options, see `:h neo-tree-mappings` for details
                config = {
                  show_path = "none"; # "none", "relative", "absolute"
                };
              };
              A = "add_directory"; # also accepts the config.show_path and config.insert_as options.
              d = "delete";
              r = "rename";
              y = "copy_to_clipboard";
              x = "cut_to_clipboard";
              p = "paste_from_clipboard";
              c = "copy"; # takes text input for destination, also accepts the config.show_path and config.insert_as options
              m = "move"; # takes text input for destination, also accepts the config.show_path and config.insert_as options
              e = "toggle_auto_expand_width";
              q = "close_window";
              "?" = "show_help";
              "<" = "prev_source";
              ">" = "next_source";
            }
          '';
        };
      filesystem = helpers.mkCompositeOption "Filesystem options" {
        window = mkWindowMappingsOption ''
          {
            H = "toggle_hidden";
            "/" = "fuzzy_finder";
            D = "fuzzy_finder_directory";
            # "/" = "filter_as_you_type"; # this was the default until v1.28
            "#" = "fuzzy_sorter"; # fuzzy sorting using the fzy algorithm
            # D = "fuzzy_sorter_directory";
            f = "filter_on_submit";
            "<C-x>" = "clear_filter";
            "<bs>" = "navigate_up";
            "." = "set_root";
            "[g" = "prev_git_modified";
            "]g" = "next_git_modified";
          }
        '';
        asyncDirectoryScan = helpers.defaultNullOpts.mkEnumFirstDefault ["auto" "always" "never"] ''
          - "auto" means refreshes are async, but it's synchronous when called from the Neotree
          commands.
          - "always" means directory scans are always async.
          - "never"  means directory scans are never async.
        '';

        scanMode = helpers.defaultNullOpts.mkEnumFirstDefault ["shallow" "deep"] ''
          - "shallow": Don't scan into directories to detect possible empty directory a priori.
          - "deep": Scan into directories to detect empty or grouped empty directories a priori.
        '';

        bindToCwd =
          helpers.defaultNullOpts.mkBool true
          "true creates a 2-way binding between vim's cwd and neo-tree's root.";

        cwdTarget = helpers.mkCompositeOption "cwd target" {
          sidebar = helpers.defaultNullOpts.mkStr "tab" "sidebar is when position = left or right";
          current = helpers.defaultNullOpts.mkStr "window" "current is when position = current";
        };

        filteredItems = helpers.mkCompositeOption "filtered items" {
          visible =
            helpers.defaultNullOpts.mkBool false
            "when true, they will just be displayed differently than normal items";

          forceVisibleInEmptyFolder =
            helpers.defaultNullOpts.mkBool false
            "when true, hidden files will be shown if the root folder is otherwise empty";

          showHiddenCount =
            helpers.defaultNullOpts.mkBool true
            "when true, the number of hidden items in each folder will be shown as the last entry";

          hideDotfiles = helpers.defaultNullOpts.mkBool true "hide dotfiles";

          hideGitignored = helpers.defaultNullOpts.mkBool true "hide gitignored files";

          hideHidden =
            helpers.defaultNullOpts.mkBool true
            "only works on Windows for hidden files/directories";

          hideByName =
            helpers.defaultNullOpts.mkNullable (types.listOf types.str) ''
              [
                ".DS_Store"
                "thumbs.db"
                # "node_modules"
              ]
            ''
            "hide by name";

          hideByPattern =
            helpers.defaultNullOpts.mkNullable (types.listOf types.str) ''
              [
                # "*.meta"
                # "*/src/*/tsconfig.json"
              ]
            ''
            "hide by pattern";

          alwaysShow =
            helpers.defaultNullOpts.mkNullable (types.listOf types.str) ''
              [
                # ".gitignored"
              ]
            ''
            "files/folders to always show";

          neverShow =
            helpers.defaultNullOpts.mkNullable (types.listOf types.str) ''
              [
                # ".DS_Store"
                # "thumbs.db"
              ]
            ''
            "files/folders to never show";

          neverShowByPattern =
            helpers.defaultNullOpts.mkNullable (types.listOf types.str) ''
              [
                # ".null-ls_*"
              ]
            ''
            "files/folders to never show (by pattern)";
        };

        findByFullPathWords = helpers.defaultNullOpts.mkBool false ''
          `false` means it only searches the tail of a path.
          `true` will change the filter into a full path

          search with space as an implicit ".*", so `fi init` will match:
          `./sources/filesystem/init.lua
        '';

        findCommand =
          helpers.defaultNullOpts.mkStr "fd"
          "This is determined automatically, you probably don't need to set it";

        findArgs =
          helpers.mkNullOrOption
          (types.either types.str (types.submodule {
            options = {
              fd =
                helpers.defaultNullOpts.mkNullable (types.listOf types.str)
                ''
                  [
                    "--exclude"
                    ".git"
                    "--exclude"
                    "node_modules"
                  ]
                ''
                "You can specify extra args to pass to the find command.";
            };
          }))
          ''
            Find arguments

            Either use a list of strings:

            ```
            findArgs = {
              fd = [
                "--exclude"
                ".git"
                "--exclude"
                "node_modules"
              ];
            };
            ```

            Or use a function instead of list of strings
            ```
            findArgs = \'\'
              find_args = function(cmd, path, search_term, args)
                if cmd ~= "fd" then
                  return args
                end
                --maybe you want to force the filter to always include hidden files:
                table.insert(args, "--hidden")
                -- but no one ever wants to see .git files
                table.insert(args, "--exclude")
                table.insert(args, ".git")
                -- or node_modules
                table.insert(args, "--exclude")
                table.insert(args, "node_modules")
                --here is where it pays to use the function, you can exclude more for
                --short search terms, or vary based on the directory
                if string.len(search_term) < 4 and path == "/home/cseickel" then
                  table.insert(args, "--exclude")
                  table.insert(args, "Library")
                end
                return args
              end
            \'\';
            ```
          '';

        groupEmptyDirs =
          helpers.defaultNullOpts.mkBool false
          "when true, empty folders will be grouped together";

        searchLimit =
          helpers.defaultNullOpts.mkInt 50
          "max number of search results when using filters";

        followCurrentFile = helpers.defaultNullOpts.mkBool false ''
          This will find and focus the file in the active buffer every time the current file is
          changed while the tree is open.
        '';

        hijackNetrwBehavior =
          helpers.defaultNullOpts.mkEnumFirstDefault
          ["open_default" "open_current" "disabled"]
          ''
            - "open_default": netrw disabled, opening a directory opens neo-tree in whatever
              position is specified in window.position
            - "open_current": netrw disabled, opening a directory opens within the window like netrw
              would, regardless of window.position
            - "disabled": netrw left alone, neo-tree does not handle opening dirs
          '';

        useLibuvFileWatcher = helpers.defaultNullOpts.mkBool false ''
          This will use the OS level file watchers to detect changes instead of relying on nvim
          autocmd events.
        '';
      };

      buffers = helpers.mkCompositeOption "Buffers options" {
        bindToCwd = helpers.defaultNullOpts.mkBool true "Bind to current working directory.";

        followCurrentFile = helpers.defaultNullOpts.mkBool true ''
          This will find and focus the file in the active buffer every time the current file is
          changed while the tree is open.
        '';

        groupEmptyDirs =
          helpers.defaultNullOpts.mkBool true
          "When true, empty directories will be grouped together.";

        window = mkWindowMappingsOption ''
          {
            "<bs>" = "navigate_up";
            "." = "set_root";
            bd = "buffer_delete";
          }
        '';
      };

      gitStatus = helpers.mkCompositeOption "git status options" {
        window = mkWindowMappingsOption ''
          {
            A = "git_add_all";
            gu = "git_unstage_file";
            ga = "git_add_file";
            gr = "git_revert_file";
            gc = "git_commit";
            gp = "git_push";
            gg = "git_commit_and_push";
          }
        '';
      };

      example = helpers.mkCompositeOption "example options" {
        renderers = helpers.mkCompositeOption "renderers" {
          custom =
            mkRendererComponentListOption
            ''
              [
                "indent"
                {
                  name = "icon";
                  default = "C";
                }
                "custom"
                "name"
              ]
            ''
            "custom renderers";
        };

        window = mkWindowMappingsOption ''
          {
            "<cr>" = "toggle_node";
            "<C-e>" = "example_command";
            d = "show_debug_info";
          }
        '';
      };
    };

  config = let
    inherit (helpers) ifNonNull' mkRaw;

    processRendererComponent = component:
      if isString component
      then [component]
      else
        (mapAttrs' (
            name: value: {
              name =
                if name == "name"
                then "@"
                else name;
              value =
                if isList value
                then processRendererComponentList value
                else value;
            }
          )
          component);

    processRendererComponentList = componentList:
      ifNonNull' componentList
      (map processRendererComponent componentList);

    processMapping = key: action:
      if isString action
      then action
      else
        mapAttrs' (k: v: {
          name =
            if k == "command"
            then "@"
            else k;
          value = v;
        })
        action;

    processMappings = mappings:
      ifNonNull' mappings
      (mapAttrs processMapping mappings);

    processWindowMappings = window:
      ifNonNull' window {
        mappings = processMappings window;
      };

    options = with cfg;
      {
        # Concatenate sources and extraSources, setting sources to it's default value if it is null
        # and extraSources is not null
        sources =
          if (!isNull cfg.extraSources)
          then
            if (isNull cfg.sources)
            then ["filesystem" "git_status" "buffers"] ++ cfg.extraSources
            else cfg.sources ++ cfg.extraSources
          else cfg.sources;
        add_blank_line_at_top = cfg.addBlankLineAtTop;
        auto_clean_after_session_restore = cfg.autoCleanAfterSessionRestore;
        close_if_last_window = cfg.closeIfLastWindow;
        close_floats_on_escape_key = cfg.closeFloatsOnEscapeKey;
        default_source = cfg.defaultSource;
        enable_diagnostics = cfg.enableDiagnostics;
        enable_git_status = cfg.enableGitStatus;
        enable_modified_markers = cfg.enableModifiedMarkers;
        enable_refresh_on_write = cfg.enableRefreshOnWrite;
        git_status_async = cfg.gitStatusAsync;
        git_status_async_options = ifNonNull' cfg.gitStatusAsyncOptions {
          batch_size = cfg.gitStatusAsyncOptions.batchSize;
          batch_delay = cfg.gitStatusAsyncOptions.batchDelay;
          max_lines = cfg.gitStatusAsyncOptions.maxLines;
        };
        hide_root_node = cfg.hideRootNode;
        retain_hidden_root_indent = cfg.retainHiddenRootIndent;
        log_level = cfg.logLevel;
        log_to_file = cfg.logToFile;
        open_files_in_last_window = cfg.openFilesInLastWindow;
        popup_border_style = cfg.popupBorderStyle;
        resize_timer_interval = cfg.resizeTimerInterval;
        sort_case_insensitive = cfg.sortCaseInsensitive;
        sort_function =
          ifNonNull' cfg.sortFunction
          (mkRaw cfg.sortFunction);
        use_popups_for_input = cfg.usePopupsForInput;
        use_default_mappings = cfg.useDefaultMappings;
        source_selector = with cfg.sourceSelector;
          ifNonNull' cfg.sourceSelector {
            inherit winbar statusline;
            show_scrolled_off_parent_node = showScrolledOffParentNode;
            tab_labels = with tabLabels;
              ifNonNull' cfg.sourceSelector.tabLabels {
                inherit filesystem buffers diagnostics;
                git_status = gitStatus;
              };
            content_layout = contentLayout;
            tabs_layout = tabsLayout;
            truncation_character = truncationCharacter;
            tabs_min_width = tabsMinWidth;
            tabs_max_width = tabsMaxWidth;
            inherit padding separator;
            separator_active = separatorActive;
            show_separator_on_edge = showSeparatorOnEdge;
            highlight_tab = highlightTab;
            highlight_tab_active = highlightTabActive;
            highlight_background = highlightBackground;
            highlight_separator = highlightSeparator;
            highlight_separator_active = highlightSeparatorActive;
          };
        event_handlers =
          ifNonNull' cfg.eventHandlers
          (
            mapAttrsToList
            (event: handler: {
              inherit event;
              handler = helpers.mkRaw handler;
            })
            cfg.eventHandlers
          );
        default_component_configs = with cfg.defaultComponentConfigs;
          ifNonNull' cfg.defaultComponentConfigs {
            container = ifNonNull' cfg.defaultComponentConfigs.container {
              enable_character_fade = container.enableCharacterFade;
              inherit (container) width;
              right_padding = container.rightPadding;
            };
            inherit diagnostics;
            indent = with indent;
              ifNonNull' cfg.defaultComponentConfigs.indent {
                indent_size = indentSize;
                inherit padding;
                with_markers = withMarkers;
                indent_markers = indentMarker;
                last_indent_marker = lastIndentMarker;
                inherit highlight;
                with_expanders = withExpanders;
                expander_collapsed = expanderCollapsed;
                expander_expanded = expanderExpanded;
                expander_highlight = expanderHighlight;
              };
            icon = with icon;
              ifNonNull' cfg.defaultComponentConfigs.icon {
                folder_closed = folderClosed;
                folder_open = folderOpen;
                folder_empty = folderEmpty;
                folder_empty_open = folderEmptyOpen;
                inherit default highlight;
              };
            inherit modified;
            name = with name;
              ifNonNull' cfg.defaultComponentConfigs.name {
                trailing_slash = trailingSlash;
                use_git_status_colors = useGitStatusColors;
                inherit highlight;
              };
            git_status = gitStatus;
          };
        renderers = ifNonNull' cfg.renderers (
          mapAttrs (name: processRendererComponentList) cfg.renderers
        );
        nesting_rules = cfg.nestingRules;
        window = with window;
          ifNonNull' cfg.window {
            inherit position width height;
            auto_expand_width = autoExpandWidth;
            inherit popup;
            same_level = sameLevel;
            insert_as = insertAs;
            mapping_options = mappingOptions;
            mappings = processMappings mappings;
          };
        filesystem = with filesystem;
          ifNonNull' cfg.filesystem {
            window = processWindowMappings window;
            async_directory_scan = asyncDirectoryScan;
            scan_mode = scanMode;
            bind_to_cwd = bindToCwd;
            cwd_target = cwdTarget;
            filteredItems = with filteredItems;
              ifNonNull' cfg.filesystem.filteredItems {
                inherit visible;
                force_visible_in_empty_folder = forceVisibleInEmptyFolder;
                show_hidden_count = showHiddenCount;
                hide_dotfiles = hideDotfiles;
                hide_gitignored = hideGitignored;
                hide_hidden = hideHidden;
                hide_by_name = hideByName;
                hide_by_pattern = hideByPattern;
                always_show = alwaysShow;
                never_show = neverShow;
                never_show_by_pattern = neverShowByPattern;
              };
            find_by_full_path_words = findByFullPathWords;
            find_command = findCommand;
            find_args =
              if isString findArgs
              then mkRaw findArgs
              else findArgs;
            group_empty_dirs = groupEmptyDirs;
            search_limit = searchLimit;
            follow_current_file = followCurrentFile;
            hijack_netrw_behavior = hijackNetrwBehavior;
            use_libuv_file_watcher = useLibuvFileWatcher;
          };
        buffers = with buffers;
          ifNonNull' cfg.buffers {
            bind_to_cwd = bindToCwd;
            follow_current_file = followCurrentFile;
            group_empty_dirs = groupEmptyDirs;
            window = processWindowMappings window;
          };
        git_status = ifNonNull' cfg.gitStatus {
          window = processWindowMappings cfg.gitStatus.window;
        };
        example = with example;
          ifNonNull' cfg.example {
            renderers = ifNonNull' cfg.example.renderers {
              custom = processRendererComponentList renderers.custom;
            };
          };
      }
      // cfg.extraOptions;
  in
    mkIf cfg.enable {
      extraPlugins = with pkgs.vimPlugins; [
        cfg.package
        nvim-web-devicons
      ];

      extraConfigLua = ''
        require('neo-tree').setup(${helpers.toLuaObject options})
      '';
      extraPackages = [pkgs.git];
    };
}