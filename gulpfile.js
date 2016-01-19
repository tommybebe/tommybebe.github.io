'use strict';

var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var browserSync = require('browser-sync');
var reload = browserSync.reload;
var fs = require('fs');

gulp.task('default', [], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './framer'
    }
  });

  gulp.watch(['./framer/app.coffee', './framer/index.html', './framer/styles/main.css'], reload);
});

gulp.task('mp', [], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './myphone'
    }
  });

  gulp.watch(['./myphone/**'], reload);
});

gulp.task('proto', [], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './prototypes'
    }
  });

  gulp.watch(['./prototypes/**'], reload);
});
