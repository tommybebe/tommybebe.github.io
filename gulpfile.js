var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var browserSync = require('browser-sync');
var reload = browserSync.reload;

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