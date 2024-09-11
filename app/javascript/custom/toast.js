import { Toast } from "bootstrap"
document.addEventListener('turbo:load', function() {
  var toastElList = [].slice.call(document.querySelectorAll('.toast'));
  toastElList.forEach(function (toastEl) {
    var toast = new Toast(toastEl, {
      autohide: true
    });

    toast.show();

    setTimeout(function () {
      toastEl.classList.add('hide');
      toast.hide();
    }, 2000);
  });
});
