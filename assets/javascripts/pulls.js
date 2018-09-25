var pullToggleSidebarDisplay = function () {
  var main = document.getElementById('main'),
    files  = document.getElementById('tab-content-files');

  var isTabContentFiles = files.style.display !== 'none';

  main.classList.toggle('nosidebar', isTabContentFiles);
};

$(document).ready(function() {
  if (! document.body.classList.contains('action-show')) {
    return;
  }

  $('.pull__tabs').click(pullToggleSidebarDisplay);

  pullToggleSidebarDisplay();

  $('.pulls__merge a').click(function() {
    $('#pull-merge-instructions').toggle();

    return false;
  });
});

window.pullSelectBranch = function(kind, branch) {
  if (! branch) {
    branch = document.getElementById('pull-commit-custom').value;
  }

  document.getElementById('pull-commit-label-' + kind).innerText = branch;
  document.getElementById('pull-commit-input-' + kind).value = branch;
};
