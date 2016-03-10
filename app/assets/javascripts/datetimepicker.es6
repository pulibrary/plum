jQuery(() => {
  $(".timepicker").datetimepicker({
    timeFormat: "HH:mm:ssZ",
    separator: "T",
    dateFormat: "yy-mm-dd",
    timezone: "0",
    showTimezone: false,
    showHour: false,
    showMinute: false,
    showSecond: false,
    hourMax: 0,
    minuteMax: 0,
    secondMax: 0
  })
})
