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

public class Akira.Lib2.Items.ModelType : Object {
    public virtual Components.CompiledFill compile_fill (
        Components.Components? components,
        Lib2.Items.ModelNode? node
    ) { 
        return Components.CompiledFill.compile (components, node);
    }

    public virtual Components.CompiledBorder compile_border (
        Components.Components? components,
        Lib2.Items.ModelNode? node
    ) {
        return Components.CompiledBorder.compile (components, node);
    }

    public virtual Components.CompiledGeometry compile_geometry (
        Components.Components? components,
        Lib2.Items.ModelNode? node
    ) {
        return new Components.CompiledGeometry.from_components (components, node);
    }

    public virtual void construct_canvas_item (ModelInstance item, Goo.Canvas canvas) {}

    public virtual void component_updated (ModelInstance item, Lib2.Components.Component.Type type) {}

    public virtual void apply_scale_transform (
        Lib2.Items.Model item_model,
        Lib2.Items.ModelNode node,
        Lib2.Modes.TransformMode.InitialDragState initial_drag_state,
        Cairo.Matrix inverse_reference_matrix,
        double global_offset_x,
        double global_offset_y,
        double reference_sx,
        double reference_sy
    ) {
        Utils.AffineTransform.scale_node (
            item_model, 
            node, 
            initial_drag_state, 
            inverse_reference_matrix, 
            global_offset_x, 
            global_offset_y, 
            reference_sx, 
            reference_sy
        );
    }

    public virtual bool is_group () { return false; }
}

public class Akira.Lib2.Items.DummyItemType : ModelType {}

public class Akira.Lib2.Items.DummyGroupType : ModelType {
    public override bool is_group () { return true; }
}
