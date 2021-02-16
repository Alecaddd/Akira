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
 * Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
 */

using Akira.Lib.Components;

/**
 * This is the base interface other items will need to extend in order to be created.
 * This interface shouldn't have any abstract attributes other than the components.
 * We use components instead of inheritance to keep our items modular and avoid useless
 * attributes repetitions.
 */
public interface Akira.Lib.Items.CanvasItem : Goo.CanvasItemSimple, Goo.CanvasItem {
    public abstract Gee.ArrayList<Component> components { get; set; }

    // Keep track of the parent artboard if the item belongs to one.
    public abstract Items.CanvasArtboard? artboard { get; set; }

    // Check if an item was created or it was loaded for ordering purpose.
    public abstract bool is_loaded { get; set; }

    /**
     * Find the component attached to the item by its GLib.Type.
     */
    private Component? get_component (GLib.Type type) {
        foreach (Component comp in components) {
            if (comp.get_type () == type) {
                return comp;
            }
        }

        return null;
    }

    public Components.Name? name {
        get {
            Component? component = this.get_component (typeof (Components.Name));
            return (Components.Name) component;
        }
    }

    public Components.Transform? transform {
        get {
            Component? component = this.get_component (typeof (Components.Transform));
            return (Components.Transform) component;
        }
    }

    public Components.Opacity? opacity {
        get {
            Component? component = this.get_component (typeof (Components.Opacity));
            return (Components.Opacity) component;
        }
    }

    public Components.Rotation? rotation {
        get {
            Component? component = this.get_component (typeof (Components.Rotation));
            return (Components.Rotation) component;
        }
    }

    public Components.Fills? fills {
        get {
            Component? component = this.get_component (typeof (Components.Fills));
            return (Components.Fills) component;
        }
    }

    public Components.Borders? borders {
        get {
            Component? component = this.get_component (typeof (Components.Borders));
            return (Components.Borders) component;
        }
    }

    public Components.Size? size {
        get {
            Component? component = this.get_component (typeof (Components.Size));
            return (Components.Size) component;
        }
    }

    public Components.Flipped? flipped {
        get {
            Component? component = this.get_component (typeof (Components.Flipped));
            return (Components.Flipped) component;
        }
    }

    public Components.BorderRadius? border_radius {
        get {
            Component? component = this.get_component (typeof (Components.BorderRadius));
            return (Components.BorderRadius) component;
        }
    }

    public Components.Layer? layer {
        get {
            Component? component = this.get_component (typeof (Components.Layer));
            return (Components.Layer) component;
        }
    }

    public void delete () {
        remove ();
    }
}