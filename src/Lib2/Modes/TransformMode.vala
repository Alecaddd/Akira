/**
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
 * Authored by: Martin "mbfraga" Fraga <mbfraga@gmail.com>
 */

/*
 * TransformMode handles mouse-activated transformations. Static methods can
 * be used to apply the underlying code on top of other modes that may need to
 * use the functionality.
 */
public class Akira.Lib2.Modes.TransformMode : AbstractInteractionMode {
    private const double ROTATION_FIXED_STEP = 15.0;

    public unowned Lib2.ViewCanvas view_canvas { get; construct; }

    public Utils.Nobs.Nob nob = Utils.Nobs.Nob.NONE;

    public class DragItemData : Object {
        public Lib2.Components.Coordinates item_center;
        public Lib2.Components.Size item_size;
        public Lib2.Components.Rotation item_rotation;
        public Lib2.Components.CompiledGeometry item_geometry;
    }

    public class InitialDragState : Object {
        public double press_x;
        public double press_y;

        // initial_selection_data
        public Geometry.RotatedRectangle area;

        public Gee.ArrayList<DragItemData> items_data;

        construct {
            items_data = new Gee.ArrayList<DragItemData> ();
        }
    }

    public class TransformExtraContext : Object {
        public Lib2.Managers.SnapManager.SnapGuideData snap_guide_data;
    }

    private Lib2.Items.NodeSelection selection;
    private InitialDragState initial_drag_state;
    public TransformExtraContext transform_extra_context;


    public TransformMode (Akira.Lib2.ViewCanvas canvas, Utils.Nobs.Nob selected_nob) {
        Object (view_canvas: canvas);
        nob = selected_nob;
        initial_drag_state = new InitialDragState ();
    }

    construct {
        transform_extra_context = new TransformExtraContext ();
        transform_extra_context.snap_guide_data = new Lib2.Managers.SnapManager.SnapGuideData ();
    }

    public override void mode_begin () {
        if (view_canvas.selection_manager.selection.is_empty ()) {
            request_deregistration (mode_type ());
            return;
        }

        selection = view_canvas.selection_manager.selection;
        initial_drag_state.area = selection.coordinates ();

        foreach (var node in selection.nodes.values) {
            unowned var item = node.instance.item;
            var data = new DragItemData ();
            data.item_center = item.components.center.copy ();
            data.item_size = item.components.size.copy ();
            data.item_rotation = item.components.rotation.copy ();
            data.item_geometry = item.compiled_geometry.copy ();
            initial_drag_state.items_data.add (data);
        }
    }

    public override void mode_end () {
        transform_extra_context = null;
        view_canvas.window.event_bus.update_snap_decorators ();
    }

    public override AbstractInteractionMode.ModeType mode_type () { return AbstractInteractionMode.ModeType.RESIZE; }

    public override Gdk.CursorType? cursor_type () {
        return Utils.Nobs.cursor_from_nob (nob);
    }

    public override bool key_press_event (Gdk.EventKey event) {
        return true;
    }

    public override bool key_release_event (Gdk.EventKey event) {
        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        initial_drag_state.press_x = event.x;
        initial_drag_state.press_y = event.y;
        return true;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        request_deregistration (mode_type ());
        return true;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        switch (nob) {
            case Utils.Nobs.Nob.NONE:
                move_from_event (
                    view_canvas,
                    selection,
                    initial_drag_state,
                    event.x,
                    event.y,
                    ref transform_extra_context.snap_guide_data
                );
                break;
            case Utils.Nobs.Nob.ROTATE:
                rotate_from_event (
                    view_canvas,
                    selection,
                    initial_drag_state,
                    event.x,
                    event.y
                );
                break;
            default:
                scale_from_event (
                    view_canvas,
                    selection,
                    initial_drag_state,
                    nob,
                    event.x,
                    event.y
                );
                break;
        }

        return true;
    }

    public override Object? extra_context () {
        return transform_extra_context;
    }

