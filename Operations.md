Operations:
    On a Line
        update metadata?
            name?
            icon?
            just use name/icon of first step?
        add step
        delete step
        reorder step
    On a FixedStep
        update ComponentFlow?
            may break outgoing constraints
        update rate?
    On a RecipeStep
        update recipe
            may break incoming and/or outgoing constraints?
            only allow recipes that can maintain the same constraint?
            may select a new default Crafter from the CrafterPresetLibrary
        update Crafter
        add constraint
        remove constraint
    On a LineStep
        add constraint
        remove constraint
    On a CrafterPresetLibrary
        add Crafter
        update Crafter
            should update any steps using the current crafter
            should display in real time count of steps that can't use the modified Crafter
            when committed, should change any steps that were using the old crafter and can't use the new crafter to use a new default crafter
        reorder Crafter
        delete Crafter