/* detect-duplicates: check to see if source metadata identifier has already been used */
$(document).ready(function(){
    $('.detect_duplicates').change(detect_duplicates);
});

function detect_duplicates() {
  var $me = $(this);
  if ( $me.val() != '' ) {
    var url = '/catalog?f[source_metadata_identifier_ssim][]=' + $me.val();
    $.ajax({ url: url + '&format=json' })
    .done(function(data) {
      if ( data.docs.length > 0 ) {
        $me.parent().append('<div id="duplicates" class="alert alert-warning">This ID is already in use: <a href="' + url + '">view records using this Source Metadata ID</a>.  Please consider using the Portion Note field to help differentiate between objects with the same metadata.</div>');
      } else {
        $('#duplicates').remove();
      }
    });
  }
}
