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
 * Authored by: Giacomo "giacomoalbe" Alberini <giacomoalbe@gmail.com>
 */

public class Akira.ViewLayers.ViewLayerMultiSelect : ViewLayer {
    public Gdk.RGBA color { get; default = Gdk.RGBA () { red = 0.25, green = 0.79, blue = 0.98, alpha = 0.5 }; }

    private Drawables.Drawable? drawable = null;
    private Drawables.Drawable? old_drawable = null;
    private Geometry.Rectangle last_drawn_bb = Geometry.Rectangle.empty ();

    private double initial_press_x;
    private double initial_press_y;

    public ViewLayerMultiSelect () {}

    public void create_region (Gdk.EventButton event) {
        initial_press_x = event.x;
        initial_press_y = event.y;

        drawable = new Drawables.DrawableRect (event.x, event.y, 0, 0);
    }

    public void update_region (double width, double height) {
        var center_x = initial_press_x + width / 2;
        var center_y = initial_press_y + height / 2;

        drawable.center_x = center_x;
        drawable.center_y = center_y;
        drawable.width = width;
        drawable.height = height;

        old_drawable = drawable;

        drawable.bounds = Geometry.Rectangle.with_coordinates (
            initial_press_x,
            initial_press_y,
            initial_press_x + width,
            initial_press_y + height
        );

        update ();
    }

    public void remove_region () {
        update ();
        drawable = null;
    }

    public Geometry.Rectangle? get_region_bounds () {
        return drawable.bounds;
    }

    public override void draw_layer (Cairo.Context context, Geometry.Rectangle target_bounds, double scale) {
        if (canvas == null || drawable == null) {
            return;
        }

        drawable.fill_rgba = color;
        drawable.paint (context, target_bounds, scale);

        last_drawn_bb = drawable.bounds;
    }

    public override void update () {
        if (canvas == null) {
            return;
        }

        if (old_drawable != null) {
            canvas.request_redraw (last_drawn_bb);
        }

        if (drawable != null) {
            canvas.request_redraw (drawable.bounds);
        }
    }
}