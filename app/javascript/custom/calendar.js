document.addEventListener("turbo:load", function() {
  const indicator = document.getElementById("current-time-indicator");
  if (!indicator) return;

  const now = new Date();
  // 6:00 AM
  const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 6, 0, 0);
  // 11:30 PM
  const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 30, 0);

  if (now < startOfDay || now > endOfDay) {
    indicator.style.display = "none";
    return;
  }
  // Total minutes from 6:00 AM to 11:30 PM
  const totalMinutesInDay = (endOfDay - startOfDay) / (1000 * 60);
  // Minutes since 6:00 AM
  const minutesSinceStartOfDay = (now - startOfDay) / (1000 * 60);

  const dayCell = document.querySelector(".day-cell.today");
  const dayCellHeight = dayCell.offsetHeight;
  const timeSlot = document.querySelector(".time-slot");
  const timeSlotHeight = timeSlot.offsetHeight;

  const blockMinute = 30;
  const toNowMinutes = (now.getHours() - 6) * 60 + now.getMinutes();
  const blocks = Math.round(toNowMinutes / blockMinute * 10) / 10;
  const indicatorTop = blocks * timeSlotHeight + dayCellHeight

  // Set the width of the indicator to match the width of the current day cell
  const dayCellWidth = dayCell.offsetWidth;
  indicator.style.width = `${dayCellWidth}px`;
  indicator.style.top = `${indicatorTop}px`;
  indicator.style.left = "0";
  indicator.style.display = "block";

  // Position the indicator within the current day cell
  dayCell.appendChild(indicator);

  // updateCurrentTimeIndicator();
  // setInterval(updateCurrentTimeIndicator, 60000);
});
