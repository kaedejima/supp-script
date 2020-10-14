window.onload = function load() {
}

$(document).ready(function () {
  $(".auto-save").blur(function (a) {
    let input_value = $(this).val();
    // body or role?
    let element_class = $(this).attr('class').substr(-4, 4);
    // order_num is the id
    let element_id = parseInt($(this).attr('id'));
    let url_id = $('#id_link').attr('href');

    // var member_name = document.querySelector('.member-name').children;
    // var member_info = [];
    // for (let i = 0; i < member_name.length; i++){
    //   member_info.push([member_name[i].textContent, member_name[i].className.replace(/\r?\n|\r/g, "").split(/[ ]+/)[1]]);
    // }
    console.log(member_info);
    console.log(url_id + "/auto-save");
    console.log("input val: " + input_value + '\n class: ' + element_class + '\n id: ' + element_id);
    // $.ajax({
    //     success: function () {
    //     if (element_class == 'role') {
    //       console.log(input_value);
    //       console.log(member_info);
    //       for (let i = 0; i < member_name.length; i++) {
    //         if (input_value == member_info[i][0]) {
    //           console.log($(this));
    //           // var old_class = $(this).parent().classList[0];
    //           // $(this).parent().classList.removeClass(old_class);
    //           // $(this).parent().classList.add(member_info[i][1]);
    //         }
    //       }
    //     }
    //   }
    // });
    $.ajax(url_id + "/auto-save", {
      type: "GET",
      data: {
        element_id: element_id,
        role_body: element_class,
        input_value: input_value
      },
      datatype: 'json'
    });
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

$(document).on("click", ".delete-btn", function () {
  var id_url = $(this).attr('id');
  var willDelete = confirm("Would like to delete this script?\nこの台本を削除しますか？");
  if (willDelete) {
    // var request = new XMLHttpRequest();
    // request.open("GET", id_url, true);
    // request.send();
    location.href=id_url;
  }
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