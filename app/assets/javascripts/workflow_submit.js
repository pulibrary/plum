/* workflow_submit: enable workflow submit button only after an action input has been selected */
$(document).ready(function(){
    $('.workflow-comments input[type*="submit"]').attr('disabled', true);
    $('input[id*="workflow_action_name_"]').change(workflow_submit)
});

function workflow_submit() {
    $('.workflow-comments input[type*="submit"]').attr('disabled', false);
}
