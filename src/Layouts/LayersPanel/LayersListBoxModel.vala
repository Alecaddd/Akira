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
 * The model holding the layers panel rows.
 */
public class Layouts.LayersPanel.LayersListBoxModel : VirtualListBoxModel {
    public delegate bool RowVisibilityFunc (GLib.Object row);

    private GLib.Sequence<Akira.Lib.Items.ModelInstance> data = new GLib.Sequence<Akira.Lib.Items.ModelInstance> ();
    private uint last_position = uint.MAX;
    private GLib.SequenceIter<Akira.Lib.Items.ModelInstance>? last_iter;
    private unowned GLib.CompareDataFunc<Akira.Lib.Items.ModelInstance> compare_func;
    private unowned RowVisibilityFunc filter_func;

    public override uint get_n_items () {
        return data.get_length ();
    }

    public override GLib.Object? get_item (uint index) {
        return get_item_internal (index);
    }

    public override GLib.Object? get_item_unfiltered (uint index) {
        return get_item_internal (index, true);
    }

    private GLib.Object? get_item_internal (uint index, bool unfiltered = false) {
        GLib.SequenceIter<Akira.Lib.Items.ModelInstance>? iter = null;

        if (last_position != uint.MAX) {
            if (last_position == index + 1) {
                iter = last_iter.prev ();
            } else if (last_position == index - 1) {
                iter = last_iter.next ();
            } else if (last_position == index) {
                iter = last_iter;
            }
        }

        if (iter == null) {
            iter = data.get_iter_at_pos ((int)index);
        }

        last_iter = iter;
        last_position = index;

        if (iter.is_end ()) {
            return null;
        }

        if (filter_func == null) {
            return iter.get ();
        } else if (filter_func (iter.get ())) {
            return iter.get ();
        } else if (unfiltered) {
            return iter.get ();
        } else {
            return null;
        }
    }

    public void add (Akira.Lib.Items.ModelInstance data) {
        if (compare_func != null) {
            this.data.insert_sorted (data, compare_func);
        } else {
            this.data.append (data);
        }

        last_iter = null;
        last_position = uint.MAX;
    }

    public void remove (Akira.Lib.Items.ModelInstance data) {
        var iter = this.data.get_iter_at_pos (get_index_of_unfiltered (data));
        iter.remove ();

        last_iter = null;
        last_position = uint.MAX;
    }

    public void remove_all () {
        data.get_begin_iter ().remove_range (data.get_end_iter ());
        unselect_all ();

        last_iter = null;
        last_position = uint.MAX;
    }

    public void set_sort_func (GLib.CompareDataFunc<Akira.Lib.Items.ModelInstance> function) {
        this.compare_func = function;
    }

    public void set_filter_func (RowVisibilityFunc? function) {
        filter_func = function;
    }
}
