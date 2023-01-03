/*
* Copyright (c) 2020-2022 Alecaddd (https://alecaddd.com)
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
* Authored by: Alessandro "alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Akira.Models.ExportModel : GLib.Object {
    public int node_id { get; set construct; }
    public Gdk.Pixbuf pixbuf { get; set construct; }

    public ExportModel (int node_id, Gdk.Pixbuf pixbuf) {
        Object (
            pixbuf: pixbuf,
            node_id: node_id
        );
    }

    /* TODO: Allow udpating the export name of nodes, and also handle the
    temporary export name for area selection exports. */

    public string to_string () {
        return "Node ID: %i".printf (node_id);
    }
}