    public static void move_from_event (
        ViewCanvas view_canvas,
        Lib2.Items.NodeSelection selection,
        InitialDragState initial_drag_state,
        double event_x,
        double event_y,
        ref Lib2.Managers.SnapManager.SnapGuideData guide_data
    ) {
        //ulong microseconds;
        //double seconds;
        //Timer timer = new Timer ();

        var blocker = new Lib2.Managers.SelectionManager.ChangeSignalBlocker (view_canvas.selection_manager);
        (void) blocker;

        var delta_x = event_x - initial_drag_state.press_x;
        var delta_y = event_y - initial_drag_state.press_y;

        double top = 0.0;
        double left = 0.0;
        double bottom = 0.0;
        double right = 0.0;
        initial_drag_state.area.top_bottom (ref top, ref bottom);
        initial_drag_state.area.left_right (ref left, ref right);

        Utils.AffineTransform.add_grid_snap_delta (top, left, ref delta_x, ref delta_y);

        int snap_offset_x = 0;
        int snap_offset_y = 0;

        if (settings.enable_snaps) {
            guide_data.type = Akira.Lib2.Managers.SnapManager.SnapGuideType.NONE;
            var sensitivity = Utils.Snapping2.adjusted_sensitivity (view_canvas.current_scale);
            var selection_area = Geometry.Rectangle () {
                    left = left + delta_x,
                    top = top + delta_y,
                    right = right + delta_x,
                    bottom = bottom + delta_y
            };

            var snap_grid = Utils.Snapping2.generate_best_snap_grid (
                view_canvas,
                selection,
                selection_area,
                sensitivity
            );

            if (!snap_grid.is_empty ()) {
                var matches = Utils.Snapping2.generate_snap_matches (
                    snap_grid,
                    selection,
                    selection_area,
                    sensitivity
                );


                if (matches.h_data.snap_found ()) {
                    snap_offset_x = matches.h_data.snap_offset ();
                    guide_data.type = Akira.Lib2.Managers.SnapManager.SnapGuideType.SELECTION;
                }

                if (matches.v_data.snap_found ()) {
                    snap_offset_y = matches.v_data.snap_offset ();
                    guide_data.type = Akira.Lib2.Managers.SnapManager.SnapGuideType.SELECTION;
                }
            }
        }

        var ct = 0;
        foreach (var node in selection.nodes.values) {
            unowned var item = node.instance.item;
            var item_drag_data = initial_drag_state.items_data[ct];
            var new_center_x = item_drag_data.item_center.x + delta_x + snap_offset_x;
            var new_center_y = item_drag_data.item_center.y + delta_y + snap_offset_y;
            item.components.center = new Lib2.Components.Coordinates (new_center_x, new_center_y);
            item.recompile_geometry (true);
            ++ct;
        }

        //timer.stop ();
        //seconds = timer.elapsed (out microseconds);
        //print ("Moved %u items in %s s\n", initial_drag_state.items_data.size, seconds.to_string ());
        view_canvas.window.event_bus.update_snap_decorators ();
    }

