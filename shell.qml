//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1

import "./modules/overview/"
import "./services/"
import "./common/"
import "./common/functions/"
import "./common/widgets/"

import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Overview {}
}
