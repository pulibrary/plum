/* mutex: only one form element with the class 'mutex' may be used at a time.
   all others will be disabled until it is blank. */
$(document).ready(function(){
    $(".mutex").change(mutex);
});

function mutex() {
    var $me = $(this);
    var $other = $('.mutex').not($me);
    if ( $me.val() != '' ) {
        $other.attr('disabled', 1);
    } else {
        $other.removeAttr('disabled');
    }
}
