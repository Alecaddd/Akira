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
 * The scrollable borders panel.
 */
public class Akira.Layouts.BordersList.BorderListBox : VirtualizingListBox {
    public unowned Lib.ViewCanvas view_canvas { get; construct; }

    private Gee.HashMap<int, BorderItemModel> borders;
    private BorderListStore list_store;

    public BorderListBox (Lib.ViewCanvas canvas) {
        Object (
            view_canvas: canvas
        );

        selection_mode = Gtk.SelectionMode.SINGLE;
        borders = new Gee.HashMap<int, BorderItemModel> ();
        list_store = new BorderListStore ();
        // list_store.set_sort_func (borders_sort_function);

        model = list_store;

        // Factory function to reuse the already generated row UI element when
        // a new border is created or the borders list scrolls to reveal borders
        // outside of the viewport.
        factory_func = (item, old_widget) => {
            BorderListItem? row = null;
            if (old_widget != null) {
                row = old_widget as BorderListItem;
            } else {
                row = new BorderListItem (view_canvas);
            }

            row.assign ((BorderItemModel) item);
            row.show_all ();

            return row;
        };

        // Listen to the button release event only for the secondary click in
        // order to trigger the context menu.
        button_release_event.connect (e => {
            if (e.button != Gdk.BUTTON_SECONDARY) {
                return Gdk.EVENT_PROPAGATE;
            }
            var row = get_row_at_y ((int)e.y);
            if (row == null) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (selected_row_widget != row) {
                select_row (row);
            }
            return create_context_menu (e, (BorderListItem)row);
        });

        // Trigger the context menu when the `menu` key is pressed.
        key_release_event.connect ((e) => {
            if (e.keyval != Gdk.Key.Menu) {
                return Gdk.EVENT_PROPAGATE;
            }
            var row = selected_row_widget;
            return create_context_menu (e, (BorderListItem)row);
        });
    }

    public void refresh_list () {
        if (borders.size > 0) {
            var removed = borders.size;
            borders.clear ();
            list_store.remove_all ();
            list_store.items_changed (0, removed, 0);
        }

        unowned var sm = view_canvas.selection_manager;
        if (sm.count () == 0) {
            return;
        }

        var added = 0;
        foreach (var selected in sm.selection.nodes.values) {
            var node = selected.node;
            if (node.instance.components.borders == null) {
                continue;
            }
            foreach (var border in node.instance.components.borders.data) {
                var item = new BorderItemModel (view_canvas, node, border.id);
                borders[node.id] = item;
                list_store.add (item);
                added++;
            }
        }

        list_store.items_changed (0, 0, added);
    }

    private bool create_context_menu (Gdk.Event e, BorderListItem row) {
        var menu = new Gtk.Menu ();
        menu.show_all ();

        if (e.type == Gdk.EventType.BUTTON_RELEASE) {
            menu.popup_at_pointer (e);
            return Gdk.EVENT_STOP;
        } else if (e.type == Gdk.EventType.KEY_RELEASE) {
            menu.popup_at_widget (row, Gdk.Gravity.EAST, Gdk.Gravity.CENTER, e);
            return Gdk.EVENT_STOP;
        }

        return Gdk.EVENT_PROPAGATE;
    }
}