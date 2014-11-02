var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var browserSync = require('browser-sync');
var reload = browserSync.reload;

gulp.task('serve', [], function(){
  browserSync({
    notify: true,
    open: false,
    port: 9000,
    server: {
      baseDir: './'
    }
  });

  gulp.watch(['./app.coffee', './index.html', './styles/main.css'], reload);
});