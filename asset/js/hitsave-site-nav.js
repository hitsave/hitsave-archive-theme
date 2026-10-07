(function ($) {
    'use strict';

    function initHitSaveNav() {
        var $chrome = $('.hitsave-site-chrome');
        if (!$chrome.length) {
            return;
        }

        var $dropdown = $chrome.find('.hitsave-nav-dropdown');
        var $toggle = $chrome.find('.hitsave-menu-toggle .menu-toggle');
        var $panel = $('#hitsave-nav-panel');
        if (!$toggle.length || !$panel.length || !$dropdown.length) {
            return;
        }

        function closeNav() {
            $chrome.removeClass('hitsave-nav-open');
            $dropdown.removeClass('hitsave-nav-open');
            $('body').removeClass('hitsave-nav-open');
            $toggle.attr('aria-expanded', 'false');
            $panel.attr('aria-hidden', 'true');
        }

        function openNav() {
            $chrome.addClass('hitsave-nav-open');
            $dropdown.addClass('hitsave-nav-open');
            $('body').addClass('hitsave-nav-open');
            $toggle.attr('aria-expanded', 'true');
            $panel.attr('aria-hidden', 'false');
        }

        function isOpen() {
            return $dropdown.hasClass('hitsave-nav-open');
        }

        $toggle.attr('aria-controls', 'hitsave-nav-panel');
        $toggle.attr('aria-expanded', 'false');

        $toggle.on('click', function (event) {
            event.preventDefault();
            event.stopPropagation();
            if (isOpen()) {
                closeNav();
            } else {
                openNav();
            }
        });

        $panel.on('click', function (event) {
            event.stopPropagation();
        });

        $panel.on('click', 'a', function () {
            closeNav();
        });

        $(document).on('keydown', function (event) {
            if (event.key === 'Escape' && isOpen()) {
                closeNav();
                $toggle.trigger('focus');
            }
        });

        $(document).on('click', function () {
            if (isOpen()) {
                closeNav();
            }
        });
    }

    $(initHitSaveNav);
}(jQuery));
