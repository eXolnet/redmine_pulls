var pullToggleSidebarDisplay = function () {
  var main = document.getElementById('main'),
    changes  = document.getElementById('tab-content-changes');

  var isTabContentChanges = changes.style.display !== 'none';

  main.classList.toggle('nosidebar', isTabContentChanges);
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

  $('#pull-comment-form').show();
});

window.pullSelectBranch = function(kind, branch) {
  if (! branch) {
    branch = document.getElementById('pull-commit-custom').value;
  }

  document.getElementById('pull-commit-label-' + kind).innerText = branch;
  document.getElementById('pull-commit-input-' + kind).value = branch;
};
