var idNo = 1;
window.onload = function load() {
  // idNo = 1;
}
$(function () {
  $(document).on("click", ".add", function () {
    $(this).parent().clone(true)
      .removeAttr("id")
      .removeClass("notDisp")
      .find("input[name=ctbt_0]")
      .attr("name", "ctbt_" + idNo.toString())
      .end()
      .insertAfter($(this).parent());
    idNo++;
  });
});

$(document).ready(function () {
  $(".auto-save").blur(function (a) {
    let input_value = $(this).val();
    // body or role?
    let element_class = $(this).attr('class').substr(-4, 4);
    // order_num is the id
    let element_id = parseInt($(this).attr('id'));
    let url_id = $('#id_link').attr('href');
    console.log(url_id + "/auto-save");
    console.log("input val: " + input_value + '\n class: ' + element_class + '\n id: ' + element_id);
    $.ajax(url_id + "/auto-save", {
      type: "GET",
      data: {
        element_id: element_id,
        role_body: element_class,
        input_value: input_value
      },
      datatype: 'json'
    })
    // alert('saved' + input_value);
  });
});

$(document).on("click", "#new-script", function () {
  let ctbtCount = document.querySelectorAll('.ctbt').length;
  make_hidden('ctbt_count', ctbtCount, 'NEWSCRIPT');
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