    Planner := {
        lines: {[line_id]: Line}
    }
    Line := {
        id: number
        name: string
        steps: {Step}
        flows(): ComponentFlowSet
        crafters(): RecipeCrafterSet
    }
    Step := {
        type: "recipe" | "fixed" | "line"
        ...
        rate(): number
        flows(): ComponentFlowSet
        crafters(): RecipeCrafterSet
    }
    Constraint := {
        step_id: int
        component: Component
    }
    Component := {
        type: "item" | "fluid"
        name: string
    }
    ComponentFlow := {
        component: Component
        rate: number
    }
    ComponentFlowSet := {
        [type] = { [name] = number }
        __plus(ComponentFlows): ComponentFlows
    }
    RecipeStep := {
        recipe: string
        constraints: {Constraint}
    }
    FixedStep := {
        flow: ComponentFlow
    }
    LineStep := {
        line_id: int
        constraints: {Constraint}
    }

    RecipeCrafter := {
        recipe_name: string,
        crafter_id: number,
    }
    RecipeCrafterSet := {
        crafters: {crafter: RecipeCrafter, count: number}
        __plus(RecipeCrafterSet): RecipeCrafterSet
        power(): Power
    }

    Crafter := {
        id: number,
        abbreviation: string,
        entity_name: string,
        modules: ModuleSet,
        beacons: BeaconSet,
        drain: Power,
        power: Power,
    }
    BeaconSet := {
        entity_name: string,
        count: number,
        modules: ModuleSet,
    }
    ModuleSet := {
        modules: {
            {
                module_name: string,
                count: number,
            }
        }
    }

    Power := number

Possible future refinement to optimize GUI update:

    PlannerDiff := {
        ops: {Operation}
    }
    Operation := {
        type: OperationType
    }
    OperationType :=
        "add_step"
        | "update_step"
        | "delete_step"
        | "create_line"
        | "update_line"
        | "delete_line"