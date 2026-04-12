//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication
//@ pragma StateDir $BASE/quickshell

import qs.modules.bar
import qs.modules.clipboard
import qs.modules.common
import qs.modules.dock
import qs.modules.logout
import qs.modules.osd
import qs.modules.panel
import qs.modules.player
import qs.modules.wallpaper
import qs.modules.discord
import qs.modules.launcher

import QtQuick
import Quickshell

ShellRoot {
    property bool shouldShowOsd: false

    Component.onCompleted: {
        Appearance.reloadTheme();
    }

    LazyLoader {
        active: true
        component: VolumeOSD {}
    }
    LazyLoader {
        active: true
        component: Bar {}
    }
    LazyLoader {
        active: Toggle.player
        component: Player {}
    }
    LazyLoader {
        active: Toggle.dock
        component: Dock {}
    }
    LazyLoader {
        active: true
        component: DockSpawner {}
    }
    LazyLoader {
        active: Toggle.wallpaper
        component: Wallpaper {}
    }
    LazyLoader {
        active: Toggle.logout
        component: Logout {}
    }
    LazyLoader {
        active: Toggle.panel
        component: Panel {}
    }
    LazyLoader {
        active: Toggle.clipboard
        component: Clipboard {}
    }
    LazyLoader {
        active: Toggle.discord
        component: DiscordOverly {}
    }
    LazyLoader {
        active: Toggle.launcher
        component: Launcher {}
    }
}
