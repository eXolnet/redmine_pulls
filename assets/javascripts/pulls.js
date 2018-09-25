var pullToggleSidebarDisplay = function () {
  var main = document.getElementById('main'),
    files  = document.getElementById('tab-content-files');

  var isTabContentFiles = files.style.display !== 'none';

  main.classList.toggle('nosidebar', isTabContentFiles);
};

$(document).ready(function() {
  $('.pull__tabs').click(pullToggleSidebarDisplay);

  pullToggleSidebarDisplay();

  $('.pulls__merge a').click(function() {
    $('#pull-merge-instructions').toggle();

    return false;
  });
});
