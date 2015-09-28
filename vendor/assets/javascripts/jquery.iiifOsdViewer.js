(function($) {

  $.fn.iiifOsdViewer = function(options) {

    var iovViews = { },
        config;

    config = $.extend({
      availableViews: ['list', 'gallery', 'horizontal'],
      listView: {
        thumbsWidth: 75
      },
      galleryView: {
        thumbsHeight: 100
      },
      header: {
        height: 30
      }
    }, options);

    iovViews = {
      list: listView,
      gallery: galleryView,
      horizontal: horizontalView
    };

    return this.each(function() {

      var $parent = $(this),
          $viewer = $('<div>').addClass('iov'),
          $viewer, $menuBar, $menuControls, $selectViews, $views,
          views = {},
          osd;

      $viewer = $([
        '<div class="iov">',
          '<div class="iov-header">',
            '<div class="iov-menu-bar">',
              '<h2 class="iov-item-count"></h2>',
            '</div>',
          '</div>',
        '</div>'
      ].join(''));

      $views = $viewer.find('.iov-views');
      $header = $viewer.find('.iov-header');
      $menuBar = $viewer.find('.iov-menu-bar');

      $menuControls = $([
        '<div class="iov-controls">',
          '<a href="javascript:;" class="fa fa-expand iov-full-screen"></a>',
        '</div>',
      ].join(''));

      $selectViews = $('<select class="iov-view-options"></select>');

      $viewer.height('100%');
      init();


      function init() {
        config.defaultView = config.defaultView || config.availableViews[0];
        config.totalImages = 0;
        config.currentView = config.defaultView;
        config.viewHeight = $parent.height() - config.header.height;

        $.each(config.data, function(index, collection) {
          config.totalImages += collection.images.length || 0;
        });

        $.subscribe('iov-jump-to-list-view', jumpTo('list'));

        addMenuBar();
        attachEvents();
        $parent.append($viewer);
        initializeViews();
        views[config.currentView].load();
        $selectViews.val(config.currentView);
      }

      function addMenuBar() {
        if (config.totalImages > 1) {
          $menuBar.append($selectViews);

          $.each(config.availableViews, function(index, view) {
            if (typeof iovViews[view] === 'function') {
              $selectViews.append('<option value="' + view + '">' + view + ' view</option>');
            } else {
              config.availableViews.splice(index, 1);
            }
          });
        } else {
          config.availableViews = ['list'];
        }

        $menuBar.prepend($menuControls);
      }

      function initializeViews() {
        $.each(config.availableViews, function(index, view) {
          views[view] = iovViews[view]($viewer, config);

          $viewer.append(views[view].html());
          views[view].hide();
        });
      }

      function jumpTo(view) {
        return function(_, hashCode) {
          hideAllViews();

          views[view].show();
          views[view].jumpToImg(hashCode);
          $selectViews.val(view);
          config.currentView = view;
        }
      }

      function attachEvents() {
        $menuBar.find('.iov-full-screen').on('click', function() {
          fullscreenElement() ? exitFullscreen() : launchFullscreen($viewer[0]);
        });

        $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenChange', function() {
          var $fullscreen = $(fullscreenElement()),
              $ctrlFullScreen = $menuBar.find('.iov-full-screen');

          if ($fullscreen.length && $fullscreen.hasClass('iov')) {
            $ctrlFullScreen.removeClass('fa-expand').addClass('fa-compress');
          } else {
            $ctrlFullScreen.removeClass('fa-compress').addClass('fa-expand');
          }

          $.each(config.availableViews, function(index, view) {
            views[view].resize();
          });

        });

        $selectViews.on('change', function() {
          config.currentView = $(this).val();

          hideAllViews();
          views[config.currentView].load();
        });
      }

      function hideAllViews() {
        $.each(config.availableViews, function(index, view) {
          views[view].hide();
        });
      }

      function launchFullscreen(el) {
        if (el.requestFullscreen) {
          el.requestFullscreen();
        } else if (el.mozRequestFullScreen) {
          el.mozRequestFullScreen();
        } else if (el.webkitRequestFullscreen) {
          el.webkitRequestFullscreen();
        } else if (el.msRequestFullscreen) {
          el.msRequestFullscreen();
        }

      }

      function exitFullscreen() {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        } else if (document.mozCancelFullScreen) {
          document.mozCancelFullScreen();
        } else if (document.webkitExitFullscreen) {
          document.webkitExitFullscreen();
        }
      }


    });

    function isFullscreen() {
      var $fullscreen = $(fullscreenElement());
      return ($fullscreen.length > 0);
    }

    function fullscreenElement() {
      return (document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement);
    }

    function hashCode(str) {
      return str.split("").reduce(function(a,b) { a = ((a << 5) - a) + b.charCodeAt(0); return a & a}, 0);
    }

    function getIiifImageUrl(server, id, width, height) {
      width = width || '';
      height = height || '';
      return [server, id, 'full/' + width + ',' + height, '0/default.jpg'].join('/');
    }

    function setViewHeight($view) {
      $view.height(isFullscreen() ? '100%' : config.viewHeight);
    }

    function lazyLoadThumbsVerticalList($list, viewportHeight) {
      var listPositionTop = $list.position().top;

      $list.find('li').each(function() {
        var $item = $(this),
            $img = $item.find('a img').first(),
            top = $item.position().top + listPositionTop;
            position = top + $img.height();

        if (position > 0 && top < viewportHeight) {
          $img.prop('src', $img.data('iov-img-url'));
        }
      });
    }

    function lazyLoadThumbsHorizontalList($list, viewportWidth) {
      $list.find('li').each(function() {
        var $item = $(this),
            $img = $item.find('a img').first(),
            left = $item.position().left,
            position = left + $img.width();

        if (position > 0 && left < viewportWidth) {
          $img.prop('src', $img.data('iov-img-url'));
        }
      });
    }


    // View modules


    // ------------------------------------------------------------------------
    // Module : List view

    function listView($viewer, config, options) {
      var osd,
          $listView,
          $listViewControls,
          $listViewOsd,
          $thumbsViewport,
          $thumbsList;

      $listViewOsd = $('<div class="iov-list-view-osd" id="iov-list-view-osd"></div>');
      $thumbsViewport = $('<div class="iov-list-view-thumbs-viewport"></div>');
      $thumbsList = $('<ul class="iov-list-view-thumbs"></ul>');
      $leftNav  = $('<a class="iov-list-view-left-nav fa fa-caret-left" href="javascript:;"><span class="iov-sr-only">Previous image</span></a>');
      $rightNav = $('<a class="iov-list-view-right-nav fa fa-caret-right" href="javascript:;"><span class="iov-sr-only">Next image</span></a>');


      $listView = $('<div class="iov-list-view"></div>');

      function render() {
        $listViewControls = $([
          '<div class="iov-list-view-controls">',
            '<a href="javascript:;" class="fa fa-plus-circle" id="iov-list-zoom-in"></a>',
            '<a href="javascript:;" class="fa fa-minus-circle" id="iov-list-zoom-out"></a>',
            '<a href="javascript:;" class="fa fa-repeat" id="iov-list-home"></a>',
          '</div>'
        ].join(''));

        setViewHeight($listView);
        $listView.append($listViewOsd);
        $listView.prepend($listViewControls);

        loadListViewThumbs();
        addImageNavBehavior();

        $thumbsViewport.scrollStop(function() {
          lazyLoadThumbsVerticalList($thumbsList, $listView.height());
        });
      }

      function loadListViewThumbs() {
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var imgUrl = getIiifImageUrl(collection.iiifServer, image.id, config.listView.thumbsWidth, null),
                infoUrl = getIiifInfoUrl(collection.iiifServer, image.id),
                $imgItem = $('<li data-alt="' + image.label + '">'),
                $img = $('<img>'),
                imgHeight = Math.round((image.height / image.width) * config.listView.thumbsWidth);

            $imgItem
              .addClass('iov-list-view-id-' + hashCode(image.id))
              .data({
                'iov-list-view-id': hashCode(image.id),
                'image-id': image.id,
                'iov-height': image.height,
                'iov-width': image.width,
                'iov-label': image.label,
                'iov-stanford-only': image.stanford_only,
                'iov-tooltip-text': image.tooltip_text,
                'iiif-info-url': infoUrl
              });

            $img
              .prop('alt', image.label)
              .height(imgHeight)
              .data('iov-img-url', imgUrl);

            // when an image load errors (i.e. WebAuth challenge)
            $img.on('error', function(){
              if ($("li", $thumbsList).index($imgItem) == 0) {
                $leftNav.hide();
                $rightNav.hide();
                $listViewControls.hide();
                $thumbsViewport.hide();
                $('.iov-menu-bar').hide();
                $listViewOsd
                  .removeClass('iov-list-view-osd')
                  .css('text-align', 'center')
                  .html('<img src="' + getThumbUrl(collection.iiifServer, image.id) + '" />')
              }
            });

            $imgItem.append($('<a href="javascript:;"></a>').append($img));
            $thumbsList.append($imgItem);

            $imgItem.on('click', function() {
              var $self = $(this);

              $self.addClass('iov-list-view-thumb-selected');
              $self.siblings().removeClass('iov-list-view-thumb-selected');
              updateView($self);

              $.publish('iov-list-view-load', $imgItem.data('iov-list-view-id'));
            });
          });
        });

        $listView.prepend($thumbsViewport.append($thumbsList));

        if (config.totalImages == 1) {
          $listViewOsd.addClass('iov-remove-margin');
          $thumbsViewport.hide();
        }
      }

      function getThumbUrl(serverUrl, imageId) {
        return [serverUrl.replace('/iiif', ''), imageId.replace('%252F', '/')].join('/') + '_thumb'
      }

      function addImageNavBehavior(){
        if (config.totalImages > 1) {
          $viewer.find('.iov-menu-bar').after($rightNav).after($leftNav);

          $.each([$leftNav, $rightNav], function() {

            $(this).on('click', function() {
              var thumbsList = $('.iov-list-view-thumbs li'),
                  activeThumb = $thumbsList.find('.iov-list-view-thumb-selected'),
                  nextThumb;

              if ($(this).is($rightNav)) {
                nextThumb = activeThumb.next('li');
                if (nextThumb.length <= 0) nextThumb = thumbsList.first();
              } else {
                nextThumb = activeThumb.prev('li');
                if (nextThumb.length <= 0) nextThumb = thumbsList.last();
              }

              nextThumb.addClass('iov-list-view-thumb-selected');
              activeThumb.removeClass('iov-list-view-thumb-selected');
              updateView(nextThumb);

              $.publish('iov-list-view-load', nextThumb.data('iov-list-view-id'));
            });
          });
        }
      }

      function updateView($imgItem) {
        loadOsdInstance($imgItem.data('iiif-info-url'));
        $rightNav.show();
        $leftNav.show();
        scrollThumbsViewport($imgItem);
      }

      function loadOsdInstance(infoUrl) {
        if (typeof osd !== 'undefined') {
          osd.open(infoUrl);
        } else {
          osd = OpenSeadragon({
            id:             'iov-list-view-osd',
            tileSources:    infoUrl,
            zoomInButton:   'iov-list-zoom-in',
            zoomOutButton:  'iov-list-zoom-out',
            homeButton:     'iov-list-home',
            showFullPageControl: false
          });
        }
      }

      function scrollThumbsViewport($imgItem) {
        var scrollTo = 0,
            top = $imgItem.position().top;

        if (typeof top !== 'undefined') {
          scrollTo = top - Math.round($thumbsViewport.height()/2) + Math.round($imgItem.height()/2) - 10; // 10 = padding

          $thumbsViewport.animate({
            scrollTop: scrollTo
          }, 250);
        }
      }

      function jumpToImg(hashCode) {
        var $imgItem = $thumbsList.find('.iov-list-view-id-' + hashCode);

        if ($imgItem.length) {
          $imgItem.click();
        }
      }

      function getIiifInfoUrl(server, id) {
        return [server, id, 'info.json'].join('/');
      }

      return {
        html: function() {
          render();
          return $listView;
        },

        hide: function() {
          $listViewControls.hide();
          $listView.hide();
        },

        show: function() {
          $listViewControls.show();
          $listView.show();
        },

        load: function() {
          $listViewControls.show();
          $listView.show();
          $thumbsList.find('li[data-iov-list-view-id!=""]')[0].click();
          $thumbsViewport.trigger('scroll');
          $leftNav.show();
          $rightNav.show();
        },

        jumpToImg: function(hashCode) {
          jumpToImg(hashCode);
        },

        resize: function() {
          setViewHeight($listView);
          $thumbsViewport.trigger('scroll');
        }
      };
    };

    // ------------------------------------------------------------------------
    // Module : Gallery view

    function galleryView($viewer, config, options) {
      var $galleryView,
          $thumbsList;

      $galleryView = $('<div class="iov-gallery-view"></div>');
      $thumbsList = $('<ul class="iov-gallery-view-thumbs"></ul>');

      function render() {
        setViewHeight($galleryView);
        loadGalleryViewThumbs();
      }

      function loadGalleryViewThumbs() {
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var imgWidth = Math.round((image.width / image.height) * config.galleryView.thumbsHeight);
                imgUrl = getIiifImageUrl(collection.iiifServer, image.id, imgWidth, config.galleryView.thumbsHeight),
                $img = $('<img>'),
                $imgItem = $('<li data-alt="' + image.label + '">');

            $imgItem.data('iov-gallery-view-id', hashCode(image.id));

            $img
              .prop('alt', image.label)
              .width(imgWidth)
              .height(config.galleryView.thumbsHeight)
              .data('iov-img-url', imgUrl);

            $imgItem.append($('<a href="javascript:;"></a>').append($img));
            $thumbsList.append($imgItem);

            if ($.inArray('list', config.availableViews) !== -1) {
              $imgItem.on('click', function() {
                $.publish('iov-jump-to-list-view', $(this).data('iov-gallery-view-id'));
              });
            }
          });
        });

        $galleryView.prepend($thumbsList);

        $galleryView.scrollStop(function() {
          lazyLoadThumbsVerticalList($thumbsList, $galleryView.height());
        });
      }

      return {
        html: function() {
          render();
          return $galleryView;
        },

        hide: function() {
          $galleryView.hide();
        },

        show: function() {
          $galleryView.show();
        },

        load: function() {
          $.publish('iov-gallery-view-load');
          $galleryView.show();
          $galleryView.trigger('scroll');
          $leftNav.hide();
          $rightNav.hide();
        },

        resize: function() {
          setViewHeight($galleryView);
          $galleryView.trigger('scroll');
        }
      };
    }

    // ------------------------------------------------------------------------
    // Module : Scroll view

    function horizontalView($viewer, config, options) {
      var $horizontalView,
          $imgsList;

      $horizontalView = $('<div class="iov-horizontal-view"></div>');
      $viewport = $('<div class="iov-horizontal-view-viewport"></div>');
      $imgsList = $('<ul class="iov-horizontal-view-images"></ul>');

      function render() {
        setViewHeight($horizontalView);
        loadHorizontalImageStubs();
      }

      function loadHorizontalImageStubs() {
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var $imgItem = $('<li data-alt="' + image.label + '">');

            $imgItem
              .data('iov-horizontal-view-id', hashCode(image.id))
              .data('iov-height', image.height)
              .data('iov-width', image.width)
              .data('iov-iiif-server', collection.iiifServer)
              .data('iov-iiif-image-id', image.id);

            $imgsList.append($imgItem.append('<a href="javascript:;"><img alt="' + image.label + '" src=""></a>'));

            if ($.inArray('list', config.availableViews) !== -1) {
              $imgItem.on('click', function() {
                $.publish('iov-jump-to-list-view', $(this).data('iov-horizontal-view-id'));
              });
            }

          });
        });

        $horizontalView.append($viewport.append($imgsList));
      }

      function loadHorizontalViewImages() {
        var height,
            imgsListWidth = 0,
            minImgWidth = 100, // to accomodate labels for vertically thin images
            imgsList = $imgsList.find('li[data-horizontal-view-id!=""]'),
            offset = 30; // 20 = horizontal scrollbar, 10 = label height

        $viewport.detach();

        height = $horizontalView.height() - offset;

        if (isFullscreen()) height -= config.header.height;

        $.each(imgsList, function(index, imgItem) {
          var $imgItem = $(imgItem),
              iiifServer = $imgItem.data('iov-iiif-server'),
              id = $imgItem.data('iov-iiif-image-id'),
              $img = $imgItem.find('img'),
              imgWidth =  Math.round(($imgItem.data('iov-width') * height) / $imgItem.data('iov-height')),
              imgUrl = getIiifImageUrl(iiifServer, id, imgWidth, height);

          $img
            .height(height)
            .width(imgWidth)
            .data('iov-img-url', imgUrl);

          imgsListWidth += Math.max(imgWidth, minImgWidth) + 10;
        });

        $imgsList.width(imgsListWidth);
        $horizontalView.append($viewport);

        $viewport.scrollStop(function() {
          lazyLoadThumbsHorizontalList($imgsList, $viewport.width());
        });
      }

      return {
        html: function() {
          render();
          return $horizontalView;
        },

        hide: function() {
          $horizontalView.hide();
        },

        show: function() {
          $horizontalView.show();
          loadHorizontalViewImages();
        },

        load: function() {
          $.publish('iov-horizontal-view-load');
          $horizontalView.show();
          loadHorizontalViewImages();
          $viewport.trigger('scroll');
          $leftNav.hide();
          $rightNav.hide();
        },

        resize: function() {
          setViewHeight($horizontalView);
          loadHorizontalViewImages();
        }
      };
    }
  };

})( jQuery );

/*
 * jQuery Tiny Pub/Sub
 * https://github.com/cowboy/jquery-tiny-pubsub
 *
 * Copyright (c) 2013 "Cowboy" Ben Alman
 * Licensed under the MIT license.
 */
(function($) {
  var o = $({});

  $.subscribe = function() {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };

  $.publish = function() {
    o.trigger.apply(o, arguments);
  };
}(jQuery));

// source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
(function($) {
  $.fn.scrollStop = function(callback) {
    $(this).scroll(function() {
      var self  = this,
      $this = $(self);

      if ($this.data('scrollTimeout')) {
        clearTimeout($this.data('scrollTimeout'));
      }

      $this.data('scrollTimeout', setTimeout(callback, 250, self));
    });
  };
}(jQuery));
