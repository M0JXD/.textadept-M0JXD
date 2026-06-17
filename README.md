# My (M0JXD's) ~/.textadept/

My collection of things I use/modified for Textadept.
They're mainly here so I can grab them wherever I need them, but anyone is welcome to use. There's:

- My init.lua
- Various simple utility modules
- Themes that match specifications better than the base16 ones, and include fixes to adapt to to the terminal version:
    - Ayu Light, Mirage, Dark and Evolve (Evolve is Dark with near black background, like the Helix theme).
    - Catppuccin Latte, Frappé, Macchiato and Mocha.
    - Xed Light and Dark to match Linux Mint's default editor.

All of the modules I've made have their own README that explains them. In short, there is:

| Module Name                 | Description |
| :-------------------------- | :---------- |
| Theme Manager               | Helps setting up switched themes and detects missing features (e.g. fonts) to gracefully fallback to defaults |
| Document Statistics         | Gives details about the buffer such as word count, selected lines etc. |
| Distraction Free            | Updated version of Distraction Free mode taking advantage of of Textadept 13 statusbar hiding and additional terminal version support |
| Quick Open                  | Based on "Open Terminal Here", but also allows opening File Browser and TUI Git Clients, working on Windows and various DEs |
| Export Extensions           | Extends the official export module with options to convert Markdown and LaTeX to PDF and HTML |
| Buffer Statusbar Utilities  | String manipulation utilities to make adjusting the Buffer Statusbar easier |
| File Browser (UNMAINTAINED) | A modified version of the Textadept File Browser |

I usually install Textadept to *~/Applications/textadept/*, I always forget my desktop integration steps so:
- Copy desktop files to *~.local/share/applications/* and SVG icons in *~/.local/share/icons/hicolor/scalable/apps/*.
- Add this into *.bashrc* or *.bash_profile* (aliases possibly in *.bash_aliases*):

```bash
export PATH=$HOME/Applications/textadept:$PATH
alias ta="textadept-curses"
alias ta-gtk="textadept-gtk"
alias ta-qt="textadept"
```
