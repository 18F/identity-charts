function albErrors() {
  var errors4XXData = REPORTS["alb_4xx_errors"];
  var errors5XXData = REPORTS["alb_5xx_errors"];
  var ctx = document.getElementById("alb_errors").getContext("2d");

  var chart = new Chart(ctx, {
    type: "line",
    data: {
      labels: errors4XXData.map(function(datum) {
        return datum.label;
      }),
      datasets: [
        {
          label: "4XX Errors",
          data: errors4XXData.map(function(datum, index) {
            return datum.value + errors5XXData[index].value; // Height of this line is both 4XX and 5XX errors
          }),
          borderColor: "rgb(245,214,0,0.75)",
          backgroundColor: "rgb(245,214,0,0.75)",
          pointRadius: 0,
        },
        {
          label: "5XX Errors",
          data: errors5XXData.map(function(datum) {
            return datum.value;
          }),
          borderColor: "rgb(171,20,47, 0.75)",
          backgroundColor: "rgb(171,20,47, 0.75)",
          pointRadius: 0,
        },
      ],
    },
    options: {
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
albErrors();
