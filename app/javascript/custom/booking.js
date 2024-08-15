document.addEventListener("turbo:load", function() {
  const blocksField = document.getElementById("blocks");
  const startTimeField = document.getElementById("start_time");
  const endTimeField = document.getElementById("end_time");
  const totalPriceField = document.getElementById("total_price");
  
  const pricePerBlock = document.getElementById("price-per-block").textContent; 
  const blockTime = document.getElementById("block-time").textContent; 

  function calculateEndTimeAndTotalPrice() {
    const blocks = parseInt(blocksField.value) || 0;
    const startTime = startTimeField.value;
    if (startTime) {
      const startTimeParts = startTime.split(":");
      let endHour = parseInt(startTimeParts[0]) + blocks * blockTime;
      let endMinutes = startTimeParts[1];
      if (endHour >= 24) {
        endHour -= 24;
      }
      endTimeField.value = `${String(endHour).padStart(2, '0')}:${endMinutes}`;
    }
    const totalPrice = blocks * pricePerBlock;
    totalPriceField.value = totalPrice;
  }

  blocksField.addEventListener("input", calculateEndTimeAndTotalPrice);
  startTimeField.addEventListener("input", calculateEndTimeAndTotalPrice);
});  
