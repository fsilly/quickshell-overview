//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//<<<<<<< HEAD
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//=======
//@ pragma Env QT_QPA_PLATFORMTHEME=
//>>>>>>> main

import "./modules/overview/"
import "./services/"
import "./common/"
import "./common/functions/"
import "./common/widgets/"

import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();
        }
    }

    Overview {}
}
