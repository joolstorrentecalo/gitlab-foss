---
stage: Create
group: Editor Extensions
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
description: "Connect and use GitLab Duo in Neovim."
---

# Neovim troubleshooting

When troubleshooting the GitLab plugin for Neovim, you should confirm if an issue still occurs
in isolation from other Neovim plugins and settings. Run the Neovim [testing steps](#test-your-neovim-configuration),
then the [troubleshooting steps](#troubleshooting-code-suggestions) for GitLab Duo Code Suggestions.

If the steps on this page don't solve your problem, check the
[list of open issues](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/?sort=created_date&state=opened&first_page_size=100)
in the Neovim plugin's project. If an issue matches your problem, update the issue.
If no issues match your problem, [create a new issue](https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim/-/issues/new).

## Test your Neovim configuration

The maintainers of the Neovim plugin often ask for the results of these checks as part of troubleshooting:

1. Ensure you have [generated help tags](#generate-help-tags).
1. Run [`:checkhealth`](#run-checkhealth).
1. Enable [debug logs](#enable-debug-logs).
1. Try to [reproduce the problem in a minimal project](#reproduce-the-problem-in-a-minimal-project).

### Generate help tags

If you see the error `E149: Sorry, no help for gitlab.txt`, you need to generate help tags in Neovim.
To resolve this issue:

- Run either of these commands:
  - `:helptags ALL`
  - `:helptags doc/` from the root directory of the plugin.

### Run `:checkhealth`

Run `:checkhealth gitlab*` to get diagnostics on your current session configuration.
These checks help you identify and resolve configuration issues on your own.

## Enable debug logs

To enable more logging:

- Set the `vim.lsp` log level in `init.lua`:

  ```lua
  vim.lsp.set_log_level('debug')
  ```

## Reproduce the problem in a minimal project

To help improve the maintainers' ability to understand and resolve your issue, create a sample
configuration or project that reproduces your issue. For example, when troubleshooting
a problem with Code Suggestions:

1. Create a sample project:

   ```plaintext
   mkdir issue-25
   cd issue-25
   echo -e "def hello(name)\n\nend" > hello.rb
   ```

1. Create a new file named `minimal.lua`, with these contents:

   ```lua
   vim.lsp.set_log_level('debug')

   vim.opt.rtp:append('$HOME/.local/share/nvim/site/pack/gitlab/start/gitlab.vim')

   vim.cmd('runtime plugin/gitlab.lua')

   -- gitlab.config options overrides:
   local minimal_user_options = {}
   require('gitlab').setup(minimal_user_options)
   ```

1. In a minimal Neovim session, edit `hello.rb`:

   ```shell
   nvim --clean -u minimal.lua hello.rb
   ```

1. Attempt to reproduce the behavior you experienced. Adjust `minimal.lua` or other project files as needed.
1. View recent entries in `~/.local/state/nvim/lsp.log` and capture relevant output:

   ```plaintext
   echo ~/.local/state/nvim/lsp.log
   ```

## Troubleshooting Code Suggestions

If code completions fail:

1. Confirm `omnifunc` is set in Neovim:

   ```lua
   :verbose set omnifunc?
   ```

1. Confirm the Language Server is active by running this command in Neovim:

   ```lua
   :lua =vim.lsp.get_active_clients()
   ```

1. Check the logs for the Language Server in `~/.local/state/nvim/lsp.log`.
1. Inspect the `vim.lsp` log path for errors by running this command in Neovim:

   ```lua
   :lua =vim.cmd('view ' .. vim.lsp.get_log_path())
   ```

### Error: `GCS:unavailable`

This error happens when your local project has not set a remote in `.git/config`.

To resolve this issue: add a Git remote in your local project using
[`git remote add`](../../topics/git/commands.md#git-remote-add).
