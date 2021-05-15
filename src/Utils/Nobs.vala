/**
 * Copyright (c) 2021 Alecaddd (http://alecaddd.com)
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

public class Akira.Utils.Nobs : Object {
    public const double ROTATION_LINE_HEIGHT = 40.0;

    /*
    Grabber Pos:
      8
      |
    0 1 2
    7   3
    6 5 4

    // -1 if no nob is grabbed.
    */
    public enum Nob {
        NONE=-1,
        TOP_LEFT,
        TOP_CENTER,
        TOP_RIGHT,
        RIGHT_CENTER,
        BOTTOM_RIGHT,
        BOTTOM_CENTER,
        BOTTOM_LEFT,
        LEFT_CENTER,
        ROTATE
    }

    public static bool is_top_nob (Nob nob) {
        return nob == Nob.TOP_LEFT || nob == Nob.TOP_CENTER || nob == Nob.TOP_RIGHT;
    }

    public static bool is_bot_nob (Nob nob) {
        return nob == Nob.BOTTOM_LEFT || nob == Nob.BOTTOM_CENTER || nob == Nob.BOTTOM_RIGHT;
    }

    public static bool is_left_nob (Nob nob) {
        return nob == Nob.TOP_LEFT || nob == Nob.LEFT_CENTER || nob == Nob.BOTTOM_LEFT;
    }

    public static bool is_right_nob (Nob nob) {
        return nob == Nob.TOP_RIGHT || nob == Nob.RIGHT_CENTER || nob == Nob.BOTTOM_RIGHT;
    }

    public static bool is_corner_nob (Nob nob) {
        return nob == Nob.TOP_RIGHT || nob == Nob.TOP_LEFT || nob == Nob.BOTTOM_RIGHT || nob == Nob.BOTTOM_LEFT;
    }

    public static bool is_horizontal_center (Nob nob) {
        return (nob == Utils.Nobs.Nob.RIGHT_CENTER || nob == Utils.Nobs.Nob.LEFT_CENTER);
    }

    public static bool is_vertical_center (Nob nob) {
        return (nob == Utils.Nobs.Nob.TOP_CENTER || nob == Utils.Nobs.Nob.BOTTOM_CENTER);
    }

    /*
     * Return a cursor type based of the type of nob.
     */
    public static Gdk.CursorType? cursor_from_nob (Nob nob_id) {
        Gdk.CursorType? result = null;
        switch (nob_id) {
            case Nob.NONE:
                result = null;
                break;
            case Nob.TOP_LEFT:
                result = Gdk.CursorType.TOP_LEFT_CORNER;
                break;
            case Nob.TOP_CENTER:
                result = Gdk.CursorType.TOP_SIDE;
                break;
            case Nob.TOP_RIGHT:
                result = Gdk.CursorType.TOP_RIGHT_CORNER;
                break;
            case Nob.RIGHT_CENTER:
                result = Gdk.CursorType.RIGHT_SIDE;
                break;
            case Nob.BOTTOM_RIGHT:
                result = Gdk.CursorType.BOTTOM_RIGHT_CORNER;
                break;
            case Nob.BOTTOM_CENTER:
                result = Gdk.CursorType.BOTTOM_SIDE;
                break;
            case Nob.BOTTOM_LEFT:
                result = Gdk.CursorType.BOTTOM_LEFT_CORNER;
                break;
            case Nob.LEFT_CENTER:
                result = Gdk.CursorType.LEFT_SIDE;
                break;
            case Nob.ROTATE:
                result = Gdk.CursorType.EXCHANGE;
                break;
        }

        return result;
    }


    public static void nob_xy_from_coordinates (
        Utils.Nobs.Nob nob,
        double tl_x,
        double tl_y,
        double tr_x,
        double tr_y,
        double bl_x,
        double bl_y,
        double br_x,
        double br_y,
        double scale,
        ref double x,
        ref double y
    ) {

        x = 0.0;
        y = 0.0;

        switch (nob) {
            case Utils.Nobs.Nob.TOP_LEFT:
                x = tl_x;
                y = tl_y;
                break;
            case Utils.Nobs.Nob.TOP_CENTER:
                x = (tl_x + tr_x) / 2.0;
                y = (tl_y + tr_y) / 2.0;
                break;
            case Utils.Nobs.Nob.TOP_RIGHT:
                x = tr_x;
                y = tr_y;
                break;
            case Utils.Nobs.Nob.RIGHT_CENTER:
                x = (tr_x + br_x) / 2.0;
                y = (tr_y + br_y) / 2.0;
                break;
            case Utils.Nobs.Nob.BOTTOM_RIGHT:
                x = br_x;
                y = br_y;
                break;
            case Utils.Nobs.Nob.BOTTOM_CENTER:
                x = (br_x + bl_x) / 2.0;
                y = (br_y + bl_y) / 2.0;
                break;
            case Utils.Nobs.Nob.BOTTOM_LEFT:
                x = bl_x;
                y = bl_y;
                break;
            case Utils.Nobs.Nob.LEFT_CENTER:
                x = (tl_x + bl_x) / 2.0;
                y = (tl_y + bl_y) / 2.0;
                break;
            case Utils.Nobs.Nob.ROTATE:
                var dx = tl_x - bl_x;
                var dy = tl_y - bl_y;
                Utils.GeometryMath.normalize (ref dx, ref dy);


                x = (tl_x + tr_x) / 2.0 + dx * ROTATION_LINE_HEIGHT / scale;
                y = (tl_y + tr_y) / 2.0 + dy * ROTATION_LINE_HEIGHT / scale;
                break;
        }
    }
}