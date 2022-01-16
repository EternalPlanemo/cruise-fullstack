const mix = require('laravel-mix');

mix.copy('source/ui/main.js', 'public')
    .css('source/ui/css/main.css', 'public')
    .css('source/ui/css/docs.css', 'public')