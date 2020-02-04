/*
  Sign ins today chart
*/
function authenticationsByHour() {
  var data = REPORTS["authentications_today_by_hour"];
  var ctx = document
    .getElementById("authentications_today_by_hour")
    .getContext("2d");
  var chart = new Chart(ctx, {
    type: "bar",
    data: {
      labels: data.map(function(datum) {
        return datum.label;
      }),
      datasets: [
        {
          data: data.map(function(datum) {
            return datum.value;
          }),
          backgroundColor: "rgb(32,84,147, 0.75)",
        },
      ],
    },
    options: {
      legend: { display: false },
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        yAxes: [
          {
            ticks: {
              beginAtZero: true,
            },
          },
        ],
      },
    },
  });
}
authenticationsByHour();

/*
  Sign ins this week chart
*/
function authenticationsByDay() {
  var data = REPORTS["authentications_this_week_by_hour"];
  var ctx = document
    .getElementById("authentications_this_week_by_hour")
    .getContext("2d");
  var chart = new Chart(ctx, {
    type: "line",
    data: {
      labels: data.map(function(datum) {
        return "";
      }),
      datasets: [
        {
          data: data.map(function(datum) {
            return datum.value;
          }),
          borderColor: "rgb(32,84,147, 0.75)",
          backgroundColor: "rgb(0,0,0,0)",
          pointRadius: 0,
        },
      ],
    },
    options: {
      legend: { display: false },
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        yAxes: [
          {
            ticks: {
              beginAtZero: true,
            },
          },
        ],
      },
    },
  });
}
authenticationsByDay();

/*
  Sign ins today ticker
*/
var auths_today_elm = document.querySelector("#authentications_today");
var auths_today = REPORTS["authentications_today"];
auths_today_elm.innerHTML =
  "<small>Total sign ins today:</small><br>" + auths_today;
