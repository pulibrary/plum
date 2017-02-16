/* mutex: only one form element with the class 'mutex' may be used at a time.
   all others will be disabled until it is blank. */
$(document).ready(function(){
    $(".mutex").change(mutex);
    $(".mutex").attr("required", null)
});

function mutex() {
    var $me = $(this);
    var $other = $('.mutex').not($me);
    if ( $me.val() != '' ) {
        $other.attr('disabled', 1);
        $("#mutex_field").val($me.val())
        $("#mutex_field").change()
    } else {
        $other.removeAttr('disabled');
        $("#mutex_field").val($other.val())
        $("#mutex_field").change()
    }
}
