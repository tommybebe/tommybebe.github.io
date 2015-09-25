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

gulp.task('setting', [], (cb)=>{
  let pages = fs.readdirSync('./daive/pages');
  let string = 'window.routes = '+JSON.stringify(pages.filter(page=> page.match(/coffee$/)));
  fs.writeFile('./daive/config.js', string, (err)=>{
    cb();
  });
});

gulp.task('daive', ['setting'], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './daive'
    }
  });

  gulp.watch(['./daive/**'], reload);
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

gulp.task('string', [], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './string'
    }
  });

  gulp.watch(['./string/app.coffee', './string/index.html', './string/styles/main.css'], reload);
});