    public static void scale_from_event (
        ViewCanvas view_canvas,
        Lib2.Items.NodeSelection selection,
        InitialDragState initial_drag_state,
        Utils.Nobs.Nob nob,
        double event_x,
        double event_y
    ) {

        // TODO WIP
        var blocker = new Lib2.Managers.SelectionManager.ChangeSignalBlocker (view_canvas.selection_manager);
        (void) blocker;

        if (selection.nodes.size != 1) {
            return;
        }

        var local_top = initial_drag_state.area.tl_y;
        var local_left = initial_drag_state.area.tl_x;
        var local_bottom = initial_drag_state.area.br_y;
        var local_right = initial_drag_state.area.br_x;

        double grid_offset_x = 0.0;
        double grid_offset_y = 0.0;
        Utils.AffineTransform.add_grid_snap_delta (local_top, local_left, ref grid_offset_x, ref grid_offset_y);

        double rot_center_x = initial_drag_state.area.center_x;
        double rot_center_y = initial_drag_state.area.center_y;

        var itr = Cairo.Matrix.identity();
        itr.rotate (-initial_drag_state.area.rotation);

        Utils.GeometryMath.to_local_from_matrix (itr, rot_center_x, rot_center_y, ref local_left, ref local_top);
        Utils.GeometryMath.to_local_from_matrix (itr, rot_center_x, rot_center_y, ref local_right, ref local_bottom);
        var start_width = double.max(1.0, local_right - local_left);
        var start_height = double.max(1.0, local_bottom - local_top);

        double nob_x = 0.0;
        double nob_y = 0.0;

        Utils.Nobs.nob_xy_from_coordinates (
            nob,
            initial_drag_state.area,
            1.0,
            ref nob_x,
            ref nob_y
        );

        double local_ev_x = event_x;
        double local_ev_y = event_y;
        Utils.GeometryMath.to_local_from_matrix (itr, rot_center_x, rot_center_y, ref local_ev_x, ref local_ev_y);

        double local_nob_x = nob_x;
        double local_nob_y = nob_y;
        Utils.GeometryMath.to_local_from_matrix (itr, rot_center_x, rot_center_y, ref local_nob_x, ref local_nob_y);

        double inc_width = 0;
        double inc_height = 0;
        double inc_x = 0;
        double inc_y = 0;

        var tr = Cairo.Matrix.identity();
        tr.rotate (initial_drag_state.area.rotation);

        Utils.AffineTransform.calculate_size_adjustments2 (
            nob,
            start_width,
            start_height,
            local_ev_x - local_nob_x,
            local_ev_y - local_nob_y,
            start_width / start_height,
            false,
            view_canvas.shift_is_pressed,
            tr,
            ref inc_x,
            ref inc_y,
            ref inc_width,
            ref inc_height
        );

        double size_off_x = inc_width / 2.0;
        double size_off_y = inc_height / 2.0;
        tr.transform_distance (ref size_off_x, ref size_off_y);

        var ct = 0;
        foreach (var node in selection.nodes.values) {
            unowned var item = node.instance.item;
            var item_drag_data = initial_drag_state.items_data[ct];

            double new_center_x = item_drag_data.item_center.x + inc_x + size_off_x + grid_offset_x;
            double new_center_y = item_drag_data.item_center.y + inc_y + size_off_y + grid_offset_y;

            double new_width = item_drag_data.item_size.width + inc_width;
            double new_height = item_drag_data.item_size.height + inc_height;

            if (item_drag_data.item_rotation.has_normal_rotation ()) {
                new_width = Utils.AffineTransform.fix_size (new_width);
                new_height = Utils.AffineTransform.fix_size (new_height);

                var tmp_left = new_center_x - new_width / 2.0;
                var tmp_top = new_center_y - new_height / 2.0;

                new_center_x = Utils.AffineTransform.fix_size (tmp_left) + new_width / 2.0;
                new_center_y = Utils.AffineTransform.fix_size (tmp_top) + new_height / 2.0;
            }



            item.components.center = new Lib2.Components.Coordinates (new_center_x, new_center_y);
            item.components.size = new Lib2.Components.Size (new_width, new_height, false);
            item.recompile_geometry (true);

            ct++;
        }
    }


    public static void rotate_from_event (
        ViewCanvas view_canvas,
        Lib2.Items.NodeSelection selection,
        InitialDragState initial_drag_state,
        double event_x,
        double event_y
    ) {
        var blocker = new Lib2.Managers.SelectionManager.ChangeSignalBlocker (view_canvas.selection_manager);
        (void) blocker;

        double original_center_x = initial_drag_state.area.center_x;
        double original_center_y = initial_drag_state.area.center_y;

        var radians = GLib.Math.atan2 (
            event_x - original_center_x,
            original_center_y - event_y
        );

        var new_rotation = radians * (180 / Math.PI);

        if (view_canvas.ctrl_is_pressed) {
            var step_num = GLib.Math.round (new_rotation / 15.0);
            new_rotation = 15.0 * step_num;
        }

        var single_item = selection.nodes.size == 1;

        var ct = 0;
        foreach (var node in selection.nodes.values) {
            unowned var item = node.instance.item;
            if (single_item) {
                new_rotation = GLib.Math.fmod (new_rotation + 360, 360);
                item.components.rotation = new Lib2.Components.Rotation (new_rotation);
                item.recompile_geometry (true);
                return;
            }

            var item_drag_data = initial_drag_state.items_data[ct];
            var old_center_x = item_drag_data.item_center.x;
            var old_center_y = item_drag_data.item_center.y;

            var tmp_rotation = new_rotation;
            var item_rotation = item_drag_data.item_rotation.in_degrees ();

            if (old_center_x != original_center_x || old_center_y != original_center_y) {
                var tr = Cairo.Matrix.identity ();
                tr.rotate (tmp_rotation * Math.PI / 180);
                var new_center_delta_x = old_center_x - original_center_x;
                var new_center_delta_y = old_center_y - original_center_y;
                tr.transform_point (ref new_center_delta_x, ref new_center_delta_y);

                item.components.center = new Lib2.Components.Coordinates (
                    original_center_x + new_center_delta_x,
                    original_center_y + new_center_delta_y
                );
            }

            tmp_rotation = GLib.Math.fmod (item_rotation + tmp_rotation + 360, 360);
            item.components.rotation = new Lib2.Components.Rotation (tmp_rotation);

            item.recompile_geometry (true);
            ct++;
        }
    }
}