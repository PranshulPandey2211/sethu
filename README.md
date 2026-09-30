<!--
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
-->

# Sethu

Compact virtual desktop switcher for KDE Plasma 6. Inactive desktops can be dots, pills, or buttons. The current desktop can be a sliding pill. Pills and buttons can show numbers (`d1`, `d2`) or desktop names.

Author: Pranshul Pandey  
License: [GPL-3.0-or-later](LICENSE)

## Install

Requires Plasma 6.

```sh
kpackagetool6 -t Plasma/Applet -i package
systemctl --user restart plasma-plasmashell
```

Then add **Sethu** from the widget list, or use Show Alternatives on the stock virtual desktop widget.

To update an existing install:

```sh
kpackagetool6 -t Plasma/Applet --upgrade package
systemctl --user restart plasma-plasmashell
```

## Use

Left click switches desktops. Clicking the current desktop opens Overview. The wheel switches desktops. Middle click adds a desktop. Right click renames, adds, or removes desktops.

Size and spacing are pixel values. Labels are available on pills and buttons.
