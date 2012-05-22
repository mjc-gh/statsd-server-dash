$(function() {
	// Get the data via AJAX request.
	var opts = { type: 'GET', dataType: 'json', headers: { Accept: 'application/json'} };

	$.ajax(location.href, opts).done(function(data) {
		if (data.invalid) {
			console.debug("error");
		} else {
			$.plot(
				$(".graph"),
				data,
				{
					xaxis: {
						mode: "time",
						timeformat: "%h:%M %p"
					},
					yaxis: {
						min: 0
					},
					points: { show: true },
					lines: { show: true }
				}
			);
		}
	});
});
