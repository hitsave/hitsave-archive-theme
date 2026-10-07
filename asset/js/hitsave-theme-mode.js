(function () {
    'use strict';

    var STORAGE_KEY = 'hitsave-theme';

    function getDefaultTheme() {
        return document.documentElement.getAttribute('data-hitsave-theme-default') || 'dark';
    }

    function getStoredTheme() {
        try {
            var stored = localStorage.getItem(STORAGE_KEY);
            if (stored === 'dark' || stored === 'light') {
                return stored;
            }
        } catch (e) {
            return null;
        }
        return null;
    }

    function updateThemeToggleButton(theme) {
        var button = document.querySelector('[data-hitsave-theme-toggle]');
        if (!button) {
            return;
        }
        var wrap = button.closest('.hitsave-theme-toggle');
        var labelToLight = wrap && wrap.getAttribute('data-hitsave-label-to-light');
        var labelToDark = wrap && wrap.getAttribute('data-hitsave-label-to-dark');
        var icon = button.querySelector('.hitsave-theme-toggle__icon');
        if (theme === 'light') {
            button.setAttribute('aria-label', labelToDark || 'Switch to dark mode');
            if (icon) {
                icon.className = 'fas fa-moon hitsave-theme-toggle__icon';
            }
        } else {
            button.setAttribute('aria-label', labelToLight || 'Switch to light mode');
            if (icon) {
                icon.className = 'fas fa-sun hitsave-theme-toggle__icon';
            }
        }
    }

    function applyTheme(theme) {
        document.documentElement.setAttribute('data-hitsave-theme', theme);
        updateThemeToggleButton(theme);
    }

    function setTheme(theme, persist) {
        if (theme !== 'dark' && theme !== 'light') {
            return;
        }
        applyTheme(theme);
        if (persist) {
            try {
                localStorage.setItem(STORAGE_KEY, theme);
            } catch (e) {
                /* ignore */
            }
        }
    }

    function initTheme() {
        applyTheme(getStoredTheme() || getDefaultTheme());
    }

    function bindToggle() {
        var button = document.querySelector('[data-hitsave-theme-toggle]');
        if (!button) {
            return;
        }
        button.addEventListener('click', function () {
            var current = document.documentElement.getAttribute('data-hitsave-theme') === 'light'
                ? 'light'
                : 'dark';
            setTheme(current === 'light' ? 'dark' : 'light', true);
        });
    }

    initTheme();
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', bindToggle);
    } else {
        bindToggle();
    }
}());
