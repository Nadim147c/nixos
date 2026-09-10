//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma UseQApplication
//@ pragma StateDir $BASE/quickshell

import qs.modules.bar
import qs.modules.clipboard
import qs.modules.common
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
        Yankd.search("");
    }

    LazyLoader {
        activeAsync: true
        component: VolumeOSD {}
    }
    LazyLoader {
        activeAsync: true
        component: Bar {}
    }
    LazyLoader {
        activeAsync: Toggle.player
        component: Player {}
    }
    LazyLoader {
        activeAsync: Toggle.wallpaper
        component: Wallpaper {}
    }
    LazyLoader {
        activeAsync: Toggle.logout
        component: Logout {}
    }
    LazyLoader {
        activeAsync: Toggle.panel
        component: Panel {}
    }
    LazyLoader {
        activeAsync: Toggle.clipboard
        component: Clipboard {}
    }
    LazyLoader {
        activeAsync: Toggle.discord
        component: DiscordOverly {}
    }
    LazyLoader {
        activeAsync: Toggle.launcher
        component: Launcher {}
    }
}
