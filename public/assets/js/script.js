$(function () {
  var idNo = 1;
  $(document).on("click", ".add", function () {
    $(this).parent().clone(true)
      .removeAttr("id")
      .removeClass("notDisp")
      .find("input[name=ctbt_0]")
      .attr("name", "ctbt_" + idNo).end().insertAfter($(this).parent());
    idNo++;
  });
});

$(document).on("click", "#new-script", function () {
  let ctbtCount = document.querySelectorAll('.ctbt').length;
  make_hidden('ctbt_count', ctbtCount, 'NEWSCRIPT');
  alert('number of contributors are: ' + ctbtCount);
});

$(document).on("click", "#login-btn", function () {
  let pwd = document.querySelectorAll('#pwd').text();
  alert('pwd: ' + pwd);
});

function make_hidden(name, value, formname) {
  var q = document.createElement('input');
  q.type = 'hidden';
  q.name = name;
  q.value = value;
  if (formname) {
    if (document.forms[formname] == undefined) {
      console.error("ERROR: form " + formname + " is not exists.");
    }
    document.forms[formname].appendChild(q);
  } else {
    document.forms[0].appendChild(q);
  }
}

// $(document).on("click", ".add", function () {
//   $(this).parent().clone(true).insertAfter($(this).parent());
// });

// $(document).on("click", ".del", function () {
//   var target = $(this).parent();
//   if (target.parent().children().length > 1) {
//     target.remove();
//   }
// });