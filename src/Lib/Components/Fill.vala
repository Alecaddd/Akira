/**
 * Copyright (c) 2019-2021 Alecaddd (https://alecaddd.com)
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
 * Authored by: Martin "mbfraga" Fraga <mbfraga@gmail.com>
 */

public class Akira.Lib.Components.Fill : GLib.Object {
    public struct FillData {
        public int _id;
        public Color _color;

        public FillData (int id = -1, Color color = Color ()) {
            _id = id;
            _color = color;
        }

        public FillData.deserialized (int id, Json.Object obj) {
            _id = id;
            _color = Color.deserialized (obj.get_object_member ("color"));
        }

        // Recommended accessors

        public int id () { return _id; }
        public Gdk.RGBA color () { return _color.rgba; }
        public bool is_color_hidden () { return _color.hidden; }

        // Mutators

        public FillData with_color (Color new_color) {
            return FillData (_id, new_color);
        }

        public Json.Node serialize () {
            var obj = new Json.Object ();
            obj.set_int_member ("id", _id);
            obj.set_member ("color", _color.serialize ());
            var node = new Json.Node (Json.NodeType.OBJECT);
            node.set_object (obj);
            return node;
        }
    }

    // main data for boxed Fill
    private FillData _data;

    public Fill (FillData data) {
        _data = data;
    }

    // Recommended accessors

    public int id () { return _data._id; }
    public Gdk.RGBA color () { return _data._color.rgba; }
    public bool is_color_hidden () { return _data._color.hidden; }

    public void set_hidden (bool is_hidden) {
        _data._color.hidden = is_hidden;
    }

    public void set_color (Color color) {
        _data._color = color;
    }

    public void set_color_rgba (Gdk.RGBA rgba) {
        _data._color.rgba = rgba;
    }
}
