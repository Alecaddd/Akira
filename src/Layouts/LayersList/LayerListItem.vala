/*
 * Copyright (c) 2021 Alecaddd (https://alecaddd.com)
 *
 * This file is part of Akira.
 *
 * Akira is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * Akira is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Akira. If not, see <https://www.gnu.org/licenses/>.
 *
 * Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
 * Adapted from the elementary OS Mail's VirtualizingListBox source code created
 * by David Hewitt <davidmhewitt@gmail.com>
 */

/*
 * The single layer row.
 */
public class Akira.Layouts.LayersList.LayerListItem : VirtualizingListBoxRow {
    private Gtk.Label label;

    construct {
        label = new Gtk.Label ("");
        label.halign = Gtk.Align.FILL;
        label.xalign = 0;
        label.expand = true;
        label.set_ellipsize (Pango.EllipsizeMode.END);

        var grid = new Gtk.Grid ();

        grid.attach (label, 0, 0, 1, 1);

        add (grid);

        show_all ();
    }

    public void assign (LayerItemModel data) {
        label.label = data.name;

        // Build a specific UI based on the node instance's type.
        if (data.is_artboard) {
            build_artboard_ui ();
        } else if (data.is_group) {
            build_group_ui ();
        } else {
            build_layer_ui ();
        }
    }

    private void build_artboard_ui () {
        get_style_context ().add_class ("artboard");
        label.get_style_context ().add_class ("artboard-name");
    }

    /*
     * TODO...
     */
    private void build_group_ui () {}

    private void build_layer_ui () {
        get_style_context ().add_class ("layer");
    }
}
