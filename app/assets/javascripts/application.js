// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/sortable
//= require jquery-ui/selectable
//= require jquery-ui/slider
//= require jquery-ui/datepicker
//= require jqueryui-timepicker-addon
// Required by Blacklight
//= require blacklight/blacklight
//= require browse_everything
//= require nestedSortable/jquery.mjs.nestedSortable
//= require bootstrap-select
//= require openseadragon

//= require hyrax
//= require_tree .

//= require modernizr
//= require jquery.iiifOsdViewer

Blacklight.onLoad(function() {
  Initializer = require('plum_boot')
  window.plum = new Initializer()
})
$(document).ready(function(){
  Blacklight.activate()
})
