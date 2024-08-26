document.addEventListener('turbo:load', function() {
  const blocksField = document.getElementById('blocks');
  const startTimeField = document.getElementById('start_time');
  const endTimeField = document.getElementById('end_time');
  const totalPriceField = document.getElementById('total_price');
  const voucherCheckboxes = document.querySelectorAll("input[name='voucher_ids[]']");
  const priceAlert = document.getElementById('price-alert');
  const generalAlert = document.getElementById('general-booking-alert')
  const pricePerBlock = document.getElementById('price-per-block').textContent;
  const blockTime = document.getElementById('block-time').textContent;

  function calculateEndTimeAndTotalPrice() {
    const blocks = parseInt(blocksField.value) || 0;
    const startTime = startTimeField.value;
    if (startTime) {
      const startTimeParts = startTime.split(':');
      let endHour = parseInt(startTimeParts[0]) + blocks * blockTime;
      let endMinutes = startTimeParts[1];
      if (endHour >= 24) {
        endHour -= 24;
      }
      endTimeField.value = `${String(endHour).padStart(2, '0')}:${endMinutes}`;
    }
    const selectedVouchers = Array.from(voucherCheckboxes)
      .filter(checkbox => checkbox.checked)
      .map(checkbox => parseFloat(checkbox.getAttribute('data-price')) || 0);

    const totalPrice = (blocks * pricePerBlock) + selectedVouchers.reduce((sum, price) => sum - price, 0);
    totalPriceField.value = totalPrice.toFixed(2);

    if (totalPrice < 0) {
      priceAlert.style.display = 'block';
      totalPriceField.value = 0
    } else {
      priceAlert.style.display = 'none';
    }
  }

  blocksField.addEventListener('input', calculateEndTimeAndTotalPrice);
  startTimeField.addEventListener('input', calculateEndTimeAndTotalPrice);
  voucherCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', calculateEndTimeAndTotalPrice);
  });

  const bookingButton = document.getElementById('submit_button_booking');

  bookingButton.addEventListener('click', function(event) {
    const startTimeValue = startTimeField.value.trim();
    const totalPrice = totalPriceField.value.trim() ;
    const dateValue = document.getElementById('user-date-booking').value.trim();

    if (!dateValue || !blockTime || !startTimeValue || totalPrice < 0) {
      event.preventDefault();
      generalAlert.style.display = 'block';
    } else {
      generalAlert.style.display = 'block';
    }
  });

  var modal = document.getElementById('myModal');

  var btn = document.getElementById('showModal');

  var span = document.getElementsByClassName('close')[0];

  btn.onclick = function() {
      modal.style.display = 'block';
  }

  span.onclick = function() {
      modal.style.display = 'none';
  }

  window.onclick = function(event) {
      if (event.target == modal) {
          modal.style.display = 'none';
      }
  }
});
