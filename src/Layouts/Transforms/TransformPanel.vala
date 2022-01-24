/*
 * Copyright (c) 2022 Alecaddd (https://alecaddd.com)
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
 */

/*
 * Layout component containing the input fields representing the transformation
 * matrix of the selected items.
 */
public class Akira.Layouts.Transforms.TransformPanel : Gtk.Grid {
    public unowned Lib.ViewCanvas view_canvas { get; construct; }

    public TransformPanel (Lib.ViewCanvas canvas) {
        Object (
            view_canvas: canvas
        );
    }

    construct {
        border_width = 12;
        row_spacing = column_spacing = 6;
        hexpand = true;

        attach (group_title (_("Position")), 0, 0, 3);
        attach (separator (), 0, 2, 3);
        attach (group_title (_("Size")), 0, 3, 3);
        attach (separator (), 0, 5, 3);
        attach (group_title (_("Transform")), 0, 6, 3);
        attach (separator (), 0, 8, 3);
        attach (group_title (_("Opacity")), 0, 9, 3);
    }

    private Gtk.Label group_title (string title) {
        var title_label = new Gtk.Label (title) {
            halign = Gtk.Align.START,
            hexpand = true,
            margin_bottom = 2
        };
        title_label.get_style_context ().add_class ("group-title");

        return title_label;
    }

    private Gtk.Separator separator () {
        var sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_bottom = 6
        };
        sep.get_style_context ().add_class ("panel-separator");

        return sep;
    }
}
