function docAuthDropOff() {
  var data = REPORTS["weekly_doc_auth_dropoff_rates"];
  var ctx = document.getElementById("doc_auth_drop_off").getContext("2d");

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
          borderColor: "rgb(0,162,196,0.75)",
          backgroundColor: "rgb(0,162,196,0.75)",
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
docAuthDropOff();
