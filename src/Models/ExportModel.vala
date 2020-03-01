/*
* Copyright (c) 2020 Alecaddd (https://alecaddd.com)
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
    public Gdk.Pixbuf pixbuf { get; set construct; }
    public string filename { get; set construct; }
    public string format { get; set construct; }
    public int quality { get; set construct; }
    public int compression { get; set construct; }

    public ExportModel (Gdk.Pixbuf pixbuf, string filename, string format, int quality, int compression) {
        Object (
            pixbuf: pixbuf,
            filename: filename,
            format: format,
            quality: quality,
            compression: compression
        );
    }

    public string to_string () {
        return "Filename: %s".printf (filename);
    }
}
